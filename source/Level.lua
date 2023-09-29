local gfx <const> = playdate.graphics

import 'Player'
import 'PlatformArc'
import 'Orbiter'
import "CoreLibs/graphics"
import "CoreLibs/math"
import "CoreLibs/sprites"
import "CoreLibs/object"


local circleCenter = playdate.geometry.point.new(200,120)
local circleRadius = 100
local maxDifficulty = 50

local playerHeight = 16
local halfPlayerHeight = 8

local adjustedRadius = circleRadius + halfPlayerHeight --incorporates player's height

local circleLineWidth = 2

class('Level').extends()
function Level:init()
    Level.super.init(self)

    self.numArcsAtOnce = 2
    self.minArcSize = 30
    self.maxArcSize = 40
    self.minArcSpeed = 0.0
    self.maxArcSpeed = 0.0

    self.player = Player(circleCenter, circleRadius)
    self.player:add()

    self.ArcDeaths = ArcDeathEffect(circleCenter, adjustedRadius + 3)

    self.score = 0

    self.arcs = {}
    self:makeArcs()
    self.orbiters = {}

end

function Level:drawCircle(center, rad, lineWidth)
	gfx.setLineWidth(lineWidth)
	gfx.drawCircleAtPoint(center, rad + halfPlayerHeight)

end

function Level:drawArcs()
	gfx.setLineWidth(6)
    
	for _, arc in ipairs(self.arcs) do
		arc:update()
		arc:draw()
	end
end

function Level:drawScore()
    gfx.drawText(tostring(self.score), 0, 0)
end

function Level:addNewRandomArc()
	
    local arcSize = self:randomFloat(self.minArcSize, self.maxArcSize)
    local startAngle = self:getRandomNonOverlappingArcStartLocation(arcSize)
    local endAngle = startAngle + arcSize
    local arcSpeed = self:randomFloat(self.minArcSpeed, self.maxArcSpeed)
	local endAngle = startAngle + arcSize
	local arc = PlatformArc(circleCenter.x, circleCenter.y, adjustedRadius + 3, startAngle, endAngle)
    arc:setSpeed(arcSpeed)
	table.insert(self.arcs, arc)
end

function Level:getRandomNonOverlappingArcStartLocation(newArcSize)
    local endRange = 360
    local restrictedRangeTable = {}
    for i, arc in ipairs(self.arcs) do
        local startArc = arc.arc.startAngle
        local endArc = arc.arc.endAngle
        local startInterval = startArc - newArcSize
        
        --we want to exclude the interval between (startArc - arcSize) to endArc.
        --if startInterval is negative, it means that the full interval wraps around the 0 line
        --if endRange is smaller than startInterval
        if(startInterval < 0 or endArc < startInterval)then
            --subtract the stuff from startInterval to 360 from endrange
            
            endRange -= (360 - (startInterval % 360)) 
            --now add the stuff from 0 to endRange to the interval table 
            local interval = {intervalStart = 0, intervalSize = endArc}
            table.insert(restrictedRangeTable, interval)
            endRange -= endArc

        else
            local interval = {intervalStart=startInterval, intervalSize = arc.size + newArcSize}
            table.insert(restrictedRangeTable, interval)
            endRange -= interval.intervalSize
        end
    end
    --print("Endrange: ", endRange)
   --printTable(restrictedRangeTable)

    local result = math.random() * endRange
    for i, interval in ipairs(restrictedRangeTable) do
        if(result >= interval.intervalStart)then
            result += interval.intervalSize
        end
    end

    return result
end

function Level:randomFloat(min, max)
    return min + math.random() * (max - min)
end

function Level:makeArcs()
	
	local testArc = PlatformArc(circleCenter.x, circleCenter.y, adjustedRadius + 3, 165, 195)
	table.insert(self.arcs, testArc)

	self:addNewRandomArc()

end

function Level:isAngleOverAnyArc(angle)
	for i, arc in ipairs(self.arcs) do
		if(arc:isAngleInArc(angle))then
			return i
		end
	end
	return -1
end

function Level:addOrbiter()
    local orbHeight = math.random(5, 30)
    local orbStartAngle = (self.player.positionOnCircle + 180) % 360 --make orbs spawn across from player
    local orbiter = Orbiter(circleCenter, circleRadius, orbHeight, orbStartAngle)
    orbiter:add()
    
    table.insert(self.orbiters, orbiter)
end

function Level:updateOrbiters()
    local collisions = gfx.sprite.allOverlappingSprites()
    for i = 1, #collisions do
        --print("yay")
        local collisionPair = collisions[i]
        if(collisionPair[1]:getTag() == 1 and collisionPair[2]:getTag() == 2)then
            self.player:kill()
        elseif(collisionPair[2]:getTag() == 1 and collisionPair[1]:getTag() == 2)then
            self.player:kill()
        end
    end
end

function Level:incrementScore(scoreAmount)
    self.score += scoreAmount
    --print(self.score)

    local scoreT = self.score / maxDifficulty
    if(self.score == 5 or self.score == 10 or self.score == 20)then
        --print("orbiter")
        self:addOrbiter()
    end

    if(self.score > 5)then
        self.minArcSpeed = playdate.math.lerp(.5, 1.0, scoreT)
        self.maxArcSpeed = playdate.math.lerp(1.0, 2.0, scoreT)
    end

    self.minArcSize = playdate.math.lerp(30, 5, scoreT)
    self.maxArcSize = playdate.math.lerp(40, 15, scoreT)

end

local testArc = nil
function Level:update()
    if(self.player.alive)then
        if(self.player.positionHeight <= 0)then
            local i = self:isAngleOverAnyArc(self.player.positionOnCircle)
            if(i ~= -1)then
                self.player:bounce()
                self:addNewRandomArc()
                self.ArcDeaths:addArcEffect(self.arcs[i])

                table.remove(self.arcs, i)
                self:incrementScore(1)
                

            else
                self.player:kill()
            end
        end
    else
        gfx.drawTextAligned("Game Over", 200, 100, kTextAlignment.center)
        gfx.drawTextAligned("B to Reset", 200, 140, kTextAlignment.center)
    end
    self:updateOrbiters()
    self.ArcDeaths:update()
    self:drawCircle(circleCenter, circleRadius, circleLineWidth)
	self:drawArcs()
    self:drawScore()
    self.ArcDeaths:draw()

    if(playdate.buttonJustPressed(playdate.kButtonA))then
		local test = self:getRandomNonOverlappingArcStartLocation(30)
		testArc = playdate.geometry.arc.new(circleCenter.x, circleCenter.y, circleRadius+20, test, (test+30) % 360 )
		print("Test value: ", test)
	end
    if(testArc ~= nil)then
        gfx.drawArc(testArc)
    end
    
end


