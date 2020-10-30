local Attributes = require(script:FindFirstAncestor("Source").Attributes)

local entitiesCache = {}
-- TODO: Will leak unless we have a DescendantRemoving event on Workspace

return function(instance)
	if entitiesCache[instance] then
		return entitiesCache[instance]
	end

	local newEntity =
		setmetatable(
		{
			type = "Entity",
			getInstance = function()
				return instance
			end,
			Destroy = function()
				entitiesCache[instance] = nil
				instance:Destroy()
			end
		},
		{
			__index = function(_, key)
				local real = instance[key]
				if real then
					if type(real) == "function" then
						error(string.format("Cannot call methods on entities. Called %q", key))
					else
						if typeof(real) == "Instance" then
							-- wrap attribute
							return setmetatable(
								{
									type = "AttributeShim"
								},
								{
									__index = function(_, attribute)
										return Attributes.getAttribute(real, attribute)
									end,
									__newindex = function(_, attribute, value)
										Attributes.setAttribute(real, attribute, value)
									end
								}
							)
						else
							return real
						end
					end
				else
					error(string.format("Property of entity %q is not found", key))
				end
			end,
			__newindex = function(_, key, value)
				instance[key] = value
			end
		}
	)

	entitiesCache[instance] = newEntity

	return newEntity
end
