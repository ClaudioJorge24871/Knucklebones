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
        white = {1, 1, 1},
        egg_white = {1, 244 / 255, 222 / 255},
        egg_grey = {216 / 255, 204 / 255, 188 / 255},
        grey = {0.5, 0.5, 0.5},
        blue = {18 / 255, 108 / 255, 248 / 255},
        red = {248 / 255, 39 / 255, 18 / 255},
        purple = {196/255, 18 / 255, 248 / 255},
        cell_border = {45 / 255, 31 / 255, 15 / 255},
        cell_color = {25 / 255, 20 / 255, 13 / 255},
        soft_yellow = {1, 231/255, 183/255},
        soft_blue = {156 / 255, 159 / 255, 1}
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
        },
        sub_Title = {
            font_Size = 40
        },
    }
}

local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["running"] = state == "running"
    game.state["ended"] = state == "ended"
end

local function isPartOfCombo(cell, person)
    local comboCount = 1
    local cells = (person == "player") and player.playerCells or enemy.enemyCells
    
    for _, otherCell in pairs(cells) do
        if otherCell.x == cell.x and otherCell ~= cell and otherCell.die_number == cell.die_number then
            comboCount = comboCount + 1
        end
    end
    
    return comboCount
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
    Starts a new game
    Used on main menu and replay game
]]
local function startNewGame()
        
    changeGameState("running")
    roll = true
    if not player.player_Turn then
        computerTurn()
    end

    -- cleans all cells
    for _,cell in pairs(player.playerCells) do
        cell.die_number = 0
        player.points = 0
    end
    for _, cell in pairs(enemy.enemyCells) do
        cell.die_number = 0
        enemy.points = 0
    end
    player.player_Turn = not player.player_Turn
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
    else
        startNewGame()
    end
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

    _G.waterShader = love.graphics.newShader("bckgrnd_effect.frag") -- setting up the water effect

    -- Creation of menu buttons 
    buttons.menu_State.play_Game = Button("Play Game",startNewGame,nil,180,60)
    buttons.menu_State.settings = Button("Settings",nil,nil,180,60)
    buttons.menu_State.exit_Game = Button("Exit",love.event.quit,nil,180,60)

    -- Using game title font for menu  
    styles.fonts.title.font = love.graphics.newFont('/fonts/ANUNEDW_.TTF',styles.fonts.title.font_Size)
    styles.fonts.default_Font.font = love.graphics.getFont()
    styles.fonts.buttons.font = love.graphics.newFont('/fonts/BebasNeue-Regular.TTF',styles.fonts.buttons.font_Size)
    styles.fonts.sub_Title.font = love.graphics.newFont('/fonts/ANUNEDW_.TTF',styles.fonts.sub_Title.font_Size)

    -- Giving value to die of menu
    local random_number = math.random(1,6)
    die = Dice(random_number)

    -- Creation of Cells 
    local cell_Size = 100
    local offset = 10
    -- create cells for player cells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = window_Height / 1.7 + i * (cell_Size  + offset)
            table.insert(player.playerCells, Cell(x, y, cell_Size))
        end
    end
    -- create cells for enemy cells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = 10 + i * (cell_Size +  offset)
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
        local anyHovered = false
        local mouse_X, mouse_Y = love.mouse.getPosition()
        for _, button in pairs(buttons.menu_State) do
            button:checkHover(mouse_X, mouse_Y)
            if button.isHovered then
                anyHovered = true
            end
        end
        -- Set cursor based on any hovered button
        if anyHovered then
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
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
    else
        if love.keyboard.isDown("escape") then
            changeGameState("menu")
        end
    end
end

--[[ 
    Function to draw on the screen
]]
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
        love.graphics.printf("Knucklebones", 0, 50, window_Width, "center")  -- Changed y-position to 50 and centered text
        love.graphics.setFont(styles.fonts.default_Font.font)

        -- Draw a random die on the menu screen
        die:draw(window_Width / 2 - 70 , 200 , 100, 100, styles.colors.egg_white)      
        
    else -- if its running or ended
    
        -- draw the player matrix
        for _, cell in pairs(player.playerCells) do
            cell:draw()
            if cell.die_number ~= 0 then
                local cell_Die = Dice(cell.die_number)
                local offset = 10
                local dieColor = styles.colors.egg_white
                if isPartOfCombo(cell,"player") == 2 then
                    dieColor = styles.colors.soft_yellow
                elseif isPartOfCombo(cell,"player") == 3 then
                    dieColor = styles.colors.soft_blue
                end
                cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80, dieColor)
            end
        end
    
        -- draw the enemy matrix
        for _, cell in pairs(enemy.enemyCells) do
            cell:draw()
            if cell.die_number ~= 0 then
                local cell_Die = Dice(cell.die_number)
                local offset = 10
                local dieColor = styles.colors.egg_white
                if isPartOfCombo(cell,"enemy") == 2 then
                    dieColor = styles.colors.soft_yellow
                elseif isPartOfCombo(cell,"enemy") == 3 then
                    dieColor = styles.colors.soft_blue
                end
                cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80, dieColor)
            end
        end
    
        love.graphics.setColor(styles.colors.white)
        --draw the enemy text
        local last_Cell = enemy.enemyCells[#enemy.enemyCells]
        local enemy_Text_X = last_Cell.x + last_Cell.size *3
        local enemy_Text_Y = last_Cell.y + last_Cell.size / 2
        love.graphics.setFont(styles.fonts.sub_Title.font)
        love.graphics.print("Enemy",enemy_Text_X,enemy_Text_Y)

        -- draw the enemy points
        local points_Text_X = last_Cell.x + last_Cell.size * 3.5
        local points_Text_Y = enemy_Text_Y + last_Cell.size / 2
        love.graphics.print(enemy.points, points_Text_X, points_Text_Y)


        -- draw the player points
        local first_Cell = player.playerCells[1]
        local player_Text_X = first_Cell.x/2
        local player_Text_Y = first_Cell.y 
        love.graphics.print("Player",player_Text_X,player_Text_Y)
    
        -- draw the player points
        local points_Text_X = first_Cell.x / 2 + first_Cell.size/2
        local points_Text_Y = first_Cell.y + first_Cell.size / 2
        love.graphics.print(player.points, points_Text_X, points_Text_Y)
    
        -- draw the Die
        die:draw(50, window_Height / 2, 100, 100, styles.colors.egg_white) 

        if game.state["ended"] then
            love.graphics.setFont(styles.fonts.title.font)
            love.graphics.setColor(styles.colors.white)
            if player.points >= enemy.points then -- if the player has more points, wins
                love.graphics.printf("Player wins",-50,window_Height / 2.5,window_Width,"center") 
            else
                love.graphics.printf("Computer wins",-50,window_Height / 2.5,window_Width,"center") 
            end
            love.graphics.setFont(styles.fonts.buttons.font)
            -- print a legend for replaying or go to menu
            love.graphics.print("Press ESC to exit or click to play again", 20, window_Height - 50)
            love.graphics.setFont(styles.fonts.default_Font.font)
        end
       
        -- draw the Die
        die:draw(50, window_Height / 2, 100, 100,styles.colors.egg_white) 
    end
end

--[[ 
    Calls draw everything with a filter
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
