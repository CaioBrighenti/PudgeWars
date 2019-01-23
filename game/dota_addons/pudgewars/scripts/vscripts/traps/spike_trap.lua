spike_trap = class({})

--------------------------------------------------------------------------------

function spike_trap:GetAOERadius()
	return self:GetSpecialValueFor( "light_strike_array_aoe" )
end

--------------------------------------------------------------------------------

function spike_trap:OnSpellStart()
	print("spike_trap: OnSpellStart")
	local damage = self:GetSpecialValueFor("light_strike_array_damage")
	local delay = self:GetSpecialValueFor( "light_strike_array_delay_time" )
	local duration = self:GetSpecialValueFor( "light_strike_array_stun_duration" )
	local radius = self:GetSpecialValueFor( "light_strike_array_aoe" )

	Timers:CreateTimer(delay, function()
		GridNav:DestroyTreesAroundPoint( self:GetCaster():GetOrigin(), radius, false )
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

		print(#enemies)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					local damage_table = {
						victim = enemy,
						attacker = self:GetCaster(),
						damage = damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
						ability = self
					}

					ApplyDamage( damage_table )
					enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = duration } )
				end
			end
		end

		--local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_WORLDORIGIN, nil )
		--ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
		--ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.light_strike_array_aoe, 1, 1 ) )
		--ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Conquest.SpikeTrap.Activate.Generic", self:GetCaster() )
	end)
end

--------------------------------------------------------------------------------
