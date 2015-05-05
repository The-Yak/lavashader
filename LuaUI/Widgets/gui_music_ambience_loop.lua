--------------------TO USE-------------------
--replace sound file with .ogg of choice, number beside it is volume, set last occurrence of timeframe to length of sound file in seconds
--------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Music/Ambience Loop",
    desc      = "Ambient lava noise for Violence",
    author    = "The_Yak",
    date      = "Oct 2013",
    license   = "GNU GPL, v2 or later",
    layer     = 5,
    enabled   = true,
  }
end	

local playSound=Spring.PlaySoundFile
local getLastUpdateSeconds=Spring.GetLastUpdateSeconds
local timeframe

function widget:Initialize()
 	timeframe=2
end

function widget:Update() 
	timeframe=timeframe -getLastUpdateSeconds() 
	if (timeframe < 0) then
		Spring.PlaySoundStream("Sounds/lavaambient.ogg",0.9)
		timeframe=78
	end
end