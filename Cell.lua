local love = require("love")

function Cell(x, y, size)
    return {
        x = x,
        y = y,
        size = size,

        draw = function(self)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
        end,

        checkPressed = function(self, x_Clicked, y_Clicked)
            return (x_Clicked >= self.x and x_Clicked <= self.x + self.size 
                    and y_Clicked >= self.y and y_Clicked <= self.y + self.size)
        end
    }
end

return Cell
