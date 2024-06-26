local player = ...
local num_players = #GAMESTATE:GetHumanPlayers()

if SL.Global.GameMode == "Casual" then return Def.Actor{} end

return Def.ActorFrame{
    Name="PaneArrowsAF",
    InitCommand=function(self) self:y(_screen.cy+60):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(3.3):smooth(0.4):diffusealpha(1) end,
    Def.Sprite{
        Name="ArrowLeft",
        Texture=THEME:GetPathG("", "EditMenu Left.png"),
        InitCommand=function(self) self:x(-157):zoomto(16, 32) if num_players > 1 and player == "PlayerNumber_P2" then self:visible(false) end end,
        PressCommand=function(self) self:stoptweening():decelerate(0.05):zoomto(12, 28):glow(color("#ffffff22")):accelerate(0.05):zoomto(16, 32):glow(color("#ffffff00")) end,
		ExpandCommand=function(self) self:x(-264) end,
		ShrinkCommand=function(self) self:x(-157) end,
    },
    Def.Sprite{
        Name="ArrowRight",
        Texture=THEME:GetPathG("", "EditMenu Right.png"),
        InitCommand=function(self) self:x(155):zoomto(16, 32) if num_players > 1 and player == "PlayerNumber_P1" then self:visible(false) end end,
        PressCommand=function(self) self:stoptweening():decelerate(0.05):zoomto(12, 28):glow(color("#ffffff22")):accelerate(0.05):zoomto(16, 32):glow(color("#ffffff00")) end,
		ExpandCommand=function(self) self:x(268) end,
		ShrinkCommand=function(self) self:x(155) end,
    },
}