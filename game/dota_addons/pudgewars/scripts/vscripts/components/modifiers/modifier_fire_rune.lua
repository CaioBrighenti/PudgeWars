modifier_fire_rune = modifier_fire_rune or class({})

function modifier_fire_rune:IsDebuff() return false end

function modifier_fire_rune:GetTexture()
	return "ember_spirit_fire_remnant"
end

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
	if IsServer() then
		PudgeArray[self:GetParent():GetPlayerID()].use_flame = true
	end
end

function modifier_fire_rune:OnDestroy()
	if IsServer() then
		PudgeArray[self:GetParent():GetPlayerID()].use_flame = false

		for key, flame in pairs(_G.all_flame_hooks) do
			if flame then
				flame:RemoveSelf()
			end

			_G.all_flame_hooks[key] = nil
		end
	end
end
