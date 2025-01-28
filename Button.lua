local love = require("love")

function Button(_text, _func, _func_Param, _width, _height)
    return {
        width = _width or 100, -- default width
        height = _height or 100, -- default height
        func = _func or function() print("This button has no function") end,
        func_Param = _func_Param,
        text = _text or "No text",
        button_X = 0,
        button_Y = 0,
        text_X = 0,
        text_Y = 0,

        -- Check if the button was pressed
        checkPressed = function (self, mouse_X, mouse_Y)
            if mouse_X >= self.button_X and self.button_X + self.width >= mouse_X then
                if mouse_Y >= self.button_Y and self.button_Y + self.height >= mouse_Y then
                    if self.func_Param then
                        self.func(self.func_Param)
                    else
                        self.func()
                    end
                end
            end  
        end,

        -- draw the button
        draw = function (self, button_X, button_Y, text_X, text_Y, button_Color, text_Color)
            self.button_X = button_X
            self.button_Y = button_Y

            -- setting default values for text coordinates if they dont exist
            if text_X then
                self.text_X = text_X
            else
                self.text_X = button_X
            end
            if text_Y then
                self.text_Y = text_Y
            else
                self.text_Y = button_Y
            end

            love.graphics.setColor(button_Color)
            love.graphics.rectangle("fill", self.button_X, self.button_Y, self.width, self.height)

            love.graphics.setColor(text_Color)
            love.graphics.print(self.text_X, self.text_X, self.text_Y)

            love.graphics.setColor(1,1,1) -- "resetting" color

        end
    }
    
end

return Button