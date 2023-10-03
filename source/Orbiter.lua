local gfx <const> = playdate.graphics

local orbiterSize = 8
local halfSize = orbiterSize / 2

class('Orbiter').extends(gfx.sprite)
function Orbiter:init(circleCenter, circleRadius, height, startAngle)
    Orbiter.super.init(self)

    self.circleCenter = circleCenter
    self.circleRadius = circleRadius
    self.positionOnCircle = startAngle --current position in circle angle (should be between 0 and 360)
    self.positionHeight = height -- current height 
    self.orbitSpeed = .5
    if(math.random() > .5) then
        self.orbitSpeed = -self.orbitSpeed
    end
    
    self:updatePosition()
    
    self:setSize(orbiterSize,orbiterSize)
    self:setCollideRect(halfSize/2,halfSize/2,halfSize,halfSize)
    self:setTag(2)
    --self:setCollideRect(0,0,6,6)

end

function Orbiter:draw(x,y,width,height)
    local center = self:getCenterPoint()

    gfx.fillCircleAtPoint(halfSize, halfSize, halfSize)
end

function Orbiter:updatePosition()
    self.positionOnCircle += self.orbitSpeed
    self.positionOnCircle = self.positionOnCircle % 360

    local angleRads = math.rad(self.positionOnCircle)

    local height = self.circleRadius - self.positionHeight

    local x = math.sin(angleRads) * height + self.circleCenter.x
    local y = -math.cos(angleRads) * height + self.circleCenter.y

    self:moveTo(x,y)

    --print(self.positionOnCircle)
end

function Orbiter:update()
    self:updatePosition()


end
