return function(...)
	return setmetatable(
		{
			type = "EntityPrefab",
			componentNames = {...}
		},
		{
			__tostring = function(t)
				return string.format("<%s: %s>", t.type, string.format("componentNames = %s", table.concat(t.componentNames, ", ")))
			end
		}
	)
end
