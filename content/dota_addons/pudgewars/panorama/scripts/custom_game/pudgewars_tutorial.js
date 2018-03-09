"use strict";
var TutorialButtonPressed = false;

function OnToggleTutorialButton()
{
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