print("[HOOK] hook loading")

local HOOK_BOUNDS = {
	top = 1600,
	bottom = -1600,
	left = -1472,
	right = 1472,
	center = Vector(0, -50, 0),
	center_radius = 150,
	rebounce_frames = 10,
}

local SCAN_HEIGHTS = {
	forward = {Vector(0, 0, -100), Vector(0, 0, 100)},
	backward = {Vector(0, 0, -100), Vector(0, 0, 0)},
}

local RUNE_UNITS = {
	npc_dummy_rune_haste = 1,
	npc_dummy_rune_gold = 2,
	npc_dummy_rune_ion = 3,
	npc_dummy_rune_fire = 4,
	npc_dummy_rune_dynamite = 5,
	rune_dynamite = 5,
	rune_lightning = 6,
	npc_dummy_rune_diretide = 7,
	npc_dummy_rune_lightning = 6, -- legacy name used in the old script
}

local DEFAULT_CHAIN_PFX = "particles/pw/ref_pudge_meathook_chain.vpcf"

local function normalize2d(vec)
	if vec == nil then
		return Vector(1, 0, 0)
	end

	local flat = Vector(vec.x, vec.y, 0)
	if flat:Length2D() == 0 then
		return Vector(1, 0, 0)
	end

	return flat:Normalized()
end

local function reflect(dir, normal)
	local n = normalize2d(normal)
	local dot = dir.x * n.x + dir.y * n.y + dir.z * n.z
	local reflected = dir - n * (2 * dot)
	reflected.z = 0
	return normalize2d(reflected)
end

local function calculateHookDamage(hero, target, base_damage, hook_speed)
	local hook_damage = base_damage

	for i = 0, 5 do
		local item = hero:GetItemInSlot(i)

		if item then
			if item:GetAbilityName() == "item_naix_jaw" then
				hero:SetHealth(hero:GetHealth() + base_damage / 100 * item:GetSpecialValueFor("hook_lifesteal"))
				local lifestealParticle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN, hero)
				local lifestealPos = hero:GetOrigin()
				ParticleManager:SetParticleControl(lifestealParticle, 4, Vector(lifestealPos.x, lifestealPos.y, lifestealPos.z))
			end

			if item:GetAbilityName() == "item_barathrum_lantern" then
				hook_damage = hook_damage + hook_speed / 100 * item:GetSpecialValueFor("damage_pct")
				local baraParticle = ParticleManager:CreateParticle("particles/items2_fx/phase_boots.vpcf", PATTACH_ABSORIGIN, target)
				local baraPos = target:GetOrigin()
				ParticleManager:SetParticleControl(baraParticle, 4, Vector(baraPos.x, baraPos.y, baraPos.z))
				break
			end
		end
	end

	return hook_damage
end

local function bounceBonusDamage(bounces, hero)
	if hero:HasItemInInventory("item_ricochet_turbine") then
		return 0.1 * bounces
	end

	local scale = 0.2
	local item_number = 2

	while scale < 0.6 do
		if hero:HasItemInInventory("item_ricochet_turbine_" .. item_number) then
			return scale * bounces
		end

		scale = scale + 0.1
		item_number = item_number + 1
	end

	return 0
end

local function shouldBounceOnShield(target)
	return GameMode.shield_carrier ~= nil and GameMode.shield_carrier == target
end

local function isPudgeHero(entity)
	return entity ~= nil and entity.GetClassname and string.find(entity:GetClassname(), "pudge") ~= nil
end

local function isBarrier(entity)
	return entity ~= nil and entity.GetClassname and string.find(entity:GetClassname(), "creature") and string.find(entity:GetUnitName(), "barrier")
end

local function isMine(entity)
	return entity ~= nil and entity.GetClassname and string.find(entity:GetClassname(), "creep") and string.find(entity:GetUnitName(), "mine")
end

local function runeType(entity)
	if entity == nil or not entity.GetUnitName then
		return nil
	end

	return RUNE_UNITS[entity:GetUnitName()]
end

local function triggerLightning(caster, target)
	if not caster:HasModifier("modifier_disruptor_thunder_strike") then
		return
	end

	local lightning_dummy = CreateUnitByName("npc_lightning_dummy", target:GetOrigin(), false, caster, caster, caster:GetTeamNumber())

	local arc_team = target:GetTeamNumber()
	if caster:GetTeamNumber() == target:GetTeamNumber() then
		if target:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			arc_team = DOTA_TEAM_BADGUYS
		else
			arc_team = DOTA_TEAM_GOODGUYS
		end
	end

	local arc_dummy = CreateUnitByName("npc_arc_dummy", target:GetOrigin(), false, nil, nil, arc_team)

	if not lightning_dummy or not arc_dummy then
		return
	end

	castInstantSpell(lightning_dummy, "pudge_wars_lightning_field", 1, 10)

	if IsValidEntity(arc_dummy) then
		castSpell(caster, arc_dummy, "pudge_wars_arc_lightning", 1, 10)
		castSpell(caster, arc_dummy, "pudge_wars_lightning_bolt", 1, 2)
		target:EmitSound("Hero_Zuus.LightningBolt")
	end
end

-- Particle Unit system kept but simplified for a single chain between hero and hook
if ParticleUnit == nil then
	ParticleUnit = {}
	ParticleUnit.__index = ParticleUnit
end

function ParticleUnit.new(particle, position, endPosition, cpStart, cpEnd, cpDelete)
	local o = {}
	setmetatable(o, ParticleUnit)

	o.particle = particle
	o.position = position
	o.endPosition = endPosition
	o.cpStart = cpStart or 0
	o.cpEnd = cpEnd or 6
	o.cpDelete = cpDelete or 10

	ParticleManager:SetParticleControl(o.particle, o.cpStart, position)
	ParticleManager:SetParticleControl(o.particle, o.cpEnd, endPosition)
	ParticleManager:SetParticleControl(o.particle, o.cpDelete, Vector(300, 0, 0))

	return o
end

function ParticleUnit:GetStart()
	return self.position
end

function ParticleUnit:GetEnd()
	return self.endPosition
end

function ParticleUnit:SetStart(vec)
	self.position = vec
	ParticleManager:SetParticleControl(self.particle, self.cpStart, vec)
end

function ParticleUnit:SetEnd(vec)
	self.endPosition = vec
	ParticleManager:SetParticleControl(self.particle, self.cpEnd, vec)
end

function ParticleUnit:Destroy()
	ParticleManager:SetParticleControl(self.particle, self.cpDelete, Vector(0, 0, 0))
end

-- Hook projectile controller
local HookProjectile = {}
HookProjectile.__index = HookProjectile

function HookProjectile.new(config)
	local o = {}
	setmetatable(o, HookProjectile)

	o.ability = config.ability
	o.caster = config.caster
	o.pudgeState = config.pudgeState
	o.direction = normalize2d(config.direction)
	o.damage = config.damage
	o.range = config.range
	o.speed = config.speed
	o.radius = config.radius
	o.modelName = config.modelName
	o.modelScale = config.modelScale
	o.chainPfx = config.chainPfx
	o.useFlame = config.useFlame

	o.travelled = 0
	o.bounces = 0
	o.rebounceCooldown = 0
	o.retracting = false
	o.finished = false
	o.hookedUnit = nil
	o.ruptureUnit = nil
	o.holdRupture = false
	o.timeout = GameRules:GetGameTime() + o.range / o.speed

	return o
end

function HookProjectile:Launch(onFinish)
	self.onFinish = onFinish
	self:SpawnHead()
	self:StartThink()
end

function HookProjectile:SpawnHead()
	local origin = self.caster:GetAbsOrigin()

	self.head = CreateUnitByName("npc_reflex_hook_test", origin + self.direction * 75, false, self.caster, self.caster, self.caster:GetTeamNumber())
	self.head:SetAbsOrigin(origin + Vector(0, 0, 125))
	self.head:SetForwardVector(self.direction)
	self.head:SetModel(self.modelName)
	self.head:SetOriginalModel(self.modelName)
	self.head:SetModelScale(self.modelScale)

	local dummyAbility = self.head:FindAbilityByName("reflex_dummy_unit")
	if dummyAbility then
		dummyAbility:SetLevel(1)
	end

	if self.useFlame then
		self:SpawnFireDummy(origin)
	end

	local startPos = origin + Vector(0, 0, 70)
	local particle = ParticleManager:CreateParticle(self.chainPfx, PATTACH_RENDERORIGIN_FOLLOW, self.head)
	self.chain = ParticleUnit.new(particle, startPos, self.head:GetAbsOrigin(), 6, 0, 10)
end

function HookProjectile:SpawnFireDummy(origin)
	self.fireDummy = CreateUnitByName("npc_firefly_hook_dummy", origin + self.direction * 75, false, self.caster, self.caster, self.caster:GetTeamNumber())
	local dummy = self.fireDummy:FindAbilityByName("reflex_dummy_unit")
	if dummy then
		dummy:SetLevel(1)
	end
	self.fireDummy:AddAbility("pudge_wars_firefly")
	local abil = self.fireDummy:FindAbilityByName("pudge_wars_firefly")

	if abil then
		abil:SetLevel(1)
		self.fireDummy:CastAbilityImmediately(abil, 0)
	end
end

function HookProjectile:StartThink()
	Timers:CreateTimer(function()
		if not self.head or self.head:IsNull() or self.finished then
			if self.pudgeState then
				self.pudgeState.is_throwing_hook = false
			end
			return
		end

		if self.retracting then
			self:UpdateRetract()
		else
			self:UpdateForward()
		end

		self:UpdateVisuals()

		if self.finished then
			self:Cleanup()
			return
		end

		return FrameTime()
	end)
end

function HookProjectile:UpdateForward()
	local dt = FrameTime()
	local move = self.direction * self.speed * dt
	local newPos = self.head:GetAbsOrigin() + move
	self.travelled = self.travelled + move:Length2D()

	self.head:SetAbsOrigin(newPos)
	self.head:SetForwardVector(self.direction)

	self:ScanForHits(true)
	self:HandleBounces(newPos)

	if GameRules:GetGameTime() > self.timeout then
		self:BeginRetract(false)
	end
end

function HookProjectile:UpdateRetract()
	local dt = FrameTime()
	local direction = self.caster:GetAbsOrigin() - self.head:GetAbsOrigin()
	direction.z = 0

	if self.hookedUnit and IsValidEntity(self.hookedUnit) then
		self.hookedUnit:SetAbsOrigin(self.head:GetAbsOrigin() + Vector(0, 0, -125))
	end

	if direction:Length2D() < 100 then
		self:FinishRetract()
		return
	end

	local step = normalize2d(direction) * self.speed * dt
	self.head:SetAbsOrigin(self.head:GetAbsOrigin() + step)
	self.head:SetForwardVector(normalize2d(-direction))
end

function HookProjectile:GetScanOffsets(forward)
	local offsets = forward and SCAN_HEIGHTS.forward or SCAN_HEIGHTS.backward
	local heroX = self.caster:GetAbsOrigin().x
	local isFarSide = (heroX > 200) or (heroX < -200)
	local zOffset = isFarSide and -200 or (forward and 100 or 0)

	return {offsets[1], Vector(0, 0, zOffset)}
end

function HookProjectile:ScanForHits(forward)
	if self.hookedUnit then
		return
	end

	for _, offset in ipairs(self:GetScanOffsets(forward)) do
		local entities = Entities:FindAllInSphere(self.head:GetAbsOrigin() + offset, self.radius / 2)

		for _, entity in pairs(entities) do
			if self:HandleEntity(entity, forward) then
				return
			end
		end
	end
end

function HookProjectile:HandleEntity(entity, forward)
	if not entity or entity:IsNull() or entity == self.caster or not entity:IsAlive() or self.hookedUnit then
		return false
	end

	if isPudgeHero(entity) and entity ~= self.caster and not shouldBounceOnShield(entity) then
		self:HookHero(entity)
		return true
	elseif isPudgeHero(entity) and entity ~= self.caster and shouldBounceOnShield(entity) then
		if forward then
			self:BounceFrom(entity:GetAbsOrigin(), "Hero_Sven.Attack.Impact")
		end

		return false
	elseif isBarrier(entity) then
		if forward then
			self:BounceFrom(entity:GetAbsOrigin(), "Hero_WitchDoctor.Attack")
		end

		triggerLightning(self.caster, entity)

		if self.caster:GetTeamNumber() ~= entity:GetTeamNumber() then
			local hook_damage = calculateHookDamage(self.caster, entity, self.damage, self.speed)
			hook_damage = hook_damage + bounceBonusDamage(self.bounces, self.caster) * self.damage
			dealDamage(self.caster, entity, hook_damage)
		end
		return false
	elseif isMine(entity) then
		self:HookNeutral(entity)
		return true
	end

	local rune = runeType(entity)
	if rune then
		self:HookRune(entity, rune)
		return true
	end

	return false
end

function HookProjectile:HookHero(target)
	self.caster.successful_hooks = self.caster.successful_hooks or 0

	if Battlepass and Battlepass.HasPudgeHookStreakCounter and Battlepass:HasPudgeHookStreakCounter(self.caster:GetPlayerID()) then
		self.caster.successful_hooks = self.caster.successful_hooks + 1
		EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Hero_Pudge.HookDrag.Arcana", self.caster)

		if self.caster.successful_hooks >= 2 then
			local pfx = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_red_hook_streak.vpcf"
			if self.caster.pudge_arcana == 1 then
				pfx = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_hook_streak.vpcf"
			end

			local hook_counter = ParticleManager:CreateParticle(pfx, PATTACH_OVERHEAD_FOLLOW, self.caster)
			local stack_10 = math.floor(self.caster.successful_hooks / 10)
			ParticleManager:SetParticleControl(hook_counter, 2, Vector(stack_10, self.caster.successful_hooks - stack_10 * 10, self.caster.successful_hooks))
			ParticleManager:ReleaseParticleIndex(hook_counter)
		end
	end

	self.caster:EmitSound("Hero_Pudge.AttackHookImpact")

	if target:HasModifier("modifier_pudge_meat_hook") then
		self:HandleHeadshot(target)
		self:BeginRetract(true)
		self.hookedUnit = target
		return
	end

	local hook_damage = calculateHookDamage(self.caster, target, self.damage, self.speed)
	hook_damage = hook_damage + bounceBonusDamage(self.bounces, self.caster) * self.damage

	if self.caster:GetTeamNumber() ~= target:GetTeamNumber() then
		self.ruptureUnit = applyRupture(self.caster, target)
	end

	triggerLightning(self.caster, target)

	target:AddNewModifier(self.caster, nil, "modifier_pudge_meat_hook", {})
	if self.caster:GetTeamNumber() ~= target:GetTeamNumber() then
		dealDamage(self.caster, target, hook_damage)
	end

	self.hookedUnit = target
	self:BeginRetract(true)
end

function HookProjectile:HandleHeadshot(target)
	if self.caster:GetTeamNumber() ~= target:GetTeamNumber() then
		target.headshot = true
		dealDamage(self.caster, target, 9000)
		EmitGlobalSound("Pudgewars.Headshot")
		Notifications:TopToAll({text = "HEADSHOT!", duration = 4.0})
	else
		dealDamage(self.caster, target, 9000)
		EmitGlobalSound("Pudgewars.Headshot")
		Notifications:TopToAll({text = "DENIED!", duration = 4.0})
	end

	local headshotParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN, target)
	local headshotPos = target:GetOrigin()
	ParticleManager:SetParticleControl(headshotParticle, 4, Vector(headshotPos.x, headshotPos.y, headshotPos.z))
	ScreenShake(target:GetOrigin(), 100, 100, 1, 9999, 0, true)
end

function HookProjectile:HookNeutral(target)
	self.caster:EmitSound("Hero_Pudge.AttackHookImpact")
	target:AddNewModifier(self.caster, nil, "modifier_pudge_meat_hook", {})
	self.hookedUnit = target
	self:BeginRetract(true)
end

function HookProjectile:HookRune(target, rune)
	self.caster:EmitSound("Hero_Pudge.AttackHookImpact")
	GameMode:RuneHooked(target, self.caster, rune)
	self.hookedUnit = target
	self:BeginRetract(true)
end

function HookProjectile:BounceFrom(point, sound)
	if self.rebounceCooldown > 0 then
		return
	end

	self.bounces = self.bounces + 1
	self.direction = reflect(self.direction, self.head:GetAbsOrigin() - point)
	self.rebounceCooldown = HOOK_BOUNDS.rebounce_frames

	if sound then
		self.head:EmitSound(sound)
	end
end

function HookProjectile:HandleBounces(headPos)
	self.rebounceCooldown = math.max(0, self.rebounceCooldown - 1)

	-- Walls
	if headPos.x > HOOK_BOUNDS.right and self.direction.x > 0 then
		self.direction = reflect(self.direction, Vector(1, 0, 0))
		self.bounces = self.bounces + 1
	elseif headPos.x < HOOK_BOUNDS.left and self.direction.x < 0 then
		self.direction = reflect(self.direction, Vector(-1, 0, 0))
		self.bounces = self.bounces + 1
	elseif headPos.y > HOOK_BOUNDS.top and self.direction.y > 0 then
		self.direction = reflect(self.direction, Vector(0, 1, 0))
		self.bounces = self.bounces + 1
	elseif headPos.y < HOOK_BOUNDS.bottom and self.direction.y < 0 then
		self.direction = reflect(self.direction, Vector(0, -1, 0))
		self.bounces = self.bounces + 1
	end

	-- Center pillar
	local centerDiff = HOOK_BOUNDS.center - headPos
	centerDiff.z = 0
	if centerDiff:Length2D() < HOOK_BOUNDS.center_radius and self.rebounceCooldown == 0 then
		self:BounceFrom(HOOK_BOUNDS.center, nil)
	end
end

function HookProjectile:BeginRetract(hitSomething)
	if self.retracting then
		return
	end

	if not hitSomething then
		self.caster.successful_hooks = 0
	end

	self.retracting = true
end

function HookProjectile:FinishRetract()
	if self.hookedUnit and IsValidEntity(self.hookedUnit) then
		self.hookedUnit:RemoveModifierByName("modifier_pudge_meat_hook")

		local shouldDelayRupture = false
		for i = 0, 5 do
			local item = self.caster:GetItemInSlot(i)
			if item and item:GetAbilityName() == "item_strygwyr_claw" and item:GetLevel() == 5 then
				shouldDelayRupture = true
			end
		end

		if shouldDelayRupture then
			local victim = self.hookedUnit
			Timers:CreateTimer(3.0, function()
				if victim and IsValidEntity(victim) then
					victim:RemoveModifierByName("modifier_bloodseeker_rupture")
				end

				if self.ruptureUnit ~= nil then
					self.ruptureUnit:Destroy()
				end
			end)
		else
			self.hookedUnit:RemoveModifierByName("modifier_bloodseeker_rupture")
			if self.ruptureUnit ~= nil then
				self.ruptureUnit:Destroy()
			end
		end

		if runeType(self.hookedUnit) ~= nil or (isMine(self.hookedUnit) and not self.hookedUnit:IsAlive()) then
			self.hookedUnit:RemoveSelf()
		else
			FindClearSpaceForUnit(self.hookedUnit, self.hookedUnit:GetAbsOrigin(), true)
		end
	elseif self.ruptureUnit ~= nil then
		self.ruptureUnit:Destroy()
	end

	self.finished = true
end

function HookProjectile:UpdateVisuals()
	if self.chain then
		self.chain:SetStart(self.caster:GetAbsOrigin() + Vector(0, 0, 70))
		self.chain:SetEnd(self.head:GetAbsOrigin())
	end

	if self.fireDummy then
		self.fireDummy:SetAbsOrigin(self.head:GetAbsOrigin() + Vector(0, 0, -200))
	end
end

function HookProjectile:CleanupFireDummy()
	if self.fireDummy then
		self.fireDummy:SetOrigin(Vector(-2368, 2368, 0))
		if _G.all_flame_hooks == nil then
			_G.all_flame_hooks = {}
		end
		table.insert(_G.all_flame_hooks, self.fireDummy)
		self.fireDummy = nil
	end
end

function HookProjectile:Cleanup()
	if self.chain then
		self.chain:Destroy()
		self.chain = nil
	end

	self:CleanupFireDummy()

	if self.head and IsValidEntity(self.head) then
		self.head:ForceKill(false)
		self.head = nil
	end

	if self.pudgeState then
		self.pudgeState.is_throwing_hook = false
	end

	if self.onFinish then
		self.onFinish()
	end
end

-- Ability definition
pudge_wars_custom_hook = class({})

function pudge_wars_custom_hook:OnSpellStart()
	local caster = self:GetCaster()
	if not caster or caster:IsNull() then
		return
	end

	local pudge = PudgeArray[caster:GetPlayerID()]
	if pudge and pudge.is_throwing_hook then
		self:EndCooldown()
		return
	end

	if pudge then
		pudge.is_throwing_hook = true
	end

	caster:EmitSound("Hero_Pudge.AttackHookExtend")

	if GameMode and GameMode.AssignHookModel and (not caster.hook_model or caster.hook_model == "") then
		GameMode:AssignHookModel(caster)
	end

	local direction = normalize2d(self:GetCursorPosition() - caster:GetAbsOrigin())
	local modelName = caster.hook_model or "models/heroes/pudge/righthook.vmdl"
	local chainPfx = caster.hook_pfx or DEFAULT_CHAIN_PFX

	local damage = self:GetSpecialValueFor("base_damage")
	local range = self:GetSpecialValueFor("base_range")
	local speed = self:GetSpecialValueFor("base_speed")
	local radius = self:GetSpecialValueFor("base_radius")
	local modelScale = 0.9

	local hook_damage_ab = caster:FindAbilityByName("pudge_wars_upgrade_hook_damage")
	local hook_range_ab = caster:FindAbilityByName("pudge_wars_upgrade_hook_range")
	local hook_speed_ab = caster:FindAbilityByName("pudge_wars_upgrade_hook_speed")
	local hook_size_ab = caster:FindAbilityByName("pudge_wars_upgrade_hook_size")

	if hook_damage_ab then
		damage = damage + hook_damage_ab:GetSpecialValueFor("bonus_damage")
	end

	if hook_range_ab then
		range = range + hook_range_ab:GetSpecialValueFor("bonus_range")
	end

	if hook_speed_ab then
		speed = speed + hook_speed_ab:GetSpecialValueFor("bonus_speed")
	end

	if hook_size_ab then
		radius = radius + hook_size_ab:GetSpecialValueFor("bonus_radius")
		modelScale = modelScale + hook_size_ab:GetSpecialValueFor("hook_radius")
	end

	if caster:HasModifier("modifier_slow_rune") then
		speed = speed - 300
	end

	if caster:HasModifier("modifier_rune_haste") then
		speed = speed + 400
	end

	local hook = HookProjectile.new({
		ability = self,
		caster = caster,
		pudgeState = pudge or {},
		direction = direction,
		damage = damage,
		range = range,
		speed = speed,
		radius = radius,
		modelName = modelName,
		modelScale = modelScale,
		chainPfx = chainPfx,
		useFlame = pudge and pudge.use_flame or false,
	})

	hook:Launch(function()
		if pudge then
			pudge.is_throwing_hook = false
		end
	end)
end

function pudge_wars_custom_hook:GetCastRange(location, target)
	local range = self:GetSpecialValueFor("base_range")
	local caster = self:GetCaster()

	if caster then
		local hook_range_ab = caster:FindAbilityByName("pudge_wars_upgrade_hook_range")
		if hook_range_ab then
			range = range + hook_range_ab:GetSpecialValueFor("bonus_range")
		end
	end

	return range
end
