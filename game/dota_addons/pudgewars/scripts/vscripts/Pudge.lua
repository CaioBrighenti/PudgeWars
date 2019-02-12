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
	Battlepass:AddItemEffects(pudge)

	local battlepass_level = Battlepass:GetRewardUnlocked(pudge:GetPlayerID())
	local level_color = GetTitleColorIXP(GetTitleIXP(battlepass_level), false)

	if IsDonator(pudge:GetPlayerID()) == 1 or IsDeveloper(pudge:GetPlayerID()) then
		pudge:SetCustomHealthLabel(GetTitleIXP(battlepass_level).." (Mod Developer)", level_color[1], level_color[2], level_color[3])
	elseif IsDonator(pudge:GetPlayerID()) == 4 then
		pudge:SetCustomHealthLabel(GetTitleIXP(battlepass_level).." (Ember Donator)", 200, 40, 40)
	elseif IsDonator(pudge:GetPlayerID()) == 5 then
		pudge:SetCustomHealthLabel(GetTitleIXP(battlepass_level).." (Golden Donator)", 255, 200, 0)
	elseif IsDonator(pudge:GetPlayerID()) == 6 then
		pudge:SetCustomHealthLabel(GetTitleIXP(battlepass_level).." (Donator)", 40, 200, 40)
	elseif IsDonator(pudge:GetPlayerID()) == 7 then
		pudge:SetCustomHealthLabel(GetTitleIXP(battlepass_level).." (Salamander Donator)", 20, 86, 239)
	else
		pudge:SetCustomHealthLabel(GetTitleIXP(battlepass_level), level_color[1], level_color[2], level_color[3])
	end

	pudge:AddNewModifier(pudge, nil, "modifier_command_restricted", {duration=PRE_GAME_TIME})
end
