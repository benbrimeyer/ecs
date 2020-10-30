local CollectionService = game:GetService("CollectionService")
local getTaggedCreator = require(script.Parent.Parent.getTaggedCreator)
local getTagged = getTaggedCreator(CollectionService)

local getEntity = require(script.Parent.getEntity)

return function(query, lambda)
	-- TODO: Eventually would be nice to support `withAny` and `withNone`
	local withAll = query.withAll
	local chunkSet = getTagged(table.unpack(withAll))

	for instance in pairs(chunkSet) do
		local entity = getEntity(instance)

		lambda(entity)
	end
end
