-- Order filter function
function GameMode:OrderFilter( keys )

	--entindex_ability	 ==> 	0
	--sequence_number_const	 ==> 	20
	--queue	 ==> 	0
	--units	 ==> 	table: 0x031d5fd0
	--entindex_target	 ==> 	0
	--position_z	 ==> 	384
	--position_x	 ==> 	-5694.3334960938
	--order_type	 ==> 	1
	--position_y	 ==> 	-6381.1127929688
	--issuer_player_id_const	 ==> 	0

	local units = keys["units"]
	local unit
	if units["0"] then
		unit = EntIndexToHScript(units["0"])
	else
		return nil
	end

	-- Do special handlings if shift-casted only here! The event gets fired another time if the caster
	-- is actually doing this order
	if keys.queue == 1 then
		return true
	end

	if keys.order_type == DOTA_UNIT_ORDER_GLYPH then
		return false
	end

	if keys.order_type == DOTA_UNIT_ORDER_BUYBACK then
		return false
	end

	-- Not working well..
--[[
	if keys.order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		local purchaser = EntIndexToHScript(units["0"])
		local item = keys.entindex_ability
		if item == nil then return true end

		for i = 0, 8 do
			local inv_item
			if unit.GetItemInSlot then
				inv_item = unit:GetItemInSlot(i)
				if inv_item == nil then return true end
				if inv_item:GetName() == self.itemIDs[item] then
					result_level = inv_item:GetLevel() + 1

					local cost = -inv_item:GetCost()
					if result_level > 5 then
						DisplayError(unit:GetPlayerID(),"#dota_hud_error_item_level_max")
						return false
					else
						UTIL_RemoveImmediate(inv_item)
						newItem = CreateItem(self.itemIDs[item], unit, nil)
						newItem:SetLevel(result_level)
						unit:AddItem(newItem)
						unit:ModifyGold(cost, false, DOTA_ModifyGold_Unspecified)
						return false
					end
				end
			end
		end

--		for _, banned_item in pairs(BANNED_ITEMS) do
--			if self.itemIDs[item] == banned_item then
--				DisplayError(unit:GetPlayerID(),"#dota_hud_error_cant_purchase_item")
--				return false
--			end
--		end
	end
--]]
	return true
end
