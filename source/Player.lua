
local gfx <const> = playdate.graphics

class('Player').extends(gfx.sprite)
function Player:init(circleCenter, circleRadius)
    Player.super.init(self)

    self.playerImage = gfx.image.new('images/pogoguy')
    self:setImage(self.playerImage)

    self.width, self.height = self:getSize()
    --print("Width: " .. self.width .. " Height: " .. self.height)

    self:setCollideRect(5, 4, 6, 6)

    self.circleCenter = circleCenter
    self.circleRadius = circleRadius

    self.positionOnCircle = 180.0 --current position in circle angle (should be between 0 and 360)
    self.positionHeight = 40.0 -- current height (start high)
    self.alive = true

    self.gravity = 8.0 / 50.0
    self.bounceStrength = 244 / 50.0
    self.bounceTimer = playdate.timer.new(10000)

    
    self.jumpAnimator = playdate.graphics.animator.new(600, -1, 70, playdate.easingFunctions.outCubic)
    self.jumpAnimator.repeatCount = -1
    self.jumpAnimator.reverses = true
    
   
    
    self.justBounced = false;


    self.yVelocity = 0.0
    self:setTag(1)

end

function Player:bounce()
    -- print("Airtime: ", self.bounceTimer.currentTime)
    -- self.bounceTimer:reset()
    -- self.bounceTimer:start()
    

    -- if(self.positionHeight < 0) then
    --     self.positionHeight = 0
    -- end
    -- self.yVelocity = self.bounceStrength

    -- local randSound = math.random(1,3)
    -- local soundName = SoundManager.kSoundBounce1
    -- print(randSound)
    -- if(randSound == 2) then
    --     soundName = SoundManager.kSoundBounce2
    -- elseif(randSound == 3) then
    --     soundName = SoundManager.kSoundBounce3
    -- end
    self.justBounced = true
    SoundManager:playSound(SoundManager.kSoundBounce)
end

function Player:updateInput()
    local cranked = playdate.getCrankChange()
    self.positionOnCircle += cranked
    self.positionOnCircle = self.positionOnCircle % 360
end

function Player:updatePosition()
    self.yVelocity -= self.gravity
    self.positionHeight += self.yVelocity
    self.positionHeight = self.jumpAnimator:currentValue()

    if(self.positionHeight > 20)then
        self.justBounced = false --prevent dying right after bouncing on a platform
    end
    --print("Height: ", self.positionHeight)

    --print("POS: " , self.positionHeight)

    local angleRads = math.rad(self.positionOnCircle)

    local height = self.circleRadius - self.positionHeight

    local x = math.sin(angleRads) * height + self.circleCenter.x
    local y = -math.cos(angleRads) * height + self.circleCenter.y

    self:moveTo(x,y)

    --print(self.positionHeight)

    self:setRotation(self.positionOnCircle + 180)
    --print(self.positionOnCircle)
end


function Player:kill()
    self.alive = false;
    SoundManager:playSound(SoundManager.kSoundDie)
    SoundManager:stopMusic()
    --self.jumpAnimator:remove()
    self:remove()
end

function Player:update()
    self:updateInput()

    self:updatePosition()
    


end