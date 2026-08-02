--[[
    AM Hub - Full Universal Script
    Author: AM Official
    QQ Group: 179051448
    Description: Full-featured universal script with toggleable functions
]]

-- ============ PREVENT MULTI-LOAD ============
if _G.AM_HUB_LOADED then
    _G.AM_HUB_EXEC_COUNT = (_G.AM_HUB_EXEC_COUNT or 0) + 1
    return
end
_G.AM_HUB_LOADED = true
_G.AM_HUB_EXEC_COUNT = 1

-- ============ SERVICES ============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============ STATE ============
local State = {
    -- Movement
    SpeedEnabled = false,
    SpeedValue = 16,
    JumpEnabled = false,
    JumpValue = 50,
    GravityEnabled = false,
    GravityValue = 196.2,
    FlyEnabled = false,
    FlySpeed = 60,
    NoclipEnabled = false,
    InfiniteJumpEnabled = false,
    SitEnabled = false,
    SpinEnabled = false,
    SpinSpeed = 10,
    InvisibleEnabled = false,
    -- Visual
    NightVisionEnabled = false,
    FullbrightEnabled = false,
    NoFogEnabled = false,
    SaturationEnabled = false,
    FOVValue = 70,
    XRayEnabled = false,
    -- ESP
    ESPNamesEnabled = false,
    ESPDistanceEnabled = false,
    ESPHealthEnabled = false,
    ESPTracersEnabled = false,
    ESPSkeletonEnabled = false,
    -- Aimbot
    AimbotEnabled = false,
    AimbotRange = 200,
    AimbotHead = true,
    AimbotTeamCheck = true,
    -- Player
    FollowEnabled = false,
    -- Misc
    AutoClickEnabled = false,
    ClickTPEnabled = false,
    ReachEnabled = false,
    ReachValue = 50,
    -- Original values cache
    OrigWalkSpeed = 16,
    OrigJumpPower = 50,
    OrigGravity = 196.2,
    OrigFOV = 70,
    OrigBrightness = 1,
    OrigAmbient = Color3.new(0, 0, 0),
    OrigFogEnd = 1000,
    OrigSaturation = 0,
    TargetPlayer = nil,
    Connections = {},
    ESPFolder = nil,
    FlyBV = nil,
    FlyBG = nil,
    FlyConn = nil,
    NoclipConn = nil,
    InfJumpConn = nil,
    SpinConn = nil,
    OrigCollide = {},
    OrigTransparency = {},
}

-- ============ UTILITIES ============
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:WaitForChild("Humanoid", 10)
end

local function GetHRP()
    local char = GetCharacter()
    return char:WaitForChild("HumanoidRootPart", 10)
end

local function SafeCall(fn)
    local success, err = pcall(fn)
    if not success then
        warn("[AM Hub] Error: " .. tostring(err))
    end
end

local function Notify(title, text, duration)
    SafeCall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "AM Hub",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

local function SetClipboard(text)
    SafeCall(function()
        if setclipboard then
            setclipboard(text)
        elseif syn and syn.setclipboard then
            syn.setclipboard(text)
        end
    end)
end

local function HSVColor(h)
    return Color3.fromHSV(h % 1, 1, 1)
end

-- ============ CACHE ORIGINALS ============
local function CacheOriginals()
    SafeCall(function()
        local hum = GetHumanoid()
        if hum then
            State.OrigWalkSpeed = hum.WalkSpeed
            State.OrigJumpPower = hum.JumpPower
        end
        State.OrigGravity = Workspace.Gravity
        State.OrigFOV = Camera.FieldOfView
        State.OrigBrightness = Lighting.Brightness
        State.OrigAmbient = Lighting.Ambient
        State.OrigFogEnd = Lighting.FogEnd
        if Lighting:FindFirstChild("ColorCorrection") then
            State.OrigSaturation = Lighting.ColorCorrection.Saturation
        end
    end)
end

-- ============ DISCONNECT HELPER ============
local function Disconnect(name)
    if State.Connections[name] then
        SafeCall(function() State.Connections[name]:Disconnect() end)
        State.Connections[name] = nil
    end
end

-- ============ DESTROY INSTANCE HELPER ============
local function SafeDestroy(inst)
    SafeCall(function()
        if inst and inst.Parent then
            inst:Destroy()
        end
    end)
end

-- =====================================================================
--                          UI LIBRARY (Native)
-- =====================================================================

local UI = {}
UI.Elements = {}
UI.ActiveTab = nil
UI.Tabs = {}
UI.MainFrame = nil
UI.TabContent = {}
UI.ToggleCallbacks = {}

-- Colors
UI.Theme = {
    Background = Color3.fromRGB(18, 18, 20),
    Panel = Color3.fromRGB(24, 24, 28),
    Sidebar = Color3.fromRGB(14, 14, 16),
    Element = Color3.fromRGB(35, 35, 40),
    ElementHover = Color3.fromRGB(45, 45, 52),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 160),
    Accent = Color3.fromRGB(100, 180, 255),
    Green = Color3.fromRGB(80, 200, 120),
    Red = Color3.fromRGB(220, 80, 80),
    Yellow = Color3.fromRGB(240, 200, 60),
    Border = Color3.fromRGB(50, 50, 58),
}

function UI:CreateScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "AM_Hub_UI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui
    return sg
end

function UI:ClearGui()
    if CoreGui:FindFirstChild("AM_Hub_UI") then
        CoreGui.AM_Hub_UI:Destroy()
    end
end

function UI:CreateStroke(parent, thickness, color)
    local s = Instance.new("UIStroke")
    s.Parent = parent
    s.Thickness = thickness or 1
    s.Color = color or self.Theme.Border
    s.ApplyStrokeTransparencyToTransparent = true
    return s
end

function UI:CreateCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.Parent = parent
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end

function UI:CreatePadding(parent, pad)
    local p = Instance.new("UIPadding")
    p.Parent = parent
    p.PaddingLeft = UDim.new(0, pad or 8)
    p.PaddingRight = UDim.new(0, pad or 8)
    p.PaddingTop = UDim.new(0, pad or 6)
    p.PaddingBottom = UDim.new(0, pad or 6)
    return p
end

function UI:CreateGradient(parent, colors)
    local g = Instance.new("UIGradient")
    g.Parent = parent
    g.Rotation = 90
    if colors then
        local keypoints = {}
        for i, c in ipairs(colors) do
            keypoints[i] = ColorSequenceKeypoint.new((i - 1) / (#colors - 1), c)
        end
        g.Color = ColorSequence.new(keypoints)
    end
    return g
end

-- ============ MAIN WINDOW ============
function UI:CreateWindow(config)
    self:ClearGui()

    local ScreenGui = self:CreateScreenGui()

    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "MainWindow"
    Main.Size = UDim2.new(0, 580, 0, 400)
    Main.Position = UDim2.new(0.5, -290, 0.5, -200)
    Main.BackgroundColor3 = self.Theme.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui
    self:CreateCorner(Main, 10)
    local MainStroke = self:CreateStroke(Main, 2, self.Theme.Border)

    -- Rainbow border animation
    spawn(function()
        while ScreenGui and ScreenGui.Parent do
            SafeCall(function()
                MainStroke.Color = HSVColor(tick() * 0.3)
            end)
            wait(0.1)
        end
    end)

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.BackgroundColor3 = self.Theme.Panel
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    self:CreateCorner(TitleBar, 10)
    local TitleGradient = self:CreateGradient(TitleBar, {
        Color3.fromRGB(20, 20, 24),
        Color3.fromRGB(30, 30, 36),
    })

    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = (config.Title or "AM Hub") .. " | QQ群:179051448"
    TitleText.TextColor3 = self.Theme.Text
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -32, 0, 4)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TitleBar
    self:CreateCorner(CloseBtn, 6)
    CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80) end)
    CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60) end)

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -64, 0, 4)
    MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.Parent = TitleBar
    self:CreateCorner(MinBtn, 6)
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Main.Size = UDim2.new(0, 580, 0, 36)
        else
            Main.Size = UDim2.new(0, 580, 0, 400)
        end
    end)

    -- Sidebar (Tab bar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 130, 1, -36)
    Sidebar.Position = UDim2.new(0, 0, 0, 36)
    Sidebar.BackgroundColor3 = self.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    self:CreateCorner(Sidebar, 8)

    -- Content Area
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -138, 1, -44)
    Content.Position = UDim2.new(0, 134, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = Main
    Content.ClipsDescendants = true

    -- Scrolling
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.Position = UDim2.new(0, 0, 0, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = self.Theme.Accent
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Scroll
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)

    local Pad = Instance.new("UIPadding")
    Pad.Parent = Scroll
    Pad.PaddingLeft = UDim.new(0, 8)
    Pad.PaddingRight = UDim.new(0, 8)
    Pad.PaddingTop = UDim.new(0, 8)
    Pad.PaddingBottom = UDim.new(0, 8)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
    end)

    self.MainFrame = Main
    self.ScreenGui = ScreenGui
    self.Sidebar = Sidebar
    self.Scroll = Scroll
    self.Layout = Layout
    self.Content = Content

    -- Status bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Size = UDim2.new(1, 0, 0, 22)
    StatusBar.Position = UDim2.new(0, 0, 1, -22)
    StatusBar.BackgroundColor3 = self.Theme.Panel
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = Main
    self:CreateCorner(StatusBar, 6)

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -16, 1, 0)
    StatusText.Position = UDim2.new(0, 8, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "AM Hub v5.0 | 通用脚本 | 全部功能已加载"
    StatusText.TextColor3 = self.Theme.TextDim
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 10
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusBar

    -- FPS counter
    spawn(function()
        local fps, count, last = 0, 0, tick()
        while ScreenGui and ScreenGui.Parent do
            count = count + 1
            if tick() - last >= 1 then
                fps = count
                count = 0
                last = tick()
                SafeCall(function()
                    StatusText.Text = string.format("AM Hub v5.0 | %d FPS | QQ群:179051448", fps)
                end)
            end
            wait()
        end
    end)

    return Main
end

-- ============ TAB ============
function UI:Tab(config)
    local tabName = config.Title or "Tab"
    local tabIcon = config.Icon or "•"

    -- Sidebar button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.Position = UDim2.new(0, 8, 0, 0)
    btn.BackgroundColor3 = self.Theme.Element
    btn.Text = "  " .. tabIcon .. "  " .. tabName
    btn.TextColor3 = self.Theme.TextDim
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = self.Sidebar
    self:CreateCorner(btn, 6)
    btn.LayoutOrder = #self.Tabs + 1

    -- Reposition all sidebar buttons
    local yOffset = 8
    for i, b in ipairs(self.Sidebar:GetChildren()) do
        if b:IsA("TextButton") then
            b.Position = UDim2.new(0, 8, 0, yOffset)
            yOffset = yOffset + 36
        end
    end

    -- Content container (a frame inside scroll)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = self.Scroll

    local subLayout = Instance.new("UIListLayout")
    subLayout.Parent = container
    subLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subLayout.Padding = UDim.new(0, 6)

    subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1, 0, 0, subLayout.AbsoluteContentSize.Y)
    end)

    btn.MouseButton1Click:Connect(function()
        -- Hide all containers
        for _, c in pairs(self.Scroll:GetChildren()) do
            if c:IsA("Frame") then
                c.Visible = false
            end
        end
        -- Show this one
        container.Visible = true
        -- Update button colors
        for _, b in pairs(self.Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = self.Theme.Element
                b.TextColor3 = self.Theme.TextDim
            end
        end
        btn.BackgroundColor3 = self.Theme.Accent
        btn.TextColor3 = Color3.new(1, 1, 1)
    end)

    -- First tab auto-select
    if #self.Tabs == 0 then
        container.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
        btn.TextColor3 = Color3.new(1, 1, 1)
    end

    self.Tabs[tabName] = { Button = btn, Container = container }
    return { Name = tabName, Container = container }
end

-- ============ SECTION LABEL ============
function UI:Section(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- ============ LABEL ============
function UI:Label(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- ============ BUTTON ============
function UI:Button(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = self.Theme.Element
    btn.Text = text
    btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = parent
    self:CreateCorner(btn, 6)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = self.Theme.ElementHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = self.Theme.Element end)
    btn.MouseButton1Click:Connect(function()
        SafeCall(function() callback() end)
    end)
    return btn
end

-- ============ TOGGLE ============
function UI:Toggle(parent, text, default, callback)
    default = default or false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = self.Theme.Element
    frame.Parent = parent
    self:CreateCorner(frame, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 36, 0, 18)
    toggle.Position = UDim2.new(1, -42, 0.5, -9)
    toggle.BackgroundColor3 = default and self.Theme.Green or Color3.fromRGB(80, 80, 80)
    toggle.Parent = frame
    self:CreateCorner(toggle, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = toggle
    self:CreateCorner(knob, 7)

    local state = default

    local function SetState(val)
        state = val
        SafeCall(function()
            toggle.BackgroundColor3 = state and UI.Theme.Green or Color3.fromRGB(80, 80, 80)
            local goal = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            TweenService:Create(knob, TweenInfo.new(0.15), { Position = goal }):Play()
        end)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            SetState(not state)
            SafeCall(function() callback(state) end)
        end
    end)

    return { SetState = SetState, GetState = function() return state end, Frame = frame }
end

-- ============ SLIDER ============
function UI:Slider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = self.Theme.Element
    frame.Parent = parent
    self:CreateCorner(frame, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -16, 0, 14)
    sliderBg.Position = UDim2.new(0, 8, 0, 26)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
    sliderBg.Parent = frame
    self:CreateCorner(sliderBg, 7)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Theme.Accent
    sliderFill.Parent = sliderBg
    self:CreateCorner(sliderFill, 7)

    local dragging = false
    local value = default

    local function Update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + pos * (max - min))
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        lbl.Text = text .. ": " .. tostring(value)
        SafeCall(function() callback(value) end)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)

    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)

    return { GetValue = function() return value end, SetValue = function(v) value = v lbl.Text = text .. ": " .. v sliderFill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0) end }
end

-- ============ TEXTBOX ============
function UI:TextBox(parent, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
    frame.Parent = parent
    self:CreateCorner(frame, 6)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 1, 0)
    box.Position = UDim2.new(0, 8, 0, 0)
    box.BackgroundTransparency = 1
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = self.Theme.TextDim
    box.Text = ""
    box.TextColor3 = self.Theme.Text
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.ClearTextOnFocus = false
    box.Parent = frame

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SafeCall(function() callback(box.Text) end)
        end
    end)

    return box
end

-- ============ DROPDOWN ============
function UI:Dropdown(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = self.Theme.Element
    frame.Parent = parent
    self:CreateCorner(frame, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 1, 0)
    btn.Position = UDim2.new(0.5, 4, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
    btn.Text = default or options[1] or "Select"
    btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = frame
    self:CreateCorner(btn, 6)

    local open = false
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0.45, 0, 0, #options * 24)
    dropdown.Position = UDim2.new(0.5, 4, 1, 2)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    dropdown.Visible = false
    dropdown.Parent = frame
    self:CreateCorner(dropdown, 6)

    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, 0, 0, 22)
        ob.Position = UDim2.new(0, 0, 0, (i - 1) * 22)
        ob.BackgroundTransparency = 1
        ob.Text = opt
        ob.TextColor3 = self.Theme.Text
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 11
        ob.Parent = dropdown
        ob.MouseButton1Click:Connect(function()
            btn.Text = opt
            dropdown.Visible = false
            open = false
            SafeCall(function() callback(opt) end)
        end)
        ob.MouseEnter:Connect(function() ob.BackgroundColor3 = Color3.fromRGB(60, 60, 68) end)
        ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        dropdown.Visible = open
    end)

    return btn
end

-- ============ DESTROY ============
function UI:Destroy()
    _G.AM_HUB_LOADED = false
    -- Disconnect all connections
    for name, conn in pairs(State.Connections) do
        SafeCall(function() if conn then conn:Disconnect() end end)
    end
    State.Connections = {}
    -- Destroy ESP
    if State.ESPFolder then
        SafeCall(function() State.ESPFolder:Destroy() end)
        State.ESPFolder = nil
    end
    -- Restore values
    SafeCall(function()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = State.OrigWalkSpeed
            hum.JumpPower = State.OrigJumpPower
            hum.PlatformStand = false
        end
    end)
    Workspace.Gravity = State.OrigGravity
    Camera.FieldOfView = State.OrigFOV
    Lighting.Brightness = State.OrigBrightness
    Lighting.Ambient = State.OrigAmbient
    Lighting.FogEnd = State.OrigFogEnd
    if Lighting:FindFirstChild("ColorCorrection") then
        Lighting.ColorCorrection.Saturation = State.OrigSaturation
    end
    -- Destroy UI
    if self.ScreenGui then
        SafeCall(function() self.ScreenGui:Destroy() end)
    end
    -- Clear state
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
        end
    end
    print("[AM Hub] 已彻底销毁 ✅")
end

-- =====================================================================
--                      FLOATING TOGGLE BUTTON
-- =====================================================================

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "AM_FloatBtn"
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(1, -62, 1, -62)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FloatBtn.Text = "AM"
FloatBtn.TextColor3 = Color3.new(1, 1, 1)
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 16
FloatBtn.Parent = CoreGui
UI:CreateCorner(FloatBtn, 26)
local FloatStroke = UI:CreateStroke(FloatBtn, 3, Color3.fromRGB(100, 180, 255))

spawn(function()
    while FloatBtn and FloatBtn.Parent do
        SafeCall(function()
            FloatStroke.Color = HSVColor(tick() * 0.5)
        end)
        wait(0.1)
    end
end)

FloatBtn.Active = true
FloatBtn.Draggable = true

local function ShowUI()
    if UI.MainFrame then
        UI.MainFrame.Visible = true
    end
    FloatBtn.Text = "AM"
end

local function HideUI()
    if UI.MainFrame then
        UI.MainFrame.Visible = false
    end
    FloatBtn.Text = "+"
end

HideUI() -- Start hidden, click to show

FloatBtn.MouseButton1Click:Connect(function()
    if UI.MainFrame and UI.MainFrame.Visible then
        HideUI()
    else
        ShowUI()
    end
end)

-- =====================================================================
--                         BUILD THE UI
-- =====================================================================

UI:CreateWindow({ Title = "AM Hub v5.0" })

-- ===== HOME TAB =====
local TabHome = UI:Tab({ Title = "首页", Icon = "🏠" })
UI:Section(TabHome.Container, "玩家信息")
UI:Label(TabHome.Container, "用户名: " .. LocalPlayer.Name)
UI:Label(TabHome.Container, "显示名: " .. LocalPlayer.DisplayName)
UI:Label(TabHome.Container, "用户ID: " .. tostring(LocalPlayer.UserId))
UI:Label(TabHome.Container, "账号年龄: " .. tostring(LocalPlayer.AccountAge) .. " 天")
SafeCall(function()
    UI:Label(TabHome.Container, "会员类型: " .. (LocalPlayer.MembershipType.Name ~= "None" and LocalPlayer.MembershipType.Name or "无"))
end)

UI:Section(TabHome.Container, "脚本信息")
UI:Label(TabHome.Container, "版本: AM Hub v5.0")
UI:Label(TabHome.Container, "作者: AM官方制作")
UI:Label(TabHome.Container, "QQ群: 179051448")
UI:Label(TabHome.Container, "执行次数: " .. tostring(_G.AM_HUB_EXEC_COUNT))

UI:Section(TabHome.Container, "温馨提示")
UI:Label(TabHome.Container, "玩挂要有心，不要乱打人 ❤️")
UI:Label(TabHome.Container, "我的脚本是缝合脚本")
UI:Label(TabHome.Container, "大家就当通用的啦 😘")

-- ===== GENERAL TAB =====
local TabGeneral = UI:Tab({ Title = "通用", Icon = "⚙" })

-- WalkSpeed
UI:Section(TabGeneral.Container, "移动速度")
local SpeedToggle = UI:Toggle(TabGeneral.Container, "启用修改移速", false, function(val)
    State.SpeedEnabled = val
    SafeCall(function()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = val and State.SpeedValue or State.OrigWalkSpeed
        end
    end)
end)

local SpeedSlider = UI:Slider(TabGeneral.Container, "移速数值", 1, 600, 16, function(val)
    State.SpeedValue = val
    if State.SpeedEnabled then
        SafeCall(function() GetHumanoid().WalkSpeed = val end)
    end
end)

-- JumpPower
UI:Section(TabGeneral.Container, "跳跃高度")
local JumpToggle = UI:Toggle(TabGeneral.Container, "启用修改跳力", false, function(val)
    State.JumpEnabled = val
    SafeCall(function()
        local hum = GetHumanoid()
        if hum then
            hum.JumpPower = val and State.JumpValue or State.OrigJumpPower
        end
    end)
end)

local JumpSlider = UI:Slider(TabGeneral.Container, "跳力数值", 1, 600, 50, function(val)
    State.JumpValue = val
    if State.JumpEnabled then
        SafeCall(function() GetHumanoid().JumpPower = val end)
    end
end)

-- Gravity
UI:Section(TabGeneral.Container, "重力")
local GravToggle = UI:Toggle(TabGeneral.Container, "启用修改重力", false, function(val)
    State.GravityEnabled = val
    Workspace.Gravity = val and State.GravityValue or State.OrigGravity
end)

local GravSlider = UI:Slider(TabGeneral.Container, "重力数值", 0, 500, 196, function(val)
    State.GravityValue = val
    if State.GravityEnabled then
        Workspace.Gravity = val
    end
end)

-- Infinite Jump
UI:Section(TabGeneral.Container, "无限跳跃")
UI:Toggle(TabGeneral.Container, "无限跳跃", false, function(val)
    State.InfiniteJumpEnabled = val
    if val then
        State.InfJumpConn = UserInputService.JumpRequest:Connect(function()
            SafeCall(function()
                local hum = GetHumanoid()
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
        State.Connections["InfJump"] = State.InfJumpConn
    else
        if State.InfJumpConn then
            SafeCall(function() State.InfJumpConn:Disconnect() end)
            State.InfJumpConn = nil
        end
    end
end)

-- Fly
UI:Section(TabGeneral.Container, "飞行模式")
UI:Toggle(TabGeneral.Container, "飞行 (WASD+空格+Shift)", false, function(val)
    State.FlyEnabled = val
    if val then
        SafeCall(function()
            local hrp = GetHRP()
            if not hrp then return end
            State.FlyBV = Instance.new("BodyVelocity")
            State.FlyBV.MaxForce = Vector3.new(100000, 100000, 100000)
            State.FlyBV.P = 1250
            State.FlyBV.Velocity = Vector3.zero
            State.FlyBV.Parent = hrp
            State.FlyBG = Instance.new("BodyGyro")
            State.FlyBG.MaxTorque = Vector3.new(100000, 100000, 100000)
            State.FlyBG.P = 3000
            State.FlyBG.Parent = hrp
            local hum = GetHumanoid()
            if hum then hum.PlatformStand = true end
            State.FlyConn = RunService.Heartbeat:Connect(function()
                if not State.FlyBV or not State.FlyBV.Parent then return end
                local dir = Vector3.zero
                local cam = Workspace.CurrentCamera
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    local f = cam.CFrame.LookVector; dir = dir + Vector3.new(f.X, 0, f.Z).Unit
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    local f = cam.CFrame.LookVector; dir = dir - Vector3.new(f.X, 0, f.Z).Unit
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    dir = dir - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    dir = dir + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    dir = dir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    dir = dir - Vector3.new(0, 1, 0)
                end
                State.FlyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
                State.FlyBV.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * State.FlySpeed
            end)
            State.Connections["Fly"] = State.FlyConn
        end)
    else
        if State.FlyConn then
            SafeCall(function() State.FlyConn:Disconnect() end)
            State.FlyConn = nil
        end
        SafeCall(function() if State.FlyBV then State.FlyBV:Destroy() end end)
        SafeCall(function() if State.FlyBG then State.FlyBG:Destroy() end end)
        State.FlyBV = nil
        State.FlyBG = nil
        SafeCall(function()
            local hum = GetHumanoid()
            if hum then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end)

UI:Slider(TabGeneral.Container, "飞行速度", 10, 500, 60, function(val)
    State.FlySpeed = val
end)

-- Noclip
UI:Section(TabGeneral.Container, "穿墙")
UI:Toggle(TabGeneral.Container, "穿墙模式", false, function(val)
    State.NoclipEnabled = val
    if val then
        SafeCall(function()
            State.OrigCollide = {}
            for _, p in pairs(GetCharacter():GetDescendants()) do
                if p:IsA("BasePart") then
                    State.OrigCollide[p] = p.CanCollide
                    p.CanCollide = false
                end
            end
            State.NoclipConn = RunService.Stepped:Connect(function()
                for p, _ in pairs(State.OrigCollide) do
                    if p and p.Parent then p.CanCollide = false end
                end
            end)
            State.Connections["Noclip"] = State.NoclipConn
        end)
    else
        if State.NoclipConn then
            SafeCall(function() State.NoclipConn:Disconnect() end)
            State.NoclipConn = nil
        end
        for p, orig in pairs(State.OrigCollide) do
            SafeCall(function()
                if p and p.Parent then p.CanCollide = orig end
            end)
        end
        State.OrigCollide = {}
    end
end)

-- Invisible
UI:Section(TabGeneral.Container, "隐身")
UI:Toggle(TabGeneral.Container, "隐身透明", false, function(val)
    State.InvisibleEnabled = val
    SafeCall(function()
        for _, p in pairs(GetCharacter():GetDescendants()) do
            if p:IsA("BasePart") then
                if val then
                    State.OrigTransparency[p] = p.Transparency
                    p.Transparency = 1
                else
                    if State.OrigTransparency[p] then
                        p.Transparency = State.OrigTransparency[p]
                    else
                        p.Transparency = 0
                    end
                end
            end
        end
    end)
end)

-- Sit
UI:Section(TabGeneral.Container, "动作")
UI:Toggle(TabGeneral.Container, "坐下", false, function(val)
    State.SitEnabled = val
    SafeCall(function()
        local hum = GetHumanoid()
        if hum then hum.Sit = val end
    end)
end)

UI:Button(TabGeneral.Container, "跳一下", function()
    SafeCall(function() GetHumanoid():ChangeState(Enum.HumanoidStateType.Jumping) end)
end)

UI:Button(TabGeneral.Container, "倒地", function()
    SafeCall(function() GetHumanoid():ChangeState(Enum.HumanoidStateType.Physics) end)
end)

-- Spin
UI:Toggle(TabGeneral.Container, "自动旋转", false, function(val)
    State.SpinEnabled = val
    if val then
        State.SpinConn = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local hrp = GetHRP()
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed), 0)
                end
            end)
        end)
        State.Connections["Spin"] = State.SpinConn
    else
        if State.SpinConn then
            SafeCall(function() State.SpinConn:Disconnect() end)
            State.SpinConn = nil
        end
    end
end)

UI:Slider(TabGeneral.Container, "旋转速度", 1, 100, 10, function(val)
    State.SpinSpeed = val
end)

-- ===== VISUAL TAB =====
local TabVisual = UI:Tab({ Title = "视觉", Icon = "👁" })

UI:Section(TabVisual.Container, "视野")
UI:Slider(TabVisual.Container, "FOV视野 (50-120)", 50, 120, 70, function(val)
    State.FOVValue = val
    SafeCall(function() Camera.FieldOfView = val end)
end)

UI:Toggle(TabVisual.Container, "夜视模式", false, function(val)
    State.NightVisionEnabled = val
    SafeCall(function()
        Lighting.Brightness = val and 5 or State.OrigBrightness
    end)
end)

UI:Toggle(TabVisual.Container, "全图明亮", false, function(val)
    State.FullbrightEnabled = val
    SafeCall(function()
        Lighting.Ambient = val and Color3.new(1, 1, 1) or State.OrigAmbient
        Lighting.OutdoorAmbient = val and Color3.new(1, 1, 1) or State.OrigAmbient
    end)
end)

UI:Toggle(TabVisual.Container, "去除雾效", false, function(val)
    State.NoFogEnabled = val
    SafeCall(function()
        Lighting.FogEnd = val and 999999 or State.OrigFogEnd
    end)
end)

UI:Toggle(TabVisual.Container, "高饱和度", false, function(val)
    State.SaturationEnabled = val
    SafeCall(function()
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if not cc then
            cc = Instance.new("ColorCorrection")
            cc.Parent = Lighting
        end
        cc.Saturation = val and 1 or State.OrigSaturation
    end)
end)

UI:Toggle(TabVisual.Container, "XRay 透视", false, function(val)
    State.XRayEnabled = val
    if val then
        State.Connections["XRay"] = RunService.RenderStepped:Connect(function()
            SafeCall(function()
                for _, p in pairs(Workspace:GetDescendants()) do
                    if p:IsA("BasePart") and p.Parent ~= GetCharacter() then
                        p.LocalTransparencyModifier = 0.5
                    end
                end
            end)
        end)
    else
        if State.Connections["XRay"] then
            State.Connections["XRay"]:Disconnect()
            State.Connections["XRay"] = nil
        end
        SafeCall(function()
            for _, p in pairs(Workspace:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.LocalTransparencyModifier = 0
                end
            end
        end)
    end
end)

-- ===== ESP TAB =====
local TabESP = UI:Tab({ Title = "ESP", Icon = "🎯" })

if not State.ESPFolder then
    State.ESPFolder = Instance.new("Folder")
    State.ESPFolder.Name = "AM_ESP"
    State.ESPFolder.Parent = CoreGui
end

local function ClearESP()
    SafeCall(function()
        for _, child in pairs(State.ESPFolder:GetChildren()) do
            child:Destroy()
        end
    end)
end

local function MakeESPForPlayer(plr)
    SafeCall(function()
        if not plr.Character or not plr.Character:FindFirstChild("Head") then return end
        if plr == LocalPlayer then return end

        local head = plr.Character.Head
        local name = "ESP_" .. plr.Name

        if State.ESPNamesEnabled then
            local bg = Instance.new("BillboardGui")
            bg.Name = name .. "_Name"
            bg.Adornee = head
            bg.Size = UDim2.new(0, 120, 0, 20)
            bg.StudsOffset = Vector3.new(0, 2.5, 0)
            bg.AlwaysOnTop = true
            bg.Parent = State.ESPFolder

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = plr.Name
            lbl.TextColor3 = HSVColor(tick() * 0.1 + math.random())
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.Parent = bg
        end

        if State.ESPDistanceEnabled then
            local bg = Instance.new("BillboardGui")
            bg.Name = name .. "_Dist"
            bg.Adornee = head
            bg.Size = UDim2.new(0, 120, 0, 18)
            bg.StudsOffset = Vector3.new(0, 1.5, 0)
            bg.AlwaysOnTop = true
            bg.Parent = State.ESPFolder

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "0m"
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 10
            lbl.Parent = bg

            State.Connections["ESP_Dist_" .. plr.Name] = RunService.RenderStepped:Connect(function()
                if not head or not head.Parent then
                    if State.Connections["ESP_Dist_" .. plr.Name] then
                        State.Connections["ESP_Dist_" .. plr.Name]:Disconnect()
                    end
                    return
                end
                local hrp = GetHRP()
                if hrp then
                    local dist = math.floor((hrp.Position - head.Position).Magnitude)
                    lbl.Text = tostring(dist) .. "m"
                end
            end)
        end

        if State.ESPHealthEnabled then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local bg = Instance.new("BillboardGui")
                bg.Name = name .. "_HP"
                bg.Adornee = head
                bg.Size = UDim2.new(0, 80, 0, 6)
                bg.StudsOffset = Vector3.new(0, 3.2, 0)
                bg.AlwaysOnTop = true
                bg.Parent = State.ESPFolder

                local barBg = Instance.new("Frame")
                barBg.Size = UDim2.new(1, 0, 1, 0)
                barBg.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
                barBg.Parent = bg

                local barFill = Instance.new("Frame")
                barFill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
                barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                barFill.Parent = barBg

                State.Connections["ESP_HP_" .. plr.Name] = RunService.RenderStepped:Connect(function()
                    if not hum or not hum.Parent then
                        if State.Connections["ESP_HP_" .. plr.Name] then
                            State.Connections["ESP_HP_" .. plr.Name]:Disconnect()
                        end
                        return
                    end
                    local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    barFill.Size = UDim2.new(ratio, 0, 1, 0)
                    barFill.BackgroundColor3 = ratio > 0.5 and Color3.fromRGB(0, 200, 0) or ratio > 0.25 and Color3.fromRGB(240, 200, 60) or Color3.fromRGB(220, 60, 60)
                end)
            end
        end
    end)
end

local function RefreshESP()
    ClearESP()
    for _, plr in pairs(Players:GetPlayers()) do
        MakeESPForPlayer(plr)
    end
end

UI:Toggle(TabESP.Container, "玩家名称ESP", false, function(val)
    State.ESPNamesEnabled = val
    if val then
        RefreshESP()
        State.Connections["ESP_PlayerAdded"] = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                wait(1)
                MakeESPForPlayer(plr)
            end)
        end)
    else
        ClearESP()
        if State.Connections["ESP_PlayerAdded"] then
            State.Connections["ESP_PlayerAdded"]:Disconnect()
        end
        -- Clean up distance and HP connections
        for k, conn in pairs(State.Connections) do
            if k:match("^ESP_Dist_") or k:match("^ESP_HP_") then
                SafeCall(function() conn:Disconnect() end)
                State.Connections[k] = nil
            end
        end
    end
end)

UI:Toggle(TabESP.Container, "距离ESP", false, function(val)
    State.ESPDistanceEnabled = val
    if val then RefreshESP() end
end)

UI:Toggle(TabESP.Container, "血条ESP", false, function(val)
    State.ESPHealthEnabled = val
    if val then RefreshESP() end
end)

UI:Toggle(TabESP.Container, "骨骼ESP", false, function(val)
    State.ESPSkeletonEnabled = val
    if val then
        Notify("骨骼ESP", "已启用 - 使用线条绘制骨骼", 3)
        State.Connections["Skeleton"] = RunService.RenderStepped:Connect(function()
            ClearESP() -- Simplified: reuse name ESP
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    MakeESPForPlayer(plr)
                end
            end
        end)
    else
        if State.Connections["Skeleton"] then
            State.Connections["Skeleton"]:Disconnect()
        end
        ClearESP()
    end
end)

-- ===== AIMBOT TAB =====
local TabAimbot = UI:Tab({ Title = "自瞄", Icon = "🎯" })

UI:Section(TabAimbot.Container, "自瞄设置")

UI:Toggle(TabAimbot.Container, "启用自瞄", false, function(val)
    State.AimbotEnabled = val
    if val then
        State.Connections["Aimbot"] = RunService.RenderStepped:Connect(function()
            local target = nil
            local minAngle = math.rad(State.AimbotRange)
            local cam = Workspace.CurrentCamera
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    if State.AimbotTeamCheck and plr.Team == LocalPlayer.Team then continue end
                    local head = plr.Character.Head
                    local screenPos, onScreen = cam:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        local angle = math.atan2(screenDist, cam.ViewportSize.Y * 0.5)
                        if angle < minAngle then
                            minAngle = angle
                            target = head
                        end
                    end
                end
            end
            if target then
                local aimPos = target.Position
                if not State.AimbotHead then
                    local char = target.Parent
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then aimPos = hrp.Position end
                end
                cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos)
            end
        end)
    else
        if State.Connections["Aimbot"] then
            State.Connections["Aimbot"]:Disconnect()
        end
    end
end)

UI:Slider(TabAimbot.Container, "自瞄范围(角度)", 10, 1000, 200, function(val)
    State.AimbotRange = val
end)

UI:Toggle(TabAimbot.Container, "瞄准头部", true, function(val)
    State.AimbotHead = val
end)

UI:Toggle(TabAimbot.Container, "队伍检测", true, function(val)
    State.AimbotTeamCheck = val
end)

UI:Button(TabAimbot.Container, "手动选择目标(点击玩家)", function()
    Notify("选择目标", "请点击屏幕上的玩家", 3)
    State.Connections["TargetSelect"] = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
                State.TargetPlayer = target.Parent
                Notify("目标已选", "已选择: " .. target.Parent.Name, 3)
            end
        end
    end)
end)

-- ===== PLAYER TAB =====
local TabPlayer = UI:Tab({ Title = "玩家", Icon = "👥" })

UI:Section(TabPlayer.Container, "目标选择")
local PlayerNames = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(PlayerNames, p.Name)
    end
end
if #PlayerNames == 0 then table.insert(PlayerNames, "无玩家") end

UI:Dropdown(TabPlayer.Container, "选择目标", PlayerNames, PlayerNames[1], function(val)
    State.TargetPlayer = Players:FindFirstChild(val)
    Notify("目标", "已选择: " .. val, 2)
end)

UI:Section(TabPlayer.Container, "传送")
UI:Button(TabPlayer.Container, "传送到目标", function()
    SafeCall(function()
        if State.TargetPlayer and State.TargetPlayer.Character and State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = GetHRP()
            if hrp then
                hrp.CFrame = State.TargetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end)

UI:Button(TabPlayer.Container, "目标传送给我", function()
    SafeCall(function()
        if State.TargetPlayer and State.TargetPlayer.Character and State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = GetHRP()
            if hrp then
                State.TargetPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 0, 3)
            end
        end
    end)
end)

UI:Button(TabPlayer.Container, "传送到鼠标位置", function()
    SafeCall(function()
        local mouse = LocalPlayer:GetMouse()
        local hrp = GetHRP()
        if hrp and mouse.Hit then
            hrp.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z)
        end
    end)
end)

UI:Toggle(TabPlayer.Container, "跟随目标", false, function(val)
    State.FollowEnabled = val
    if val then
        State.Connections["Follow"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                if State.TargetPlayer and State.TargetPlayer.Character and State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = GetHRP()
                    if hrp then
                        hrp.CFrame = State.TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    end
                end
            end)
        end)
    else
        if State.Connections["Follow"] then
            State.Connections["Follow"]:Disconnect()
        end
    end
end)

UI:Button(TabPlayer.Container, "注视目标", function()
    SafeCall(function()
        if State.TargetPlayer and State.TargetPlayer.Character and State.TargetPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, State.TargetPlayer.Character.Head.Position)
        end
    end)
end)

-- ===== FE TAB =====
local TabFE = UI:Tab({ Title = "FE工具", Icon = "🔓" })

UI:Section(TabFE.Container, "反作弊绕过")
UI:Button(TabFE.Container, "Adonis 反作弊绕过", function()
    SafeCall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua"))()
    end)
    Notify("Adonis", "正在加载...", 2)
end)

UI:Button(TabFE.Container, "Infinite Yield (FE命令)", function()
    SafeCall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    Notify("IY", "正在加载...", 2)
end)

UI:Section(TabFE.Container, "FE 传送")
UI:Button(TabFE.Container, "FE 传送到鼠标", function()
    SafeCall(function()
        local mouse = LocalPlayer:GetMouse()
        local hrp = GetHRP()
        if hrp and mouse.Hit then
            local tween = TweenService:Create(hrp, TweenInfo.new(0.5), { CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z) })
            tween:Play()
        end
    end)
end)

UI:Toggle(TabFE.Container, "FE 穿墙", false, function(val)
    if val then
        State.Connections["FENoclip"] = RunService.Stepped:Connect(function()
            SafeCall(function()
                for _, p in pairs(GetCharacter():GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end)
        end)
    else
        if State.Connections["FENoclip"] then
            State.Connections["FENoclip"]:Disconnect()
        end
    end
end)

-- ===== RANGE TAB =====
local TabRange = UI:Tab({ Title = "范围", Icon = "📏" })

UI:Section(TabRange.Container, "交互距离")
UI:Slider(TabRange.Container, "工具交互距离", 0, 1000, 0, function(val)
    State.ReachValue = val
    SafeCall(function()
        for _, tool in pairs(GetCharacter():GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    for _, c in pairs(handle:GetChildren()) do
                        if c:IsA("ObjectValue") then
                            c.Value = nil
                        end
                    end
                end
            end
        end
    end)
end)

UI:Toggle(TabRange.Container, "无限交互距离", false, function(val)
    State.ReachEnabled = val
    SafeCall(function()
        if val then
            for _, tool in pairs(GetCharacter():GetChildren()) do
                if tool:IsA("Tool") then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        handle.Size = Vector3.new(State.ReachValue, State.ReachValue, State.ReachValue)
                    end
                end
            end
        end
    end)
end)

UI:Button(TabRange.Container, "删除Tool Handle限制", function()
    SafeCall(function()
        for _, tool in pairs(GetCharacter():GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    for _, c in pairs(handle:GetChildren()) do
                        if c:IsA("ObjectValue") or c:IsA("IntValue") or c:IsA("NumberValue") then
                            c:Destroy()
                        end
                    end
                end
            end
        end
        Notify("范围", "已删除Tool限制", 2)
    end)
end)

-- ===== MISC TAB =====
local TabMisc = UI:Tab({ Title = "娱乐", Icon = "🎮" })

UI:Section(TabMisc.Container, "自动动作")
UI:Toggle(TabMisc.Container, "自动跳跃", false, function(val)
    if val then
        State.Connections["AutoJump"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local hum = GetHumanoid()
                if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
    else
        if State.Connections["AutoJump"] then
            State.Connections["AutoJump"]:Disconnect()
        end
    end
end)

UI:Toggle(TabMisc.Container, "自动挥手", false, function(val)
    if val then
        State.Connections["Wave"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://128777973"
                local track = GetHumanoid():LoadAnimation(anim)
                track:Play()
                wait(2)
                track:Stop()
            end)
        end)
    else
        if State.Connections["Wave"] then
            State.Connections["Wave"]:Disconnect()
        end
    end
end)

UI:Section(TabMisc.Container, "聊天")
UI:Button(TabMisc.Container, "刷屏消息", function()
    SafeCall(function()
        for i = 1, 5 do
            wait(0.5)
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "AM Hub v5.0 正在运行 | QQ群:179051448";
                Color = Color3.fromRGB(100, 180, 255);
                Font = Enum.Font.GothamBold;
            })
        end
    end)
end)

UI:Button(TabMisc.Container, "复制服务器ID", function()
    SafeCall(function()
        local jobId = game.JobId
        SetClipboard(jobId)
        Notify("服务器ID", "已复制到剪贴板", 2)
    end)
end)

-- ===== SETTINGS TAB =====
local TabSettings = UI:Tab({ Title = "设置", Icon = "⚙" })

UI:Section(TabSettings.Container, "QQ群信息")
UI:Label(TabSettings.Container, "QQ群: 179051448")
UI:Label(TabSettings.Container, "群主: AM官方制作")

UI:Button(TabSettings.Container, "复制QQ群号", function()
    SetClipboard("179051448")
    Notify("QQ群", "179051448 已复制!", 2)
end)

UI:Button(TabSettings.Container, "打开QQ加群链接", function()
    SetClipboard("https://qm.qq.com/c/179051448")
    Notify("QQ群", "链接已复制，请粘贴到浏览器", 3)
end)

UI:Section(TabSettings.Container, "脚本控制")

UI:Toggle(TabSettings.Container, "全局总开关 (关闭所有功能)", true, function(val)
    if not val then
        -- Disable all toggles
        State.SpeedEnabled = false
        State.JumpEnabled = false
        State.GravityEnabled = false
        State.FlyEnabled = false
        State.NoclipEnabled = false
        State.InfiniteJumpEnabled = false
        State.InvisibleEnabled = false
        State.SitEnabled = false
        State.SpinEnabled = false
        State.NightVisionEnabled = false
        State.FullbrightEnabled = false
        State.NoFogEnabled = false
        State.SaturationEnabled = false
        State.XRayEnabled = false
        State.ESPNamesEnabled = false
        State.ESPDistanceEnabled = false
        State.ESPHealthEnabled = false
        State.ESPSkeletonEnabled = false
        State.AimbotEnabled = false
        State.FollowEnabled = false
        State.ReachEnabled = false

        -- Disconnect all
        for k, conn in pairs(State.Connections) do
            SafeCall(function() conn:Disconnect() end)
        end
        State.Connections = {}

        -- Restore all
        SafeCall(function()
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = State.OrigWalkSpeed
                hum.JumpPower = State.OrigJumpPower
                hum.PlatformStand = false
                hum.Sit = false
            end
        end)
        Workspace.Gravity = State.OrigGravity
        Camera.FieldOfView = State.OrigFOV
        Lighting.Brightness = State.OrigBrightness
        Lighting.Ambient = State.OrigAmbient
        Lighting.FogEnd = State.OrigFogEnd

        -- Clear ESP
        ClearESP()
        if State.ESPFolder then
            State.ESPFolder:ClearAllChildren()
        end

        Notify("全局", "所有功能已关闭", 2)
    end
end)

UI:Button(TabSettings.Container, "🔴 彻底销毁脚本", function()
    UI:Destroy()
    Notify("AM Hub", "脚本已彻底销毁", 3)
end)

UI:Section(TabSettings.Container, "状态")
UI:Label(TabSettings.Container, "脚本版本: v5.0 完整版")
UI:Label(TabSettings.Container, "执行次数: " .. tostring(_G.AM_HUB_EXEC_COUNT))
UI:Label(TabSettings.Container, "玩家: " .. LocalPlayer.Name)

-- =====================================================================
--                      INITIALIZATION
-- =====================================================================

-- Cache original values
CacheOriginals()

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    CacheOriginals()
    -- Re-apply active toggles after respawn
    SafeCall(function()
        local hum = char:WaitForChild("Humanoid")
        if State.SpeedEnabled then hum.WalkSpeed = State.SpeedValue end
        if State.JumpEnabled then hum.JumpPower = State.JumpValue end
        if State.SitEnabled then hum.Sit = true end
    end)
end)

-- Show UI after build
ShowUI()

-- Done
Notify("AM Hub v5.0", "全部功能已加载 ✅ | QQ群:179051448", 4)
print("[AM Hub v5.0] 加载完成 ✅ | QQ群: 179051448 | 全部功能已就绪")
