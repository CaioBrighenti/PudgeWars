"use strict";
function OnVotePanelClose()
{
	$.Msg("OnVotePanelClose")
	var contextPanel = $.GetContextPanel()
	contextPanel.visible = false
}

function OnVote50()
{
	$( "#PudgeWarsVotePanelVotedForLabel" ).text = "Voted for 50!"
	$( "#PudgeWarsVotePanelButtons50" ).visible	 = false
	$( "#PudgeWarsVotePanelButtons75" ).visible	 = false
	$( "#PudgeWarsVotePanelButtons100" ).visible	 = false
	GameEvents.SendCustomGameEventToServer("pudgewars_player_vote50", {})
}

function OnVote75()
{
	$( "#PudgeWarsVotePanelVotedForLabel" ).text = "Voted for 75!"
	$( "#PudgeWarsVotePanelButtons50" ).visible	 = false
	$( "#PudgeWarsVotePanelButtons75" ).visible	 = false
	$( "#PudgeWarsVotePanelButtons100" ).visible	 = false
	GameEvents.SendCustomGameEventToServer("pudgewars_player_vote75", {})
}

function OnVote100()
{
	$( "#PudgeWarsVotePanelVotedForLabel" ).text = "Voted for 100!"
	$( "#PudgeWarsVotePanelButtons50" ).visible	 = false
	$( "#PudgeWarsVotePanelButtons75" ).visible	 = false
	$( "#PudgeWarsVotePanelButtons100" ).visible	 = false
	GameEvents.SendCustomGameEventToServer("pudgewars_player_vote100", {})
}

function OnVoteTimerUpdate(data) 
{
	if ((60 - parseInt(data.time_elapsed) - 2)<10) {
		$( "#PudgeWarsVoteTipTimer" ).text = "00:0" + (60 - parseInt(data.time_elapsed) - 2)
	} else {
		$( "#PudgeWarsVoteTipTimer" ).text = "00:" + (60 - parseInt(data.time_elapsed) - 2)
	}
}

function OnVoteUpdate(data)
{
	var vote_visibility = data.vote_visible;

	if (vote_visibility) {
		var contextPanel = $.GetContextPanel()
		contextPanel.visible = true
		var i = 0
		for (i = 0; i < data.votes_50; i++) { 
    		var count = i + 1
    		var display_name = "#PudgeWarsVotePanelRows1Block" + count
    		$( display_name ).visible = true
		}
		var i = 0
		for (i = 0; i < data.votes_75; i++) { 
    		var count = i + 1
    		var display_name = "#PudgeWarsVotePanelRows2Block" + count
    		$( display_name ).visible = true
		}
		var i = 0
		for (i = 0; i < data.votes_100; i++) { 
    		var count = i + 1
    		var display_name = "#PudgeWarsVotePanelRows3Block" + count
    		$( display_name ).visible = true
		}
	} else {
		var contextPanel = $.GetContextPanel()
		contextPanel.visible = false
	};
}

function OnVoteBlocksUpdate(data)
{
	var i = 0
	for (i = 0; i < data.votes_50; i++) { 
    	var count = i + 1
    	var display_name = "#PudgeWarsVotePanelRows1Block" + count
    	$( display_name ).visible = true
	}
	var i = 0
	for (i = 0; i < data.votes_75; i++) { 
    	var count = i + 1
    	var display_name = "#PudgeWarsVotePanelRows2Block" + count
    	$( display_name ).visible = true
	}
	var i = 0
	for (i = 0; i < data.votes_100; i++) { 
    	var count = i + 1
    	var display_name = "#PudgeWarsVotePanelRows3Block" + count
    	$( display_name ).visible = true
	}
}

(function () {
	GameEvents.Subscribe( "pudgewars_vote_update", OnVoteUpdate );
	GameEvents.Subscribe( "pudgewars_vote_blocks_update", OnVoteBlocksUpdate );
	GameEvents.Subscribe( "pudgewars_vote_timer_update", OnVoteTimerUpdate );
})();
