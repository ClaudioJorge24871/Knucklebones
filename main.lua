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

-- Variável para temporização
local computer_Delay = 0
local computer_Waiting = false -- Indica se o computador está aguardando

function love.mousepressed(x, y, button, istouch, presses)
    if player_Turn and (not roll) and button == 1 then
        for _, cell in pairs(playerCells) do
            if cell:checkPressed(x, y) then
                -- lógica para quando uma célula é clicada
                local target_Cell = cell
                if target_Cell.die_number == 0 then
                    -- verificar se há células vazias acima
                    for _, other_Cell in pairs(playerCells) do
                        if other_Cell.x == cell.x and other_Cell.y < target_Cell.y and other_Cell.die_number == 0 then
                            target_Cell = other_Cell
                        end
                    end

                    -- se uma célula vazia acima for encontrada, desenhe o dado nela
                    if target_Cell then
                        target_Cell.die_number = die.getNumber()
                        roll = true
                        player_Turn = false
                        computer_Waiting = true -- Inicia o atraso para o computador jogar
                        computer_Delay = 0    -- Reinicia o contador de atraso
                    end
                    break
                end
            end
        end
    end
end

--[[ 
    Função para a jogada do computador 
]]
local function computerTurn()
    local available_Columns = {}
    for _, cell in pairs(enemyCells) do
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
        end
    end
end

--[[ 
    Função para carregar os dados iniciais do jogo 
]]
function love.load()
    love.graphics.setBackgroundColor(115 / 255, 160 / 255, 30 / 255) -- verde

    local cell_Size = 100
    local offset = cell_Size / 4
    -- criar células para playerCells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = window_Height / 1.7 + i * (cell_Size + offset)
            table.insert(playerCells, Cell(x, y, cell_Size))
        end
    end
    -- criar células para enemyCells
    for i = 0, 2 do
        for j = 0, 2 do
            local x = window_Width / 2.7 + j * (cell_Size + offset)
            local y = 10 + i * (cell_Size + offset)
            table.insert(enemyCells, Cell(x, y, cell_Size))
        end
    end
end

--[[ 
    Função para atualizar as atividades do programa 
]]
function love.update(dt)
    for _, player_Cell in pairs(playerCells) do
        for _, enemy_Cell in pairs(enemyCells) do
            if player_Cell.x == enemy_Cell.x and player_Cell.die_number == enemy_Cell.die_number then
                if not player_Turn then
                    enemy_Cell.die_number = 0
                else
                    player_Cell.die_number = 0
                end
            end
        end
    end

    if roll then
        local number = math.random(1, 6)
        die = Dice(number)
        roll = false
    end

    if not roll and not player_Turn and computer_Waiting then
        -- Incrementa o tempo de atraso
        computer_Delay = computer_Delay + dt
        if computer_Delay >= 1 then -- Espera 1 segundo
            computerTurn()
            player_Turn = true
            roll = true
            computer_Waiting = false
        end
    end
end

--[[ 
    Função para desenhar na tela 
]]
function love.draw()
    love.graphics.setColor(0, 0, 0) -- preto
    love.graphics.rectangle("fill", 30, 30, 100, 100)
    love.graphics.setColor(0.5, 0.5, 0.5) -- cinza
    love.graphics.rectangle("fill", 35, 35, 90, 90)

    -- desenhar as células do jogador
    for _, cell in pairs(playerCells) do
        cell:draw()
        if cell.die_number ~= 0 then
            local cell_Die = Dice(cell.die_number)
            local offset = 10
            cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80)
        end
    end

    -- desenhar as células do inimigo
    for _, cell in pairs(enemyCells) do
        cell:draw()
        if cell.die_number ~= 0 then
            local cell_Die = Dice(cell.die_number)
            local offset = 10
            cell_Die:draw(cell.x + offset, cell.y + offset, 80, 80)
        end
    end

    if not roll then
        die:draw(40, 40, 80, 80)
    end
end
