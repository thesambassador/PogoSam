
function GetRandomElement(myTable)
    --print(myTable)
    return myTable[math.random(#myTable)]
end

function RandFloat(a, b)
    return math.random() * (b-a) + a
end

function GetAngleWrappedMidpoint(angle1, angle2)
    --if the 2nd angle is less than the 1st, it's wrapped, so averaging the two won't work
    --instead we just add 360 and call it good?
    if(angle2 < angle1)then
        angle2 += 360
    end
    return ((angle1 + angle2) / 2) % 360
end