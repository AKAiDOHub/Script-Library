-- UI Library by DeepSeek
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "ImGuiLibrary"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Configurações globais
local config = {
    theme = "Darker", -- "White" ou "Darker"
    open = true,
    draggable = true,
    position = UDim2.new(0.5, -150, 0.5, -200),
    size = UDim2.new(0, 300, 0, 400),
    accentColor = Color3.fromRGB(0, 120, 215),
    font = Enum.Font.SourceSans,
    textSize = 14,
    mobileFriendly = true,
    animationSpeed = 0.15
}

-- Cores dos temas
local themes = {
    White = {
        background = Color3.fromRGB(240, 240, 240),
        text = Color3.fromRGB(50, 50, 50),
        element = Color3.fromRGB(220, 220, 220),
        elementHover = Color3.fromRGB(210, 210, 210),
        border = Color3.fromRGB(180, 180, 180)
    },
    Darker = {
        background = Color3.fromRGB(30, 30, 30),
        text = Color3.fromRGB(220, 220, 220),
        element = Color3.fromRGB(50, 50, 50),
        elementHover = Color3.fromRGB(70, 70, 70),
        border = Color3.fromRGB(80, 80, 80)
    }
}

-- Elementos principais
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = themes[config.theme].background
mainFrame.BorderColor3 = themes[config.theme].border
mainFrame.BorderSizePixel = 1
mainFrame.Position = config.position
mainFrame.Size = config.size
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.BackgroundColor3 = config.accentColor
topBar.BorderSizePixel = 0
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(0.5, -10, 1, 0)
title.Font = config.font
title.Text = "ImGui Library"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.BackgroundTransparency = 1
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Font = config.font
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 16
closeButton.Parent = topBar

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.BackgroundTransparency = 1
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Parent = mainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Name = "TabListLayout"
tabListLayout.FillDirection = Enum.FillDirection.Horizontal
tabListLayout.Padding = UDim.new(0, 5)
tabListLayout.Parent = tabContainer

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.BackgroundTransparency = 1
contentContainer.Position = UDim2.new(0, 0, 0, 70)
contentContainer.Size = UDim2.new(1, 0, 1, -70)
contentContainer.Parent = mainFrame

local contentScrolling = Instance.new("ScrollingFrame")
contentScrolling.Name = "ContentScrolling"
contentScrolling.BackgroundTransparency = 1
contentScrolling.BorderSizePixel = 0
contentScrolling.Size = UDim2.new(1, 0, 1, 0)
contentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScrolling.ScrollBarThickness = 5
contentScrolling.ScrollBarImageColor3 = config.accentColor
contentScrolling.Parent = contentContainer

local contentLayout = Instance.new("UIListLayout")
contentLayout.Name = "ContentLayout"
contentLayout.Padding = UDim.new(0, 10)
contentLayout.Parent = contentScrolling

-- Variáveis de estado
local dragging = false
local dragStartPos
local tabs = {}
local currentTab = nil
local elements = {}
local mobileTouchPositions = {}

-- Funções utilitárias
local function tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or config.animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function updateCanvas()
    contentScrolling.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
end

local function applyTheme()
    local theme = themes[config.theme]
    
    mainFrame.BackgroundColor3 = theme.background
    mainFrame.BorderColor3 = theme.border
    
    for _, element in pairs(elements) do
        if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
            element.TextColor3 = theme.text
        end
        
        if element:IsA("Frame") and element.Name:find("Element") then
            element.BackgroundColor3 = theme.element
            element.BorderColor3 = theme.border
        end
    end
end

local function createElement(instanceType, properties)
    local element = Instance.new(instanceType)
    
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            element[prop] = value
        end
    end
    
    if properties.Parent then
        element.Parent = properties.Parent
    end
    
    table.insert(elements, element)
    return element
end

-- Funções de UI
local function createTab(name)
    local tabButton = createElement("TextButton", {
        Name = name.."Tab",
        BackgroundColor3 = themes[config.theme].element,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Size = UDim2.new(0, 80, 0, 30),
        Font = config.font,
        Text = name,
        TextColor3 = themes[config.theme].text,
        TextSize = config.textSize,
        Parent = tabContainer
    })
    
    local tabContent = createElement("Frame", {
        Name = name.."Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = contentScrolling
    })
    
    local tabContentLayout = createElement("UIListLayout", {
        Name = "Layout",
        Padding = UDim.new(0, 10),
        Parent = tabContent
    })
    
    tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    
    tabs[name] = {
        button = tabButton,
        content = tabContent
    }
    
    tabButton.MouseButton1Click:Connect(function()
        for tabName, tabData in pairs(tabs) do
            tabData.content.Visible = false
            tabData.button.BackgroundColor3 = themes[config.theme].element
        end
        
        tabContent.Visible = true
        tabButton.BackgroundColor3 = config.accentColor
        currentTab = name
    end)
    
    if not currentTab then
        tabContent.Visible = true
        tabButton.BackgroundColor3 = config.accentColor
        currentTab = name
    end
    
    return tabs[name]
end

local function button(name, callback)
    if not currentTab then return end
    
    local buttonFrame = createElement("Frame", {
        Name = name.."Element",
        BackgroundColor3 = themes[config.theme].element,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Parent = tabs[currentTab].content
    })
    
    local buttonLabel = createElement("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = config.font,
        Text = name,
        TextColor3 = themes[config.theme].text,
        TextSize = config.textSize,
        Parent = buttonFrame
    })
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            tween(buttonFrame, {BackgroundColor3 = config.accentColor}, 0.1):Wait()
            tween(buttonFrame, {BackgroundColor3 = themes[config.theme].element}, 0.3)
            callback()
        end
    end
    
    buttonLabel.MouseEnter:Connect(function()
        tween(buttonFrame, {BackgroundColor3 = themes[config.theme].elementHover})
    end)
    
    buttonLabel.MouseLeave:Connect(function()
        tween(buttonFrame, {BackgroundColor3 = themes[config.theme].element})
    end)
    
    buttonLabel.InputBegan:Connect(onInput)
    
    updateCanvas()
    return buttonFrame
end

local function toggle(name, default, callback)
    if not currentTab then return end
    
    local toggleFrame = createElement("Frame", {
        Name = name.."Element",
        BackgroundColor3 = themes[config.theme].element,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Parent = tabs[currentTab].content
    })
    
    local toggleLabel = createElement("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, -10, 1, 0),
        Font = config.font,
        Text = name,
        TextColor3 = themes[config.theme].text,
        TextSize = config.textSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local toggleButton = createElement("Frame", {
        Name = "Toggle",
        BackgroundColor3 = default and config.accentColor or themes[config.theme].elementHover,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Position = UDim2.new(1, -50, 0.5, -10),
        Size = UDim2.new(0, 40, 0, 20),
        Parent = toggleFrame
    })
    
    local toggleState = default or false
    
    local function updateToggle()
        tween(toggleButton, {BackgroundColor3 = toggleState and config.accentColor or themes[config.theme].elementHover})
        callback(toggleState)
    end
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            toggleState = not toggleState
            updateToggle()
        end
    end
    
    toggleButton.InputBegan:Connect(onInput)
    toggleLabel.InputBegan:Connect(onInput)
    
    updateCanvas()
    
    return {
        Set = function(value)
            toggleState = value
            updateToggle()
        end,
        Get = function()
            return toggleState
        end
    }
end

local function slider(name, min, max, default, callback)
    if not currentTab then return end
    
    local sliderFrame = createElement("Frame", {
        Name = name.."Element",
        BackgroundColor3 = themes[config.theme].element,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Size = UDim2.new(1, -20, 0, 60),
        Parent = tabs[currentTab].content
    })
    
    local sliderLabel = createElement("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 0, 20),
        Font = config.font,
        Text = name,
        TextColor3 = themes[config.theme].text,
        TextSize = config.textSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })
    
    local sliderValue = createElement("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 20),
        Size = UDim2.new(1, -20, 0, 20),
        Font = config.font,
        Text = tostring(default),
        TextColor3 = themes[config.theme].text,
        TextSize = config.textSize,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderFrame
    })
    
    local sliderBar = createElement("Frame", {
        Name = "Bar",
        BackgroundColor3 = themes[config.theme].elementHover,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 10, 0, 45),
        Size = UDim2.new(1, -20, 0, 10),
        Parent = sliderFrame
    })
    
    local sliderFill = createElement("Frame", {
        Name = "Fill",
        BackgroundColor3 = config.accentColor,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        Parent = sliderBar
    })
    
    local sliderButton = createElement("TextButton", {
        Name = "Handle",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Position = UDim2.new((default - min)/(max - min), -7, 0, -7),
        Size = UDim2.new(0, 14, 0, 24),
        Text = "",
        Parent = sliderBar
    })
    
    local dragging = false
    local currentValue = default
    
    local function updateSlider(value)
        local normalized = math.clamp((value - min)/(max - min), 0, 1)
        sliderFill.Size = UDim2.new(normalized, 0, 1, 0)
        sliderButton.Position = UDim2.new(normalized, -7, 0, -7)
        currentValue = math.floor(value * 100) / 100
        sliderValue.Text = tostring(currentValue)
        callback(currentValue)
    end
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end
    
    local function onInputEnded()
        dragging = false
    end
    
    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            local sliderPos = sliderBar.AbsolutePosition.X
            local sliderWidth = sliderBar.AbsoluteSize.X
            local inputX = input.Position.X
            
            if config.mobileFriendly and input.UserInputType == Enum.UserInputType.Touch then
                inputX = mobileTouchPositions[input]
            end
            
            local relativeX = math.clamp(inputX - sliderPos, 0, sliderWidth)
            local normalized = relativeX / sliderWidth
            local value = min + (max - min) * normalized
            updateSlider(value)
        end
    end
    
    sliderButton.InputBegan:Connect(onInput)
    sliderBar.InputBegan:Connect(onInput)
    
    sliderButton.InputEnded:Connect(onInputEnded)
    sliderBar.InputEnded:Connect(onInputEnded)
    
    UserInputService.InputChanged:Connect(onInputChanged)
    
    if config.mobileFriendly then
        UserInputService.TouchStarted:Connect(function(input, processed)
            if not processed then
                mobileTouchPositions[input] = input.Position.X
            end
        end)
    end
    
    updateCanvas()
    
    return {
        Set = function(value)
            updateSlider(math.clamp(value, min, max))
        end,
        Get = function()
            return currentValue
        end
    }
end

local function dropdown(name, options, default, callback)
    if not currentTab then return end
    
    local dropdownFrame = createElement("Frame", {
        Name = name.."Element",
        BackgroundColor3 = themes[config.theme].element,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Parent = tabs[currentTab].content
    })
    
    local dropdownLabel = createElement("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, -10, 1, 0),
        Font = config.font,
        Text = name,
        TextColor3 = themes[config.theme].text,
        TextSize = config.textSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownFrame
    })
    
    local dropdownButton = createElement("TextButton", {
        Name = "Dropdown",
        BackgroundColor3 = themes[config.theme].elementHover,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Position = UDim2.new(1, -80, 0.5, -10),
        Size = UDim2.new(0, 70, 0, 20),
        Font = config.font,
        Text = options[default] or options[1],
        TextColor3 = themes[config.theme].text,
        TextSize = config.textSize - 2,
        Parent = dropdownFrame
    })
    
    local dropdownList = createElement("Frame", {
        Name = "List",
        BackgroundColor3 = themes[config.theme].element,
        BorderColor3 = themes[config.theme].border,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        Parent = dropdownFrame
    })
    
    local dropdownListLayout = createElement("UIListLayout", {
        Name = "Layout",
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdownList
    })
    
    local currentOption = default or 1
    local isOpen = false
    
    local function updateDropdown()
        dropdownButton.Text = options[currentOption]
        callback(currentOption, options[currentOption])
    end
    
    local function toggleDropdown()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        
        if isOpen then
            local height = 0
            for _, option in pairs(options) do
                height = height + 25
            end
            dropdownList.Size = UDim2.new(1, 0, 0, math.min(height, 150))
        else
            dropdownList.Size = UDim2.new(1, 0, 0, 0)
        end
    end
    
    for i, option in pairs(options) do
        local optionButton = createElement("TextButton", {
            Name = "Option"..i,
            BackgroundColor3 = themes[config.theme].element,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 25),
            Font = config.font,
            Text = option,
            TextColor3 = themes[config.theme].text,
            TextSize = config.textSize - 2,
            Parent = dropdownList
        })
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = themes[config.theme].elementHover
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = themes[config.theme].element
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            currentOption = i
            updateDropdown()
            toggleDropdown()
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    updateDropdown()
    updateCanvas()
    
    return {
        Set = function(index)
            if options[index] then
                currentOption = index
                updateDropdown()
            end
        end,
        Get = function()
            return currentOption, options[currentOption]
        end
    }
end

-- Funções de controle da UI
local function toggleUI()
    config.open = not config.open
    mainFrame.Visible = config.open
end

local function setTheme(themeName)
    if themes[themeName] then
        config.theme = themeName
        applyTheme()
    end
end

-- Configuração de eventos
closeButton.MouseButton1Click:Connect(toggleUI)

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        
        if config.mobileFriendly and input.UserInputType == Enum.UserInputType.Touch then
            mobileTouchPositions[input] = input.Position.X
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
        local newPos
        if config.mobileFriendly and input.UserInputType == Enum.UserInputType.Touch then
            newPos = Vector2.new(mobileTouchPositions[input] or input.Position.X, input.Position.Y)
        else
            newPos = input.Position
        end
        
        local delta = newPos - dragStartPos
        local newPosition = UDim2.new(
            mainFrame.Position.X.Scale,
            mainFrame.Position.X.Offset + delta.X,
            mainFrame.Position.Y.Scale,
            mainFrame.Position.Y.Offset + delta.Y
        )
        
        mainFrame.Position = newPosition
        dragStartPos = newPos
        config.position = newPosition
    end
end)

-- API pública
return {
    CreateTab = createTab,
    Button = button,
    Toggle = toggle,
    Slider = slider,
    Dropdown = dropdown,
    ToggleUI = toggleUI,
    SetTheme = setTheme,
    Config = config,
    UpdateTheme = applyTheme
}
