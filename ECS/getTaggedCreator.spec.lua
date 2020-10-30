local llama = require(script:FindFirstAncestor("Packages").llama)

local getTaggedCreator = require(script.Parent.getTaggedCreator)
local createMockEvent = require(script:FindFirstAncestor("Source").Tests.createMockEvent)

return function()
	describe(
		"WHEN constructed with collectionService mock",
		function()
			beforeAll(
				function()
					-- ! Hack to satisfy selene lint
					local expect = expect

					expect.extend(
						{
							onlyHas = function(actual, ...)
								local args = {...}
								local pass = true
								local missingArg = nil
								local extraKey = nil
								for _, arg in ipairs(args) do
									if not llama.Set.has(actual, arg) then
										pass = false
										missingArg = arg
										break
									end
								end

								for key, _ in pairs(actual) do
									if not table.find(args, key) then
										pass = false
										extraKey = key
										break
									end
								end

								return {
									pass = pass,
									message = missingArg and string.format("Actual value is missing: %q", tostring(missingArg)) or
										extraKey and string.format("Actual value has extra key: %q", tostring(extraKey)) or
										"Expected anything but"
								}
							end
						}
					)
				end
			)

			beforeEach(
				function(context)
					local collectionService = {
						taggedItems = {},
						addedSignals = {},
						removedSignals = {},
						HasTag = function(self, instance, tag)
							return (self.taggedItems[tag] or {})[instance]
						end,
						GetTagged = function(self, tag)
							return llama.Set.toList(self.taggedItems[tag] or {})
						end,
						GetInstanceAddedSignal = function(self, tag)
							local signal = self.addedSignals[tag]
							if signal then
								return signal
							end

							local newSignal = createMockEvent()
							self.addedSignals[tag] = newSignal
							return newSignal
						end,
						GetInstanceRemovedSignal = function(self, tag)
							local signal = self.removedSignals[tag]
							if signal then
								return signal
							end

							local newSignal = createMockEvent()
							self.removedSignals[tag] = newSignal
							return newSignal
						end
					}

					context.createInstance = function(...)
						local tags = {...}
						local instance =
							setmetatable(
							{
								Destroy = function(self)
									-- iterate twice so when signals fire, it's all updated
									for _, tag in ipairs(tags) do
										if collectionService.taggedItems[tag] then
											collectionService.taggedItems[tag][self] = nil
										end
									end

									for _, tag in ipairs(tags) do
										-- fire signal
										local signal = collectionService.removedSignals[tag]
										if signal then
											signal.fire(self)
										end
									end
								end
							},
							{
								__tostring = function()
									return "<instance: " .. table.concat(tags, ",") .. ">"
								end
							}
						)

						-- iterate twice so when signals fire, it's all updated
						for _, tag in ipairs(tags) do
							-- add to GetTagged cache
							collectionService.taggedItems[tag] = collectionService.taggedItems[tag] or {}
							collectionService.taggedItems[tag][instance] = true
						end
						for _, tag in ipairs(tags) do
							-- fire signal
							local signal = collectionService.addedSignals[tag]
							if signal then
								signal.fire(instance)
							end
						end

						return instance
					end

					context.getTagged = getTaggedCreator(collectionService)
				end
			)

			afterEach(
				function(context)
					context.getTagged:Destroy()
				end
			)

			describe(
				"GIVEN one tag",
				function()
					it(
						"SHOULD return foo in chunk when created before invoked",
						function(context)
							local foo = context.createInstance("foo")
							local chunk = context.getTagged("foo")

							expect(chunk).to.onlyHas(foo)
						end
					)

					it(
						"SHOULD return foo in chunk when created after invoked",
						function(context)
							context.getTagged("foo")
							local foo = context.createInstance("foo")
							local chunk = context.getTagged("foo")

							expect(chunk).to.onlyHas(foo)
						end
					)

					it(
						"SHOULD return remove items from chunk when they are destroyed",
						function(context)
							local foo1 = context.createInstance("foo")
							local foo2 = context.createInstance("foo")
							local chunk1 = context.getTagged("foo")
							expect(chunk1).to.onlyHas(foo1, foo2)

							foo1:Destroy()

							local chunk2 = context.getTagged("foo")
							expect(chunk2).to.onlyHas(foo2)
						end
					)
				end
			)

			describe(
				"GIVEN two tags",
				function()
					it(
						"SHOULD union when created before invoked",
						function(context)
							local foo_bar = context.createInstance("foo", "bar")
							context.createInstance("foo")
							context.createInstance("bar")

							local chunk = context.getTagged("foo", "bar")

							expect(chunk).to.onlyHas(foo_bar)
						end
					)

					it(
						"SHOULD union when created after invoked",
						function(context)
							context.getTagged("foo", "bar")

							local foo_bar = context.createInstance("foo", "bar")
							context.createInstance("foo")
							context.createInstance("bar")

							local chunk = context.getTagged("foo", "bar")
							expect(chunk).to.onlyHas(foo_bar)
						end
					)
				end
			)

			describe(
				"GIVEN five tags",
				function()
					it(
						"SHOULD union when created before invoked",
						function(context)
							local all_1 = context.createInstance("a", "b", "c", "d", "e")
							local chunk = context.getTagged("a", "b", "c", "d", "e")

							expect(chunk).to.onlyHas(all_1)
						end
					)

					it(
						"SHOULD union when created after invoked",
						function(context)
							context.getTagged("a", "b", "c", "d", "e")

							local all_1 = context.createInstance("a", "b", "c", "d", "e")

							local chunk = context.getTagged("a", "b", "c", "d", "e")
							expect(chunk).to.onlyHas(all_1)
						end
					)

					it(
						"SHOULD handle complicated cases",
						function(context)
							local all_1 = context.createInstance("a", "b", "c", "d", "e")
							context.createInstance("a", "b", "e")
							context.createInstance("b", "c", "d")
							context.getTagged("a", "b", "c", "d", "e")

							local all_2 = context.createInstance("a", "b", "c", "d", "e")
							context.createInstance("a", "b", "e")
							context.createInstance("b", "c", "d")
							context.createInstance("a", "b", "c", "e")

							local all_with_extra = context.createInstance("a", "b", "c", "d", "e", "f")

							local chunk = context.getTagged("a", "b", "c", "d", "e")
							expect(chunk).to.onlyHas(all_1, all_2, all_with_extra)
						end
					)
				end
			)
		end
	)
end
