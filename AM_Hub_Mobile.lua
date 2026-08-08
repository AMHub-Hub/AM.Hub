--=====================================================
--  AM · 硬核扫描拦截器 v2.0
--  拦截：GetPlayers / HttpGet( badges&games API ) / Player属性
--  ⚠ 仅限 Alt 小号测试 ⚠
--  群号: QQ17395735636   ← 改成你的
--=====================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ==================== UI ====================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "AM_HardBlock"
gui.ResetOnSpawn = false

local f = Instance.new("Frame", gui)
f.Size = UDim2.new(0,260,0,230)
f.Position = UDim2.new(0.5,-130,0.5,-115)
f.BackgroundColor3 = Color3.fromRGB(10,10,15)
f.BorderColor3 = Color3.fromRGB(255,40,40)
f.BorderSizePixel = 2
f.Active = true; f.Draggable = true

local t = Instance.new("TextLabel",f)
t.Size=UDim2.new(1,0,0,30); t.BackgroundColor3=Color3.fromRGB(180,20,20)
t.Text="AM·硬核扫描拦截器 v2"; t.TextColor3=Color3.new(1,1,1)
t.TextScaled=true; t.Font=Enum.Font.SourceSansBold

local grp = Instance.new("TextLabel",f)
grp.Size=UDim2.new(1,0,0,20); grp.Position=UDim2.new(0,0,0,30)
grp.BackgroundTransparency=1; grp.Text="群号: 123456789"
grp.TextColor3=Color3.fromRGB(255,200,200); grp.TextScaled=true

local st = Instance.new("TextLabel",f)
st.Size=UDim2.new(1,0,0,22); st.Position=UDim2.new(0,0,0,55)
st.BackgroundTransparency=1; st.Text="● 未启动"
st.TextColor3=Color3.fromRGB(255,100,100); st.TextScaled=true

local btn = Instance.new("TextButton",f)
btn.Size=UDim2.new(0.8,0,0,45); btn.Position=UDim2.new(0.1,0,0,90)
btn.BackgroundColor3=Color3.fromRGB(200,40,40)
btn.Text="▶ 启动硬核拦截"; btn.TextColor3=Color3.new(1,1,1)
btn.TextScaled=true; btn.Font=Enum.Font.SourceSansBold

local lg = Instance.new("TextLabel",f)
lg.Size=UDim2.new(1,-10,0,22); lg.Position=UDim2.new(0,5,0,145)
lg.BackgroundTransparency=1; lg.Text="拦截: 0 | API: 0 | 属性: 0"
lg.TextColor3=Color3.fromRGB(180,180,180); lg.TextScaled=true; lg.TextWrapped=true

local note = Instance.new("TextLabel",f)
note.Size=UDim2.new(1,-10,0,40); note.Position=UDim2.new(0,5,0,170)
note.BackgroundTransparency=1
note.Text="仅保护本机客户端\n诬陷党换机器/换号仍会扫描他人"
note.TextColor3=Color3.fromRGB(120,120,120); note.TextScaled=true

-- ==================== 拦截核心 ====================
local Running = false
local C = {total=0, api=0, attr=0}

-- 假数据池
local FAKES = {"Noob_001","Guest_xx","TestAcc_7","Player_42","Unknown_X"}
local fi = 0
local function fakeN() fi=(fi%#FAKES)+1; return FAKES[fi] end

-- 备份
local oldHttpGet = game.HttpGet
local oldHttpPost = game.HttpPost
local oldGetPlrs = Players.GetPlayers

-- Hook 1: HttpGet —— 拦 Roblox 数据 API + 外部上报
local function hkHttpGet(self, url, ...)
    local u = tostring(url or ""):lower()
    -- 拦勋章 / 游戏历史 / 用户资料 这三类
    if u:find("badges.roblox.com")
    or u:find("games.roblox.com")
    or u:find("users.roblox.com")
    or u:find("inventory.roblox.com") then
        C.api += 1; C.total += 1
        lg.Text = string.format("拦截: %d | API: %d | 属性: %d",C.total,C.api,C.attr)
        -- 返回空 data，让扫描脚本拿到"这人啥也没有"
        return '{"data":[]}'
    end
    -- 拦向他们自己后台的上报（非 roblox/github 的 POST/GET）
    if u:find("http") and not u:find("roblox.com") and not u:find("github.com") and not u:find("raw.githubusercontent") then
        C.api += 1; C.total += 1
        lg.Text = string.format("拦截: %d | API: %d | 属性: %d",C.total,C.api,C.attr)
        return ""
    end
    return oldHttpGet(self, url, ...)
end

-- Hook 2: HttpPost 一律拦（他们上报用）
local function hkHttpPost(self, url, data, ...)
    local u = tostring(url or ""):lower()
    if not u:find("roblox.com") then
        C.api += 1; C.total += 1
        lg.Text = string.format("拦截: %d | API: %d | 属性: %d",C.total,C.api,C.attr)
        return ""
    end
    return oldHttpPost(self, url, data, ...)
end

-- Hook 3: GetPlayers 返回空
local function hkGetPlayers(self)
    if Running then
        C.attr += 1; C.total += 1
        lg.Text = string.format("拦截: %d | API: %d | 属性: %d",C.total,C.api,C.attr)
        return {}
    end
    return oldGetPlrs(self)
end

-- Hook 4: Player 属性返回假值
local oldIdx
oldIdx = hookmetamethod(game, "__index", function(self, key)
    if Running and typeof(self)=="Instance" and self:IsA("Player") then
        if key=="Name" or key=="DisplayName" then
            C.attr += 1; C.total += 1
            lg.Text = string.format("拦截: %d | API: %d | 属性: %d",C.total,C.api,C.attr)
            return fakeN()
        end
        if key=="UserId" then return math.random(100000,999999) end
    end
    return oldIdx(self, key)
end)

-- 安装 / 卸载
local function install()
    hookfunction(game.HttpGet, hkHttpGet)
    hookfunction(game.HttpPost, hkHttpPost)
    hookfunction(Players.GetPlayers, hkGetPlayers)
end
local function uninstall()
    hookfunction(game.HttpGet, oldHttpGet)
    hookfunction(game.HttpPost, oldHttpPost)
    hookfunction(Players.GetPlayers, oldGetPlrs)
end

-- ==================== 按钮 ====================
btn.MouseButton1Click:Connect(function()
    Running = not Running
    if Running then
        install()
        st.Text="● 硬核拦截中"; st.TextColor3=Color3.fromRGB(100,255,120)
        btn.Text="■ 停止拦截"; btn.BackgroundColor3=Color3.fromRGB(50,150,50)
        print("[AM] 硬核拦截已启动")
    else
        uninstall()
        st.Text="● 未启动"; st.TextColor3=Color3.fromRGB(255,100,100)
        btn.Text="▶ 启动硬核拦截"; btn.BackgroundColor3=Color3.fromRGB(200,40,40)
        print("[AM] 已停止")
    end
end)

print("[AM·硬核扫描拦截器 v2] 加载完成")
