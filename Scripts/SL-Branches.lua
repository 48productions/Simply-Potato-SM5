if not Branch then Branch = {} end

SelectMusicOrCourse = function()
	if GAMESTATE:IsCourseMode() then
		return "ScreenSelectCourse"
	else
		if SL.Global.GameMode == "Casual" then
			return "ScreenSelectMusicCasual"
		end

		return "ScreenSelectMusic"
	end
end

-- Override the fallback Branch.TitleMenu and Branch.AfterInit to never show ScreenLogo
Branch.AfterInit = function()
	return Branch.TitleMenu()
end
Branch.TitleMenu = function()
    -- Branch to the title menu (play/options/edit/exit) in home mode, and title join "press start to join" in pay/free play modes
    if GAMESTATE:GetCoinMode() == "CoinMode_Home" then
        return "ScreenTitleMenu"
    else
        return "ScreenTitleJoin"
    end
end

Branch.AllowScreenSelectProfile = function()
	if ThemePrefs.Get("AllowScreenSelectProfile") then
		return "ScreenSelectProfile"
	else
		return Branch.AllowScreenSelectColor()
	end
end

Branch.AllowScreenSelectColor = function()
	-- Skip ScreenSelectColor in Rainbow Mode, Potato Mode (the current SL color doesn't apply to either), or if it's been disabled in the option menu
	if ThemePrefs.Get("AllowScreenSelectColor") and not ThemePrefs.Get("RainbowMode") and ThemePrefs.Get("VisualTheme") ~= "Potato" then
		if AllowThonk() then return "ScreenSelectColorThonk" end
		return "ScreenSelectColor"
	else
		return Branch.AfterScreenSelectColor()
	end
end

Branch.AfterScreenSelectColor = function()
	local preferred_style = ThemePrefs.Get("AutoStyle")

	if preferred_style ~= "none"
	-- AutoStyle should not be possible in pay mode
	-- it's too confusing for machine operators, novice players, and developers alike
	and GAMESTATE:GetCoinMode() ~= "CoinMode_Pay" then

		-- If "versus" ensure that both players are actually considered joined.
		if preferred_style == "versus" then
			GAMESTATE:JoinPlayer(PLAYER_1)
			GAMESTATE:JoinPlayer(PLAYER_2)

		-- if AutoStyle was "single" but both players are already joined
		-- (for whatever reason), we're in a bit of a pickle, as there is
		-- no way to read the player's mind and know which side they really
		-- want to play on. Unjoin PLAYER_2 for lack of a better solution.
		elseif preferred_style == "single" then
			GAMESTATE:UnjoinPlayer(PLAYER_2)
		end

		-- FIXME: there's probably a more sensible place to set the current style for
		-- the engine, but I guess we're doing it here, in SL-Branches.lua, for now.
		GAMESTATE:SetCurrentStyle( preferred_style )

		if AllowThonk() then return "ScreenSelectPlayModeThonk" end
		return "ScreenSelectPlayMode"
	end

	if AllowThonk() then return "ScreenSelectStyleThonk" end
	return "ScreenSelectStyle"
end

Branch.AfterEvaluationStage = function()
	-- If we're in Casual mode, don't save the profile(s).
	--if SL.Global.GameMode == "Casual" then
	--	return Branch.AfterProfileSave()
	--else
		return "ScreenProfileSave" --Plot twist let's *always* save profiles now - 48
	--end
end

Branch.AfterSelectPlayMode = function()
	return SelectMusicOrCourse()
end


Branch.AfterGameplay = function()
	if THEME:GetMetric("ScreenHeartEntry", "HeartEntryEnabled") then
		local go_to_heart= false
		for i, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
			local profile= PROFILEMAN:GetProfile(pn)
			if profile and profile:GetIgnoreStepCountCalories() then
				go_to_heart= true
			end
		end

		if go_to_heart then
			return "ScreenHeartEntry"
		end
	end

	return Branch.AfterHeartEntry()
end

Branch.AfterHeartEntry = function()
	local pm = ToEnumShortString(GAMESTATE:GetPlayMode())
	if( pm == "Regular" ) then return "ScreenEvaluationStage" end
	if( pm == "Nonstop" ) then return "ScreenEvaluationNonstop" end
end

Branch.AfterSelectMusic = function()
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return "ScreenPlayerOptions"
	else
		-- routine mode specifically uses ScreenGameplayShared
		local style = GAMESTATE:GetCurrentStyle():GetName()
		if style == "routine" then
			return "ScreenGameplayShared"
		end

		-- while everything else (single, versus, double, etc.) uses ScreenGameplay
		return "ScreenGameplay"
	end
end

Branch.SSMCancel = function()

	if GAMESTATE:GetCurrentStageIndex() > 0 then
		return Branch.AllowScreenEvalSummary()
	end

	-- Check if we forced thonk mode via the title screen pad code for this set, and disable it if so
	if getenv("ForceThonk") == true then
		ANNOUNCER:SetCurrentAnnouncer("")
		setenv("ForceThonk", false)
	end
	if getenv("AllowAF") == true then
		setenv("AllowAF", false)
	end

	return Branch.TitleMenu()
end

Branch.AllowScreenNameEntry = function()

	-- If we're in Casual mode, don't allow NameEntry, and don't
	-- bother saving the profile(s). Skip directly to GameOver.
	if SL.Global.GameMode == "Casual" then
		return "ScreenProfileSaveSummary" --Plot twist let's save profiles in casual now - 48

	elseif ThemePrefs.Get("AllowScreenNameEntry") and SL.Global.MissComboFail == false then --If name entry is enabled and we didn't fail the set via a miss combo, go to name entry
		return "ScreenNameEntryTraditional"

	else
		return "ScreenProfileSaveSummary"
	end
end

Branch.AllowScreenEvalSummary = function()
	if ThemePrefs.Get("AllowScreenEvalSummary") and SL.Global.MissComboFail == false then --Show the evaluation summary screen if it's enabled and if the player didn't fail because of a miss combo
		return "ScreenEvaluationSummary"
	else
		return Branch.AllowScreenNameEntry()
	end
end


local EnoughCreditsToContinue = function()
	local credits = GetCredits().Credits
	local premium = GAMESTATE:GetPremium()
	local style = GAMESTATE:GetCurrentStyle():GetName():gsub("8", "")

	if premium == "Premium_2PlayersFor1Credit" and credits > 0 then return true end

	if premium == "Premium_DoubleFor1Credit" then
		if style == "versus" then
			if credits > 1 then return true end
		else
			if credits > 0 then return true end
		end
	end

	if premium == "Premium_Off" then
		if style == "single" then
			if credits > 0 then return true end
		else
			if credits > 1 then return true end
		end
	end

	return false
end

Branch.AfterProfileSave = function()

	if PREFSMAN:GetPreference("EventMode") then
		return SelectMusicOrCourse()

	elseif GAMESTATE:IsCourseMode() then
		return Branch.AllowScreenNameEntry()

	else

		-- deduct the number of stages that stock StepMania says the song is
		local song = GAMESTATE:GetCurrentSong()
		local SMSongCost = (song:IsMarathon() and 3) or (song:IsLong() and 2) or 1
		SL.Global.Stages.Remaining = SL.Global.Stages.Remaining - SMSongCost

		-- check if stages should be "added back" to SL.Global.Stages.Remaining because of an active rate mod
		if SL.Global.ActiveModifiers.MusicRate ~= 1 then
			local ActualSongCost = 1
			local StagesToAddBack = 0

			local Duration = song:GetLastSecond()
			local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

			local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
			local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

			local IsMarathon = (DurationWithRate/MarathonCutoff > 1)
			local IsLong     = (DurationWithRate/LongCutoff > 1)

			ActualSongCost = (IsMarathon and 3) or (IsLong and 2) or 1
			StagesToAddBack = SMSongCost - ActualSongCost

			SL.Global.Stages.Remaining = SL.Global.Stages.Remaining + StagesToAddBack
		end

		-- Now, check if StepMania and SL disagree on the stage count. If necessary, add stages back.
		-- This might be necessary because:
		-- a) a Lua chart reloaded ScreenGameplay, or
		-- b) everyone failed, and StepmMania zeroed out the stage numbers
		if GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()) < SL.Global.Stages.Remaining then
			local StagesToAddBack = math.abs(SL.Global.Stages.Remaining - GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber()))
			local Players = GAMESTATE:GetHumanPlayers()
			for pn in ivalues(Players) do
				for i=1, StagesToAddBack do
					GAMESTATE:AddStageToPlayer(pn)
				end
			end
		end

		-- now, check if this set is over.
		local setOver
		-- This is only true if the set would have been over naturally,
		setOver = (SL.Global.Stages.Remaining <= 0)
		-- OR if we allow players to fail a set early and the players actually failed.
		if ThemePrefs.Get("AllowFailingOutOfSet") == true then
			setOver = setOver or STATSMAN:GetCurStageStats():AllFailed()
		end
		-- OR if both players failed because of a miss combo (overriding AllowFailingOutOfSet)
		if SL.Global.MissComboFail == true then
			setOver = true
		end
		-- this style is more verbose but avoids obnoxious if statements

		if setOver then
			-- continues are only allowed in Pay mode
			if PREFSMAN:GetPreference("CoinMode") == "CoinMode_Pay" then
				if SL.Global.ContinuesRemaining > 0 and EnoughCreditsToContinue() then
					return "ScreenPlayAgain"
				end
			end

			return Branch.AllowScreenEvalSummary()
		else
			return SelectMusicOrCourse()
		end
	end

	-- just in case?
	return SelectMusicOrCourse()
end

Branch.AfterProfileSaveSummary = function()
	SL.Global.MissComboFail = false --Make sure to clear the "miss combo fail" flag before going into game over!
    --Because it is stored in the player prefs, the "seen modfile" check is reset after each game cycle if a player isn't using a profile, and is saved to their profile if it is
	if ThemePrefs.Get("AllowScreenGameOver") then
		return "ScreenGameOver"
	else
		return Branch.AfterInit()
	end
end

Branch.DefaultGameMode = function()
	if GAMESTATE:IsAnyHumanPlayerUsingMemoryCard() then --Switch the default mode based on whether anyone has a memory card (they both read from an setting in the Simply Love Options menu) - 48
		return ThemePrefs.Get("DefaultGameModeMemoryCard") or "ITG"
	else
		return ThemePrefs.Get("DefaultGameMode") or "ITG"
	end
end
