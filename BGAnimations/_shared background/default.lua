local af = Def.ActorFrame{}

-- use the "VisualTheme" ThemePrefs value to generate a proper filepath to the appropriate
-- SharedBackground texture and pass it to Normal.lua and RainbowMode.lua now as this file
-- is being initialized.

-- if the player chooses a different VisualTheme during runtime, MESSAGEMAN will broadcast
-- "BackgroundImageChanged" which we can use in Normal.lua and RainbowMode.lua to Load() the
-- newly-appropriate texture from disk into each Sprite; see also: ./BGAnimations/ScreenOptionsService overlay.lua
local file

-- With thonk mode enabled, force the thonk background. Otherwise, find the background file for the current style
if AllowThonk() then
	file = "_VisualStyles/Thonk/SharedBackground-"
else
    file = "_VisualStyles/" .. ThemePrefs.Get("VisualTheme") .. "/SharedBackground-"
end

-- In Potato (or Thonk) mode, the theme color is forced to orange and the background changes to a cool gradient
-- Additionally, this also makes holiday cheer force the theme color to blue and the background changes to an even cooler gradient
local usePotatoBG = ThemePrefs.Get("VisualTheme") == "Potato" or ThemePrefs.Get("VisualTheme") == "Thonk"

-- a simple Quad to serve as the backdrop
af[#af+1] = Def.Quad{
	InitCommand=function(self)
        self:FullScreen():Center()
        if usePotatoBG then
			if HolidayCheer() then
				self:diffuseupperleft(color("#0f00f6")):diffuselowerright(color("#5a62dc"))
					:diffuseupperright(color("#71d0ff")):diffuselowerleft(color("#e322ea"))
			else
				self:diffuseupperleft(color("#912c00")):diffuselowerright(color("#912c00"))
					:diffuseupperright(color("#a65900")):diffuselowerleft(color("#a65900"))
			end
        else
			self:diffuseupperright(GetHexColor(SL.Global.ActiveColorIndex+2)):diffuseupperleft(GetHexColor(SL.Global.ActiveColorIndex+2))
				:diffuselowerleft(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuselowerright(GetHexColor(SL.Global.ActiveColorIndex+1))
				:diffusealpha(0.4)
        end
    end,
	BackgroundImageChangedMessageCommand=function(self)
		THEME:ReloadMetrics()
		SL.Global.ActiveColorIndex = usePotatoBG and (HolidayCheer() and 5 or 11) or ThemePrefs.Get("SimplyLoveColor") -- Reload the current color from file (or force potato color in potato mode)
		self:linear(1)
        if usePotatoBG then
            if HolidayCheer() then
				self:diffuseupperleft(color("#0f00f6")):diffuselowerright(color("#5a62dc"))
					:diffuseupperright(color("#71d0ff")):diffuselowerleft(color("#e322ea"))
			else
				self:diffuseupperleft(color("#912c00")):diffuselowerright(color("#912c00"))
					:diffuseupperright(color("#a65900")):diffuselowerleft(color("#a65900"))
			end
        else
			self:diffuseupperright(GetHexColor(SL.Global.ActiveColorIndex+2)):diffuseupperleft(GetHexColor(SL.Global.ActiveColorIndex+2))
				:diffuselowerleft(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuselowerright(GetHexColor(SL.Global.ActiveColorIndex+1))
				:diffusealpha(0.4)
        end
	end,
	ColorSelectedMessageCommand=function(self)
		if not usePotatoBG then -- Recolor background based on the current color, but only in non-potato modes
			self:linear(0.5)
				:diffuseupperright(GetHexColor(SL.Global.ActiveColorIndex+2)):diffuseupperleft(GetHexColor(SL.Global.ActiveColorIndex+2))
				:diffuselowerleft(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuselowerright(GetHexColor(SL.Global.ActiveColorIndex+1))
				:diffusealpha(0.4)
		end
	end
}

-- Load the lua for each background. They set themselves as visible/invisible when needed, for better transitions between rainbow and non-rainbow mode
-- This... probably doesn't drain performance TOO much when not in use???
-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then af[#af+1] = LoadActor("./Snow.lua") end -- Overlay snow on the other backgrounds for the holidays
af[#af+1] = LoadActor("./Spud.lua", file)

return af