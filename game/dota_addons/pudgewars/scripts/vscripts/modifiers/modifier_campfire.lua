modifier_campfire = class({})

function modifier_campfire:IsHidden() return true end
function modifier_campfire:IsPurgable() return false end

function modifier_campfire:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

function modifier_campfire:OnCreated()
	self.vOffset = Vector(0, 0, 50)
	self.active = false
	self.duration = 180
	self.vision_range = 900
	self:StartIntervalThink(0.5)
end

function modifier_campfire:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():HasModifier("modifier_invulnerable") then
			self.active = false
		end

		if self.active == false then
			if self.nFXIndex then
				ParticleManager:DestroyParticle(self.nFXIndex, false)
				ParticleManager:ReleaseParticleIndex(self.nFXIndex)
				self.nFXIndex = nil
			end
		end
	end
end

function modifier_campfire:OnAttacked(kv)
	if IsServer() then
		if kv.target ~= self:GetParent() then
			return
		end

		self.nFXIndex = ParticleManager:CreateParticle("particles/act_2/campfire_flame.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(self.nFXIndex, 2, self:GetCaster():GetOrigin() + self.vOffset)
		AddFOWViewer(kv.attacker:GetTeamNumber(), self:GetParent():GetAbsOrigin(), self.vision_range, self.duration, true)
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_invulnerable", {duration = self.duration})
		self.active = true
	end
end

function modifier_campfire:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_campfire:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_campfire:GetAbsoluteNoDamagePure()
	return 1
end
