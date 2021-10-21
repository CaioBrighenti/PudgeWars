print("[PUDGE] PudgeClass loading")

function GameMode.create(playerId)
	local pudge = {}
	setmetatable(pudge,GameMode)
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

	print(pudge)
	return pudge
end

function GameMode:InitPudge(pudge)
	print(pudge:GetUnitName())
	print('Pudge Spawned for the first time, id=' .. pudge:GetPlayerOwnerID())
	PudgeArray[ pudge:GetPlayerOwnerID() ] = self.create( pudge:GetPlayerOwnerID() )
	--Add the unit for easy acces in other functions
	PudgeArray[pudge:GetPlayerOwnerID()].pudgeunit = pudge

	--Set starting gold to 0
	pudge:SetGold(0, false)

	PudgeArray[pudge:GetPlayerOwnerID()].hasspawned = true

	for i = 0, 5 do
		local ability = pudge:GetAbilityByIndex(i)

		if ability then
			ability:SetLevel(1)
		end
	end

	pudge:FindAbilityByName("pudge_wars_abilities_down"):SetLevel(1)

	pudge.ab2 = "pudge_wars_empty1"
	pudge.ab3 = "pudge_wars_empty2"
	pudge.ab4 = "pudge_wars_empty3"

	pudge.successful_hooks = 0

	pudge:AddNewModifier(pudge, nil, "modifier_command_restricted", {duration=PRE_GAME_TIME})
	pudge:AddNewModifier(pudge, nil, "modifier_ability_points", {}):SetStackCount(pudge:GetAbilityPoints())
end
