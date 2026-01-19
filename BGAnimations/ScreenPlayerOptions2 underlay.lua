-- Shared zoom value for the note sprites
local noteZoom = 0.4
local notefield = {}

-- Calculate receptor y-positions, applying the Split, Cross, Alternate, and Reverse mods found in player options
local function calculateSCAR(popts, column)
	--return -60 -- Disable calculation for now
	if popts == nil then return -60 end -- No player options for some reason = bail here
	if popts:Centered() == 1 then return 20 end -- Centered overrides all other SCAR mods... I think?
	
	local ypos = 1 -- Start with the standard receptor y position and invert it based on the selected mods
	if popts:Reverse() == 1 then ypos = ypos * -1 end -- Reverse inverts all columns
	if popts:Split() == 1 and (column == 3 or column == 4) then ypos = ypos * -1 end -- Split inverts columns 3 and 4
	if popts:Alternate() == 1 and (column == 2 or column == 4) then ypos = ypos * -1 end -- Alternate inverts columns 2 and 4
	if popts:Cross() == 1 and (column == 2 or column == 3) then ypos = ypos * -1 end -- Split inverts columns 2 and 3
	return ypos == 1 and -45 or 40
end



local function HandleInput(event)
	if not event.PlayerNumber then return end -- Input not bound, return
	if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
		notefield[ToEnumShortString(event.PlayerNumber)]:playcommand("Refresh", {ActiveMods=SL[ToEnumShortString(event.PlayerNumber)].ActiveModifiers})
	end
end



local af = Def.ActorFrame{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(HandleInput):propagate(true) end
}


for player in ivalues(GAMESTATE:GetHumanPlayers()) do

	local poptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Preferred')
	local active_mods = SL[ToEnumShortString(player)].ActiveModifiers -- Cache this player's current active modifiers for fetching the combo/judgment graphics
	local combo_font = active_mods.ComboFont
	local measure_font
	if combo_font == "Wendy" or combo_font == "Wendy (Cursed)" then
		measure_font = "_wendy small"
	else
		measure_font = "_Combo Fonts/" .. combo_font .. "/"
	end
	local judgment_font = active_mods.JudgmentGraphic

	-- An ActorFrame for each player
	playerAF = Def.ActorFrame{
		InitCommand=function(self)
			notefield[ToEnumShortString(player)] = self
			self:xy(_screen.w * 0.85, player == PLAYER_1 and _screen.h * 0.32 or _screen.h * 0.72):propagate(true)
			    :playcommand("Reposition", {POptions=GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Preferred')})
				:playcommand("Refresh", {ActiveMods=SL[ToEnumShortString(player)].ActiveModifiers})
		end,
	
		-- Background quad
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(_screen.cx * 0.4, _screen.h * 0.38)
					:diffuse(Color.Black):diffusealpha( BrighterOptionRows() and 0.95 or 0.75)
			end,
		},
		
		
	}
	
	 -- Illustrative notefield
	local notefieldAF = Def.ActorFrame{
			InitCommand=function(self) self:diffusealpha(0) end,
			OptionRowChangedMessageCommand=function(self)
				local row_num = SCREENMAN:GetTopScreen():GetCurrentRowIndex(player)
				self:stoptweening():smooth(0.2):diffusealpha((row_num >= 2 and row_num <= 11) and 1 or 0) -- Only show the notefield when the player is highlighting options that update it (the engine options can't properly do this)
			end,
			
			-- Background quad 2 ("Background" option)
			Def.Sprite{
				Texture=THEME:GetPathG("", "_FallbackBanners/Arrows/banner11 (doubleres).png"),
				InitCommand=function(self)
					self:scaletoclipped(_screen.cx * 0.39, _screen.h * 0.31):y(14):diffusealpha(0.5)
				end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideSongBG) end,
			},
			
			-- Column Cue
			Def.Quad{
				InitCommand=function(self) self:zoomto(24, _screen.h * 0.31):xy(-45, 14):diffuse(0.3, 1, 1, 0.2) end,
				RefreshCommand=function(self, params) self:visible(params.ActiveMods.ColumnCues) end
			},
			
			-- Surround Lifebar
			Def.Quad{
				InitCommand=function(self) self:zoomto(_screen.cx * 0.195, _screen.h * 0.155):xy(-_screen.cx * 0.0975, _screen.h * 0.0775 + 14):diffuse(0.2,0.2,0.2,1):faderight(0.8) end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideLifebar and params.ActiveMods.LifeMeterType == "Surround") end,
			},
			
			-- Receptors
			NOTESKIN:LoadActorForNoteSkin("Left", "Receptor", poptions:NoteSkin())..{
				InitCommand=function(self) self:x(-45):zoom(noteZoom) end,
				RepositionCommand=function(self, params) self:y(calculateSCAR(params.POptions, 1)) end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideTargets) end,
			},
			NOTESKIN:LoadActorForNoteSkin("Down", "Receptor", poptions:NoteSkin())..{
				InitCommand=function(self) self:x(-15):zoom(noteZoom) end,
				RepositionCommand=function(self, params) self:y(calculateSCAR(params.POptions, 2)) end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideTargets) end,
			},
			NOTESKIN:LoadActorForNoteSkin("Up", "Receptor", poptions:NoteSkin())..{
				InitCommand=function(self) self:x(15):zoom(noteZoom) end,
				RepositionCommand=function(self, params) self:y(calculateSCAR(params.POptions, 3)) end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideTargets) end,
			},
			NOTESKIN:LoadActorForNoteSkin("Right", "Receptor", poptions:NoteSkin())..{
				InitCommand=function(self) self:x(45):zoom(noteZoom) end,
				RepositionCommand=function(self, params) self:y(calculateSCAR(params.POptions, 4)) end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideTargets) end,
			},
			
			-- Judge font
			LoadActor( GetJudgmentGraphicPath(judgment_font) )..{
				Condition=judgment_font ~= "None",
				InitCommand=function(self) self:zoom(noteZoom * 0.8):y(-10):animate(false) end,
				RefreshCommand=function(self, params) self:rotationz(params.ActiveMods.JudgmentTilt and -10 or 0) end,
			},
			
			-- Combo text
			LoadFont("_Combo Fonts/" .. combo_font .."/" .. combo_font)..{
				Text="24",
				InitCommand=function(self) self:zoom(noteZoom * 0.8) end,
				RefreshCommand=function(self, params) self:y(20):visible(not params.ActiveMods.HideCombo) end,
			},
			
			-- Measure counter
			LoadFont(measure_font)..{
				Text="2/8",
				InitCommand=function(self) self:zoom(noteZoom * 0.4) end,
				-- Reposition based off the "Move Left" and "Move Up" mods
				RefreshCommand=function(self, params) self:visible(params.ActiveMods.MeasureCounter ~= "None"):xy(params.ActiveMods.MeasureCounterLeft and -30 or 0, params.ActiveMods.MeasureCounterUp and -22 or 5) end,
			},
			
			-- Subtractive scoring
			LoadFont("_wendy small")..{
				Text="-3.9%",
				InitCommand=function(self) self:zoom(noteZoom * 0.4):xy(30, 5):diffuse(color("#ff55cc")) end,
				RefreshCommand=function(self, params) self:visible(params.ActiveMods.SubtractiveScoring) end,
			},
			
			-- Score
			LoadFont("_wendy monospace numbers")..{
				Text="57.30",
				InitCommand=function(self) self:zoom(0.15):xy(-25, -70) end,
				-- Hide score if it's disabled or if we're showing the NPS graph
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideScore and not params.ActiveMods.NPSGraphAtTop) end,
			},
			
			-- Pacemaker
			LoadFont("_wendy small")..{
				Text="+4.2",
				InitCommand=function(self) self:zoom(0.15):xy(8, -67) end,
				-- Hide pacemaker if it's disabled or if we're showing the NPS graph
				RefreshCommand=function(self, params) self:visible(params.ActiveMods.Pacemaker and not params.ActiveMods.NPSGraphAtTop) end,
			},
			
			-- NPS graph
			Def.ActorFrame{
				InitCommand=function(self) self:y(-67) end,
				RefreshCommand=function(self, params) self:visible(params.ActiveMods.NPSGraphAtTop) end,
				
				-- Top half
				Def.Quad{
					InitCommand=function(self) self:zoomto(110,5):y(-2.5):diffuse(color_slate2) end,
				},
				-- Bottom half
				Def.Quad{
					InitCommand=function(self) self:zoomto(110,5):y(2.5):diffuse(color("#1591BB")) end,
				},
			},
			
			-- Standard Lifebar
			Def.ActorFrame{
				InitCommand=function(self) self:xy(-40, -80) end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideLifebar and params.ActiveMods.LifeMeterType == "Standard") end,
				
				-- Border
				Def.Quad{
					InitCommand=function(self) self:zoomto(50,10) end,
				},
				-- Inside
				Def.Quad{
					InitCommand=function(self) self:zoomto(48,8):diffuse(PlayerColor(player)) end,
				},
			},
			
			-- Vertical Lifebar
			Def.ActorFrame{
				InitCommand=function(self) self:xy(-66, 10) end,
				RefreshCommand=function(self, params) self:visible(not params.ActiveMods.HideLifebar and params.ActiveMods.LifeMeterType == "Vertical") end,
				
				-- Border
				Def.Quad{
					InitCommand=function(self) self:zoomto(10, 80) end,
				},
				-- Inside
				Def.Quad{
					InitCommand=function(self) self:zoomto(8, 78):diffuse(PlayerColor(player)) end,
				},
			},
			
			-- Target score graph
			Def.ActorFrame{
				InitCommand=function(self) self:xy(66, 10) end,
				RefreshCommand=function(self, params) self:visible(params.ActiveMods.DataVisualizations == "Target Score Graph") end,
				
				-- Border
				Def.Quad{
					InitCommand=function(self) self:zoomto(10, 80) end,
				},
				-- Inside
				Def.Quad{
					InitCommand=function(self) self:zoomto(8, 78):diffuse(0,0,0,1) end,
				},
			},
			
			-- The help text is handled by the engine ([ScreenPlayerOptions2] ExplanationPX in metrics)
			
			-- Help text background
			Def.Quad{
				InitCommand=function(self) self:zoomto(_screen.cx * 0.4, 40):y(70):fadetop(0.1):diffuse(0,0,0,0.5) end,
			}
		}
	
	-- Measure Lines
	local lineAF = Def.ActorFrame{
		InitCommand=function(self) self:diffusealpha(0.7) end,
		
		-- Top bar (measure)
		Def.Quad{
			InitCommand=function(self) self:zoomto(100, 2):y(-13.5) end,
			RefreshCommand=function(self, params)
				local opt = params.ActiveMods.MeasureLines
				self:visible(opt == "Measure" or opt=="Quarter" or opt=="Eighth")
			end,
		},
		
		-- Bottom bar (4th)
		Def.Quad{
			InitCommand=function(self) self:zoomto(100, 1):y(54) end,
			RefreshCommand=function(self, params)
				local opt = params.ActiveMods.MeasureLines
				self:visible(opt == "Quarter" or opt=="Eighth")
			end,
		},
	}
	
	-- Middle bar (8th)

	local lineAF2 = Def.ActorFrame{
		RefreshCommand=function(self, params)
			self:visible(params.ActiveMods.MeasureLines=="Eighth")
		end,
	}
	-- This should be a dashed line, so add a bunch of quads
	-- This doesn't feel ideal - 48
	for i=1,9 do
		lineAF2[#lineAF2+1] = Def.Quad{
			InitCommand=function(self) self:zoomto(5, 1):xy(-57.5 + (i*10), 20.25) end,
		}
	end

	lineAF[#lineAF+1] = lineAF2

	notefieldAF[#notefieldAF+1] = lineAF

	-- Arrows
	notefieldAF[#notefieldAF+1] = NOTESKIN:LoadActorForNoteSkin("Left", "Tap Note", poptions:NoteSkin())..{
		InitCommand=function(self) self:x(-45):zoom(noteZoom) end,
		RepositionCommand=function(self, params) self:y(calculateSCAR(params.POptions, 1) * 0.3) end,
	}
	notefieldAF[#notefieldAF+1] = NOTESKIN:LoadActorForNoteSkin("Left", "Tap Note", poptions:NoteSkin())..{
		InitCommand=function(self)
			local spacingX = NOTESKIN:GetMetricFForNoteSkin("Tap Note", "TapNoteNoteColorTextureCoordSpacingX", poptions:NoteSkin())
			local spacingY = NOTESKIN:GetMetricFForNoteSkin("Tap Note", "TapNoteNoteColorTextureCoordSpacingY", poptions:NoteSkin())
			self:x(45):zoom(noteZoom):baserotationz(-90):texturetranslate(spacingX, spacingY)
		end,
		RepositionCommand=function(self, params) self:y(calculateSCAR(params.POptions, 4) * -0.45) end,
	}
	
	playerAF[#playerAF+1] = notefieldAF
	af[#af+1] = playerAF
end

return af