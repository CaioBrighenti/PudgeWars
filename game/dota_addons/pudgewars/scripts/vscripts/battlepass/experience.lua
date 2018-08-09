-- Experience System
XP_level_table = {0,100,300,600,1000,1500,2100,2800,3400,4300,5300}
--------------    0  1   2   3    4    5    6    7    8    9   10

for i = 11 + 1, 100 do -- +1 because index is 0
	XP_level_table[i] = XP_level_table[i-1] + 1000
end

function GetXPLevelByXp(xp)
	if xp <= 0 then return 1 end

	for k, v in pairs(XP_level_table) do
		if v > xp then
			return k - 1
		end
	end

	return #XP_level_table
end

function GetXpProgressToNextLevel(xp)

	if xp == 0 then
		local xp = {
			xp = 0,
			max_xp = XP_level_table[1 + 1], -- +1 because index is 0
		}

		return xp
	end

	local level = GetXPLevelByXp(xp)

	if xp >= XP_level_table[#XP_level_table] then
		local xp = {
			xp = XP_level_table[level] - XP_level_table[level - 1],
			max_xp = XP_level_table[level] - XP_level_table[level - 1],
		}

		return xp
	end

	local next = level + 1
	local thisXp = XP_level_table[level]
	local nextXp = XP_level_table[next]
	print(thisXp, nextXp)
	if nextXp == nil then
		nextXp = 0
	end

	local xpRequiredForThisLevel = nextXp - thisXp
	local xpProgressInThisLevel = xp - thisXp

	local xp = {
		xp = xpProgressInThisLevel,
		max_xp = xpRequiredForThisLevel,
	}

	return xp
end

function GetTitleIXP(level)
	if level <= 9 then
		return "Rookie"
	elseif level <= 19 then
		return "Amateur"
	elseif level <= 29 then
		return "Captain"
	elseif level <= 39 then
		return "Warrior"
	elseif level <= 49 then
		return "Commander"
	elseif level <= 59 then
		return "General"
	elseif level <= 69 then
		return "Master"
	elseif level <= 79 then
		return "Epic"
	elseif level <= 89 then
		return "Legendary"
	elseif level <= 99 then
		return "Ancient"
	elseif level == 100 then
		return "Icefrog"
	else
		return "Icefrog "..level - 100
	end
end

function GetTitleColorIXP(title, js)
	if js == true then
		if title == "Rookie" then
			return "#FFFFFF"
		elseif title == "Amateur" then
			return "#66CC00"
		elseif title == "Captain" then
			return "#4C8BCA"
		elseif title == "Warrior" then
			return "#004C99"
		elseif title == "Commander" then
			return "#985FD1"
		elseif title == "General" then
			return "#460587"
		elseif title == "Master" then
			return "#FA5353"
		elseif title == "Epic" then
			return "#8E0C0C"
		elseif title == "Legendary" then
			return "#EFBC14"
		elseif title == "Ancient" then
			return "#BF950D"
		elseif title == "Icefrog" then
			return "#1456EF"
		end
	else
		if title == "Rookie" then
			return {255, 255, 255}
		elseif title == "Amateur" then
			return {102, 204, 0}
		elseif title == "Captain" then
			return {76, 139, 202}
		elseif title == "Warrior" then
			return {0, 76, 153}
		elseif title == "Commander" then
			return {152, 95, 209}
		elseif title == "General" then
			return {70, 5, 135}
		elseif title == "Master" then
			return {250, 83, 83}
		elseif title == "Epic" then
			return {142, 12, 12}
		elseif title == "Legendary" then
			return {239, 188, 20}
		elseif title == "Ancient" then
			return {191, 149, 13}
		elseif title == "Icefrog" then
			return {20, 86, 239}
		end
	end
end

function GetPlayerInfoXP()
--	if not api then return end
--	if not api.imba.ready then return end

	for ID = 0, PlayerResource:GetPlayerCount() -1 do
--		local global_xp = api.imba.get_player_info(PlayerResource:GetSteamID(ID)).xp
		local level = 0
		local global_xp = 0

		if IsDonator(ID) == 1 or IsDeveloper(ID) then
			global_xp = global_xp + 182700
		elseif IsDonator(ID) == 4 then
			global_xp = global_xp + 10000
		elseif IsDonator(ID) == 5 then
			global_xp = global_xp + 3000
		elseif IsDonator(ID) == 6 then
			global_xp = global_xp + 1000
		elseif IsDonator(ID) == 7 then
			global_xp = global_xp + 75000
		end

		for i = 1, #XP_level_table do
			if global_xp >= XP_level_table[i] then
				if global_xp >= XP_level_table[#XP_level_table] then -- if max level
					level = #XP_level_table
				else
					level = level + 1
				end
			end
		end

--		print(GetXpProgressToNextLevel(global_xp).xp.."/"..GetXpProgressToNextLevel(global_xp).max_xp, level)

		CustomNetTables:SetTableValue("player_table", tostring(ID),
		{
			XP = GetXpProgressToNextLevel(global_xp).xp,
			MaxXP = GetXpProgressToNextLevel(global_xp).max_xp,
			Lvl = level, -- add +1 only on the HUD else you are level 0 at the first level
			title = GetTitleIXP(level),
			title_color = GetTitleColorIXP(GetTitleIXP(level), true),
--			IMR_5v5 = api.imba.get_player_info(PlayerResource:GetSteamID(ID)).imr5v5,
--			IMR_5v5_calibrating = api.imba.get_player_info(PlayerResource:GetSteamID(ID)).imr5v5_calibrating,
			XP_change = 0,
--			IMR_5v5_change = 0,
		})
	end

	Battlepass:Init()
	GetTopPlayersXP()
	GetTopPlayersMMR()
end

function GetTopPlayersXP()
	if not api then return end
	if not api.imba.ready then return end

	local level = {}
	local current_xp_in_level = {}
	local max_xp = {}

	local rankings = api.imba.get_rankings_xp()

	for i = 1, #rankings do
		local top_user = rankings[i]
		local global_xp = top_user.xp

		level[top_user.rank] = 0

		for i = 1, #XP_level_table do
			if global_xp > XP_level_table[i] then
				if global_xp > XP_level_table[#XP_level_table] then -- if max level
					level[top_user.rank] = #XP_level_table
					current_xp_in_level[top_user.rank] = XP_level_table[level[top_user.rank]] - XP_level_table[level[top_user.rank]]
					max_xp[top_user.rank] = XP_level_table[level[top_user.rank]] - XP_level_table[level[top_user.rank]]
				else
					level[top_user.rank] = i +1
					current_xp_in_level[top_user.rank] = 0
					current_xp_in_level[top_user.rank] = global_xp - XP_level_table[i]
					max_xp[top_user.rank] = XP_level_table[level[top_user.rank]+1] - XP_level_table[level[top_user.rank]]
				end
			end
		end

		CustomNetTables:SetTableValue("top_xp", tostring(top_user.rank),
		{
			SteamID64 = top_user.steamid,
			XP = current_xp_in_level[top_user.rank],
			MaxXP = max_xp[top_user.rank],
			Lvl = level[top_user.rank],
			title = GetTitleIXP(level[top_user.rank]),
			title_color = GetTitleColorIXP(GetTitleIXP(level[top_user.rank]), true),
			IMR_5v5 = top_user.imr5v5,
		})
	end
end

function GetTopPlayersMMR()
	if not api then return end
	if not api.imba.ready then return end

	local level = {}
	local current_xp_in_level = {}
	local max_xp = {}

	for _, top_user in pairs(api.imba.get_rankings_imr5v5()) do
		local global_xp = top_user.xp
		level[top_user.rank] = 0

		for i = 1, #XP_level_table do
			if global_xp > XP_level_table[i] then
				if global_xp > XP_level_table[#XP_level_table] then -- if max level
					level[top_user.rank] = #XP_level_table
					current_xp_in_level[top_user.rank] = XP_level_table[level[top_user.rank]] - XP_level_table[level[top_user.rank]]
					max_xp[top_user.rank] = XP_level_table[level[top_user.rank]] - XP_level_table[level[top_user.rank]]
				else
					level[top_user.rank] = i +1 -- transform level 0 into level 1
					current_xp_in_level[top_user.rank] = 0
					current_xp_in_level[top_user.rank] = global_xp - XP_level_table[i]
					max_xp[top_user.rank] = XP_level_table[level[top_user.rank]+1] - XP_level_table[level[top_user.rank]]
				end
			end
		end

		CustomNetTables:SetTableValue("top_imr5v5", tostring(top_user.rank),
		{
			SteamID64 = top_user.steamid,
			XP = current_xp_in_level[top_user.rank],
			MaxXP = max_xp[top_user.rank],
			Lvl = level[top_user.rank],
			title = GetTitleIXP(level[top_user.rank]),
			title_color = GetTitleColorIXP(GetTitleIXP(level[top_user.rank]), true),
			IMR_5v5 = top_user.imr5v5,
		})
	end
end
