local love = require("love")

function Button(_text, _func, _func_Param, _width, _height, _borderRadius)
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
        borderRadius = _borderRadius or 10, -- default border radius
        button_Color = {},
        isHovered = false, -- Track hover state

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
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end,

        -- Function to draw a rounded rectangle
        drawRoundedRectangle = function (self, x, y, width, height, radius)
            local segments = 10
            love.graphics.arc("fill", x + radius, y + radius, radius, math.pi, 1.5 * math.pi, segments)
            love.graphics.arc("fill", x + width - radius, y + radius, radius, 1.5 * math.pi, 2 * math.pi, segments)
            love.graphics.arc("fill", x + radius, y + height - radius, radius, 0.5 * math.pi, math.pi, segments)
            love.graphics.arc("fill", x + width - radius, y + height - radius, radius, 0, 0.5 * math.pi, segments)
            love.graphics.rectangle("fill", x + radius, y, width - 2 * radius, height)
            love.graphics.rectangle("fill", x, y + radius, width, height - 2 * radius)
        end,

        -- Draw the button
        draw = function (self, button_X, button_Y, text_X, text_Y, button_Color, text_Color)
            love.graphics.setFont(styles.fonts.buttons.font)
            self.button_X = button_X
            self.button_Y = button_Y

            self.button_Color = button_Color

            -- Setting default values for text coordinates if they don't exist
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

            -- Shadow
            love.graphics.setColor(styles.colors.white) -- black
            self:drawRoundedRectangle(self.button_X + 5, self.button_Y + 5, self.width, self.height, self.borderRadius)

            -- Border
            love.graphics.setColor(styles.colors.black) -- white
            self:drawRoundedRectangle(self.button_X - 1, self.button_Y - 1, self.width + 2, self.height + 2, self.borderRadius)

            -- Button
            local currentColor = self.button_Color
            if self.isHovered then
                -- Darken the color by reducing its RGB values
                currentColor = {
                    math.max(currentColor[1] - 0.2, 0), -- Reduce red
                    math.max(currentColor[2] - 0.2, 0), -- Reduce green
                    math.max(currentColor[3] - 0.2, 0), -- Reduce blue
                    currentColor[4] or 1 -- Preserve alpha if it exists
                }
            end
            love.graphics.setColor(currentColor)
            self:drawRoundedRectangle(self.button_X, self.button_Y, self.width, self.height, self.borderRadius)

            -- Text
            love.graphics.setColor(text_Color)
            love.graphics.printf(self.text, self.text_X, self.text_Y, self.width - 5, "center")

            love.graphics.setColor(styles.colors.white) -- "resetting" color
        end,

        -- Check if the button is being hovered
        -- In Button.lua, update the checkHover function:
        checkHover = function (self, mouse_X, mouse_Y)
            self.isHovered = false
            if mouse_X >= self.button_X and mouse_X <= self.button_X + self.width then
                if mouse_Y >= self.button_Y and mouse_Y <= self.button_Y + self.height then
                    self.isHovered = true
                end
            end
        end
    }
end

return Button