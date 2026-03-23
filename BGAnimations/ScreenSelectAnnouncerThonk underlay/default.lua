local AnnouncerSelected = false
local af

local current_game = GAMESTATE:GetCurrentGame():GetName()
------------------------------------------------------------------------------------

local choices = {
	{
		name="No Announcer",
		desc=ScreenString("NoAnnouncer"),
		y=_screen.h*0.25,
	}
}

for i,announcer in ipairs(ANNOUNCER:GetAnnouncerNames()) do
	choices[#choices+1] = { name=announcer, y=_screen.h*0.25 + 68*i}
end

local current_index = 1

------------------------------------------------------------------------------------

-- pass in a postive integer to get the next enabled choice to the right
-- pass in a negative integer to get the next enabled choice to the left
local GetNextEnabledChoice = function(dir)
	local start = dir > 0 and current_index+1 or #choices+current_index-1
	local stop = dir > 0 and #choices+current_index-1 or current_index+1

	for i=start, stop, dir do
		local index = ((i-1) % #choices) + 1

		current_index = index
	end
end

------------------------------------------------------------------------------------

local function input(event)
	if not event or not event.PlayerNumber or not event.button then
		return false
	end

	-- normal input handling
	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			local prev_index = current_index
			GetNextEnabledChoice(event.GameButton=="MenuRight" and -1 or 1)

			for i, child in ipairs( af:GetChild("") ) do
				if i == current_index then
					child:queuecommand("GainFocus")
					af:GetChild("InfoWindow"):GetChild("AnnouncerName"):settext(choices[i].name)
					af:GetChild("InfoWindow"):GetChild("FlavorText"):playcommand("Change", {text=choices[i].desc})
				else
					child:queuecommand("LoseFocus")
				end
			end
			if prev_index ~= current_index then af:GetChild("Change"):play() end

		elseif event.GameButton == "Start" then
			AnnouncerSelected = true
			af:GetChild("Start"):play()
			af:playcommand("Finish", {PlayerNumber=event.PlayerNumber})

		elseif event.GameButton == "Back" then
			topscreen:RemoveInputCallback(input)
			topscreen:Cancel()
		end
	end

	return false
end

------------------------------------------------------------------------------------

local t = Def.ActorFrame{
	InitCommand=function(self)
		af = self
		self:queuecommand("Capture")
		self:playcommand("Enable")

		for i, child in ipairs( self:GetChild("") ) do
			if i == current_index then
				child:queuecommand("GainFocus")
			else
				child:queuecommand("LoseFocus")
			end
		end
	end,
	OnCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then
			self:queuecommand("Listen")
		end
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		if seconds <= 0 and not AnnouncerSelected then
			AnnouncerSelected = true
			self:playcommand("Finish")
		else
			self:sleep(0.25)
			self:queuecommand("Listen")
		end
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	FinishCommand=function(self, params)
		local announcer = choices[current_index].name
		
		if announcer ~= "No Announcer" then ANNOUNCER:SetCurrentAnnouncer(announcer) end
		
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

for i,choice in ipairs(choices) do
	t[#t+1] = LoadActor("./choice.lua", {choice, i} )
end

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", SupportPan=false, IsAction=true }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", SupportPan=false, IsAction=true }


-- ANNOUNCER INFO WINDOW
t[#t+1] = Def.ActorFrame{
	Name="InfoWindow",
	InitCommand=function(self) self:xy(_screen.w * 0.75, _screen.cy) end,
	
	-- Border
	Def.Quad{
		InitCommand=function(self) self:zoomto(302, 302) end
	},
	
	-- Background
	Def.Quad{
		InitCommand=function(self) self:zoomto(300, 300):diffuse(0,0,0,1) end
	},
	
	-- "Current Announcer" text
	LoadFont("_upheaval_underline 80px")..{
		Text=ScreenString("CurAnnouncer"),
		InitCommand=function(self) self:zoom(0.35):diffuse(0.8,0.8,0.8,1):y(-130) end
	},
	
	-- Announcer name
	LoadFont("_upheaval_underline 80px")..{
		Name="AnnouncerName",
		Text="",
		InitCommand=function(self) self:zoom(0.45):diffuse(PlayerColor(PLAYER_1)):y(-100):maxwidth(550) end
	},
	
	-- Flavor text
	LoadFont("common normal")..{
		Name="FlavorText",
		Text="",
		InitCommand=function(self) self:zoom(1):y(100) end,
		ChangeCommand=function(self, args)
			local text = args.text ~= nil and args.text or ""
			self:finishtweening():cropright(1):settext(text):linear(1):cropright(0)
		end,
	},
}


return t