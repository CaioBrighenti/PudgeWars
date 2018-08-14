-- Lifesteal modifier

item_naix_jaw = class({})

function item_naix_jaw:GetAbilityTextureName()
	if self:GetLevel() == 5 then
		return "item_naix_jaw_max"
	else
		return "item_naix_jaw"
	end
end

function item_naix_jaw:GetIntrinsicModifierName()
	return "modifier_lifesteal"
end

LinkLuaModifier("modifier_lifesteal", "items/item_naix_jaw.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lifesteal = class({})

function modifier_lifesteal:GetTexture()
	return "modifiers/lifesteal_mask"
end

function modifier_lifesteal:GetTexture()
	return "item_naix_jaw"
end

function modifier_lifesteal:DeclareFunctions()
	local decFunc = {
	MODIFIER_EVENT_ON_ATTACK_LANDED}

	return decFunc
end

function modifier_lifesteal:OnAttackLanded(keys)
	if IsServer() then
		if self:GetAbility():GetLevel() ~= 5 then return end
		local parent = self:GetParent()
		local attacker = keys.attacker

		if parent ~= attacker then return end

		local target = keys.target
		local lifesteal_amount = attacker:GetLifesteal()

		-- If there's no valid target, or lifesteal amount, do nothing
		if target:IsBuilding() or (target:GetTeam() == attacker:GetTeam()) or lifesteal_amount <= 0 then
			return
		end

		-- Calculate actual lifesteal amount
		local damage = keys.damage
		local target_armor = target:GetPhysicalArmorValue()
		local heal = damage * lifesteal_amount * 0.01 * GetReductionFromArmor(target_armor) * 0.01
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal, nil)

		-- Choose the particle to draw
		local lifesteal_particle = "particles/generic_gameplay/generic_lifesteal.vpcf"

		-- Heal and fire the particle
		attacker:Heal(heal, attacker)
		local lifesteal_pfx = ParticleManager:CreateParticle(lifesteal_particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
		ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
	end
end

function modifier_lifesteal:OnDestroy()
	if IsServer() then
		-- fix with Vampiric Aura interaction
		if self:GetParent():HasItemInInventory("item_lifesteal_mask") then
			self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_lifesteal", {})
		end
	end
end

function modifier_lifesteal:IsHidden() return false end
function modifier_lifesteal:IsPurgable() return false end
function modifier_lifesteal:IsDebuff() return false end

--	function modifier_lifesteal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_lifesteal:GetModifierLifesteal()
	return self:GetAbility():GetSpecialValueFor("lifesteal_pct")
end
