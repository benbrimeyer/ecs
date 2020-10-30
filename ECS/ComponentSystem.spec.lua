local ECS = require(script.Parent)

return function()
	beforeEach(
		function()
			ECS.ClearComponentData()

			local moveForwardStruct = {
				speed = 100
			}

			ECS.AddComponentData(
				{
					moveForward = moveForwardStruct
				}
			)
		end
	)

	it(
		"SHOULD work in expanded form",
		function()
			local Entities = ECS.Entities

			local myEntity = Entities.CreateEntity("translation", "moveForward")
			myEntity.Parent = game

			local success,
				message =
				pcall(
				function()
					local MovementSystem = ECS.ComponentSystem:extend("MovementSystem")

					function MovementSystem:init()
						self.entityQuery = {withAll = {"translation", "moveForward"}}
						self.lambda = function(entity)
							Entities.AddComponentData(
								entity,
								"translation",
								{
									Value = Entities.GetComponentData(entity, "moveForward", "speed")
								}
							)
						end
					end

					function MovementSystem:onUpdate()
						Entities.ForEach(self.entityQuery, self.lambda)
					end

					MovementSystem:init()
					MovementSystem:onUpdate()
					expect(myEntity).to.haveComponentData(
						"translation",
						{
							Value = 100
						}
					)
				end
			)

			myEntity:Destroy()
			if not success then
				fail(message)
			end
		end
	)

	it(
		"SHOULD work in minified form",
		function()
			local Entities = ECS.Entities

			local myEntity = Entities.CreateEntity("translation", "moveForward")
			myEntity.Parent = game

			local success,
				message =
				pcall(
				function()
					local MovementSystem = ECS.ComponentSystem:extend("MovementSystem")

					function MovementSystem:init()
						self.entityQuery = {withAll = {"translation", "moveForward"}}
						self.lambda = function(entity)
							expect(entity.translation.Value).to.equal(nil)
							expect(entity.moveForward.speed).to.equal(100)

							entity.translation.Value = entity.moveForward.speed

							expect(entity.translation.Value).to.equal(100)
						end
					end

					function MovementSystem:onUpdate()
						Entities.ForEach(self.entityQuery, self.lambda)
					end

					MovementSystem:init()
					MovementSystem:onUpdate()
					expect(myEntity).to.haveComponentData(
						"translation",
						{
							Value = 100
						}
					)
				end
			)

			myEntity:Destroy()
			if not success then
				fail(message)
			end
		end
	)

	it(
		"SHOULD throw if you don't override OnUpdate",
		function()
			local Throw = ECS.ComponentSystem:extend("Throw")

			expect(
				function()
					Throw:onUpdate()
				end
			).to.throw("Should have overridden onUpdate")
		end
	)

	it(
		"SHOULD tostring with systemName",
		function()
			local abcSystem = ECS.ComponentSystem:extend("abc")
			expect(tostring(abcSystem)).to.match("<ComponentSystem: abc>")
		end
	)
end
