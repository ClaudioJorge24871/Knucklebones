local love = require("love")
local Dice = require("Dice")
local Cell = require("Cell")

math.randomseed(os.time())


local playerTurn = true
local roll = true
local die = Dice(6)

local window_Width = love.graphics.getWidth()
local window_Height = love.graphics.getHeight()

local playerCells = {}
local enemyCells = {}

function love.mousepressed(x, y, button, istouch, presses)
    if playerTurn and (not roll) and button == 1 then
        for _,cell in pairs(playerCells) do
            if cell:checkPressed(x, y) then
                -- logic for when a cell is Clicked
                cell.die_number = die.getNumber()
                roll = true
                playerTurn = false
            end
        end
    end
end

function love.load()
    love.graphics.setBackgroundColor(115 / 255, 160 / 255, 30 / 255) -- green

    local cell_Size = 100
    local offset = cell_Size / 4
    -- create cells in playerCells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = window_Height / 1.7 + i * (cell_Size + offset)
            table.insert(playerCells, Cell(x, y, cell_Size))
        end
    end
    -- create cells in enemyCells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = 10 + i * (cell_Size + offset)
            table.insert(enemyCells, Cell(x,y,cell_Size))
        end
    end
end

function love.update(dt)
    if roll then
        local number = math.random(1,6)
        die = Dice(number)
        roll = false
    end
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
        if cell.die_number ~= 0 then
            local cell_Die = Dice(cell.die_number) 
            local offset = 10 
            cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80)
        end
    end

    -- draw the enemy cells
    for _, cell in pairs(enemyCells) do
        cell:draw()
    end

    if not roll then
        die:draw(40,40,80,80)
    end
    
end