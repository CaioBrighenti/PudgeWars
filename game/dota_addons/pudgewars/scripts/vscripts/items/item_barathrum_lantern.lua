item_barathrum_lantern = item_barathrum_lantern or class({})
item_barathrum_lantern_2 = item_barathrum_lantern_2 or class({})
item_barathrum_lantern_3 = item_barathrum_lantern_3 or class({})
item_barathrum_lantern_4 = item_barathrum_lantern_4 or class({})
item_barathrum_lantern_5 = item_barathrum_lantern_5 or class({})

function item_barathrum_lantern:OnCreated()
	print(self:GetLevel())
end

function item_barathrum_lantern:GetIntrinsicModifierName() return "modifier_bash_lantern" end
function item_barathrum_lantern_2:GetIntrinsicModifierName() return "modifier_bash_lantern" end
function item_barathrum_lantern_3:GetIntrinsicModifierName() return "modifier_bash_lantern" end
function item_barathrum_lantern_4:GetIntrinsicModifierName() return "modifier_bash_lantern" end
function item_barathrum_lantern_5:GetIntrinsicModifierName() return "modifier_bash_lantern" end

LinkLuaModifier("modifier_bash_lantern", "items/item_barathrum_lantern.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bash_lantern = modifier_bash_lantern or class({})

function modifier_bash_lantern:IsDebuff() return false end

-- function modifier_bash_lantern:GetTextureName()
-- 	return "dark_seer_ion_shell"
-- end

-- function modifier_bash_lantern:GetEffectName()
-- 	return ""
-- end

-- function modifier_bash_lantern:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_bash_lantern:OnAttackLanded(keys)
	if self:GetParent() == keys.attacker and self:GetAbility():GetAbilityName() == "item_barathrum_lantern_5" then
		print(self:GetAbility():GetAbilityName())
		if PudgeWarsMode:RollBash(17) then
			dealDamage(self:GetParent(), keys.victim, 300)

			local bashParticle = ParticleManager:CreateParticle( 'particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf', PATTACH_ABSORIGIN, unit)
			local bashPos = unit:GetOrigin()
			ParticleManager:SetParticleControl(bashParticle, 4, Vector( bashPos.x, bashPos.y, bashPos.z))
			unit:AddNewModifier(caster, nil, "modifier_stunned", {duration=1.2})
			unit:EmitSound('Hero_Spirit_Breaker.GreaterBash')
		end 
	end
end
