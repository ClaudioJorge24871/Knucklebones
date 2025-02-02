local love = require("love")

function Cell(x, y, size)
    return {
        x = x,
        y = y,
        size = size,
        die_number = 0,

        draw = function(self)
            love.graphics.setColor(styles.colors.cell_border) -- border
            love.graphics.rectangle("fill", self.x - 2, self.y - 2, self.size + 4, self.size + 4)
            love.graphics.setColor(styles.colors.cell_color) 
            love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
        end,

        checkPressed = function(self, x_Clicked, y_Clicked)
            return (x_Clicked >= self.x and x_Clicked <= self.x + self.size 
                    and y_Clicked >= self.y and y_Clicked <= self.y + self.size)
        end
    }
end

return Cell
