print("[PUDGE] PudgeClass loading")
if PudgeClass == nil then
		PudgeClass = {}
		PudgeClass.__index = PudgeClass
end

function PudgeClass.create(playerId)
	local pudge = {}
	setmetatable(pudge,PudgeClass)
	pudge.playerId = playerId
	pudge.isHooked = false
	pudge.hasspawned = false
	pudge.abilityused = {}
	pudge.timesinceabilityused = {}
	pudge.timestouseability = {}
	pudge.pudgeunit = nil
	pudge.death_time = 0
	pudge.modelName = ""
	pudge.use_flame = false
	pudge.has_voted = false
	pudge.is_throwing_hook = false
	pudge.pos_before_dc = nil
	pudge.has_max_level_timer = false
	pudge.damagetomes = 0

	--ENUMS
	pudge.grappleint = 0
	pudge.tinysarmint = 1
	return pudge
end

function PudgeWarsMode:InitPudge( spawnedUnit )
	print('Pudge Spawned for the first time, id=' .. spawnedUnit:GetPlayerOwnerID())
	PudgeArray[ spawnedUnit:GetPlayerOwnerID() ] = PudgeClass.create( spawnedUnit:GetPlayerOwnerID() )
	--Add the unit for easy acces in other functions
	PudgeArray[spawnedUnit:GetPlayerOwnerID()].pudgeunit = spawnedUnit

	--Set starting gold to 0
	spawnedUnit:SetGold(0, false)

	PudgeArray[spawnedUnit:GetPlayerOwnerID()].hasspawned = true
	spawnedUnit:FindAbilityByName("pudge_wars_custom_hook"):SetLevel(1)
	spawnedUnit:FindAbilityByName("pudge_wars_abilities_up"):SetLevel(1)
	spawnedUnit:FindAbilityByName("pudge_wars_abilities_down"):SetLevel(1)
	spawnedUnit:FindAbilityByName("pudge_wars_empty1"):SetLevel(1)
	spawnedUnit:FindAbilityByName("pudge_wars_empty2"):SetLevel(1)
	spawnedUnit:FindAbilityByName("pudge_wars_empty3"):SetLevel(1)
--	spawnedUnit:FindAbilityByName("pudge_wars_upgrade_hook_damage"):SetLevel(1)
--	spawnedUnit:FindAbilityByName("pudge_wars_upgrade_hook_speed"):SetLevel(1)
--	spawnedUnit:FindAbilityByName("pudge_wars_upgrade_hook_range"):SetLevel(1)
--	spawnedUnit:FindAbilityByName("pudge_wars_upgrade_hook_size"):SetLevel(1)

	spawnedUnit.ab2 = "pudge_wars_empty1"
	spawnedUnit.ab3 = "pudge_wars_empty2"
	spawnedUnit.ab4 = "pudge_wars_empty3"

	spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_command_restricted", {duration=PRE_GAME_TIME})
end
