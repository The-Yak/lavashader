
local versionNum = '0.11a'

function widget:GetInfo()
  return {
    name      = "Ambient Player",
    desc      = "v"..(versionNum).." modified ambient sound mixed for lavamaps",
    author    = "Klon, The_Yak",
    date      = "dez 2014",
    license   = "GNU GPL, v2 or later",
    layer     = -1,
    enabled   = true,
  }
end	

local PLAYLIST_FILE = 'LuaUI/sounds/ambient/ambientplaylist.lua'

local PlaySound= Spring.PlaySoundFile
local PlayStream= Spring.PlaySoundStream
local Echo = Spring.Echo
local random=math.random

local updateIntervalSeconds = 29
local secondsToUpdate = 0.1
--local gameStarted = Spring.GetGameFrame() > 0

local tracks
local ambientVolume


function widget:Initialize()	
	if VFS.FileExists(PLAYLIST_FILE, VFS.RAW_FIRST) then
		if (Spring.LoadSoundDef(PLAYLIST_FILE)) then
			--Echo("Loaded Ambient Sound Defs successfully")
		end
		local tracklist = {}
		tracklist,ambientVolume = VFS.Include(PLAYLIST_FILE, nil, VFS.RAW_FIRST)		
		ambientVolume = ambientVolume or 1.0
		
		if (tracklist.Sounditems == nil) then
			Echo("<ambient player>: playlist was empty")
			Destroy()
			return
		else
			tracks=tracklist.Sounditems
		end
	else
		Echo("<ambient player>: no playlist found")
		Destroy()
		return
	end
end



function widget:Destroy()	
end

--Screw this line, we want ambient noise as soon as the game starts
--function widget:GameStart()
--	gameStarted = true
--end

function widget:Update(dt) 	
	--Screw this line, we want ambient noise as soon as the game starts
	--if not (gameStarted) then return end
	
	if (secondsToUpdate>0) then
		secondsToUpdate=secondsToUpdate-dt
		return
	else
		secondsToUpdate=updateIntervalSeconds
	end
	
	local track = 1
	local params = tracks['lavaambient'..track];
	
	--local windSpeed = Spring.GetGameRulesParam("WindStrength");
	--if windSpeed == nil then
	--	_,_,_,springWindSpeed = Spring.GetWind();
	--	windSpeed = springWindSpeed/4;
	--else
	--	windSpeed = 0.2 + windSpeed * 2.5;
	--end
	
	--if you want to use windspeed as a volume modifier
	--PlaySound(params.name, windSpeed) 
	PlaySound(params.name, 0.35)
end

