load_game = require('load_game')
function love.load()
    -- Image constant
    bg = love.graphics.newImage('bg.jpg')
    head = love.graphics.newImage('snake_head.png')
    body = love.graphics.newImage('snake_body_h.png')
    tail = love.graphics.newImage('snake_tail.png')
    turn = love.graphics.newImage('snake_turn.png')
    food = love.graphics.newImage('snake_food.png')
    particle_image = love.graphics.newImage("particle.png")
    music = love.audio.newSource("sound_snake_play.mp3", "stream")
    get_food = love.audio.newSource("sound_snake_get.mp3", "static")
    fail_game = love.audio.newSource("sound_snake_fail.mp3", "static")

    particle = love.graphics.newParticleSystem(particle_image, 256)
    particle:setParticleLifetime(1, 2)
    particle:setEmissionRate(0)                          -- 不连续发射
    particle:setSizeVariation(1)                         -- 大小变化
    particle:setLinearAcceleration(-200, -200, 200, 200) -- 随机加速度
    particle:setSizes(3, 0.5)                            -- 初始3倍图片,消失前0.5倍图片
    particle:setSpin(0, 360)

    music:setLooping(true)
    music:play()

    -- Game constant
    WORLD_WIDTH = love.graphics.getWidth()
    WORLD_HEIGHT = love.graphics.getHeight()
    MAX_Width_Delta = math.max(WORLD_WIDTH - 900, 0)
    MAX_Height_Delta = math.max(WORLD_HEIGHT - 600, 0)

    SNAKE_W = head.getWidth(head)
    SNAKE_H = head.getHeight(head)
    FOOD_W = food.getWidth(food)
    FOOD_H = food.getHeight(food)

    font = love.graphics.newFont('m6x11plus.ttf', 25)
    center_font = love.graphics.newFont('m6x11plus.ttf', 20)
    small_font = love.graphics.newFont('m6x11plus.ttf', 15)

    wrong_table = {
        { 'right', 'right' },
        { 'right', 'left' },
        { 'left',  'left' },
        { 'left',  'right' },
        { 'down',  'down' },
        { 'down',  'up' },
        { 'up',    'up' },
        { 'up',    'down' },
    }

    -- randomseed
    math.randomseed(os.time())

    -- table variable
    playback = {}

    snake = {
        { x = 450, y = 240 },
        { x = 420, y = 240 },
        { x = 390, y = 240 },
    }
    foods = {}

    -- string variable
    direction = 'right'

    -- interger/number variable
    speed = 30
    nowtick = 0
    score = 0
    timer = 0
    play_time = 0
    true_time = 0
    food_count = 0
    double_food_probability = 0.0
    random_number = 0.0
    playbackIndex = 1
    replayIndex = 1
    replayTimer = 0

    -- boolean variable
    saved = false
    show_fps = false
    show_snake_speed = false
    active_double = false
    running = false
    EndGame = false
    isReplaying = false
    begin = true

    add_raspberry()
end

function love.draw()
    love.graphics.draw(bg, 0, MAX_Height_Delta)
    for i, xyPos in ipairs(snake) do
        show_image_table = show_image(i, snake)
        image_name = show_image_table[1]
        angle = show_image_table[2]
        love.graphics.draw(image_name, xyPos.x, xyPos.y, math.rad(angle), 1, 1, SNAKE_W / 2, SNAKE_H / 2)
        love.graphics.draw(particle, 0, 0)
    end
    for index, value in ipairs(foods) do
        love.graphics.draw(food, value.x, value.y, math.rad(0), 1, 1, FOOD_W / 2, FOOD_H / 2)
    end
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0)
    -- love.graphics.print(random_number, WORLD_WIDTH/2, 500, 0)
    love.graphics.rectangle("fill", 0, 0, WORLD_WIDTH, MAX_Height_Delta)
    if score == 0 then
        love.graphics.setColor(0, 0, 1)
        CenterFontPrint(font, 'Press SPACE to start, And press F to show FPS', WORLD_WIDTH / 2, 30, 0)
    elseif score > 0 and running == false then
        love.graphics.setColor(0, 1, 0)
        CenterFontPrint(font, 'GAME PAUSED, Press SPACE to contiue', WORLD_WIDTH / 2, 30, 0)
    elseif not EndGame then
        love.graphics.setColor(0, 1, 1)
        if score >= 1000 then
            love.graphics.setFont(small_font)
            CenterFontPrint(small_font, 'score: ' .. score, 200, 30, 0)
            love.graphics.setFont(font)
        elseif score >= 100 then
            love.graphics.setFont(center_font)
            CenterFontPrint(center_font, 'score: ' .. score, 200, 30, 0)
            love.graphics.setFont(font)
        else
            CenterFontPrint(font, 'score: ' .. score, 200, 30, 0)
        end
        love.graphics.setColor(1, 0, 0)
        CenterFontPrint(font, 'time: ' .. timer, WORLD_WIDTH - 200, 30, 0)
        if active_double then
            love.graphics.setColor(0.5, 0.5, 0)
            CenterFontPrint(font, 'ACTIVE!', WORLD_WIDTH / 2, 30, 0)
        else
            love.graphics.setColor(0.5, 0, 0.5)
            CenterFontPrint(font, 'Double food: ' .. double_food_probability * 100 .. '%', WORLD_WIDTH / 2, 30, 0)
        end
    else
        love.graphics.setColor(1, 0, 1)
        if true_time % 3 < 1 then
            CenterFontPrint(font, 'GAME OVER!  score: ' .. score, WORLD_WIDTH / 2, 30, 0)
        elseif true_time % 3 < 2 then
            CenterFontPrint(font, 'Press R key to restart game...', WORLD_WIDTH / 2, 30, 0)
        else
            CenterFontPrint(font, 'highscore: ' .. loadHighScore(), WORLD_WIDTH / 2, 30, 0)
        end
    end
    if show_fps then
        love.graphics.setFont(small_font)
        love.graphics.setColor(1, 1, 0)
        CenterFontPrint(small_font, 'FPS: ' .. FPS, WORLD_WIDTH - 75, 30, 0)
        love.graphics.setFont(font)
    end
    if show_snake_speed then
        love.graphics.setFont(small_font)
        love.graphics.setColor(0, 0.5, 0.5)
        CenterFontPrint(small_font, 'Speed: ' .. string.format('%.2f', speed / 60) .. 's/step', 75, 30, 0)
        love.graphics.setFont(font)
    end
    love.graphics.setColor(1, 1, 1)
end

function love.update(dt)
    -- if isReplaying then
    --     print("进入回放分支")
    --     replayTimer = replayTimer + dt
    --     print("replayTimer", replayTimer)
    -- end
    FPS = love.timer.getFPS()
    if EndGame then
        true_time = true_time + dt
    else
        play_time = play_time + dt
    end
    nowtick = nowtick + 1
    if nowtick >= speed then
        nowtick = 0
        if not EndGame then
            if running then
                local newFoodX, newFoodY = nil, nil
                score = score + 1
                timer = string.format('%.2f', timer + speed / 60)
                if direction == 'right' then
                    newHead = { x = snake[1].x + 30, y = snake[1].y }
                elseif direction == 'left' then
                    newHead = { x = snake[1].x - 30, y = snake[1].y }
                elseif direction == 'down' then
                    newHead = { x = snake[1].x, y = snake[1].y + 30 }
                elseif direction == 'up' then
                    newHead = { x = snake[1].x, y = snake[1].y - 30 }
                else
                    newHead = { x = snake[1].x, y = snake[1].y }
                end

                if active_double then
                    active_double = false
                end

                speed = math.max(15, 30 - math.floor(#snake / 5))

                local willGrow = false

                for index, value in ipairs(foods) do
                    if newHead.x == value.x and newHead.y == value.y then
                        willGrow = true
                        table.remove(foods, index)
                        if #foods < 15 then
                            local food_pos = add_raspberry()
                            if math.random() < double_food_probability then
                                local food_pos2 = add_raspberry()
                                double_food_probability = 0.0
                                active_double = true
                            end
                        end
                        get_food:play()
                        particle:setPosition(value.x, value.y)
                        particle:emit(128)
                        score = score + 10
                        food_count = food_count + 1
                        random_number = math.random(0, 500) / 1000
                        double_food_probability = double_food_probability + random_number
                        break
                    end
                end

                table.insert(snake, 1, newHead)

                if not willGrow then
                    table.remove(snake)
                end

                print("save snake length", #snake)
                addFrame()

                saveRecording('gameplay')

                if snake[1].x < MAX_Width_Delta or snake[1].x > WORLD_WIDTH then
                    fail_game:isLooping(false)
                    fail_game:play()
                    EndGame = true
                elseif snake[1].y < MAX_Height_Delta or snake[1].y > WORLD_HEIGHT then
                    fail_game:isLooping(false)
                    fail_game:play()
                    EndGame = true
                end
                --
                for index, value in ipairs(snake) do
                    if snake[1].x == value.x and snake[1].y == value.y and index ~= 1 then
                        fail_game:isLooping(false)
                        fail_game:play()
                        EndGame = true
                        break
                    end
                end
            end
        else
            music:stop()
            if not saved then
                if score > tonumber(loadHighScore()) then
                    saveHighScore(score)
                end
                saveUserData()
                saveMapToFile('lastgame')
            end
        end
    end
    -- if isReplaying then
    --     speed = 30
    --     replayTimer = replayTimer + dt
    --     if replayTimer >= speed / 60 then
    --         replayTimer = 0
    --         local frame = playback[replayIndex]
    --         -- print('x', playback[replayIndex].x)
    --         if frame then
    --             applyFrame(frame)
    --             replayIndex = replayIndex + 1
    --         else
    --             isReplaying = false
    --         end
    --     end
    -- end
    particle:update(dt)
end

function love.keypressed(key)
    if running then
        for index, value in ipairs(wrong_table) do
            if key == value[1] and getDirection() == value[2] then
                direction = getDirection()
                return
            end
        end
        if key == 'right' then
            direction = 'right'
        elseif key == 'left' then
            direction = 'left'
        elseif key == 'down' then
            direction = 'down'
        elseif key == 'up' then
            direction = 'up'
        end
    end
    if not EndGame then
        if key == 'space' then
            running = not running
        elseif key == 'f' then
            show_fps = not show_fps
        elseif key == 'g' then
            show_snake_speed = not show_snake_speed
        elseif key == 'l' then
            snake = {}
            foods = {}
            for index, value in ipairs(loadMaptoTable('lastgame')) do
                if value.type == 1 then
                    table.insert(snake, {x = value.x, y = value.y})
                elseif value.type == 2 then
                    table.insert(foods, {x = value.x, y = value.y})
                end
            end
        end
    end
    if EndGame then
        if key == 'r' then
            ResetGame()
        elseif key == 'p' then
            playback = loadRecording('gameplay')
            playbackIndex = 1
            snake = {
                { x = 450, y = 240 },
                { x = 420, y = 240 },
                { x = 390, y = 240 },
            }
            foods = {

            }
            isReplaying = true
            replayIndex = 0
            playback = loadRecording('gameplay')

        elseif key == 'a' then
            if isReplaying and replayIndex > 1 then
                replayIndex = replayIndex - 1
                applyFrame(playback[replayIndex])
            end
        elseif key == 'd' then
            if isReplaying and replayIndex < #playback - 1 then
                replayIndex = replayIndex + 1
                applyFrame(playback[replayIndex])
            end
        end
    end
end

function show_image(i)
    if i == 1 or i == #snake then
        if i == 1 then
            before = snake[1]
            after = snake[2]
        else
            before = snake[#snake - 1]
            after = snake[#snake]
        end
        --
        offX = before.x - after.x
        offY = before.y - after.y
        --
        if offX == 30 and offY == 0 then
            if i == 1 then
                return { head, 0 }
            else
                return { tail, 0 }
            end
        elseif offX == -30 and offY == 0 then
            if i == 1 then
                return { head, 180 }
            else
                return { tail, 180 }
            end
        elseif offX == 0 and offY == 30 then
            if i == 1 then
                return { head, 90 }
            else
                return { tail, 90 }
            end
        elseif offX == 0 and offY == -30 then
            if i == 1 then
                return { head, 270 }
            else
                return { tail, 270 }
            end
        else
            return { body, 0 }
        end
    elseif snake[i - 1].x == snake[i + 1].x then
        return { body, 90 }
    elseif snake[i - 1].y == snake[i + 1].y then
        return { body, 0 }
    else
        local slope = (snake[i - 1].x - snake[i + 1].x) / (snake[i - 1].y - snake[i + 1].y)
        local right = math.max(snake[i - 1].x, snake[i + 1].x) > snake[i].x
        if slope > 0 and right then
            return { turn, 180 }
        elseif slope > 0 and not right then
            return { turn, 0 }
        elseif slope < 0 and right then
            return { turn, 270 }
        elseif slope < 0 and not right then
            return { turn, 90 }
        else
            return { body, 0 }
        end
    end
end

function getDirection()
    local offX = snake[1].x - snake[2].x
    local offY = snake[1].y - snake[2].y
    if offX == 30 and offY == 0 then
        return 'right'
    elseif offX == -30 and offY == 0 then
        return 'left'
    elseif offX == 0 and offY == 30 then
        return 'down'
    elseif offX == 0 and offY == -30 then
        return 'up'
    end
end

function add_raspberry()
    x = (math.random(0, math.min(WORLD_WIDTH / 30, 30))) * 30 + MAX_Width_Delta
    y = (math.random(0, math.min(WORLD_HEIGHT / 30, 20))) * 30 + MAX_Height_Delta
    for index, value in ipairs(snake) do
        if value.x == x and value.y == y then
            return add_raspberry()
        end
    end
    table.insert(foods, { x = x, y = y })
    return { x, y }
end

function ResetGame()
    -- table variable
    playback = {}

    snake = {
        { x = 450, y = 240 },
        { x = 420, y = 240 },
        { x = 390, y = 240 },
    }
    foods = {}

    -- string variable
    direction = 'right'

    -- interger/number variable
    speed = 30
    nowtick = 0
    score = 0
    timer = 0
    play_time = 0
    true_time = 0
    food_count = 0
    double_food_probability = 0.0
    random_number = 0.0
    playbackIndex = 1
    replayIndex = 1
    replayTimer = 0

    -- boolean variable
    saved = false
    show_fps = false
    show_snake_speed = false
    active_double = false
    running = false
    EndGame = false
    isReplaying = false
    begin = true

    add_raspberry()
end

function saveHighScore(score)
    local file = love.filesystem.newFile("highscore.txt")
    file:open("w")
    file:write(score)
    file:close()
end

function loadHighScore()
    if love.filesystem.getInfo("highscore.txt") then
        local content = love.filesystem.read("highscore.txt")
        return tonumber(content) or 0
    end
    return 0
end

function saveUserData()
    local old_data = loadUserData()
    local file = love.filesystem.newFile("userdata.txt")
    file:open("w")
    file:write(tostring(old_data[1] + 1) .. '\n')
    file:write(math.max(string.format('%.5f', play_time), old_data[2]) .. '\n')
    file:write(old_data[3] + food_count)
    file:close()
end

function loadUserData()
    if love.filesystem.getInfo("userdata.txt") then
        local data = love.filesystem.read("userdata.txt")
        local DataTable = {}
        for line in data:gmatch("[^\r\n]+") do
            table.insert(DataTable, line)
        end
        return DataTable
    end
    return { 0, 0, 0 }
end

function saveMapToFile(filename)
    local file = love.filesystem.newFile(filename .. ".txt")
    file:open('w')
    for index, value in ipairs(snake) do
        file:write(value.x .. ',' .. value.y .. ',1\n')
    end
    for index, value in ipairs(foods) do
        file:write(value.x .. ',' .. value.y .. ',2\n')
    end
end

function loadMaptoTable(filename)
    local content = love.filesystem.read(filename .. ".txt")
    local items = {}
    for line in content:gmatch("[^\r\n]+") do
        local x, y, typ = line:match("(%d+),(%d+),(%d+)")
        table.insert(items, { x = tonumber(x), y = tonumber(y), type = tonumber(typ) })
    end
    return items
end

function CenterFontPrint(font, text, x, y, rad)
    love.graphics.print(text, x, y, rad, 1, 1, font:getWidth(text) / 2, font:getHeight(text) / 2)
end

function applyFrame(frame)
    snake = copyTable(frame.snake)
    foods = copyTable(frame.foods)
    print("切换到帧", replayIndex, "蛇头坐标", frame.snake[1].x, frame.snake[1].y)
    print("snake length", #snake)
end

function copyTable(t)
    local new = {}
    for i, v in ipairs(t) do
        new[i] = {x = v.x, y = v.y}
    end
    return new
end
