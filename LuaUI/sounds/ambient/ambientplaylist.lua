
--sounditem definition file, format is same as sounds.lua in <game folder>/gamedata, but some custom parameters are added that are used
--only be the ambient player

-- rnd: sound is played once this many seconds, on average. 1 means always (loop), 0 or negative means never

-- length: length of the track in seconds, if you want a track to be played multiple times in parallel, 
-- enter something lower than the actual length, or set the offset to negative
-- you also might want to set this to somewhat lower than the actual size for seamless transition of loops
-- (warning: do not set this to 0 with looped tracks)

-- offset: seconds before this track is played wether its looped or random, for the most part this will just be added to the track length
-- when considering if its eligible to be played
-- (can be negative)

local folder = "LuaUI/sounds/ambient/"
local ambientVolume = 7.0

SoundItems = {}
for i=1,8 do
	local j = tostring(i);
	local name = "lavaambient"..j;
	local SoundItem = {
		name = name,
		file = folder..name..".ogg",
		gain = 0.2,
		pitch = 1.0,
		pitchMod = 0,
		gainMod = 0.075,
		priority = 1,
		maxconcurrent = 2, 
		maxdist = FLT_MAX, 
		preload = true,
		in3d = true,
		rolloff = 0,
		rnd = 1,
		offset = 0,
		length = 78,
	}
	
	SoundItems[name] = SoundItem;
end

local Sounds = {
	Sounditems = SoundItems
}

return Sounds, ambientVolume
