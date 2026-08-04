--[[===============================================================================
                                AM 通用脚本 · 纯中文版
                         Author: AM | QQ群: 179051448
                         Build: 2026.1.5 | 3000行级
                          左侧悬浮窗 | 可拖动 | 纯中文
===============================================================================]]

--// ======================== 防重复执行 ============================
if getgenv().__AM_中文通用已加载 then
    return
end
getgenv().__AM_中文通用已加载 = true

--// ======================== 服务缓存 ============================
local 玩家服务    = game:GetService("Players")
local 运行服务    = game:GetService("RunService")
local 输入服务    = game:GetService("UserInputService")
local 灯光服务    = game:GetService("Lighting")
local 工作区      = game:GetService("Workspace")
local 界面服务    = game:GetService("GuiService")
local 补间服务    = game:GetService("TweenService")
local 垃圾回收    = game:GetService("Debris")
local 本地玩家   = 玩家服务.LocalPlayer
local 摄像机     = 工作区.CurrentCamera

--// ======================== 配置中心 ============================
local 配置 = {
    飞行 = {
        启用     = false,
        速度     = 60,
        模式     = "摇杆",
    },
    视觉 = {
        夜视     = false,
        去雾     = false,
        广角     = false,
        删除阴影 = false,
    },
    ESP = {
        启用     = false,
        显示名字 = true,
        显示距离 = true,
        显示血量 = false,
        显示方框 = false,
    },
    自瞄 = {
        启用     = false,
        范围     = 140,
        平滑度   = 0.12,
    },
    杂项 = {
        穿墙     = false,
        无限跳   = false,
        防坠落   = false,
        重力     = 196,
    },
    界面 = {
        标题     = "☁ AM 通用脚本",
        群号     = "179051448",
        作者     = "AM制作",
    }
}

--// ======================== 工具函数 ============================
local function 安全调用(函数)
    local 成功, 错误 = pcall(函数)
    if not 成功 then
        warn("[AM][错误]", 错误)
    end
end

local function 获取角色()
    return 本地玩家.Character or 本地玩家.CharacterAdded:Wait()
end

local function 获取根部件()
    return 获取角色():WaitForChild("HumanoidRootPart")
end

local function 获取人类()
    return 获取角色():WaitForChild("Humanoid")
end

local function 创建实例(类型, 属性)
    local 对象 = Instance.new(类型)
    for 键, 值 in pairs(属性 or {}) do
        对象[键] = 值
    end
    return 对象
end

local function 添加圆角(对象, 半径)
    local 圆角 = 创建实例("UICorner", {
        CornerRadius = UDim.new(0, 半径 or 8)
    })
    圆角.Parent = 对象
    return 圆角
end

local function 添加描边(对象, 颜色, 粗细)
    local 描边 = 创建实例("UIStroke", {
        Color = 颜色 or Color3.fromRGB(100, 255, 170),
        Thickness = 粗细 or 1
    })
    描边.Parent = 对象
    return 描边
end

--// ======================== 主题配色 ============================
local 主题 = {
    背景     = Color3.fromRGB(8, 8, 12),
    面板     = Color3.fromRGB(16, 16, 22),
    强调色   = Color3.fromRGB(100, 255, 170),
    文字     = Color3.fromRGB(240, 240, 240),
    次要文字 = Color3.fromRGB(140, 140, 140),
    绿色     = Color3.fromRGB(60, 220, 110),
    红色     = Color3.fromRGB(255, 80, 80),
    橙色     = Color3.fromRGB(255, 160, 40),
    蓝色     = Color3.fromRGB(60, 130, 255),
}
--// ======================== 创建屏幕界面 ============================
local 主界面 = 创建实例("ScreenGui", {
    Name = "AM_通用脚本_界面",
    Parent = 本地玩家:WaitForChild("PlayerGui"),
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

--// ======================== 左侧悬浮按钮 ============================
local 悬浮按钮 = 创建实例("TextButton", {
    Name = "AM悬浮按钮",
    Size = UDim2.new(0, 56, 0, 56),
    Position = UDim2.new(0, 16, 0.5, -28),
    BackgroundColor3 = 主题.强调色,
    Text = "AM",
    TextColor3 = Color3.new(0, 0, 0),
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
    Parent = 主界面,
})
添加圆角(悬浮按钮, 28)
悬浮按钮.Active = true
悬浮按钮.Draggable = true

-- 悬浮按钮拖动逻辑（兼容手机触摸）
local 悬浮拖动中 = false
local 悬浮偏移X = 0
local 悬浮偏移Y = 0

悬浮按钮.InputBegan:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
       输入.UserInputType == Enum.UserInputType.Touch then
        悬浮拖动中 = true
        悬浮偏移X = 输入.Position.X - 悬浮按钮.AbsolutePosition.X
        悬浮偏移Y = 输入.Position.Y - 悬浮按钮.AbsolutePosition.Y
    end
end)

悬浮按钮.InputEnded:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
       输入.UserInputType == Enum.UserInputType.Touch then
        悬浮拖动中 = false
    end
end)

运行服务.RenderStepped:Connect(function()
    if 悬浮拖动中 then
        local 鼠标 = 输入服务:GetMouseLocation()
        local 新X = math.clamp(鼠标.X - 悬浮偏移X, 0, 摄像机.ViewportSize.X - 56)
        local 新Y = math.clamp(鼠标.Y - 悬浮偏移Y, 0, 摄像机.ViewportSize.Y - 56)
        悬浮按钮.Position = UDim2.new(0, 新X, 0, 新Y)
    end
end)

-- 悬浮按钮呼吸效果
spawn(function()
    while 悬浮按钮.Parent do
        local t = tick()
        local hue = (t * 0.15) % 1
        悬浮按钮.BackgroundColor3 = Color3.fromHSV(hue, 0.5, 1)
        wait(0.05)
    end
end)

--// ======================== 主面板 ============================
local 主面板 = 创建实例("Frame", {
    Name = "AM主面板",
    Size = UDim2.new(0, 380, 0, 560),
    Position = UDim2.new(0, 80, 0.5, -280),
    BackgroundColor3 = 主题.背景,
    Active = true,
    Draggable = true,
    Visible = false,
    Parent = 主界面,
})
添加圆角(主面板, 12)
添加描边(主面板, 主题.强调色, 1.2)

-- 主面板拖动（防止被标题栏遮挡时也能拖动）
local 面板拖动中 = false
local 面板偏移X = 0
local 面板偏移Y = 0

主面板.InputBegan:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
       输入.UserInputType == Enum.UserInputType.Touch then
        面板拖动中 = true
        面板偏移X = 输入.Position.X - 主面板.AbsolutePosition.X
        面板偏移Y = 输入.Position.Y - 主面板.AbsolutePosition.Y
    end
end)

主面板.InputEnded:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
       输入.UserInputType == Enum.UserInputType.Touch then
        面板拖动中 = false
    end
end)

运行服务.RenderStepped:Connect(function()
    if 面板拖动中 then
        local 鼠标 = 输入服务:GetMouseLocation()
        local 新X = math.clamp(鼠标.X - 面板偏移X, 0, 摄像机.ViewportSize.X - 380)
        local 新Y = math.clamp(鼠标.Y - 面板偏移Y, 0, 摄像机.ViewportSize.Y - 560)
        主面板.Position = UDim2.new(0, 新X, 0, 新Y)
    end
end)

--// ======================== 顶部标题栏 ============================
local 标题栏 = 创建实例("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = 主题.面板,
    Parent = 主面板,
})
添加圆角(标题栏, 10)

-- 标题栏拖动
local 标题拖动中 = false
标题栏.InputBegan:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
       输入.UserInputType == Enum.UserInputType.Touch then
        标题拖动中 = true
        面板偏移X = 输入.Position.X - 主面板.AbsolutePosition.X
        面板偏移Y = 输入.Position.Y - 主面板.AbsolutePosition.Y
    end
end)

标题栏.InputEnded:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
       输入.UserInputType == Enum.UserInputType.Touch then
        标题拖动中 = false
    end
end)

运行服务.RenderStepped:Connect(function()
    if 标题拖动中 then
        local 鼠标 = 输入服务:GetMouseLocation()
        local 新X = math.clamp(鼠标.X - 面板偏移X, 0, 摄像机.ViewportSize.X - 380)
        local 新Y = math.clamp(鼠标.Y - 面板偏移Y, 0, 摄像机.ViewportSize.Y - 560)
        主面板.Position = UDim2.new(0, 新X, 0, 新Y)
    end
end)

--// 标题文字
local 标题文字 = 创建实例("TextLabel", {
    Size = UDim2.new(1, -160, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Text = 配置.界面.标题,
    TextColor3 = 主题.强调色,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = 标题栏,
})

--// QQ群号显示（可点击复制）
local QQ群标签 = 创建实例("TextButton", {
    Size = UDim2.new(0, 100, 0, 28),
    Position = UDim2.new(1, -110, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(40, 40, 50),
    Text = "群:" .. 配置.界面.群号,
    TextColor3 = 主题.文字,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    Parent = 标题栏,
})
添加圆角(QQ群标签, 6)

QQ群标签.MouseButton1Click:Connect(function()
    安全调用(function()
        setclipboard(配置.界面.群号)
        local 提示 = 创建实例("TextLabel", {
            Size = UDim2.new(0, 200, 0, 30),
            Position = UDim2.new(0.5, -100, 0, 50),
            BackgroundColor3 = 主题.绿色,
            Text = "✓ QQ群号已复制",
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Parent = 主界面,
        })
        添加圆角(提示, 8)
        垃圾回收:AddItem(提示, 2)
    end)
end)

--// 关闭按钮
local 关闭按钮 = 创建实例("TextButton", {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -40, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(60, 30, 30),
    Text = "✕",
    TextColor3 = 主题.红色,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Parent = 标题栏,
})
添加圆角(关闭按钮, 6)

关闭按钮.MouseButton1Click:Connect(function()
    主面板.Visible = false
end)

--// ======================== 内容滚动区 ============================
local 内容区 = 创建实例("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -52),
    Position = UDim2.new(0, 10, 0, 46),
    BackgroundTransparency = 1,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = 主题.强调色,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = 主面板,
})

local 内容布局 = 创建实例("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 10),
    Parent = 内容区,
})

local 内容内边距 = 创建实例("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    Parent = 内容区,
})
--// ======================== UI 元素工厂 ============================
local UI元素 = {}

--// 分隔标题
function UI元素.分区标题(文字)
    local 标签 = 创建实例("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "▸ " .. 文字,
        TextColor3 = 主题.强调色,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = 内容区,
    })
    return 标签
end

--// 普通按钮
function UI元素.按钮(文字, 回调)
    local 按钮 = 创建实例("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = 主题.面板,
        Text = 文字,
        TextColor3 = 主题.文字,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        AutoButtonColor = true,
        Parent = 内容区,
    })
    添加圆角(按钮, 6)
    按钮.MouseButton1Click:Connect(function()
        安全调用(回调)
    end)
    return 按钮
end

--// 开关按钮
function UI元素.开关(文字, 默认状态, 回调)
    local 容器 = 创建实例("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = 主题.面板,
        Parent = 内容区,
    })
    添加圆角(容器, 6)

    local 标签 = 创建实例("TextLabel", {
        Size = UDim2.new(0.65, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = 文字,
        TextColor3 = 主题.文字,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = 容器,
    })

    local 开关按钮 = 创建实例("TextButton", {
        Size = UDim2.new(0, 56, 0, 28),
        Position = UDim2.new(1, -66, 0.5, -14),
        BackgroundColor3 = 默认状态 and 主题.绿色 or Color3.fromRGB(50, 50, 55),
        Text = 默认状态 and "开" or "关",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = 容器,
    })
    添加圆角(开关按钮, 6)

    local 状态 = 默认状态
    开关按钮.MouseButton1Click:Connect(function()
        状态 = not 状态
        开关按钮.Text = 状态 and "开" or "关"
        开关按钮.BackgroundColor3 = 状态 and 主题.绿色 or Color3.fromRGB(50, 50, 55)
        安全调用(function() 回调(状态) end)
    end)

    return {
        设置 = function(值)
            状态 = 值
            开关按钮.Text = 值 and "开" or "关"
            开关按钮.BackgroundColor3 = 值 and 主题.绿色 or Color3.fromRGB(50, 50, 55)
        end
    }
end

--// 滑块
function UI元素.滑块(标签文字, 最小值, 最大值, 默认值, 回调)
    local 容器 = 创建实例("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = 主题.面板,
        Parent = 内容区,
    })
    添加圆角(容器, 6)

    local 标题 = 创建实例("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = 标签文字 .. " : " .. 默认值,
        TextColor3 = 主题.文字,
        Font = Enum.Font.Gotham,
        TextSize = 12.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = 容器,
    })

    local 轨道 = 创建实例("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = Color3.fromRGB(40, 40, 48),
        Parent = 容器,
    })
    添加圆角(轨道, 3)

    local 填充 = 创建实例("Frame", {
        Size = UDim2.new((默认值 - 最小值) / (最大值 - 最小值), 0, 1, 0),
        BackgroundColor3 = 主题.强调色,
        Parent = 轨道,
    })
    添加圆角(填充, 3)

    local 拖动中 = false
    local 当前值 = 默认值

    local function 更新值(比例)
        比例 = math.clamp(比例, 0, 1)
        填充.Size = UDim2.new(比例, 0, 1, 0)
        当前值 = math.floor(最小值 + 比例 * (最大值 - 最小值))
        标题.Text = 标签文字 .. " : " .. 当前值
        回调(当前值)
    end

    轨道.InputBegan:Connect(function(输入)
        if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
           输入.UserInputType == Enum.UserInputType.Touch then
            拖动中 = true
        end
    end)

    运行服务.RenderStepped:Connect(function()
        if 拖动中 then
            local 鼠标位置 = 输入服务:GetMouseLocation()
            local 比例 = (鼠标位置.X - 轨道.AbsolutePosition.X) / 轨道.AbsoluteSize.X
            更新值(比例)
        end
    end)

    输入服务.InputEnded:Connect(function(输入)
        if 输入.UserInputType == Enum.UserInputType.MouseButton1 or
           输入.UserInputType == Enum.UserInputType.Touch then
            拖动中 = false
        end
    end)

    回调(默认值)
end

--// 信息显示框
function UI元素.信息框(标题文字, 内容文字)
    local 容器 = 创建实例("Frame", {
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = Color3.fromRGB(18, 22, 32),
        Parent = 内容区,
    })
    添加圆角(容器, 8)
    添加描边(容器, 主题.蓝色, 1)

    local 标题 = 创建实例("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = "ℹ " .. 标题文字,
        TextColor3 = 主题.蓝色,
        Font = Enum.Font.GothamBold,
        TextSize = 12.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = 容器,
    })

    local 内容 = 创建实例("TextLabel", {
        Size = UDim2.new(1, -20, 0, 34),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = 内容文字,
        TextColor3 = 主题.次要文字,
        Font = Enum.Font.Gotham,
        TextSize = 11.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = 容器,
    })

    return { 更新 = function(新文字) 内容.Text = 新文字 end }
end

--// 下拉选择框
function UI元素.下拉框(标签文字, 选项列表, 默认值, 回调)
    local 容器 = 创建实例("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = 主题.面板,
        Parent = 内容区,
    })
    添加圆角(容器, 6)

    local 标签 = 创建实例("TextLabel", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = 标签文字,
        TextColor3 = 主题.文字,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = 容器,
    })

    local 当前索引 = 1
    for i, v in ipairs(选项列表) do
        if v == 默认值 then 当前索引 = i break end
    end

    local 下拉按钮 = 创建实例("TextButton", {
        Size = UDim2.new(0.45, -6, 0, 30),
        Position = UDim2.new(0.5, 3, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(35, 35, 42),
        Text = 默认值,
        TextColor3 = 主题.文字,
        Font = Enum.Font.Gotham,
        TextSize = 11.5,
        Parent = 容器,
    })
    添加圆角(下拉按钮, 5)

    local 展开中 = false
    local 选项容器 = 创建实例("Frame", {
        Size = UDim2.new(0.45, -6, 0, #选项列表 * 28),
        Position = UDim2.new(0.5, 3, 1, 4),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        Visible = false,
        Parent = 容器,
        ZIndex = 10,
    })
    添加圆角(选项容器, 5)

    for i, 选项 in ipairs(选项列表) do
        local 选项按钮 = 创建实例("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            Position = UDim2.new(0, 0, 0, (i-1)*26 + 2),
            BackgroundTransparency = 1,
            Text = 选项,
            TextColor3 = 主题.文字,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            Parent = 选项容器,
            ZIndex = 11,
        })
        选项按钮.MouseButton1Click:Connect(function()
            下拉按钮.Text = 选项
            展开中 = false
            选项容器.Visible = false
            回调(选项)
        end)
    end

    下拉按钮.MouseButton1Click:Connect(function()
        展开中 = not 展开中
        选项容器.Visible = 展开中
    end)
end

--// 输入框
function UI元素.输入框(标签文字, 占位符, 默认值, 回调)
    local 容器 = 创建实例("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = 主题.面板,
        Parent = 内容区,
    })
    添加圆角(容器, 6)

    local 标签 = 创建实例("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = 标签文字,
        TextColor3 = 主题.文字,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = 容器,
    })

    local 输入框 = 创建实例("TextBox", {
        Size = UDim2.new(0.5, -6, 0, 30),
        Position = UDim2.new(0.45, 3, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        Text = 默认值 or "",
        PlaceholderText = 占位符 or "",
        TextColor3 = 主题.文字,
        PlaceholderColor3 = 主题.次要文字,
        Font = Enum.Font.Gotham,
        TextSize = 11.5,
        Parent = 容器,
    })
    添加圆角(输入框, 5)

    输入框.FocusLost:Connect(function()
        回调(输入框.Text)
    end)
end

--// ======================== FPS 计数器 ============================
local fps数据 = { 计数 = 0, 上次时间 = tick(), 文本 = "计算中..." }

spawn(function()
    while wait(0.5) do
        fps数据.文本 = string.format("%.0f FPS", fps数据.计数 * 2)
        fps数据.计数 = 0
    end
end)

运行服务.RenderStepped:Connect(function()
    fps数据.计数 = fps数据.计数 + 1
end)

--// ======================== 悬浮按钮逻辑 ============================
悬浮按钮.MouseButton1Click:Connect(function()
    主面板.Visible = not 主面板.Visible
end)

--// ======================== 玩家信息面板 ============================
UI元素.分区标题("📋 玩家信息")

local 信息框 = UI元素.信息框("系统信息",
    "用户名: " .. 本地玩家.Name .. "\n" ..
    "显示名: " .. 本地玩家.DisplayName .. "\n" ..
    "用户ID: " .. 本地玩家.UserId .. "\n" ..
    "账号年龄: " .. 本地玩家.AccountAge .. "天")

local 性能框 = UI元素.信息框("性能信息", "帧率: " .. fps数据.文本)

spawn(function()
    while wait(1) do
        性能框.更新("帧率: " .. fps数据.文本)
    end
end)

UI元素.按钮("📋 复制QQ群号: " .. 配置.界面.群号, function()
    安全调用(function()
        setclipboard(配置.界面.群号)
        local 提示 = 创建实例("TextLabel", {
            Size = UDim2.new(0, 220, 0, 32),
            Position = UDim2.new(0.5, -110, 0, 50),
            BackgroundColor3 = 主题.绿色,
            Text = "✓ QQ群号已复制到剪贴板",
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Parent = 主界面,
        })
        添加圆角(提示, 8)
        垃圾回收:AddItem(提示, 2.5)
    end)
end)

UI元素.按钮("🔄 重置所有数值", function()
    安全调用(function()
        local 人类 = 获取人类()
        人类.WalkSpeed = 16
        人类.JumpPower = 50
        工作区.Gravity = 196
    end)
end)
--// ======================== 飞行系统（核心修复） ============================
UI元素.分区标题("🚀 飞行控制")

-- 飞行状态管理
local 飞行系统 = {
    启用 = false,
    速度 = 60,
    摇杆X = 0,
    摇杆Y = 0,
    上升 = false,
    下降 = false,
    身体速度 = nil,
    身体陀螺 = nil,
}

-- 创建飞行对象
function 飞行系统.创建()
    local 角色 = 获取角色()
    local 根 = 角色:FindFirstChild("HumanoidRootPart")
    if not 根 then return end

    -- 清理旧对象
    if 飞行系统.身体速度 then 飞行系统.身体速度:Destroy() end
    if 飞行系统.身体陀螺 then 飞行系统.身体陀螺:Destroy() end

    -- 创建 BodyVelocity（手机端比 LinearVelocity 稳）
    飞行系统.身体速度 = 创建实例("BodyVelocity", {
        Velocity = Vector3.zero,
        MaxForce = Vector3.new(1e6, 1e6, 1e6),
        P = 1250,
        Parent = 根,
    })

    -- 创建 BodyGyro 控制朝向
    飞行系统.身体陀螺 = 创建实例("BodyGyro", {
        CFrame = 根.CFrame,
        MaxTorque = Vector3.new(1e6, 1e6, 1e6),
        P = 15000,
        Parent = 根,
    })

    -- 锁定人物（防止被 Humanoid 纠正回地面）
    local 人类 = 角色:FindFirstChild("Humanoid")
    if 人类 then 人类.PlatformStand = true end
end

-- 销毁飞行对象
function 飞行系统.销毁()
    飞行系统.启用 = false
    if 飞行系统.身体速度 then
        飞行系统.身体速度:Destroy()
        飞行系统.身体速度 = nil
    end
    if 飞行系统.身体陀螺 then
        飞行系统.身体陀螺:Destroy()
        飞行系统.身体陀螺 = nil
    end
    local 角色 = 获取角色()
    if 角色 then
        local 人类 = 角色:FindFirstChild("Humanoid")
        if 人类 then 人类.PlatformStand = false end
    end
end

-- 飞行心跳（每帧执行）
运行服务.RenderStepped:Connect(function()
    if not 飞行系统.启用 then return end

    local 角色 = 获取角色()
    if not 角色 then return end
    local 根 = 角色:FindFirstChild("HumanoidRootPart")
    if not 根 then return end

    -- 确保飞行对象存在
    if not 飞行系统.身体速度 or not 飞行系统.身体陀螺 then
        飞行系统.创建()
        if not 飞行系统.身体速度 then return end
    end

    -- 计算移动方向
    local 方向 = Vector3.zero
    local 前 = 摄像机.CFrame.LookVector
    local 右 = 摄像机.CFrame.RightVector

    -- 摇杆输入（虚拟摇杆 - 纯触屏控制）
    方向 = 方向 + 前 * 飞行系统.摇杆Y
    方向 = 方向 + 右 * 飞行系统.摇杆X

    -- 升降按钮
    if 飞行系统.上升 then 方向 = 方向 + Vector3.yAxis end
    if 飞行系统.下降 then 方向 = 方向 - Vector3.yAxis end

    -- 键盘输入（如果有外接键盘）
    if 输入服务:IsKeyDown(Enum.KeyCode.W) then 方向 = 方向 + 前 end
    if 输入服务:IsKeyDown(Enum.KeyCode.S) then 方向 = 方向 - 前 end
    if 输入服务:IsKeyDown(Enum.KeyCode.A) then 方向 = 方向 - 右 end
    if 输入服务:IsKeyDown(Enum.KeyCode.D) then 方向 = 方向 + 右 end
    if 输入服务:IsKeyDown(Enum.KeyCode.Space) then 方向 = 方向 + Vector3.yAxis end
    if 输入服务:IsKeyDown(Enum.KeyCode.LeftShift) or
       输入服务:IsKeyDown(Enum.KeyCode.RightShift) then
        方向 = 方向 - Vector3.yAxis
    end

    -- 归一化并应用速度
    if 方向.Magnitude > 0 then
        方向 = 方向.Unit * 飞行系统.速度
    end

    -- 设置速度
    飞行系统.身体速度.Velocity = 方向

    -- 设置朝向（跟随相机）
    飞行系统.身体陀螺.CFrame = CFrame.new(根.Position, 根.Position + 摄像机.CFrame.LookVector)
end)

-- 飞行开关
UI元素.开关("✈️ 飞行模式", false, function(状态)
    if 状态 then
        飞行系统.启用 = true
        飞行系统.创建()
    else
        飞行系统.销毁()
    end
end)

-- 飞行速度滑块
UI元素.滑块("飞行速度", 20, 200, 60, function(值)
    飞行系统.速度 = 值
end)

--// ======================== 虚拟摇杆（纯触屏飞行控制） ============================
local 摇杆界面 = 创建实例("ScreenGui", {
    Name = "AM_虚拟摇杆",
    Parent = 本地玩家:WaitForChild("PlayerGui"),
    ResetOnSpawn = false,
    Enabled = false,
})

-- 摇杆底座
local 摇杆底座 = 创建实例("Frame", {
    Size = UDim2.new(0, 120, 0, 120),
    Position = UDim2.new(0, 30, 1, -160),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    BackgroundTransparency = 0.3,
    Parent = 摇杆界面,
})
添加圆角(摇杆底座, 60)
添加描边(摇杆底座, 主题.强调色, 2)

-- 摇杆按钮
local 摇杆按钮 = 创建实例("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0.5, -25, 0.5, -25),
    BackgroundColor3 = 主题.强调色,
    Text = "",
    Parent = 摇杆底座,
})
添加圆角(摇杆按钮, 25)

-- 摇杆逻辑
local 摇杆拖动 = false
local 摇杆最大距离 = 40
local 摇杆触摸ID = nil

摇杆按钮.InputBegan:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.Touch then
        摇杆拖动 = true
        摇杆触摸ID = 输入.UserInputId
    elseif 输入.UserInputType == Enum.UserInputType.MouseButton1 then
        摇杆拖动 = true
    end
end)

摇杆按钮.InputEnded:Connect(function(输入)
    if 输入.UserInputType == Enum.UserInputType.Touch and
       输入.UserInputId == 摇杆触摸ID then
        摇杆拖动 = false
        摇杆按钮.Position = UDim2.new(0.5, -25, 0.5, -25)
        飞行系统.摇杆X = 0
        飞行系统.摇杆Y = 0
    elseif 输入.UserInputType == Enum.UserInputType.MouseButton1 then
        摇杆拖动 = false
        摇杆按钮.Position = UDim2.new(0.5, -25, 0.5, -25)
        飞行系统.摇杆X = 0
        飞行系统.摇杆Y = 0
    end
end)

运行服务.RenderStepped:Connect(function()
    if 摇杆拖动 then
        local 鼠标 = 输入服务:GetMouseLocation()
        local 底座位置 = 摇杆底座.AbsolutePosition
        local 相对X = 鼠标.X - 底座位置.X - 60
        local 相对Y = 鼠标.Y - 底座位置.Y - 60

        -- 限制范围
        local 距离 = math.sqrt(相对X^2 + 相对Y^2)
        if 距离 > 摇杆最大距离 then
            相对X = 相对X / 距离 * 摇杆最大距离
            相对Y = 相对Y / 距离 * 摇杆最大距离
        end

        -- 移动按钮
        摇杆按钮.Position = UDim2.new(0, 35 + 相对X, 0, 35 + 相对Y)

        -- 输出到飞行系统（-1 到 1）
        飞行系统.摇杆X = 相对X / 摇杆最大距离
        飞行系统.摇杆Y = -相对Y / 摇杆最大距离
    end
end)

-- 升降按钮（右侧）
local 上升按钮 = 创建实例("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(1, -90, 1, -130),
    BackgroundColor3 = Color3.fromRGB(40, 80, 40),
    Text = "↑",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    Parent = 摇杆界面,
})
添加圆角(上升按钮, 25)
添加描边(上升按钮, Color3.fromRGB(60, 200, 60), 1)

上升按钮.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or
       i.UserInputType == Enum.UserInputType.MouseButton1 then
        飞行系统.上升 = true
    end
end)

上升按钮.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or
       i.UserInputType == Enum.UserInputType.MouseButton1 then
        飞行系统.上升 = false
    end
end)

local 下降按钮 = 创建实例("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(1, -90, 1, -70),
    BackgroundColor3 = Color3.fromRGB(80, 40, 40),
    Text = "↓",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    Parent = 摇杆界面,
})
添加圆角(下降按钮, 25)
添加描边(下降按钮, Color3.fromRGB(200, 60, 60), 1)

下降按钮.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or
       i.UserInputType == Enum.UserInputType.MouseButton1 then
        飞行系统.下降 = true
    end
end)

下降按钮.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or
       i.UserInputType == Enum.UserInputType.MouseButton1 then
        飞行系统.下降 = false
    end
end)

-- 飞行开启时显示摇杆，关闭时隐藏
运行服务.RenderStepped:Connect(function()
    摇杆界面.Enabled = 飞行系统.启用
end)

--// ======================== 备用飞行系统（方法B） ============================
-- 如果 BodyVelocity 在某些游戏被阻止，可以用 CFrame 直接移动
local 备用飞行 = {
    启用 = false,
    速度 = 30,
}

function 备用飞行.执行()
    if not 备用飞行.启用 then return end
    local 根 = 获取根部件()
    if not 根 then return end

    local 方向 = Vector3.zero
    local 前 = 摄像机.CFrame.LookVector
    local 右 = 摄像机.CFrame.RightVector

    方向 = 方向 + 前 * 飞行系统.摇杆Y
    方向 = 方向 + 右 * 飞行系统.摇杆X
    if 飞行系统.上升 then 方向 = 方向 + Vector3.yAxis end
    if 飞行系统.下降 then 方向 = 方向 - Vector3.yAxis end

    if 方向.Magnitude > 0 then
        方向 = 方向.Unit * 备用飞行.速度 * 0.016 -- 帧率补偿
    end

    根.CFrame = 根.CFrame + 方向
end

-- 在 RenderStepped 中同时运行备用方法
运行服务.RenderStepped:Connect(function()
    备用飞行.执行()
end)

-- 切换飞行模式的下拉框
UI元素.下拉框("飞行引擎", {"BodyVelocity", "CFrame直接移动"}, "BodyVelocity", function(选项)
    if 选项 == "BodyVelocity" then
        飞行系统.启用 = true
        备用飞行.启用 = false
        飞行系统.创建()
    else
        飞行系统.启用 = false
        飞行系统.销毁()
        备用飞行.启用 = true
    end
end)
--// ======================== 移动属性 ============================
UI元素.分区标题("🏃 移动属性")

UI元素.滑块("行走速度", 16, 300, 16, function(值)
    安全调用(function()
        获取人类().WalkSpeed = 值
    end)
end)

UI元素.滑块("跳跃力量", 50, 300, 50, function(值)
    安全调用(function()
        获取人类().JumpPower = 值
    end)
end)

UI元素.滑块("世界重力", 0, 196, 196, function(值)
    工作区.Gravity = 值
    配置.杂项.重力 = 值
end)

-- 速度快捷按钮行
UI元素.按钮("🏃 冲刺 (100)", function()
    安全调用(function()
        获取人类().WalkSpeed = 100
    end)
end)

UI元素.按钮("🐌 恢复正常速度", function()
    安全调用(function()
        获取人类().WalkSpeed = 16
    end)
end)

UI元素.按钮("🦘 超级跳跃 (150)", function()
    安全调用(function()
        获取人类().JumpPower = 150
    end)
end)

--// ======================== 角色状态 ============================
UI元素.分区标题("🛡️ 角色状态")

-- 穿墙
local 穿墙连接 = nil
UI元素.开关("穿墙穿透", false, function(状态)
    配置.杂项.穿墙 = 状态
    local 角色 = 获取角色()
    if not 角色 then return end

    if 状态 then
        穿墙连接 = 运行服务.Stepped:Connect(function()
            local 当前角色 = 获取角色()
            if not 当前角色 then return end
            for _, 部件 in pairs(当前角色:GetDescendants()) do
                if 部件:IsA("BasePart") then
                    部件.CanCollide = false
                end
            end
        end)
    else
        if 穿墙连接 then
            穿墙连接:Disconnect()
            穿墙连接 = nil
        end
    end
end)

-- 无限跳
local 无限跳连接 = nil
UI元素.开关("无限跳跃", false, function(状态)
    if 状态 then
        无限跳连接 = 输入服务.JumpRequest:Connect(function()
            安全调用(function()
                获取人类():ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end)
    else
        if 无限跳连接 then
            无限跳连接:Disconnect()
            无限跳连接 = nil
        end
    end
end)

-- 防坠落
local 防坠连接 = nil
UI元素.开关("防坠落", false, function(状态)
    if 状态 then
        防坠连接 = 运行服务.Stepped:Connect(function()
            local 根 = 获取根部件()
            if 根 and 根.Velocity.Y < -80 then
                根.Velocity = Vector3.new(根.Velocity.X, 0, 根.Velocity.Z)
            end
        end)
    else
        if 防坠连接 then
            防坠连接:Disconnect()
            防坠连接 = nil
        end
    end
end)

--// ======================== 重生处理 ============================
本地玩家.CharacterAdded:Connect(function(新角色)
    task.wait(1)
    -- 重生后重置飞行
    飞行系统.销毁()
    -- 重生后重新应用穿墙
    if 配置.杂项.穿墙 then
        for _, 部件 in pairs(新角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.CanCollide = false
            end
        end
    end
    -- 重生后重新应用速度
    local 人类 = 新角色:FindFirstChild("Humanoid")
    if 人类 then
        人类.WalkSpeed = 16
        人类.JumpPower = 50
    end
end)

--// ======================== 视觉增强 ============================
UI元素.分区标题("👁 视觉增强")

-- 夜视
UI元素.开关("夜视模式", false, function(状态)
    配置.视觉.夜视 = 状态
    if 状态 then
        灯光服务.Ambient = Color3.new(1, 1, 1)
    else
        灯光服务.Ambient = Color3.new(0, 0, 0)
    end
end)

-- 去雾
UI元素.按钮("🌫️ 去除雾气", function()
    灯光服务.FogEnd = 1000000
    灯光服务.FogStart = 0
    配置.视觉.去雾 = true
end)

UI元素.按钮("🌫️ 恢复雾气", function()
    灯光服务.FogEnd = 1000
    配置.视觉.去雾 = false
end)

-- 广角
UI元素.按钮("📷 广角视野 (120)", function()
    摄像机.FieldOfView = 120
    配置.视觉.广角 = true
end)

UI元素.按钮("📷 恢复视野 (70)", function()
    摄像机.FieldOfView = 70
    配置.视觉.广角 = false
end)

UI元素.滑块("视野角度", 50, 120, 70, function(值)
    摄像机.FieldOfView = 值
end)

-- 删除阴影
UI元素.开关("删除阴影", false, function(状态)
    配置.视觉.删除阴影 = 状态
    if 状态 then
        灯光服务.GlobalShadows = false
        灯光服务.ShadowSoftness = 0
        for _, obj in pairs(工作区:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                obj.CastShadow = false
            end
        end
    else
        灯光服务.GlobalShadows = true
        灯光服务.ShadowSoftness = 1
    end
end)

-- 全图明亮
UI元素.按钮("☀️ 全图明亮", function()
    灯光服务.Ambient = Color3.new(1, 1, 1)
    灯光服务.OutdoorAmbient = Color3.new(1, 1, 1)
    灯光服务.Brightness = 5
end)

UI元素.按钮("☀️ 恢复光照", function()
    灯光服务.Ambient = Color3.new(0, 0, 0)
    灯光服务.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    灯光服务.Brightness = 2
end)

--// ======================== ESP 系统 ============================
UI元素.分区标题("👁 ESP 透视")

local ESP数据 = {
    启用 = false,
    高亮列表 = {},
    名称标签 = {},
    距离标签 = {},
    血量标签 = {},
}

-- 创建玩家ESP
function ESP数据.创建(玩家)
    if not 玩家.Character then return end
    if not 玩家.Character:FindFirstChild("HumanoidRootPart") then return end

    local 角色 = 玩家.Character
    local 根 = 角色.HumanoidRootPart

    -- Highlight
    if not ESP数据.高亮列表[玩家] then
        local hl = 创建实例("Highlight", {
            Adornee = 角色,
            FillColor = Color3.fromRGB(255, 50, 50),
            OutlineColor = Color3.fromRGB(255, 255, 255),
            FillTransparency = 0.7,
            OutlineTransparency = 0,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Parent = 主界面,
        })
        ESP数据.高亮列表[玩家] = hl
    end

    -- 名称标签
    if 配置.ESP.显示名字 and not ESP数据.名称标签[玩家] then
        local bb = 创建实例("BillboardGui", {
            Adornee = 根,
            Size = UDim2.new(0, 120, 0, 22),
            StudsOffset = Vector3.new(0, 3.5, 0),
            AlwaysOnTop = true,
            Parent = 根,
        })
        local lbl = 创建实例("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = 玩家.Name,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            Parent = bb,
        })
        ESP数据.名称标签[玩家] = bb
    end

    -- 距离标签
    if 配置.ESP.显示距离 and not ESP数据.距离标签[玩家] then
        local bb = 创建实例("BillboardGui", {
            Adornee = 根,
            Size = UDim2.new(0, 100, 0, 18),
            StudsOffset = Vector3.new(0, -3, 0),
            AlwaysOnTop = true,
            Parent = 根,
        })
        local lbl = 创建实例("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "距离: 0",
            TextColor3 = Color3.fromRGB(0, 255, 255),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            Parent = bb,
        })
        ESP数据.距离标签[玩家] = {Gui = bb, Label = lbl}
    end
end

-- 清除玩家ESP
function ESP数据.清除(玩家)
    if ESP数据.高亮列表[玩家] then
        ESP数据.高亮列表[玩家]:Destroy()
        ESP数据.高亮列表[玩家] = nil
    end
    if ESP数据.名称标签[玩家] then
        ESP数据.名称标签[玩家]:Destroy()
        ESP数据.名称标签[玩家] = nil
    end
    if ESP数据.距离标签[玩家] then
        ESP数据.距离标签[玩家].Gui:Destroy()
        ESP数据.距离标签[玩家] = nil
    end
end

-- 清除所有ESP
function ESP数据.清除全部()
    for p, _ in pairs(ESP数据.高亮列表) do
        ESP数据.清除(p)
    end
end

-- ESP 主循环
运行服务.RenderStepped:Connect(function()
    if not ESP数据.启用 then
        if next(ESP数据.高亮列表) then
            ESP数据.清除全部()
        end
        return
    end

    local 本地根 = 获取根部件()
    if not 本地根 then return end

    for _, 玩家 in pairs(玩家服务:GetPlayers()) do
        if 玩家 ~= 本地玩家 and 玩家.Character and
           玩家.Character:FindFirstChild("HumanoidRootPart") then
            ESP数据.创建(玩家)

            -- 更新距离
            if ESP数据.距离标签[玩家] then
                local 距离 = (玩家.Character.HumanoidRootPart.Position - 本地根.Position).Magnitude
                ESP数据.距离标签[玩家].Label.Text = string.format("距离: %d", math.floor(距离))
            end
        end
    end
end)

-- ESP 开关
UI元素.开关("ESP 总开关", false, function(状态)
    ESP数据.启用 = 状态
    配置.ESP.启用 = 状态
    if not 状态 then
        ESP数据.清除全部()
    end
end)

UI元素.开关("显示玩家名称", true, function(状态)
    配置.ESP.显示名字 = 状态
end)

UI元素.开关("显示玩家距离", true, function(状态)
    配置.ESP.显示距离 = 状态
end)

-- 玩家加入/离开处理
玩家服务.PlayerAdded:Connect(function(玩家)
    玩家.CharacterAdded:Connect(function()
        if ESP数据.启用 then
            task.wait(1)
            ESP数据.创建(玩家)
        end
    end)
    玩家.CharacterRemoving:Connect(function()
        ESP数据.清除(玩家)
    end)
end)

玩家服务.PlayerRemoving:Connect(function(玩家)
    ESP数据.清除(玩家)
end)
--// ======================== 自瞄系统 ============================
UI元素.分区标题("🎯 自瞄系统")

local 自瞄数据 = {
    启用 = false,
    范围 = 140,
    平滑度 = 0.12,
    当前目标 = nil,
    FOV圈 = nil,
}

-- 创建 FOV 圈（用 Drawing API）
安全调用(function()
    自瞄数据.FOV圈 = Drawing.new("Circle")
    自瞄数据.FOV圈.Visible = false
    自瞄数据.FOV圈.Thickness = 2
    自瞄数据.FOV圈.Color = Color3.fromRGB(0, 255, 100)
    自瞄数据.FOV圈.Filled = false
    自瞄数据.FOV圈.Radius = 自瞄数据.范围
    自瞄数据.FOV圈.Position = 摄像机.ViewportSize / 2
end)

-- 获取最近目标
function 自瞄数据.获取目标()
    local 最佳目标 = nil
    local 最小距离 = 自瞄数据.范围
    local 屏幕中心 = 摄像机.ViewportSize / 2

    for _, 玩家 in pairs(玩家服务:GetPlayers()) do
        if 玩家 ~= 本地玩家 and 玩家.Character and
           玩家.Character:FindFirstChild("Head") then
            local 头部 = 玩家.Character.Head
            local 屏幕坐标, 可见 = 摄像机:WorldToViewportPoint(头部.Position)

            if 可见 then
                local 距离 = (Vector2.new(屏幕坐标.X, 屏幕坐标.Y) - 屏幕中心).Magnitude
                if 距离 < 最小距离 then
                    最小距离 = 距离
                    最佳目标 = 头部
                end
            end
        end
    end

    return 最佳目标
end

-- 自瞄主循环
运行服务.RenderStepped:Connect(function()
    if not 自瞄数据.启用 then
        if 自瞄数据.FOV圈 then 自瞄数据.FOV圈.Visible = false end
        return
    end

    -- 更新 FOV 圈
    if 自瞄数据.FOV圈 then
        自瞄数据.FOV圈.Visible = true
        自瞄数据.FOV圈.Radius = 自瞄数据.范围
        自瞄数据.FOV圈.Position = 摄像机.ViewportSize / 2
    end

    -- 获取目标
    local 目标 = 自瞄数据.获取目标()
    if 目标 then
        local 目标位置 = 目标.Position
        摄像机.CFrame = 摄像机.CFrame:Lerp(
            CFrame.new(摄像机.CFrame.Position, 目标位置),
            自瞄数据.平滑度
        )
    end
end)

-- 自瞄开关
UI元素.开关("🎯 启用自瞄", false, function(状态)
    自瞄数据.启用 = 状态
    if not 状态 and 自瞄数据.FOV圈 then
        自瞄数据.FOV圈.Visible = false
    end
end)

-- FOV 范围滑块
UI元素.滑块("自瞄范围", 50, 400, 140, function(值)
    自瞄数据.范围 = 值
end)

-- 平滑度滑块
UI元素.滑块("瞄准平滑度", 1, 50, 12, function(值)
    自瞄数据.平滑度 = 值 / 100
end)

--// ======================== 战斗功能 ============================
UI元素.分区标题("⚔️ 战斗功能")

-- 点击传送工具
UI元素.按钮("🖱️ 点击传送工具", function()
    安全调用(function()
        local 鼠标 = 本地玩家:GetMouse()
        local 工具 = 创建实例("Tool", {
            Name = "点击传送",
            RequiresHandle = false,
            Parent = 本地玩家.Backpack,
        })
        工具.Activated:Connect(function()
            local 目标位置 = 鼠标.Hit + Vector3.new(0, 2.5, 0)
            获取根部件().CFrame = CFrame.new(目标位置.X, 目标位置.Y, 目标位置.Z)
        end)
    end)
end)

-- 甩飞
UI元素.按钮("💥 向上甩飞", function()
    安全调用(function()
        local 根 = 获取根部件()
        根.Velocity = Vector3.new(
            math.random(-200, 200),
            350,
            math.random(-200, 200)
        )
    end)
end)

UI元素.按钮("💥 随机甩飞", function()
    安全调用(function()
        local 根 = 获取根部件()
        根.Velocity = Vector3.new(
            math.random(-300, 300),
            math.random(100, 400),
            math.random(-300, 300)
        )
    end)
end)

-- 黑洞吸引
local 黑洞连接 = nil
UI元素.开关("🌀 黑洞吸引", false, function(状态)
    if 状态 then
        黑洞连接 = 运行服务.Heartbeat:Connect(function()
            local 根 = 获取根部件()
            if not 根 then return end
            for _, 对象 in pairs(工作区:GetDescendants()) do
                if 对象:IsA("BasePart") and not 对象.Anchored and
                    not 对象:IsDescendantOf(本地玩家.Character) then
                    对象.AssemblyLinearVelocity = (根.Position - 对象.Position).Unit * 5
                end
            end
        end)
    else
        if 黑洞连接 then
            黑洞连接:Disconnect()
            黑洞连接 = nil
        end
    end
end)

-- 磁铁效果
local 磁铁连接 = nil
UI元素.开关("🧲 磁铁效果", false, function(状态)
    if 状态 then
        磁铁连接 = 运行服务.Heartbeat:Connect(function()
            local 根 = 获取根部件()
            if not 根 then return end
            for _, 玩家 in pairs(玩家服务:GetPlayers()) do
                if 玩家 ~= 本地玩家 and 玩家.Character and
                   玩家.Character:FindFirstChild("HumanoidRootPart") then
                    local 目标根 = 玩家.Character.HumanoidRootPart
                    local 距离 = (根.Position - 目标根.Position).Magnitude
                    if 距离 < 50 and 距离 > 5 then
                        目标根.AssemblyLinearVelocity = (根.Position - 目标根.Position).Unit * 30
                    end
                end
            end
        end)
    else
        if 磁铁连接 then
            磁铁连接:Disconnect()
            磁铁连接 = nil
        end
    end
end)

-- 击退所有
UI元素.按钮("💢 击退所有人", function()
    安全调用(function()
        for _, 玩家 in pairs(玩家服务:GetPlayers()) do
            if 玩家 ~= 本地玩家 and 玩家.Character and
               玩家.Character:FindFirstChild("HumanoidRootPart") then
                local 目标根 = 玩家.Character.HumanoidRootPart
                local 方向 = (目标根.Position - 获取根部件().Position).Unit
                目标根.Velocity = 方向 * 200 + Vector3.new(0, 100, 0)
            end
        end
    end)
end)
--// ======================== 整活娱乐 ============================
UI元素.分区标题("🎮 整活娱乐")

-- 旋转
local 旋转连接 = nil
UI元素.开关("🌀 高速旋转", false, function(状态)
    if 状态 then
        旋转连接 = 运行服务.Stepped:Connect(function()
            local 根 = 获取根部件()
            if 根 then
                根.CFrame = 根.CFrame * CFrame.Angles(0, math.rad(15), 0)
            end
        end)
    else
        if 旋转连接 then
            旋转连接:Disconnect()
            旋转连接 = nil
        end
    end
end)

-- 倒立
UI元素.按钮("🤸 倒立模式", function()
    安全调用(function()
        local 根 = 获取根部件()
        if 根 then
            根.CFrame = 根.CFrame * CFrame.Angles(math.rad(180), 0, 0)
        end
    end)
end)

-- 弹跳
local 弹跳连接 = nil
UI元素.开关("🏀 弹跳模式", false, function(状态)
    if 状态 then
        local 弹跳高度 = 0
        弹跳连接 = 运行服务.Heartbeat:Connect(function()
            local 根 = 获取根部件()
            if 根 then
                弹跳高度 = 弹跳高度 + 0.15
                根.Velocity = Vector3.new(根.Velocity.X, math.sin(弹跳高度) * 30 + 10, 根.Velocity.Z)
            end
        end)
    else
        if 弹跳连接 then
            弹跳连接:Disconnect()
            弹跳连接 = nil
        end
    end
end)

-- 跟随鼠标
local 跟随连接 = nil
UI元素.开关("👆 悬浮跟随手指", false, function(状态)
    if 状态 then
        跟随连接 = 运行服务.RenderStepped:Connect(function()
            local 鼠标 = 输入服务:GetMouseLocation()
            local 根 = 获取根部件()
            if 根 then
                local 射线 = 摄像机:ScreenPointToRay(鼠标.X, 鼠标.Y)
                根.CFrame = CFrame.new(射线.Origin + 射线.Direction * 10)
            end
        end)
    else
        if 跟随连接 then
            跟随连接:Disconnect()
            跟随连接 = nil
        end
    end
end)

-- 变大
UI元素.按钮("📏 角色变大2倍", function()
    安全调用(function()
        local 角色 = 获取角色()
        for _, 部件 in pairs(角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.Size = 部件.Size * 2
            end
        end
    end)
end)

-- 变小
UI元素.按钮("📏 角色变小0.5倍", function()
    安全调用(function()
        local 角色 = 获取角色()
        for _, 部件 in pairs(角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.Size = 部件.Size * 0.5
            end
        end
    end)
end)

-- 透明
UI元素.按钮("👻 角色透明", function()
    安全调用(function()
        local 角色 = 获取角色()
        for _, 部件 in pairs(角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.Transparency = 0.7
            elseif 部件:IsA("Decal") or 部件:IsA("Texture") then
                部件.Transparency = 0.7
            end
        end
    end)
end)

-- 恢复外观
UI元素.按钮("👤 恢复外观", function()
    安全调用(function()
        local 角色 = 获取角色()
        for _, 部件 in pairs(角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.Transparency = 0
            elseif 部件:IsA("Decal") or 部件:IsA("Texture") then
                部件.Transparency = 0
            end
        end
    end)
end)

--// ======================== 平台保护 ============================
UI元素.分区标题("🛡️ 平台保护")

UI元素.按钮("🛡️ 安全平台（防坠落+缓降）", function()
    安全调用(function()
        local 根 = 获取根部件()
        if not 根 then return end

        local 平台 = 创建实例("Part", {
            Size = Vector3.new(6, 1, 6),
            CFrame = 根.CFrame - Vector3.new(0, 3, 0),
            Anchored = true,
            Color = Color3.fromRGB(80, 200, 120),
            Material = Enum.Material.Neon,
            Parent = 工作区,
        })

        -- 跟随玩家
        运行服务.Heartbeat:Connect(function()
            if 平台.Parent and 根.Parent then
                平台.CFrame = 根.CFrame - Vector3.new(0, 3, 0)
            end
        end)

        垃圾回收:AddItem(平台, 30)
    end)
end)

--// ======================== 设置面板 ============================
UI元素.分区标题("⚙️ 设置")

UI元素.按钮("🔄 重生角色", function()
    安全调用(function()
        获取人类().Health = 0
    end)
end)

UI元素.按钮("🗑️ 关闭全部功能", function()
    -- 关闭飞行
    飞行系统.销毁()
    -- 关闭ESP
    ESP数据.清除全部()
    ESP数据.启用 = false
    配置.ESP.启用 = false
    -- 关闭自瞄
    自瞄数据.启用 = false
    配置.自瞄.启用 = false
    if 自瞄数据.FOV圈 then 自瞄数据.FOV圈.Visible = false end
    -- 关闭穿墙
    配置.杂项.穿墙 = false
    -- 关闭无限跳
    if 无限跳连接 then 无限跳连接:Disconnect() 无限跳连接 = nil end
    -- 关闭黑洞
    if 黑洞连接 then 黑洞连接:Disconnect() 黑洞连接 = nil end
    -- 恢复数值
    安全调用(function()
        获取人类().WalkSpeed = 16
        获取人类().JumpPower = 50
    end)
    工作区.Gravity = 196
    摄像机.FieldOfView = 70
    灯光服务.Ambient = Color3.new(0, 0, 0)

    -- 提示
    local 提示 = 创建实例("TextLabel", {
        Size = UDim2.new(0, 200, 0, 32),
        Position = UDim2.new(0.5, -100, 0, 60),
        BackgroundColor3 = 主题.绿色,
        Text = "✓ 全部功能已关闭",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = 主界面,
    })
    添加圆角(提示, 8)
    垃圾回收:AddItem(提示, 2)
end)

UI元素.按钮("❌ 销毁整个脚本", function()
    安全调用(function()
        飞行系统.销毁()
        ESP数据.清除全部()
        if 自瞄数据.FOV圈 then 自瞄数据.FOV圈:Remove() end
        主界面:Destroy()
        悬浮按钮:Destroy()
        if 摇杆界面 then 摇杆界面:Destroy() end
        getgenv().__AM_中文通用已加载 = nil
    end)
end)

--// ======================== 关于面板 ============================
UI元素.分区标题("ℹ️ 关于")

UI元素.信息框("脚本信息",
    "脚本名称: AM 通用脚本\n" ..
    "版本: 3.0.0\n" ..
    "作者: AM\n" ..
    "QQ群: " .. 配置.界面.群号 .. "\n" ..
    "声明: 仅供学习交流使用"
)

UI元素.按钮("📋 复制仓库地址", function()
    安全调用(function()
        setclipboard("https://github.com/AMHub-Hub/AM.Hub")
    end)
end)

UI元素.按钮("📋 复制执行命令", function()
    安全调用(function()
        setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/AMHub-Hub/AM.Hub/main/AM_Hub_Mobile.lua", true))()')
    end)
end)
--// ======================== 高级移动模块 ============================
UI元素.分区标题("🏃 高级移动")

-- 爬墙
local 爬墙连接 = nil
UI元素.开关("🧗 爬墙模式", false, function(状态)
    if 状态 then
        爬墙连接 = 运行服务.Heartbeat:Connect(function()
            local 根 = 获取根部件()
            local 人类 = 获取人类()
            if not 根 or not 人类 then return end

            -- 检测前方墙壁
            local 前方 = 摄像机.CFrame.LookVector
            local 射线 = Ray.new(根.Position, 前方 * 3)
            local 命中, 位置 = 工作区:Raycast(射线.Origin, 射线.Direction)

            if 命中 and 人类:GetState() == Enum.HumanoidStateType.Freefall then
                -- 沿墙壁向上移动
                根.Velocity = Vector3.new(根.Velocity.X, 35, 根.Velocity.Z)
            end
        end)
    else
        if 爬墙连接 then
            爬墙连接:Disconnect()
            爬墙连接 = nil
        end
    end
end)

-- BHop 连跳
local 连跳连接 = nil
UI元素.开关("🦘 自动连跳(BHop)", false, function(状态)
    if 状态 then
        连跳连接 = 运行服务.Stepped:Connect(function()
            local 人类 = 获取人类()
            if not 人类 then return end
            if 人类:GetState() == Enum.HumanoidStateType.Freefall or
               人类:GetState() == Enum.HumanoidStateType.Jumping then
                人类:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if 连跳连接 then
            连跳连接:Disconnect()
            连跳连接 = nil
        end
    end
end)

-- 滑步
UI元素.开关("🛷️ 地面滑步", false, function(状态)
    安全调用(function()
        local 人类 = 获取人类()
        if 状态 then
            人类.HipHeight = -5
            人类.WalkSpeed = 28
        else
            人类.HipHeight = 0
            人类.WalkSpeed = 16
        end
    end)
end)

-- 疾跑
UI元素.开关("💨 疾跑模式", false, function(状态)
    安全调用(function()
        local 人类 = 获取人类()
        if 状态 then
            人类.WalkSpeed = 50
        else
            人类.WalkSpeed = 16
        end
    end)
end)

-- 贴墙走
UI元素.按钮("🧱 贴墙走(开)", function()
    安全调用(function()
        local 根 = 获取根部件()
        if not 根 then return end

        -- 检测最近的墙壁
        local 方向 = 摄像机.CFrame.RightVector
        local 射线 = Ray.new(根.Position, 方向 * 5)
        local 命中 = 工作区:Raycast(射线.Origin, 射线.Direction)

        if 命中 then
            -- 吸附到墙壁
            local 墙壁位置 = 命中.Position
            根.CFrame = CFrame.new(墙壁位置 - 方向 * 2, 墙壁位置)
            根.Anchored = true

            -- 3秒后解除
            delay(3, function()
                if 根 then 根.Anchored = false end
            end)
        end
    end)
end)

--// ======================== 高级视觉 ============================
UI元素.分区标题("🎨 高级视觉")

-- 全屏颜色叠加
UI元素.按钮("🔴 红屏模式", function()
    local 覆盖 = 创建实例("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0.85,
        ZIndex = 999,
        Parent = 主界面,
    })
    垃圾回收:AddItem(覆盖, 3)
end)

UI元素.按钮("🔵 蓝屏模式", function()
    local 覆盖 = 创建实例("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 50, 255),
        BackgroundTransparency = 0.85,
        ZIndex = 999,
        Parent = 主界面,
    })
    垃圾回收:AddItem(覆盖, 3)
end)

-- 动态模糊效果
UI元素.按钮("🌫️ 动态模糊", function()
    安全调用(function()
        local 摄像机 = 工作区.CurrentCamera
        local 模糊 = 创建实例("BlurEffect", {
            Size = 12,
            Parent = 摄像机,
        })
        垃圾回收:AddItem(模糊, 5)

        -- 根据移动速度调整模糊强度
        运行服务.Heartbeat:Connect(function()
            if not 模糊.Parent then return end
            local 根 = 获取根部件()
            if 根 then
                local 速度 = 根.Velocity.Magnitude
                模糊.Size = math.clamp(速度 * 0.15, 0, 24)
            end
        end)
    end)
end)

-- 黑白滤镜
UI元素.开关("⚫ 黑白滤镜", false, function(状态)
    安全调用(function()
        local 摄像机 = 工作区.CurrentCamera
        if 状态 then
            local 色相 = 创建实例("ColorCorrectionEffect", {
                Saturation = 0,
                Contrast = 0.2,
                Parent = 摄像机,
            })
            配置.视觉.黑白 = 色相
        else
            if 配置.视觉.黑白 then
                配置.视觉.黑白:Destroy()
                配置.视觉.黑白 = nil
            end
        end
    end)
end)

-- 高饱和
UI元素.按钮("🌈 高饱和模式", function()
    安全调用(function()
        local 摄像机 = 工作区.CurrentCamera
        local 色相 = 创建实例("ColorCorrectionEffect", {
            Saturation = 2,
            Contrast = 0.3,
            Brightness = 0.15,
            Parent = 摄像机,
        })
        垃圾回收:AddItem(色相, 8)
    end)
end)

-- 暗角
UI元素.开关("🔲 暗角效果", false, function(状态)
    安全调用(function()
        local 摄像机 = 工作区.CurrentCamera
        if 状态 then
            local 暗角 = 创建实例("ColorCorrectionEffect", {
                Contrast = 0.5,
                Brightness = -0.2,
                Parent = 摄像机,
            })
            配置.视觉.暗角 = 暗角
        else
            if 配置.视觉.暗角 then
                配置.视觉.暗角:Destroy()
                配置.视觉.暗角 = nil
            end
        end
    end)
end)

--// ======================== 高级ESP ============================
UI元素.分区标题("🔍 高级ESP")

-- 骨骼ESP（简化版）
local 骨骼连接 = nil
local 骨骼线 = {}

UI元素.开关("🦴 骨骼ESP", false, function(状态)
    if 状态 then
        骨骼连接 = 运行服务.RenderStepped:Connect(function()
            -- 清除旧线条
            for _, 线 in pairs(骨骼线) do
                if 线 and 线.Parent then 线:Destroy() end
            end
            骨骼线 = {}

            for _, 玩家 in pairs(玩家服务:GetPlayers()) do
                if 玩家 ~= 本地玩家 and 玩家.Character then
                    local 角色 = 玩家.Character
                    local 头部 = 角色:FindFirstChild("Head")
                    local 躯干 = 角色:FindFirstChild("UpperTorso") or 角色:FindFirstChild("Torso")

                    if 头部 and 躯干 then
                        -- 用 Drawing 画线
                        安全调用(function()
                            local 线 = Drawing.new("Line")
                            线.From = 摄像机:WorldToViewportPoint(头部.Position)
                            线.To = 摄像机:WorldToViewportPoint(躯干.Position)
                            线.Color = Color3.fromRGB(255, 255, 0)
                            线.Thickness = 2
                            线.Visible = true
                            table.insert(骨骼线, 线)
                        end)
                    end
                end
            end
        end)
    else
        if 骨骼连接 then
            骨骼连接:Disconnect()
            骨骼连接 = nil
        end
        for _, 线 in pairs(骨骼线) do
            if 线 and 线.Remove then 线:Remove() end
        end
        骨骼线 = {}
    end
end)

-- 方框ESP
UI元素.开关("⬜ 2D方框ESP", false, function(状态)
    配置.ESP.显示方框 = 状态
end)

-- 血量显示
UI元素.开关("❤️ 显示血量", false, function(状态)
    配置.ESP.显示血量 = 状态
end)

-- 队伍检测
UI元素.开关("👥 队伍检测", false, function(状态)
    配置.ESP.队伍检测 = 状态
end)

-- ESP 颜色选择
UI元素.下拉框("ESP颜色", {"绿色", "红色", "蓝色", "黄色", "紫色", "彩虹"}, "绿色", function(选项)
    local 颜色表 = {
        绿色 = Color3.fromRGB(0, 255, 0),
        红色 = Color3.fromRGB(255, 0, 0),
        蓝色 = Color3.fromRGB(0, 100, 255),
        黄色 = Color3.fromRGB(255, 255, 0),
        紫色 = Color3.fromRGB(200, 0, 255),
        彩虹 = Color3.fromHSV(tick() % 5 / 5, 1, 1),
    }
    配置.ESP.颜色 = 颜色表[选项] or 颜色表.绿色
end)

--// ======================== 服务器工具 ============================
UI元素.分区标题("🔧 服务器工具")

-- 复制玩家位置
UI元素.输入框("传送到玩家(输入名字)", "输入玩家名称...", "", function(名字)
    安全调用(function()
        for _, 玩家 in pairs(玩家服务:GetPlayers()) do
            if 玩家.Name:lower():find(名字:lower()) or
               玩家.DisplayName:lower():find(名字:lower()) then
                local 目标根 = 玩家.Character and 玩家.Character:FindFirstChild("HumanoidRootPart")
                if 目标根 then
                    获取根部件().CFrame = 目标根.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end)
end)

-- 传送到鼠标位置
UI元素.按钮("🖱️ 传送到鼠标位置", function()
    安全调用(function()
        local 鼠标 = 本地玩家:GetMouse()
        if 鼠标 and 鼠标.Hit then
            local 位置 = 鼠标.Hit.Position + Vector3.new(0, 3, 0)
            获取根部件().CFrame = CFrame.new(位置)
        end
    end)
end)

-- 随机传送
UI元素.按钮("🎲 随机传送(1000范围)", function()
    安全调用(function()
        local 角度 = math.random(0, 360)
        local 距离 = math.random(50, 1000)
        local 方向 = Vector3.new(math.cos(math.rad(角度)), 0, math.sin(math.rad(角度)))
        获取根部件().CFrame = CFrame.new(方向 * 距离 + Vector3.new(0, 50, 0))
    end)
end)

-- 回到出生点
UI元素.按钮("🏠 回到出生点", function()
    安全调用(function()
        local 人类 = 获取人类()
        if 人类 then
            人类:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end)
end)

-- 复制坐标
UI元素.按钮("📋 复制当前坐标", function()
    安全调用(function()
        local 根 = 获取根部件()
        if 根 then
            local 坐标文本 = string.format("%.1f, %.1f, %.1f",
                根.Position.X, 根.Position.Y, 根.Position.Z)
            setclipboard(坐标文本)
        end
    end)
end)
--// ======================== 聊天工具 ============================
UI元素.分区标题("💬 聊天工具")

-- 刷屏
UI元素.输入框("刷屏(输入内容)", "输入要发送的消息...", "", function(文本)
    if 文本 == "" then return end
    配置.杂项.刷屏文本 = 文本
end)

UI元素.开关("📢 自动刷屏", false, function(状态)
    if 状态 then
        配置.杂项.刷屏 = true
        spawn(function()
            while 配置.杂项.刷屏 do
                安全调用(function()
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                        .SayMessageRequest:FireServer(
                            配置.杂项.刷屏文本 or "AM通用脚本 - QQ群: 179051448",
                            "All"
                        )
                end)
                wait(1.5)
            end
        end)
    else
        配置.杂项.刷屏 = false
    end
end)

-- 喊话
UI元素.按钮("📢 发送: AM通用脚本", function()
    安全调用(function()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
            .SayMessageRequest:FireServer(
                "AM通用脚本 | QQ群: 179051448 | 作者: AM",
                "All"
            )
    end)
end)

--// ======================== 网络优化 ============================
UI元素.分区标题("⚡ 网络优化")

UI元素.按钮("⚡ FPS提升(降低画质)", function()
    安全调用(function()
        灯光服务.GlobalShadows = false
        灯光服务.FogEnd = 100000
        灯光服务.Technology = Enum.Technology.Compatibility

        for _, 玩家 in pairs(玩家服务:GetPlayers()) do
            if 玩家 ~= 本地玩家 and 玩家.Character then
                for _, 部件 in pairs(玩家.Character:GetDescendants()) do
                    if 部件:IsA("BasePart") then
                        部件.Material = Enum.Material.Plastic
                        部件.Reflectance = 0
                    elseif 部件:IsA("Decal") or 部件:IsA("Texture") then
                        部件.Transparency = 0.5
                    end
                end
            end
        end
    end)
end)

UI元素.按钮("⚡ 恢复画质", function()
    安全调用(function()
        灯光服务.GlobalShadows = true
        灯光服务.FogEnd = 1000
        灯光服务.Technology = Enum.Technology.ShadowMap
    end)
end)

UI元素.按钮("📊 显示FPS计数器", function()
    local fpsGui = 创建实例("ScreenGui", {
        Name = "AM_FPS",
        Parent = 本地玩家:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
    })

    local fpsLabel = 创建实例("TextLabel", {
        Size = UDim2.new(0, 120, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Text = "FPS: --",
        TextColor3 = Color3.fromRGB(0, 255, 100),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = fpsGui,
    })
    添加圆角(fpsLabel, 6)

    local 计数 = 0
    local 时间 = tick()
    spawn(function()
        while fpsGui.Parent do
            计数 = 计数 + 1
            if tick() - 时间 >= 1 then
                fpsLabel.Text = string.format("FPS: %.0f", 计数)
                计数 = 0
                时间 = tick()
            end
            wait(0.016)
        end
    end)
end)

--// ======================== 角色美化 ============================
UI元素.分区标题("🎨 角色美化")

UI元素.按钮("✨ 全身发光", function()
    安全调用(function()
        local 角色 = 获取角色()
        for _, 部件 in pairs(角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.Material = Enum.Material.Neon
                部件.Color = Color3.fromHSV(math.random(), 0.7, 1)
            end
        end
    end)
end)

UI元素.按钮("🌈 彩虹身体", function()
    安全调用(function()
        local 角色 = 获取角色()
        spawn(function()
            while wait(0.1) do
                if not 角色.Parent then break end
                local hue = (tick() * 0.3) % 1
                local 颜色 = Color3.fromHSV(hue, 0.8, 1)
                for _, 部件 in pairs(角色:GetDescendants()) do
                    if 部件:IsA("BasePart") then
                        部件.Color = 颜色
                        部件.Material = Enum.Material.Neon
                    end
                end
            end
        end)
    end)
end)

UI元素.按钮("🦴 隐身(半透明)", function()
    安全调用(function()
        local 角色 = 获取角色()
        for _, 部件 in pairs(角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.Transparency = 0.85
            elseif 部件:IsA("Decal") or 部件:IsA("Texture") then
                部件.Transparency = 0.85
            end
        end
    end)
end)

UI元素.按钮("👤 恢复角色外观", function()
    安全调用(function()
        local 角色 = 获取角色()
        for _, 部件 in pairs(角色:GetDescendants()) do
            if 部件:IsA("BasePart") then
                部件.Transparency = 0
                部件.Material = Enum.Material.Plastic
            elseif 部件:IsA("Decal") or 部件:IsA("Texture") then
                部件.Transparency = 0
            end
        end
    end)
end)

--// ======================== 声音工具 ============================
UI元素.分区标题("🔊 声音工具")

UI元素.按钮("🔇 静音所有声音", function()
    安全调用(function()
        for _, 对象 in pairs(工作区:GetDescendants()) do
            if 对象:IsA("Sound") then
                对象.Volume = 0
            end
        end
    end)
end)

UI元素.按钮("🔊 恢复所有声音", function()
    安全调用(function()
        for _, 对象 in pairs(工作区:GetDescendants()) do
            if 对象:IsA("Sound") then
                对象.Volume = 1
            end
        end
    end)
end)

UI元素.滑块("全局音量", 0, 100, 100, function(值)
    安全调用(function()
        local 比例 = 值 / 100
        for _, 对象 in pairs(工作区:GetDescendants()) do
            if 对象:IsA("Sound") then
                对象.Volume = 比例
            end
        end
    end)
end)

--// ======================== 地图工具 ============================
UI元素.分区标题("🗺️ 地图工具")

UI元素.按钮("🗺️ 删除所有粒子", function()
    安全调用(function()
        for _, 对象 in pairs(工作区:GetDescendants()) do
            if 对象:IsA("ParticleEmitter") or 对象:IsA("Trail") then
                对象:Destroy()
            end
        end
    end)
end)

UI元素.按钮("🌫️ 删除所有烟雾/火", function()
    安全调用(function()
        for _, 对象 in pairs(工作区:GetDescendants()) do
            if 对象:IsA("Smoke") or 对象:IsA("Fire") or 对象:IsA("Sparkles") then
                对象:Destroy()
            end
        end
    end)
end)

UI元素.按钮("💡 点亮全图", function()
    安全调用(function()
        -- 删除所有光源后添加一个全局光
        for _, 对象 in pairs(工作区:GetDescendants()) do
            if 对象:IsA("PointLight") or 对象:IsA("SpotLight") or 对象:IsA("SurfaceLight") then
                对象:Destroy()
            end
        end

        local 全局光 = 创建实例("PointLight", {
            Brightness = 5,
            Range = 1000,
            Color = Color3.fromRGB(255, 255, 255),
            Parent = 获取根部件(),
        })
    end)
end)

UI元素.按钮("🌑 全图变暗", function()
    灯光服务.Ambient = Color3.new(0.05, 0.05, 0.1)
    灯光服务.OutdoorAmbient = Color3.new(0.02, 0.02, 0.05)
    灯光服务.Brightness = 0.1
end)

--// ======================== 键盘快捷键 ============================
UI元素.分区标题("⌨️ 键盘快捷键")

UI元素.信息框("快捷键列表",
    "F1 - 开关飞行\n" ..
    "F2 - 开关穿墙\n" ..
    "F3 - 开关无限跳\n" ..
    "F4 - 开关ESP\n" ..
    "F5 - 开关自瞄\n" ..
    "F6 - 隐藏/显示面板\n" ..
    "右Ctrl - 隐藏/显示面板"
)

-- 快捷键绑定
输入服务.InputBegan:Connect(function(输入, 已处理)
    if 已处理 then return end

    if 输入.KeyCode == Enum.KeyCode.F1 then
        飞行系统.启用 = not 飞行系统.启用
        if 飞行系统.启用 then 飞行系统.创建() else 飞行系统.销毁() end

    elseif 输入.KeyCode == Enum.KeyCode.F2 then
        配置.杂项.穿墙 = not 配置.杂项.穿墙
        if 配置.杂项.穿墙 then
            穿墙连接 = 运行服务.Stepped:Connect(function()
                local 角色 = 获取角色()
                if not 角色 then return end
                for _, 部件 in pairs(角色:GetDescendants()) do
                    if 部件:IsA("BasePart") then 部件.CanCollide = false end
                end
            end)
        else
            if 穿墙连接 then 穿墙连接:Disconnect() end
        end

    elseif 输入.KeyCode == Enum.KeyCode.F3 then
        配置.杂项.无限跳 = not 配置.杂项.无限跳
        if 配置.杂项.无限跳 then
            无限跳连接 = 输入服务.JumpRequest:Connect(function()
                安全调用(function() 获取人类():ChangeState(Enum.HumanoidStateType.Jumping) end)
            end)
        else
            if 无限跳连接 then 无限跳连接:Disconnect() end
        end

    elseif 输入.KeyCode == Enum.KeyCode.F4 then
        ESP数据.启用 = not ESP数据.启用
        配置.ESP.启用 = ESP数据.启用

    elseif 输入.KeyCode == Enum.KeyCode.F5 then
        自瞄数据.启用 = not 自瞄数据.启用
        配置.自瞄.启用 = 自瞄数据.启用

    elseif 输入.KeyCode == Enum.KeyCode.F6 or
           输入.KeyCode == Enum.KeyCode.RightControl then
        主面板.Visible = not 主面板.Visible
    end
end)

--// ======================== 自动重生保护 ============================
UI元素.分区标题("🔄 自动重生保护")

UI元素.开关("🔄 死亡自动重生", false, function(状态)
    配置.杂项.自动重生 = 状态
    if 状态 then
        配置.杂项.重生连接 = 本地玩家.CharacterAdded:Connect(function(角色)
            task.wait(1)
            -- 重生后恢复设置
            local 人类 = 角色:FindFirstChild("Humanoid")
            if 人类 then
                人类.WalkSpeed = 16
                人类.JumpPower = 50
            end
            -- 重新应用穿墙
            if 配置.杂项.穿墙 then
                for _, 部件 in pairs(角色:GetDescendants()) do
                    if 部件:IsA("BasePart") then 部件.CanCollide = false end
                end
            end
        end)
    else
        if 配置.杂项.重生连接 then
            配置.杂项.重生连接:Disconnect()
        end
    end
end)

--// ======================== 调试信息 ============================
UI元素.分区标题("🔧 调试信息")

UI元素.按钮("📊 打印调试信息", function()
    安全调用(function()
        local 根 = 获取根部件()
        local 人类 = 获取人类()
        local 信息 = string.format(
            "[AM 调试]\n" ..
            "角色: %s\n" ..
            "位置: %.1f, %.1f, %.1f\n" ..
            "速度: %.1f\n" ..
            "血量: %.0f/%.0f\n" ..
            "状态: %s\n" ..
            "飞行: %s\n" ..
            "穿墙: %s\n" ..
            "ESP: %s\n" ..
            "自瞄: %s",
            获取角色().Name,
            根.Position.X, 根.Position.Y, 根.Position.Z,
            根.Velocity.Magnitude,
            人类.Health, 人类.MaxHealth,
            tostring(人类:GetState()),
            tostring(飞行系统.启用),
            tostring(配置.杂项.穿墙),
            tostring(ESP数据.启用),
            tostring(自瞄数据.启用)
        )
        print(信息)
    end)
end)

UI元素.按钮("📊 测试所有服务", function()
    安全调用(function()
        print("[AM] 服务测试:")
        print("  Players:", 玩家服务 and "OK" or "FAIL")
        print("  RunService:", 运行服务 and "OK" or "FAIL")
        print("  InputService:", 输入服务 and "OK" or "FAIL")
        print("  Lighting:", 灯光服务 and "OK" or "FAIL")
        print("  Workspace:", 工作区 and "OK" or "FAIL")
        print("  TweenService:", 补间服务 and "OK" or "FAIL")
        print("  Debris:", 垃圾回收 and "OK" or "FAIL")
        print("[AM] 角色测试:")
        print("  Character:", 获取角色() and "OK" or "FAIL")
        print("  Humanoid:", 获取人类() and "OK" or "FAIL")
        print("  RootPart:", 获取根部件() and "OK" or "FAIL")
        print("[AM] UI测试:")
        print("  MainGui:", 主界面 and "OK" or "FAIL")
        print("  主面板:", 主面板 and "OK" or "FAIL")
        print("  悬浮按钮:", 悬浮按钮 and "OK" or "FAIL")
    end)
end)

--// ======================== 性能监控 ============================
UI元素.分区标题("📈 性能监控")

local 性能数据 = {
    帧时间 = {},
    最高帧时间 = 0,
    平均帧时间 = 0,
}

运行服务.RenderStepped:Connect(function(增量)
    table.insert(性能数据.帧时间, 增量)
    if #性能数据.帧时间 > 120 then
        table.remove(性能数据.帧时间, 1)
    end

    local 总和 = 0
    for _, v in ipairs(性能数据.帧时间) do
        总和 = 总和 + v
        性能数据.最高帧时间 = math.max(性能数据.最高帧时间, v)
    end
    性能数据.平均帧时间 = 总和 / #性能数据.帧时间
end)

UI元素.按钮("📈 显示性能报告", function()
    安全调用(function()
        local 平均FPS = 1 / 性能数据.平均帧时间
        local 最低FPS = 1 / 性能数据.最高帧时间
        local 报告 = string.format(
            "[AM 性能报告]\n" ..
            "平均FPS: %.1f\n" ..
            "最低FPS: %.1f\n" ..
            "平均帧时间: %.2fms\n" ..
            "最高帧时间: %.2fms\n" ..
            "内存(MB): %.1f",
            平均FPS, 最低FPS,
            性能数据.平均帧时间 * 1000,
            性能数据.最高帧时间 * 1000,
            collectgarbage("count") / 1024
        )
        print(报告)
    end)
end)

UI元素.按钮("🧹 强制垃圾回收", function()
    安全调用(function()
        local 前 = collectgarbage("count")
        collectgarbage("collect")
        local 后 = collectgarbage("count")
        print(string.format("[AM] 回收: %.1f MB -> %.1f MB (释放 %.1f MB)",
            前 / 1024, 后 / 1024, (前 - 后) / 1024))
    end)
end)
--// ======================== 备用模块A：FE动作 ============================
--[[
    =====================================================================
                        备用模块 A - FE 动作系统
    =====================================================================
    此模块提供客户端动作播放功能，可用于娱乐和演示。
    使用方法：在下方下拉框选择动作名称，自动播放。
    =====================================================================
]]

UI元素.分区标题("🎭 备用模块A: FE动作")

-- 动作列表
local 动作列表 = {
    "闲置", "走路", "跑步", "跳跃", "摔倒",
    "挥手", "鼓掌", "跳舞", "坐下", "躺下",
    "爬行", "游泳", "攀爬", "飞行", "蹲下",
}

-- 当前动作
local 当前动作 = "闲置"

UI元素.下拉框("选择动作", 动作列表, "闲置", function(动作名)
    安全调用(function()
        当前动作 = 动作名
        local 人类 = 获取人类()
        if not 人类 then return end

        -- 使用 AnimationId 播放动画
        local 动画ID表 = {
            闲置 = "rbxassetid://180435571",
            走路 = "rbxassetid://180426354",
            跑步 = "rbxassetid://180426354",
            跳跃 = "rbxassetid://125753702",
            摔倒 = "rbxassetid://129136205",
            挥手 = "rbxassetid://128777203",
            鼓掌 = "rbxassetid://129136205",
            跳舞 = "rbxassetid://129136205",
            坐下 = "rbxassetid://129136205",
            躺下 = "rbxassetid://129136205",
            爬行 = "rbxassetid://180426354",
            游泳 = "rbxassetid://180426354",
            攀爬 = "rbxassetid://180426354",
            飞行 = "rbxassetid://180426354",
            蹲下 = "rbxassetid://180426354",
        }

        local id = 动画ID表[动作名] or 动画ID表.闲置
        local 动画 = 创建实例("Animation", { AnimationId = id })
        local 动画追踪 = 人类:LoadAnimation(动画)
        动画追踪:Play()
    end)
end)

--// ======================== 备用模块B：部件环绕 ============================
--[[
    =====================================================================
                        备用模块 B - 部件环绕系统
    =====================================================================
    在玩家周围生成环绕飞行的部件，可调节数量、速度、半径。
    纯视觉效果，不影响游戏逻辑。
    =====================================================================
]]

UI元素.分区标题("🌀 备用模块B: 部件环绕")

local 环绕数据 = {
    启用 = false,
    数量 = 8,
    速度 = 2,
    半径 = 5,
    部件列表 = {},
}

local 环绕连接 = nil

function 环绕数据.创建()
    -- 清除旧的
    环绕数据.销毁()

    local 根 = 获取根部件()
    if not 根 then return end

    for i = 1, 环绕数据.数量 do
        local 部件 = 创建实例("Part", {
            Size = Vector3.new(1, 1, 1),
            Color = Color3.fromHSV(i / 环绕数据.数量, 1, 1),
            Material = Enum.Material.Neon,
            CanCollide = false,
            Anchored = true,
            Parent = 工作区,
        })
        table.insert(环绕数据.部件列表, 部件)
    end
end

function 环绕数据.销毁()
    for _, 部件 in pairs(环绕数据.部件列表) do
        if 部件 and 部件.Parent then
            部件:Destroy()
        end
    end
    环绕数据.部件列表 = {}
end

function 环绕数据.更新(时间)
    local 根 = 获取根部件()
    if not 根 then return end

    for i, 部件 in pairs(环绕数据.部件列表) do
        local 角度 = 时间 * 环绕数据.速度 + (i / #环绕数据.部件列表) * math.pi * 2
        local x = math.cos(角度) * 环绕数据.半径
        local z = math.sin(角度) * 环绕数据.半径
        local y = math.sin(角度 * 2) * 2
        部件.CFrame = CFrame.new(根.Position + Vector3.new(x, y + 3, z))
    end
end

UI元素.开关("启用环绕", false, function(状态)
    环绕数据.启用 = 状态
    if 状态 then
        环绕数据.创建()
        环绕连接 = 运行服务.Heartbeat:Connect(function(增量)
            环绕数据.更新(tick())
        end)
    else
        if 环绕连接 then 环绕连接:Disconnect() 环绕连接 = nil end
        环绕数据.销毁()
    end
end)

UI元素.滑块("环绕数量", 3, 24, 8, function(值)
    环绕数据.数量 = 值
    if 环绕数据.启用 then
        环绕数据.创建()
    end
end)

UI元素.滑块("环绕速度", 1, 10, 2, function(值)
    环绕数据.速度 = 值
end)

UI元素.滑块("环绕半径", 2, 15, 5, function(值)
    环绕数据.半径 = 值
end)

--// ======================== 备用模块C：点击传送增强 ============================
--[[
    =====================================================================
                        备用模块 C - 传送增强
    =====================================================================
    提供多种传送方式：坐标传送、玩家传送、随机传送等。
    =====================================================================
]]

UI元素.分区标题("📡 备用模块C: 传送增强")

UI元素.输入框("X坐标", "输入X...", "0", function(值)
    配置.杂项.传送X = tonumber(值) or 0
end)

UI元素.输入框("Y坐标", "输入Y...", "50", function(值)
    配置.杂项.传送Y = tonumber(值) or 50
end)

UI元素.输入框("Z坐标", "输入Z...", "0", function(值)
    配置.杂项.传送Z = tonumber(值) or 0
end)

UI元素.按钮("📡 传送到坐标", function()
    安全调用(function()
        local x = 配置.杂项.传送X or 0
        local y = 配置.杂项.传送Y or 50
        local z = 配置.杂项.传送Z or 0
        获取根部件().CFrame = CFrame.new(x, y, z)
    end)
end)

UI元素.按钮("📡 传送到世界中心", function()
    安全调用(function()
        获取根部件().CFrame = CFrame.new(0, 50, 0)
    end)
end)

UI元素.按钮("📡 传送到原点", function()
    安全调用(function()
        获取根部件().CFrame = CFrame.new(0, 0, 0)
    end)
end)

--// ======================== 备用模块D：信息收集 ============================
--[[
    =====================================================================
                        备用模块 D - 信息收集
    =====================================================================
    显示当前游戏/服务器的详细信息，包括玩家列表、Ping等。
    =====================================================================
]]

UI元素.分区标题("📊 备用模块D: 信息收集")

UI元素.按钮("📊 显示服务器信息", function()
    安全调用(function()
        local 玩家列表 = ""
        local 数量 = 0
        for _, p in pairs(玩家服务:GetPlayers()) do
            数量 = 数量 + 1
            玩家列表 = 玩家列表 .. string.format("%d. %s (%s)\n",
                数量, p.Name, p.DisplayName)
        end

        local 信息 = string.format(
            "=== 服务器信息 ===\n" ..
            "玩家数量: %d/%d\n" ..
            "服务器名称: %s\n" ..
            "工作区名称: %s\n" ..
            "摄像机类型: %s\n" ..
            "重力: %.0f\n" ..
            "\n=== 玩家列表 ===\n%s",
            数量, 玩家服务.MaxPlayers,
            游戏.JobId or "Unknown",
            工作区.Name,
            tostring(摄像机.CameraType),
            工作区.Gravity,
            玩家列表
        )
        print(信息)
    end)
end)

UI元素.按钮("📊 显示自身信息", function()
    安全调用(function()
        local 根 = 获取根部件()
        local 人类 = 获取人类()
        local 信息 = string.format(
            "=== 自身信息 ===\n" ..
            "用户名: %s\n" ..
            "显示名: %s\n" ..
            "用户ID: %d\n" ..
            "账号年龄: %d天\n" ..
            "角色: %s\n" ..
            "位置: %.1f, %.1f, %.1f\n" ..
            "速度: %.1f\n" ..
            "血量: %.0f/%.0f\n" ..
            "状态: %s\n" ..
            "行走速度: %.0f\n" ..
            "跳跃力量: %.0f",
            本地玩家.Name,
            本地玩家.DisplayName,
            本地玩家.UserId,
            本地玩家.AccountAge,
            获取角色().Name,
            根.Position.X, 根.Position.Y, 根.Position.Z,
            根.Velocity.Magnitude,
            人类.Health, 人类.MaxHealth,
            tostring(人类:GetState()),
            人类.WalkSpeed,
            人类.JumpPower
        )
        print(信息)
    end)
end)

--// ======================== 备用模块E：安全备份 ============================
--[[
    =====================================================================
                        备用模块 E - 安全备份
    =====================================================================
    定期自动保存角色位置，死亡后可以回到安全点。
    =====================================================================
]]

UI元素.分区标题("💾 备用模块E: 安全备份")

local 备份数据 = {
    启用 = false,
    安全点 = nil,
    间隔 = 10,
}

UI元素.开关("自动备份位置", false, function(状态)
    备份数据.启用 = 状态
    if 状态 then
        spawn(function()
            while 备份数据.启用 do
                local 根 = 获取根部件()
                if 根 then
                    备份数据.安全点 = 根.CFrame
                end
                wait(备份数据.间隔)
            end
        end)
    end
end)

UI元素.滑块("备份间隔(秒)", 3, 60, 10, function(值)
    备份数据.间隔 = 值
end)

UI元素.按钮("💾 手动保存位置", function()
    安全调用(function()
        local 根 = 获取根部件()
        备份数据.安全点 = 根.CFrame
        print("[AM] 位置已保存")
    end)
end)

UI元素.按钮("📍 回到安全点", function()
    安全调用(function()
        if 备份数据.安全点 then
            获取根部件().CFrame = 备份数据.安全点
            print("[AM] 已传送到安全点")
        end
    end)
end)

--// ======================== 备用模块F：UI主题 ============================
--[[
    =====================================================================
                        备用模块 F - UI 主题切换
    =====================================================================
    允许切换不同的UI配色方案，满足个性化需求。
    =====================================================================
]]

UI元素.分区标题("🎨 备用模块F: UI主题")

UI元素.下拉框("选择主题", {"暗夜绿", "深蓝", "暗红", "紫色", "橙色"}, "暗夜绿", function(主题名)
    安全调用(function()
        local 主题表 = {
            暗夜绿 = { 背景 = Color3.fromRGB(8,8,12), 面板 = Color3.fromRGB(16,16,22), 强调 = Color3.fromRGB(100,255,170) },
            深蓝 = { 背景 = Color3.fromRGB(5,8,15), 面板 = Color3.fromRGB(10,15,25), 强调 = Color3.fromRGB(60,130,255) },
            暗红 = { 背景 = Color3.fromRGB(15,5,5), 面板 = Color3.fromRGB(25,10,10), 强调 = Color3.fromRGB(255,80,80) },
            紫色 = { 背景 = Color3.fromRGB(10,5,15), 面板 = Color3.fromRGB(18,10,25), 强调 = Color3.fromRGB(180,80,255) },
            橙色 = { 背景 = Color3.fromRGB(15,10,5), 面板 = Color3.fromRGB(25,18,10), 强调 = Color3.fromRGB(255,160,40) },
        }
        local t = 主题表[主题名] or 主题表.暗夜绿
        主题.背景 = t.背景
        主题.面板 = t.面板
        主题.强调色 = t.强调
        主面板.BackgroundColor3 = t.背景
        悬浮按钮.BackgroundColor3 = t.强调
    end)
end)

--// ======================== 初始化完成 ============================
--[[
    =====================================================================
                           初始化完成通知
    =====================================================================
    所有模块加载完毕，显示欢迎信息。
    =====================================================================
]]

安全调用(function()
    local 欢迎 = 创建实例("TextLabel", {
        Size = UDim2.new(0, 260, 0, 36),
        Position = UDim2.new(0.5, -130, 0, 20),
        BackgroundColor3 = 主题.绿色,
        Text = "✓ AM 通用脚本 加载完成 v3.0",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = 主界面,
    })
    添加圆角(欢迎, 8)
    垃圾回收:AddItem(欢迎, 3)
end)

-- 控制台输出
print("======================================================================")
print("  AM 通用脚本 v3.0 - 加载完成")
print("  作者: AM | QQ群: 179051448")
print("  功能模块: 飞行/ESP/自瞄/穿墙/黑洞/传送/美化/更多")
print("  悬浮窗位置: 左侧 | 可拖动")
print("  快捷键: F1飞行 F2穿墙 F3无限跳 F4ESP F5自瞄 F6面板")
print("======================================================================")

--// ======================== 最终保护 ============================
-- 确保脚本不会因错误而完全停止
spawn(function()
    while wait(5) do
        安全调用(function()
            -- 检查关键对象是否还在
            if not 主界面 or not 主界面.Parent then
                warn("[AM] 主界面丢失，尝试重建...")
                -- 这里可以添加重建逻辑
            end
            if not 悬浮按钮 or not 悬浮按钮.Parent then
                warn("[AM] 悬浮按钮丢失")
            end
        end)
    end
end)

-- 最终返回
return "AM_通用脚本_v3.0_加载成功"

--[[
================================================================================
                             END OF FILE
================================================================================
    AM 通用脚本 v3.0 - 纯中文版
    总行数: 3000+
    作者: AM
    QQ群: 179051448
    声明: 仅供学习交流使用

    模块清单:
    [1] 飞行系统 (BodyVelocity + CFrame双引擎)
    [2] 虚拟摇杆 (纯触屏控制)
    [3] 移动属性 (速度/跳力/重力)
    [4] 角色状态 (穿墙/无限跳/防坠落)
    [5] 视觉增强 (夜视/去雾/广角/阴影)
    [6] ESP透视 (Highlight/名称/距离/血量/方框)
    [7] 自瞄系统 (FOV圈/平滑锁头)
    [8] 战斗功能 (传送/甩飞/黑洞/磁铁)
    [9] 整活娱乐 (旋转/弹跳/变大/透明)
    [10] 设置面板 (关闭全部/重生/销毁)
    [11] 高级移动 (爬墙/BHop/滑步/疾跑)
    [12] 高级视觉 (模糊/黑白/暗角/高饱和)
    [13] 高级ESP (骨骼/方框/队伍/颜色)
    [14] 服务器工具 (传送/坐标/刷屏)
    [15] 网络优化 (FPS提升/画质恢复)
    [16] 角色美化 (发光/彩虹/隐身/恢复)
    [17] 声音工具 (静音/音量/恢复)
    [18] 地图工具 (粒子/烟雾/光源)
    [19] 键盘快捷键 (F1-F6/右Ctrl)
    [20] 自动重生保护
    [21] 调试信息
    [22] 性能监控
    [23] FE动作系统
    [24] 部件环绕
    [25] 传送增强
    [26] 信息收集
    [27] 安全备份
    [28] UI主题切换

    感谢使用 AM 通用脚本！
    有问题请联系QQ群: 179051448
================================================================================
]]

-- EOF
print("[AM] 脚本执行完毕，所有模块已就绪")
print("[AM] 按F6或点击左侧AM按钮打开面板")
print("[AM] 祝你游戏愉快！")
