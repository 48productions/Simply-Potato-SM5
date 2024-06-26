local noteskin = PREFSMAN:GetPreference("EditorNoteSkinP1") -- uses the editor noteskin because "default noteskin" isn't a real preference
-- TODO: give this its own theme preference???

-- Fall back to the "default" noteskin if the above noteskin can't be found (surprisingly easy to run into when switching between game modes, etc)
if not NOTESKIN:DoesNoteSkinExist(noteskin) then
    noteskin = "default"
    
    -- If "default" isn't a valid noteskin, all hope is lost in the world. Retreat!
    if not NOTESKIN:DoesNoteSkinExist(noteskin) then return Def.Actor{} end
end

local game = GAMESTATE:GetCurrentGame():GetName()
local directions

local af = Def.ActorFrame{}

if game == "dance" then directions =      {"Left", "Down", "Up", "Right", "Left", "Down", "Up", "Right"}
elseif game == "pump" then directions =   {"DownLeft", "UpLeft", "Center", "UpRight", "DownRight", "DownLeft", "UpLeft", "Center", "UpRight", "DownRight"}
elseif game == "techno" then directions = {"DownLeft", "Left", "UpLeft", "Down", "Up", "UpRight", "Right", "DownRight"}
else return Def.Actor{}
end

-- I LOVE VIDEO GAMES
if ... == 1 and game == "dance" then
	directions = {"Left", "Up", "Down", "Right", "Left", "Up", "Down", "Right"}
end

if game ~= "pump" then
	for i=0,7 do
		af[#af+1] = NOTESKIN:LoadActorForNoteSkin(directions[i+1], "Tap Note", noteskin)..{
			InitCommand=function(self)
				self:x(65 * (i-3.5))  -- IDK if they're actually centered but it looks good enough
			end
		}
	end
else for i=0,9 do 
	af[#af+1] = NOTESKIN:LoadActorForNoteSkin(directions[i+1], "Tap Note", noteskin)..{
		InitCommand=function(self)
			self:x(65 * (i-4.5))
		end
	}
	end
end

return af