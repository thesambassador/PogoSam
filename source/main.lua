import "CoreLibs/graphics"
import "CoreLibs/math"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/easing"
import "CoreLibs/animator"
import "Player"
import "PlatformArc"
import "Level"
import "soundManager"
import "utility"
import "ArcDeathEffect"

local gfx <const> = playdate.graphics
local font = gfx.font.new('font/Mini Sans 2X')

playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
gfx.setFont(font)

local level = Level()
--level.player:kill() 

function reset()
	--SoundManager:prepAndStartMusic() done in Player now
	gfx.sprite.removeAll()
	level = nil
	level = Level()
end

function playdate.gameWillPause()
	print("pause")
end

function playdate.update()

	playdate.timer.updateTimers()
	gfx.sprite.update()
	level:update()

	if(playdate.buttonJustPressed(playdate.kButtonB))then
		reset()
	end

	playdate.drawFPS(2, 224)


end