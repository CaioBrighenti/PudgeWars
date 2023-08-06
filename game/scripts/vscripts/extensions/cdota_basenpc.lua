function CDOTA_BaseNPC:InitializeAbilities()
	for i = 0, 24 do
		local ability = self:GetAbilityByIndex(i)
		local ability_name = ability and ability:GetAbilityName() or nil

		if ability_name then
			local ability_kv = GetAbilityKeyValuesByName(ability_name)

			if ability_kv then
				if ability_kv["IsInnateAbility"] and ability_kv["IsInnateAbility"] == 1 then
					ability:SetLevel(1)
				end
			end
		end
	end
end
