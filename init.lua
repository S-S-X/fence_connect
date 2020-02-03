--[[
# fence_connect (with high probability)
#
# Testing universal connecting configurable fences.
# Featuring not so easy fence building by SX
# Adds some sneaky challenges for pro and semipro fence builders.
#
]]--

local fences = {
	{'default', 'fence_wood'},
	{'default', 'fence_acacia_wood'},
	{'default', 'fence_junglewood'},
	{'default', 'fence_pine_wood'},
	{'default', 'fence_aspen_wood'},
}

local explodenodename = function(nodename)
	local nameidx = string.find(nodename, ":", 1, true)
	local mod = string.sub(nodename, 1, nameidx)
	local name = string.sub(nodename, nameidx + 1, #nodename)
	return mod, name
end

local configurable_fence_on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	if minetest.is_protected(pos,clicker) then return end

	local index = meta:get_int("fence_connect_index") or 0
	index = index % 5 + 1 -- Rotate index 1 - 5
	local mod, name = explodenodename(node.name)
	local nextname = meta:get_string("fence_connect_next")
	if nextname == "" then
		nextname = "fence_connect:" .. name .. "_1"
	end
	local realnode = meta:get_string("fence_connect_node")
	if realnode == "" then
		realnode = node.name
	end

	if index == 5 then
		nextname = realnode
	else
		local _, realname = explodenodename(realnode)
		nextname = "fence_connect:" .. realname .. "_" .. index
	end
	minetest.swap_node(pos, {name = nextname})

	meta = minetest.get_meta(pos)
	meta:set_int("fence_connect_index", index)
	meta:set_string("fence_connect_next", nextname)
	meta:set_string("fence_connect_node", realnode)
end

local register_configurable_fence = function(fence, nodes)
	local nodename = fence[1] .. ":" .. fence[2]
	if not minetest.registered_nodes[nodename] then
		print("ERROR: Node not registered: " .. nodename)
		return
	end
	local clone = function(source)
		local result = {}
		for k,v in pairs(minetest.registered_nodes[nodename]) do
			result[k] = v
		end
		return result
	end

	-- Default node has default connections
	local params = clone(nodename)
	params.on_rightclick = configurable_fence_on_rightclick
	minetest.register_node(":" .. nodename, params)

	-- Connect with many nodes through larger common groups
	params = clone(nodename)
	params.connects_to = {
		"group:fence",
		"group:wood",
		"group:tree",
		"group:soil",
		"group:stone",
		"group:wall",
		"group:wool",
	}
	params.drop = nodename
	params.on_rightclick = configurable_fence_on_rightclick
	params.not_in_creative_inventory = 1
	params.not_in_craft_guide = 1
	minetest.register_node("fence_connect:" .. fence[2] .. "_1", params)

	-- All nodes collected with search function
	params = clone(nodename)
	params.on_rightclick = configurable_fence_on_rightclick
	params.connects_to = nodes
	params.drop = nodename
	params.not_in_creative_inventory = 1
	params.not_in_craft_guide = 1
	minetest.register_node("fence_connect:" .. fence[2] .. "_2", params)

	-- Nothing, never connect. Not even with another fence.
	params = clone(nodename)
	params.on_rightclick = configurable_fence_on_rightclick
	params.connects_to = nil
	params.drop = nodename
	params.not_in_creative_inventory = 1
	params.not_in_craft_guide = 1
	minetest.register_node("fence_connect:" .. fence[2] .. "_3", params)

	-- Connect only with another fence
	params = clone(nodename)
	params.on_rightclick = configurable_fence_on_rightclick
	params.connects_to = {"group:fence"}
	params.drop = nodename
	params.not_in_creative_inventory = 1
	params.not_in_craft_guide = 1
	minetest.register_node("fence_connect:" .. fence[2] .. "_4", params)
end

print("Fence_connect started collecting connectable nodes")
local count = 0
local nodes = {"group:fence"}
for name,node in pairs(minetest.registered_nodes) do
	if node.walkable
		and node.pointable
		and node.diggable
		and not node.buildable_to
		and not node.floodable
		and not node.climbable
		and node.liquidtype == "none"
		and node.drowning == 0
		and node.damage_per_second == 0
		and (not node.waving or node.waving == 0)
		and string.sub(node.name, 1, #'default:fence') ~= 'default:fence'
		then
		table.insert(nodes, node.name)
		count = count + 1
	end
end
for _,fence in pairs(fences) do
	register_configurable_fence(fence, nodes)
end
print("[OK] fence_connect connector groups compiled with " .. count .. " nodes")
print("[OK] fence connector loaded")
