-- ========================================
-- AM Hub - 通用脚本 (Mobile)
-- 作者: AM官方制作
-- QQ群: 179051448
-- ========================================

if _G.AM_Script_Loaded then
    _G.AM_Execution_Count = (_G.AM_Execution_Count or 0) + 1
    return
end

_G.AM_Script_Loaded = true
_G.AM_Execution_Count = 1

-- ========== 加载 WindUI（双源） ==========
local WindUI
local ok = pcall(function()
    WindUI = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/main.lua"))()
end)
if not ok or not WindUI then
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end

-- ========== 彩虹色函数 ==========
local function RainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

-- ========== 创建窗口（黑色背景 + 彩虹边框） ==========
local Window = WindUI:CreateWindow({
    Title = "AM Hub",
    Icon = "crown",
    Author = "AM官方制作",
    AuthorImage = 90840643379863,
    Folder = "AMHub",
    Size = UDim2.fromOffset(500, 600),
    Transparent = false,
    BackgroundColor = Color3.fromRGB(10, 10, 10),
    BorderColor = Color3.fromRGB(255, 0, 0),
    User = {
        Enabled = true,
        Callback = function()
            print("[AM] 用户按钮点击")
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

-- 编辑打开按钮（彩虹色 + 悬浮窗效果）
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
local function Tab(a)
    return Window:Tab({Title = a, Icon = "eye"})
end

local function Button(a, b, c)
    return a:Button({Title = b, Callback = c})
end

local function Toggle(a, b, c, d)
    return a:Toggle({Title = b, Value = c, Callback = d})
end

local function Slider(a, b, c, d, e, f)
    return a:Slider({Title = b, Step = 1, Value = {Min = c, Max = d, Default = e}, Callback = f})
end

local function Dropdown(a, b, c, d, e)
    return a:Dropdown({Title = b, Values = c, Value = d, Callback = e})
end

-- ========== 获取玩家信息 ==========
local player = game.Players.LocalPlayer
local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end
local function GetHum()
    local c = GetChar()
    return c:WaitForChild("Humanoid", 9)
end
local function GetHRP()
    local c = GetChar()
    return c:WaitForChild("HumanoidRootPart", 9)
end

-- 缓存原始值
local _orig = {}
local _cached = false
local function CacheOrig()
    if _cached then return end
    pcall(function()
        local h = GetHum()
        if h then
            _orig.WalkSpeed = h.WalkSpeed
            _orig.JumpPower = h.JumpPower
            _orig.JumpHeight = h.JumpHeight
        end
        _orig.Gravity = workspace.Gravity
        _cached = true
    end)
end

-- ========== 【首页 Tab】 ==========
local Taba = Tab("首页")

-- 用户信息（详细版）
local membershipType = "Unknown"
pcall(function()
    local mt = player.MembershipType
    if mt == Enum.MembershipType.None then membershipType = "无会员"
    elseif mt == Enum.MembershipType.BuildersClub then membershipType = "BC"
    elseif mt == Enum.MembershipType.TurboBuildersClub then membershipType = "TBC"
    elseif mt == Enum.MembershipType.OutrageousBuildersClub then membershipType = "OBC"
    elseif mt == Enum.MembershipType.Premium then membershipType = "Premium"
    end
end)

Taba:Paragraph({
    Title = "👤 玩家信息",
    Desc = string.format(
        "用户名: %s\n显示名: %s\n用户ID: %d\n账号年龄: %d天\n会员类型: %s\n位置: %s",
        player.Name,
        player.DisplayName,
        player.UserId,
        player.AccountAge,
        membershipType,
        tostring(pcall(function() return math.floor(player.Character.HumanoidRootPart.Position.X) end) or "未知")
    ),
    Image = "info",
    ImageSize = 20,
    Color = Color3.fromHex("#00CCFF")
})

-- FPS 实时计算
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
                Title = "📊 性能信息",
                Desc = "帧率: " .. fpsText,
                Image = "bar-chart",
                ImageSize = 20,
                Color = Color3.fromHex("#00FFAA")
            })
        end)
    end
end)

-- 脚本信息
Taba:Paragraph({
    Title = "🔧 脚本信息",
    Desc = "脚本名称: AM Hub\n版本: v2.0 通用版\n作者: AM官方制作\n最大贡献: Cappo",
    Image = "star",
    ImageSize = 20,
    Color = Color3.fromHex("#FFD700")
})

Taba:Paragraph({
    Title = "💡 AM温馨提示",
    Desc = "玩挂要有心，不要乱打人❤️\n此脚本为通用缝合脚本，不收费",
    Image = "heart",
    ImageSize = 24,
    Color = Color3.fromHex("#FF69B4"),
    BackgroundTransparency = 0.3,
    OutlineColor = RainbowColor(),
    OutlineThickness = 2,
    Padding = UDim.new(0, 1)
})

Taba:Paragraph({
    Title = "📢 重要声明",
    Desc = "此脚本不卖、不倒卖\n遇到问题加QQ群获取帮助",
    Image = "megaphone",
    ImageSize = 20,
    Color = Color3.fromHex("#FF4444"),
    BackgroundTransparency = 0.2,
    OutlineColor = Color3.fromHex("#FF0000"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

-- ========== 【通用 Tab】 ==========
local Tab1 = Tab("通用")

Tab1:Paragraph({
    Title = "⚙️ 通用功能",
    Desc = "以下功能均可开关，关闭即还原",
    Image = "settings",
    ImageSize = 20,
    Color = Color3.fromHex("#FFFFFF")
})

-- ---- 移动速度 ----
local _spdOn, _spdVal = false, 16
Toggle(Tab1, "启用移动速度修改", false, function(v)
    CacheOrig()
    _spdOn = v
    pcall(function() GetHum().WalkSpeed = v and _spdVal or (_orig.WalkSpeed or 16) end)
end)
Slider(Tab1, "移动速度值", 1, 600, 16, function(v)
    _spdVal = v
    if _spdOn then pcall(function() GetHum().WalkSpeed = v end) end
end)

-- ---- 跳跃高度 ----
local _jmpOn, _jmpVal = false, 50
Toggle(Tab1, "启用跳跃高度修改", false, function(v)
    CacheOrig()
    _jmpOn = v
    pcall(function() GetHum().JumpPower = v and _jmpVal or (_orig.JumpPower or 50) end)
end)
Slider(Tab1, "跳跃高度值", 1, 600, 50, function(v)
    _jmpVal = v
    if _jmpOn then pcall(function() GetHum().JumpPower = v end) end
end)

-- ---- 重力 ----
local _grvOn, _grvVal = false, 196
Toggle(Tab1, "启用重力修改", false, function(v)
    CacheOrig()
    _grvOn = v
    workspace.Gra
