local ores={}
-- {1ore,2output,3name,4ore_texture,5tint}
for i,v in ipairs(T) do
	data:extend({{
        name = 'fi_materials_pure_'..v[3],
        type = 'item',
        icons = {{icon = '__248k__/ressources/electronic/el_materials/el_materials_pure_aluminum.png', tint=v[5]}},
        icon_size = 64,
        stack_size = 50,
        subgroup = 'fi_item_subgroup_a-c',
        order = 'a-a',
    },
	{
        name = 'el_arc_pure_'..v[3],
        type = 'fluid',
        icons = {{
			icon = "__base__/graphics/icons/fluid/water.png", tint={r=165/255,g=106/255,b=59/255}
		},
		{
			icon = v[4],
			scale=0.25
		}
		},
        icon_size = 64,
        default_temperature = 1600,
        max_temperature = 2000,
        heat_capacity = '100kJ',
        base_color = { r=0.92, g=0.29, b=0.22 }, 
		flow_color = { r=0.92, g=0.29, b=0.22 }, 
		pressure_to_speed_ratio = 0.400, 
		flow_to_energy_ratio = 0,
        subgroup = 'el_item_subgroup_e',
        order = 'a-a',
    },
	{
        name = 'el_purify_'..v[3]..'_recipe',
        type = 'recipe',
        enabled = 'false',
        category = 'el_purifier_category',
        main_product = 'el_dirty_water',
        ingredients = {
            {type="fluid", name="water", amount=50},
            --{type="fluid", name="steam", amount=240, temperature=165},
            {type="item", name=v[1], amount=10}
        },
        results = {
            {type="fluid", name="el_dirty_water", amount=50},
            {type="item", name="el_materials_pure_"..v[3], amount=5},
        },
        energy_required = 1,
        always_show_made_in = true,
        icon_size = 64,
        icons = {
            {
                icon = "__248k__/ressources/fluids/el_dirty_water.png"
            },
            {
                icon = v[4],
				scale= 0.25
            }
        } 
    },
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
        order = 'a-b',
        always_show_made_in = true
    },
	{
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
        order = 'a-b',
        always_show_made_in = true,
        allow_decomposition = false
    }})
end