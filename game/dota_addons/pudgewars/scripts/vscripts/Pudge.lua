print("[PUDGE] PudgeClass loading")
if PudgeClass == nil then
		PudgeClass = {}
		PudgeClass.__index = PudgeClass
end

function PudgeClass.create(playerId)
	local pudge = {}
	setmetatable(pudge,PudgeClass)
	pudge.playerId = playerId
	pudge.hookDamageLevel = 0
	pudge.hookSpeedLevel = 0
	pudge.hookSizeLevel = 0
	pudge.hookDistanceLevel = 0
	pudge.upgradePoints = 1
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
	PudgeWarsMode:SetAbilToLevelOne( spawnedUnit , "pudge_wars_custom_hook")
	PudgeWarsMode:SetAbilToLevelOne( spawnedUnit , "pudge_wars_abilities_up")
	PudgeWarsMode:SetAbilToLevelOne( spawnedUnit , "pudge_wars_empty1")
	PudgeWarsMode:SetAbilToLevelOne( spawnedUnit , "pudge_wars_empty2")
	PudgeWarsMode:SetAbilToLevelOne( spawnedUnit , "pudge_wars_empty3")
	PudgeWarsMode:UpdateUpgradePoints(spawnedUnit)

	if spawnedUnit:GetPlayerID() ~= -1 then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_stunned", {duration=PRE_GAME_TIME})
	end

	Timers:CreateTimer(0.1, function()
		spawnedUnit:SetAbilityPoints(0)
	end)
end
