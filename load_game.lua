recording = {}  -- 每一帧一个条目
function addFrame(headX, headY, ate, doubleFood, newFoodX, newFoodY, newFoodX2, newFoodY2)
    if ate == nil then
        table.insert(recording, {
            headX = headX,
            headY = headY,
            ate = nil,
            doubleFood = doubleFood,
            newFoodX = newFoodX,
            newFoodY = newFoodY,
        })
    elseif ate then
        if doubleFood then
            table.insert(recording, {
                headX = headX,
                headY = headY,
                ate = ate,
                doubleFood = doubleFood,
                newFoodX = newFoodX,
                newFoodY = newFoodY,
                newFoodX2 = newFoodX2,
                newFoodY2 = newFoodY2,
            })
        else
            table.insert(recording, {
                headX = headX,
                headY = headY,
                ate = ate,
                doubleFood = doubleFood,
                newFoodX = newFoodX,
                newFoodY = newFoodY,
            })
        end
    else
        table.insert(recording, {
            headX = headX,
            headY = headY,
            ate = ate,
            doubleFood = doubleFood,
        })
    end
end

function saveRecording(filename)
    local file = love.filesystem.newFile(filename .. ".txt")
    file:open('w')
    for index, value in ipairs(recording) do
        file:write(value.headX .. ',' .. value.headY .. ',' .. tostring(value.ate) .. ',' .. tostring(value.doubleFood))
        if value.ate == nil then
            file:write(',' .. value.newFoodX .. ',' .. value.newFoodY .. ',' .. 0 .. ',' .. 0)
        elseif value.ate then
            file:write(',' .. value.newFoodX .. ',' .. value.newFoodY)
            if value.doubleFood then
                file:write(',' .. value.newFoodX2 .. ',' .. value.newFoodY2)
            else
                file:write(',' .. 0 .. ',' .. 0)
            end
        else
            file:write(',' .. 0 .. ',' .. 0 .. ',' .. 0 .. ',' .. 0)
        end
        file:write('\n')
    end
end

function loadRecording(filename)
    local content = love.filesystem.read(filename .. ".txt")
    if not content then return end
    local recordingTable = {}
    for line in content:gmatch("[^\r\n]+") do
        -- print(line)
        local x, y, ate, doubleFood, newFoodX, newFoodY, newFoodX2, newFoodY2 = line:match("(%d+),(%d+),(%w+),(%w+),(%d+),(%d+),(%d+),(%d+)")
        print(x,y,ate,doubleFood)
        if x and y then
            if ate == "nil" then
                table.insert(recordingTable, {
                    x = tonumber(x),
                    y = tonumber(y),
                    ate = nil,
                    doubleFood = (doubleFood == "true"),
                    newFoodX = tonumber(newFoodX),
                    newFoodY = tonumber(newFoodY),
                })
            elseif ate == "true" then
                if doubleFood == "true" then
                    table.insert(recordingTable, {
                        x = tonumber(x),
                        y = tonumber(y),
                        ate = (ate == "true"),
                        doubleFood = (doubleFood == "true"),
                        newFoodX = tonumber(newFoodX),
                        newFoodY = tonumber(newFoodY),
                        newFoodX2 = tonumber(newFoodX2),
                        newFoodY2 = tonumber(newFoodY2),
                    })
                end
                table.insert(recordingTable, {
                    x = tonumber(x),
                    y = tonumber(y),
                    ate = (ate == "true"),
                    doubleFood = (doubleFood == "true"),
                    newFoodX = tonumber(newFoodX),
                    newFoodY = tonumber(newFoodY),
                })
            else
                table.insert(recordingTable, {
                    x = tonumber(x),
                    y = tonumber(y),
                    ate = (ate == "true"),
                    doubleFood = (doubleFood == "true"),
                })
            end
            
        end
    end
    return recordingTable
end

return {
    recording = recording,
    addFrame = addFrame,
    saveRecording = saveRecording,
    loadRecording = loadRecording
}