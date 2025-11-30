 
 
 

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

 
local StoreBuyRF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreBuyRF")
 
local EquipBestItemRE = ReplicatedStorage.Remotes.EquipBestItemRE

 
 
 

local Colors = {
    Primary = Color3.fromRGB(138, 43, 226),       
    Secondary = Color3.fromRGB(30, 30, 35),       
    Background = Color3.fromRGB(15, 15, 20),      
    Surface = Color3.fromRGB(25, 25, 30),         
    Accent = Color3.fromRGB(186, 85, 211),        
    Success = Color3.fromRGB(147, 51, 234),       
    Text = Color3.fromRGB(240, 240, 245),         
    TextSecondary = Color3.fromRGB(160, 160, 170),  
    Border = Color3.fromRGB(75, 0, 130)           
}

 
local State = {
     
    eggESPEnabled = false,
    autoTPEgg3Enabled = false,
    autoTPEgg2Enabled = false,
    teleportDelay = 0.5,
    
     
    autoBuyGear = true,
    buyLoopCount = 10,
    buyDelaySeconds = 10,
    
     
    equipBest = true,
    equipDelay = 3,
    
     
    currentTab = "Main",
    isMinimized = false
}

 
local ITEMS_TO_BUY = {
    "BAT_M1",
    "BOOM_R1",
    "BUCKET_C1",
    "BAT_L1",
}
local STORE_NAME = "ResourceStore"
local BUY_AMOUNT = 1

 
local espConnections = {}

 
 
 

local function createTween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function addShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

 
 
 

local function performBuyCycle()
    if not State.autoBuyGear then return end
    
    print("Memulai siklus pembelian (" .. State.buyLoopCount .. " kali)...")
    for i = 1, State.buyLoopCount do
        if not State.autoBuyGear then break end  
        
        local currentItem = ITEMS_TO_BUY[((i - 1) % #ITEMS_TO_BUY) + 1]
        
        print("Mencoba membeli item: " .. currentItem .. " (Percobaan ke-" .. i .. ")")
        
         
        local success, result = pcall(function()
            return StoreBuyRF:InvokeServer(STORE_NAME, currentItem, BUY_AMOUNT)
        end)
        
        if success then
            print("Pembelian " .. currentItem .. " berhasil. Hasil: " .. tostring(result))
        else
            warn("Pembelian " .. currentItem .. " gagal. Error: " .. tostring(result))
        end
        
        task.wait(0.1)  
    end
    print("Siklus pembelian selesai.")
end

local function autoBuyLoop()
    while State.autoBuyGear do
        performBuyCycle()
        
        if State.autoBuyGear then
            print("Menunggu " .. State.buyDelaySeconds .. " detik untuk siklus berikutnya...")
            
            local startTime = tick()
            while State.autoBuyGear and (tick() - startTime) < State.buyDelaySeconds do
                task.wait(0.1)
            end
        end
    end
    print("Auto Buy Gear dimatikan.")
end

 
 
 

local function equipBestLoop()
    while State.equipBest do
        pcall(function()
            EquipBestItemRE:FireServer()
            print("🛡️ Equip Best Item executed")
        end)
        
        if State.equipBest then
            local startTime = tick()
            while State.equipBest and (tick() - startTime) < State.equipDelay do
                task.wait(0.1)
            end
        end
    end
    print("Equip Best dimatikan.")
end

 
 
 

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RainEventGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

 
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 16)
createStroke(MainFrame, Colors.Border, 2)

 
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Colors.Primary
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
createCorner(TitleBar, 16)

 
local TitleBarCover = Instance.new("Frame")
TitleBarCover.Size = UDim2.new(1, 0, 0, 16)
TitleBarCover.Position = UDim2.new(0, 0, 1, -16)
TitleBarCover.BackgroundColor3 = Colors.Primary
TitleBarCover.BorderSizePixel = 0
TitleBarCover.Parent = TitleBar

 
local TitleContainer = Instance.new("Frame")
TitleContainer.Size = UDim2.new(0, 200, 1, 0)
TitleContainer.Position = UDim2.new(0, 20, 0, 0)
TitleContainer.BackgroundTransparency = 1
TitleContainer.Parent = TitleBar

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 40, 0, 40)
LogoText.Position = UDim2.new(0, 0, 0.5, -20)
LogoText.BackgroundColor3 = Colors.Background
LogoText.Text = "R"
LogoText.TextColor3 = Colors.Primary
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 24
LogoText.Parent = TitleContainer
createCorner(LogoText, 8)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 150, 1, 0)
TitleText.Position = UDim2.new(0, 50, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Rain Event"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 20
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleContainer

local SubtitleText = Instance.new("TextLabel")
SubtitleText.Size = UDim2.new(0, 150, 0, 15)
SubtitleText.Position = UDim2.new(0, 50, 1, -20)
SubtitleText.BackgroundTransparency = 1
SubtitleText.Text = "ESP & Auto TP Menu"
SubtitleText.TextColor3 = Color3.fromRGB(200, 220, 255)
SubtitleText.Font = Enum.Font.Gotham
SubtitleText.TextSize = 11
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.Parent = TitleContainer

 
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 45, 0, 45)
MinimizeButton.Position = UDim2.new(1, -60, 0.5, -22.5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundTransparency = 0.9
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.AutoButtonColor = false
MinimizeButton.Parent = TitleBar
createCorner(MinimizeButton, 8)

 
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -60)
Sidebar.Position = UDim2.new(0, 0, 0, 60)
Sidebar.BackgroundColor3 = Colors.Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 8)
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 15)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

 
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -150, 1, -60)
ContentArea.Position = UDim2.new(0, 150, 0, 60)
ContentArea.BackgroundColor3 = Colors.Background
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

 
local MinimizedIcon = Instance.new("Frame")
MinimizedIcon.Name = "MinimizedIcon"
MinimizedIcon.Size = UDim2.new(0, 55, 0, 55)
MinimizedIcon.Position = UDim2.new(0, 20, 0, 20)
MinimizedIcon.BackgroundColor3 = Colors.Primary
MinimizedIcon.BorderSizePixel = 0
MinimizedIcon.Visible = false
MinimizedIcon.Active = true
MinimizedIcon.Parent = ScreenGui
createCorner(MinimizedIcon, 14)
createStroke(MinimizedIcon, Colors.Border, 2)

local IconGlow = Instance.new("Frame")
IconGlow.Name = "Glow"
IconGlow.Size = UDim2.new(1, 8, 1, 8)
IconGlow.Position = UDim2.new(0, -4, 0, -4)
IconGlow.BackgroundColor3 = Colors.Primary
IconGlow.BackgroundTransparency = 0.7
IconGlow.BorderSizePixel = 0
IconGlow.ZIndex = 0
IconGlow.Parent = MinimizedIcon
createCorner(IconGlow, 16)

local IconText = Instance.new("TextLabel")
IconText.Size = UDim2.new(1, 0, 1, 0)
IconText.BackgroundTransparency = 1
IconText.Text = "R"
IconText.TextColor3 = Color3.fromRGB(255, 255, 255)
IconText.Font = Enum.Font.GothamBold
IconText.TextSize = 28
IconText.Parent = MinimizedIcon

 
 
 

local TabButtons = {}
local TabPages = {}

local function createTabButton(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Colors.Secondary
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = Sidebar
    createCorner(btn, 8)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Colors.TextSecondary
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 18
    iconLabel.Parent = btn
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -50, 1, 0)
    textLabel.Position = UDim2.new(0, 45, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = Colors.TextSecondary
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = btn
    
    TabButtons[name] = {button = btn, icon = iconLabel, text = textLabel}
    return btn
end

local function createTabPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.ScrollBarImageColor3 = Colors.Primary
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 15)
    layout.Parent = page
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = page
    
    TabPages[name] = page
    return page
end

local function switchTab(tabName)
    State.currentTab = tabName
    
    for name, data in pairs(TabButtons) do
        if name == tabName then
            data.button.BackgroundTransparency = 0
            data.icon.TextColor3 = Colors.Primary
            data.text.TextColor3 = Colors.Text
        else
            data.button.BackgroundTransparency = 1
            data.icon.TextColor3 = Colors.TextSecondary
            data.text.TextColor3 = Colors.TextSecondary
        end
    end
    
    for name, page in pairs(TabPages) do
        page.Visible = (name == tabName)
    end
end

 
local mainTab = createTabButton("Main", "🏠", 1)
local eventTab = createTabButton("Event", "🎯", 2)
local shopTab = createTabButton("Shop", "🛍️", 3)

local mainPage = createTabPage("Main")
local eventPage = createTabPage("Event")
local shopPage = createTabPage("Shop")

 
 
 

local function createSection(parent, title, order)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Colors.Surface
    section.BorderSizePixel = 0
    section.LayoutOrder = order
    section.Parent = parent
    createCorner(section, 12)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Colors.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = section
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = content
    
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 15)
    padding.Parent = section
    
    return content
end

local function createToggle(parent, label, defaultState, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -60, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 26)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -13)
    toggleButton.BackgroundColor3 = defaultState and Colors.Success or Colors.Secondary
    toggleButton.Text = ""
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = container
    createCorner(toggleButton, 13)
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = defaultState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    createCorner(toggleCircle, 10)
    
    local state = defaultState
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        createTween(toggleButton, TweenInfo.new(0.3), {
            BackgroundColor3 = state and Colors.Success or Colors.Secondary
        })
        
        createTween(toggleCircle, TweenInfo.new(0.3), {
            Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        })
        
        if callback then
            callback(state)
        end
    end)
    
    return container
end

local function createInput(parent, label, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, 0, 0, 35)
    inputBox.Position = UDim2.new(0, 0, 0, 25)
    inputBox.BackgroundColor3 = Colors.Secondary
    inputBox.Text = tostring(defaultValue)
    inputBox.TextColor3 = Colors.Text
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 13
    inputBox.PlaceholderText = "Enter value..."
    inputBox.PlaceholderColor3 = Colors.TextSecondary
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    createCorner(inputBox, 8)
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = inputBox
    
    inputBox.FocusLost:Connect(function()
        if callback then
            callback(inputBox.Text)
        end
    end)
    
    return container
end

 
 
 

local equipSection = createSection(mainPage, "Auto Equip", 1)

createToggle(equipSection, "Equip Best", false, function(state)
    State.equipBest = state
    
    if state then
        task.spawn(function()
            equipBestLoop()
        end)
        print("🛡️ Equip Best: ON")
    else
        print("🛡️ Equip Best: OFF")
    end
end)

createInput(equipSection, "Equip Delay (seconds)", "3", function(value)
    local num = tonumber(value)
    if num and num >= 1 then
        State.equipDelay = num
    end
end)

 
 
 

local espSection = createSection(eventPage, "ESP Settings", 1)

createToggle(espSection, "Egg ESP", false, function(state)
    State.eggESPEnabled = state
    updateESP()
end)

local autoTPSection = createSection(eventPage, "Auto Teleport", 2)

createToggle(autoTPSection, "Auto TP Egg 3", false, function(state)
    State.autoTPEgg3Enabled = state
    if state then
        State.autoTPEgg2Enabled = false
    end
end)

createToggle(autoTPSection, "Auto TP Egg 2", false, function(state)
    State.autoTPEgg2Enabled = state
    if state then
        State.autoTPEgg3Enabled = false
    end
end)

 
 
 

local autoBuySection = createSection(shopPage, "Auto Buy Gear", 1)

createToggle(autoBuySection, "Auto Buy Gear", false, function(state)
    State.autoBuyGear = state
    
    if state then
        task.spawn(function()
            autoBuyLoop()
        end)
        print("🛍️ Auto Buy Gear: ON")
    else
        print("🛍️ Auto Buy Gear: OFF")
    end
end)

createInput(autoBuySection, "Loop Count", "10", function(value)
    local num = tonumber(value)
    if num and num >= 1 then
        State.buyLoopCount = num
    end
end)

createInput(autoBuySection, "Delay (seconds)", "10", function(value)
    local num = tonumber(value)
    if num and num >= 1 then
        State.buyDelaySeconds = num
    end
end)

 
 
 

 
mainTab.MouseButton1Click:Connect(function() switchTab("Main") end)
eventTab.MouseButton1Click:Connect(function() switchTab("Event") end)
shopTab.MouseButton1Click:Connect(function() switchTab("Shop") end)

 
local isIconPressed = false
local hasMovedIcon = false

MinimizeButton.MouseButton1Click:Connect(function()
    State.isMinimized = not State.isMinimized
    
    if State.isMinimized then
         
        createTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        
        task.wait(0.3)
        MainFrame.Visible = false
        MinimizedIcon.Visible = true
        
         
        createTween(IconGlow, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.4
        })
        task.wait(0.6)
        createTween(IconGlow, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.7
        })
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MinimizedIcon.Visible = false
        
        createTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 600, 0, 400)
        })
    end
end)

 
MinimizedIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isIconPressed = true
        hasMovedIcon = false
    end
end)

MinimizedIcon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isIconPressed and not hasMovedIcon then
             
            State.isMinimized = false
            MinimizedIcon.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            
            createTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 600, 0, 400)
            })
        end
        isIconPressed = false
        hasMovedIcon = false
    end
end)

 
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

 
local draggingIcon = false
local iconDragStart = nil
local iconStartPos = nil

MinimizedIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingIcon = true
        iconDragStart = input.Position
        iconStartPos = MinimizedIcon.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingIcon = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingIcon and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - iconDragStart
        
         
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            hasMovedIcon = true
        end
        
        MinimizedIcon.Position = UDim2.new(
            iconStartPos.X.Scale,
            iconStartPos.X.Offset + delta.X,
            iconStartPos.Y.Scale,
            iconStartPos.Y.Offset + delta.Y
        )
    end
end)

 
MinimizeButton.MouseEnter:Connect(function()
    createTween(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.7
    })
end)

MinimizeButton.MouseLeave:Connect(function()
    createTween(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.9
    })
end)

 
task.spawn(function()
    while true do
        if State.isMinimized and MinimizedIcon.Visible then
            createTween(IconGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(1, 12, 1, 12),
                Position = UDim2.new(0, -6, 0, -6)
            })
            task.wait(1.5)
            createTween(IconGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(1, 8, 1, 8),
                Position = UDim2.new(0, -4, 0, -4)
            })
            task.wait(1.5)
        else
            task.wait(0.5)
        end
    end
end)

 
IconText.Rotation = 0

 
 
 

local function createESP(obj)
    if obj:FindFirstChild("ESPBox_egg") then return end
    
    local color = Color3.fromRGB(255, 200, 0)
    local emoji = "🥚"
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPBox_egg"
    highlight.Adornee = obj
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = obj
    
     
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel_egg"
    billboard.Adornee = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = emoji .. " " .. obj.Name
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
     
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent or not State.eggESPEnabled then
            if connection then
                connection:Disconnect()
            end
            return
        end
        
        local objPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if objPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - objPart.Position).Magnitude
            textLabel.Text = emoji .. " " .. obj.Name .. "\n[" .. math.floor(distance) .. " studs]"
        end
    end)
    
    table.insert(espConnections, connection)
end

local function removeESP(obj)
    if obj:FindFirstChild("ESPBox_egg") then
        obj.ESPBox_egg:Destroy()
    end
    if obj:FindFirstChild("ESPLabel_egg") then
        obj.ESPLabel_egg:Destroy()
    end
end

local function updateESP()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("egg") or obj.Name:find("Easteregg")) then
            if State.eggESPEnabled then
                createESP(obj)
            else
                removeESP(obj)
            end
        end
    end
end

local function findEasterEgg(eggNumber)
    local targetName = "Drop/Easteregg" .. eggNumber
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == targetName then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                return part.Position
            end
        end
    end
    return nil
end

local function teleportToEgg(eggNumber)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local eggPos = findEasterEgg(eggNumber)
    if eggPos then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(eggPos + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

 
 
 

local lastTeleportTime = 0
RunService.Heartbeat:Connect(function()
    if not State.autoTPEgg3Enabled and not State.autoTPEgg2Enabled then return end
    
    local currentTime = tick()
    if currentTime - lastTeleportTime < State.teleportDelay then return end
    
    local success = false
    if State.autoTPEgg3Enabled then
        success = teleportToEgg(3)
    elseif State.autoTPEgg2Enabled then
        success = teleportToEgg(2)
    end
    
    if success then
        lastTeleportTime = currentTime
    end
end)

 
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        task.wait(0.1)  
        
        if State.eggESPEnabled and (obj.Name:lower():find("egg") or obj.Name:find("Easteregg")) then
            createESP(obj)
        end
    end
end)

 
 
 

 
switchTab("Main")

 
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

task.wait(0.1)

createTween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 600, 0, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200)
})

 
task.spawn(function()
    task.wait(1)
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(0.5, -150, 0, -70)
    notif.BackgroundColor3 = Colors.Success
    notif.BorderSizePixel = 0
    notif.Parent = ScreenGui
    createCorner(notif, 12)
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = "✅ Rain Event Menu Loaded Successfully!"
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.Font = Enum.Font.GothamBold
    notifText.TextSize = 14
    notifText.TextXAlignment = Enum.TextXAlignment.Center
    notifText.Parent = notif
    
    createTween(notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0, 20)
    })
    
    task.wait(3)
    
    createTween(notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -150, 0, -70)
    })
    
    task.wait(0.5)
    notif:Destroy()
end)

print("🎯 Rain Event Menu - Successfully Loaded!")
print("💜 Made by Rain Mods")
print("🌟 Features: Equip Best + Egg ESP + Auto Teleport + Auto Buy Gear")