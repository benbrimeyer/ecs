local CollectionService = game:GetService("CollectionService")
local getComponentData = require(script.Parent.getComponentData)

return function(entityOrInstance, components)
	local instance = type(entityOrInstance) == "table" and entityOrInstance.getInstance() or entityOrInstance

	for _, componentName in ipairs(components) do
		local componentInstance = getComponentData(instance, componentName)
		if componentInstance then
			componentInstance:Destroy()
		end

		CollectionService:RemoveTag(instance, componentName)
	end
end
