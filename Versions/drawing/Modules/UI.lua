local ChatUI = {
    DrawingObjects = {},
    Create = function(self, Data)
        if Data.Type == "Button" then
            local Button = Drawing.new("Circle")
            Button.Radius = 2
        end
    end
}

ChatUI:Create({
    Type = "Button"
})