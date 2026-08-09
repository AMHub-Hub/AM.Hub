--//==========================================================\\
--||  圣地亚哥边境角色扮演 · 汉化刷钱脚本 v1.0
--||  功能：自动刷环(Onfoot/Incar) | 自动洗钱 | 飞行 | 穿墙
--||  适用：PC + 手机端（Delta/Arceus X/Wave/Volt 等）
--||  警告：仅限小号测试，主号风险自负
--\\==========================================================//

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")

-- ==================== 加载外部UI库 ====================
local libUrl = "https://raw.githubusercontent.com/Footagesus/WindUI/main/Lib.lua"
local ok, WindUI = pcall(function() return loadstring(game:HttpGet(libUrl))() end)
if not ok then
    warn("[汉化刷钱] UI库加载失败，请检查网络或链接")
    return
end

-- ==================== 创建窗口 ====================
local Window = WindUI:CreateWindow({
    Title = "圣地亚哥边境 · 刷钱助手",
    Icon = "dollar-sign",
    Author = "汉化版 by AM",
    Folder = "SanDiegoCN",
    Size = UDim2.fromOffset(520, 380),
    Transparent = true,
})

-- ==================== 标签页 ====================
local TabFarm = Window:Tab({Title = "自动刷钱", Icon = "trending-up"})
local TabMove  = Window:Tab({Title = "移动辅助", Icon = "zap"})
local TabInfo  = Window:Tab({Title = "说明",     Icon = "info"})

-- ==================== 状态变量 ====================
local farming = false
local farmType = "onfoot" -- onfoot / incar
local flySpeed = 170
local cyclesBeforeWash = 5
local noclipOn = false

-- ==================== 核心：自动刷环 ====================
-- 原理：沿地图预设的"环"路线循环移动，每圈获得工资，到数后去洗钱点
local ringWaypoints = nil
local washLocation = nil

local function getRingWaypoints()
    -- 尝试从游戏中获取刷环路径点
    local wp = {}
    local success = pcall(function()
        local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("地图")
        if map then
            local rings = map:FindFirstChild("Rings") or map:FindFirstChild("环")
            if rings then
                for _, v in ipairs(rings:GetChildren()) do
                    if v:IsA("BasePart") then
                        table.insert(wp, v.Position)
                    end
                end
            end
        end
    end)
    if success and #wp > 0 then return wp end
    -- 备用：手动预设几个常见坐标（不同版本可能不同）
    return {
        Vector3.new(0, 3, 0),
        Vector3.new(50, 3, 0),
        Vector3.new(50, 3, 50),
        Vector3.new(0, 3, 50),
        Vector3.new(-50, 3, 50),
        Vector3.new(-50, 3, 0),
        Vector3.new(-50, 3, -50),
        Vector3.new(0, 3, -50),
        Vector3.new(50, 3, -50),
    }
end

local function getWashLocation()
    local loc
    pcall(function()
        local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("地图")
        if map then
            local wash = map:FindFirstChild("MoneyWash") or map:FindFirstChild("洗钱点")
            if wash and wash:IsA("BasePart") then loc = wash.Position end
        end
    end)
    return loc or Vector3.new(100, 3, 100) -- 备用坐标
end

local function teleportTo(pos)
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
end

local function startFarm()
    if farming then return end
    farming = true
    ringWaypoints = getRingWaypoints()
    washLocation = getWashLocation()
    local cycle = 0

    spawn(function()
        while farming do
            -- 走路刷环
            for _, wp in ipairs(ringWaypoints) do
                if not farming then break end
                teleportTo(wp)
                task.wait(0.3)
            end
            cycle += 1
            -- 到达设定圈数后去洗钱
            if cycle >= cyclesBeforeWash then
                teleportTo(washLocation)
                task.wait(2) -- 等待洗钱完成
                cycle = 0
            end
            task.wait(0.1)
        end
    end)

    -- 通知
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "✅ 刷钱已启动";
            Text = "类型: " .. (farmType == "onfoot" and "步行刷环" or "驾车刷环") ..
                   "\n速度: " .. flySpeed ..
                   "\n每 " .. cyclesBeforeWash .. " 圈洗钱一次";
            Duration = 5;
        })
    end)
end

local function stopFarm()
    farming = false
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "⏹️ 刷钱已停止";
            Text = "欢迎再次使用";
            Duration = 3;
        })
    end)
end

-- ==================== 飞行系统 ====================
local flyActive = false
local flyConn = nil

local function startFly()
    flyActive = true
    local player = game.Players.LocalPlayer
    local bodyVel = nil
    local bodyGyro = nil

    flyConn = game:GetService("RunService").Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        end

        local cam = workspace.CurrentCamera
        local move = Vector3.new(0,0,0)
        local uis = game:GetService("UserInputService")
        if uis:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            bodyVel.Velocity = move.Unit * flySpeed
        else
            bodyVel.Velocity = Vector3.new(0,0,0)
        end
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flyActive = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, v in ipairs(char.HumanoidRootPart:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
end

-- ==================== 穿墙 ====================
local function setNoclip(on)
    noclipOn = on
    local player = game.Players.LocalPlayer
    if on then
        spawn(function()
            while noclipOn do
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

-- ==================== 【自动刷钱】UI ====================

TabFarm:Paragraph({
    Title = "💰 自动刷钱说明";
    Desc = "自动沿地图环路线循环移动获取工资\n到达设定圈数后自动前往洗钱点\n建议飞行速度 ≤170，过高会掉线";
    Color = Color3.fromHex("#FFD700");
    BackgroundColor3 = Color3.fromHex("#1A1500");
    BackgroundTransparency = 0.3;
    OutlineColor = Color3.fromHex("#FFD700");
    OutlineThickness = 1;
    Padding = UDim.new(0, 1);
})

-- 刷钱类型选择
TabFarm:Dropdown({
    Title = "刷钱模式";
    Values = {"步行刷环(Onfoot)", "驾车刷环(Incar)"};
    Value = "步行刷环(Onfoot)";
    Callback = function(val)
        farmType = val:find("Onfoot") and "onfoot" or "incar"
    end;
})

-- 飞行速度
TabFarm:Slider({
    Title = "飞行/移动速度";
    Step = 10;
    Value = {Min = 50, Max = 300, Default = 170};
    Callback = function(val)
        flySpeed = val
    end;
})

-- 洗钱圈数
TabFarm:Slider({
    Title = "每几圈去洗钱";
    Step = 1;
    Value = {Min = 1, Max = 20, Default = 5};
    Callback = function(val)
        cyclesBeforeWash = val
    end;
})

-- 开始/停止刷钱
TabFarm:Toggle({
    Title = "▶ 启动自动刷钱";
    Value = false;
    Callback = function(val)
        if val then startFarm() else stopFarm() end
    end;
})

-- ==================== 【移动辅助】UI ====================

TabMove:Paragraph({
    Title = "🚀 移动辅助";
    Desc = "飞行：WASD移动 + 空格上升 + Shift下降\n穿墙：穿透所有固体障碍物";
    Color = Color3.fromHex("#00CCFF");
    BackgroundColor3 = Color3.fromHex("#001A22");
    BackgroundTransparency = 0.3;
    OutlineColor = Color3.fromHex("#00CCFF");
    OutlineThickness = 1;
    Padding = UDim.new(0, 1);
})

TabMove:Toggle({
    Title = "✈️ 飞行模式";
    Value = false;
    Callback = function(val)
        if val then startFly() else stopFly() end
    end;
})

TabMove:Slider({
    Title = "飞行速度(独立调节)";
    Step = 10;
    Value = {Min = 50, Max = 300, Default = 170};
    Callback = function(val)
        flySpeed = val
    end;
})

TabMove:Toggle({
    Title = "👻 穿墙模式";
    Value = false;
    Callback = function(val)
        setNoclip(val)
    end;
})

-- 一键回出生点
TabMove:Button({
    Title = "🏠 回出生点";
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
        end
    end;
})

-- ==================== 【说明】UI ====================

TabInfo:Paragraph({
    Title = "📖 刷钱原理";
    Desc = [[
1. 脚本自动沿地图"环(Ring)"路线循环移动
2. 每经过一个环获得一次工资
3. 到达设定圈数后自动传送到洗钱点
4. 洗钱完成后继续刷环
5. 循环往复，挂机即可赚钱
]];
    Color = Color3.fromHex("#00FF88");
    BackgroundColor3 = Color3.fromHex("#001A0A");
    BackgroundTransparency = 0.3;
    OutlineColor = Color3.fromHex("#00FF88");
    OutlineThickness = 1;
    Padding = UDim.new(0, 1);
})

TabInfo:Paragraph({
    Title = "⚠️ 注意事项";
    Desc = [[
• 飞行速度建议 ≤170，过高会物理不同步导致掉线
• 必须在角色完全加载后再启动
• 使用小号，主号有封号风险
• 进服后先等3-5秒再运行脚本
• 如脚本失效，可能是游戏更新，需等作者修复
]];
    Color = Color3.fromHex("#FF4444");
    BackgroundColor3 = Color3.fromHex("#1A0000");
    BackgroundTransparency = 0.3;
    OutlineColor = Color3.fromHex("#FF4444");
    OutlineThickness = 1;
    Padding = UDim.new(0, 1);
})

TabInfo:Paragraph({
    Title = "🔑 手动刷钱技巧（不用脚本）";
    Desc = [[
警察路线：加入警队 → 开车到公寓 → 找有声的打印机
→ 查数据库开搜查令 → 破门 → 没收打印机（每台1万）
平民路线：买海滩别墅 → 地下室放满生产设备
→ 再租公寓放满印钞机 → 挂机每小时10-40万
]];
    Color = Color3.fromHex("#FFAA00");
    BackgroundColor3 = Color3.fromHex("#1A1000");
    BackgroundTransparency = 0.3;
    OutlineColor = Color3.fromHex("#FFAA00");
    OutlineThickness = 1;
    Padding = UDim.new(0, 1);
})

TabInfo:Paragraph({
    Title = "📱 适用执行器";
    Desc = "手机端：Delta / Arceus X / Hydrogen / Codex\n电脑端：Wave / Volt / Synapse Z / Potassium";
    Color = Color3.fromHex("#AAAAAA");
    BackgroundTransparency = 0.5;
})

-- ==================== 初始化完成 ====================
print([[
┌─────────────────────────────────┐
│  圣地亚哥边境 · 汉化刷钱脚本 v1.0  │
│  已加载完成                       │
│  请切换到"自动刷钱"标签页启动       │
└─────────────────────────────────┘
]])

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🟢 脚本加载成功";
        Text = "圣地亚哥边境汉化刷钱版\n请到「自动刷钱」标签页启动";
        Duration = 5;
    })
end)
