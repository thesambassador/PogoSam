import "CoreLibs/keyboard"

local gfx <const> = playdate.graphics

class('Highscore').extends()
function Highscore:init()
    Highscore.super.init(self)
    self.highScores = {}
    self.lastEntry = ""
    self.entryText = ""
    self.showingEntry = false
    self.showingList = false
    self.pages = 1
    self.pageShowing = 1
    self.lastIndexEntered = 0 --last index in the FULL uncollapsed score list that was entered
    self.maxNameLength = 3
    self.collapsingScores = false

    self:loadScores()
end

function Highscore:loadScores()
    self.highScores = playdate.datastore.read("highscores")
    if(self.highScores == nil)then
        print("No high score file found, empty list it is")
        self.highScores = {}
    else
        print("High scores loaded")
        --self:printScores()
    end
    self.pages = #self.highScores // 10 + 1
    print("pages: ", self.pages)
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

function Highscore:showScoreList(show, page)
    self.showingList = show
    self.pageShowing = page or (self.lastIndexEntered // 10 + 1)
end

function Highscore:movePage(dir)
    self.pageShowing += dir
    if(self.pageShowing < 1)then
        self.pageShowing = 1
    elseif(self.pageShowing > self.pages)then
        self.pageShowing = self.pages
    end
end

--gets the collapsed or uncollapsed high scores depending on state
function Highscore:getScoreList()
    if(not self.collapsingScores)then
        return self.highScores --uncollapsed list
    else
        local playerScores = {}
        for i, entry in ipairs(self.highScores) do
            if(playerScores[entry.name] == nil or playerScores[entry.name].score < entry.score)then
                
                playerScores[entry.name] = {score = entry.score, name = entry.name}
            end
        end
        
        local scoreArray = {}
        for i, entry in pairs(playerScores)do
            table.insert(scoreArray, entry)
        end

        table.sort(scoreArray, function (a, b)
            return a.score > b.score
        end)

        --for i, entry in ipairs(scoreArray) do
            --print(entry.name, " ", entry.score)
       -- end

        return scoreArray
    end




end

function Highscore:drawScoreBox()
    local origDrawMode = gfx.getImageDrawMode()
    local origColor = gfx.getColor()
    if(self.showingList)then
        local marginX = 10
        local marginY = 5

        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        
        
        local drawY = 2 * marginY
        local drawX = 2 * marginX
        local yIncrement = 20

        gfx.fillRoundRect(marginX, marginY, 400-(marginX * 2), 240 - (marginY * 2), 5)

        gfx.drawTextAligned("High Scores", 200, drawY, kTextAlignment.center)
        drawY += yIncrement

        local pageStart = (self.pageShowing - 1) * 10
        local scoreList = self:getScoreList()
        for i, entry in ipairs(scoreList) do
            if(i > pageStart and i <= (pageStart + 10))then

                local rankText = "0"..i
                if(i >= 10)then
                    rankText = tostring(i)
                end

                --we wanna "highlight" the last entry that was added
                if(i == self.lastIndexEntered and not self.collapsingScores)then
                    gfx.setColor(gfx.kColorWhite)
                    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
                    gfx.fillRoundRect(110, drawY, 160, 20, 5)
                elseif(self.collapsingScores and entry.name == self.lastEntry)then
                    gfx.setColor(gfx.kColorWhite)
                    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
                    gfx.fillRoundRect(110, drawY, 160, 20, 5)
                else
                    gfx.setColor(gfx.kColorBlack)
                    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                end

                gfx.drawTextAligned(rankText, 120, drawY, kTextAlignment.left)
                gfx.drawTextAligned(entry.name, 200, drawY, kTextAlignment.center)
                gfx.drawTextAligned(entry.score, 260, drawY, kTextAlignment.right)
                drawY += yIncrement
                
                gfx.setColor(gfx.kColorBlack)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            end
        end

        w, h = gfx.drawText("Ⓑ Back", marginX + 5, 210)
        local collapseText = "Collapse Ⓐ"
        if(self.collapsingScores)then
            collapseText = "Uncollapse Ⓐ"
        end
        gfx.drawTextAligned(collapseText, 385, 210, kTextAlignment.right)
        gfx.drawText("Page "..self.pageShowing, 325,10)

    end
    
    gfx.setColor(origColor)
    gfx.setImageDrawMode(origDrawMode)
end

function Highscore:showKeyboardForEntry(score, hideCallback)
    local entryDisplayWidth = 200
    local entryDisplayHeight = 120

   
    self.entryText = self.lastEntry
    self.showingEntry = true
    playdate.keyboard.text = self.entryText
    local thisHighscore = self
    --nameBox:add()

    playdate.keyboard.textChangedCallback = function ()
        if(playdate.keyboard.text:len() > self.maxNameLength)then
            playdate.keyboard.text = playdate.keyboard.text:sub(1,maxNameLength)
            
        end
        thisHighscore.entryText = playdate.keyboard.text
    end
    playdate.keyboard.keyboardDidHideCallback = function ()
        self.showingEntry = false
        --playdate.keyboard.text will be an empty string if the user selects the cancel button on the keyboard
        if(playdate.keyboard.text ~= "" and playdate.keyboard.text:len() > 0)then
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
    local index = -1
    self.lastEntry = newName
    print("Highscore name: ", newName, ": ", newScore)
    local newEntry = {name=newName, score=newScore}
    local inserted = false
    for i, entry in ipairs(self.highScores) do
        if(newScore > entry.score)then
            inserted = true
            table.insert(self.highScores, i, newEntry)
            index = i
            playdate.datastore.write(self.highScores, "highscores")
            break
        end
    end

    if(not inserted)then
        table.insert(self.highScores, newEntry)
        index = #self.highScores
        playdate.datastore.write(self.highScores, "highscores")
    end
    self.pages = #self.highScores // 10 + 1
    self:printScores()
    self.lastIndexEntered = index
    print("Last index: ", self.lastIndexEntered)
    return index
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

function Highscore:addGarbage()
    for i=1,10 do
        self:addEntry(i, "SA"..i)
    end
end