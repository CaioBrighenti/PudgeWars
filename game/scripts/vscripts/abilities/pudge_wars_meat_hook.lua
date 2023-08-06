-- Old hook code to format
print("[HOOK] hook loading")

-- function GetHookDamage(hero, target, hook_damage, hook_speed)
-- 	local naix_jaw = hero:FindItemInInventory("item_naix_jaw")
-- 	local bara_lantern = hero:FindItemInInventory("item_barathrum_lantern")

-- 	if naix_jaw then
-- 		hook_damage = hook_damage + hook_damage / 100 * naix_jaw:GetSpecialValueFor("hook_damage")
-- 	end

-- 	if bara_lantern then
-- 		hook_damage = hook_damage + hook_damage / 100 * bara_lantern:GetSpecialValueFor("hook_damage")
-- 	end

-- 	return hook_damage

-- 	for i = 0, 5 do
-- 		local item = hero:GetItemInSlot(i)

-- 		if item then
-- 			if item:GetAbilityName() == "item_naix_jaw" then
-- 				hero:SetHealth(hero:GetHealth() + hook_damage / 100 * item:GetSpecialValueFor("hook_lifesteal"))
-- 				lifestealParticle = ParticleManager:CreateParticle('particles/generic_gameplay/generic_lifesteal.vpcf', PATTACH_ABSORIGIN, hero)
-- 				lifestealPos = hero:GetOrigin()
-- 				ParticleManager:SetParticleControl(lifestealParticle, 4, Vector(lifestealPos.x, lifestealPos.y, lifestealPos.z))
-- 			end

-- 			if item:GetAbilityName() == "item_barathrum_lantern" then
-- 				hook_damage = hook_damage + hook_speed / 100 * item:GetSpecialValueFor("damage_pct")
-- 				baraParticle = ParticleManager:CreateParticle('particles/items2_fx/phase_boots.vpcf', PATTACH_ABSORIGIN, target)
-- 				baraPos = target:GetOrigin()
-- 				ParticleManager:SetParticleControl(baraParticle, 4, Vector(baraPos.x, baraPos.y, baraPos.z))
-- 				break
-- 			end
-- 		end
-- 	end

-- 	return hook_damage
-- end

-- function bounceDamage(bounces, hero)
-- 	if hero:HasItemInInventory("item_ricochet_turbine") then
-- 		return 0.1 * bounces
-- 	end

-- 	local i = 0.2
-- 	local item_number = 2

-- 	while i < 0.6 do
-- 		if hero:HasItemInInventory("item_ricochet_turbine_" .. (item_number)) then
-- 			return (i * bounces)
-- 		end

-- 		i = i + 0.1

-- 		item_number = item_number + 1
-- 	end

-- 	return 0
-- end

-- function findEntity(entities, vars_table, forward, bounces, hero)
-- 	hooked = vars_table[0]
-- 	hero = vars_table[1]
-- 	complete = vars_table[2]
-- 	damage = vars_table[3]
-- 	speed = vars_table[4]
-- 	bounce = vars_table[5]
-- 	rupture_unit = vars_table[6]
-- 	es_totem = vars_table[7]

-- 	if entities ~= nil then
-- 		for k, v in pairs(entities) do
-- 			--if string.find(v:GetClassname(), "pudge") or string.find(v:GetClassname(), "mine") then
-- 			if hooked == nil then
-- 				if ((string.find(v:GetClassname(), "pudge")) and (v ~= hero) and (v:IsAlive())) and ((GameMode.shield_carrier == nil) or (GameMode.shield_carrier ~= v)) then
-- 					if Battlepass:HasPudgeHookStreakCounter(hero:GetPlayerID()) then
-- 						hero.successful_hooks = hero.successful_hooks + 1
-- 						EmitSoundOnLocationWithCaster(hero:GetAbsOrigin(), "Hero_Pudge.HookDrag.Arcana", hero)
-- 						local pfx = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_red_hook_streak.vpcf"
-- 						if hero.pudge_arcana == 1 then
-- 							pfx = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_hook_streak.vpcf"
-- 						end
-- 						if hero.successful_hooks >= 2 then
-- 							local hook_counter = ParticleManager:CreateParticle(pfx, PATTACH_OVERHEAD_FOLLOW, hero)
-- 							local stack_10 = math.floor(hero.successful_hooks / 10)
-- 							ParticleManager:SetParticleControl(hook_counter, 2, Vector(stack_10, hero.successful_hooks - stack_10 * 10, hero.successful_hooks))
-- 							ParticleManager:ReleaseParticleIndex(hook_counter)
-- 						end
-- 					end

-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					complete = true
-- 					if v:HasModifier("modifier_pudge_meat_hook") and (hero:GetTeamNumber() ~= v:GetTeamNumber()) then
-- 						--HEADSHOT
-- 						v.headshot = true
-- 						dealDamage(hero, v, 9000)
-- 						EmitGlobalSound("Pudgewars.Headshot")
-- 						--sendAMsg('HEADSHOT!')
-- 						Notifications:TopToAll({ text = "HEADSHOT!", duration = 4.0 })
-- 						local headshotParticle = ParticleManager:CreateParticle('particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf', PATTACH_ABSORIGIN, v)
-- 						local headshotPos = v:GetOrigin()
-- 						ParticleManager:SetParticleControl(headshotParticle, 4, Vector(headshotPos.x, headshotPos.y, headshotPos.z))
-- 						ScreenShake(v:GetOrigin(), 100, 100, 1, 9999, 0, true)
-- 					elseif v:HasModifier("modifier_pudge_meat_hook") and (hero:GetTeamNumber() == v:GetTeamNumber()) then
-- 						--DENY
-- 						dealDamage(hero, v, 9000)
-- 						EmitGlobalSound("Pudgewars.Headshot") -- change to DENY SOUND
-- 						Notifications:TopToAll({ text = "DENIED!", duration = 4.0 })
-- 						local headshotParticle = ParticleManager:CreateParticle('particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf', PATTACH_ABSORIGIN, v)
-- 						local headshotPos = v:GetOrigin()
-- 						ParticleManager:SetParticleControl(headshotParticle, 4, Vector(headshotPos.x, headshotPos.y, headshotPos.z))
-- 						ScreenShake(v:GetOrigin(), 100, 100, 1, 9999, 0, true)
-- 					else
-- 						local hookdamage = GetHookDamage(hero, v, damage, speed)
-- 						hookdamage = hookdamage + (bounceDamage(bounces, hero) * damage)
-- 						rupture_unit = applyRupture(hero, v)

-- 						if hero:HasModifier("modifier_disruptor_thunder_strike") then
-- 							--if the hero is under the effect of the lightning rune)
-- 							local light_unit = CreateUnitByName("npc_lightning_dummy", v:GetOrigin(), false, hero, hero, hero:GetTeamNumber())
-- 							local arc_unit = nil
-- 							if (hero:GetTeamNumber() ~= v:GetTeamNumber()) then
-- 								arc_unit = CreateUnitByName("npc_arc_dummy", v:GetOrigin(), false, nil, nil, v:GetTeamNumber())
-- 							elseif v:GetTeam() == DOTA_TEAM_GOODGUYS then
-- 								arc_unit = CreateUnitByName("npc_arc_dummy", v:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)
-- 							else
-- 								arc_unit = CreateUnitByName("npc_arc_dummy", v:GetOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)
-- 							end

-- 							if arc_unit == nil or light_unit == nil then
-- 								return
-- 							end

-- 							castInstantSpell(light_unit, "pudge_wars_lightning_field", 1, 10)

-- 							if IsValidEntity(arc_unit) then
-- 								castSpell(hero, arc_unit, "pudge_wars_arc_lightning", 1, 10)
-- 								castSpell(hero, arc_unit, "pudge_wars_lightning_bolt", 1, 2)
-- 								v:EmitSound("Hero_Zuus.LightningBolt")
-- 							else
-- 								return
-- 							end
-- 						end

-- 						--v:AddNewModifier(hero, nil, "modifier_rooted", {})
-- 						v:AddNewModifier(hero, nil, "modifier_pudge_meat_hook", {})
-- 						if (hero:GetTeamNumber() ~= v:GetTeamNumber()) then
-- 							dealDamage(hero, v, hookdamage)
-- 						end
-- 					end
-- 					hooked = v
-- 				elseif ((string.find(v:GetClassname(), "pudge")) and (v ~= hero) and (v:IsAlive())) and ((GameMode.shield_carrier ~= nil) or (GameMode.shield_carrier == v)) or (string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "barrier") and v:IsAlive()) then
-- 					if forward then
-- 						bounce = true --BOUNCE

-- 						if (string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "barrier") and v:IsAlive()) then
-- 							if hero:HasModifier("modifier_disruptor_thunder_strike") then
-- 								--if the hero is under the effect of the lightning rune
-- 								local light_unit = CreateUnitByName("npc_lightning_dummy", v:GetOrigin(), false, hero, hero, hero:GetTeamNumber())
-- 								local arc_unit = nil
-- 								if (hero:GetTeamNumber() ~= v:GetTeamNumber()) then
-- 									arc_unit = CreateUnitByName("npc_arc_dummy", v:GetOrigin(), false, nil, nil, v:GetTeamNumber())
-- 								elseif v:GetTeam() == DOTA_TEAM_GOODGUYS then
-- 									arc_unit = CreateUnitByName("npc_arc_dummy", v:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)
-- 								else
-- 									arc_unit = CreateUnitByName("npc_arc_dummy", v:GetOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)
-- 								end

-- 								if arc_unit == nil or light_unit == nil then
-- 									return
-- 								end

-- 								castInstantSpell(light_unit, "pudge_wars_lightning_field", 1, 10)

-- 								if IsValidEntity(arc_unit) then
-- 									castSpell(hero, arc_unit, "pudge_wars_arc_lightning", 1, 10)
-- 									castSpell(hero, arc_unit, "pudge_wars_lightning_bolt", 1, 2)
-- 									v:EmitSound("Hero_Zuus.LightningBolt")
-- 								else
-- 									return
-- 								end
-- 							end

-- 							--Deal damage as well if its a totem
-- 							es_totem = v
-- 							local hookdamage = GetHookDamage(hero, v, damage, speed)
-- 							hookdamage = hookdamage + (bounceDamage(bounces, hero) * damage)
-- 							if (hero:GetTeamNumber() ~= v:GetTeamNumber()) then
-- 								dealDamage(hero, v, hookdamage)
-- 							end
-- 						end
-- 					end
-- 				elseif string.find(v:GetClassname(), "creep") and string.find(v:GetUnitName(), "mine") and v:IsAlive() then
-- 					--Only do v:GetUnitName() if its a creep so we know its a unit and doesnt throw an error
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					complete = true
-- 					hooked = v
-- 					-- v:AddNewModifier(hero, nil, "modifier_rooted", {})
-- 					v:AddNewModifier(hero, nil, "modifier_pudge_meat_hook", {})
-- 				elseif string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "dummy_rune_haste") and v:IsAlive() then
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					GameMode:RuneHooked(v, hero, 1)
-- 					complete = true
-- 					hooked = v
-- 				elseif string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "dummy_rune_gold") and v:IsAlive() then
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					GameMode:RuneHooked(v, hero, 2)
-- 					complete = true
-- 					hooked = v
-- 				elseif string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "dummy_rune_ion") and v:IsAlive() then
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					GameMode:RuneHooked(v, hero, 3)
-- 					complete = true
-- 					hooked = v
-- 				elseif string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "npc_dummy_rune_fire") and v:IsAlive() then
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					GameMode:RuneHooked(v, hero, 4)
-- 					complete = true
-- 					hooked = v
-- 				elseif string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "rune_dynamite") and v:IsAlive() then
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					GameMode:RuneHooked(v, hero, 5)
-- 					complete = true
-- 					hooked = v
-- 				elseif string.find(v:GetClassname(), "creature") and string.find(v:GetUnitName(), "rune_lightning") and v:IsAlive() then
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					GameMode:RuneHooked(v, hero, 6)
-- 					complete = true
-- 					hooked = v
-- 				elseif string.find(v:GetClassname(), "creature") and v:GetUnitName() == "npc_dummy_rune_diretide" and v:IsAlive() then
-- 					hero:EmitSound('Hero_Pudge.AttackHookImpact')
-- 					GameMode:RuneHooked(v, hero, 7)
-- 					complete = true
-- 					hooked = v
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- function LaunchHook(keys)
-- 	print("Launch Hook")
-- 	local hero = keys.caster
-- 	local pudge = PudgeArray[hero:GetPlayerID()]
-- 	local hook_ab = hero:FindAbilityByName("pudge_wars_custom_hook")

-- 	local hooks = {} -- a bunch of dummy units to track hook position
-- 	local damage = hook_ab:GetSpecialValueFor("base_damage")
-- 	local distance = hook_ab:GetSpecialValueFor("base_range")
-- 	local speed = hook_ab:GetSpecialValueFor("base_speed")
-- 	local radius = hook_ab:GetSpecialValueFor("base_radius")
-- 	local hookCount = 1
-- 	local hooked = nil
-- 	local modelScale = 0.9

-- 	local dropped = false                  -- Has a hero been dropped from the hook? If so, don't rehook them or anyone
-- 	local topBound = 1600                  -- Top wall y coordinate
-- 	local bottomBound = -1600              -- Bottom wall y coordinate
-- 	local leftBound = -1472                -- Left wall x coordinate
-- 	local rightBound = 1472                -- Right wall y coordinate
-- 	local centerRadius = 150               -- Radius of bounce circle around the ancient in center
-- 	local ancientPosition = Vector(0, -50, 0) -- Position to use as the ancient's position.  Moved down slightly to give slightly better appearance
-- 	local rebounceToleranceMax = 10        -- Number of gameframe ticks to wait between bounces in case a fast hook goes deep within the ancient before bouncing
-- 	local rebounceTolerance = 0            -- Rebounce gameframe counter
-- 	local shield_barrier_bounce = false    --If hit a pudge with shield_barrier
-- 	local has_bounced_on_shield = false
-- 	local bounces = 0                      --Calculation on bounces for Ricochets Turbine

-- 	local linkCreationTolerance = 200      -- Chain link creation distance.  Creates a new chain link when the chain extends more than this distance from the hero.
-- 	local linkFollowDistance = 150         -- Chain follow distance.  This determines the size of linear links in the chain.
-- 	local linkDeletionTolerance = 100      -- Chain deletion distance.  This determines how close a chain/hook has to be to the hero to be deleted on retract.

-- 	local fire_dummy = nil
-- 	local stop_flame_hook = false

-- 	local hook_damage_ab = hero:FindAbilityByName("pudge_wars_upgrade_hook_damage")
-- 	local hook_range_ab = hero:FindAbilityByName("pudge_wars_upgrade_hook_range")
-- 	local hook_speed_ab = hero:FindAbilityByName("pudge_wars_upgrade_hook_speed")
-- 	local hook_size_ab = hero:FindAbilityByName("pudge_wars_upgrade_hook_size")

-- 	if hook_damage_ab then
-- 		damage = damage + hook_damage_ab:GetSpecialValueFor("bonus_damage")
-- 	end

-- 	if hook_range_ab then
-- 		distance = distance + hook_range_ab:GetSpecialValueFor("bonus_range")
-- 	end

-- 	if hook_speed_ab then
-- 		speed = speed + hook_speed_ab:GetSpecialValueFor("bonus_speed")
-- 	end

-- 	if hook_size_ab then
-- 		radius = radius + hook_size_ab:GetSpecialValueFor("bonus_radius")
-- 		modelScale = modelScale + hook_size_ab:GetSpecialValueFor("hook_radius")
-- 	end

-- 	print("Pudge throwing hook?", pudge.is_throwing_hook)
-- 	if pudge.is_throwing_hook then
-- 		local abil = hero:FindAbilityByName("pudge_wars_custom_hook")
-- 		abil:EndCooldown()
-- 		return
-- 	else
-- 		pudge.is_throwing_hook = true
-- 		hero:EmitSound("Hero_Pudge.AttackHookExtend")
-- 	end

-- 	-- only load pudge hook first time
-- 	local modelName = pudge.modelName

-- 	if modelName == "" then
-- 		if PudgeArray[hero:GetPlayerOwnerID()].modelName == "" then
-- 			GameMode:AssignHookModel(hero)
-- 		end
-- 	end

-- 	local complete = false

-- 	if hero:HasModifier("modifier_slow_rune") then
-- 		speed = speed - 300
-- 	end

-- 	if hero:HasModifier("modifier_rune_haste") then
-- 		speed = speed + 400
-- 	end

-- 	local pos = keys.target_points[1]
-- 	local dir = pos - hero:GetAbsOrigin()
-- 	dir = dir:Normalized()

-- 	local hook_model = "models/heroes/pudge/righthook.vmdl"

-- 	if hero.hook_model then
-- 		hook_model = hero.hook_model
-- 	end

-- 	print("Create dummy unit")
-- 	local hook_dummy = CreateUnitByName("npc_reflex_hook_test", hero:GetOrigin() + dir * 75, false, hero, hero, hero:GetTeamNumber())
-- 	hooks[1] = hook_dummy
-- 	print(hook_dummy)
-- 	print(IsValidEntity(hook_dummy))
-- 	Timers:CreateTimer(0.1, function()
-- 		print(hook_dummy:GetUnitName())
-- 		print(hook_dummy:IsAlive())
-- 	end)
-- 	hook_dummy:SetModel(hook_model)
-- 	hook_dummy:SetOriginalModel(hook_model)
-- 	hook_dummy:SetModelScale(modelScale)
-- 	hook_dummy:SetAbsOrigin(hero:GetAbsOrigin() + Vector(0, 0, 125))

-- 	if modelName ~= "none" then
-- 		hook_dummy:SetOriginalModel(modelName)
-- 		hook_dummy:SetModel(modelName)
-- 	end

-- 	if pudge.use_flame then
-- 		fire_dummy = CreateUnitByName("npc_firefly_hook_dummy", hero:GetOrigin() + dir * 75, false, hero, hero, hero:GetTeamNumber())
-- 		fire_dummy:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
-- 		fire_dummy:AddAbility("pudge_wars_firefly")
-- 		local abil = fire_dummy:FindAbilityByName("pudge_wars_firefly")
-- 		abil:SetLevel(1)
-- 		fire_dummy:CastAbilityImmediately(abil, 0)

-- 		GameMode:CreateTimer(DoUniqueString("fireflydummy"), {
-- 			endTime = GameRules:GetGameTime(),
-- 			useGameTime = true,
-- 			callback = function(reflex, args)
-- 				if not stop_flame_hook and hook_dummy and IsValidEntity(hook_dummy) then
-- 					fire_dummy:SetAbsOrigin(hook_dummy:GetAbsOrigin() + Vector(0, 0, -200))
-- 					return GameRules:GetGameTime()
-- 				end

-- 				fire_dummy:SetOrigin(Vector(-2368, 2368, 0))
-- 				table.insert(_G.all_flame_hooks, fire_dummy)
-- 				return
-- 			end
-- 		})
-- 	end

-- 	local ability = hook_dummy:FindAbilityByName("reflex_dummy_unit")
-- 	if ability then ability:SetLevel(1) else print("ERROR: Unable to find reflex dummy ability") end
-- 	hookCount = hookCount + 1

-- 	local vHookOffset = Vector(0, 0, 96)
-- 	local target_position = pos + vHookOffset
-- 	local vKillswitch = Vector(((distance / speed) * 2) + 10, 0, 0)

-- 	-- Create special chain link attached to Hook
-- 	local particle = ParticleManager:CreateParticle(hero.hook_pfx, PATTACH_RENDERORIGIN_FOLLOW, hook_dummy)
-- 	local position = hero:GetAbsOrigin()
-- 	local endPosition = hook_dummy:GetAbsOrigin()
-- 	local pu = ParticleUnit.new(particle, position, endPosition, 6, 0, 10) --cpStart, cpEnd, cpDelete)

-- 	hooks[hookCount] = pu
-- 	print("Chain particle number:", hookCount)
-- 	hookCount = hookCount + 1

-- 	local timeout = GameRules:GetGameTime() + distance / speed
-- 	local vars_table = {}

-- 	vars_table[0] = hooked
-- 	vars_table[1] = hero
-- 	vars_table[2] = complete
-- 	vars_table[3] = damage
-- 	vars_table[4] = speed
-- 	vars_table[5] = false --BOUNCE
-- 	vars_table[6] = nil -- rupture_unit
-- 	vars_table[7] = nil -- totem unit
-- 	local current_time = 0

-- 	print("About to start timer")
-- 	Timers:CreateTimer(function()
-- 		print("Start hook timer")
-- 		hooked = vars_table[0]
-- 		hero = vars_table[1]
-- 		complete = vars_table[2]
-- 		damage = vars_table[3]
-- 		speed = vars_table[4]
-- 		print(hook_dummy)
-- 		print(IsValidEntity(hook_dummy))
-- 		local hook_dummy_origin = hook_dummy:GetAbsOrigin()

-- 		print("Complete:", complete)
-- 		if complete then
-- 			if hooked ~= nil and IsValidEntity(hooked) and IsValidEntity(hook_dummy) then
-- 				hooked:SetAbsOrigin(hook_dummy_origin + Vector(0, 0, -125))

-- 				local diff = hero:GetAbsOrigin() - hooked:GetAbsOrigin()

-- 				if diff:Length() < 150 then
-- 					--hooked:RemoveModifierByName("modifier_rooted")
-- 					hooked:RemoveModifierByName("modifier_pudge_meat_hook")

-- 					if hero:HasItemInInventory('item_strygwyr_claw') and hero:FindItemInInventory('item_strygwyr_claw'):GetLevel() == 5 then
-- 						--If the caster has max level strygwyrs, leave rupture for 3 seconds
-- 						local hooked_rupture = hooked

-- 						Timers:CreateTimer(3.0, function()
-- 							if hooked_rupture and IsValidEntity(hooked_rupture) then
-- 								hooked_rupture:RemoveModifierByName("modifier_bloodseeker_rupture")
-- 							end

-- 							if vars_table[6] ~= nil then
-- 								vars_table[6]:Destroy()
-- 							end
-- 						end)
-- 					else
-- 						--Remove rupture unit
-- 						hooked:RemoveModifierByName("modifier_bloodseeker_rupture")
-- 						if vars_table[6] ~= nil then
-- 							vars_table[6]:Destroy()
-- 						end
-- 					end
-- 					if (string.find(hooked:GetClassname(), "creature") and string.find(hooked:GetUnitName(), "rune")) or (string.find(hooked:GetClassname(), "creep") and string.find(hooked:GetUnitName(), "mine") and not hooked:IsAlive()) then
-- 						--Remove the rune as soon as it has return to the caster
-- 						print("Remove rune:", hooked:GetUnitName())
-- 						hooked:RemoveSelf()
-- 					else
-- 						-- Prevent getting stuck
-- 						FindClearSpaceForUnit(hooked, hooked:GetAbsOrigin(), true)
-- 					end

-- 					hooked = nil
-- 					dropped = true
-- 				end
-- 			end

-- 			--Move close chain
-- 			if #hooks > 1 then
-- 				local direction = hero:GetAbsOrigin() - hooks[#hooks]:GetEnd()
-- 				direction.z = 0
-- 				direction = direction:Normalized()
-- 				hooks[#hooks]:SetStart(hero:GetAbsOrigin() + Vector(0, 0, 70))
-- 				hooks[#hooks]:SetEnd(hooks[#hooks]:GetEnd() + direction * speed / 30)
-- 			else
-- 				local direction = hero:GetAbsOrigin() - hooks[#hooks]:GetAbsOrigin()
-- 				direction.z = 0
-- 				direction = direction:Normalized()
-- 				hooks[#hooks]:SetAbsOrigin(hooks[#hooks]:GetAbsOrigin() + direction * speed / 30)
-- 			end

-- 			for i = #hooks - 1, 2, -1 do
-- 				local diff = hooks[i + 1]:GetEnd() - hooks[i]:GetEnd()
-- 				if diff:Length() > linkFollowDistance then
-- 					diff.z = 0
-- 					hooks[i]:SetEnd(hooks[i]:GetEnd() + diff:Normalized() * (diff:Length() - linkFollowDistance))
-- 				end
-- 				if hooks[i]:GetStart() ~= hooks[i + 1]:GetEnd() then
-- 					hooks[i]:SetStart(hooks[i + 1]:GetEnd())
-- 				end
-- 			end

-- 			if #hooks > 1 then
-- 				local diff = hooks[2]:GetAbsOrigin() - hook_dummy_origin
-- 				diff.z = 0
-- 				hook_dummy:SetAbsOrigin(hook_dummy_origin + diff:Normalized() * (diff:Length() - linkFollowDistance))
-- 				hook_dummy:SetForwardVector(-1 * diff:Normalized())
-- 			end

-- 			local diff = nil
-- 			local hasFire = false

-- 			if #hooks > 1 then
-- 				diff = hooks[#hooks]:GetEnd() - hero:GetAbsOrigin()
-- 			else
-- 				diff = hooks[#hooks]:GetAbsOrigin() - hero:GetAbsOrigin()
-- 				hasFire = hooks[#hooks]:HasAbility("pudge_wars_firefly")
-- 			end

-- 			diff.z = 0

-- 			if diff:Length() < linkDeletionTolerance then
-- 				if hasFire then
-- 					stop_flame_hook = true
-- 				else
-- 					hooks[#hooks]:Destroy()
-- 					hooks[#hooks] = nil
-- 					if #hooks > 1 then
-- 						hooks[#hooks]:SetStart(hero:GetAbsOrigin() + Vector(0, 0, 70))
-- 					end
-- 				end
-- 			end

-- 			if #hooks == 0 then
-- 				if hooked ~= nil and IsValidEntity(hooked) then
-- 					--hooked:RemoveModifierByName("modifier_rooted")
-- 					hooked:RemoveModifierByName("modifier_pudge_meat_hook")
-- 				end
-- 				pudge.is_throwing_hook = false
-- 				return
-- 			end

-- 			--print(tostring(hooks[#hooks]:GetAbsOrigin()) .. " -- " .. tostring(dir) .. " -- " .. speed .. " -- " .. tostring(#hooks))
-- 			if hooked == nil and not dropped then
-- 				--BACKWARDS
-- 				local entities = Entities:FindAllInSphere(hook_dummy_origin + Vector(0, 0, -100), radius / 2)
-- 				findEntity(entities, vars_table, false, bounces, hero)
-- 				local entities = nil
-- 				if hero:GetAbsOrigin().x > 200 or hero:GetAbsOrigin().x < -200 then
-- 					entities = Entities:FindAllInSphere(hook_dummy_origin + Vector(0, 0, -200), radius / 2)
-- 				else
-- 					entities = Entities:FindAllInSphere(hook_dummy_origin + Vector(0, 0, 0), radius / 2)
-- 				end
-- 				findEntity(entities, vars_table, false, bounces, hero)
-- 				hooked = vars_table[0]
-- 				hero = vars_table[1]
-- 				complete = vars_table[2]
-- 				damage = vars_table[3]
-- 				speed = vars_table[4]
-- 			end
-- 		else
-- 			-- Move hook
-- 			dir.z = 0
-- 			print(hooks)
-- 			print(hook_dummy)
-- 			print(hook_dummy_origin, dir, speed)
-- 			hook_dummy:SetAbsOrigin(hook_dummy_origin + dir * speed / 30)
-- 			dir.z = 0
-- 			hook_dummy:SetForwardVector(dir)

-- 			local diff = hook_dummy_origin - hooks[2]:GetAbsOrigin()
-- 			diff.z = 0
-- 			if diff:Length() > linkFollowDistance then
-- 				hooks[2]:SetStart(hooks[2]:GetAbsOrigin() + diff:Normalized() * (diff:Length() - linkFollowDistance))
-- 			end
-- 			if hooks[2]:GetEnd() ~= hook_dummy_origin then
-- 				hooks[2]:SetEnd(hook_dummy_origin)
-- 			end

-- 			-- Move chains
-- 			for i = 3, #hooks do
-- 				local diff = hooks[i - 1]:GetAbsOrigin() - hooks[i]:GetAbsOrigin()
-- 				diff.z = 0
-- 				if diff:Length() > linkFollowDistance then
-- 					hooks[i]:SetStart(hooks[i]:GetAbsOrigin() + diff:Normalized() * (diff:Length() - linkFollowDistance))
-- 				end
-- 				if hooks[i]:GetEnd() ~= hooks[i - 1]:GetAbsOrigin() then
-- 					hooks[i]:SetEnd(hooks[i - 1]:GetAbsOrigin())
-- 				end
-- 			end

-- 			-- Create New Chain link
-- 			local diff = hooks[#hooks]:GetAbsOrigin() - hero:GetAbsOrigin()
-- 			if diff:Length() > linkCreationTolerance then
-- 				diff.z = 0
-- 				local direction = diff:Normalized()
-- 				local particle = ParticleManager:CreateParticle("particles/pw/ref_pudge_meathook_chain.vpcf", PATTACH_ABSORIGIN, hook_dummy) --
-- 				local position = hero:GetAbsOrigin() + Vector(0, 0, 70)
-- 				local endPosition = hero:GetAbsOrigin() + direction * 75 + Vector(0, 0, 140)
-- 				local pu = ParticleUnit.new(particle, position, endPosition) --cpStart, cpEnd, cpDelete)

-- 				hooks[hookCount] = pu

-- 				hookCount = hookCount + 1
-- 			elseif #hooks > 1 then
-- 				hooks[#hooks]:SetStart(hero:GetAbsOrigin() + Vector(0, 0, 120))
-- 			end

-- 			--Collision detection
-- 			if hooked == nil and vars_table[5] == false then
-- 				--FORWARD
-- 				local entities = Entities:FindAllInSphere(hook_dummy_origin + Vector(0, 0, -100), radius / 2)
-- 				findEntity(entities, vars_table, true, bounces, hero)
-- 				local entities = nil
-- 				if hero:GetAbsOrigin().x > 200 or hero:GetAbsOrigin().x < -200 then
-- 					entities = Entities:FindAllInSphere(hook_dummy_origin + Vector(0, 0, -200), radius / 2)
-- 				else
-- 					entities = Entities:FindAllInSphere(hook_dummy_origin + Vector(0, 0, 100), radius / 2)
-- 				end
-- 				findEntity(entities, vars_table, true, bounces, hero)
-- 				hooked = vars_table[0]
-- 				hero = vars_table[1]
-- 				complete = vars_table[2]
-- 				damage = vars_table[3]
-- 				speed = vars_table[4]
-- 			end

-- 			-- Bounce wall checks
-- 			local hookPos = hook_dummy_origin
-- 			local angx = (math.acos(dir.x) / math.pi * 180)
-- 			local angy = (math.acos(dir.y) / math.pi * 180)
-- 			if hookPos.x > rightBound and dir.x > 0 then
-- 				local rotAngle = 180 - angx * 2
-- 				if angy > 90 then
-- 					rotAngle = 360 - rotAngle
-- 				end
-- 				bounces = bounces + 1
-- 				dir = RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir)
-- 			elseif hookPos.x < leftBound and dir.x < 0 then
-- 				local rotAngle = angx * 2 - 180
-- 				if angy < 90 then
-- 					rotAngle = 360 - rotAngle
-- 				end
-- 				bounces = bounces + 1
-- 				dir = RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir)
-- 			elseif hookPos.y > topBound and dir.y > 0 then
-- 				local rotAngle = 180 - angy * 2
-- 				if angx < 90 then
-- 					rotAngle = 360 - rotAngle
-- 				end
-- 				bounces = bounces + 1
-- 				dir = RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir)
-- 			elseif hookPos.y < bottomBound and dir.y < 0 then
-- 				local rotAngle = angy * 2 - 180
-- 				if angx > 90 then
-- 					rotAngle = 360 - rotAngle
-- 				end
-- 				bounces = bounces + 1
-- 				dir = RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir)
-- 			end

-- 			-- Bounce center
-- 			hookPos.z = 0
-- 			diff = ancientPosition - hookPos
-- 			rebounceTolerance = rebounceTolerance - 1
-- 			if ((diff:Length() < centerRadius) and (rebounceTolerance) < 1) then
-- 				rebounceTolerance = rebounceToleranceMax
-- 				diff = diff:Normalized()
-- 				local diffx = (math.acos(diff.x) / math.pi * 180)
-- 				local diffy = (math.acos(diff.y) / math.pi * 180)
-- 				local angx = (math.acos(dir.x) / math.pi * 180)
-- 				local angy = (math.acos(dir.y) / math.pi * 180)
-- 				local dx = diffx - angx
-- 				local dy = diffy - angy

-- 				local rotAngle = 180 - math.abs(dx) - math.abs(dy)

-- 				if (dx < 0 and dy < 0 and dir.x > 0 and dir.y < 0) or
-- 					(dx > 0 and dy < 0 and dir.x > 0 and dir.y > 0) or
-- 					(dx > 0 and dy > 0 and dir.x < 0 and dir.y > 0) or
-- 					(dx < 0 and dy > 0 and dir.x < 0 and dir.y < 0) then
-- 					rotAngle = 360 - rotAngle
-- 				end
-- 				bounces = bounces + 1
-- 				dir = RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir)
-- 			end

-- 			--Bounce on shiled barrier target
-- 			if ((vars_table[5] == true) and ((rebounceTolerance) < 1)) and (vars_table[7] == nil) and (GameMode.shield_carrier) then
-- 				diff = GameMode.shield_carrier:GetAbsOrigin() - hookPos
-- 				has_bounced_on_shield = true
-- 				rebounceTolerance = rebounceToleranceMax
-- 				diff = diff:Normalized()
-- 				local diffx = (math.acos(diff.x) / math.pi * 180)
-- 				local diffy = (math.acos(diff.y) / math.pi * 180)
-- 				local angx = (math.acos(dir.x) / math.pi * 180)
-- 				local angy = (math.acos(dir.y) / math.pi * 180)
-- 				local dx = diffx - angx
-- 				local dy = diffy - angy

-- 				local rotAngle = 180 - math.abs(dx) - math.abs(dy)

-- 				if (dx < 0 and dy < 0 and dir.x > 0 and dir.y < 0) or
-- 					(dx > 0 and dy < 0 and dir.x > 0 and dir.y > 0) or
-- 					(dx > 0 and dy > 0 and dir.x < 0 and dir.y > 0) or
-- 					(dx < 0 and dy > 0 and dir.x < 0 and dir.y < 0) then
-- 					rotAngle = 360 - rotAngle
-- 				end
-- 				bounces = bounces + 1
-- 				dir = RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir)
-- 				hook_dummy:EmitSound("Hero_Sven.Attack.Impact")
-- 				vars_table[5] = false
-- 			elseif ((vars_table[5] == true) and ((rebounceTolerance) < 1) and (vars_table[7]) and (IsValidEntity(vars_table[7]))) then
-- 				--Bounce on ES totems
-- 				diff = vars_table[7]:GetAbsOrigin() - hookPos
-- 				rebounceTolerance = rebounceToleranceMax
-- 				diff = diff:Normalized()

-- 				local diffx = (math.acos(diff.x) / math.pi * 180)
-- 				local diffy = (math.acos(diff.y) / math.pi * 180)
-- 				local angx = (math.acos(dir.x) / math.pi * 180)
-- 				local angy = (math.acos(dir.y) / math.pi * 180)
-- 				local dx = diffx - angx
-- 				local dy = diffy - angy

-- 				local rotAngle = 180 - math.abs(dx) - math.abs(dy)

-- 				if (dx < 0 and dy < 0 and dir.x > 0 and dir.y < 0) or
-- 					(dx > 0 and dy < 0 and dir.x > 0 and dir.y > 0) or
-- 					(dx > 0 and dy > 0 and dir.x < 0 and dir.y > 0) or
-- 					(dx < 0 and dy > 0 and dir.x < 0 and dir.y < 0) then
-- 					rotAngle = 360 - rotAngle
-- 				end

-- 				bounces = bounces + 1
-- 				dir = RotatePosition(Vector(0, 0, 0), QAngle(0, rotAngle, 0), dir)

-- 				hook_dummy:EmitSound("Hero_WitchDoctor.Attack")
-- 				vars_table[5] = false
-- 				vars_table[7] = nil
-- 			end

-- 			if current_time > timeout then
-- 				complete = true
-- 				vars_table[0] = hooked
-- 				vars_table[1] = hero
-- 				vars_table[2] = complete
-- 				vars_table[3] = damage
-- 				vars_table[4] = speed

-- 				if hooked == nil then
-- 					hero.successful_hooks = 0
-- 				end

-- 				return FrameTime()
-- 			end
-- 		end

-- 		vars_table[0] = hooked
-- 		vars_table[1] = hero
-- 		vars_table[2] = complete
-- 		vars_table[3] = damage
-- 		vars_table[4] = speed
-- 		current_time = current_time + FrameTime()
-- 		return FrameTime()
-- 	end)

-- 	pudge.is_throwing_hook = false -- if timer breaks, reset is_throwing_hook so they can keep throwing hooks

-- 	for key, val in pairs(hooks) do
-- 		hooks[key]:Destroy()
-- 		hooks[key] = nil
-- 	end
-- end

-- -- Particle Unit system
-- if ParticleUnit == nil then
-- 	ParticleUnit = {}
-- 	ParticleUnit.__index = ParticleUnit
-- end

-- function ParticleUnit.new(particle, position, endPosition, cpStart, cpEnd, cpDelete)
-- 	--print ( '[ParticleUnit] ParticleUnit:new' )
-- 	local o = {}
-- 	setmetatable(o, ParticleUnit)

-- 	o.particle = particle
-- 	o.position = position
-- 	o.endPosition = endPosition
-- 	o.cpStart = cpStart or 0
-- 	o.cpEnd = cpEnd or 6
-- 	o.cpDelete = cpDelete or 10

-- 	ParticleManager:SetParticleControl(o.particle, o.cpStart, position)
-- 	ParticleManager:SetParticleControl(o.particle, o.cpEnd, endPosition)
-- 	ParticleManager:SetParticleControl(o.particle, o.cpDelete, Vector(300, 0, 0))

-- 	return o
-- end

-- New hook system

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

function modifier_pudge_wars_meat_hook_handler:CreateHook()
	local hook_dummy = CreateUnitByName("npc_reflex_hook_test", self.ability.caster:GetOrigin() + self.ability.dir * 75, false, self.ability.caster, self.ability.caster, self.ability.caster:GetTeam())
	hook_dummy:SetModel(self.ability.hook_model)
	hook_dummy:SetOriginalModel(self.ability.hook_model)
	hook_dummy:SetModelScale(self.ability.modelScale)
	hook_dummy:SetForwardVector(self.ability.dir)

	-- Create special chain link attached to Hook
	print("Hook chain particle:", self.ability.caster.hook_pfx)
	local particle = ParticleManager:CreateParticle("particles/pw/ref_pudge_meathook_chain.vpcf", PATTACH_ABSORIGIN, hook_dummy)
	local position = self.ability.caster:GetAbsOrigin() + Vector(0, 0, 96)
	local endPosition = hook_dummy:GetAbsOrigin() + Vector(0, 0, 96)
	ParticleManager:SetParticleControl(particle, 0, endPosition)
	ParticleManager:SetParticleControl(particle, 6, position)
	ParticleManager:SetParticleControl(particle, 10, Vector(300, 0, 0))
	-- local pu = self.NewPFX(particle, position, endPosition, 6, 0, 10) --cpStart, cpEnd, cpDelete)

	hook_dummy.particle = particle
	table.insert(self.ability.hook_dummies, hook_dummy)
end

function modifier_pudge_wars_meat_hook_handler:CreateChainLink(vDirection)
	print("Create chain link:", #self.ability.hook_dummies)
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
	table.insert(self.ability.hook_dummies, chain_dummy)
end

function modifier_pudge_wars_meat_hook_handler:OnIntervalThink()
	self.current_time = self.current_time + FrameTime()

	if self.current_time <= self.ability.timeout then
		self:HookForward()
	else
		self:Destroy()
		-- self:HookBackward()
	end
end

function modifier_pudge_wars_meat_hook_handler:HookForward()
	-- Move hook
	self.ability.dir.z = 0
	local hook_dummy = self.ability.hook_dummies[1]
	local forward_dummy = self.ability.hook_dummies[2]
	local last_dummy = self.ability.hook_dummies[#self.ability.hook_dummies]

	hook_dummy:SetAbsOrigin(hook_dummy:GetAbsOrigin() + self.ability.dir * self.ability.speed / 30)
	-- hook_dummy:SetForwardVector(self.ability.dir)

	local diff = hook_dummy:GetAbsOrigin() - forward_dummy:GetAbsOrigin()
	diff.z = 0

	if diff:Length2D() > self.ability.linkFollowDistance then
		forward_dummy:SetAbsOrigin(forward_dummy:GetAbsOrigin() + diff:Normalized() * (diff:Length2D() - self.ability.linkFollowDistance))
	end

	-- if forward_dummy:GetEnd() ~= hook_dummy:GetAbsOrigin() then
	-- 	forward_dummy:SetEnd(hook_dummy:GetAbsOrigin())
	-- end

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
	local entities = Entities:FindAllInSphere(GetGroundPosition(hook_dummy:GetAbsOrigin(), hook_dummy), self.ability.radius / 2)
	local target = self:FindValidTarget(entities)

	if target then
		self:HookHit(target)
	end

	-- Check for bounce
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
