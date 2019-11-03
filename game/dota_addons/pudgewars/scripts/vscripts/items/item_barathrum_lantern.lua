item_barathrum_lantern = item_barathrum_lantern or class({})

function item_barathrum_lantern:OnCreated()
--	print(self:GetLevel())
end

function item_barathrum_lantern:GetAbilityTextureName()
	if self:GetLevel() == 5 then
		return "item_barathrum_lantern_max"
	else
		return "item_barathrum_lantern"
	end
end

function item_barathrum_lantern:GetIntrinsicModifierName() return "modifier_bash_lantern" end

LinkLuaModifier("modifier_bash_lantern", "items/item_barathrum_lantern.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bash_lantern = modifier_bash_lantern or class({})

function modifier_bash_lantern:IsHidden() return true end
function modifier_bash_lantern:IsPurgable() return false end
function modifier_bash_lantern:IsPurgeException() return false end

-- function modifier_bash_lantern:GetTextureName()
-- 	return "dark_seer_ion_shell"
-- end

function modifier_bash_lantern:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_bash_lantern:OnAttackLanded(keys)
	if self:GetParent() == keys.attacker and self:GetAbility():GetLevel() == 5 then
		if PudgeWarsMode:RollBash(self:GetAbility():GetSpecialValueFor("bash_chance")) then
			dealDamage(self:GetParent(), keys.target, self:GetAbility():GetSpecialValueFor("bash_damage"))

			local bashParticle = ParticleManager:CreateParticle('particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf', PATTACH_ABSORIGIN, keys.target)
			local bashPos = keys.target:GetOrigin()
			ParticleManager:SetParticleControl(bashParticle, 4, Vector( bashPos.x, bashPos.y, bashPos.z))
			keys.target:AddNewModifier(self:GetParent(), nil, "modifier_stunned", {duration=1.2})
			keys.target:EmitSound('Hero_Spirit_Breaker.GreaterBash')
		end 
	end
end
