dofile_once( "data/scripts/game_helpers.lua" )
dofile_once("data/scripts/lib/utilities.lua")

local HealthAmount = 0.2	-- How much health is generated at pickup, 0.04 is about one health point

function item_pickup( entity_item, entity_who_picked, item_name )
	local pos_x, pos_y = EntityGetTransform( entity_item )
	
	local money = 0
	local value = 10
	
	edit_component( entity_who_picked, "WalletComponent", function(comp,vars)
		money = ComponentGetValueInt( comp, "money")
	end)

	-- load the gold_value from VariableStorageComponent
	local components = EntityGetComponent( entity_item, "VariableStorageComponent" )
	
	if ( components ~= nil ) then
		for key,comp_id in pairs(components) do 
			local var_name = ComponentGetValue( comp_id, "name" )
			if( var_name == "gold_value") then
				value = ComponentGetValueInt( comp_id, "value_int" )
			end
		end
	end

	local extra_money_count = GameGetGameEffectCount( entity_who_picked, "EXTRA_MONEY" )
	if extra_money_count > 0 then
		for i=1,extra_money_count do
			value = value * 2
		end
	end

	money = money + value
	
	edit_component( entity_who_picked, "WalletComponent", function(comp,vars)
		vars.money = money
	end)

	local player_damagemodel = EntityGetComponent( entity_who_picked, "DamageModelComponent" )

	if( player_damagemodel ~= nil ) then
		for i, damagemodel in ipairs( player_damagemodel ) do
			hp = tonumber( ComponentGetValue( damagemodel, "hp" ) )
			max_hp = tonumber( ComponentGetValue( damagemodel, "max_hp" ) )
			if( hp < max_hp ) then
				hp = hp + HealthAmount
			else
				hp = max_hp
			end
			ComponentSetValue( damagemodel, "hp", hp )
		end
	end

	shoot_projectile( entity_item, "data/entities/particles/gold_pickup.xml", pos_x, pos_y, 0, 0 )
	EntityKill( entity_item )
end
