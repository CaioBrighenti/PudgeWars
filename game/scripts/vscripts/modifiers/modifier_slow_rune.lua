
modifier_slow_rune = modifier_slow_rune or class({})

-- Modifier properties
function modifier_slow_rune:IsHidden() 		return false end
function modifier_slow_rune:IsPurgable()	return false end
function modifier_slow_rune:IsDebuff() 		return true end

function modifier_slow_rune:GetTextureName()
	return "rune_haste"
end

function modifier_slow_rune:DeclareFunctions()
	local funcs	=	{
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_MAX
	}
	return funcs
end

function modifier_slow_rune:GetModifierMoveSpeed_Absolute()
	return 150
end

function modifier_slow_rune:GetModifierMoveSpeed_Max()
	return 150
end
