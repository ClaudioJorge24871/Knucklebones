local love = require("love")
local Dice = require("Dice")
local Cell = require("Cell")

local dice = Dice(6)
local window_Width = love.graphics.getWidth()
local window_Height = love.graphics.getHeight()
local matrix_Rect_Size = 100

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

local Cell = Cell()

local function drawPlayerMatrix() 
    local offset = matrix_Rect_Size / 3
    for i = -1, 1 do
        Cell:draw(window_Width / 2.25 + i*( matrix_Rect_Size + offset), 
                  window_Height - (4*matrix_Rect_Size), matrix_Rect_Size)
        Cell:draw(window_Width / 2.25 + i*( matrix_Rect_Size + offset), 
                  window_Height - (3*matrix_Rect_Size) + offset, matrix_Rect_Size)
        Cell:draw(window_Width / 2.25 + i*( matrix_Rect_Size + offset), 
                  window_Height - (1.7*matrix_Rect_Size) + offset, matrix_Rect_Size)
    end

    
end

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
    -- dice:draw(55,55,50,50)

    for i = 1, #player_Matrix do
        for j = 1, #player_Matrix[i] do
            drawPlayerMatrix()

            if player_Matrix[i][j] ~= 0 then
                
            end
        end
    end
end