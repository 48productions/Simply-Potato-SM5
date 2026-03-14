local logo_tween_time = 0.5 -- Time for the "falling" Simply Spud" logo animation
local logo_tween_offset = 0.13

local TextColor = (ThemePrefs.Get("RainbowMode") and (not HolidayCheer()) and Color.Black) or Color.White

local SongStats = SONGMAN:GetNumSongs() .. " songs in "
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, "
SongStats = SongStats .. #SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses")) .. " courses"

-- - - - - - - - - - - - - - - - - - - - -
local game = GAMESTATE:GetCurrentGame():GetName();
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

--Do you like video games?
local video_games = 0
if SPLovesVideoGames() then video_games = 1 end

-- - - - - - - - - - - - - - - - - - - - -
-- People commonly have multiple copies of SL installed – sometimes different forks with unique features
-- sometimes due to concern that an update will cause them to lose data, sometimes accidentally, etc.

-- It is important to display the current theme's name to help users quickly assess what version of SL
-- they are using right now.  THEME:GetThemeDisplayName() provides the name of the theme folder from the
-- edit: ThemeInfo.ini, so we'll show that.  It is likely to be unique and users are likely to recognize it.

-- More importantly, you can easily change ThemeInfo.ini if you decide to rename your theme halfway through development
-- You can't change the name of the theme's folder without breaking the repo - 48 :(
--local sl_name = THEME:GetThemeDisplayName()
local sl_name = THEME:GetCurThemeName() --The theme's display name isn't it's path lol

-- - - - - - - - - - - - - - - - - - - - -
-- ProductFamily() returns "StepMania"
-- ProductVersion() returns the (stringified) version number (like "5.0.12" or "5.1.0")
-- so, start with a string like "StepMania 5.0.12" or "StepMania 5.1.0"
local sm_version = ("%s %s"):format(ProductFamily(), ProductVersion())

-- GetThemeVersion() is defined in ./Scripts/SL-Helpers.lua and returns the SL version from ThemeInfo.ini
local sl_version = GetThemeVersion()

-- "git" appears in ProductVersion() for non-release builds of StepMania.
-- If a non-release executable is being used, append date information about when it
-- was built to potentially help non-technical cabinet owners submit bug reports.
if ProductVersion():find("git") then
	local date = VersionDate()
	local year = date:sub(1,4)
	local month = date:sub(5,6)
	if month:sub(1,1) == "0" then month = month:gsub("0", "") end
	month = THEME:GetString("Months", "Month"..month)
	local day = date:sub(7,8)

	sm_version = ("%s, Built %s %s %s"):format(sm_version, day, month, year)
end

-- - - - - - - - - - - - - - - - - - - - -
local style = ThemePrefs.Get("VisualTheme")
local image = "TitleMenu"

-- see: watch?v=wxBO6KX9qTA etc.
if FILEMAN:DoesFileExist((IsSM53() and "/Appearance/Themes/" or "/Themes/")..sl_name.."/Graphics/_VisualStyles/"..ThemePrefs.Get("VisualTheme").."/TitleMenuAlt (doubleres).png") then
	if AllowAF() or math.random(1,100) <= 10 then image="TitleMenuAlt" end -- An alternate title screen image is shown on April Fools day  (or a 10% chance otherwise)
end

local af = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Initialize.lua
		InitializeSimplyLove()

		self:Center()
	end,
    OnCommand=function(self) self:propagate(true):queuecommand("AnimateLogo") end, -- Workaround for a bug where input is eaten until this OnCommand finishes (sorry, Squirrel ;_;)
	OffCommand=function(self) self:linear(0.5):diffusealpha(0) end,
	
	LoadActor(THEME:GetPathG("","BigArrow.lua")),
	
    --Background cover for the intro animation
    Def.Quad{
        InitCommand=function(self) self:zoomto(_screen.w,_screen.h):diffuse(0,0,0,1) end,
        AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 7.5 + logo_tween_time):decelerate(0.75):diffuse(1,1,1,0.05):decelerate(3):diffusealpha(0) end,
        OffCommand=function(self) self:finishtweening() end,
    },
	
	
	-- Thonk code okay sound
	Def.Sound{
		File=THEME:GetPathS("", "_unlock.ogg"),
		-- Secret cheat code to enable thonk mode at any time
		CodeMessageCommand=function(self, params)
			-- Triggering thonk mode via the pad code sets a timeout
			-- If this timeout is active, this code cannot be entered again until the timeout expires (ROUGHLY 6ish hours later in the day, but is inconsistent for style points and ease of implementation)
			-- This prevents players from spamming thonk mode and the associated meme announcer, if present, all day in a public venue
			if params.Name == "EnableThonk" then -- First, did we even enter the thonk mode code?
				--SM((SL.ThonkTimeout + 6)..Hour())
				--if true then
				if (SL.ThonkTimeout + 6) < Hour() then -- Next check the timeout
					setenv("AllowAF", true) -- Set an environment variable to allow thonk
					self:play()
				else
					SM("Recharging...")
				end
				SL.ThonkTimeout = Hour() -- Peak game design: Reset the timeout even if the code failed lol
			end
		end,
	},
}

-- decorative arrows, now using the editor noteskin!
if style ~= "Potato" then
    af[#af+1] = LoadActor(THEME:GetPathG("", "_logos"), video_games)..{
        AnimateLogoCommand=function(self)
            self:y(-16):zoom(0.55)
        end,
    }
end

-- old
--af[#af+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
--	InitCommand=function(self)
--		self:y(-16):zoom( game=="pump" and 0.2 or 0.205 )
--	end
--}
--end

-- Spud theme handles the logo VERY DIFFERENTLY (tween individual letters), special-case it here
if style == "Potato" then
    -- Logo AF
    af[#af+1] = Def.ActorFrame{
        InitCommand=function(self) self:zoom(0.42):diffusealpha(1) end,
        LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Logo_Shadow (doubleres).png"))..{
            InitCommand=function(self) self:diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 7):smooth(1):diffusealpha(1) end,
        },
        -- "Simply" AF
        Def.ActorFrame{
            InitCommand=function(self) self:y(-128-100) end,
            OffCommand=function(self) self:finishtweening() end,
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Simply_S (doubleres).png"))..{ -- S
                InitCommand=function(self) self:x(-294):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Simply_I (doubleres).png"))..{ -- I
                InitCommand=function(self) self:x(-176):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.1) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Simply_M (doubleres).png"))..{ -- M
                InitCommand=function(self) self:x(-49):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 2):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.2) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Simply_P (doubleres).png"))..{ -- P
                InitCommand=function(self) self:x(84):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 3):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.3) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Simply_L (doubleres).png"))..{ -- L
                InitCommand=function(self) self:x(211):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 4):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.4) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Simply_Y (doubleres).png"))..{ -- Y
                InitCommand=function(self) self:x(294):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 5):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.5) end end,
            },
        },
        
        -- "Spud" AF
        Def.ActorFrame{
            InitCommand=function(self) self:y(89-100) end,
            OffCommand=function(self) self:finishtweening() end,
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Spud_S (doubleres).png"))..{ -- S
                InitCommand=function(self) self:x(-271):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 3):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.1) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Spud_P (doubleres).png"))..{ -- P
                InitCommand=function(self) self:x(-96):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 4.66):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.2) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Spud_U (doubleres).png"))..{ -- U
                InitCommand=function(self) self:x(87):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 6.33):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.3) end end,
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/Logo/Spud_D (doubleres).png"))..{ -- D
                InitCommand=function(self) self:x(269):diffusealpha(0) end,
                AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 8):decelerate(logo_tween_time):addy(100):diffusealpha(1) if AllowThonk() then self:bounce():effectoffset(0.4) end end,
            },
        },
        
        -- Zoomy spud logo
        LoadActor(THEME:GetPathG("", "_VisualStyles/Potato/TitleMenu (doubleres).png"))..{
            InitCommand=function(self) self:diffusealpha(0) end,
            AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 7.5 + logo_tween_time):diffusealpha(0.3):decelerate(0.5):diffusealpha(0):zoom(1.5) end,
        },
    }
else
    -- Use the old logo-handling method for non-potato styles
    af[#af+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/"..image.." (doubleres).png"))..{
        InitCommand=function(self) self:x(2):zoom(0.7):shadowlength(0.75) end,
        OffCommand=function(self) self:linear(0.5):shadowlength(0) end
    }
end

-- SM version, SL version, song stats
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:zoom(0.8):y(-120):diffusealpha(0) end,
	AnimateLogoCommand=function(self) self:sleep(logo_tween_offset * 8 + logo_tween_time):linear(0.4):diffusealpha(1) end,

	LoadFont("Common Normal")..{
		--Text=sm_version .. "       " .. sl_name .. (sl_version and (" v" .. sl_version) or ""),
		Text=sm_version,
		InitCommand=function(self) self:y(-20):diffuse(TextColor) end,
	},
	LoadFont("Common Normal")..{
		--Text=SongStats,
		Text=sl_name .. (sl_version and (" v" .. sl_version) or ""),
		InitCommand=function(self) self:diffuse(TextColor) end,
	}
}

-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then
	af[#af+1] = Def.Sprite{
		Texture=THEME:GetPathB("ScreenTitleMenu", "underlay/hat.png"),
		InitCommand=function(self) self:zoom(0.225):xy( 130, -self:GetHeight()/2 ):rotationz(15):queuecommand("Drop") end,
		DropCommand=function(self) self:sleep(logo_tween_offset * 3):decelerate(1.333):y(-100) end,
	}
end

af[#af+1] = LoadActor("../SplashText.lua", video_games)

return af