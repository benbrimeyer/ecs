local CollectionService = game:GetService("CollectionService")
local Attributes = require(script:FindFirstAncestor("Source").Attributes)

local ComponentData = require(script.Parent.Parent.ComponentData)

return function(entityOrInstance, components)
	local instance = type(entityOrInstance) == "table" and entityOrInstance.getInstance() or entityOrInstance

	for _, componentName in ipairs(components) do
		local component = Instance.new("Folder")
		component.Name = componentName
		component.Parent = instance

		CollectionService:AddTag(instance, componentName)

		local struct = ComponentData.GetComponentData(componentName)
		if struct then
			for key, value in pairs(struct) do
				Attributes.setAttribute(component, key, value)
			end
		end
	end
end
