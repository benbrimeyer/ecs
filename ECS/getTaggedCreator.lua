local llama = require(script:FindFirstAncestor("Packages").llama)

return function(collectionService)
	local CollectionService = collectionService or game:GetService("CollectionService")

	local chunksById = {}
	local updateChunksByComponent = {}
	local connections = {}

	local function hasAllTags(instance, tags)
		for _, tag in ipairs(tags) do
			if not CollectionService:HasTag(instance, tag) then
				return false
			end
		end

		return true
	end

	local function subscribeComponent(component)
		updateChunksByComponent[component] = updateChunksByComponent[component] or {}

		table.insert(
			connections,
			CollectionService:GetInstanceAddedSignal(component):Connect(
				function(instance)
					for _, chunk in ipairs(updateChunksByComponent[component]) do
						-- if not in chunk already
						if not chunk:has(instance) then
							if hasAllTags(instance, chunk.components) then
								chunk:add(instance)
							end
						end
					end
				end
			)
		)

		table.insert(
			connections,
			CollectionService:GetInstanceRemovedSignal(component):Connect(
				function(instance)
					for _, chunk in ipairs(updateChunksByComponent[component]) do
						if chunk:has(instance) then
							chunk:remove(instance)
						end
					end
				end
			)
		)
	end

	local function serializeComponents(...)
		local components =
			llama.List.sort(
			{...},
			function(a, b)
				return a < b
			end
		)

		return table.concat(components, "+")
	end

	local Chunk = {}
	Chunk.__index = Chunk
	Chunk.__tostring = function(t)
		return "<Chunk: " .. llama.Dictionary.count(t.set) .. " items>"
	end

	function Chunk.new(id, components)
		local self = {
			id = id,
			components = components,
			set = {}
		}
		return setmetatable(self, Chunk)
	end

	function Chunk:union(set)
		self.set = llama.Set.union(self.set, set)
	end

	function Chunk:add(instance)
		self.set[instance] = true
	end

	function Chunk:remove(instance)
		self.set[instance] = nil
	end

	function Chunk:has(instance)
		return llama.Set.has(self.set, instance)
	end

	local function getTagged(_, ...)
		local components = {...}
		local componentId = serializeComponents(...)

		local chunkSet = chunksById[componentId]
		if not chunkSet then
			chunkSet = Chunk.new(componentId, components)

			-- construct chunk set w/ existing items in world
			local sets =
				llama.List.map(
				components,
				function(component)
					local items = CollectionService:GetTagged(component)
					return llama.List.toSet(items)
				end
			)
			local intersectionSet = llama.Set.intersect(unpack(sets))
			chunkSet:union(intersectionSet)

			-- now chunk is created, assign it to list of all components
			for _, component in ipairs(components) do
				subscribeComponent(component)
				table.insert(updateChunksByComponent[component], chunkSet)
			end
			-- and save it for later
			chunksById[componentId] = chunkSet
		end

		return chunkSet.set
	end

	return setmetatable(
		{
			Destroy = function()
				for _, connection in ipairs(connections) do
					connection:Disconnect()
				end
			end
		},
		{
			__call = getTagged
		}
	)
end
