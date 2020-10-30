local Attributes = require(script:FindFirstAncestor("Source").Attributes)

return function(entityOrInstance, componentName, optionalKey)
	local instance = type(entityOrInstance) == "table" and entityOrInstance.getInstance() or entityOrInstance

	local componentInstance = instance:FindFirstChild(componentName)
	if componentInstance and optionalKey then
		return Attributes.getAttribute(componentInstance, optionalKey)
	end

	return componentInstance
end
