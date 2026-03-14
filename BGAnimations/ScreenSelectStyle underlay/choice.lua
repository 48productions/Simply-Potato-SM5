local args = ...
local choiceName = args[1].name
local frame_x = args[1].x
local pads = args[1].pads
local index = args[2]


local _zoom = WideScale(0.435,0.525)
local _shadow = 1
local _game = GAMESTATE:GetCurrentGame():GetName()

local drawNinePanelPad = function(color, xoffset)

	return Def.ActorFrame {

		InitCommand=function(self) self:x(xoffset) end,

		-- Split the pad into two actorframes, and apply affects to each to affect alternating panels
		-- Pad AF 1
		Def.ActorFrame {
			PulseCommand=function(self) self:diffuseramp():effectcolor1(0.7,0.7,0.7,1):effectcolor2(1,1,1,1):effectclock("bgm"):effectperiod(2) end,
			StopPulsingCommand=function(self) self:stopeffect() end,
			
			-- first row
			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(_zoom * self:GetWidth() * -1)
					self:y(_zoom * self:GetHeight() * -2)

					if _game == "pump" or _game == "techno" or (_game == "dance" and choiceName == "solo") then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},

			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(_zoom * self:GetWidth())
					self:y(_zoom * self:GetHeight() * -2)

					if _game == "pump" or _game == "techno" or (_game == "dance" and choiceName == "solo") then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},


			-- second row
			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(0)
					self:y(_zoom * self:GetHeight() * -1)

					if _game == "pump" then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},



			-- third row
			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(_zoom * self:GetWidth() * -1)
					self:y(0)

					if _game == "pump" or _game == "techno" then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},

			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(_zoom * self:GetWidth())
					self:y(0)

					if _game == "pump" or _game == "techno" then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			}
		},
		
		
		
		-- Pad AF 2
		Def.ActorFrame {
			PulseCommand=function(self) self:diffuseramp():effectcolor1(0.7,0.7,0.7,1):effectcolor2(1,1,1,1):effectclock("bgm"):effectoffset(1):effectperiod(2) end,
			StopPulsingCommand=function(self) self:stopeffect() end,
			
			-- first row
			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(0)
					self:y(_zoom * self:GetHeight() * -2)

					if _game == "dance" or _game == "techno" then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},
			
			
			
			-- second row
			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(_zoom * self:GetWidth() * -1)
					self:y(_zoom * self:GetHeight() * -1)

					if _game == "dance" or _game == "techno" then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},

			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(_zoom * self:GetWidth())
					self:y(_zoom * self:GetHeight() * -1)

					if _game == "dance" or _game == "techno" then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},
			
			
			
			-- third row
			LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom):shadowlength(_shadow)
					self:x(0)
					self:y(0)

					if _game == "dance" or _game == "techno" then
						self:diffuse(color)
					else
						self:diffuse(0.2,0.2,0.2,1)
					end
				end
			},
		}
	}
end



local af = Def.ActorFrame{
	Enabled = false,
	InitCommand=function(self)
		self:zoom(0.5):xy( frame_x, _screen.cy + WideScale(0,10) ):diffusealpha(0)

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
		self:linear(0.125):zoom(1):diffusealpha(1):playcommand("Pulse")
		if ThemePrefs.Get("VisualTheme")=="Gay" and not HolidayCheer() then
			self:effectmagnitude(0,4,0)
		else
            self:effectmagnitude(0, 8, 0)
        end
	end,
	LoseFocusCommand=function(self)
		self:linear(0.125):zoom(0.5):effectmagnitude(0,0,0):diffusealpha(self.Enabled and 0.6 or 0.25):playcommand("StopPulsing")
	end,
	EnableCommand=function(self)
        self:smooth(0.2)
		if self.Enabled then
			self:diffusealpha(0.6)
		else
			self:diffusealpha(0.25)
		end
	 end,

	LoadFont("_upheaval_underline 80px")..{
		Text=THEME:GetString("ScreenSelectStyle", choiceName:gsub("^%l", string.upper)),
		InitCommand=function(self)
			self:shadowlength(1):y(37):zoom(0.4)
		end,
	}
}

-- draw as many pads as needed for this choice
if pads ~= nil then
	for pad in ivalues(pads) do
		af[#af+1] = drawNinePanelPad(pad.color, pad.offset)..{
			OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
		}
	end
end

-- thinking emoji
if choiceName == "thonk" then
	af[#af+1] = LoadActor("thonk.png")..{
		InitCommand=function(self)
			self:zoom(_zoom * 0.9):shadowlength(_shadow):y(-35):vibrate()
		end
	}
	af[#af+1] = LoadFont("Common Normal")..{
		Text=THEME:GetString("ScreenSelectStyle", "ThonkDesc"),
		InitCommand=function(self)
			self:shadowlength(1):y(80):diffuse(0.9,0.9,0.9,0.7):zoom(0.8)
		end
	}
end

return af