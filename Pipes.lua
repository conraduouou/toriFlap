--[[
    Pipes object that serve as obstacles for the bird
    --> for flappy bird-like game
]]

Pipes = {}

-- let's do GameFromScratch's method of making objects
Pipes.new = function()
    local self = self or {}

    -- Make x of object spawn from the width of the screen
    self.pipe1x = love.graphics.getWidth()
    self.pipe1y = 0

    -- generate random pipe height ranging from 100 to 550
    self.pipe1Width = 40
    self.pipe1Height = math.random(100, 550)

    -- set 2nd pipe height to consume the whole height below the 1st pipe
    self.pipe2Width = self.pipe1Width
    self.pipe2Height = love.graphics.getHeight() - (self.pipe1Height + 90)

    -- set 2nd pipe have the same x as 1st pipe, but go below with 90 pixels allowance
    self.pipe2x = self.pipe1x
    self.pipe2y = self.pipe1Height + 90

    -- flag for score
    self.isScored = false

    -- our very own update function... so proud of u self
    self.update = function()
        -- handy function from love2D that emulates dt from update
        dt = love.timer.getDelta()
        
        self.pipe1x = self.pipe1x - 275 * dt
        self.pipe2x = self.pipe1x
    end

    -- render 'pipes'
    self.draw = function()
        love.graphics.setColor(120 / 255, 180 / 255, 120 / 255, 1)
        
        -- it's design time using LUA
        love.graphics.rectangle('fill', self.pipe1x - 5, self.pipe1y + self.pipe1Height - 30, 50, 30)
        love.graphics.rectangle('fill', self.pipe1x, self.pipe1y, self.pipe1Width, self.pipe1Height)

        love.graphics.rectangle('fill', self.pipe2x - 5, self.pipe2y, 50, 30)
        love.graphics.rectangle('fill', self.pipe2x, self.pipe2y, self.pipe2Width, self.pipe2Height)
        love.graphics.setColor(1, 1, 1, 1)
    end

    return self
end