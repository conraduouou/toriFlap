--[[
    Flappy Bird-like game
]]

push = require 'push'
Class = require 'class'

require "Player"
require "Pipes"

local player = nil

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- seed RNG
math.randomseed(os.time())

-- make state
gameState = 'start'

-- sounds
hitSound = love.audio.newSource("sounds/hit.wav", "static")
pointSound = love.audio.newSource("sounds/point.wav", "static")
spaceSound = love.audio.newSource("sounds/space.wav", "static")
waterSound = love.audio.newSource("sounds/water.wav", "static")

spaceSound:setLooping(false)
waterSound:setLooping(false)

function love.load()

    love.window.setTitle("tori Flap!")
    love.audio.setVolume(1)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    
    -- menu logo
    toriLogo = love.graphics.newImage("graphics/toriFlap.png")

    -- font
    largeFont = love.graphics.newFont("fonts/font.ttf", 64)
    smallFont = love.graphics.newFont("fonts/font.ttf", 32)
    love.graphics.setFont(largeFont)

    -- instantiate a new Player object
    player = Player()
    player.x = love.graphics.getWidth()/2 - player.width / 2
    player.y = love.graphics.getHeight()/2

    -- experiment worked --> So proud of u self
    -- basically what I did was make a table where I could store all pipe instantiations and print whatever is on screen
    pipes = {}
    pipes[1] = Pipes.new()      -- have a new pipe at start
    counter = 0

    -- score
    score = 0
    record = 0

    -- alpha for background fade
    alpha1 = 0
    alpha2 = 0

    -- to be able to cap fps at 60
    min_dt = 1/60
    next_time = love.timer.getTime()
    
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)

    -- if key pressed is escape
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

function love.update(dt)
    
    -- add min_dt to next_time
    next_time = next_time + min_dt

    -- start
    if gameState == 'start' then
        player:update(dt)

        pipes[1].pipe1x = love.graphics.getWidth()
        pipes[1].pipe2x = love.graphics.getWidth()

        alpha1 = 0
        alpha2 = 0

        player.rotation = 0

        if player.y >= (love.graphics.getHeight() / 2) + 20 then
            player.dy = -350
        end

        if love.keyboard.wasPressed('space') then
            gameState = 'play'
        end
    elseif gameState == 'play' then
        player:update(dt)

        -- updating pipes table and removing calling collision function
        for i = 1 + counter, #pipes do
            pipes[i]:update()

            -- reinsert new pipe every 450 pixels
            if love.graphics.getWidth() - pipes[#pipes].pipe1x >= 450 then
                table.insert(pipes, i + 1, Pipes.new())
            end 

            -- skip when pipe gets outside of screen
            if pipes[i].pipe1x <= -40 then
                counter = counter + 1

            -- score 
            elseif pipes[i].pipe1x <= player.x and pipes[i].isScored == false then
                pipes[i].isScored = true
                pointSound:stop()
                pointSound:play()
                score = score + 1

            -- collision detections
            elseif collide1(player, pipes[i]) then
                hitSound:play()
                gameState = 'hit'

            elseif collide2(player, pipes[i]) then
                hitSound:play()
                gameState = 'hit'

            end
        end

        -- the dead zone
        if player.y >= love.graphics.getHeight() then
            gameState = 'hit'

        -- the space zone
        elseif player.y <= 0 - player.height then
            gameState = 'hit'
        end
    elseif gameState == 'hit' then      -- when player hits pipe
        player:update(dt)

        -- transition to gameState over through fade HEHE
        if player.y >= love.graphics.getHeight() then
            waterSound:stop()
            waterSound:play()

            temp = math.random(2)

            player.y = -50
            player.dy = 0
            gameState = 'over1'
        elseif player.y <= 0 - player.height then
            spaceSound:stop()
            spaceSound:play()

            temp = math.random(2)

            player.y = love.graphics.getHeight() + 50
            player.dy = 0
            gameState = 'over2'
        end
    elseif gameState == 'over1' then     -- initiate game over1 state
        alpha1 = alpha1 + 2 * dt

        if alpha1 >= 1 then
            alpha1 = 1

            alpha2 = alpha2 + 1 * dt

            player.dy = player.dy + 50 * dt
            player.y = player.y + player.dy * dt
            player.rotation = player.rotation + math.rad(5)

            if player.y >= love.graphics.getHeight() / 2 then
                player.y = love.graphics.getHeight() / 2
            end

            if alpha2 >= 1 then
                alpha2 = 1
            end

            if love.keyboard.wasPressed('space') and player.y < love.graphics.getHeight() / 2 then
                player.y = love.graphics.getHeight()/2
            elseif love.keyboard.wasPressed('space') and player.y == love.graphics.getHeight() / 2 then
                if record < score then
                    record = score
                end

                waterSound:stop()

                score = 0
                counter = 0
                clearPipes(pipes)
                pipes[1] = Pipes.new()      -- generate a new 1st pipe
                gameState = 'start'
            end
        end
    elseif gameState == 'over2' then        -- initiate game over2 state
        alpha1 = alpha1 + 2 * dt

        if alpha1 >= 1 then
            alpha1 = 1

            alpha2 = alpha2 + 1 * dt

            player.dy = player.dy - 50 * dt
            player.y = player.y + player.dy * dt
            player.rotation = player.rotation + math.rad(-5)

            if player.y <= love.graphics.getHeight() / 2 then
                player.y = love.graphics.getHeight() / 2
            end

            if alpha2 >= 1 then
                alpha2 = 1
            end

            if love.keyboard.wasPressed('space') and player.y > love.graphics.getHeight() / 2 then
                player.y = love.graphics.getHeight()/2
            elseif love.keyboard.wasPressed('space') and player.y == love.graphics.getHeight() / 2 then
                if record < score then
                    record = score
                end

                spaceSound:stop()
                
                score = 0
                counter = 0
                clearPipes(pipes)
                pipes[1] = Pipes.new()      -- generate a new 1st pipe
                gameState = 'start'
            end
        end
    end
        
    love.keyboard.keysPressed = {}
end

-- collide function for player and pipe above
function collide1(player, pipe)

    -- checks to see if they are not overlapping
    if (player.x > pipe.pipe1x + pipe.pipe1Width or player.x + player.width < pipe.pipe1x) then
        return false
    end
    
    if (player.y > pipe.pipe1y + pipe.pipe1Height or player.y + player.height < pipe.pipe1y) then
        return false
    end

    -- else they must be overlapping
    return true
end

-- collide function for player and pipe below
function collide2(player, pipe)

    -- checks to see if they are not overlapping
    if (player.x > pipe.pipe2x + pipe.pipe2Width or player.x + player.width < pipe.pipe2x) then
        return false
    end
    
    if (player.y > pipe.pipe2y + pipe.pipe2Height or player.y + player.height < pipe.pipe2y) then
        return false
    end

    -- else they must be overlapping
    return true
end

-- clear pipes table function
function clearPipes(pipes)
    local max = #pipes
    for i = 1, max do
        pipes[i] = nil
    end

    for i = 1, max do
        table.remove(pipes, i)
    end
end

function love.draw()
    
    love.graphics.clear(128 / 255, 213 / 255, 242 / 255, 1)
    
    -- pipes
    for i = 1 + counter, #pipes do
        pipes[i]:draw()
    end
    
    -- water
    love.graphics.setColor(75 / 255, 170 / 255, 220 / 255, 1)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 40, love.graphics.getWidth(), 40)
    love.graphics.setColor(1, 1, 1, 1)
    
    -- score
    love.graphics.setFont(largeFont)
    love.graphics.printf(score, 0, 100, love.graphics.getWidth(), "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf(record, 0, 150, love.graphics.getWidth(), "center")
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press 'space' to start!", 0, 600, love.graphics.getWidth(), "center")
        love.graphics.setFont(largeFont)

        love.graphics.draw(toriLogo, love.graphics.getWidth()/2 - toriLogo:getWidth()/2, 100)

        love.graphics.setFont(largeFont)
        love.graphics.printf(score, 0, 400, love.graphics.getWidth(), "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf(record, 0, 450, love.graphics.getWidth(), "center")

    -- if game is over
    elseif gameState == 'over1' then
        love.graphics.setColor(75 / 255, 170 / 255, 220 / 255, alpha1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 1, 1, alpha2)
        love.graphics.setFont(smallFont)
        love.graphics.printf("Score:", 0, 100, love.graphics.getWidth(), "center")

        if temp == 1 then
            love.graphics.printf("Hina mo naman", 0, 400, love.graphics.getWidth(), "center")
        else
            love.graphics.printf("Yan lang kaya mo?", 0, 400, love.graphics.getWidth(), "center")
        end

        love.graphics.setFont(largeFont)
        love.graphics.printf(score, 0, 130, love.graphics.getWidth(), "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press 'space' to play again!", 0, 600, love.graphics.getWidth(), "center")
       
    -- if player flies over screen
    elseif gameState == 'over2' then
        love.graphics.setColor(2 / 255, 15 / 255, 26 / 255, alpha1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 1, 1, alpha2)
        love.graphics.setFont(smallFont)
        love.graphics.printf("Score:", 0, 100, love.graphics.getWidth(), "center")

        if temp == 1 then
            love.graphics.printf("Ligalig mo naman sa space", 0, 400, love.graphics.getWidth(), "center")
        else
            love.graphics.printf("You flew to space", 0, 400, love.graphics.getWidth(), "center")
        end

        love.graphics.setFont(largeFont)
        love.graphics.printf(score, 0, 130, love.graphics.getWidth(), "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press 'space' to play again!", 0, 600, love.graphics.getWidth(), "center")
    end

    player:render()

    -- something mentioned in the love2D documentation about sleep
    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    
    love.timer.sleep(next_time - cur_time)
end