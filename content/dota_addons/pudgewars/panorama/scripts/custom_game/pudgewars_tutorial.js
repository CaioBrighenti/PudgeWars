"use strict";
var TutorialButtonPressed = false;

function OnToggleTutorialButton() {
	if (TutorialButtonPressed) {
		TutorialButtonPressed = false;
		$.GetContextPanel().SetHasClass( "toggle_tutorial_button", false );
		Game.EmitSound( "ui_team_select_lock_and_start" );
	} else {
		TutorialButtonPressed = true;
		$.GetContextPanel().SetHasClass( "toggle_tutorial_button", true );
		Game.EmitSound( "ui_team_select_lock_and_start" );
	};
}

SetTopBarScoreToWin()

function SetTopBarScoreToWin() {
	var team_score = CustomNetTables.GetTableValue("game_score", "team_score")
	var max_score = CustomNetTables.GetTableValue("game_score", "max_score")

	if (max_score)
		max_score = max_score.kills;
	else
		return;

	var radiant_score = 0;
	var dire_score = 0;

	if (team_score) {
		radiant_score = team_score.radiant_score;
		dire_score = team_score.dire_score;
	}

	$("#RadiantScore").text = radiant_score + "/" + max_score;
	$("#DireScore").text = dire_score + "/" + max_score;

	$("#RadiantProgressBar").value = radiant_score / max_score;
	$("#DireProgressBar").value = (max_score - dire_score) / max_score;
}

CustomNetTables.SubscribeNetTableListener("game_score", SetTopBarScoreToWin);

// Show tutorial to newcomers only
var plyData = CustomNetTables.GetTableValue("battlepass", Game.GetLocalPlayerID());

if (plyData.XP > 1) {
	TutorialButtonPressed = true;
	$.GetContextPanel().SetHasClass("toggle_tutorial_button", true);
}
