local NumWheelItems = 15
local Selected = false

local displayingNews = false
local news_img = nil

local tipList = {
    -- UI Navigation
    "When picking a song folder,\nthe genre and difficulty scale\nare below the folder's banner!",
    "DDR songs use a different\nrating scale for difficulties!",
    "Different folders use different\ndifficulty rating scales!",
    "A folder's difficulty rating scale\nis shown below the folder's banner!",
    "Press  &SELECT;  when picking a song\nto open the sorting menu",
    "You can sort by song name\nusing the &SELECT; button sort menu",
    "Using a USB drive? Press &SELECT; on the\nresults screen to save a screenshot",
    "Press UP + DOWN to\nclose the current folder",
    "A song's length is shown below its banner.\nSome harder songs test your stamina!",
    
    -- Charting meta
    "Some long, \"Hold\" notes are colored differently.\nTap these \"Roll\" notes repeatedly!",
    "DDR songs have a different step charting\nstyle from other folders. Which do you like more?",
    "\"Tech\"-focused songs focus on hard patterns,\nwhile \"Stamina\" songs test your endurance.",
    "Orange \"Modfile\" songs use insane scripted effects!\nUp for a challenge? Try \"Mawaruchi Surviver!\"",
    
    -- Get Involved!!!!
    "Use a USB drive to play\ncustom songs, save options, and more!",
    "You can write your own custom\nsongs/steps at home using \"StepMania\"",
    "Participate in local\nevents and tournaments!",
    "Thank your rad arcade staff!",
    "This game transforms on April Fools day.\nBe there.",
    
    -- Improvement tips!
    "Keep standing on the arrows when playing,\ntry not to return to the center!",
    "Alternating your feet after each arrow\ncan make some step patterns easier!",
    "Use either foot for any arrow!\nAdd your own flair to the dance!",
    "Practice makes perfect!\nKeep playing, and you'll improve fast!",
    "Dancing expert? Press &START; again after\npicking a song to change your options",
    "Arrows too dense to read? Try upping\nthe \"Speed Mod\" option a tad",
    "The \"Constant Arrow Speed\" option\nsets the arrow's speed to be the same regardless\nof the song's BPM",
    "The \"Screen Filter\" option darkens the\nbackground, so arrows are easier to see",
    "The \"Music Rate\" option speeds up/slows down\nthe song, great for practicing tricky steps",
    "Using only your heels/toes to hit\narrows can help with fast steps",
    "Don't be afraid to try something new!",

}

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()
		local overlay = topscreen:GetChild("Overlay")

        if event.GameButton == "Start" then
			Selected = true
            overlay:queuecommand("Finish")

		elseif event.GameButton == "Back" then
			topscreen:RemoveInputCallback(input)
			topscreen:Cancel()
		end
	end

	return false
end

local t = Def.ActorFrame{
    OnCommand=function(self)
        --If we've figured out we're not display news (in casual mode, didn't find news to display, etc),
        --Automatically skip this screen - we don't need to initialize the other stuff here just GET OUT
        if displayingNews == false then
            SCREENMAN:GetTopScreen():GetChild("Overlay"):playcommand("Finish")
        else
            SCREENMAN:GetTopScreen():AddInputCallback(input)
            if PREFSMAN:GetPreference("MenuTimer") then
                self:queuecommand("Listen")
            end
        end
        
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		if seconds <= 0 and not Selected then
			Selected = true
			--MESSAGEMAN:Broadcast("FinishNews")
            SCREENMAN:GetTopScreen():GetChild("Overlay"):playcommand("Finish")
		else
			self:sleep(0.25)
			self:queuecommand("Listen")
		end
	end,
    FinishCommand=function(self)
        self:sleep(1):queuecommand("Advance")
	end,
    AdvanceCommand=function(self)
        SCREENMAN:GetTopScreen():RemoveInputCallback(input)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
    end,
    LoadActor( THEME:GetPathS("common", "start") )..{
        Name="start_sound",
        SupportPan = false,
        IsAction = true,
        FinishCommand=function(self)
            if displayingNews then self:play() end
        end
    },
}

 --Going into a non-casual gamemode that uses the regular music wheel, play the first half of the music wheel intro animation
if SL.Global.GameMode ~= "Casual" then
    --BG
    t[#t+1] = Def.Quad{
        InitCommand=function(self)
            self:x( _screen.cx+_screen.w/4 - 1)
                :y( _screen.cy )
                :zoomto(_screen.w/2, 28 * NumWheelItems - 4)
                :diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White )
        end,
    }
    --FG
    t[#t+1] = Def.Quad{
        InitCommand=function(self)
            self:x( _screen.cx+_screen.w/4 )
                :y( _screen.cy)
                :zoomto(_screen.w/2, 28 * NumWheelItems - 4)
                :diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
        end,
    }
    --Loading text
    t[#t+1] = Def.BitmapText{
		Font="_upheaval_underline 80px",
		Text=THEME:GetString("ScreenProfileLoad","Loading Profiles..."),
		InitCommand=function(self)
			self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.5):diffusealpha(1):draworder(101):y(0)
                :xy(SL.Global.GameMode ~= "Casual" and _screen.w * .75 or _screen.cx, SL.Global.GameMode ~= "Casual" and _screen.cy or _screen.h / 6)
		end,
	}
    
    --Tip text
    t[#t+1] = Def.BitmapText{
        --Text=RNGJESUS from array, change depending on memory/non-memory
        Font="Common normal",
        Text="TIP: "..tipList[math.random(1, #tipList)],
        InitCommand=function(self)
            self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):xy(_screen.w * .75, _screen.h * 0.7):diffusealpha(0):draworder(101)
        end,
        OnCommand=function(self) self:smooth(0.2):diffusealpha(0.7) end,
        OffCommand=function(self)
            self:smooth(0.1):diffusealpha(0)
        end,
    }
    
    if GAMESTATE:IsAnyHumanPlayerUsingMemoryCard() then
    
        --Get the highest max news seen values between both players
        local max_news = math.max(SL.P1.ActiveModifiers.MaxNewsSeen, SL.P2.ActiveModifiers.MaxNewsSeen)
        news_img = getNewsImg(max_news)
        --news_img = getNewsImg(nil) --Debug: Force a fetch of the latest news
        if news_img then
            displayingNews = true
        end
        
        if news_img then
            --News image
            t[#t+1] = Def.Sprite{
                Texture=news_img and THEME:GetPathO("", news_img) or THEME:GetPathG("", "_blank.png"),
                InitCommand=function(self)
                    self:diffusealpha(0):draworder(104)
                    self:stretchto(_screen.w * 0.14 + 1, _screen.h * 0.10 + 1, _screen.w * 0.86 - 1, _screen.h * 0.82 - 1)
                end,
                OnCommand=function(self)
                    self:smooth(0.5):diffusealpha(1)
                end,
                FinishCommand=function(self)
                    self:smooth(0.15):diffusealpha(0)
                end,
            }
            
            --News BG
            t[#t+1] = Def.Quad{
                InitCommand=function(self)
                    self:zoomto(_screen.w * 0.8,0):Center():diffuse(color('#00000000')):draworder(103)
                end,
                OnCommand=function(self)
                    self:smooth(0.25):stretchto(_screen.w * 0.14, _screen.h * 0.10, _screen.w * 0.86, _screen.h * 0.82):diffusealpha(1)
                end,
                FinishCommand=function(self)
                    self:smooth(0.25):zoomto(_screen.w * 0.8,0)
                end,
            }
            
            --News BG Outline
            t[#t+1] = Def.Quad{
                InitCommand=function(self)
                    self:zoomto(_screen.w * 0.8,0):Center():diffuse(color('#cccccc00')):draworder(102)
                end,
                OnCommand=function(self)
                    self:smooth(0.25):stretchto(_screen.w * 0.14 - 1, _screen.h * 0.10 - 1, _screen.w * 0.86 + 1, _screen.h * 0.82 + 1):diffusealpha(1)
                end,
                FinishCommand=function(self)
                    self:smooth(0.25):zoomto(_screen.w * 0.8,0)
                end,
            }
            
            --"Press START to continue" text
            t[#t+1] = LoadFont("_upheaval_underline 80px")..{
                InitCommand=function(self)
                    self:xy(_screen.cx,_screen.h-65):zoom(0.5):shadowlength(1.7):settext("Press &START; to continue"):diffusealpha(0):draworder(105)
                end,
                OnCommand=function(self)
                    self:smooth(1):diffusealpha(1):diffuseshift():effectperiod(1.333):effectcolor1(1,1,1,0.3):effectcolor2(1,1,1,1)
                end,
                FinishCommand=function(self) self:smooth(0.3):diffusealpha(0) end,
            }
            
            --Screen BG
            t[#t+1] = Def.Quad{
                InitCommand=function(self)
                    self:FullScreen():draworder(101):diffuse(color('#00000000'))
                end,
                OnCommand=function(self)
                    self:smooth(0.1):diffusealpha(0.3)
                end,
                FinishCommand=function(self) self:smooth(0.1):diffusealpha(0) end,
            }
        end
    end
end

return t