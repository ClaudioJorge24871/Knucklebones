local love = require("love")
local socket = require 'socket'
local Dice = require("Dice")
local Cell = require("Cell")

math.randomseed(os.time())


local player_Turn = true
local roll = true
local die = Dice(6)

local window_Width = love.graphics.getWidth()
local window_Height = love.graphics.getHeight()

local playerCells = {}
local enemyCells = {}

function love.mousepressed(x, y, button, istouch, presses)
    if player_Turn and (not roll) and button == 1 then
        for _,cell in pairs(playerCells) do
            if cell:checkPressed(x, y) then
                -- logic for when a cell is Clicked
                local target_Cell = cell
                -- check if there are empty cells above 
                for _, other_Cell in pairs(playerCells) do
                    if target_Cell.die_number ~= 0 then
                        if other_Cell.x == cell.x and other_Cell.y < target_Cell.y and other_Cell.die_number == 0 then
                            target_Cell = other_Cell
                        end
                    end
                end

                -- if another cell above empty was found, draw the dice on that one
                if target_Cell then
                    target_Cell.die_number = die.getNumber()
                    roll = true
                    player_Turn = false
                end
                break
            end
        end
    end
end

--[[
    Function to implement the logic of the computer/enemy play
]] 
local function computerTurn()

    local available_Columns = {}
    for _,cell in pairs(enemyCells) do
        if cell.die_number == 0 then
            available_Columns[cell.x] = true
        end
    end

    local columnKeys = {}
    for columnX, _ in pairs(available_Columns) do
        table.insert(columnKeys, columnX)
    end

    if #columnKeys > 0 then
        local randomColumn = columnKeys[math.random(1, #columnKeys)]

        local target_Cell = nil
        for _, cell in pairs(enemyCells) do
            if cell.x == randomColumn and cell.die_number == 0 then
                if not target_Cell or cell.y < target_Cell.y then
                    target_Cell = cell
                end
            end
        end

        if target_Cell then
            target_Cell.die_number = die.getNumber()
            roll = true
            player_Turn = true
        end
    end
end

--[[
    Function to load initial data of game
]]
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


--[[
    Function to update the program activity
]] 
function love.update(dt)
    if roll then
        local number = math.random(1,6)
        die = Dice(number)
        roll = false
    end

    if not roll and not player_Turn then
        socket.sleep(0.3)
        computerTurn()
        socket.sleep(0.2)
        roll = true
    end
end

--[[
    Function to draw on the screen
]] 
function love.draw()
    
    love.graphics.setColor(0,0,0) -- black
    love.graphics.rectangle("fill",30,30,100,100)
    love.graphics.setColor(0.5,0.5,0.5) -- grey
    love.graphics.rectangle("fill",35,35,90,90)

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
        if cell.die_number ~=0 then
            local cell_Die = Dice(cell.die_number)
            local offset = 10
            cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80)
        end
    end

    if not roll then
        die:draw(40,40,80,80)
    end
    
end