import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local bounceLeeway = 3 --you can miss the platforms by this amount
local spawnExpandSpeed = 1000 --milliseconds
local spawnSizeOffset = 2

class('PlatformArc').extends()
function PlatformArc:init(x, y, radius, startAngle, endAngle)
    PlatformArc.super.init(self)
    
    self.circleRadius = radius
    self.circleCenter = playdate.geometry.point.new(x,y)
    self.midPoint = self:GetMidpoint(startAngle, endAngle)
    self.size = self:GetSize(startAngle, endAngle)
    self.currentHalfSize = 1
    self.startHalfSize = 1
    self.targetHalfSize = self.size / 2.0
    self.animateTimer = playdate.timer.new(spawnExpandSpeed, self.currentHalfSize, self.targetHalfSize, playdate.easingFunctions.outElastic)

    --print("Size ", self.size)
    local startStartAngle = (self.midPoint - spawnSizeOffset) % 360
    local startEndAngle = (self.midPoint + spawnSizeOffset) % 360

    self.arc = playdate.geometry.arc.new(x,y,radius,startStartAngle, startEndAngle)
    self.speed = 0
end

function PlatformArc:GetMidpoint(angle1, angle2)
    --if the 2nd angle is less than the 1st, it's wrapped, so averaging the two won't work
    --instead we just add 360 and call it good?
    if(angle2 < angle1)then
        angle2 += 360
    end
    return ((angle1 + angle2) / 2) % 360
end

function PlatformArc:GetSize(startAngle, endAngle)
    --if the 2nd angle is less than the 1st, it's wrapped, so averaging the two won't work
    --instead we just add 360 and call it good?
    if(endAngle < startAngle)then
        endAngle += 360
    end
    return ((endAngle - startAngle)) % 360
end

function PlatformArc:draw()
    gfx.drawArc(self.arc)
end

function PlatformArc:setSpeed(speed)
    self.speed = speed
end


function PlatformArc:update()
    if(self.currentHalfSize < self.targetHalfSize)then
        --print("TimerValue: ", self.animateTimer.value)
        -- local t = self.animateTimer.currentTime / spawnExpandSpeed
        -- self.currentHalfSize = playdate.math.lerp(self.startHalfSize, self.targetHalfSize, t)
        -- print(self.animateTimer.value)
        self.currentHalfSize = self.animateTimer.value
    else
        self.currentHalfSize = self.targetHalfSize
    end


    self.midPoint += self.speed

    self.arc.startAngle = self.midPoint - self.currentHalfSize
    self.arc.endAngle = self.midPoint + self.currentHalfSize
    
    --self.arc.startAngle += self.speed
    --self.arc.endAngle += self.speed
    self:clampArcAngles()
end

function PlatformArc:clampArcAngles()
    self.arc.startAngle = self.arc.startAngle % 360
    self.arc.endAngle = self.arc.endAngle % 360
    self.midPoint = self.midPoint % 360
end

function PlatformArc:isAngleInArc(angle)
    angle = angle % 360 -- incase a bigger/smaller number is passed in

    local adjustedStart = self.arc.startAngle - bounceLeeway
    local adjustedEnd = self.arc.endAngle + bounceLeeway

    --print("Angle: ", angle)
    --print("adjustedStart: ", adjustedStart)
    --print("adjustedEnd: ", adjustedEnd)
    --normal case, just check to see if angle is between start and end
    if(adjustedStart < adjustedEnd)then
        if(angle >= adjustedStart and angle <= adjustedEnd)then
            return true
        end
    else
        if(angle >= adjustedStart or angle <= adjustedEnd)then
            return true
        end
    end
    return false
end