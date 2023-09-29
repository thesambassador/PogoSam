
local snd = playdate.sound

SoundManager = {}

SoundManager.kSoundBounce = 'bounce'
-- SoundManager.kSoundBounce1 = 'jump_1'
-- SoundManager.kSoundBounce2 = 'jump_2'
-- SoundManager.kSoundBounce3 = 'jump_3'
SoundManager.kSoundStart= 'start'
SoundManager.kSoundDie = 'death_1'

local sounds = {}

for _, v in pairs(SoundManager) do
	sounds[v] = snd.sampleplayer.new('sound/' .. v)
end

SoundManager.sounds = sounds



--SoundManager.music = snd.fileplayer.new('audio/music_a1')

function SoundManager:playSound(name)
	self.sounds[name]:play(1)		
end


function SoundManager:stopSound(name)
	self.sounds[name]:stop()
end

function SoundManager:prepAndStartMusic()
	SoundManager:stopMusic()
	
	SoundManager.shouldPlay = true
	SoundManager.startLoops= {"sound/music_a1","sound/music_a2"}
	SoundManager.midLoops = {"sound/music_b1", "sound/music_b2"}
	SoundManager.endLoops = {"sound/music_c1", "sound/music_c2"}
	SoundManager.finalLoop = GetRandomElement(SoundManager.endLoops)
	SoundManager.musicQueue = {GetRandomElement(SoundManager.startLoops), GetRandomElement(SoundManager.midLoops), GetRandomElement(SoundManager.endLoops)}
	SoundManager.musicLoopIndex = 0

	SoundManager:playNext()
	

end

function SoundManager:playNext()
	if(SoundManager.shouldPlay)then
		SoundManager.musicLoopIndex += 1
		local fileToLoop = SoundManager.finalLoop
		if(SoundManager.musicLoopIndex <= 3)then
			fileToLoop = SoundManager.musicQueue[SoundManager.musicLoopIndex]
		end
		SoundManager.musicPlayer = snd.fileplayer.new(fileToLoop)
		SoundManager.musicPlayer:play(1)
		SoundManager.musicPlayer:setFinishCallback(function() SoundManager:playNext() end)
	end
end

function SoundManager:stopMusic()
	if(SoundManager.musicPlayer ~= nil)then
		SoundManager.shouldPlay = false
		SoundManager.musicPlayer:stop()
	end
end

function SoundManager:playMusic()
	local filePlayer = snd.fileplayer.new('sound/music_a1')
	local filePlayer2 = snd.fileplayer.new('sound/music_a2')
	filePlayer:play(1) 
	filePlayer:setFinishCallback(function () filePlayer2:play(1) end)
		
end

function SoundManager:LoopToNext(filePlayer, otherArg)
	
	filePlayer2:play(1)
end
