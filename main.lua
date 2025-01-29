local love = require("love")
local socket = require 'socket'
local Dice = require("Dice")
local Cell = require("Cell")
local Button = require("Button")

math.randomseed(os.time())

local roll = true
local die = Dice(6)

local window_Width = love.graphics.getWidth()
local window_Height = love.graphics.getHeight()

-- Time variables
local computer_Delay = 0
local computer_Waiting = false 


local player = {
    playerCells = {},
    points = 0
}

local enemy = {
    enemyCells = {},
    points = 0
}

local game = {
    player_Turn = true,
    state = {
        menu = true,
        running = false,
        ended = false
    }
}

local buttons = {
    menu_State = {},
    running_State = {},
    ended_State = {}
} 


--[[
    Function to help increment points when a combo occurs

    If no combo occurs return 1
]]
local function checkComboPoints(person, column, row, number_to_Check)
    local combo_Counter = 1
    if person == "player" then
        for _,cell in pairs(player.playerCells) do
            if cell.x == column and cell.y ~= row then
                -- if the current cell is on the same column as the cell column passed
                if cell.die_number == number_to_Check then
                    -- if its the same column and the same number, increases the combo count
                    combo_Counter = combo_Counter + 1
                end
            end
        end
    else
        for _,cell in pairs(enemy.enemyCells) do
            if cell.x == column and cell.y ~= row then
                if cell.die_number == number_to_Check then
                    combo_Counter = combo_Counter + 1
                end
            end
        end
    end

    if combo_Counter == 2 then
        return number_to_Check * 4 - number_to_Check
    elseif combo_Counter == 3 then
        return number_to_Check * 9 - number_to_Check - number_to_Check
    else
        return number_to_Check
    end
end

--[[
    Function called for when mouse is clicked
    can be seen as the player turn function
]]
function love.mousepressed(x, y, button, istouch, presses)
    if game.state["running"] then
        if game.player_Turn and (not roll) and button == 1 then
            for _, cell in pairs(player.playerCells) do
                if cell:checkPressed(x, y) then
                    -- logic for when a cell is clicked
                    local target_Cell = cell
                    if target_Cell.die_number == 0 then
                        -- checks if there are empty cells above 
                        for _, other_Cell in pairs(player.playerCells) do
                            if other_Cell.x == cell.x and other_Cell.y < target_Cell.y and other_Cell.die_number == 0 then
                                target_Cell = other_Cell
                            end
                        end
    
                        -- if a empty cell was found above, draw on that cell
                        if target_Cell then
                            target_Cell.die_number = die.getNumber()
                            -- increment the player points when placing a die
                            player.points = player.points + checkComboPoints("player",target_Cell.x,target_Cell.y,target_Cell.die_number)
                            roll = true
                            game.player_Turn = false
                            computer_Waiting = true 
                            computer_Delay = 0 
                        end
                        break
                    end
                end
            end
        end
    elseif game.state["menu"] then
        for index in pairs(buttons.menu_State) do
            buttons.menu_State[index]:checkPressed(x,y)
        end
    end
end

--[[ 
    Function for computer turn
]]
local function computerTurn()
    local available_Columns = {}
    for _, cell in pairs(enemy.enemyCells) do
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
        for _, cell in pairs(enemy.enemyCells) do
            if cell.x == randomColumn and cell.die_number == 0 then
                if not target_Cell or cell.y > target_Cell.y then
                    target_Cell = cell
                end
            end
        end

        if target_Cell then
            target_Cell.die_number = die.getNumber()
            -- incremet the enemy points
            enemy.points = enemy.points + checkComboPoints("enemy",target_Cell.x,target_Cell.y,target_Cell.die_number)
            roll = true
        end
    end

    game.player_Turn = true
end

--[[
    Check if a die collision as occured after a play 
]]
local function checkDieCollision()
    for _, player_Cell in pairs(player.playerCells) do
        for _, enemy_Cell in pairs(enemy.enemyCells) do
            if player_Cell.x == enemy_Cell.x and player_Cell.die_number == enemy_Cell.die_number then
                if not game.player_Turn then
                    -- decreasing the points from enemy
                    enemy.points = enemy.points - checkComboPoints("enemy",enemy_Cell.x,enemy_Cell.y,enemy_Cell.die_number)
                    enemy_Cell.die_number = 0 -- resets the current cell

                    -- check if there are die "above" the one destroyed
                    for i = #enemy.enemyCells, 1, -1 do
                        local cell = enemy.enemyCells[i] 
                        if cell.x == enemy_Cell.x and cell.y < enemy_Cell.y and cell.die_number ~= 0 then
                            -- bring down those dies
                            local temp = cell.die_number
                            cell.die_number = enemy_Cell.die_number
                            enemy_Cell.die_number = temp
                            enemy_Cell = cell
                        end
                    end
                else
                    -- decreasing the points from player
                    player.points = player.points - checkComboPoints("player",player_Cell.x,player_Cell.y,player_Cell.die_number)
                    player_Cell.die_number = 0
                    
                    -- check if there are die "bellow" the one destroyed
                    for i = 1, #player.playerCells do
                        local cell = player.playerCells[i]
                        if cell.x == player_Cell.x and cell.y > player_Cell.y and cell.die_number ~= 0 then
                            local temp = cell.die_number
                            cell.die_number = player_Cell.die_number
                            player_Cell.die_number = temp
                            player_Cell = cell
                        end
                    end
                end
            end
        end
    end
end

local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["running"] = state == "running"
    game.state["ended"] = state == "ended"
end

--[[
    Starts a new game
    Used on main menu and replay game
]]
local function startNewGame()
    changeGameState("running")
end

--[[ 
    Function to load the inital data
]]
function love.load()
    love.graphics.setBackgroundColor(115 / 255, 160 / 255, 30 / 255) -- green
    -- Creation of menu buttons 
    buttons.menu_State.play_Game = Button("Play Game",startNewGame,nil,120,40)
    buttons.menu_State.settings = Button("Settings",nil,nil,120,40)
    buttons.menu_State.exit_Game = Button("Exit",love.event.quit,nil,120,40)

    -- Creation of Cells 
    local cell_Size = 100
    local offset = cell_Size / 4
    -- create cells for player cells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = window_Height / 1.7 + i * (cell_Size )
            table.insert(player.playerCells, Cell(x, y, cell_Size))
        end
    end
    -- create cells for enemy cells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = 10 + i * (cell_Size)
            table.insert(enemy.enemyCells, Cell(x, y, cell_Size))
        end
    end
end

--[[ 
    Function to update the game logic
]]
function love.update(dt)

    if roll then
        local number = math.random(1, 6)
        die = Dice(number)
        roll = false
    end

    if not roll and not game.player_Turn and computer_Waiting then
        computer_Delay = computer_Delay + dt
        if computer_Delay >= 0.5 then
            computerTurn()
            roll = true
            computer_Waiting = false
        end
    end

    checkDieCollision() -- checking if there are die collision
end

--[[ 
    Function to draw on the screen
]]
function love.draw()
    if game.state["menu"] then
        -- if we are on menu state, draw the menu buttons created on love.local
        buttons.menu_State.play_Game:draw(30,20,35,25,{0.6,0.6,0.6},{0,0,0})
        buttons.menu_State.settings:draw(30,80,35,85,{0.6,0.6,0.6},{0,0,0})
        buttons.menu_State.exit_Game:draw(30,140,35,145,{0.6,0.6,0.6},{0,0,0})
    elseif game.state["running"] then
        love.graphics.setColor(0, 0, 0) -- black
        love.graphics.rectangle("fill", 30, 30, 100, 100)
        love.graphics.setColor(0.5, 0.5, 0.5) -- grey
        love.graphics.rectangle("fill", 35, 35, 90, 90)
    
        -- draw the player matrix
        for _, cell in pairs(player.playerCells) do
            cell:draw()
            if cell.die_number ~= 0 then
                local cell_Die = Dice(cell.die_number)
                local offset = 10
                cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80)
            end
        end
    
        -- draw the enemy matrix
        for _, cell in pairs(enemy.enemyCells) do
            cell:draw()
            if cell.die_number ~= 0 then
                local cell_Die = Dice(cell.die_number)
                local offset = 10
                cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80)
            end
        end
    
        -- draw the enemy points
        local last_Cell = enemy.enemyCells[#enemy.enemyCells]
        local points_Text_X = last_Cell.x + last_Cell.size + 5
        local points_Text_Y = last_Cell.y + last_Cell.size - 12
        love.graphics.setColor(1,1,1)
        love.graphics.print("Enemy points: "..enemy.points, points_Text_X, points_Text_Y)
    
        -- draw the player points
        local first_Cell = player.playerCells[1]
        local points_Text_X = first_Cell.x - first_Cell.size
        local points_Text_Y = first_Cell.y
        love.graphics.setColor(1,1,1)
        love.graphics.print("Player points: "..player.points, points_Text_X, points_Text_Y)
    
        -- draw the Die
        die:draw(40, 40, 80, 80) 
    end
end
