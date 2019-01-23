modifier_shield_rune = modifier_shield_rune or class({})

function modifier_shield_rune:IsDebuff() return false end

function modifier_shield_rune:GetTextureName()
	return "dark_seer_ion_shell"
end

function modifier_shield_rune:GetEffectName()
	return "particles/pw/shield_barrier.vpcf"
end

function modifier_shield_rune:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shield_rune:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_shield_rune:OnIntervalThink()
	local units = Entities:FindAllInSphere(self:GetParent():GetAbsOrigin(), 400)

	for k,v in pairs(units) do
		if IsValidEntity(v) and string.find(v:GetClassname(), "pudge") and v ~= self:GetParent() then
			dealDamage(self:GetParent(), v, 15)
		end
	end
end
