local Attributes = require(script:FindFirstAncestor("Source").Attributes)

local getEntity = require(script.getEntity)
local createPrefab = require(script.createPrefab)
local createArchetype = require(script.createArchetype)
local getComponentData = require(script.getComponentData)
local removeComponentsFromEntity = require(script.removeComponentsFromEntity)
local createEntity = require(script.createEntity)
local forEach = require(script.forEach)

return {
	CreatePrefab = createPrefab,
	CreateArchetype = createArchetype,
	CreateEntity = createEntity,
	AddComponentData = function(entity, componentName, data)
		-- TODO: have minified share this code
		local componentInstance = getComponentData(entity, componentName)

		for key, value in pairs(data) do
			Attributes.setAttribute(componentInstance, key, value)
		end
	end,
	RemoveComponents = function(entity, ...)
		removeComponentsFromEntity(entity, {...})
	end,
	GetComponentData = getComponentData,
	ForEach = forEach,
	GetEntity = getEntity
}
