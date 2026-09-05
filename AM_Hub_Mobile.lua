local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local AMButton = Instance.new("TextButton")
AMButton.Size = UDim2.new(0, 58, 0, 58)
AMButton.Position = UDim2.new(0, 18, 0.5, -29)
AMButton.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
AMButton.BorderSizePixel = 1
AMButton.Text = "AM"
AMButton.TextColor3 = Color3.new(1, 1, 1)
AMButton.TextSize = 20
AMButton.Font = Enum.Font.GothamBold
AMButton.Parent = ScreenGui

local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 300, 0, 400)
Menu.Position = UDim2.new(0, 88, 0.5, -200)
Menu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Menu.BorderSizePixel = 2
Menu.Visible = false
Menu.Active = true
Menu.Parent = ScreenGui

local MenuLabel = Instance.new("TextLabel")
MenuLabel.Size = UDim2.new(1, 0, 0, 40)
MenuLabel.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
MenuLabel.Text = "AM Hub Menu"
MenuLabel.TextColor3 = Color3.new(0, 0, 0)
MenuLabel.TextSize = 18
MenuLabel.Font = Enum.Font.GothamBold
MenuLabel.Parent = Menu

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 20
CloseBtn.Parent = Menu

CloseBtn.MouseButton1Click:Connect(function()
	Menu.Visible = false
end)

AMButton.MouseButton1Click:Connect(function()
	Menu.Visible = not Menu.Visible
end)

print("AM Hub minimal loaded")
