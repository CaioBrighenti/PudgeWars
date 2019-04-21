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
	pudge.is_throwing_hook = false
	pudge.pos_before_dc = nil
	pudge.has_max_level_timer = false
	pudge.damagetomes = 0

	--ENUMS
	pudge.grappleint = 0
	pudge.tinysarmint = 1
	return pudge
end

function PudgeWarsMode:InitPudge(pudge)
	print('Pudge Spawned for the first time, id=' .. pudge:GetPlayerOwnerID())
	PudgeArray[ pudge:GetPlayerOwnerID() ] = PudgeClass.create( pudge:GetPlayerOwnerID() )
	--Add the unit for easy acces in other functions
	PudgeArray[pudge:GetPlayerOwnerID()].pudgeunit = pudge

	--Set starting gold to 0
	pudge:SetGold(0, false)

	PudgeArray[pudge:GetPlayerOwnerID()].hasspawned = true

	for i = 0, 5 do
		pudge:GetAbilityByIndex(i):SetLevel(1)
	end
	pudge:FindAbilityByName("pudge_wars_abilities_down"):SetLevel(1)

	pudge.ab2 = "pudge_wars_empty1"
	pudge.ab3 = "pudge_wars_empty2"
	pudge.ab4 = "pudge_wars_empty3"

	pudge.successful_hooks = 0

	pudge:AddNewModifier(pudge, nil, "modifier_command_restricted", {duration=PRE_GAME_TIME})
end
