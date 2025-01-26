local love = require("love")

function Cell() 
    local x
    local y
    local size

return{

    draw = function (self,x,y,side_Size) -- draw a cell given x and y coordinates and a size
        self.x = x
        self.y = y
        self.size = side_Size
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill",x,y,side_Size,side_Size)
    end,

    checkPressed = function (self, x_Clicked, y_Clicked) -- checks if the player clicked on this cell
        return (x_Clicked >= self.x and x_Clicked <= self.x + self.size 
                and y_Clicked >= self.y and y_Clicked <= self.y + self.size)
         
    end
}


end


return Cell