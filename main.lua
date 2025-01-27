local love = require("love")
local Dice = require("Dice")
local Cell = require("Cell")

local dice = Dice(6)
local playerCells = {}
local enemyCells = {}

local window_Width = love.graphics.getWidth()
local window_Height = love.graphics.getHeight()

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
        for _,cell in pairs(playerCells) do
            if cell:checkPressed(x, y) then
                -- logic for when a cell is Clicked
                love.graphics.setBackgroundColor(0,0,0)
            end
        end
    end
end

function love.load()
    love.graphics.setBackgroundColor(115 / 255, 160 / 255, 30 / 255) -- green

    local cell_Size = 100
    local offset = cell_Size / 4
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = window_Height / 1.7 + i * (cell_Size + offset)
            table.insert(playerCells, Cell(x, y, cell_Size))
        end
    end
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = 10 + i * (cell_Size + offset)
            table.insert(enemyCells, Cell(x,y,cell_Size))
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

    -- draw the player cells
    for _, cell in pairs(playerCells) do
        cell:draw()
    end

    -- draw the enemy cells
    for _, cell in pairs(enemyCells) do
        cell:draw()
    end

end