LinkLuaModifier("modifier_butchers_cleaver", "abilities/pudge_wars_cleaver", LUA_MODIFIER_MOTION_NONE)

pudge_wars_cleaver = class({})

function pudge_wars_cleaver:IsHiddenWhenStolen() return false end
function pudge_wars_cleaver:IsRefreshable() return true end
function pudge_wars_cleaver:IsStealable() return true end
function pudge_wars_cleaver:IsNetherWardStealable() return true end
function pudge_wars_cleaver:IsInnateAbility() return false end
function pudge_wars_cleaver:GetAbilityTextureName() return "pudge_cleaver" end

-------------------------------------------

function pudge_wars_cleaver:OnSpellStart()
	local vTargetPosition = self:GetCursorPosition()
	local caster = self:GetCaster()

	-- I want to remove the thing but I can't find it.
	if self:GetCaster() and self:GetCaster():IsHero() then
		local cleaver = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_OFFHAND_WEAPON )
		if cleaver ~= nil then
			cleaver:AddEffects( EF_NODRAW )
		end
	end

	local velocity = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("projectile_speed")
	local info = {
		bDeleteOnHit = true,
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
		vVelocity = Vector(velocity.x,velocity.y,0),
		fDistance = self:GetSpecialValueFor("range"),
		fStartRadius = self:GetSpecialValueFor("projectile_radius"),
		fEndRadius = self:GetSpecialValueFor("projectile_radius"),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		EffectName = "particles/hero/pudge/butchers_cleave_projectile.vpcf",
		iVisionRadius = self:GetSpecialValueFor("projectile_radius"),
		bProvidesVision = true,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}
	
	self.projectile = ProjectileManager:CreateLinearProjectile(info)
end

function pudge_wars_cleaver:OnProjectileHit(hTarget,vLocation)
	if not hTarget then 
		for i =0,30 do
			local cleaver = self:GetCaster():GetTogglableWearable( i )
			if cleaver ~= nil then
				cleaver:RemoveEffects(EF_NODRAW)		
			end
		end
		return 
	end
	
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	hTarget:AddNewModifier(self:GetCaster(),self,"modifier_butchers_cleaver",{duration = self:GetSpecialValueFor("duration")}):SetStackCount(-self:GetSpecialValueFor("move_slow"))

	local damage = 
	{
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("damage"),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}

	ApplyDamage(damage)
end

-------------------------------------------

modifier_butchers_cleaver = class({})

function modifier_butchers_cleaver:IsDebuff() return true end
function modifier_butchers_cleaver:IsHidden() return false end
function modifier_butchers_cleaver:IsPurgable() return true end

-------------------------------------------

function modifier_butchers_cleaver:DeclareFunctions()
	local decFuns =
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return decFuns
end

function modifier_butchers_cleaver:GetEffectName()
	return "particles/hero/pudge/pudge_cleaver_overhead.vpcf"
end

function modifier_butchers_cleaver:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_butchers_cleaver:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end
