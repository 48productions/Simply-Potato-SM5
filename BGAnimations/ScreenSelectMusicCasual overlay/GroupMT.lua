local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local TransitionTime = args[3]
local steps_type = args[4]
local row = args[5]
local col = args[6]
local Input = args[7]

local switch_to_songs = function(group_name)
	local songs = {}
	local current_song = GAMESTATE:GetCurrentSong()
	local index = 1

	-- prune out songs that don't have valid steps
	for i,song in ipairs(SONGMAN:GetSongsInGroup(group_name)) do
		if current_song == song then index = i end

		if song:HasStepsType(steps_type) then
			songs[#songs+1] = song
		end
	end

	songs[#songs+1] = "CloseThisFolder"

	SongWheel:set_info_set(songs, index)
end


local item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			-- this is a terrible way to do this
			local item_index = name:gsub("item", "")
			self.index = item_index
			self.column = ((item_index-1) % col.how_many) + 1

			self.static_row = math.ceil((item_index/col.how_many)-1) % row.how_many + 1
			self.changing_row = self.static_row

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself

					subself:x(col.w * self.column)
					subself:y(row.h * (self.changing_row-1))

					if GAMESTATE:GetCurrentSong() then

						if self.index ~= GroupWheel:get_actor_item_at_focus_pos().index then
							subself:playcommand("LoseFocus"):diffusealpha(0)
						else
							-- position this folder in the header
							subself:playcommand("GainFocus"):xy(70,35):zoom(0.35)

							switch_to_songs(GAMESTATE:GetCurrentSong():GetGroupName())
							MESSAGEMAN:Broadcast("SwitchFocusToSongs")
						end
					else
						-- hide the outmost two rows
						if self.changing_row <= 0 or self.changing_row == math.ceil(GroupWheel.num_items/col.how_many) - 1 then
							subself:diffusealpha(0)
						end
					end
				end,
				OnCommand=function(subself) subself:finishtweening() end,

				StartCommand=function(subself)
					-- hide everything but the chosen Actor
					if self.index ~= GroupWheel:get_actor_item_at_focus_pos().index then
						subself:linear(0.2)
						subself:diffusealpha(0)
					else
						-- slide the chosen Actor into place
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					end
				end,
				UnhideCommand=function(subself)
					-- we're going back to group selection
					-- slide the chosen group Actor back into grid position
					if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToGroups")
					end

					-- only unhide the middle rows, of course
					if self.changing_row > 0 and self.changing_row ~= math.ceil(GroupWheel.num_items/col.how_many) - 1 then
						subself:sleep(0.3)
						subself:linear(0.2)
						subself:diffusealpha(1)
					end

				end,
				GainFocusCommand=cmd(linear,0.2; zoom,0.8),
				LoseFocusCommand=cmd(linear,0.2; zoom,0.6),
				SlideToTopCommand=cmd( linear, 0.12; y, 35; zoom, 0.35; linear, 0.2; x, 70; queuecommand, "Switch" ),
				SlideBackIntoGridCommand=function(subself)
					subself:linear( 0.2 ):x( self.column * col.w )
					subself:linear( 0.12 ):zoom( 0.8 ):y( row.h * self.changing_row )
				end,
				SwitchCommand=function(subself) switch_to_songs(self.groupName) end,



				LoadActor("./img/folderBack.png")..{
					Name="back",
					InitCommand=cmd(zoom,0.75),
					OnCommand=cmd(y,-10),
					GainFocusCommand=cmd(diffuse, color("#c47215")),
					LoseFocusCommand=cmd(diffuse, color("#4e4f54"))
				},

				Def.Banner{
					Name="Banner",
					InitCommand=function(subself)
						self.banner = subself
					end,
					OnCommand=cmd(playcommand,"Refresh"),
					RefreshCommand=cmd(y,-30; setsize,418,164; zoom, 0.48),
				},


				LoadActor("./img/folderFront.png")..{
					Name="front",
					InitCommand=cmd(zoom,0.75; valign,1),
					OnCommand=cmd(y, 64),
					GainFocusCommand=cmd( diffusetopedge, color("#eebc54"); diffusebottomedge, color("#7c5505"); decelerate,0.33; rotationx,50; ),
					LoseFocusCommand=cmd( diffusebottomedge, color("#6d6e73"); diffusetopedge, color("#6d6e73"); decelerate,0.15; rotationx,0; ),
				},

				-- group text
				Def.BitmapText{
					Font="_miso",
					InitCommand=function(subself) self.bmt = subself end,
					OnCommand=function(subself)
						if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
							subself:horizalign(left):diffuse(Color.Black):xy(150,-6):zoom(3)
						end
					end,
					GainFocusCommand=cmd(x, 0; horizalign, center; linear, 0.15; y,16; zoom,1.1),
					LoseFocusCommand=cmd(x, 0; horizalign, center; linear, 0.15; y, 6; zoom, 1; diffuse, Color.White),
					SlideToTopCommand=cmd(sleep, 0.3; diffuse, Color.Black; queuecommand, "SlideToTop2"),
					SlideToTop2Command=cmd(horizalign, left; linear, 0.2; xy, 150,-6; zoom, 3),
					SlideBackIntoGridCommand=cmd(horizalign, center; linear, 0.2; xy, 0,16; zoom, 1.1; diffuse, Color.White),
				}
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			if Input.WheelWithFocus ~= GroupWheel then return end

			self.container:finishtweening()

			if has_focus then
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
			end

			if self.changing_row <= 0 or self.changing_row == math.ceil(num_items/col.how_many) - 1 then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end

			self.container:y( row.h * self.changing_row )
		end,

		set = function(self, groupName)

			self.groupName = groupName

			-- handle text
			self.bmt:settext(self.groupName)

			-- handle banner
			self.banner:LoadFromSongGroup(self.groupName)
			self.banner:playcommand( "Refresh" )

			-- determine if we have row shifting to do
			local ActiveActor = GroupWheel:get_actor_item_at_focus_pos()

			-- we'll only get into this if statement once...
			if GroupWheel.ActiveRow ~= ActiveActor.static_row then
				local change = GroupWheel.ActiveRow - ActiveActor.static_row
				GroupWheel.ActiveRow = ActiveActor.static_row

				-- ... so update every item's changing_row attribute now for the transform that comes next
				for i=1,GroupWheel.num_items do
					GroupWheel.items[i].changing_row = (GroupWheel.items[i].changing_row + change) % row.how_many
				end
			end
		end
	}
}

return item_mt