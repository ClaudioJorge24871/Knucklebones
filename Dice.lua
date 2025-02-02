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
        drawRoundedDie = function(self, x, y, width, height, radius)
            local segments = 10
            love.graphics.arc("fill", x + radius, y + radius, radius, math.pi, 1.5 * math.pi, segments)
            love.graphics.arc("fill", x + width - radius, y + radius, radius, 1.5 * math.pi, 2 * math.pi, segments)
            love.graphics.arc("fill", x + radius, y + height - radius, radius, 0.5 * math.pi, math.pi, segments)
            love.graphics.arc("fill", x + width - radius, y + height - radius, radius, 0, 0.5 * math.pi, segments)
            love.graphics.rectangle("fill", x + radius, y, width - 2 * radius, height)
            love.graphics.rectangle("fill", x, y + radius, width, height - 2 * radius)
        end,

        -- draw the die given coordinates and size
        draw = function(self, x_Pos, y_Pos, width, height)
            love.graphics.setColor(styles.colors.egg_grey)
            self:drawRoundedDie(x_Pos, y_Pos, width, height, 5)
            love.graphics.setColor(styles.colors.egg_white)
            self:drawRoundedDie(x_Pos + 5, y_Pos + 5, width - 10, height - 10, 5)
            love.graphics.setColor(styles.colors.black)
            draw_helper(x_Pos,y_Pos,width,height)
        end,

        getNumber = function (self)
            return number
        end
    }

end


return Dice