local ECS = require(script.Parent)

return function()
	afterEach(
		function()
			ECS.ClearComponentData()
		end
	)

	describe(
		"Custom data types",
		function()
			it(
				"SHOULD tostring EntityPrefab",
				function()
					local Entities = ECS.Entities
					local myPrefab = Entities.CreatePrefab("foo", "bar")

					local myPrefabString = tostring(myPrefab)
					expect(myPrefabString).to.match("<EntityPrefab:")
				end
			)

			it(
				"SHOULD tostring EntityArchetype",
				function()
					local Entities = ECS.Entities
					local myArchetype = Entities.CreateArchetype(Instance.new("Folder"))

					local myArchetypeString = tostring(myArchetype)
					expect(myArchetypeString).to.match("<EntityArchetype:")
				end
			)
		end
	)

	describe(
		"Entity.CreateEntity()",
		function()
			it(
				"SHOULD return the same entity when called on same instance",
				function()
					local Entities = ECS.Entities
					local entity1 = Entities.CreateEntity()
					local entity2 = Entities.GetEntity(entity1.getInstance())
					local entity3 = Entities.GetEntity(entity1.getInstance())

					expect(entity1).to.equal(entity2).to.equal(entity3)
				end
			)
			it(
				"SHOULD create entities with components",
				function()
					local Entities = ECS.Entities
					local myPrefab = Entities.CreatePrefab("foo", "bar")
					expect(myPrefab).to.be.ok()
					local entity = Entities.CreateEntity(myPrefab)

					expect(entity.getInstance()).to.be.ok().to.inheritClass("Folder").to.haveComponentData("foo").to.haveComponentData(
						"bar"
					).to.haveCollectionServiceTag("foo").to.haveCollectionServiceTag("bar")

					Entities.AddComponentData(
						entity,
						"foo",
						{
							baz = true
						}
					)

					expect(entity.getInstance()).to.haveComponentData("foo").to.haveComponentData("foo", {baz = true})
					-- supports shorthand
					expect(entity.foo).to.be.ok()
					expect(entity.foo.baz).to.equal(true)

					Entities.RemoveComponents(entity, "foo")
					expect(entity.getInstance()).to.be.ok().to.never.haveComponentData("foo").to.haveComponentData("bar")
				end
			)

			it(
				"SHOULD not allow creation when parented to datamodel",
				function()
					local Entities = ECS.Entities
					local part = Instance.new("Part")

					part.Parent = game

					expect(
						function()
							Entities.CreateArchetype(part)
						end
					).to.throw("Given instance cannot be child of datamodel.")

					part:Destroy()
				end
			)

			it(
				"SHOULD create entities with components 2",
				function()
					local Entities = ECS.Entities
					local part = Instance.new("Part")

					local originalBrickColor = BrickColor.new("Bright red")
					part.BrickColor = originalBrickColor

					local myArchetype = Entities.CreateArchetype(part)

					part.BrickColor = BrickColor.new("Bright blue")

					local entity1 = Entities.CreateEntity(myArchetype)
					expect(entity1.getInstance()).to.be.ok().to.never.equal(part)
					expect(entity1.getInstance().BrickColor).to.equal(BrickColor.new("Bright red"))
				end
			)

			it(
				"SHOULD merge all arguments",
				function()
					local Entities = ECS.Entities
					local attachment = Instance.new("Attachment")

					local myPrefab = Entities.CreatePrefab("foo", "hello", "world")
					local myArchetype = Entities.CreateArchetype(attachment)
					local entity1 = Entities.CreateEntity(myArchetype, myPrefab, "foo", "bar")

					expect(entity1.getInstance()).to.be.ok().haveCollectionServiceTag("hello").haveCollectionServiceTag("world").haveCollectionServiceTag(
						"foo"
					).haveCollectionServiceTag("bar").inheritClass("Attachment")
				end
			)

			it(
				"SHOULD removeComponents all components",
				function()
					local Entities = ECS.Entities
					local entity1 = Entities.CreateEntity("a", "b", "c", "d")

					Entities.RemoveComponents(entity1, "a", "b", "c")
					expect(entity1).to.be.ok().to.haveComponentData("d").never.haveComponentData("a").never.haveComponentData("b").never.haveComponentData(
						"c"
					)
				end
			)

			it(
				"SHOULD not create entity with multiple archetypes",
				function()
					local Entities = ECS.Entities
					local myArchetype1 = Entities.CreateArchetype(Instance.new("Attachment"))
					local myArchetype2 = Entities.CreateArchetype(Instance.new("Attachment"))
					expect(
						function()
							Entities.CreateEntity(myArchetype1, myArchetype2)
						end
					).to.throw("Already defined archetype")
				end
			)

			it(
				"SHOULD define ComponentStruct",
				function()
					local Entities = ECS.Entities
					ECS.AddComponentData(
						{
							foo = {
								hello = "world"
							}
						}
					)

					local entity1 = Entities.CreateEntity("foo")
					expect(entity1).to.be.ok().to.haveComponentData(
						"foo",
						{
							hello = "world"
						}
					)
				end
			)

			it(
				"SHOULD throw when redefining ComponentData",
				function()
					ECS.AddComponentData(
						{
							foo = {
								hello = "world"
							}
						}
					)

					expect(
						function()
							ECS.AddComponentData(
								{
									foo = {
										hello = "world"
									}
								}
							)
						end
					).to.throw()
				end
			)

			it(
				"SHOULD allow GetComponentData to return attribute data",
				function()
					local entity = ECS.Entities.CreateEntity("foo")
					ECS.Entities.AddComponentData(entity, "foo", {hello = "world"})

					local result1 = ECS.Entities.GetComponentData(entity, "foo")
					expect(result1).to.be.ok()

					local result2 = ECS.Entities.GetComponentData(entity, "foo", "hello")
					expect(result2).to.be.ok().to.equal("world")
				end
			)
		end
	)

	describe(
		"Entities.ForEach",
		function()
			it(
				"SHOULD iterate through entities",
				function()
					local Entities = ECS.Entities
					local myPrefab = Entities.CreatePrefab("foo", "bar")
					local entity1 = Entities.CreateEntity(myPrefab)
					expect(entity1.getInstance()).to.be.ok().to.haveCollectionServiceTag("foo").to.haveCollectionServiceTag("bar")
					local entity2 = Entities.CreateEntity("foo")
					expect(entity2.getInstance()).to.be.ok().to.haveCollectionServiceTag("foo").to.never.haveCollectionServiceTag(
						"bar"
					)

					entity1.Parent = game
					entity2.Parent = game

					local success,
						message =
						pcall(
						function()
							local entitiesHit = {}
							Entities.ForEach(
								{
									withAll = {"foo", "bar"}
								},
								function(entity)
									table.insert(entitiesHit, entity)
									Entities.AddComponentData(
										entity,
										"foo",
										{
											hello = "world"
										}
									)
								end
							)

							expect(#entitiesHit).to.equal(1)
							expect(entitiesHit[1]).to.equal(entity1)
							expect(table.find(entitiesHit, entity2)).to.never.be.ok()

							expect(entity1).to.haveComponentData("foo", {hello = "world"})
							expect(entity2).to.haveComponentData("foo").to.never.haveComponentData("foo", {hello = "world"})
						end
					)

					entity1:Destroy()
					entity2:Destroy()

					if not success then
						fail(message)
					end
				end
			)

			it(
				"SHOULD iterate and allow removal",
				function()
					local Entities = ECS.Entities
					local entity1 = Entities.CreateEntity("foo")
					local entity2 = Entities.CreateEntity("foo")
					entity1.Parent = game
					entity2.Parent = game

					local success,
						message =
						pcall(
						function()
							local entitiesHit = {}
							local entityQuery = {withAll = {"foo"}}
							Entities.ForEach(
								entityQuery,
								function(entity)
									table.insert(entitiesHit, entity)
									Entities.RemoveComponents(entity, "foo")
								end
							)
							expect(#entitiesHit).to.equal(2)

							Entities.ForEach(
								entityQuery,
								function(_entity)
									fail("Should never run")
								end
							)
							expect(#entitiesHit).to.equal(2)

							expect(entity1).to.be.ok()
							expect(entity2).to.be.ok()
						end
					)

					entity1:Destroy()
					entity2:Destroy()

					if not success then
						fail(message)
					end
				end
			)
		end
	)
end
