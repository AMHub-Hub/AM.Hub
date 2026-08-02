-- ========================================
-- AM脚本 修整版 - 黑色外框 + 彩虹色
-- ========================================

if _G.AM_Script_Loaded then
    _G.AM_Execution_Count = (_G.AM_Execution_Count or 0) + 1
    return
end

_G.AM_Script_Loaded = true
_G.AM_Execution_Count = 1

-- ========== 稳定加载 WindUI ==========
local WindUI
local success, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/main.lua"))()
end)
if not success then
    warn("WindUI加载失败，尝试备用源...")
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end

-- ========== 彩虹色生成函数 ==========
local function RainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

-- ========== 创建窗口 ==========
local Window = WindUI:CreateWindow({
    Title = "AM脚本",
    Icon = "crown",
    Author = "AM官方制作",
    AuthorImage = 90840643379863,
    Folder = "AMHub",
    Size = UDim2.fromOffset(560, 360),
    Transparent = false,
    BackgroundColor = Color3.fromRGB(10, 10, 10),  -- 黑色背景
    BorderColor = Color3.fromRGB(255, 0, 0),        -- 初始红色外框
    User = {
        Enabled = true,
        Callback = function() 
            print("AM脚本 - 用户按钮点击") 
        end,
        Anonymous = false
    },
})

-- 彩虹边框动画
spawn(function()
    while _G.AM_Script_Loaded do
        pcall(function()
            Window:SetBorderColor(RainbowColor())
        end)
        wait(0.1)
    end
end)

-- 编辑打开按钮（彩虹色）
Window:EditOpenButton({
    Title = "AM",
    Icon = "crown",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 3,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 128, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
    }),
    Draggable = true
})

-- ========== 封装函数 ==========
function Tab(a)
    return Window:Tab({Title = a, Icon = "eye"})
end

function Button(a, b, c)
    return a:Button({Title = b, Callback = c})
end

function Toggle(a, b, c, d)
    return a:Toggle({Title = b, Value = c, Callback = d})
end

function Slider(a, b, c, d, e, f)
    return a:Slider({Title = b, Step = 1, Value = {Min = c, Max = d, Default = e}, Callback = f})
end

function Dropdown(a, b, c, d, e)
    return a:Dropdown({Title = b, Values = c, Value = d, Callback = e})
end

-- ========== 获取玩家（安全方式） ==========
local player = game.Players.LocalPlayer
local function GetHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- ========== 首页 Tab ==========
local Taba = Tab("首页")

Taba:Paragraph({
    Title = "系统信息",
    Desc = string.format("用户名: %s\n显示名: %s\n用户ID: %d\n账号年龄: %d天", 
        player.Name, player.DisplayName, player.UserId, player.AccountAge),
    Image = "info",
    ImageSize = 20,
    Color = Color3.fromHex("#0099FF")
})

-- FPS 计数器（实时更新）
local fpsText = "计算中..."
spawn(function()
    local counter = 0
    local lastTime = tick()
    while _G.AM_Script_Loaded do
        counter += 1
        if tick() - lastTime >= 1 then
            fpsText = string.format("%.1f FPS", counter)
            counter = 0
            lastTime = tick()
        end
        wait()
    end
end)

-- 每2秒刷新性能信息
spawn(function()
    while _G.AM_Script_Loaded do
        wait(2)
        pcall(function()
            Taba:Paragraph({
                Title = "性能信息",
                Desc = "帧率: " .. fpsText,
                Image = "bar-chart",
                ImageSize = 20,
                Color = Color3.fromHex("#00A2FF")
            })
        end)
    end
end)

Taba:Paragraph({
    Title = "AM温馨提示：玩挂要有心，不要乱打人",
    Desc = [[ ]],
    Image = "heart",
    ImageSize = 24,
    Color = Color3.fromHex("#FF69B4"),
    BackgroundTransparency = 0.3,
    OutlineColor = RainbowColor(),
    OutlineThickness = 2,
    Padding = UDim.new(0, 1)
})

Taba:Paragraph({
    Title = "最大贡献者：AM独自制作",
    Desc = [[Cappo]],
    Image = "star",
    ImageSize = 24,
    Color = Color3.fromHex("#FFD700"),
    BackgroundTransparency = 0.3,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

-- ========== 通用 Tab（全部带开关） ==========
local Tab1 = Tab("通用")

Tab1:Paragraph({
    Title = "通用功能",
    Desc = [[以下功能均可开关]],
    Image = "settings",
    ImageSize = 20,
    Color = Color3.fromHex("#FFFFFF")
})

-- 移动速度（Toggle + Slider 联动）
local speedEnabled = false
local speedValue = 16

Toggle(Tab1, "启用移动速度修改", false, function(val)
    speedEnabled = val
    local hum = GetHumanoid()
    hum.WalkSpeed = val and speedValue or 16
end)

Slider(Tab1, "移动速度值", 1, 600, 16, function(val)
    speedValue = val
    if speedEnabled then
        pcall(function() GetHumanoid().WalkSpeed = val end)
    end
end)

-- 跳跃高度（Toggle + Slider 联动）
local jumpEnabled = false
local jumpValue = 50

Toggle(Tab1, "启用跳跃高度修改", false, function(val)
    jumpEnabled = val
    local hum = GetHumanoid()
    hum.JumpPower = val and jumpValue or 50
end)

Slider(Tab1, "跳跃高度值", 1, 600, 50, function(val)
    jumpValue = val
    if jumpEnabled then
        pcall(function() GetHumanoid().JumpPower = val end)
    end
end)

-- 重力（Toggle + Slider 联动）
local gravityEnabled = false
local gravityValue = 196.2

Toggle(Tab1, "启用重力修改", false, function(val)
    gravityEnabled = val
    workspace.Gravity = val and gravityValue or 196.2
end)

Slider(Tab1, "重力值", 1, 500, 196, function(val)
    gravityValue = val
    if gravityEnabled then
        workspace.Gravity = val
    end
end)

-- 无限跳（Toggle）
Toggle(Tab1, "无限跳", false, function(val)
    _G.AM_InfiniteJump = val
    if val then
        local hum = GetHumanoid()
        hum.Jumping:Connect(function()
            if _G.AM_InfiniteJump then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- 穿墙（Toggle）
Toggle(Tab1, "穿墙", false, function(val)
    _G.AM_Noclip = val
    if val then
        spawn(function()
            while _G.AM_Noclip and _G.AM_Script_Loaded do
                pcall(function()
                    local char = player.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                wait(0.1)
            end
        end)
    end
end)

-- 飞行（Toggle - 简单版）
Toggle(Tab1, "飞行", false, function(val)
    _G.AM_Fly = val
    local hum = GetHumanoid()
    if val then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.Name = "AM_FlyForce"
        bv.MaxForce = V
