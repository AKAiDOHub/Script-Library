-- UI Library for Roblox
-- By: [Your Name]
-- Version: 1.0

local UI = {}
UI.__index = UI

-- Theme settings
UI.Themes = {
    Dark = {
        MainColor = Color3.fromRGB(40, 40, 40),
        SecondaryColor = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(0, 120, 215),
        Font = Enum.Font.Gotham
    },
    Light = {
        MainColor = Color3.fromRGB(240, 240, 240),
        SecondaryColor = Color3.fromRGB(220, 220, 220),
        TextColor = Color3.fromRGB(0, 0, 0),
        AccentColor = Color3.fromRGB(0, 120, 215),
        Font = Enum.Font.Gotham
    }
}

-- Create a new UI instance
function UI.new(themeName)
    local self = setmetatable({}, UI)
    
    -- Set theme
    self.Theme = UI.Themes[themeName] or UI.Themes.Dark
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Container for elements
    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.BackgroundTransparency = 1
    self.Container.Size = UDim2.new(1, 0, 1, 0)
    self.Container.Parent = self.ScreenGui
    
    return self
end

-- Create a button
function UI:CreateButton(options)
    options = options or {}
    local name = options.Name or "Button"
    local position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    local size = options.Size or UDim2.new(0, 200, 0, 50)
    local callback = options.Callback or function() end
    
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = name
    button.Position = position
    button.Size = size
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.BackgroundColor3 = self.Theme.AccentColor
    button.TextColor3 = self.Theme.TextColor
    button.Font = self.Theme.Font
    button.TextSize = 14
    button.AutoButtonColor = true
    button.Parent = self.Container
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Button effects
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.1),
            {BackgroundTransparency = 0.1}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.1),
            {BackgroundTransparency = 0}
        ):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return button
end

-- Create a toggle switch
function UI:CreateToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    local default = options.Default or false
    local callback = options.Callback or function() end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Position = position
    toggleFrame.Size = UDim2.new(0, 200, 0, 30)
    toggleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleFrame.BackgroundColor3 = self.Theme.SecondaryColor
    toggleFrame.BackgroundTransparency = 0.5
    toggleFrame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = name
    label.TextColor3 = self.Theme.TextColor
    label.Font = self.Theme.Font
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Text = ""
    toggleButton.Size = UDim2.new(0.25, 0, 0.7, 0)
    toggleButton.Position = UDim2.new(0.725, 0, 0.15, 0)
    toggleButton.BackgroundColor3 = default and self.Theme.AccentColor or Color3.fromRGB(100, 100, 100)
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local state = default
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        if state then
            game:GetService("TweenService"):Create(
                toggleButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = self.Theme.AccentColor}
            ):Play()
        else
            game:GetService("TweenService"):Create(
                toggleButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}
            ):Play()
        end
        callback(state)
    end)
    
    return {
        SetState = function(self, newState)
            state = newState
            if state then
                toggleButton.BackgroundColor3 = self.Theme.AccentColor
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
        end,
        GetState = function(self)
            return state
        end
    }
end

-- Create a slider
function UI:CreateSlider(options)
    options = options or {}
    local name = options.Name or "Slider"
    local position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local callback = options.Callback or function() end
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name
    sliderFrame.Position = position
    sliderFrame.Size = UDim2.new(0, 200, 0, 60)
    sliderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderFrame.BackgroundColor3 = self.Theme.SecondaryColor
    sliderFrame.BackgroundTransparency = 0.5
    sliderFrame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = name
    label.TextColor3 = self.Theme.TextColor
    label.Font = self.Theme.Font
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.Theme.TextColor
    valueLabel.Font = self.Theme.Font
    valueLabel.TextSize = 14
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, -20, 0, 20)
    valueLabel.Position = UDim2.new(0, 10, 0, 25)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -20, 0, 5)
    track.Position = UDim2.new(0, 10, 0, 45)
    track.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    track.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = self.Theme.AccentColor
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local handle = Instance.new("TextButton")
    handle.Name = "Handle"
    handle.Text = ""
    handle.Size = UDim2.new(0, 15, 0, 15)
    handle.Position = UDim2.new((default - min) / (max - min), -5, 0, -5)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    local dragging = false
    
    local function updateValue(x)
        local relativeX = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local ratio = relativeX / track.AbsoluteSize.X
        local value = math.floor(min + (max - min) * ratio)
        
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        handle.Position = UDim2.new(ratio, 0, 0, -5)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    handle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateValue(input.Position.X)
        end
    end)
    
    return {
        SetValue = function(self, value)
            value = math.clamp(value, min, max)
            local ratio = (value - min) / (max - min)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            handle.Position = UDim2.new(ratio, 0, 0, -5)
            valueLabel.Text = tostring(value)
        end
    }
end

-- Create a text input
function UI:CreateInput(options)
    options = options or {}
    local name = options.Name or "Input"
    local position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    local placeholder = options.Placeholder or "Type here..."
    local callback = options.Callback or function() end
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = name
    inputFrame.Position = position
    inputFrame.Size = UDim2.new(0, 200, 0, 40)
    inputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    inputFrame.BackgroundColor3 = self.Theme.SecondaryColor
    inputFrame.BackgroundTransparency = 0.5
    inputFrame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Text = ""
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = self.Theme.TextColor
    textBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    textBox.Font = self.Theme.Font
    textBox.TextSize = 14
    textBox.BackgroundTransparency = 1
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textBox.Text)
        end
    end)
    
    return {
        SetText = function(self, text)
            textBox.Text = text
        end,
        GetText = function(self)
            return textBox.Text
        end
    }
end

-- Create a label
function UI:CreateLabel(options)
    options = options or {}
    local text = options.Text or "Label"
    local position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    local size = options.Size or UDim2.new(0, 200, 0, 30)
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = text
    label.TextColor3 = self.Theme.TextColor
    label.Font = self.Theme.Font
    label.TextSize = options.TextSize or 14
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Center
    label.Parent = self.Container
    
    return {
        SetText = function(self, newText)
            label.Text = newText
        end
    }
end

-- Destroy the UI
function UI:Destroy()
    self.ScreenGui:Destroy()
end

return UI
