local ComponentData = require(script.ComponentData)

return {
	Entities = require(script.Entities),
	ComponentSystem = require(script.ComponentSystem),
	AddComponentData = ComponentData.AddComponentData,
	ClearComponentData = ComponentData.ClearComponentData
}
