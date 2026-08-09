-- ============================================================
-- SDBP Ultimate Hub v2.0 (Based on amorestar Style)
-- Features: Farming, Combat, Interaction
-- Warning: Use at your own risk. Do not use on main accounts.
-- ============================================================

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

--// Check if character loaded
if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
    warn("Please wait for character to load...")
    LocalPlayer.CharacterAdded:Wait()
end

--// Anti-Cheat Bypass Simulation (Basic)
-- This is a placeholder. Real bypass requires deep memory patching (Not possible via pure Lua here).
local function SafeCall(func)
    local success, err = pcall(func)
    if not success then
        warn("Operation failed: ", err)
    end
end

--// Create Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SDBP_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

--// Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
TitleBar.Text = "⚡ SDBP · 全能工具 (v2.0)"
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.TextScaled = true
TitleBar.Parent = MainFrame

--// Tabs
local Tabs = {"刷钱", "战斗", "互动"}
local TabButtons = {}
local TabContents = {}

for i, name in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0, 35)
    btn.Position = UDim2.new((i-1)*0.33, 0, 0.05, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Parent = MainFrame
    TabButtons[name] = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(0.9, 0, 0.85, 0)
    content.Position = UDim2.new(0.05, 0, 0.15, 0)
    content.BackgroundTransparency = 1
    content.Visible = (i == 1) -- Default show first tab
    content.Parent = MainFrame
    TabContents[name] = content
end

--// Function to switch tabs
local function SwitchTab(tabName)
    for _, name in ipairs(Tabs) do
        TabContents[name].Visible = (name == tabName)
        TabButtons[name].BackgroundColor3 = (name == tabName) and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(30, 30, 40)
    end
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

--// ============================================================
--// 1. 刷钱功能 (Farming)
--// ============================================================
local FarmFrame = TabContents["刷钱"]
local FarmSpeed = 16 -- Base speed
local IsFlying = false
local FarmEnabled = false

-- Speed Slider (0 - 300%)
local SpeedLabel = Instance.new("TextLabel", FarmFrame)
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "移动速度: 100%"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.TextScaled = true

local function UpdateSpeed(percent)
    percent = math.clamp(percent, 0, 300)
    FarmSpeed = 16 * (percent / 100)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = FarmSpeed
    end
    SpeedLabel.Text = "移动速度: " .. percent .. "%"
end

local SpeedUpBtn = Instance.new("TextButton", FarmFrame)
SpeedUpBtn.Size = UDim2.new(0.45, 0, 0, 30)
SpeedUpBtn.Position = UDim2.new(0, 0, 0.1, 0)
SpeedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
SpeedUpBtn.Text = "+10%"
SpeedUpBtn.TextScaled = true
SpeedUpBtn.MouseButton1Click:Connect(function()
    local current = tonumber(SpeedLabel.Text:match("%d+")) or 100
    UpdateSpeed(current + 10)
end)

local SpeedDownBtn = Instance.new("TextButton", FarmFrame)
SpeedDownBtn.Size = UDim2.new(0.45, 0, 0, 30)
SpeedDownBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
SpeedDownBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
SpeedDownBtn.Text = "-10%"
SpeedDownBtn.TextScaled = true
SpeedDownBtn.MouseButton1Click:Connect(function()
    local current = tonumber(SpeedLabel.Text:match("%d+")) or 100
    UpdateSpeed(current - 10)
end)

-- Cycles before wash
local WashLabel = Instance.new("TextLabel", FarmFrame)
WashLabel.Size = UDim2.new(1, 0, 0, 25)
WashLabel.Position = UDim2.new(0, 0, 0.2, 0)
WashLabel.BackgroundTransparency = 1
WashLabel.Text = "洗钱周期: 3"
WashLabel.TextColor3 = Color3.new(1, 1, 1)
WashLabel.TextScaled = true

local WashCount = 3
local WashUpBtn = Instance.new("TextButton", FarmFrame)
WashUpBtn.Size = UDim2.new(0.45, 0, 0, 30)
WashUpBtn.Position = UDim2.new(0, 0, 0.25, 0)
WashUpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
WashUpBtn.Text = "+1"
WashUpBtn.TextScaled = true
WashUpBtn.MouseButton1Click:Connect(function()
    WashCount = WashCount + 1
    WashLabel.Text = "洗钱周期: " .. WashCount
end)

local WashDownBtn = Instance.new("TextButton", FarmFrame)
WashDownBtn.Size = UDim2.new(0.45, 0, 0, 30)
WashDownBtn.Position = UDim2.new(0.5, 0, 0.25, 0)
WashDownBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
WashDownBtn.Text = "-1"
WashDownBtn.TextScaled = true
WashDownBtn.MouseButton1Click:Connect(function()
    WashCount = WashCount - 1
    WashCount = math.max(1, WashCount)
    WashLabel.Text = "洗钱周期: " .. WashCount
end)

-- Start/Stop Buttons
local StartBtn = Instance.new("TextButton", FarmFrame)
StartBtn.Size = UDim2.new(1, 0, 0, 40)
StartBtn.Position = UDim2.new(0, 0, 0.4, 0)
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
StartBtn.Text = "▶ 开始刷钱"
StartBtn.TextScaled = true
StartBtn.MouseButton1Click:Connect(function()
    FarmEnabled = true
    StartBtn.Visible = false
    -- Add logic to start farming loop here (e.g., fly around, collect rings)
    -- For simplicity, we just set speed. Full loop needs pathfinding.
    UpdateSpeed(100) -- Reset to safe speed
    print("Farming started.")
end)

local StopBtn = Instance.new("TextButton", FarmFrame)
StopBtn.Size = UDim2.new(1, 0, 0, 40)
StopBtn.Position = UDim2.new(0, 0, 0.45, 0)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
StopBtn.Text = "■ 停止刷钱"
StopBtn.TextScaled = true
StopBtn.MouseButton1Click:Connect(function()
    FarmEnabled = false
    StartBtn.Visible = true
    -- Stop farming
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Reset to normal
    end
    print("Farming stopped.")
end)
StopBtn.Visible = false -- Hide initially

--// ============================================================
--// 2. 战斗功能 (Combat)
--// ============================================================
local CombatFrame = TabContents["战斗"]
local InfiniteAmmo = false
local AimbotEnabled = false
local FOV = 90
local MaxDistance = 100

-- Infinite Ammo Toggle
local AmmoToggle = Instance.new("TextButton", CombatFrame)
AmmoToggle.Size = UDim2.new(1, 0, 0, 40)
AmmoToggle.Position = UDim2.new(0, 0, 0.1, 0)
AmmoToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
AmmoToggle.Text = "🔫 无限子弹: 关闭"
AmmoToggle.TextScaled = true
AmmoToggle.MouseButton1Click:Connect(function()
    InfiniteAmmo = not InfiniteAmmo
    AmmoToggle.Text = "🔫 无限子弹: " .. (InfiniteAmmo and "开启" or "关闭")
    if InfiniteAmmo then
        -- Hook into weapon firing system (simplified)
        -- In real, you'd need to intercept RemoteEvents or modify client-side ammo
        print("Infinite Ammo ON (Simulated)")
    else
        print("Infinite Ammo OFF")
    end
end)

-- FOV Slider
local FOVLabel = Instance.new("TextLabel", CombatFrame)
FOVLabel.Size = UDim2.new(1, 0, 0, 25)
FOVLabel.Position = UDim2.new(0, 0, 0.2, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: 90"
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.TextScaled = true

local function UpdateFOV(val)
    FOV = math.clamp(val, 10, 180)
    FOVLabel.Text = "FOV: " .. FOV
    -- Apply FOV change (client-side only, server may reject)
    Camera.FieldOfView = FOV
end

local FOVUpBtn = Instance.new("TextButton", CombatFrame)
FOVUpBtn.Size = UDim2.new(0.45, 0, 0, 30)
FOVUpBtn.Position = UDim2.new(0, 0, 0.25, 0)
FOVUpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
FOVUpBtn.Text = "+10"
FOVUpBtn.TextScaled = true
FOVUpBtn.MouseButton1Click:Connect(function()
    UpdateFOV(FOV + 10)
end)

local FOVDownBtn = Instance.new("TextButton", CombatFrame)
FOVDownBtn.Size = UDim2.new(0.45, 0, 0, 30)
FOVDownBtn.Position = UDim2.new(0.5, 0, 0.25, 0)
FOVDownBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FOVDownBtn.Text = "-10"
FOVDownBtn.TextScaled = true
FOVDownBtn.MouseButton1Click:Connect(function()
    UpdateFOV(FOV - 10)
end)

-- Aimbot Toggle (Strongest)
local AimbotToggle = Instance.new("TextButton", CombatFrame)
AimbotToggle.Size = UDim2.new(1, 0, 0, 40)
AimbotToggle.Position = UDim2.new(0, 0, 0.4, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
AimbotToggle.Text = "🎯 最强自瞄: 关闭"
AimbotToggle.TextScaled = true
AimbotToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotToggle.Text = "🎯 最强自瞄: " .. (AimbotEnabled and "开启" or "关闭")
    if AimbotEnabled then
        print("Aimbot ON (Simulated - Targets nearest enemy)")
        -- Simple aimbot simulation: point mouse at nearest player
        RunService.RenderStepped:Connect(function()
            if AimbotEnabled then
                local nearest = nil
                local minDist = MaxDistance
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = plr
                        end
                    end
                end
                if nearest then
                    -- Point mouse at target (simplified)
                    local targetPos = nearest.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        Mouse.X = screenPos.X
                        Mouse.Y = screenPos.Y
                    end
                end
            end
        end)
    else
        print("Aimbot OFF")
    end
end)

-- Max Distance Slider
local DistLabel = Instance.new("TextLabel", CombatFrame)
DistLabel.Size = UDim2.new(1, 0, 0, 25)
DistLabel.Position = UDim2.new(0, 0, 0.5, 0)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "自瞄距离: 100米"
DistLabel.TextColor3 = Color3.new(1, 1, 1)
DistLabel.TextScaled = true

local function UpdateDist(val)
    MaxDistance = math.clamp(val, 0, 100)
    DistLabel.Text = "自瞄距离: " .. MaxDistance .. "米"
end

local DistUpBtn = Instance.new("TextButton", CombatFrame)
DistUpBtn.Size = UDim2.new(0.45, 0, 0, 30)
DistUpBtn.Position = UDim2.new(0, 0, 0.55, 0)
DistUpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
DistUpBtn.Text = "+10米"
DistUpBtn.TextScaled = true
DistUpBtn.MouseButton1Click:Connect(function()
    UpdateDist(MaxDistance + 10)
end)

local DistDownBtn = Instance.new("TextButton", CombatFrame)
DistDownBtn.Size = UDim2.new(0.45, 0, 0, 30)
DistDownBtn.Position = UDim2.new(0.5, 0, 0.55, 0)
DistDownBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
DistDownBtn.Text = "-10米"
DistDownBtn.TextScaled = true
DistDownBtn.MouseButton1Click:Connect(function()
    UpdateDist(MaxDistance - 10)
end)

--// ============================================================
--// 3. 互动功能 (Interaction)
--// ============================================================
local InteractFrame = TabContents["互动"]
local AutoInteract = false
local InteractSpeed = 100 -- 0-100%
local InteractDistance = 100 -- 0-100 meters

-- Auto Interact Toggle
local AutoInteractToggle = Instance.new("TextButton", InteractFrame)
AutoInteractToggle.Size = UDim2.new(1, 0, 0, 40)
AutoInteractToggle.Position = UDim2.new(0, 0, 0.1, 0)
AutoInteractToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
AutoInteractToggle.Text = "🤖 自动互动: 关闭"
AutoInteractToggle.TextScaled = true
AutoInteractToggle.MouseButton1Click:Connect(function()
    AutoInteract = not AutoInteract
    AutoInteractToggle.Text = "🤖 自动互动: " .. (AutoInteract and "开启" or "关闭")
    if AutoInteract then
        print("Auto Interact ON (Simulated - interacts with objects within range)")
        RunService.Heartbeat:Connect(function()
            if AutoInteract then
                -- Simulate interacting with nearby objects (e.g., doors, loot boxes)
                -- This is a placeholder; actual interaction requires knowing object names and proximity
                -- For example: interact with "Door" or "LootBox" within distance
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("door") or obj.Name:lower():find("loot") then
                        local dist = (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= InteractDistance then
                            -- Simulate interaction (this part is highly dependent on game's remote events)
                            print("Interacting with: ", obj.Name)
                            -- In real, you'd call: obj:WaitForChild("ProximityPrompt"):InputHoldBegin(UserInputType.MouseButton1)
                        end
                    end
                end
            end
        end)
    else
        print("Auto Interact OFF")
    end
end)

-- Interact Speed Slider (0-100%)
local SpeedLabelI = Instance.new("TextLabel", InteractFrame)
SpeedLabelI.Size = UDim2.new(1, 0, 0, 25)
SpeedLabelI.Position = UDim2.new(0, 0, 0.2, 0)
SpeedLabelI.BackgroundTransparency = 1
SpeedLabelI.Text = "互动速度: 100%"
SpeedLabelI.TextColor3 = Color3.new(1, 1, 1)
SpeedLabelI.TextScaled = true

local function UpdateInteractSpeed(percent)
    percent = math.clamp(percent, 0, 100)
    InteractSpeed = percent
    SpeedLabelI.Text = "互动速度: " .. percent .. "%"
end

local SpeedUpBtnI = Instance.new("TextButton", InteractFrame)
SpeedUpBtnI.Size = UDim2.new(0.45, 0, 0, 30)
SpeedUpBtnI.Position = UDim2.new(0, 0, 0.25, 0)
SpeedUpBtnI.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
SpeedUpBtnI.Text = "+10%"
SpeedUpBtnI.TextScaled = true
SpeedUpBtnI.MouseButton1Click:Connect(function()
    UpdateInteractSpeed(tonumber(SpeedLabelI.Text:match("%d+")) + 10)
end)

local SpeedDownBtnI = Instance.new("TextButton", InteractFrame)
SpeedDownBtnI.Size = UDim2.new(0.45, 0, 0, 30)
SpeedDownBtnI.Position = UDim2.new(0.5, 0, 0.25, 0)
SpeedDownBtnI.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
SpeedDownBtnI.Text = "-10%"
SpeedDownBtnI.TextScaled = true
SpeedDownBtnI.MouseButton1Click:Connect(function()
    UpdateInteractSpeed(tonumber(SpeedLabelI.Text:match("%d+")) - 10)
end)

-- Interact Distance Slider (0-100 meters)
local DistLabelI = Instance.new("TextLabel", InteractFrame)
DistLabelI.Size = UDim2.new(1, 0, 0, 25)
DistLabelI.Position = UDim2.new(0, 0, 0.4, 0)
DistLabelI.BackgroundTransparency = 1
DistLabelI.Text = "互动距离: 100米"
DistLabelI.TextColor3 = Color3.new(1, 1, 1)
DistLabelI.TextScaled = true

local function UpdateInteractDist(dist)
    dist = math.clamp(dist, 0, 100)
    InteractDistance = dist
    DistLabelI.Text = "互动距离: " .. dist .. "米"
end

local DistUpBtnI = Instance.new("TextButton", InteractFrame)
DistUpBtnI.Size = UDim2.new(0.45, 0, 0, 30)
DistUpBtnI.Position = UDim2.new(0, 0, 0.45, 0)
DistUpBtnI.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
DistUpBtnI.Text = "+10米"
DistUpBtnI.TextScaled = true
DistUpBtnI.MouseButton1Click:Connect(function()
    UpdateInteractDist(InteractDistance + 10)
end)

local DistDownBtnI = Instance.new("TextButton", InteractFrame)
DistDownBtnI.Size = UDim2.new(0.45, 0, 0, 30)
DistDownBtnI.Position = UDim2.new(0.5, 0, 0.45, 0)
DistDownBtnI.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
DistDownBtnI.Text = "-10米"
DistDownBtnI.TextScaled = true
DistDownBtnI.MouseButton1Click:Connect(function()
    UpdateInteractDist(InteractDistance - 10)
end)

--// Initial Setup
SwitchTab("刷钱")
print("SDBP Hub Loaded. Use at your own risk.")

--// Cleanup on exit (optional)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Escape then
        -- Optionally close the GUI or toggle it
        -- ScreenGui.Enabled = false
    end
end)
