-- assume that all human players failed
--local img = "failed text.png"

local cleared = false

-- loop through all available human players
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	-- if any of them passed, we want to display the "cleared" graphic
	if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() then
        cleared = true
		--img = "cleared text-new.png"
	end
end

return Def.ActorFrame {
	Def.Quad{
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black) end,
		OnCommand=function(self) self:sleep(0.2):linear(0.5):diffusealpha(0) end,
	},

    LoadActor(cleared and "cleared bg.png" or "failed bg.png")..{ --BG - left half (we render this in two halves so we can get a mirrored gradient across the whole background)
		InitCommand=function(self) self:zoom(0.8):xy(_screen.cx - self:GetZoomedWidth() / 2, _screen.cy):diffuseleftedge(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuserightedge(GetHexColor(SL.Global.ActiveColorIndex-1)):diffusealpha(0) end,
		OnCommand=function(self) self:accelerate(0.4):diffusealpha(0.8):sleep(0.6):decelerate(0.4):diffusealpha(0) end
	},
    
    LoadActor(cleared and "cleared bg.png" or "failed bg.png")..{ --BG - right half
		InitCommand=function(self) self:zoom(0.8):basezoomx(-1):xy(_screen.cx - self:GetZoomedWidth() / 2, _screen.cy):diffuseleftedge(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuserightedge(GetHexColor(SL.Global.ActiveColorIndex-1)):diffusealpha(0) end,
		OnCommand=function(self) self:accelerate(0.4):diffusealpha(0.8):sleep(0.6):decelerate(0.4):diffusealpha(0) end
	},

	LoadActor(cleared and "cleared text-new.png" or "failed text-new.png")..{ --Text
		InitCommand=function(self) self:Center():zoom(0.8):diffusealpha(0) end,
		OnCommand=function(self) self:accelerate(0.4):diffusealpha(1):sleep(0.6):decelerate(0.4):diffusealpha(0) end
    },
}