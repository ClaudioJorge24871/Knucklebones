local love = require("love")
local Dice = require("Dice")

local dice = Dice(6)

function love.load()
    love.graphics.setBackgroundColor(115 / 255, 160 / 255, 30 / 255) -- green
end

function love.update(dt)

end

function love.draw()
    love.graphics.setColor(0,0,0) -- black
    love.graphics.rectangle("fill",30,30,100,100)
    love.graphics.setColor(0.5,0.5,0.5) -- grey
    love.graphics.rectangle("fill",35,35,90,90)
    dice:draw(55,55,50,50)
end