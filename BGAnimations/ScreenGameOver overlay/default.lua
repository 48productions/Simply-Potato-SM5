local Players = GAMESTATE:GetHumanPlayers();

local using_mem_card = GAMESTATE:IsAnyHumanPlayerUsingMemoryCard()
local new_profile_written = PROFILEMAN:ProfileFromMemoryCardIsNew('PlayerNumber_P1') or PROFILEMAN:ProfileFromMemoryCardIsNew('PlayerNumber_P2') --If either player has a *new* memory card profile, note it

local logo_tween_time = 0.5 -- Time for the falling text animation
local logo_tween_offset = 0.13

local t = Def.ActorFrame{
	InitCommand=function(self)
		-- Check if we forced thonk mode via style selection for this set, and disable it if so
		if getenv("ForceThonk") == true then
			ANNOUNCER:SetCurrentAnnouncer("")
			setenv("ForceThonk", false)
		end
		if getenv("AllowAF") == true then
			setenv("AllowAF", false)
		end
	end,
    OnCommand=function(self)
		self:propagate(true):queuecommand("AnimateLogo")
	end,
	
    --"Thanks for playing"/USB reminder text
    LoadFont("_upheaval_underline 80px")..{
		Text=ScreenString("ThanksForPlaying"),
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+150):diffuse(color("#aaaaaaff")):zoom(0.25) end,
		OnCommand=function(self)
			self:queuecommand("Pulse")
			if using_mem_card then
                if new_profile_written then --Display different messages if a new memory card profile was written
                    self:settext(ScreenString("NewProfile"))
                else
                    self:settext(ScreenString("USBReminder"))
                end
            end
		end,
		PulseCommand=function(self) self:smooth(1.5):zoom(0.35):smooth(1.5):zoom(0.34):queuecommand("Pulse") end,
	},
}

--[[if using_mem_card then --If any player is using a memory card, remind them to take it with them!
	t[#t+1] = LoadActor("usbicon.png")..{
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+215):zoom(0.35) end,
		OnCommand=function(self) self:glow(1,1,1,1):glowshift():queuecommand("Rotate") end,
		RotateCommand=function(self) self:smooth(1):rotationz(8):smooth(1):rotationz(-8):queuecommand("Rotate") end,
	}
end]]

--Background cover
t[#t+1] = Def.Quad{
    InitCommand=function(self) self:zoomto(_screen.w,_screen.h):Center():diffuse(0,0,0,1) end,
    AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 7.5 + logo_tween_time):decelerate(0.75):diffuse(1,1,1,0.01):decelerate(3):diffusealpha(0) end,
}

 --"Game Over" text
 t[#t+1] = Def.ActorFrame{
    InitCommand=function(self) self:zoom(0.42):Center() end,
    -- Text shadow (don't have the asset for this yet)
    --[[LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Logo_Shadow (doubleres).png"))..{
        InitCommand=function(self) self:diffusealpha(0) end,
        AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 7):smooth(1):diffusealpha(1) end,
    },]]
    -- "Game" AF
    Def.ActorFrame{
        InitCommand=function(self) self:y(-128-100) end,
        OffCommand=function(self) self:finishtweening() end,
        LoadActor("Text/Game_G (doubleres).png")..{
            InitCommand=function(self) self:x(-271):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0) end end,
        },
        LoadActor("Text/Game_A (doubleres).png")..{
            InitCommand=function(self) self:x(-96):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.1) end end,
        },
        LoadActor("Text/Game_M (doubleres).png")..{
            InitCommand=function(self) self:x(87):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 2):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.2) end end,
        },
        LoadActor("Text/Game_E (doubleres).png")..{
            InitCommand=function(self) self:x(269):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 3):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.3) end end,
        },
    },
    
    -- "Over" AF
    Def.ActorFrame{
        InitCommand=function(self) self:y(89-100) end,
        OffCommand=function(self) self:finishtweening() end,
        LoadActor("Text/Over_O (doubleres).png")..{
            InitCommand=function(self) self:x(-271):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 2):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.1) end end,
        },
        LoadActor("Text/Over_V (doubleres).png")..{
            InitCommand=function(self) self:x(-96):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 3):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.2) end end,
        },
        LoadActor("Text/Over_E (doubleres).png")..{
            InitCommand=function(self) self:x(87):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 4):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.3) end end,
        },
        LoadActor("Text/Over_R (doubleres).png")..{
            InitCommand=function(self) self:x(269):diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 5):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.4) end end,
        },
    },
}

return t