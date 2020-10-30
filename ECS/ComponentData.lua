local componentData = {}

return {
	GetComponentData = function(componentName)
		return componentData[componentName]
	end,
	AddComponentData = function(data)
		for componentName, struct in pairs(data) do
			assert(componentData[componentName] == nil, string.format("ComponentData for %q already exists", componentName))
			componentData[componentName] = struct
		end
	end,
	ClearComponentData = function()
		componentData = {}
	end
}
