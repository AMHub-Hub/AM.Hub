--[[
    ============================================
    AM拦截诬陷脚本 · 本地隐私保护版
    ============================================
    功能：隐藏全服玩家头顶名牌/血条/称号
    用途：防止被诬陷团队截图人肉、录屏自保
    注意：本脚本仅本地生效，无法阻止他人扫描
    作者：AM制作
    ============================================
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

-- ========== 配置区 ==========
local CONFIG = {
    GroupNumber   = "QQ17395735636",       -- ← 改成你的群号
    GuiName       = "AM_Intercept",
    Title         = "AM拦截诬陷脚本",
    Version       = "v1.0",
    ScanInterval  = 3,                -- 定期检查新生成头顶GUI的间隔(秒)
}
-- ============================

-- 防止重复加载
if _G.AM_Intercept_Loaded then return end
_G.AM_Intercept_Loaded = true

-- 判断是否为头顶名牌类GUI
local function isNameTag(gui)
    local n = gui.Name:lower()
    return (n:find("name") or n:find("tag") or n:find("overhead")
         or n:find("badge") or n:find("title") or n:find("label")
         or n:find("display") or n:find("head") or n:find("top")
         or n:find("billboard") or n:find("nick"))
end

-- 对单个角色执行隐藏/恢复
local function applyToCharacter(char, state)
    if not char then return end

    -- Humanoid 头顶名 & 血条
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        if state then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.NameDisplayDistance = 0
            hum.HealthDisplayDistance = 0
        else
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            hum.NameDisplayDistance = 100
            hum.HealthDisplayDistance = 100
        end
    end

    -- 遍历所有子孙：BillboardGui / SurfaceGui / TextLabel
    for _, g in ipairs(char:GetDescendants()) do
        if (g:IsA("BillboardGui") or g:IsA("SurfaceGui")) and isNameTag(g) then
            g.Enabled = not state
        elseif g:IsA("TextLabel") and isNameTag(g) then
            -- 部分服把名字做成 TextLabel 挂在 Head 上
            if state then
                g.TextTransparency = 1
                g.BackgroundTransparency = 1
            else
                g.TextTransparency = 0
                g.BackgroundTransparency = 0
            end
        end
    end
end

-- ========== 创建悬浮窗 UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CONFIG.GuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- 主面板
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 200)
Main.Position = UDim2.new(0.5, -120, 0.5, -100)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(0, 200, 255)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

-- 顶部标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 5, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = CONFIG.Title .. " " .. CONFIG.Version
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled = true
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- 群号显示
local GroupLabel = Instance.new("TextLabel")
GroupLabel.Size = UDim2.new(1, 0, 0, 24)
GroupLabel.Position = UDim2.new(0, 0, 0, 36)
GroupLabel.BackgroundTransparency = 1
GroupLabel.Text = "群号: " .. CONFIG.GroupNumber
GroupLabel.TextColor3 = Color3.fromRGB(150, 210, 255)
GroupLabel.TextScaled = true
GroupLabel.Font = Enum.Font.SourceSans
GroupLabel.Parent = Main

-- 说明文字
local Desc = Instance.new("TextLabel")
Desc.Size = UDim2.new(1, -10, 0, 36)
Desc.Position = UDim2.new(0, 5, 0, 60)
Desc.BackgroundTransparency = 1
Desc.Text = "自动检测并隐藏玩家头顶名牌\n防止被诬陷团队截图利用"
Desc.TextColor3 = Color3.fromRGB(180, 180, 180)
Desc.TextScaled = true
Desc.Font = Enum.Font.SourceSans
Desc.TextWrapped = true
Desc.Parent = Main

-- 状态指示
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 22)
Status.Position = UDim2.new(0, 0, 0, 100)
Status.BackgroundTransparency = 1
Status.Text = "● 未启动"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.TextScaled = true
Status.Font = Enum.Font.SourceSansBold
Status.Parent = Main

-- 启动按钮
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.8, 0, 0, 42)
Btn.Position = UDim2.new(0.1, 0, 0, 130)
Btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
Btn.Text = "▶ 启动拦截"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.TextScaled = true
Btn.Font = Enum.Font.SourceSansBold
Btn.Parent = Main

-- 最小化按钮
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -30, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.Parent = TitleBar

-- ========== 逻辑 ==========
local Running = false
local connList = {}

local function applyAll(state)
    for _, p in ipairs(Players:GetPlayers()) do
        pcall(function() applyToCharacter(p.Character, state) end)
    end
end

-- 启动
local function startIntercept()
    Running = true
    applyAll(true)
    Status.Text = "● 拦截中"
    Status.TextColor3 = Color3.fromRGB(80, 255, 120)
    Btn.Text = "■ 停止拦截"
    Btn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    print("[AM拦截诬陷脚本] 已启动 - 头顶名牌已隐藏")
end

-- 停止
local function stopIntercept()
    Running = false
    applyAll(false)
    Status.Text = "● 未启动"
    Status.TextColor3 = Color3.fromRGB(255, 80, 80)
    Btn.Text = "▶ 启动拦截"
    Btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    print("[AM拦截诬陷脚本] 已停止 - 头顶名牌已恢复")
end

-- 按钮
Btn.MouseButton1Click:Connect(function()
    if Running then stopIntercept() else startIntercept() end
end)

-- 最小化
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in ipairs(Main:GetChildren()) do
        if child ~= TitleBar then
            child.Visible = not minimized
        end
    end
    Main.Size = minimized and UDim2.new(0, 240, 0, 32) or UDim2.new(0, 240, 0, 200)
    MinBtn.Text = minimized and "+" or "—"
end)

-- 玩家加入/重生监听
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.2)
        pcall(function() applyToCharacter(c, Running) end)
    end)
end)

-- 定期检查新生成的头顶GUI（应对动态加载）
task.spawn(function()
    while true do
        task.wait(CONFIG.ScanInterval)
        if Running then
            pcall(function() applyAll(true) end)
        end
    end
end)

-- 本地玩家重生也要处理
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.2)
    pcall(function() applyToCharacter(c, Running) end)
end)

print("[AM拦截诬陷脚本] 悬浮窗已加载 | 群号: " .. CONFIG.GroupNumber)
print("[AM拦截诬陷脚本] 本脚本仅本地生效，用于防止截图人肉")
