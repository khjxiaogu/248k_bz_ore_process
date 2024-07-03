function extract_name(object)
	return object.name or object[1]
end
function extract_amount(object)
	local aamt=object.amount
	if (not aamt) and object.amount_max ~=nil and object.amount_min ~=nil then
		aamt=((object.amount_max+object.amount_min)/2.0);
	end
	if not aamt then 
		return object[2]
	end
	return aamt * (object.probability or 1)
end
function extract_probability(object)
	return object.probability or 1
end
function ingredients_to_result(object)
	if object.name then
		return object
	else
		return {type="item",name=object[1],amount=object[2]}
	end
end
function find_name(object,name)
	if not object then 
		return nil
	end
	for _,v in ipairs(object) do
		if extract_name(v) ==name then
			return v
		end
	end
end
-- simply remove direct catalyst
function remove_catalyst_ingredient(ingredients,results)
	local actual={}
	for _,v in ipairs(ingredients) do
		if not find_name(results,extract_name(v)) then
			table.insert(actual,v)
		end
	end
	return actual
end
function remove_catalyst_results(ingredients,results)
	if not results then 
		return {}
	end
	local actual={}
	for _,v in ipairs(results) do
		if not find_name(ingredients,extract_name(v)) then
			table.insert(actual,v)
		end
	end
	return actual
end
function reduce_probability(object,division)
	object=ingredients_to_result(object)
	object.probability=(object.probability or 1)/division
	if object.amount then
		local actamount=object.probability*object.amount
		if actamount<1 then
			object.probability=actamount
			object.amount=1
		elseif actamount==math.floor(actamount) then
			object.probability=1
			object.amount=actamount
		end
	elseif object.probability>1 then
		local factor=math.ceil(object.probability)
		object.probability=object.probability/factor
		object.amount_min=object.amount_min*factor
		object.amount_max=object.amount_max*factor
	end
	
	return object
end
function handle_byproducts(recipe,main_product,results,cost_type)
	local products
	if not recipe[cost_type] then
		recipe[cost_type]={
			main_product = recipe.main_product,
			enabled = recipe.enabled,
			energy_required = recipe.energy_required,
			ingredients = table.deepcopy(recipe.ingredients),
			results = table.deepcopy(recipe.results)
		}
	end
	products=recipe[cost_type].results
	log("----------------")
	log("byproducts = "..serpent.block(results))
	log("main_product = "..main_product)
	
	local division=extract_amount(find_name(results,main_product))/10
	log("division = "..division)
	for _,v in ipairs(results) do
		if extract_name(v) ~= main_product then
			-- ore are added directly
			if string.find(extract_name(v),"-ore") then
				table.insert(products,reduce_probability(table.deepcopy(v),division))
			else
				local nrecipe=data.raw["recipe"][extract_name(v)]
				-- smelting recipe give back ingredients
				if nrecipe and nrecipe.category == "smelting" then
					if nrecipe[cost_type] then
						local subdivision=extract_amount(find_name(nrecipe[cost_type].results,extract_name(v)))*division
						for _,v2 in ipairs(remove_catalyst_ingredient(nrecipe[cost_type].ingredients,nrecipe[cost_type].results)) do
							table.insert(products,reduce_probability(table.deepcopy(v2),subdivision/extract_amount(v)))
						end
					elseif nrecipe.ingredients then
						local subdivision=extract_amount(find_name(nrecipe.results,extract_name(v)))*division
						for _,v2 in ipairs(remove_catalyst_ingredient(nrecipe.ingredients,nrecipe.results)) do
							table.insert(products,reduce_probability(table.deepcopy(v2),subdivision/extract_amount(v)))
						end
					end
				else
					-- others are also added directly
					table.insert(products,reduce_probability(table.deepcopy(v),division))
				end
			end
		end
	end
	log("----------------")


end
for k,v in pairs(data.raw["resource"]) do
	local on=string.sub(k,1,-5)
	if (string.find(k,"-ore") and data.raw["item"]['el_materials_pure_'..on]) then
		if mods["modpack_se_k2_bz_248k"] then
			if not data.raw["item-subgroup"]["resources-"..on] then 
				data:extend {
					{
						type = "item-subgroup",
						name = "resources-"..on,
						group = "resources",
						order = on,
					}
				}
			end
			data.raw["item"]['el_materials_pure_'..on].subgroup = "resources-"..on
			data.raw["fluid"]['el_arc_pure_'..on].subgroup = "resources-"..on
			data.raw["recipe"]['el_purify_'   ..on..'_recipe'].subgroup = "resources-"..on
			data.raw["recipe"]['el_arc_pure_' ..on..'_recipe'].subgroup = "resources-"..on
			data.raw["recipe"]['el_cast_pure_'..on..'_recipe'].subgroup = "resources-"..on
		end
		-- handle byproducts
		local recipe=data.raw["recipe"][on..'-plate']
		if recipe then
			if recipe.normal and recipe.normal.results then
				log(serpent.block(recipe.normal.ingredients))
				handle_byproducts(data.raw["recipe"]['el_purify_'   ..on..'_recipe'],on..'-plate',remove_catalyst_results(recipe.normal.ingredients,recipe.normal.results),'normal')
			end
			if recipe.expensive and recipe.expensive.results then
				log(serpent.block(recipe.expensive.ingredients))
				handle_byproducts(data.raw["recipe"]['el_purify_'   ..on..'_recipe'],on..'-plate',remove_catalyst_results(recipe.expensive.ingredients,recipe.expensive.results),'expensive')
			end
			if (not recipe.normal) and (not recipe.expensive) and recipe.results then
				handle_byproducts(data.raw["recipe"]['el_purify_'   ..on..'_recipe'],on..'-plate',remove_catalyst_results(recipe.ingredients,recipe.results),'normal')
				handle_byproducts(data.raw["recipe"]['el_purify_'   ..on..'_recipe'],on..'-plate',remove_catalyst_results(recipe.ingredients,recipe.results),'expensive')
			end
		end
	end
end
