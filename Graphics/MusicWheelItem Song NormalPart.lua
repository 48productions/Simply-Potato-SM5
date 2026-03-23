local af = Def.ActorFrame{
	InitCommand=function(self) self:x(26) if AllowThonk() then self:bounce():effectclock("bgm"):effectmagnitude(-20,0,0):effectperiod(1):effectoffset(1) end  end,

	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color_betweensongs)
			:zoomto(_screen.w/2.1675, _screen.h/15)
		end
	},
	Def.Quad{
		InitCommand=function(self)
			if ThemePrefs.Get("RainbowMode") then
				self:diffuse(1,1,1,0.5)
			else
				self:diffuse(color_slate4)
			end
			self:zoomto(_screen.w/2.1675, _screen.h/15 - 1)
		end
	}
}

if not GAMESTATE:IsCourseMode() then
	local game = GAMESTATE:GetCurrentGame():GetName():gsub("^%l", string.upper)
	local style = GAMESTATE:GetCurrentStyle():GetName():gsub("^%l", string.upper):gsub("Versus", "Single")
	local stepstype = "StepsType_"..game.."_"..style

	-- using a png in a Sprite ties the visual to a specific rasterized font (currently Miso),
	-- but Sprites are cheaper than BitmapTexts, so we should use them where dynamic text is not needed
	af[#af+1] = LoadActor( THEME:GetPathG("", "Has Edit (doubleres).png") )..{
		InitCommand=function(self)
			self:visible(false):x(WideScale(130,182)):zoom(0.375)
			if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,1) end
		end,
		SetCommand=function(self, params)
			self:visible(params.Song and params.Song:HasEdits(stepstype) or false)
		end
	}
end

return af
