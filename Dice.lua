local love = require("love")

math.randomseed(os.time())

-- Object to create a die
function Dice(_number)
    local DEFAULT_SIDES = 6
    local number = _number

    -- draws the dice points
    local draw_helper = function(x_Pos, y_Pos, width, height)
        local cx , cy = x_Pos + width/2, y_Pos + height / 2 -- getting the center coordinates
        local dot_Radius = math.min(width,height) / 10
        local offset = width / 4                            -- distance of dots from the center

        local dot_positions = {
            [1] = {{cx,cy}}, -- center
            [2] = {{x_Pos + width - offset, y_Pos + offset},{x_Pos + offset, y_Pos + height - offset}},
            [3] = {{x_Pos + width - offset, y_Pos + offset},{x_Pos + offset, y_Pos + height - offset},{cx,cy}},
            [4] = {{x_Pos + width - offset, y_Pos + offset},{x_Pos + offset, y_Pos + height - offset},
                   {x_Pos + offset, y_Pos + offset},{x_Pos + width - offset, y_Pos + height - offset}},
            [5] = {{x_Pos + width - offset, y_Pos + offset},{x_Pos + offset, y_Pos + height - offset},
                   {x_Pos + offset, y_Pos + offset},{x_Pos + width - offset, y_Pos + height - offset},{cx,cy}},
            [6] = {{x_Pos + width - offset, y_Pos + offset},{x_Pos + offset, y_Pos + height - offset},
                   {x_Pos + offset, y_Pos + offset},{x_Pos + width - offset, y_Pos + height - offset},
                   {x_Pos + width - offset, y_Pos + height/2},{x_Pos + offset, y_Pos + height/2}}
        }
    
        for _,position in pairs(dot_positions[number]) do
            love.graphics.circle("fill",position[1],position[2],dot_Radius,30)
        end
    end

    return{
        -- draw the die given coordinates and size
        draw = function(self, x_Pos, y_Pos, width, height)
            love.graphics.setColor(styles.colors.white) -- white
            love.graphics.rectangle("fill", x_Pos + 5, y_Pos + 5, width, height) -- shadow 
            love.graphics.rectangle("fill", x_Pos, y_Pos, width, height)
            love.graphics.setColor(styles.colors.black) -- black
            love.graphics.rectangle("line",x_Pos - 2, y_Pos - 2, width + 2, height + 2)
            draw_helper(x_Pos,y_Pos,width,height)
        end,

        getNumber = function (self)
            return number
        end
    }

end


return Dice