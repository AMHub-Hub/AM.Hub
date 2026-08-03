-- AM Hub | XK Style | FINAL
if _G.AM then return end _G.AM=true
local p=game.Players.LocalPlayer
local rs=game:GetService"RunService"
local uis=game:GetService"UserInputService"
local ws=workspace
local cam=ws.CurrentCamera
local lp=p.Character or p.CharacterAdded:Wait()
local hum=lp:WaitForChild"Humanoid"
local root=lp:WaitForChild"HumanoidRootPart"

local s={f=false,n=false,i=false,e=false,a=false,sp=16,jp=50,g=196,fs=60,r=200}
local c={}

local function clear()
    for _,v in pairs(c)do if v.Disconnect then v:Disconnect()end end
    c={}
    if s.bv then s.bv:Destroy()end
    if s.bg then s.bg:Destroy()end
    hum.WalkSpeed=16
    hum.JumpPower=50
    ws.Gravity=196
    cam.CameraType=Enum.CameraType.Custom
end

p.CharacterAdded:Connect(function(ch)
    clear()
    lp=ch
    hum=ch:WaitForChild"Humanoid"
    root=ch:WaitForChild"HumanoidRootPart"
end)

-- GUI
local g=Instance.new("ScreenGui",game.CoreGui)g.Name="AM"
local win=Instance.new("Frame",g)
win.Size=UDim2.new(0,220,0,300)
win.Position=UDim2.new(0.5,-110,0.5,-150)
win.BackgroundColor3=Color3.fromRGB(14,14,16)
win.BackgroundTransparency=0.1
win.Active=true win.Draggable=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12)

local t=Instance.new("TextLabel",win)t.Size=UDim2.new(1,-40,0,24)t.Position=UDim2.new(0,10,0,6)
t.Text="AM" t.TextColor3=Color3.new(1,1,1)t.Font=Enum.Font.GothamBold t.TextSize=13

local x=Instance.new("TextButton",win)x.Size=UDim2.new(0,24,0,24)x.Position=UDim2.new(1,-30,0,6)
x.Text="✕"x.TextColor3=Color3.fromRGB(255,80,80)x.BackgroundTransparency=1
x.MouseButton1Click:Connect(function()clear()g:Destroy()_G.AM=nil end)

local f=Instance.new("Frame",win)f.Position=UDim2.new(0,8,0,36)f.Size=UDim2.new(1,-16,1,-44)
f.BackgroundTransparency=1
local l=Instance.new("UIListLayout",f)l.Padding=UDim.new(0,5)

local function btn(name)
    local b=Instance.new("TextButton",f)
    b.Size=UDim2.new(1,0,0,26)
    b.Text=name.." [OFF]"
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.Gotham
    b.TextSize=12
    b.BackgroundColor3=Color3.fromRGB(30,30,34)
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end

-- Fly
local fly=btn("飞行")
fly.MouseButton1Click:Connect(function()
    s.f=not s.f
    fly.Text="飞行 ["..(s.f and"ON"or"OFF").."]"
    if s.f then
        s.bv=Instance.new("BodyVelocity",root)s.bv.MaxForce=Vector3.new(1e6,1e6,1e6)
        s.bg=Instance.new("BodyGyro",root)s.bg.MaxTorque=Vector3.new(1e6,1e6,1e6)
        hum.PlatformStand=true
        c.f=rs.Heartbeat:Connect(function()
            local d=Vector3.zero
            if uis:IsKeyDown(Enum.KeyCode.W)then d+=cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S)then d-=cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A)then d-=cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D)then d+=cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space)then d+=Vector3.new(0,1,0)end
            s.bg.CFrame=CFrame.new(root.Position,root.Position+cam.CFrame.LookVector)
            s.bv.Velocity=(d.Magnitude>0 and d.Unit or Vector3.zero)*s.fs
        end)
    else
        if c.f then c.f:Disconnect()end
        s.bv:Destroy()s.bg:Destroy()
        hum.PlatformStand=false
    end
end)

-- Speed
local sp=btn("速度")
sp.MouseButton1Click:Connect(function()
    s.sp=s.sp==16 and 100 or 16
    sp.Text="速度 ["..s.sp.."]"
    hum.WalkSpeed=s.sp
end)

-- Jump
local jp=btn("跳力")
jp.MouseButton1Click:Connect(function()
    s.jp=s.jp==50 and 150 or 50
    jp.Text="跳力 ["..s.jp.."]"
    hum.JumpPower=s.jp
end)

-- Noclip
local nc=btn("穿墙")
nc.MouseButton1Click:Connect(function()
    s.n=not s.n
    nc.Text="穿墙 ["..(s.n and"ON"or"OFF").."]"
    if s.n then
        c.n=rs.Stepped:Connect(function()
            for _,x in pairs(lp:GetDescendants())do if x:IsA"BasePart"then x.CanCollide=false end end
        end)
    else
        if c.n then c.n:Disconnect()end
    end
end)

-- Inf Jump
local ij=btn("无限跳")
ij.MouseButton1Click:Connect(function()
    s.i=not s.i
    ij.Text="无限跳 ["..(s.i and"ON"or"OFF").."]"
    if s.i then
        c.i=uis.JumpRequest:Connect(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    else
        if c.i then c.i:Disconnect()end
    end
end)

-- ESP
local es=btn("ESP")
es.MouseButton1Click:Connect(function()
    s.e=not s.e
    es.Text="ESP ["..(s.e and"ON"or"OFF").."]"
    if s.e then
        local fo=Instance.new("Folder",game.StarterGui)fo.Name="AM_ESP"
        c.e=rs.RenderStepped:Connect(function()
            for _,pl in pairs(game.Players:GetPlayers())do
                if pl~=p and pl.Character and pl.Character:FindFirstChild"Head"then
                    local n="T_"..pl.Name
                    if not fo:FindFirstChild(n)then
                        local bb=Instance.new("BillboardGui",fo)
                        bb.Name=n bb.Adornee=pl.Character.Head bb.Size=UDim2.new(0,80,0,18)bb.AlwaysOnTop=true
                        local tx=Instance.new("TextLabel",bb)
                        tx.Size=UDim2.new(1,0,1,0)tx.BackgroundTransparency=1 tx.Text=pl.Name
                        tx.TextColor3=Color3.fromHSV(tick()%5/5,1,1)tx.TextScaled=true
                    end
                end
            end
        end)
    else
        if c.e then c.e:Disconnect()end
        local fo=game.StarterGui:FindFirstChild("AM_ESP")
        if fo then fo:Destroy()end
    end
end)

-- Aimbot
local ai=btn("自瞄")
ai.MouseButton1Click:Connect(function()
    s.a=not s.a
    ai.Text="自瞄 ["..(s.a and"ON"or"OFF").."]"
    if s.a then
        cam.CameraType=Enum.CameraType.Scriptable
        c.a=rs.RenderStepped:Connect(function()
            local t=nil local md=math.huge
            for _,pl in pairs(game.Players:GetPlayers())do
                if pl~=p and pl.Character and pl.Character:FindFirstChild"Head"then
                    local d=(pl.Character.Head.Position-root.Position).Magnitude
                    if d<s.r and d<md then md=d t=pl.Character.Head end
                end
            end
            if t then cam.CFrame=CFrame.new(cam.CFrame.Position,t.Position)end
        end)
    else
        if c.a then c.a:Disconnect()end
        cam.CameraType=Enum.CameraType.Custom
    end
end)

-- Destroy all
local off=btn("关闭全部")
off.MouseButton1Click:Connect(function()
    clear()
    fly.Text="飞行 [OFF]" sp.Text="速度 [16]" jp.Text="跳力 [50]"
    nc.Text="穿墙 [OFF]" ij.Text="无限跳 [OFF]" es.Text="ESP [OFF]" ai.Text="自瞄 [OFF]"
end)

print"[AM] loaded"
