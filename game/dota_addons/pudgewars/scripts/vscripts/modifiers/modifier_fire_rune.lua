modifier_fire_rune = modifier_fire_rune or class({})

function modifier_fire_rune:IsDebuff() return false end

-- function modifier_fire_rune:GetTextureName()
-- 	return "dark_seer_ion_shell"
-- end

-- function modifier_fire_rune:GetEffectName()
-- 	return ""
-- end

-- function modifier_fire_rune:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_fire_rune:OnCreated()
	PudgeArray[self:GetParent():GetPlayerID()].use_flame = true
end

function modifier_fire_rune:OnDestroy()
	PudgeArray[self:GetParent():GetPlayerID()].use_flame = false

	for key, flame in pairs(_G.all_flame_hooks) do
		if flame then
			print("destroy flame")
			flame:RemoveSelf()
		end

		_G.all_flame_hooks[key] = nil
	end
end
