LinkLuaModifier("modifier_lycan_paw", "items/item_lycan_paw.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lycan_paw_max", "items/item_lycan_paw.lua", LUA_MODIFIER_MOTION_NONE)

item_lycan_paw = class({})

function item_lycan_paw:GetIntrinsicModifierName()
	return "modifier_lycan_paw"
end

modifier_lycan_paw = class({})

function modifier_lycan_paw:IsHidden() return false end
function modifier_lycan_paw:IsPurgable() return false end

function modifier_lycan_paw:DeclareFunctions()
	local decFuns =
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return decFuns
end

function modifier_lycan_paw:OnCreated()
	self:StartIntervalThink(1.0)
end

function modifier_lycan_paw:OnIntervalThink()
	if IsClient() then return end
	if self:GetAbility():GetLevel() == 5 then
		if not self:GetParent():HasModifier("modifier_lycan_paw_max") then
			self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_lycan_paw_max", {}):SetStackCount(self:GetAbility():GetSpecialValueFor("movespeed_percent_bonus"))
		end
	end
end

function modifier_lycan_paw:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
end

function modifier_lycan_paw:OnRemoved()
	if self:GetParent():HasModifier("modifier_lycan_paw_max") then
		self:GetParent():RemoveModifierByName("modifier_lycan_paw_max")
	end
end

modifier_lycan_paw_max = class({})

function modifier_lycan_paw_max:IsHidden() return true end
function modifier_lycan_paw_max:IsPurgable() return false end

function modifier_lycan_paw_max:DeclareFunctions()
	local decFuns =
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return decFuns
end

function modifier_lycan_paw_max:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
end

function modifier_lycan_paw_max:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetStackCount()
end
