local player = ...

local meterFillLength = 136
local meterFillHeight = 18
local meterXOffset = _screen.cx + (player==PLAYER_1 and -1 or 1) * WideScale(238, 288)

local newBPS, oldBPS
local swoosh, move

local Update = function(self)

	newBPS = GAMESTATE:GetSongBPS()
	move = (newBPS*-1)

	if GAMESTATE:GetSongFreeze() then move = 0 end
	if swoosh then swoosh:texcoordvelocity(move,0) end

	oldBPS = newBPS
end

local meter = Def.ActorFrame{

	InitCommand=function(self) self:y(20):SetUpdateFunction(Update):visible(false) end,
	OnCommand=function(self) self:visible(true) end,

	-- frame
	Border(meterFillLength+4, meterFillHeight+4, 2)..{
		InitCommand=function(self) self:x(meterXOffset) end
	},

	-- // start meter proper //
	Def.Quad{
		Name="MeterFill";
		InitCommand=function(self) self:zoomto(0,meterFillHeight):diffuse(PlayerColor(player)):horizalign(left) end,
		OnCommand=function(self) self:x( meterXOffset - meterFillLength/2 ) end,

		-- check state of mind
		HealthStateChangedMessageCommand=function(self,params)
			if(params.PlayerNumber == player) then
				if(params.HealthState == 'HealthState_Hot') then -- Lifebar full = (almost) white
					self:diffuse(color("0.8,0.8,0.8,1"))
				elseif params.HealthState == 'HealthState_Dead' then -- Lifebar gone = red (also fill set the bar to fill the meter)
                    self:diffuse(color("0.35,0,0,1"))
                    self:decelerate(0.4):zoomx(meterFillLength)
                else -- Lifebar somewhere in between = player-colored
					self:diffuse(PlayerColor(player))
				end
			end
		end,

		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == player) then
				local life = params.LifeMeter:GetLife() * (meterFillLength)
				self:finishtweening()
				self:bouncebegin(0.1):zoomx( life )
			end
		end,
        
        
	},

	LoadActor("swoosh.png")..{
		Name="MeterSwoosh",
		InitCommand=function(self)
			swoosh = self

			self:zoomto(meterFillLength,meterFillHeight)
				 :diffusealpha(0.2)
				 :horizalign( left )
		end,
		OnCommand=function(self)
			self:x(meterXOffset - meterFillLength/2);
			self:customtexturerect(0,0,1,1);
			--texcoordvelocity is handled by the Update function below
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if(params.PlayerNumber == player) then
				if(params.HealthState == 'HealthState_Hot') then
					self:diffusealpha(1)
				else
					self:diffusealpha(0.2)
				end
			end
		end,
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == player) then
				local life = params.LifeMeter:GetLife() * (meterFillLength)
				self:finishtweening()
				self:bouncebegin(0.1)
				self:zoomto( life, meterFillHeight )
			end
		end
	}
}

return meter

-- copyright 2008-2012 AJ Kelly/freem.
-- do not use this code in your own themes without my permission.