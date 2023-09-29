
local gfx <const> = playdate.graphics

local numDivisions = 2
local animTime = 300
local finalRadius = 200
local startThickness = 6
local endThickness = 0

class('ArcDeathEffect').extends()
function ArcDeathEffect:init(circleCenter, circleRadius)
    ArcDeathEffect.super.init(self)

    self.circleCenter = circleCenter
    self.circleRadius = circleRadius
    self.arcs = {}
end

function ArcDeathEffect:addArcEffect(startArc)
    local bigArcStart = startArc.arc.startAngle
    local bigArcEnd = startArc.arc.endAngle

    if(bigArcEnd < bigArcStart)then
        bigArcEnd += 360 -- just to keep calculations easy
    end

    local firstCut = playdate.math.lerp(bigArcStart, bigArcEnd, RandFloat(.1, .4))
    self:addSubArc(bigArcStart, firstCut)
    local secondCut = playdate.math.lerp(bigArcStart, bigArcEnd, RandFloat(.6, .9))
    self:addSubArc(firstCut, secondCut)
    self:addSubArc(secondCut, bigArcEnd)
end

function ArcDeathEffect:addSubArc(angleStart, angleEnd)
    local subArc = {}
    subArc.arc = playdate.geometry.arc.new(self.circleCenter.x,self.circleCenter.y,self.circleRadius,angleStart, angleEnd)
    subArc.midPoint = GetAngleWrappedMidpoint(angleStart, angleEnd)
    subArc.alive = true
    subArc.thickness = startThickness

    subArc.radiusTimer = playdate.timer.new(animTime-50, self.circleRadius, finalRadius) -- the -50 is a quick hack toendAngleTimer avoid some artifacts from the other timers
    subArc.radiusTimer.updateCallback = function (timer)
        subArc.arc.radius = timer.value
        print(timer.value)
    end
    subArc.radiusTimer.timerEndedCallback = function (timer)
        subArc.alive = false
    end

    subArc.thicknessTimer = playdate.timer.new(animTime, startThickness, endThickness)
    subArc.thicknessTimer.updateCallback = function (timer)
        subArc.thickness = timer.value
    end

    subArc.startAngleTimer = playdate.timer.new(animTime, angleStart, subArc.midPoint)
    subArc.startAngleTimer.updateCallback = function (timer)
        subArc.arc.startAngle = timer.value
    end

    subArc.endAngleTimer = playdate.timer.new(animTime, angleEnd, subArc.midPoint)
    subArc.endAngleTimer.updateCallback = function (timer)
        subArc.arc.endAngle = timer.value
    end

    table.insert(self.arcs, subArc)
end

function ArcDeathEffect:update()
    for i, arc in ipairs(self.arcs) do
        if(arc.alive == false)then
            self.arcs[i] = nil
        end
    end


end

function ArcDeathEffect:draw()
    for i, arc in ipairs(self.arcs) do
        if(arc == nil) then
            print("nil")
        else
            gfx.setLineWidth(arc.thickness)
            gfx.drawArc(arc.arc)
        end
    end
end