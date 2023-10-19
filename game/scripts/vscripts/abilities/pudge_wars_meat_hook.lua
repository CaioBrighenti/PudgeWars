LinkLuaModifier("modifier_pudge_wars_meat_hook_handler", "abilities/pudge_wars_meat_hook.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pudge_wars_meat_hook", "abilities/pudge_wars_meat_hook.lua", LUA_MODIFIER_MOTION_NONE)

pudge_wars_meat_hook = pudge_wars_meat_hook or class({})

function pudge_wars_meat_hook:OnSpellStart()
	if not IsServer() then return end

	-- Ability properties
	self.caster = self:GetCaster()
	self.hook_dummies = {}        -- Table of dummy units that will be used to track hook positions
	self.linkCreationTolerance = 200 -- Chain link creation distance.  Creates a new chain link when the chain extends more than this distance from the hero.
	self.linkFollowDistance = 150 -- Chain follow distance.  This determines the size of linear links in the chain.
	self.linkDeletionTolerance = 100 -- Chain deletion distance.  This determines how close a chain/hook has to be to the hero to be deleted on retract.

	-- Hook ability upgrades
	self.hook_damage_ab = self.caster:FindAbilityByName("pudge_wars_upgrade_hook_damage")
	self.hook_range_ab = self.caster:FindAbilityByName("pudge_wars_upgrade_hook_range")
	self.hook_speed_ab = self.caster:FindAbilityByName("pudge_wars_upgrade_hook_speed")
	self.hook_size_ab = self.caster:FindAbilityByName("pudge_wars_upgrade_hook_size")

	-- Hook ability values
	self.damage = self:GetSpecialValueFor("base_damage") + self.hook_damage_ab:GetSpecialValueFor("bonus_damage")
	self.distance = self:GetSpecialValueFor("base_range") + self.hook_range_ab:GetSpecialValueFor("bonus_range")
	self.speed = self:GetSpecialValueFor("base_speed") + self.hook_speed_ab:GetSpecialValueFor("bonus_speed")
	self.radius = self:GetSpecialValueFor("base_radius") + self.hook_size_ab:GetSpecialValueFor("bonus_radius")

	-- Hook properties
	self.timeout = self.distance / self.speed

	self.modelScale = 0.9 + self.hook_size_ab:GetSpecialValueFor("hook_radius")
	self.hook_model = self.caster.hook_model or "models/heroes/pudge/righthook.vmdl"

	-- Hook variables
	self.dir = (self:GetCursorPosition() - self.caster:GetAbsOrigin()):Normalized()

	self.caster:AddNewModifier(self.caster, self, "modifier_pudge_wars_meat_hook_handler", {})
end

modifier_pudge_wars_meat_hook_handler = modifier_pudge_wars_meat_hook_handler or class({})

function modifier_pudge_wars_meat_hook_handler:OnCreated()
	if not IsServer() then return end

	self.ability = self:GetAbility()
	self.current_time = 0

	self:CreateHook()
	self:CreateChainLink(self.ability.dir)
	self:StartIntervalThink(FrameTime())
end

function modifier_pudge_wars_meat_hook_handler:OnIntervalThink()
	self.current_time = self.current_time + FrameTime()

	if self.current_time <= self.ability.timeout then
		self:HookForward()
	else
		self:HookBackward()
	end
end

function modifier_pudge_wars_meat_hook_handler:CreateHook()
	local hook_dummy = CreateUnitByName("npc_reflex_hook_test", self.ability.caster:GetOrigin() + self.ability.dir * 75, false, self.ability.caster, self.ability.caster, self.ability.caster:GetTeam())
	hook_dummy:SetModel(self.ability.hook_model)
	hook_dummy:SetOriginalModel(self.ability.hook_model)
	hook_dummy:SetModelScale(self.ability.modelScale)
	hook_dummy:SetForwardVector(self.ability.dir)

	-- Create special chain link attached to Hook
	-- print("Hook chain particle:", self.ability.caster.hook_pfx)
	local particle = ParticleManager:CreateParticle("particles/pw/ref_pudge_meathook_chain.vpcf", PATTACH_ABSORIGIN, hook_dummy)
	local position = self.ability.caster:GetAbsOrigin() + Vector(0, 0, 96)
	local endPosition = hook_dummy:GetAbsOrigin() + Vector(0, 0, 96)
	ParticleManager:SetParticleControl(particle, 0, endPosition)
	ParticleManager:SetParticleControl(particle, 6, position)
	ParticleManager:SetParticleControl(particle, 10, Vector(300, 0, 0))
	-- local pu = self.NewPFX(particle, position, endPosition, 6, 0, 10) --cpStart, cpEnd, cpDelete)

	hook_dummy.particle = particle
	hook_dummy.dev_hook_counter = 1
	table.insert(self.ability.hook_dummies, hook_dummy)

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, hook_dummy)
	ParticleManager:SetParticleControl(pfx, 1, Vector(0, hook_dummy.dev_hook_counter, 0))
end

function modifier_pudge_wars_meat_hook_handler:CreateChainLink(vDirection)
	-- print("Create chain link:", #self.ability.hook_dummies)
	local previous_chain_dummy = self.ability.hook_dummies[#self.ability.hook_dummies]

	local chain_dummy = CreateUnitByName("wearable_dummy", self.ability.caster:GetOrigin() + self.ability.dir * 75, false, self.ability.caster, self.ability.caster, self.ability.caster:GetTeam())
	chain_dummy:SetForwardVector(vDirection)

	if IsInToolsMode() then
		chain_dummy:SetMaxHealth(#self.ability.hook_dummies)
		chain_dummy:SetHealth(#self.ability.hook_dummies)
	end

	local position = chain_dummy:GetAbsOrigin() + Vector(0, 0, 70)
	local endPosition = previous_chain_dummy:GetAbsOrigin() + vDirection * 75 + Vector(0, 0, 140)

	local particle = ParticleManager:CreateParticle("particles/pw/ref_pudge_meathook_chain.vpcf", PATTACH_ABSORIGIN, chain_dummy)
	ParticleManager:SetParticleControl(particle, 0, endPosition)
	ParticleManager:SetParticleControl(particle, 6, position)
	ParticleManager:SetParticleControl(particle, 10, Vector(300, 0, 0))
	-- local pu = self.NewPFX(particle, position, endPosition, 6, 0, 10) --cpStart, cpEnd, cpDelete)

	chain_dummy.particle = particle
	chain_dummy.dev_hook_counter = #self.ability.hook_dummies + 1
	table.insert(self.ability.hook_dummies, chain_dummy)

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, chain_dummy)
	ParticleManager:SetParticleControl(pfx, 1, Vector(0, chain_dummy.dev_hook_counter, 0))
end

function modifier_pudge_wars_meat_hook_handler:HookForward()
	-- Move hook
	self.ability.dir.z = 0
	local hook_dummy = self.ability.hook_dummies[1]
	local forward_dummy = self.ability.hook_dummies[2]
	local last_dummy = self.ability.hook_dummies[#self.ability.hook_dummies]
	local hook_pos = hook_dummy:GetAbsOrigin()

	hook_dummy:SetAbsOrigin(hook_pos + hook_dummy:GetForwardVector() * self.ability.speed * FrameTime())

	local diff = hook_pos - forward_dummy:GetAbsOrigin()
	diff.z = 0

	if diff:Length2D() > self.ability.linkFollowDistance then
		forward_dummy:SetAbsOrigin(forward_dummy:GetAbsOrigin() + diff:Normalized() * (diff:Length2D() - self.ability.linkFollowDistance))
	end

	-- Move chains
	for i = 3, #self.ability.hook_dummies do
		local previous_chain = self.ability.hook_dummies[i - 1]
		local chain = self.ability.hook_dummies[i]
		local diff = previous_chain:GetAbsOrigin() - chain:GetAbsOrigin()
		diff.z = 0

		if diff:Length2D() > self.ability.linkFollowDistance then
			chain:SetAbsOrigin(chain:GetAbsOrigin() + diff:Normalized() * (diff:Length2D() - self.ability.linkFollowDistance))
		end

		ParticleManager:SetParticleControl(chain.particle, 0, previous_chain:GetAbsOrigin() + Vector(0, 0, 96))
		ParticleManager:SetParticleControl(chain.particle, 6, chain:GetAbsOrigin() + Vector(0, 0, 96))
	end

	-- Create new chain link if distance greater than linkCreationTolerance
	local diff = last_dummy:GetAbsOrigin() - self.ability.caster:GetAbsOrigin()

	if diff:Length2D() > self.ability.linkCreationTolerance then
		diff.z = 0
		local direction = diff:Normalized()
		self:CreateChainLink(direction)
	elseif #self.ability.hook_dummies > 1 then
		ParticleManager:SetParticleControl(self.ability.hook_dummies[#self.ability.hook_dummies].particle, 0, self.ability.caster:GetAbsOrigin() + Vector(0, 0, 120))
	end

	-- Check for collision
	local entities = Entities:FindAllInSphere(GetGroundPosition(hook_pos, hook_dummy), self.ability.radius / 2)
	local target = self:FindValidTarget(entities)

	if target then
		self:HookHit(target)
	end

	-- Check for collision with walls
	local dir = hook_dummy:GetForwardVector()
	local rightBound = 1350
	local leftBound = -1350
	local topBound = 1600
	local bottomBound = -1600

	if hook_pos.x > rightBound and dir.x > 0 then
		local rotAngle = 180 - (math.acos(dir.x) / math.pi * 180) * 2

		if (math.acos(dir.y) / math.pi * 180) > 90 then
			rotAngle = 360 - rotAngle
		end

		hook_dummy:SetForwardVector(RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir))
	elseif hook_pos.x < leftBound and dir.x < 0 then
		local rotAngle = (math.acos(dir.x) / math.pi * 180) * 2 - 180

		if (math.acos(dir.y) / math.pi * 180) < 90 then
			rotAngle = 360 - rotAngle
		end

		hook_dummy:SetForwardVector(RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir))
	elseif hook_pos.y > topBound and dir.y > 0 then
		local rotAngle = 180 - (math.acos(dir.y) / math.pi * 180) * 2

		if (math.acos(dir.x) / math.pi * 180) < 90 then
			rotAngle = 360 - rotAngle
		end

		hook_dummy:SetForwardVector(RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir))
	elseif hook_pos.y < bottomBound and dir.y < 0 then
		local rotAngle = (math.acos(dir.y) / math.pi * 180) * 2 - 180

		if (math.acos(dir.x) / math.pi * 180) > 90 then
			rotAngle = 360 - rotAngle
		end

		hook_dummy:SetForwardVector(RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir))
	end
end

function modifier_pudge_wars_meat_hook_handler:FindValidTarget(hEntities)
	for _, hEntity in pairs(hEntities or {}) do
		if hEntity ~= self.ability.caster and string.find(hEntity:GetClassname(), "pudge") and hEntity:IsAlive() then
			if hEntity:GetTeamNumber() ~= self.ability.caster:GetTeamNumber() then
				return hEntity
			end
		end
	end
end

function modifier_pudge_wars_meat_hook_handler:HookHit(target)
	if target:HasModifier("modifier_pudge_wars_meat_hook") then
		if target:GetTeam() == self.ability.caster:GetTeam() then
			-- Deny
			Notifications:TopToAll({ text = "DENIED!", duration = 4.0 })
		else
			-- Headshot
			Notifications:TopToAll({ text = "HEADSHOT!", duration = 4.0 })
		end

		target:Kill(self, self.ability.caster)
		EmitGlobalSound("Pudgewars.Headshot")
		local headshotParticle = ParticleManager:CreateParticle('particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf', PATTACH_ABSORIGIN, target)
		local headshotPos = target:GetOrigin()
		ParticleManager:SetParticleControl(headshotParticle, 4, Vector(headshotPos.x, headshotPos.y, headshotPos.z))
		ScreenShake(target:GetOrigin(), 100, 100, 1, 9999, 0, true)
	else

	end

	self:DealDamage(self.ability.caster, target, self.ability.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_pudge_wars_meat_hook_handler:HookBackward()
	if #self.ability.hook_dummies > 0 then
		local caster_position = self.ability.caster:GetAbsOrigin()

		for i = 1, #self.ability.hook_dummies do
			local hook_dummy = self.ability.hook_dummies[i]

			if hook_dummy then
				local back_dummy = self.ability.hook_dummies[i + 1]
				local direction = (caster_position - hook_dummy:GetAbsOrigin()):Normalized()

				if back_dummy then
					local diff = hook_dummy:GetAbsOrigin() - back_dummy:GetAbsOrigin()
					diff.z = 0

					-- Move chains backwards
					back_dummy:SetAbsOrigin(back_dummy:GetAbsOrigin() + direction * self.ability.speed * FrameTime())

					ParticleManager:SetParticleControl(back_dummy.particle, 0, hook_dummy:GetAbsOrigin() + Vector(0, 0, 96))
					ParticleManager:SetParticleControl(back_dummy.particle, 6, back_dummy:GetAbsOrigin() + Vector(0, 0, 96))
				end

				-- Move hook as well
				if i == 1 then
					hook_dummy:SetAbsOrigin(hook_dummy:GetAbsOrigin() + direction * self.ability.speed * FrameTime())
				end

				-- Supprimer le chain s'il est assez proche du caster
				local chain_diff = hook_dummy:GetAbsOrigin() - caster_position
				chain_diff.z = 0

				if chain_diff:Length2D() < self.ability.linkDeletionTolerance then
					hook_dummy:RemoveSelf()
					table.remove(self.ability.hook_dummies, i)
				end
			end
		end
	end

	-- print("Remaining hooks:", #self.ability.hook_dummies)
	if #self.ability.hook_dummies == 0 then
		self:Destroy()
	end
end

function modifier_pudge_wars_meat_hook_handler:DestroyHook()
	local hook_dummy = self.ability.hook_dummies[#self.ability.hook_dummies]

	-- Destroy hook
	hook_dummy:Destroy()
	table.remove(self.ability.hook_dummies, #self.ability.hook_dummies)
end

function modifier_pudge_wars_meat_hook_handler:DealDamage(caster, target, damage, damage_type, damage_flags)
	local damage_table = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damage_type,
		damage_flags = damage_flags,
		ability = self.ability
	}

	ApplyDamage(damage_table)
end
