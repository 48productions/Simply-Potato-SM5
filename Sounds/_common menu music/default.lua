local songs = {
	Hearts = "feel",
	Arrows = "cloud break",
	Bears  = "crystalis",
	Ducks  = "Xuxa fami VRC6",
	Cats   = "Beanmania IIDX",
	Spooky = "Spooky Scary Chiptunes",
	Gay    = "Mystical Wheelbarrow Journey",
	Stars  = "Shooting Star - faux VRC6 remix",
	Thonk  = "Da Box of Kardboard Too (feat Naoki vs ZigZag) - TaroNuke Remix",
	Potato = "Da Box of Kardboard Too (feat Naoki vs ZigZag) - TaroNuke Remix",
	Christmas = "HolidayCheer",
	Nov20 = "20",
	Silent = "Silent",
}

-- retrieve the current VisualTheme from the ThemePrefs system
local style = ThemePrefs.Get("MenuSong")

-- use the style to index the songs table (above)
-- and get the song associated with this VisualTheme
local file = songs[ style ]

-- if a song file wasn't defined in the songs table above
-- fall back on the song for Hearts as default music
-- (this sometimes happens when people are experimenting
-- with making their own custom VisualThemes)
if not file then file = songs.Hearts end

-- Force thonk music if thonk mode is enabled
if AllowThonk() then file = songs.Thonk end

-- Force other easter egg music as deemed needed, but ONLY if menu music isn't set to silent
if file ~= songs.Silent then
    if PREFSMAN:GetPreference("EasterEggs") and file ~= songs.Thonk then
        --  41 days remain until the end of the year (20,November)
        if MonthOfYear()==10 and DayOfMonth()==20 then file = "20" end
        -- Halloween is a holiday too
        if MonthOfYear()==9 then file = "Spooky Scary Chiptunes" end
        -- the best way to spread holiday cheer is singing loud for all to hear (Christmas)
        if MonthOfYear()==11 then file = "HolidayCheer" end
    end
end

return THEME:GetPathS("", "_common menu music/" .. file)
