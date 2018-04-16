pudge_wars_upgrade_hook_damage = class({})

function pudge_wars_upgrade_hook_damage:OnUpgrade()
	SpendAbilityPoint(self:GetCaster())
end

pudge_wars_upgrade_hook_range = class({})

function pudge_wars_upgrade_hook_range:OnUpgrade()
	SpendAbilityPoint(self:GetCaster())
end

pudge_wars_upgrade_hook_speed = class({})

function pudge_wars_upgrade_hook_speed:OnUpgrade()
	SpendAbilityPoint(self:GetCaster())
end

pudge_wars_upgrade_hook_size = class({})

function pudge_wars_upgrade_hook_size:OnUpgrade()
	SpendAbilityPoint(self:GetCaster())
end

function SpendAbilityPoint(hero)
	local modifier = hero:FindModifierByName("modifier_ability_points")
	if modifier then
		modifier:SetStackCount(hero:GetAbilityPoints() - 1)

		if modifier:GetStackCount() == 0 then
			hero:FindAbilityByName("pudge_wars_abilities_down"):CastAbility()
		end
	end
end
