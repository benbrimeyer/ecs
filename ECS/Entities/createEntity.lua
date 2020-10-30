local HttpService = game:GetService("HttpService")

local getEntity = require(script.Parent.getEntity)
local addComponentsToEntity = require(script.Parent.addComponentsToEntity)

return function(...)
	local instance = nil
	local components = {}
	local componentSet = {}
	for _, arg in ipairs({...}) do
		if type(arg) == "string" then
			local componentName = arg
			if not componentSet[componentName] then
				componentSet[componentName] = true
				table.insert(components, componentName)
			end
		elseif type(arg) == "table" then
			if arg.type == "EntityPrefab" then
				for _, componentName in ipairs(arg.componentNames) do
					if not componentSet[componentName] then
						componentSet[componentName] = true
						table.insert(components, componentName)
					end
				end
			elseif arg.type == "EntityArchetype" then
				assert(instance == nil, "Already defined archetype")
				instance = arg.instance:Clone()
			end
		end
	end

	if not instance then
		instance = Instance.new("Folder")
	end
	instance.Name = HttpService:GenerateGUID(false)

	local entity = getEntity(instance)
	addComponentsToEntity(entity, components)

	return entity
end
