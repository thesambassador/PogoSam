import "CoreLibs/keyboard"

local gfx <const> = playdate.graphics

class('Highscore').extends()
function Highscore:init()
    Highscore.super.init(self)
    self.highScores = {}
    self.lastEntry = ""
    self.entryText = "___"
    self.showingEntry = false
    self.showingList = false

    self:loadScores()
end

function Highscore:loadScores()
    self.highScores = playdate.datastore.read("highscores")
    if(self.highScores == nil)then
        print("No high score file found, empty list it is")
        self.highScores = {}
    else
        print("High scores loaded")
        self:printScores()
    end
end

function Highscore:drawNameBox()
    if(playdate.keyboard.isVisible())then
        local origDrawMode = gfx.getImageDrawMode()
        gfx.fillRoundRect(11, 60, 200, 120, 5)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextAligned(self.entryText, 111, 120, kTextAlignment.center)
        gfx.setImageDrawMode(origDrawMode)
    end
    
end

function Highscore:showScoreList(show)
    self.showingList = show
end

function Highscore:drawScoreBox()
    local origDrawMode = gfx.getImageDrawMode()
    if(self.showingList)then
        local marginX = 10
        local marginY = 5
        
        gfx.fillRoundRect(marginX, marginY, 400-(marginX * 2), 240 - (marginY * 2), 5)
        local drawY = 2 * marginY
        local drawX = 2 * marginX
        local yIncrement = 20

        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

        gfx.drawTextAligned("High Scores", 200, drawY, kTextAlignment.center)
        drawY += yIncrement

        
        for i, entry in ipairs(self.highScores) do
            local rankText = "0"..i
            if(i == 10)then
                rankText = i
            end
            gfx.drawTextAligned(rankText, 120, drawY, kTextAlignment.left)
            gfx.drawTextAligned(entry.name, 200, drawY, kTextAlignment.center)
            gfx.drawTextAligned(entry.score, 260, drawY, kTextAlignment.right)
            drawY += yIncrement

            
        end

        w, h = gfx.drawText("Ⓑ Back", marginX + 5, 210)

    end
    

    gfx.setImageDrawMode(origDrawMode)
end

function Highscore:showKeyboardForEntry(score, hideCallback)
    local entryDisplayWidth = 200
    local entryDisplayHeight = 120

   
    self.entryText = "___"
    self.showingEntry = true
    local thisHighscore = self
    --nameBox:add()

    playdate.keyboard.textChangedCallback = function ()
        if(playdate.keyboard.text:len() > 3)then
            playdate.keyboard.text = playdate.keyboard.text:sub(1,3)
            
        end
        thisHighscore.entryText = playdate.keyboard.text
    end
    playdate.keyboard.keyboardDidHideCallback = function ()
        self.showingEntry = false
        --playdate.keyboard.text will be an empty string if the user selects the cancel button on the keyboard
        if(playdate.keyboard.text ~= "" and playdate.keyboard.text:len() == 3)then
            self:addEntry(score, playdate.keyboard.text)
        else
            print("Keyboard input cancelled")
        end
        if(hideCallback ~= nil)then
            hideCallback()
        end
    end
    playdate.keyboard.show(self.lastEntry)
end

function Highscore:addEntry(newScore, newName)
    print("Highscore name: ", newName, ": ", newScore)
    local newEntry = {name=newName, score=newScore}
    local inserted = false
    for i, entry in ipairs(self.highScores) do
        if(newScore > entry.score)then
            inserted = true
            table.insert(self.highScores, i, newEntry)
            playdate.datastore.write(self.highScores, "highscores")
            break
        end
    end

    if(not inserted and #self.highScores < 10)then
        table.insert(self.highScores, newEntry)
        playdate.datastore.write(self.highScores, "highscores")
    end
    self:printScores()
end

function Highscore:resetScores()
    self.highScores = {}
    playdate.datastore.write(self.highScores, "highscores")
end

function Highscore:printScores()
    for i, entry in ipairs(self.highScores) do
        print(i, " ", entry.name, " ", entry.score)
    end
end