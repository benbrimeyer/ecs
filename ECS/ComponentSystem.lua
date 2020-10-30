return {
	extend = function(_self, name)
		return setmetatable(
			{
				init = function()
				end,
				onUpdate = function()
					error("Should have overridden onUpdate after calling ComponentSystem:extend")
				end
			},
			{
				__tostring = function()
					return "<ComponentSystem: " .. name .. ">"
				end
			}
		)
	end
}
