--// AM 圆形流光悬浮窗
--// Roblox Luau - LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "AM_FloatingUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

--==================================================
-- 圆形悬浮按钮
--==================================================

local button = Instance.new("TextButton")
button.Name = "AMButton"
button.Size = UDim2.fromOffset(75, 75)
button.Position = UDim2.new(0, 30, 0.5, -37)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
button.BackgroundTransparency = 0.25
button.BorderSizePixel = 0
button.Text = "AM"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 25
button.Font = Enum.Font.GothamBold
button.AutoButtonColor = false
button.Active = true
button.Parent = gui

-- 圆形
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

--==================================================
-- 流光边框
--==================================================

local stroke = Instance.new("UIStroke")
stroke.Thickness = 4
stroke.Transparency = 0
stroke.Parent = button

-- 使用渐变制造彩色流动效果
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 180, 0)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 120)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(120, 0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 150))
})

gradient.Rotation = 0
gradient.Parent = stroke

--==================================================
-- 流光动画
--==================================================

local rotation = 0

RunService.RenderStepped:Connect(function(dt)
    rotation = (rotation + dt * 80) % 360
    gradient.Rotation = rotation
end)

--==================================================
-- 手指 / 鼠标拖动
--==================================================

local dragging = false
local dragStart
local startPosition

button.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = button.Position
    end
end)

button.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        button.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- 点击
--==================================================

button.MouseButton1Click:Connect(function()
    print("AM 悬浮按钮被点击")
end)
