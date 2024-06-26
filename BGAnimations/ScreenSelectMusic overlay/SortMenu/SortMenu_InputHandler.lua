local sort_wheel = ...

-- this handles user input while in the SortMenu
local function input(event)
	if not (event and event.PlayerNumber and event.button) then
		return false
	end
	--SOUND:StopMusic() --Let's fade the music out when we open the sort menu, instead of stopping it on the first input in the sort menu - 48

	local screen   = SCREENMAN:GetTopScreen()
	local overlay  = screen:GetChild("Overlay")
	local sortmenu = overlay:GetChild("SortMenuAF")

	if event.type ~= "InputEventType_Release" then

		if event.GameButton == "MenuRight" then
			sort_wheel:scroll_by_amount(1)
			sortmenu:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			sort_wheel:scroll_by_amount(-1)
			sortmenu:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			sortmenu:GetChild("start_sound"):play()
			local focus = sort_wheel:get_actor_item_at_focus_pos()

            --Special-case the sorts powered by Preferred Sort (Event and CustomGenre, set sort to Preferred and set the preferred sort list)
			if focus.kind == "SortBy" then
                local sort_by = focus.sort_by
                if sort_by == "Event" then
                    sort_by = "Preferred"
                    SONGMAN:SetPreferredSongs("Event.txt")
                end
                if sort_by == "CustomGenre" then
                    sort_by = "Preferred"
                    SONGMAN:SetPreferredSongs("CustomGenre.txt")
                end
				MESSAGEMAN:Broadcast('Sort',{order=sort_by})
				overlay:queuecommand("DirectInputToEngine")


			-- the player wants to change modes, for example from ITG to FA+
			elseif focus.kind == "ChangeMode" then
				SL.Global.GameMode = focus.change
				SetGameModePreferences()
				THEME:ReloadMetrics()

				-- Change the header text to reflect the newly selected GameMode.
				overlay:GetParent():GetChild("Header"):playcommand("UpdateHeaderText")

				-- Reload the SortMenu's available options and queue "DirectInputToEngine"
				-- to return input from Lua back to the engine and hide the SortMenu from view
				sortmenu:playcommand("AssessAvailableChoices"):queuecommand("DirectInputToEngine")


			-- the player wants to change styles, for example from single to double
			elseif focus.kind == "ChangeStyle" then
				-- If the MenuTimer is in effect, make sure to grab its current
				-- value before reloading the screen.
				if PREFSMAN:GetPreference("MenuTimer") then
					overlay:playcommand("ShowPressStartForOptions")
				end

				-- Get the style we want to change to
				local new_style = focus.change:lower()

				-- accommodate techno game
				if GAMESTATE:GetCurrentGame():GetName()=="techno" then new_style = new_style.."8" end

				-- set it in the engine
				GAMESTATE:SetCurrentStyle(new_style)

				-- finally, reload the screen
				screen:SetNextScreenName("ScreenReloadSSM")
				screen:StartTransitioningScreen("SM_GoToNextScreen")

			-- the player is ragequitting (ending the session early)
			elseif focus.kind == "FeelingSalty" and focus.new_overlay == "QuitGame" then
				screen:SetNextScreenName(Branch.SSMCancel())
				screen:StartTransitioningScreen("SM_GoToNextScreen")

			elseif focus.new_overlay then
				if focus.new_overlay == "TestInput" then
					sortmenu:queuecommand("DirectInputToTestInput")
				end
			end
		end
	end
	if (event.GameButton == "Back" or event.GameButton == "Select") and event.type == "InputEventType_Release" then
		overlay:queuecommand("DirectInputToEngine")
	end

	return false
end

return input