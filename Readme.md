Developed ECS library, loosely based on Unity's ECS api.

It uses instances as entities and attributes as components. Systems are objects with an onUpdate method that can be overridden.

### Demo:
```lua
local ECS = require(...)

ECS.AddComponentData({
	-- define a struct that all future movement components will use as a template
	movement = {
		speed = 9001,
		gravityPercent = 100,
	}
})

-- Create an instance archetype that will be used as a template for entities
local blockArchetype = Instance.new("Part")
blockArchetype.Anchored = true
blockArchetype.Size = Vector3.new(2, 2, 2)

-- Define entities by passing in archetypes and strings for tags in any order
local myCustomEntity = ECS.Entities.CreateEntity(blockArchetype, "movement")
print(myCustomEntity.movement.speed) -- 9001
print(myCustomEntity.Anchored) -- true

local MovementSystem = ECS.ComponentSystem:extend("Movement")

function MovementSystem:onUpdate()
	-- Create an entity query, focusing on all entities with "movement"
	ECS.Entities.ForEach({ withAll = { "movement" }}, function(entity)
		entity.movement.speed -= entity.movement.gravityPercent
		print(entity.Size) -- Vector3(2, 2, 2)
	end)
end
```


### Concepts

#### Entities, Components, and Systems
**Entities** are the subjects. Entities are the blocks/items with child **components** which may have attributes that hold some state. **Systems** exists to query matching entities based on their current components and running operations on them.

We can create entities by calling `ECS.Entities.CreateEntity`. This method accepts a varags of components, archetypes, and prefabs. 

For starters, we can initialize our new entity with components using strings as our componentNames, like so:
```lua
local entity = ECS.Entities.CreateEntity("movement", "gravity", "emitsLight")
```

In our framework, all entities are a thin wrapper on Roblox Instances. By default, these Roblox Instances are Folders. Entities have the following methods:
- `entity.getInstance()` returns the Instance associated with the Entity
- `entity:Destroy()` destroys both the Entity and the associated Instance

If you have a reference to an entity, you can also access components and their attributes like so:
```lua
local speed = ECS.Entities.GetComponentData(entity, "movement", "speed")
```
or you can use the short-hand notation:
```lua
local speed = entity.movement.speed
```


Likewise, you can write to entity's components like so:
```lua
ECS.Entities.AddComponentData(entity, "movement", {
    speed = 100,
})
```
or short-hand notation:
```lua
entity.movement.speed = 100
```

⚠️  Note: Currently you can only add a new component to an entity using the `AddComponentData` method. Attempting to write a new component using the short-hand notation will throw. Maybe this will change in the future.

#### ComponentData
We can run `ECS.AddComponentData` to give a default structure for components constructed at runtime. For example, if we know all entities with component type `emitsLight` needs a `lightLevel` attribute, we can define a struct with `ECS.AddComponentData` that will include `lightLevel` as a default value.

#### Entity Archetypes
By default, calling `ECS.Entities.CreateEntity()` will return an entity wrapping a Folder. Most cases, however, we'll want to have entities represented by blocks or items. In these cases, we can create an Entity Archetype to pass into our CreateEntity method.

To create an Entity Archetype, first we need to create our template Instance without parenting it to the datamodel and calling `ECS.Entities.CreateArchetype`. Then we can pass the resulting archetype into our `ECS.Entities.CreateEntity` function.

```lua
local block = Instance.new("Part")
block.Size = Vector3.new(2, 2, 2)

local blockArchetype = ECS.Entities.CreateArchetype(block)
local entity = ECS.Entities.CreateEntity(blockArchetype)

assert(entity.Size == Vector3.new(2, 2, 2))
```

#### Entity Prefabs
Instead of manually passing lists of tags every time we need to create a new entity, we can create Entity Prefabs to save us some trouble. This is about as close to a "class" as we'll get in our framework.

For example, if we have a list of components any AI actor needs to function, we may create an Actor Entity Prefab like so:

```lua
local actorPrefab = ECS.Entities.CreatePrefab("health", "turnsToPlayer", "backpack")
local entity = ECS.Entities.CreateEntity(actorPrefab)
```
in our example above, entity will have the `health`, `turnsToPlayer`, and `backpack` components when created.
