local args = ...
local choiceName = args[1].name
local frame_y = args[1].y
local index = args[2]



local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy( _screen.w/5, frame_y ):diffusealpha(0)

		if ThemePrefs.Get("VisualTheme")=="Gay" and not HolidayCheer() then
			self:bob():effectmagnitude(0,0,0):effectclock('bgm'):effectperiod(0.666)
		else
            self:bob():effectmagnitude(0, 0, 0)
        end
	end,
	OffCommand=function(self)
		self:sleep(0.04 * index)
		self:linear(0.2)
		self:diffusealpha(0)
	end,
	GainFocusCommand=function(self)
		self:finishtweening():linear(0.125):x(_screen.w/4):diffusealpha(1):playcommand("Pulse")
		if ThemePrefs.Get("VisualTheme")=="Gay" and not HolidayCheer() then
			self:effectmagnitude(4,0,0)
		else
            self:effectmagnitude(8,0,0)
        end
	end,
	LoseFocusCommand=function(self)
		self:finishtweening():linear(0.125):x(_screen.w/5):effectmagnitude(0,0,0):diffusealpha(0.6):playcommand("StopPulsing")
	end,

	--Outline
	Def.Quad{
		InitCommand=function(self) self:zoomto(232, 66):diffuse(1,1,1,1):cropbottom(1) end,
		OnCommand=function(self) self:linear(0.2):cropbottom(0) end,
		GainFocusCommand=function(self) self:stoptweening():linear(0.1) end,
		LoseFocusCommand=function(self) self:stoptweening():linear(0.1) end,
		OffCommand=function(self) self:sleep(0.15):linear(0.2):cropbottom(1) end
	},



	--Background
	Def.Quad{
		InitCommand=function(self) self:zoomto(230, 64):diffuse(0,0,0,1):cropbottom(1) end,
		OnCommand=function(self) self:linear(0.2):cropbottom(0) end,
		GainFocusCommand=function(self) self:stoptweening():linear(0.1) end,
		LoseFocusCommand=function(self) self:stoptweening():linear(0.1) end,
		OffCommand=function(self) self:sleep(0.15):linear(0.2):cropbottom(1) end
	},

	--Icon
	--[[LoadActor("icon-" .. text .. ".png")..{
		Name="Icon",
		InitCommand=function(self) self:bob() end,
		OnCommand=function(self) self:diffusealpha(0):sleep(0.11):linear(0.2):diffusealpha(1) end,
		GainFocusCommand=function(self) self:stoptweening():decelerate(0.1):zoom(0.5):diffuse(color("#FFFFFF")):effectmagnitude(0, 8, 0) end,
		LoseFocusCommand=function(self) self:stoptweening():decelerate(0.1):zoom(0.4):diffuse(color("#808080")):effectmagnitude(0, 0, 0) end,
		OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
	},]]

	-- Announcer Name
	LoadFont("_upheaval_underline 80px")..{
		Text=choiceName,

		InitCommand=function(self) self:maxwidth(400):y(-4) end,
		OnCommand=function(self) self:diffusealpha(0):sleep(0.02):linear(0.2):diffusealpha(1):zoom(0.5) end,
		GainFocusCommand=function(self) self:stoptweening():linear(0.1):diffuse(PlayerColor(PLAYER_1)) end,
		LoseFocusCommand=function(self) self:stoptweening():linear(0.1):diffuse(color("#888888")) end,
		OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
	},
}

return af