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
import "Highscore"
import "ArcDeathEffect"

local gfx <const> = playdate.graphics

local font = gfx.font.new("font/Mini Sans 2X")

if(font == nil)then
	print("failed to load font")
end


playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
gfx.setFont(font)

local level = Level()
local highscore = Highscore()
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

	--gfx.fillRoundRect(20, 60, 200, 120, 5)

	if(not level.player.alive)then
		if(not playdate.keyboard.isVisible())then
			if(playdate.buttonJustPressed(playdate.kButtonA))then
				highscore:showKeyboardForEntry(level.score, reset)

			elseif(playdate.buttonJustPressed(playdate.kButtonB))then
				reset()
			end
		end
		--highscore:drawScoreBox(3, 20)
		--highscore:drawNameBox()
	end

	
	
	--playdate.graphics.setDrawOffset(-50, 0)
	playdate.drawFPS(2, 224)

	
end