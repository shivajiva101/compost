compost = {}
compost.items = {}
compost.groups = {}

function compost.register_item(name)
	compost.items[name] = true
end

function compost.register_group(name)
	compost.groups[name] = true
end

function compost.can_compost(name)
	if compost.items[name] then
		return true
	else
		for k, i in pairs(minetest.registered_items[name].groups) do
			if i > 0 then
				if compost.groups[tostring(k)] then
					return true
				end
			end
		end

		return false
	end
end

local function infotext(num, name)
	if num == 0 then
		return "owner: "..name.."\nhold leaves and punch to start!"
	elseif num == 1 or num == 2 then
		return "owner: "..name.."\nstage: "..num
	elseif num == 3 then
		return "owner: "..name.."\ncompost ready: punch to eject dirt!"
	end
end

local function composter(pos)
	local node_name = minetest.get_node(pos).name
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if node_name == "compost:wood_barrel_1" then
		minetest.swap_node(pos, {name = "compost:wood_barrel_2"})
		meta:set_string("infotext", infotext(2, owner))
		minetest.get_node_timer(pos):start(math.random(40,120))
	elseif node_name == "compost:wood_barrel_2" then
		minetest.swap_node(pos, {name = "compost:wood_barrel_3"})
		meta:set_string("infotext", infotext(3, owner))
	end
end

-- grass
compost.register_item("default:grass_1")
compost.register_item("default:junglegrass")

-- leaves
compost.register_group("leaves")

-- dirt
compost.register_item("default:dirt")
compost.register_item("default:dirt_with_grass")

-- stick
compost.register_item("default:stick")

-- flowers
compost.register_item("flowers:geranium")
compost.register_item("flowers:tulip")
compost.register_item("flowers:rose")
compost.register_item("flowers:dandelion_yellow")
compost.register_item("flowers:dandelion_white")

-- food
compost.register_item("farming:bread")
compost.register_item("farming:wheat")

-- groups
compost.register_group("plant")
compost.register_group("flower")

minetest.register_node("compost:wood_barrel", {
	description = "Wood Barrel",
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy = 3},
	sounds =  default.node_sound_wood_defaults(),
	on_punch = function(pos, node, puncher, pointed_thing)
		local wielded_item = puncher:get_wielded_item():get_name()
		if can_compost(wielded_item) then
			local meta = minetest.get_meta(pos)
			local name = meta:get_string("owner")
			-- swap barrel
			minetest.swap_node(pos, {name = "compost:wood_barrel_1"})
			meta:set_string("infotext", infotext(1, name))
			local w = puncher:get_wielded_item()
			-- take item if not in creative mode
			if not(minetest.setting_getbool("creative_mode")) then
				w:take_item(1)
				puncher:set_wielded_item(w)
			end
			-- initialise node timer 40-120 seconds
			minetest.get_node_timer(pos):start(math.random(40,120))
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		meta:set_string("owner", name)
		meta:set_string("infotext", infotext(0, name))
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if player:get_player_name() == owner then
			return true
		end
	end,
})

minetest.register_node("compost:wood_barrel_1", {
	description = "Wood Barrel with compost",
	tiles = {"default_wood.png^compost_compost_1.png", "default_wood.png"},
	drawtype = "nodebox",
	on_timer = composter,
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2},
			{-3/8, -1/2, -3/8, 3/8, 3/8, 3/8}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
	sounds =  default.node_sound_wood_defaults()
})

minetest.register_node("compost:wood_barrel_2", {
	description = "Wood Barrel with compost",
	tiles = {"default_wood.png^compost_compost_2.png", "default_wood.png"},
	drawtype = "nodebox",
	on_timer = composter,
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2},
			{-3/8, -1/2, -3/8, 3/8, 3/8, 3/8}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
	sounds =  default.node_sound_wood_defaults()
})

minetest.register_node("compost:wood_barrel_3", {
	description = "Wood Barrel",
	tiles = {"default_wood.png^compost_compost_3.png", "default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/2, 1/2, -3/8, 1/2},
			{-1/2, -1/2, -1/2, -3/8, 1/2, 1/2},
			{3/8, -1/2, -1/2, 1/2, 1/2, 1/2},
			{-1/2, -1/2, -1/2, 1/2, 1/2, -3/8},
			{-1/2, -1/2, 3/8, 1/2, 1/2, 1/2},
			{-3/8, -1/2, -3/8, 3/8, 3/8, 3/8}},
	},
	paramtype = "light",
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
	sounds =  default.node_sound_wood_defaults(),
	on_punch = function(pos, node, player, pointed_thing)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if player:get_player_name() ~= owner then return end
		local p = {
			x = pos.x + math.random(0, 5)/5 - 0.5,
			y = pos.y+1,
			z = pos.z + math.random(0, 5)/5 - 0.5
		}
		minetest.add_item(p, {name = "default:dirt"})
		minetest.swap_node(pos, {name = "compost:wood_barrel"})
		meta:set_string("infotext", infotext(0, owner))
	end
})

minetest.register_craft({
	output = "compost:wood_barrel",
	recipe = {
		{"default:wood", "", "default:wood"},
		{"default:wood", "", "default:wood"},
		{"default:wood", "stairs:slab_wood", "default:wood"}
	}
})

minetest.register_node("compost:compost", {
	description = "Compost",
	tiles = {"compost_compost.png"},
	groups = {crumbly = 3},
	sounds =  default.node_sound_dirt_defaults(),
})

minetest.register_node("compost:garden_soil", {
	description = "Garden Soil",
	tiles = {"compost_garden_soil.png"},
	groups = {crumbly = 3, soil=3, grassland = 1, wet = 1},
	sounds =  default.node_sound_dirt_defaults(),
})

minetest.register_craft({
	output = "compost:garden_soil",
	recipe = {
		{"compost:compost", "compost:compost"},
	}
})

if minetest.get_modpath ("tubelib") and tubelib then
	print ("[compost] found tubelib")

	-- Thanks to @joe7575
	tubelib.register_node ("compost:wood_barrel",  {
			"compost:wood_barrel_1",
			"compost:wood_barrel_2",
			"compost:wood_barrel_3"
		}, {
			on_push_item = function  (pos, side, item, player_name)
				local node = minetest.get_node (pos)

				if node.name == "compost:wood_barrel" and compost.can_compost(item:get_name()) then
					minetest.set_node(pos, {name = "compost:wood_barrel_1"})
					return true
				else
					return false
				end
			end,

			on_unpull_item = function  (pos, side, item, player_name)
				minetest.set_node(pos, {name = "compost:wood_barrel_3"})
				return true
			end,

			on_pull_item = function  (pos, side, player_name)
				local node = minetest.get_node (pos)

				if node.name == "compost:wood_barrel_3" then
					minetest.set_node(pos, {name = "compost:wood_barrel"})
					return ItemStack("compost:compost")
				end

				return nil
			end,
	})
end
