function default_ore(name,texture,tint)
	return {name..'-ore',name..'-plate',name,texture,tint}
end
local ores={}
log("starting up script")
for k,v in pairs(data.raw["resource"]) do
	if(string.find(k,"-ore")) then
		table.insert(ores,default_ore(string.sub(k,1,-5),v.icon,v.map_color))
	end
end

-- {1ore,2output,3name,4ore_texture,5tint}
for i,v in ipairs(ores) do

	if (data.raw["item"][v[1]] and data.raw["item"][v[2]]) then
		if not data.raw["item"]['el_materials_pure_'..v[3]] then
			log(v[3])
			data:extend({
				{
				name = 'el_materials_pure_'..v[3],
				type = 'item',
				icons = {{icon = '__248k__/ressources/electronic/el_materials/el_materials_pure_aluminum.png', tint=v[5]}},
				icon_size = 64,
				stack_size = 50,
				subgroup = 'el_item_subgroup_e',
				localised_name = {'item-name.el_materials_pure',{'item-name.'..v[1]}},
				order = 'a-'..v[3]..'-b',
				}
			})
		end
		if not data.raw["fluid"]['el_arc_pure_'..v[3]] then
			data:extend({
				{
					name = 'el_arc_pure_'..v[3],
					type = 'fluid',
					icons = {
						{
							icon = "__248k_bz_ore_process__/assets/metal_fluid.png"
						},
						{
							icon = v[4],
							scale=0.25,
							shift={-8,-8}
						}
					},
					localised_name = {'fluid-name.el_arc_pure',{'item-name.'..v[1]}},
					icon_size = 64,
					default_temperature = 1600,
					max_temperature = 2000,
					heat_capacity = '100kJ',
					base_color = { r=0.92, g=0.29, b=0.22 }, 
					flow_color = { r=0.92, g=0.29, b=0.22 }, 
					pressure_to_speed_ratio = 0.400, 
					flow_to_energy_ratio = 0,
					subgroup = 'el_item_subgroup_e',
					order = 'a-'..v[3]..'-c',
				}
			})
		end
		if not data.raw["recipe"]['el_purify_'..v[3]..'_recipe'] then
			data:extend({
			{
				name = 'el_purify_'..v[3]..'_recipe',
				type = 'recipe',
				enabled = 'false',
				category = 'el_purifier_category',
				normal = 
				{
					main_product = "el_materials_pure_"..v[3],
					enabled = true,
					energy_required = 1,
					ingredients = {
						{type="fluid", name="water", amount=50},
						--{type="fluid", name="steam", amount=240, temperature=165},
						{type="item", name=v[1], amount=10}
					},
					results = {
						{type="fluid", name="el_dirty_water", amount=50},
						{type="item", name="el_materials_pure_"..v[3], amount=5},
					}
				},
				expensive = 
				{
					main_product = "el_materials_pure_"..v[3],
					enabled = true,
					energy_required = 1,
					ingredients = {
						{type="fluid", name="water", amount=50},
						--{type="fluid", name="steam", amount=240, temperature=165},
						{type="item", name=v[1], amount=10}
					},
					results = {
						{type="fluid", name="el_dirty_water", amount=50},
						{type="item", name="el_materials_pure_"..v[3], amount=5},
					}
				},
				always_show_made_in = true,
				icon_size = 64,
				order = 'a-'..v[3]..'-b',
				icons = {
					{
						icon = "__248k__/ressources/fluids/el_dirty_water.png"
					},
					{
						icon = v[4],
						scale= 0.25,
						shift={-8,-8}
					}
				} 
			}})
			table.insert(data.raw["technology"]["el_purifier_tech"].effects,{ type = 'unlock-recipe',recipe = 'el_purify_'..v[3]..'_recipe'})
		end
		if not data.raw["recipe"]['el_arc_pure_'..v[3]..'_recipe'] then
			data:extend({
			{
				name = 'el_arc_pure_'..v[3]..'_recipe',
				type = 'recipe',
				enabled = 'false',
				category = 'el_arc_furnace_category',
				ingredients = {
					{type="item", name="el_materials_pure_"..v[3], amount=1},
				},
				results = {
					{type="fluid", name="el_arc_pure_"..v[3], amount=200},
				},
				energy_required = 0.2,
				order = 'a-'..v[3]..'-c',
				always_show_made_in = true
			}
			})
			table.insert(data.raw["technology"]["el_arc_furnace_tech"].effects,{ type = 'unlock-recipe',recipe = 'el_arc_pure_'..v[3]..'_recipe'})
		end
		if not data.raw["recipe"]['el_cast_pure_'..v[3]..'_recipe'] then
			data:extend({{
				name = 'el_cast_pure_'..v[3]..'_recipe',
				type = 'recipe',
				enabled = 'false',
				category = 'el_caster_category',
				ingredients = {
					{type="fluid", name="el_arc_pure_"..v[3], amount=100},
				},
				results = {
					{type="item", name=v[2], amount=1},
				},
				energy_required = 0.2,
				order = 'a-'..v[3]..'-d',
				always_show_made_in = true,
				allow_decomposition = false
			}})
			table.insert(data.raw["technology"]["el_caster_tech"].effects,{ type = 'unlock-recipe',recipe = 'el_cast_pure_'..v[3]..'_recipe'})
		end
	end
end