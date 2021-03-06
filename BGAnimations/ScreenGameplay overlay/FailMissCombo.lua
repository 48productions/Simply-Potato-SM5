--
--Here lies a custom implementation of Fail 30/51/etc Misses
--
--If enabled in the theme prefs, players can fail a song if they get a certain miss combo
--If all joined players have failed, the song is *immediately* failed regardless of the default fail type
--Ideally (though also configurable), if both players fail by miss combo, the entire set is forcibly failed even if failing out of the whole set is disabled
--This is intended for public machines where casual players might walk away from the game mid-song 
--

local is_single_player = (GAMESTATE:GetNumSidesJoined() == 1) --Is there only one player joined? If so, our logic for immediate fails changes a bit
local stage_stats = {} --Copy of each joined player's stage stats, set below
local fail_count = ThemePrefs.Get("FailOnMissCombo") --The combo to fail at, specified as a theme pref

for player in ivalues({PLAYER_1, PLAYER_2}) do --Get an instance of each joined player's stage stats, save them for later
	if GAMESTATE:IsSideJoined(player) then
		stage_stats[player] = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	end
end

return Def.Actor{
	JudgmentMessageCommand=function(self, params) --Called whenever either player hits a note and gets a judgement

		if is_single_player and stage_stats[params.Player]:GetCurrentMissCombo() >= fail_count then --Single player with a high miss count? Fail em!
			self:playcommand("FailNow")
		elseif not is_single_player and (stage_stats[PLAYER_1]:GetCurrentMissCombo() >= fail_count and stage_stats[PLAYER_2]:GetCurrentMissCombo() >= fail_count) then --Two players, both have a high miss count? Fail em!
			self:playcommand("FailNow")
		end
		
	end,
	FailNowCommand=function(self) --Called to IMMEDIATELY force a fail, regardless of the current fail type
		if ThemePrefs.Get("MissComboFailsSet") then SL.Global.MissComboFail = true end --If the miss combo is supposed to fail the set, set a flag to make sure that the eval screen goes into game over instead of select music
		SCREENMAN:GetTopScreen():PostScreenMessage("SM_BeginFailed", 0)
	end
}