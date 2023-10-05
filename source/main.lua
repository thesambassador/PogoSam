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

--local font = gfx.font.new("font/Mini Sans 2X")
local font = gfx.font.new("font/Roobert-11-Medium")

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
	highscore.showingEntry = false
	highscore.showingList = false
end



function playdate.gameWillPause()
	print("pause")
end

local kStateBeforeStart = "BeforeStart"
local kStateDuringGame = "DuringGame"
local kStateDeath = "Death"
local kStateHighScoreEntry = "HighScoreEntry"
local kStateHighScoreShow = "HighScoreShow"


local gameState = "GameBeforeStart"
local resetHoldTime = 3
local heldTime = 0.0

function playdate.update()

	playdate.timer.updateTimers()
	gfx.sprite.update()
	level:update()

	--BeforeStart
	if(level.player.alive and not level.player.gameStarted and not highscore.showingList)then
		gameState = kStateBeforeStart
		
        w, h = gfx.drawText("Ⓐ Scores", 15, 210)
       
		if(playdate.buttonJustPressed(playdate.kButtonA))then
			print("Showing it")
			level.player.alive = false
			highscore:showScoreList(true)
		end
	--DuringGame
	elseif(level.player.alive and level.player.gameStarted)then
		gameState = kStateDuringGame
	--Death
	elseif(not level.player.alive and not highscore.showingEntry and not highscore.showingList)then
		gameState = kStateDeath

		gfx.drawTextAligned("Game Over", 200, 60, kTextAlignment.center)
		gfx.drawTextAligned("Ⓐ Submit Score", 200, 100, kTextAlignment.center)
        gfx.drawTextAligned("Ⓑ Restart", 200, 140, kTextAlignment.center)

		

		if(playdate.buttonJustPressed(playdate.kButtonA))then
			highscore:showKeyboardForEntry(level.score, function ()
				highscore:showScoreList(true)
			end)
		elseif(playdate.buttonJustPressed(playdate.kButtonB))then
			reset()
		end
	--high score entry showing
	elseif(not level.player.alive and highscore.showingEntry)then
		gameState = kStateHighScoreEntry
		highscore:drawNameBox()
	--high score list showing
	elseif(not level.player.alive and highscore.showingList)then
		gameState = kStateHighScoreShow
		highscore:drawScoreBox()
		if(playdate.buttonJustPressed(playdate.kButtonB))then
			reset()
		end

		if(playdate.buttonJustPressed(playdate.kButtonA))then
			playdate.resetElapsedTime()
			print("reset")
		end

		if(playdate.buttonIsPressed(playdate.kButtonA) and playdate.buttonIsPressed(playdate.kButtonDown))then
			print(playdate.getElapsedTime())
			if(playdate.getElapsedTime() > resetHoldTime)then
				playdate.resetElapsedTime()
				highscore:resetScores()
				resetHoldTime = 5000
			end
		end

		if(playdate.buttonJustReleased(playdate.kButtonA))then
			resetHoldTime = 3
		end
	end
	--print(gameState)
	-- if(not level.player.alive)then
	-- 	if(not playdate.keyboard.isVisible())then
	-- 		if(playdate.buttonJustPressed(playdate.kButtonA))then
	-- 			highscore:showKeyboardForEntry(level.score, reset)

	-- 		elseif(playdate.buttonJustPressed(playdate.kButtonB))then
	-- 			reset()
	-- 		end
	-- 	end
	-- 	--highscore:drawScoreBox(3, 20)
	-- 	--highscore:drawNameBox()
	-- end

	
	
	--playdate.graphics.setDrawOffset(-50, 0)
	--playdate.drawFPS(2, 224)

	
end