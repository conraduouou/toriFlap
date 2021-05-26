--[[
    Player class file
    --> for flappy bird-like game
]]

-- make Player a Class value
Player = Class{}

local GRAVITY = 20
local FLAP = 420

-- flap sound
flapSound = love.audio.newSource("sounds/flap.wav", "static")

-- make constructor
function Player:init()

    -- pass parameters
    self.x = 0 
    self.y = 0

    -- texture data
    self.texture = love.graphics.newImage("graphics/seal.png");
    self.rotation = math.rad(0)
    self.width = self.texture:getWidth()
    self.height = self.texture:getHeight()

    -- something to manipulate gravity with
    self.dy = 0

    -- state machine in order to incorporate rotation
    self.state = 'fall'
    self.behavior = {
        -- every time bird doesn't flap
        ['fall'] = function(dt)

            -- if space was pressed
            if love.keyboard.wasPressed('space') and gameState == 'play' then
                flapSound:stop()
                flapSound:play()
                self.state = 'flap'
                self.rotation = math.rad(0)
                self.dy = -FLAP
            end

            -- make gravity 'pull' player downwards and make it rotate downward as well
            self.dy = self.dy + GRAVITY
            self.rotation = self.rotation + math.rad(5)

            -- player will not exceed over -75 degrees
            if self.rotation >= math.rad(75) then
                self.rotation = math.rad(75)
            end
        end,

        -- every time bird flaps
        ['flap'] = function (dt)

            -- to enable flapping even when in motion
            if love.keyboard.wasPressed('space') and gameState == 'play' then
                flapSound:stop()
                flapSound:play()
                self.dy = -FLAP
            end

            -- make player rotate upwards to 'flap'
            self.rotation = self.rotation - math.rad(20)

            -- player will not exceed 45 degree angle upwards
            if self.rotation <= math.rad(-45) then
                self.rotation = math.rad(-45)
            end

            -- make transition from flap state to fall state
            if self.dy >= 0 then
                self.state = 'fall'
            end

            self.dy = self.dy + GRAVITY
        end
    }
end

-- update function
function Player:update(dt)
    -- update state machine
    self.behavior[self.state](dt)

    -- increase the y value to descend
    self.y = self.y + self.dy * dt
end
    
-- draw function
function Player:render()
    local xOffset = self.width / 2
    local yOffset = self.height / 2

    love.graphics.draw(self.texture, self.x + xOffset, self.y + yOffset, self.rotation, 1, 1, xOffset, yOffset)
end