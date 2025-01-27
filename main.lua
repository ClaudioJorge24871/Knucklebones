local love = require("love")
local Dice = require("Dice")
local Cell = require("Cell")

local dice = Dice(6)
local cells = {}

local player_Matrix = {
    {0,0,0},
    {0,0,0},
    {0,0,0}
}

local enemy_Matrix = {
    {0,0,0},
    {0,0,0},
    {0,0,0}
}

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        for _,cell in pairs(cells) do
            if cell:checkPressed(x, y) then
                -- logic for when a cell is Clicked
                love.graphics.setBackgroundColor(0,0,0)
            end
        end
    end
end

function love.load()
    love.graphics.setBackgroundColor(115 / 255, 160 / 255, 30 / 255) -- green

    local cellSize = 100
    local offset = cellSize / 3
    for i = 0, 2 do
        for j = 0, 2 do
            local x = 200 + j * (cellSize + offset)
            local y = 200 + i * (cellSize + offset)
            table.insert(cells, Cell(x, y, cellSize))
        end
    end
end

function love.update(dt)

end

function love.draw()
    
    love.graphics.setColor(0,0,0) -- black
    love.graphics.rectangle("fill",30,30,100,100)
    love.graphics.setColor(0.5,0.5,0.5) -- grey
    love.graphics.rectangle("fill",35,35,90,90)
    -- dice:draw(55,55,50,50)

    for _, cell in pairs(cells) do
        cell:draw()
    end
end