--[[ spike_trap_ai.lua ]]

---------------------------------------------------------------------------
-- AI for the Spike Trap
---------------------------------------------------------------------------

local triggerActive = true

function Fire(trigger)
	local triggerName = thisEntity:GetName()
	--print(tostring(triggerName))
	local caller = trigger.activator
	local target = Entities:FindByName( nil, triggerName .. "_target" )
	local spikes = triggerName .. "_model"
	local dust = triggerName .. "_particle"
	local fx = triggerName .. "_fx"
	--print(spikes)
	if target ~= nil and triggerActive == true then
		local spikeTrap = thisEntity:FindAbilityByName("spike_trap")
		SpikeTrap(thisEntity, spikeTrap, caller)
--		thisEntity:CastAbilityOnPosition(target:GetOrigin(), spikeTrap, -1 )
		EmitSoundOn( "Conquest.SpikeTrap.Plate" , spikeTrap)
		DoEntFire( spikes, "SetAnimation", "spiketrap_activate", 0, self, self )
		DoEntFire( dust, "Start", "", 0, self, self )
		DoEntFire( dust, "Stop", "", 2, self, self )
		DoEntFire( fx, "Start", "", 0, self, self )
		DoEntFire( fx, "Stop", "", 2, self, self )

		--thisEntity:SetContextThink( "ResetTrapModel", function() ResetTrapModel( spikes ) end, 3 )
		triggerActive = false
		thisEntity:SetContextThink( "ResetTrapModel", function() ResetTrapModel() end, 4 )
	end
end

function ResetTrapModel()
	--DoEntFire( spikes, "SetAnimation", "spiketrap_idle", 0, self, self )
	triggerActive = true
end

function SpikeTrap(caster, ability, caller)
--	print("spike_trap: OnSpellStart")
	local damage = ability:GetSpecialValueFor("light_strike_array_damage")
	local delay = ability:GetSpecialValueFor( "light_strike_array_delay_time" )
	local duration = ability:GetSpecialValueFor( "light_strike_array_stun_duration" )
	local radius = ability:GetSpecialValueFor( "light_strike_array_aoe" )

	Timers:CreateTimer(delay, function()
		GridNav:DestroyTreesAroundPoint( caster:GetOrigin(), radius, false )
		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

--		print(#enemies)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					local damage_table = {
						victim = enemy,
						attacker = caller,
						damage = damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
						ability = self
					}

					ApplyDamage( damage_table )
					enemy:AddNewModifier( caller, self, "modifier_stunned", { duration = duration } )
				end
			end
		end

		--local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_WORLDORIGIN, nil )
		--ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetOrigin() )
		--ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.light_strike_array_aoe, 1, 1 ) )
		--ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOnLocationWithCaster( caster:GetOrigin(), "Conquest.SpikeTrap.Activate.Generic", caster )
	end)
end