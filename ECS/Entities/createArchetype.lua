return function(instance)
	assert(instance.Parent == nil, "Given instance cannot be child of datamodel.")

	return setmetatable(
		{
			type = "EntityArchetype",
			instance = instance:Clone()
		},
		{
			__tostring = function(t)
				return string.format("<%s: %s>", t.type, string.format("instance = %s", instance.ClassName))
			end
		}
	)
end
