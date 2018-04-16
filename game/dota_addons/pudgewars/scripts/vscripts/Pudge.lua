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

	spawnedUnit.ab2 = "pudge_wars_empty1"
	spawnedUnit.ab3 = "pudge_wars_empty2"
	spawnedUnit.ab4 = "pudge_wars_empty3"

	spawnedUnit.successful_hooks = 0
	Battlepass:AddItemEffects(spawnedUnit)

	local battlepass_level = Battlepass:GetRewardUnlocked(spawnedUnit:GetPlayerID())
	local level_color = GetTitleColorIXP(GetTitleIXP(battlepass_level), false)

	if IsDeveloper(spawnedUnit:GetPlayerID()) then
		spawnedUnit:SetCustomHealthLabel(GetTitleIXP(battlepass_level).." (Mod Developer)", level_color[1], level_color[2], level_color[3])
	elseif IsDonator(spawnedUnit:GetPlayerID()) then
		spawnedUnit:SetCustomHealthLabel(GetTitleIXP(battlepass_level).." (Donator)", level_color[1], level_color[2], level_color[3])
	else
		spawnedUnit:SetCustomHealthLabel(GetTitleIXP(battlepass_level), level_color[1], level_color[2], level_color[3])
	end

	spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_command_restricted", {duration=PRE_GAME_TIME})
end
