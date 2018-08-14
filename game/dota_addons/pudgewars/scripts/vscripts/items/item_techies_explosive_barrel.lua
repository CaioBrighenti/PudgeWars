LinkLuaModifier("modifier_explosive_barrel", "items/item_techies_explosive_barrel.lua", LUA_MODIFIER_MOTION_NONE)

item_techies_explosive_barrel = item_techies_explosive_barrel or class({})

function item_techies_explosive_barrel:GetAbilityTextureName()
	if self:GetLevel() == 5 then
		return "item_techies_explosive_barrel_max"
	else
		return "item_techies_explosive_barrel"
	end
end

function item_techies_explosive_barrel:OnCreated()
--	print(self:GetLevel())
end

function item_techies_explosive_barrel:OnChannelFinish(bInterrupted)
	local point = self:GetCursorPosition()

	if bInterrupted == false then
		local mine = CreateUnitByName("npc_dota_mine_"..self:GetLevel(), point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		mine:AddNewModifier(mine, self, "modifier_explosive_barrel", {})
	end
end

modifier_explosive_barrel = modifier_explosive_barrel or class({})

function modifier_explosive_barrel:IsHidden() return false end
function modifier_explosive_barrel:IsPurgable() return false end

function modifier_explosive_barrel:OnCreated()
	if IsClient() then return end
	self:StartIntervalThink(0.1)
	self.detonate = false
end

function modifier_explosive_barrel:OnIntervalThink()
	local units = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)		
	if self.detonate == false and #units > 0 then
		DynamiteRune(self:GetParent(), self:GetAbility():GetSpecialValueFor("radius"), 0)
		self.detonate = true
	end
end
