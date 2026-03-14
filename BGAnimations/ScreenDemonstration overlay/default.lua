local af = Def.ActorFrame{}

--[[af[#af+1] = LoadFont("_wendy small")..{
	Text="FHDSJKFDHSJKL",
	InitCommand=function(self) self:Center():diffusealpha(0):shadowlength(1) end,
	OnCommand=function(self)
		self:wag()
	end
}]]

local song = GAMESTATE:GetCurrentSong()

--[[af[#af+1] = Def.ActorFrame{
    InitCommand=function(self) self:xy(_screen.w, _screen.h - 140):zoom(1) end,
    OnCommand=function(self) self:x(_screen.w * 0.85) end,
    
    Def.Quad{
        InitCommand=function(self)
            self:zoomto(240, 179):xy(40,15):diffuse(0,0,0,1)
        end
    },
    
    LoadFont("Common Normal")..{
        InitCommand=function(self)
            self:xy(-60, 80):zoom(1.5):diffuse(Color.White):shadowlength(0.75):horizalign(0):maxwidth(100)
            self:settext(song:GetDisplayMainTitle())
        end
    },
    
	-- Banner outline quad
	Def.Quad{
		InitCommand=function(self)
            --self:diffuse(0,0,0,0):zoomto(0,0)
            self:zoomto(128, 128):diffuseshift():effectcolor1(0.75,0.75,0.75,1):effectcolor2(0,0,0,1)
        end,
        OnCommand=function(self)
            --self:zoomto(128, 128):diffuseshift():effectcolor1(0.75,0.75,0.75,1):effectcolor2(0,0,0,1)
        end,
	},
    
	-- Banner/Jacket/etc, blatantly copied from ScreenSelectMusicCasual's SongMT.lua
	Def.Sprite{
		Name="Banner",
        InitCommand=function(self)
            local path
            if song:HasJacket() then --Go through and find *some* kind of asset to use for this
				path = song:GetJacketPath()
				img_type = "Jacket"
			elseif song:HasBackground() then
				path = song:GetBackgroundPath()
				img_type = "Background"
			elseif song:HasBanner() then
				path = song:GetBannerPath()
				img_type = "Banner"
			else
				path = nil
				img_type = nil
				if NoJacketTexture ~= nil then
					self.banner:SetTexture(NoJacketTexture)
				else
                    Load( THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/no-jacket.png") )
                    NoJacketTexture = self.banner:GetTexture()
                end
                return
            end
            
            -- thank you, based Jousway (If SM is recent enough to cache banners/etc, load from the cache)
            if (Sprite.LoadFromCached ~= nil) then
				self:LoadFromCached(img_type, path)
                
			-- support SM5.0.12 begrudgingly
			else
				self:LoadBanner(path)
			end
            self:zoomto(126, 126)
        end,
		OnCommand=function(self)
            --self:zoomto(126,126)
        end,
	},
}]]


af[#af+1] = LoadFont("_upheaval_underline 80px")..{
	InitCommand=function(self)
		self:xy(_screen.cx,_screen.h-80):zoom(0.5):shadowlength(1.7)
		self:visible(false):queuecommand("Refresh")
		if getenv("ForceThonk") == true then setenv("ForceThonk", false) end -- If we entered the thonk code on the title screen but didn't press start (AllowAF is true) or if ForceThonk is for some reason still true), disable it here
		if getenv("AllowAF") == true then setenv("AllowAF", false) end
	end,
	OnCommand=function(self)
		self:diffuseshift():effectperiod(1.333)
		self:effectcolor1(1,1,1,0):effectcolor2(1,1,1,1)
	end,
	OffCommand=function(self) self:visible(false) end,

	CoinsChangedMessageCommand=function(self) self:queuecommand("Refresh") end,
	CoinModeChangedMessageCommand=function(self) self:queuecommand("Refresh") end,

	RefreshCommand=function(self)
		self:visible( not IsHome() )

		if GAMESTATE:GetCoinMode() == "CoinMode_Free" then
		 	self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
			return
		end

		if GetCredits().Credits <= 0 then
			self:settext( THEME:GetString("ScreenLogo", "EnterCreditsToPlay") )
		else
		 	self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
		end
	end
}

return af