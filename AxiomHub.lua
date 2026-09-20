--[[
    ╔══════════════════════════════════════════════════╗
    ║   AXIOM HUB - STEAL AN EGG EDITION v2            ║
    ║   Menu: Người Chơi | Auto | Teleport | Misc      ║
    ╚══════════════════════════════════════════════════╝
]]

-- ============ SERVICES ============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============ CONFIG ============
local CONFIG = {
    Hotkey = Enum.KeyCode.RightShift,
    Theme = {
        Background    = Color3.fromRGB(18, 18, 26),
        Header        = Color3.fromRGB(28, 28, 40),
        TabActive     = Color3.fromRGB(120, 90, 255),
        TabInactive   = Color3.fromRGB(35, 35, 48),
        Accent        = Color3.fromRGB(120, 90, 255),
        AccentDark    = Color3.fromRGB(80, 60, 190),
        Text          = Color3.fromRGB(240, 240, 250),
        SubText       = Color3.fromRGB(150, 150, 170),
        ToggleOff     = Color3.fromRGB(55, 55, 70),
        ToggleOn      = Color3.fromRGB(120, 90, 255),
        Stroke        = Color3.fromRGB(48, 48, 62),
        Input         = Color3.fromRGB(35, 35, 48),
    },
}

-- ============ STATE ============
local State = {
    -- Người chơi
    WalkSpeedValue = 100,
    FlyValue       = 200,
    FlyEnabled     = false,
    NoclipEnabled  = false,
    InfiniteJump   = false,

    -- Auto
    AutoSteal      = false,
    AutoReturn     = false,
    AutoHatch      = false,
    AutoCollect    = false,

    -- Teleport
    SelectedBiome  = "Forest",
    AutoTeleportBiome = false,

    -- Misc
    FullBright     = false,
    ShowFPS        = false,
    ShowCoords     = false,
}

-- ============ HELPERS ============
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function teleportTo(pos)
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

-- ============ UI CREATION ============
local ScreenGui, MainFrame, ContentHolder
local Tabs = {}
local TabButtons = {}
local CurrentTab = "Người Chơi"

local function createUI()
    local old = CoreGui:FindFirstChild("AxiomHubSAE")
    if old then old:Destroy() end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AxiomHubSAE"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- Main
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    MainFrame.BackgroundColor3 = CONFIG.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 12)
    mc.Parent = MainFrame

    local ms = Instance.new("UIStroke")
    ms.Color = CONFIG.Theme.Stroke
    ms.Thickness = 1.5
    ms.Parent = MainFrame

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 44)
    Header.BackgroundColor3 = CONFIG.Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 12)
    hc.Parent = Header

    local hfix = Instance.new("Frame")
    hfix.Size = UDim2.new(1, 0, 0, 12)
    hfix.Position = UDim2.new(0, 0, 1, -12)
    hfix.BackgroundColor3 = CONFIG.Theme.Header
    hfix.BorderSizePixel = 0
    hfix.Parent = Header

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 1, -2)
    accent.BackgroundColor3 = CONFIG.Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "AXIOM HUB  •  STEAL AN EGG"
    Title.TextColor3 = CONFIG.Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
    CloseBtn.BackgroundColor3 = CONFIG.Theme.AccentDark
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = CONFIG.Theme.Text
    CloseBtn.TextSize = 22
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    -- Tab bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 34)
    TabBar.Position = UDim2.new(0, 10, 0, 50)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabBar

    -- Content holder
    ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -20, 1, -96)
    ContentHolder.Position = UDim2.new(0, 10, 0, 90)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ClipsDescendants = true
    ContentHolder.Parent = MainFrame

    -- Tạo tab
    local TabNames = {"Người Chơi", "Auto", "Teleport", "Misc"}
    for _, name in ipairs(TabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 115, 1, 0)
        btn.BackgroundColor3 = CONFIG.Theme.TabInactive
        btn.Text = name
        btn.TextColor3 = CONFIG.Theme.SubText
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = TabBar

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.Theme.Accent
        frame.CanvasSize = UDim2.new(0, 0, 0, 0)
        frame.Visible = (name == CurrentTab)
        frame.Parent = ContentHolder

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = frame

        Tabs[name] = frame
        TabButtons[name] = btn

        btn.MouseButton1Click:Connect(function()
            for n, f in pairs(Tabs) do f.Visible = false end
            for n, b in pairs(TabButtons) do
                b.BackgroundColor3 = CONFIG.Theme.TabInactive
                b.TextColor3 = CONFIG.Theme.SubText
            end
            frame.Visible = true
            btn.BackgroundColor3 = CONFIG.Theme.TabActive
            btn.TextColor3 = CONFIG.Theme.Text
            CurrentTab = name
        end)
    end

    -- Set active tab
    TabButtons[CurrentTab].BackgroundColor3 = CONFIG.Theme.TabActive
    TabButtons[CurrentTab].TextColor3 = CONFIG.Theme.Text
end

-- ============ UI FACTORIES ============
local function addHeader(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = CONFIG.Theme.Accent
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function addToggle(parent, name, key, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -4, 0, 34)
    Row.BackgroundColor3 = CONFIG.Theme.Header
    Row.BorderSizePixel = 0
    Row.Parent = parent

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = CONFIG.Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 46, 0, 22)
    Btn.Position = UDim2.new(1, -58, 0.5, -11)
    Btn.BackgroundColor3 = State[key] and CONFIG.Theme.ToggleOn or CONFIG.Theme.ToggleOff
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.Parent = Row

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = Btn

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = State[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Knob.BackgroundColor3 = CONFIG.Theme.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = Btn

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = Knob

    local function setVis(on)
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and CONFIG.Theme.ToggleOn or CONFIG.Theme.ToggleOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
    end

    Btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        setVis(State[key])
        if callback then callback(State[key]) end
    end)

    return Row
end

local function addInput(parent, name, key, placeholder, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -4, 0, 34)
    Row.BackgroundColor3 = CONFIG.Theme.Header
    Row.BorderSizePixel = 0
    Row.Parent = parent

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 130, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = CONFIG.Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -160, 0, 24)
    Box.Position = UDim2.new(0, 150, 0.5, -12)
    Box.BackgroundColor3 = CONFIG.Theme.Input
    Box.Text = tostring(State[key] or "")
    Box.PlaceholderText = placeholder or ""
    Box.TextColor3 = CONFIG.Theme.Text
    Box.PlaceholderColor3 = CONFIG.Theme.SubText
    Box.TextSize = 13
    Box.Font = Enum.Font.Gotham
    Box.BorderSizePixel = 0
    Box.ClearTextOnFocus = false
    Box.Parent = Row

    local ibc = Instance.new("UICorner")
    ibc.CornerRadius = UDim.new(0, 4)
    ibc.Parent = Box

    Box.FocusLost:Connect(function()
        local num = tonumber(Box.Text)
        if num then
            State[key] = num
            if callback then callback(num) end
        else
            Box.Text = tostring(State[key] or "")
        end
    end)

    return Row
end

local function addButton(parent, name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -4, 0, 32)
    Btn.BackgroundColor3 = CONFIG.Theme.AccentDark
    Btn.Text = name
    Btn.TextColor3 = CONFIG.Theme.Text
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Btn.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = Btn

    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local BIOMES = {"Forest","Lake","Desert","Jungle","Snow","Volcano","Abyss","Cosmic"}
local BIOME_POS = {
    Forest  = Vector3.new(0, 5, 0),
    Lake    = Vector3.new(200, 5, 0),
    Desert  = Vector3.new(400, 5, 0),
    Jungle  = Vector3.new(600, 5, 0),
    Snow    = Vector3.new(800, 5, 0),
    Volcano = Vector3.new(1000, 5, 0),
    Abyss   = Vector3.new(1200, 5, 0),
    Cosmic  = Vector3.new(1400, 5, 0),
}

local function addDropdown(parent, name, key, options, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -4, 0, 34)
    Row.BackgroundColor3 = CONFIG.Theme.Header
    Row.BorderSizePixel = 0
    Row.Parent = parent

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 130, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = CONFIG.Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -160, 0, 24)
    Btn.Position = UDim2.new(0, 150, 0.5, -12)
    Btn.BackgroundColor3 = CONFIG.Theme.Input
    Btn.Text = State[key]
    Btn.TextColor3 = CONFIG.Theme.Text
    Btn.TextSize = 12
    Btn.Font = Enum.Font.Gotham
    Btn.BorderSizePixel = 0
    Btn.Parent = Row

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = Btn

    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(1, -160, 0, #options * 22)
    ListFrame.Position = UDim2.new(0, 150, 1, 2)
    ListFrame.BackgroundColor3 = CONFIG.Theme.Header
    ListFrame.BorderSizePixel = 0
    ListFrame.Visible = false
    ListFrame.ZIndex = 10
    ListFrame.Parent = Row

    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 4)
    lc.Parent = ListFrame

    local ll = Instance.new("UIListLayout")
    ll.Padding = UDim.new(0, 1)
    ll.Parent = ListFrame

    for _, opt in ipairs(options) do
        local O = Instance.new("TextButton")
        O.Size = UDim2.new(1, 0, 0, 20)
        O.BackgroundColor3 = CONFIG.Theme.Background
        O.Text = opt
        O.TextColor3 = CONFIG.Theme.Text
        O.TextSize = 12
        O.Font = Enum.Font.Gotham
        O.BorderSizePixel = 0
        O.ZIndex = 11
        O.Parent = ListFrame

        O.MouseButton1Click:Connect(function()
            State[key] = opt
            Btn.Text = opt
            ListFrame.Visible = false
            if callback then callback(opt) end
        end)
    end

    Btn.MouseButton1Click:Connect(function()
        ListFrame.Visible = not ListFrame.Visible
    end)

    return Row
end

-- ============ BUILD TABS ============
local function buildPlayerTab()
    local f = Tabs["Người Chơi"]

    addHeader(f, "⚡ TỐC ĐỘ")
    addInput(f, "Tốc độ chạy", "WalkSpeedValue", "Nhập số...", function(v)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = v end
    end)

    addHeader(f, "🕊️ BAY")
    addToggle(f, "Bật bay", "FlyEnabled")
    addInput(f, "Độ cao bay", "FlyValue", "Nhập số...", function(v) end)
    addButton(f, "Áp dụng tốc độ", function()
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = State.WalkSpeedValue end
    end)
    addButton(f, "Reset về mặc định", function()
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
        State.WalkSpeedValue = 16
    end)

    addHeader(f, "🎯 KHÁC")
    addToggle(f, "NoClip (xuyên tường)", "NoclipEnabled")
    addToggle(f, "Infinite Jump (nhảy vô hạn)", "InfiniteJump")
end

local function buildAutoTab()
    local f = Tabs["Auto"]

    addHeader(f, "🥚 AUTO STEAL")
    addToggle(f, "Auto Steal (lấy trứng gần nhất)", "AutoSteal")
    addToggle(f, "Auto Return to Base", "AutoReturn")
    addToggle(f, "Auto Hatch Egg", "AutoHatch")
    addToggle(f, "Auto Collect Money", "AutoCollect")

    addHeader(f, "📍 AUTO TELEPORT")
    addToggle(f, "Auto Teleport Biome", "AutoTeleportBiome")
end

local function buildTeleportTab()
    local f = Tabs["Teleport"]

    addHeader(f, "🌍 TELEPORT BIOME")
    addDropdown(f, "Chọn biome", "SelectedBiome", BIOMES, function(opt)
        local pos = BIOME_POS[opt]
        if pos then teleportTo(pos) end
    end)

    addHeader(f, "🎯 TELEPORT NHANH")
    for _, name in ipairs(BIOMES) do
        addButton(f, "Tới " .. name, function()
            local pos = BIOME_POS[name]
            if pos then teleportTo(pos) end
        end)
    end
end

local function buildMiscTab()
    local f = Tabs["Misc"]

    addHeader(f, "✨ HIỂN THỊ")
    addToggle(f, "FullBright (sáng toàn map)", "FullBright")
    addToggle(f, "Show FPS", "ShowFPS")
    addToggle(f, "Show Coordinates", "ShowCoords")

    addHeader(f, "ℹ️ THÔNG TIN")
    addButton(f, "In info ra console", function()
        print("[Axiom] Speed: " .. tostring(State.WalkSpeedValue))
        print("[Axiom] Fly: " .. tostring(State.FlyEnabled))
        print("[Axiom] Fly Height: " .. tostring(State.FlyValue))
        print("[Axiom] Biome: " .. tostring(State.SelectedBiome))
    end)
end

-- ============ FLY SYSTEM ============
local flyConnection = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function stopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

local function startFly()
    stopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.P = 1e3
    flyBodyGyro.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not State.FlyEnabled then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            flyBodyVelocity.Velocity = moveDir.Unit * State.FlyValue
        else
            flyBodyVelocity.Velocity = Vector3.zero
        end
        flyBodyGyro.CFrame = cam.CFrame
    end)
end

-- ============ LOOPS ============
local function startLoops()
    -- Fly toggle
    task.spawn(function()
        while true do
            task.wait(0.3)
            if State.FlyEnabled and not flyConnection then
                startFly()
            elseif not State.FlyEnabled and flyConnection then
                stopFly()
            end
        end
    end)

    -- Auto Steal
    task.spawn(function()
        while true do
            task.wait(0.1)
            if State.AutoSteal then
                local hrp = getHRP()
                if hrp then
                    local nearest, dist = nil, math.huge
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA(
