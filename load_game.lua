-- load_game.lua

recording = {}

function addFrame()
    local frame = {
        snake = copyTable(snake),
        foods = copyTable(foods)
    }
    table.insert(recording, frame)
end

function copyTable(t)
    local new = {}
    for i, v in ipairs(t) do
        new[i] = {x = v.x, y = v.y}
    end
    return new
end

function saveRecording(filename)
    local file = love.filesystem.newFile(filename .. ".txt")
    file:open('w')
    for i, frame in ipairs(recording) do
        -- 存蛇
        for _, pos in ipairs(frame.snake) do
            file:write("s," .. pos.x .. "," .. pos.y .. "\n")
        end
        -- 存食物
        for _, pos in ipairs(frame.foods) do
            file:write("f," .. pos.x .. "," .. pos.y .. "\n")
        end
        file:write("---\n")  -- 帧分隔符
    end
    file:close()
end

function loadRecording(filename)
    local content = love.filesystem.read(filename .. ".txt")
    if not content then return {} end
    local frames = {}
    local currentFrame = {snake = {}, foods = {}}
    for line in content:gmatch("[^\r\n]+") do
        if line == "---" then
            table.insert(frames, {snake = copyTable(currentFrame.snake), foods = copyTable(currentFrame.foods)})
            currentFrame = {snake = {}, foods = {}}
        else
            local kind, x, y = line:match("(.),(%d+),(%d+)")
            if kind == "s" then
                table.insert(currentFrame.snake, {x = tonumber(x), y = tonumber(y)})
            elseif kind == "f" then
                table.insert(currentFrame.foods, {x = tonumber(x), y = tonumber(y)})
            end
        end
    end
    return frames
end
