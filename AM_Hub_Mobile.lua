if _G.XION_Script_Loaded then
    _G.XION_Execution_Count = (_G.XION_Execution_Count or 0) + 1
    return
end

_G.XION_Script_Loaded = true
_G.XION_Execution_Count = 1

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "AM脚本",
    Icon = "crown",
    Author = "AM官方制作",
    AuthorImage = 90840643379863,
    Folder = "CloudHub",
    Size = UDim2.fromOffset(560, 360),
    Transparent = true,
    User = {
        Enabled = true,
        Callback = function() 
            print("clicked") 
        end,
        Anonymous = false
    },
})

Window:EditOpenButton({
    Title = "AM",
    Icon = "crown",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 3,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 238, 144)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
    }),
    Draggable = true
})


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

function Input(a, b, c, d, e, f)
    return a:Input({
        Title = b,
        Desc = c or "",
        Value = d or "",
        Placeholder = e or "",
        Callback = f
    })
end

local Taba = Tab("首页")
local Tab1 = Tab("通用")
local TabFE = Tab("FE")
local Tabzj = Tab("自己搞的一些小玩意")
local Tabyl = Tab("娱乐")
local Tab2 = Tab("ESP")
local Tab3 = Tab("自瞄")
local Tab4 = Tab("子追")
local Tabc = Tab("范围")
local Tabjb = Tab("各大脚本")
local Tab5 = Tab("力量传奇")
local Tab6 = Tab("忍者传奇")
local Tab7 = Tab("极速传奇")
local Tab8 = Tab("墨水游戏")
local Tab9 = Tab("FPS：S")
local Tab10 = Tab("破坏者谜团")
local Tab11 = Tab("监狱人生")
local Tab12 = Tab("最强战场")
local Tab13 = Tab("99夜")
local Tab14 = Tab("doors")
local Tab15 = Tab("死铁轨")
local Tab16 = Tab("EVADE")
local Tab17 = Tab("锻造厂")
local Tabd = Tab("催更地点")
local Tabb = Tab("设置")

local player = game.Players.LocalPlayer

Taba:Paragraph({
    Title = "系统信息",
    Desc = string.format("用户名: %s\n显示名: %s\n用户ID: %d\n账号年龄: %d天", 
        player.Name, player.DisplayName, player.UserId, player.AccountAge),
    Image = "info",
    ImageSize = 20,
    Color = Color3.fromHex("#0099FF")
})

local fpsCounter = 0
local fpsLastTime = tick()
local fpsText = "计算中..."

spawn(function()
    while wait() do
        fpsCounter += 1
        
        if tick() - fpsLastTime >= 1 then
            fpsText = string.format("%.1f FPS", fpsCounter) -- 显示一位小数
            fpsCounter = 0
            fpsLastTime = tick()
        end
    end
end)

Taba:Paragraph({
    Title = "性能信息",
    Desc = "帧率: " .. fpsText,
    Image = "bar-chart",
    ImageSize = 20,
    Color = Color3.fromHex("#00A2FF")
})

Taba:Paragraph({
    Title = "AM温馨提示：玩挂要有心，不要乱打人❤️",
    Desc = [[ ]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#FFFFFF"),
    BackgroundTransparency = 1,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

Taba:Paragraph({
    Title = "最大贡献者：AM独自制作",
    Desc = [[Cappo]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#FFFFFF"),
    BackgroundTransparency = 1,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

Taba:Paragraph({
    Title = "我不回消息，偶然，此脚本不买，倒卖s妈",
    Desc = [[ ]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#000000"),
    BackgroundColor3 = Color3.fromHex("#000000"),
    BackgroundTransparency = 0.2,
    OutlineColor = Color3.fromHex("#000000"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})
Taba:Paragraph({
    Title = "我的脚本是缝合脚本，大家就当通用的啦😘",
    Desc = [[ ]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#000000"),
    BackgroundTransparency = 1,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

Button(Tab1, "复制QQ群[获取最新消息]", function()
    setclipboard("179051448")
end)

Tab1:Paragraph({
    Title = "以下是常用的",
    Desc = [[ 👇👇👇]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#000000"),
    BackgroundTransparency = 1,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

Button(Tab1, "Adonis管理系统反作弊绕过", function() 
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua'))()
end)

Slider(Tab1, "移动速度", 1, 600, game.Players.LocalPlayer.Character.Humanoid.WalkSpeed, function(a) 
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = a
end)

Slider(Tab1, "跳跃高度", 1, 600, game.Players.LocalPlayer.Character.Humanoid.JumpPower, function(a) 
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = a
end)

Slider(Tab1, "重力设置", 1, 500, workspace.Gravity, function(a) 
        workspace.Gravity = a
end)

Button(Tab1, "锁视角", function() 
    local ShiftlockStarterGui = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
ShiftlockStarterGui.Name = "Shiftlock (StarterGui)"
ShiftlockStarterGui.Parent = game.CoreGui
ShiftlockStarterGui.ZIndexBehavior =  Enum.ZIndexBehavior.Sibling
ShiftlockStarterGui.ResetOnSpawn = false

ImageButton.Parent = ShiftlockStarterGui
ImageButton.Active = true
ImageButton.Draggable = true
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton.BackgroundTransparency = 1.000
ImageButton.Position = UDim2.new(0.921914339, 0, 0.552375436, 0)
ImageButton.Size = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
ImageButton.SizeConstraint = Enum.SizeConstraint.RelativeXX
ImageButton.Image = "http://www.roblox.com/asset/?id=182223762"
local function TLQOYN_fake_script()
    local script = Instance.new("LocalScript", ImageButton)

    local MobileCameraFramework = {}
    local Players = game.Players
    local runservice = game:GetService("RunService")
    local CAS = game:GetService("ContextActionService")
    local Player = Players.LocalPlayer
    local character = Player.Character or Player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character.Humanoid
    local camera = workspace.CurrentCamera
    local button = script.Parent
    uis = game:GetService("UserInputService")
    ismobile = uis.TouchEnabled
    button.Visible = ismobile
    
    local states = {
        OFF = "rbxasset://textures/ui/mouseLock_off@2x.png",
        ON = "rbxasset://textures/ui/mouseLock_on@2x.png"
    }
    local MAX_LENGTH = 900000
    local active = false
    local ENABLED_OFFSET = CFrame.new(1.7, 0, 0)
    local DISABLED_OFFSET = CFrame.new(-1.7, 0, 0)
local rootPos = Vector3.new(0,0,0)
