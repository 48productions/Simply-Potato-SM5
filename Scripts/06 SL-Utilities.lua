------------------------------------------------------------
-- 06 SL-Utilities.lua
-- Utility Functions for Development
--
-- The filename starts with "06" so that it loads before other SL scripts that rely on
-- global functions defined here.  For more information on this numbering system that
-- pretty much no one uses, see: ./Themes/_fallback/Scripts/hierarchy.txt

------------------------------------------------------------
-- define helper functions local to this file first
-- global utility functions (below) will depend on these
------------------------------------------------------------

-- TableToString_Recursive() function via:
-- http://www.hpelbers.org/lua/print_r
-- Copyright 2009: hans@hpelbers.org
local function TableToString_Recursive(t, name, indent)
	local tableList = {}

	function table_r (t, name, indent, full)
		local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
		local tag = indent .. id .. ' = '
		local out = {}	-- result

		if type(t) == "table" then
			if tableList[t] ~= nil then
				table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
			else
				tableList[t]= full and (full .. '.' .. id) or id
				if next(t) then -- Table not empty
					table.insert(out, tag .. '{')
					for key,value in pairs(t) do
						table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
					end
					table.insert(out,indent .. '}')
				else
					table.insert(out,tag .. '{}')
				end
			end
		else
			local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
			table.insert(out, tag .. val)
		end

		return table.concat(out, '\n')
	end

	return table_r(t,name or 'Value',indent or '')
end


function table.val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )

		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
			return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and table.tostring( v ) or tostring( v )
	end
end

function table.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
end

function table.tostring( tbl )
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, table.val_to_str( v ) )
    	done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] then
			table.insert( result, "\t" .. table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
		end
	end
	return "{\n" .. table.concat( result, ",\n" ) .. "\n}"
end


------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS
-- use these to assist in theming/scripting efforts
------------------------------------------------------------

-- SM()
-- Shorthand for SCREENMAN:SystemMessage(), this is useful for
-- rapid iterative testing by allowing us to print variables to the screen.
-- If passed a table, SM() will use the TableToString_Recursive (from above)
-- to display children recursively until the SystemMessage spills off the screen.
function SM( arg )

	-- if a table has been passed in
	if type( arg ) == "table" then

		-- recursively print its contents to a string
		local msg = TableToString_Recursive(arg)
		-- and SystemMessage() that string
		SCREENMAN:SystemMessage( msg )
	else
		SCREENMAN:SystemMessage( tostring(arg) )
	end
end


-- range() accepts one, two, or three arguments and returns a table
-- Example Usage:

-- range(4)			--> {1, 2, 3, 4}
-- range(4, 7)		--> {4, 5, 6, 7}
-- range(5, 27, 5) 	--> {5, 10, 15, 20, 25}

-- either of these are acceptable
-- range(-1,-3, 0.5)	--> {-1, -1.5, -2, -2.5, -3 }
-- range(-1,-3, -0.5)	--> {-1, -1.5, -2, -2.5, -3 }

-- but this just doesn't make sense and will return an empty table
-- range(1, 3, -0.5)	--> {}

function range(start, stop, step)
	if start == nil then return end

	if not stop then
		stop = start
		start = 1
	end

	step = step or (start < stop and 1 or -1)

	-- if step has been explicitly provided as a positive number
	-- but the start and stop values tell us to decrement
	-- multiply step by -1 to allow decrementing to occur
	if step > 0 and start > stop then
		step = -1 * step
	end

	local t = {}
	while start < stop+step do
		t[#t+1] = start
		start = start + step
	end
	return t
end

-- pass in a range of time values in seconds and get back a table of stringified
-- values formatted as minutes and seconds.
--
-- for example usage, see the MenuTimer OptionRows defined in ./Scripts/99 SL-ThemePrefs.lua
function SecondsToMMSS_range(start, stop, step)
	local ret = {}
	local range = range(start, stop, step)
	for v in ivalues(range) do
		ret[#ret+1] = SecondsToMMSS(v):gsub("^0*", "")
	end
	return ret
end


-- stringify() accepts an indexed table, applies tostring() to each element,
-- and returns the results.  sprintf style format can be provided via an
-- optional second argument.  Note that this function will remove key/value pairs
-- if any are passed in via "tbl".
--
-- Example:
-- 		local blah = stringify( {10, true, "hey now", asdf=10} )
-- Result:
-- 		blah == { "10", "true", "hey now" }
--
-- For an example with range()
-- see Mini in ./Scripts/SL-PlayerOptions.lua
function stringify( tbl, form )
	if not tbl then return end

	local t = {}
	for _,value in ipairs(tbl) do
		t[#t+1] = (type(value)=="number" and form and form:format(value) ) or tostring(value)
	end
	return t
end

-- iterates over a numerically-indexed table (haystack) until a desired value (needle) is found
-- if found, return the index (number) of the desired value within the table
-- if not found, return nil
function FindInTable(needle, haystack)
	for i = 1, #haystack do
		if needle == haystack[i] then
			return i
		end
	end
	return nil
end

-- i'm learning haskell okay? map is nice -ian5v
function map(func, array)
	local new_array = {}
	for i,v in ipairs(array) do
		new_array[i] = func(v)
	end
	return new_array
end

-- Returns a copy of a given table
function table.copy(tbl)
	local tbl2 = {}
	for k, v in pairs(tbl) do
		tbl2[k] = v
	end
	return tbl2
end



--Parses a string for a date, returns a table formatted as {year, month, day}
function parseDate(opt_date)
    local ret = {}
    local i = 1
    for str in string.gmatch(opt_date, "[^/]+") do --Split our input string at each /, then convert each substring to a number and store it in a table
    
        ret[i] = tonumber(str)
        if ret[i] == nil or ret[i] < 1 then return nil end --Ensure the value we got from tonumber is actually a number and is greater than 1 (check against month -1 lol)
        i = i + 1
    end
    
    if #ret == 3 and ret[1] <= 12 and ret[2] <= 31 then --Simple validation: We should have three numbers here, and the month and day should be at least *somewhat* feasible
        --return {ret[3],ret[1],ret[2]}
        return (ret[3] * 10000) + (ret[1] * 100) + ret[2]
    else
        return nil
    end
end


--Checks if news entry opt with an id of id is valid on cur_date, also factors in a player's max_news value if applicable
function checkValidNews(cur_date, news_path, max_news, id, opt)
    --First: If max_news is specified, we're displaying news to a player on game start and shouldn't show them news they've already seen
    --If this is the case, we'll run two extra checks: Is this news newer than the newest news they've been shown (max_news)? And is this news NOT limited to attract mode showings only?
    if max_news == nil or (id > max_news and opt.ShowToPlayer) then
    
        --If max_news isn't specified (showing in attract mode), make sure showing in attract mode isn't disabled
        if max_news == nil and opt.DisableAttractShow then return nil end
    
        --Next: Does this entry have all the needed values, and does the image it specifies actually exist?
        if opt.File and opt.StartDate and opt.EndDate and FILEMAN:DoesFileExist(news_path .. opt.File) then
                    
            --Last: Is this news valid on the current date?
            local start_date = parseDate(opt.StartDate)
            local end_date = parseDate(opt.EndDate)
            
            --Check if we parsed our start and end dates correctly, then make sure the current date is between those two dates
            if start_date ~= nil and end_date ~= nil and start_date <= cur_date and end_date >= cur_date then
            
                --If we've gotten to this point without returning: Good news, everyone!
                --We have valid news to display! Return the corresponding image
                
                if max_news ~= nil then --If max news is specified, set the max news seen values for all joined players
                    if GAMESTATE:IsSideJoined(PLAYER_1) then SL.P1.ActiveModifiers.MaxNewsSeen = id end
                    if GAMESTATE:IsSideJoined(PLAYER_2) then SL.P2.ActiveModifiers.MaxNewsSeen = id end
                end
                return "News/" .. opt.File
            else
                --SM(start_date..cur_date..end_date)
                return nil
            end
            
        end
    end
    --SM(idS..id..max_news)
    return nil --This news entry isn't valid
end


--Returns a path to the latest and greatest valid news image. Accounts for the following:

-- - News that is set to start after/end before the current date will not be shown
-- - If max_news is specified (not nil), news with an ID <= max_news will not be shown
-- - If no valid news is found (or all news entries have config errors), nil is returned
function getNewsImg(max_news)
    local news_path = THEME:GetCurrentThemeDirectory() .. "Other/News/" --The path the news config/images are in
    local config = nil --The news config file
    
    if FILEMAN:DoesFileExist(news_path.."/news.ini") then --Does news.ini exist? Try loading it
        config = IniFile.ReadFile(news_path.."news.ini")
        if config then --Loaded the news config, now see what news exists:tm:
            --Get the current date
            local cur_date = (Year() * 10000) + ((MonthOfYear() + 1) * 100) + DayOfMonth()
            
            --Now iterate through the news entries to find news to display:
            
            --First, get an array of all the news entry ids in the config. We'll sort this later so we can iterate through them.
            --(Code shamelessly stolen from SM's 01 IniFile.lua, modified so we can iterate backwards through our config. Also makes stopping the loop once we find valid news easier)
            local entry_keys = {}
            for key, val in pairs(config) do
                local num_key = tonumber(key)
                if num_key ~= nil then entry_keys[num_key] = key end --The keys (news entries) in our table can be numbers that are secretly strings. Store our real news keys (strings) in this array under the index of the number version of the key
            end
             --Now reverse-sort this key table...
            table.sort(entry_keys, function(a,b) return a > b end)
            
            --...and iterate through it
            for i, id in ipairs(entry_keys) do
                local opt = config[id]
                
                --Check if this news id is valid, return it if it is
                local img = checkValidNews(cur_date, news_path, max_news, tonumber(id), opt)
                if img then return img end
                
            end --Loop news entry iteration
            
        end
    end
    
    return nil --At this point there's no valid news :(
end


-- Returns true if we should apply thonk mode effects (this can be the case even if the current visual theme is not thonk, mostly for april fool's)
function AllowThonk()
 return ThemePrefs.Get("VisualTheme") == "Thonk" or getenv("ForceThonk") == true
end

-- Allows thonk mode to be selected on ScreenSelectStyle. Returns true if either condition is met:
--  - We are within a week of april fool's day
--  - The konami code was entered on the title screen (env "AllowThonk" is true)
function AllowAF()
    return (MonthOfYear()==3 and DayOfMonth()>=1 and DayOfMonth() <= 7 and PREFSMAN:GetPreference("EasterEggs")) or getenv("AllowAF") == true
end

--I LOVE VIDEO GAMES (changes splash text and title screen arrow positions on ScreenTitleMenu/TitleJoin and ScreenLogo)
function SPLovesVideoGames()
	return (GAMESTATE:GetCurrentGame():GetName() == "dance" and PREFSMAN:GetPreference("EasterEggs") and math.random(1,100) <= 5 )
end