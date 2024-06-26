local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local GetStepsToDisplay = LoadActor("../StepsDisplayList/StepsToDisplay.lua")
-- I feel like this surely must be the wrong way to do this...
local GlobalOffsetSeconds = PREFSMAN:GetPreference("GlobalOffsetSeconds")

local RowIndex = 1

return Def.Sprite{
	Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/PerPlayer/arrow.png"),
	Name="Cursor"..pn,
	InitCommand=function(self)
		self:visible( GAMESTATE:IsHumanPlayer(player) ):diffusealpha(0)
		self:halign( p )

		self:zoom(0.575)
		self:bounce():effectclock("beatnooffset")

		if player == PLAYER_1 then
			self:x(-142)
			self:effectmagnitude(-3,0,0)

		elseif player == PLAYER_2 then
			self:rotationz(180)
			self:x(140)
			self:effectmagnitude(3,0,0)
		end

		self:effectperiod(1)--:effectoffset( -10 * GlobalOffsetSeconds)
	end,

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then self:visible(true) end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then self:visible(false) end
	end,

	OnCommand=function(self) self:playcommand("Set") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentTrailP1ChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentTrailP2ChangedMessageCommand=function(self) self:queuecommand("Set") end,

	SetCommand=function(self)
		local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()

		if SongOrCourse then
			local AllStepsOrTrails = (GAMESTATE:IsCourseMode() and SongOrCourse:GetAllTrails()) or SongUtil.GetPlayableSteps( SongOrCourse )
			local StepsToDisplay = GetStepsToDisplay(AllStepsOrTrails)[1]
			local CurrentStepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)



			for i,chart in pairs(StepsToDisplay) do
				if chart == CurrentStepsOrTrail then
					RowIndex = i
					break
				end
			end
			self:stoptweening():smooth(0.05):diffusealpha(1)
		else
			self:stoptweening():smooth(0.05):diffusealpha(0)
		end

		-- keep within reasonable limits because Edit charts are a thing
		RowIndex = clamp(RowIndex, 1, 5)

		-- update cursor y position
		local sdl = self:GetParent():GetParent():GetChild("StepsDisplayListAF"):GetChild("StepsDisplayList")
		if sdl then
			local grid = sdl:GetChild("Grid")
			self:y(sdl:GetY() + grid:GetY() + grid:GetChild("Blocks_"..RowIndex):GetY() + 1 )
		end
	end
}
