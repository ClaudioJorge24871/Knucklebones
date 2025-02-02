local love = require("love")
local socket = require 'socket'
local Dice = require("Dice")
local Cell = require("Cell")
local Button = require("Button")
local moonshine = require("moonshine") 

math.randomseed(os.time())

local roll = true
local die = Dice(0)
local menu_background_image = nil

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
    player_Turn = math.random(1,10) >= 5 ,
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

_G.styles = {
    colors = {
        black = {0,0,0},
        white = {1,1,1},
        grey = {0.5, 0.5, 0.5},
        blue = {18 / 255, 108 / 255, 248 / 255},
        red = {248 / 255, 39 / 255, 18 / 255},
        purple = {196/255, 18 / 255, 248 / 255}
    },
    fonts = {
        title = {
            font_Size = 80
        },
        default_Font = {
            font_Size = 16
        },
        buttons = {
            font_Size = 30
        }
    }
}

local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["running"] = state == "running"
    game.state["ended"] = state == "ended"
end


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
    Checks if any player has its matrix full
]]
local function checkEndedGame()
    local playerFull = true
    for _, cell in pairs(player.playerCells) do
        if cell.die_number == 0 then
            playerFull = false
            break
        end
    end

    local enemyFull = true
    for _, cell in pairs(enemy.enemyCells) do
        if cell.die_number == 0 then
            enemyFull = false
            break
        end
    end

    if playerFull or enemyFull then
        changeGameState("ended")
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

--[[
    Starts a new game
    Used on main menu and replay game
]]
local function startNewGame()
    changeGameState("running")
    roll = true
    if not player.player_Turn then
        computerTurn()
    end
end

--[[ 
    Function to load the inital data
]]
function love.load()
    menu_background_image = love.graphics.newImage('/images/bkg_image_knbones.png')
    _G.bgWidth = menu_background_image:getWidth()
    _G.bgHeight = menu_background_image:getHeight()

    -- Setting up moonshine
    love.graphics.setBackgroundColor(0, 0, 0)
    _G.effect = moonshine(moonshine.effects.vignette)
    
    effect.vignette.radius = 1.5

    _G.waterShader = love.graphics.newShader("water.frag") -- setting up the water effect

    -- Creation of menu buttons 
    buttons.menu_State.play_Game = Button("Play Game",startNewGame,nil,180,60)
    buttons.menu_State.settings = Button("Settings",nil,nil,180,60)
    buttons.menu_State.exit_Game = Button("Exit",love.event.quit,nil,180,60)

    -- Using game title font for menu  
    styles.fonts.title.font = love.graphics.newFont('/fonts/ANUNEDW_.TTF',styles.fonts.title.font_Size)
    styles.fonts.default_Font.font = love.graphics.getFont()
    styles.fonts.buttons.font = love.graphics.newFont('/fonts/BebasNeue-Regular.TTF',styles.fonts.buttons.font_Size)

    -- Giving value to die of menu
    local random_number = math.random(1,6)
    die = Dice(random_number)

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
    shaderTime = (shaderTime or 0) + dt /5
    waterShader:send("time", shaderTime)

    if game.state["menu"] then
        for index in pairs(buttons.menu_State) do
            local mouse_X , mouse_Y = love.mouse.getPosition()
            buttons.menu_State[index]:checkHover(mouse_X, mouse_Y)
        end
    elseif game.state["running"] then
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

        checkEndedGame() -- checking if any grid is full
        checkDieCollision() -- checking if there are die collision
    end
end


local function drawEverything()
    -- Calculate scaling factors to fit the window
    local scaleX = window_Width / bgWidth
    local scaleY = window_Height / bgHeight

    -- Draw the background with the shader and scaling
    love.graphics.setShader(waterShader)
    love.graphics.draw(menu_background_image, 0, 0, 0, scaleX, scaleY)
    love.graphics.setShader()

    if game.state["menu"] then
        -- if we are on menu state, draw the menu buttons created on love.local
        buttons.menu_State.play_Game:draw(window_Width / 3.5,window_Height / 1.2,window_Width / 3.5 + 8, window_Height / 1.2 + 10, styles.colors.blue,styles.colors.white)
        buttons.menu_State.settings:draw(window_Width / 2.35,window_Height / 1.2,window_Width / 2.35 + 8, window_Height / 1.2 + 10, styles.colors.purple,styles.colors.white)
        buttons.menu_State.exit_Game:draw(window_Width / 1.76, window_Height / 1.2, window_Width / 1.76 + 8, window_Height / 1.2 + 10, styles.colors.red, styles.colors.white)

        -- Draw the title 
        love.graphics.setFont(styles.fonts.title.font)
        love.graphics.printf("Knucklebones",window_Width / 2 - 16 * 20 ,20, window_Width, "left")
        love.graphics.setFont(styles.fonts.default_Font.font) -- reset to default font

        -- Draw a random die
        die:draw(window_Width / 2 - 70 , 200 , 100, 100)      
        
    else -- if its running or ended
    
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
        love.graphics.setColor(styles.colors.white)
        love.graphics.print("Enemy points: "..enemy.points, points_Text_X, points_Text_Y)
    
        -- draw the player points
        local first_Cell = player.playerCells[1]
        local points_Text_X = first_Cell.x - first_Cell.size
        local points_Text_Y = first_Cell.y
        love.graphics.setColor(styles.colors.white)
        love.graphics.print("Player points: "..player.points, points_Text_X, points_Text_Y)
    
        -- draw the Die
        die:draw(50, window_Height / 2, 100, 100) 

        if game.state["ended"] then
            love.graphics.setFont(styles.fonts.title.font)
            love.graphics.setColor(styles.colors.white)
            if player.points >= enemy.points then -- if the player has more points, wins
                love.graphics.printf("Player wins",0,window_Height / 2.5,window_Width,"center") 
            else
                love.graphics.printf("Computer wins",0,window_Height / 2.5,window_Width,"center") 
            end
            love.graphics.setFont(styles.fonts.default_Font.font)
        end
       
        -- draw the Die
        die:draw(50, window_Height / 2, 100, 100) 
    end
end

--[[ 
    Function to draw on the screen
]]
function love.draw()
    -- Apply moonshine effect to game elements
    effect(function()
        drawEverything()
    end)
end


function love.resize(w, h)
    window_Width, window_Height = w, h
end
