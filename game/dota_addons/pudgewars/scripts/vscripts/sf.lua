print("[SCALEFORM] Scaleform loading") 

function PudgeWarsMode:InitScaleForm()
    --Actionscript events
    
    --Player voted for number of kills needed to win the game
    Convars:RegisterCommand( "winVote", function(name, p)
        --get the player that sent the command
	print("start winVote")
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then 
	    --if the player is valid, execute PlayerBuyAbilityPoint
	    print("cmdPlayer ok, votes: " .. p)
	    print("cmdPlayerId: " .. cmdPlayer:GetPlayerID())
	    FireGameEvent('pwgm_player_voted', { player_ID = cmdPlayer:GetPlayerID(), vote_type = "winVote", vote_value = tonumber(p) })
	    print("fired game event pwgm_player_vote")
	    return true 
	end
	return false
    end, "Event: winVote", 0 )

    Convars:RegisterCommand( "cfWinVote", function(name, p)
	print("start confirm winvote")
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then 
	    --if the player is valid, execute PlayerBuyAbilityPoint
	    plyId = cmdPlayer:GetPlayerID()
	    print("cmdPlayer ok,confirm vote: " .. p)
	    print("cmdPlayerId: " .. plyId)
	    vote = tonumber(p)
	    if vote == 100 then
		self.vote_100_votes = self.vote_100_votes + 1
	    elseif vote == 75 then
		self.vote_75_votes = self.vote_75_votes + 1
	    elseif vote == 50 then
		self.vote_50_votes = self.vote_50_votes + 1
	    end    

	    --PudgeArray[ plyId ].has_voted = true
	    FireGameEvent('pwgm_cf_player_voted', { player_ID = cmdPlayer:GetPlayerID(), vote_type = "winVote", vote_value = tonumber(p) })

	    FireGameEvent('pwgm_update_vote_score', { votes_on_50 = self.vote_50_votes, votes_on_75 = self.vote_75_votes, votes_on_100 = self.vote_100_votes, })


	    print("fired game event pwgm_cf_player_voted, and pwgm_update_vote_score")
	    return true 
	end
	return false
	
    end, "Event: cfWinVote", 0 )
end
