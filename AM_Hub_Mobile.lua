if _G.AM_L then return end _G.AM_L=true
local G=game,Pl=G.Players,LP=Pl.LocalPlayer
local WS=G:GetService("Workspace"),UIS=G:GetService("UserInputService"),RS=G:GetService("RunService")
local WUI
pcall(function()WUI=loadstring(G:HttpGet("https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/main.lua"))()end)
if not WUI then WUI=loadstring(G:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()end
local Win=WUI:CreateWindow({Title="AM脚本",Icon="crown",Folder="AM",Size=UDim2.fromOffset(480,320),Transparent=true,User={Enabled=true,Callback=function()end}})
Win:EditOpenButton({Title="AM",Icon="crown",CornerRadius=UDim.new(1,0),StrokeThickness=3,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,255))}),Draggable=true})
spawn(function()while _G.AM_L do pcall(function()Win:SetBorderColor(Color3.fromHSV(tick()%5/5,1,1))end)wait(.1)end)
local function Ch()return LP.Character or LP.CharacterAdded:Wait()end
local function Hm()return Ch():WaitForChild("Humanoid")end
local O={};local OC=false
local function CO()if OC then return end pcall(function()local h=Hm()O.W=h.WalkSpeed O.J=h.JumpPower O.G=WS.Gravity OC=true end)end
local T1=Win:Tab({Title="通用",Icon="eye"})
T1:Paragraph({Title="用户:"..LP.Name.." | ID:"..LP.UserId.." | 年龄:"..LP.AccountAge.."天",Desc="QQ群:179051448",Color=Color3.fromHex("#00FF00")})
local S={}
T1:Toggle({Title="移速改",Value=false,Callback=function(v)CO()S.sp=v pcall(function()Hm().WalkSpeed=v and S.sv or O.W end)end})
T1:Slider({Title="移速",Min=1,Max=600,Default=16,Callback=function(v)S.sv=v if S.sp then pcall(function()Hm().WalkSpeed=v end)end})
T1:Toggle({Title="跳力改",Value=false,Callback=function(v)CO()S.jp=v pcall(function()Hm().JumpPower=v and S.jv or O.J end)end})
T1:Slider({Title="跳力",Min=1,Max=600,Default=50,Callback=function(v)S.jv=v if S.jp then pcall(function()Hm().JumpPower=v end)end})
T1:Toggle({Title="重力改",Value=false,Callback=function(v)CO()S.gr=v WS.Gravity=v and S.gv or O.G end})
T1:Slider({Title="重力",Min=1,Max=500,Default=196,Callback=function(v)S.gv=v if S.gr then WS.Gravity=v end end})
local FLY,NCLC,IJ
T1:Toggle({Title="飞行",Value=false,Callback=function(v)
if v then local hrp=Ch():WaitForChild("HumanoidRootPart")
FLY=Instance.new("BodyVelocity",hrp)FLY.MaxForce=Vector3.new(9e5,9e5,9e5)
local bg=Instance.new("BodyGyro",hrp)bg.MaxTorque=Vector3.new(9e5,9e5,9e5)bg.P=3000
pcall(function()Hm().PlatformStand=true end)
FLY.Changed:Connect(function()end)
S.flycon=RS.Heartbeat:Connect(function()local mv=Vector3.zero local c=WS.CurrentCamera
if UIS:IsKeyDown(Enum.KeyCode.W)then mv+=c.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S)then mv-=c.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A)then mv-=c.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D)then mv+=c.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.Space)then mv+=Vector3.new(0,1,0)end
if UIS:IsKeyDown(Enum.KeyCode.LeftShift)then mv-=Vector3.new(0,1,0)end
bg.CFrame=CFrame.new(hrp.Position,hrp.Position+c.CFrame.LookVector)
FLY.Velocity=(mv.Magnitude>0 and mv.Unit or Vector3.zero)*S.fsv end)
else pcall(function()S.flycon:Disconnect()FLY:Destroy()end)pcall(function()Hm().PlatformStand=false end)end
end})
T1:Slider({Title="飞行速度",Min=10,Max=500,Default=60,Callback=function(v)S.fsv=v end})
T1:Toggle({Title="穿墙",Value=false,Callback=function(v)
if v then S.nc={}for _,p in pairs(Ch():GetDescendants())do if p:IsA("BasePart")then S.nc[p]=p.CanCollide p.CanCollide=false end end
S.nccon=RS.Stepped:Connect(function()for p,_ in pairs(S.nc)do if p and p.Parent then p.CanCollide=false end end)
else pcall(function()S.nccon:Disconnect()end)for p,o in pairs(S.nc)do if p and p.Parent then p.CanCollide=o end end S.nc={}end
end})
T1:Toggle({Title="无限跳",Value=false,Callback=function(v)
if v then S.ijcon=UIS.JumpRequest:Connect(function()pcall(function()local h=Hm()if h:GetState()~=Enum.HumanoidStateType.Dead then h:ChangeState(Enum.HumanoidStateType.Jumping)end end)end)
else pcall(function()S.ijcon:Disconnect()end)end
end})
T1:Toggle({Title="隐身(透明)",Value=false,Callback=function(v)pcall(function()for _,p in pairs(Ch():GetDescendants())do if p:IsA("BasePart")then p.Transparency=v and 1 or 0 end end end)end})
local T2=Win:Tab({Title="视觉",Icon="eye"})
T2:Slider({Title="FOV",Min=50,Max=120,Default=70,Callback=function(v)pcall(function()WS.CurrentCamera.FieldOfView=v end)end})
T2:Toggle({Title="夜视",Value=false,Callback=function(v)pcall(function()G:GetService("Lighting").Brightness=v and 5 or 2 end)end})
T2:Toggle({Title="去雾",Value=false,Callback=function(v)pcall(function()G:GetService("Lighting").FogEnd=v and 999999 or 1000 end)end})
local T3=Win:Tab({Title="ESP",Icon="eye"})
T3:Toggle({Title="名称ESP",Value=false,Callback=function(v)
S.esp=v if v then local f=Instance.new("Folder",G.CoreGui)f.Name="AMESP"
S.espcon=RS.RenderStepped:Connect(function()f:ClearAllChildren()for _,p in pairs(Pl:GetPlayers())do if p~=LP and p.Character and p.Character:FindFirstChild("Head")then local b=Instance.new("BillboardGui",f)b.Adornee=p.Character.Head b.Size=UDim2.new(0,100,0,20)b.AlwaysOnTop=true local l=Instance.new("TextLabel",b)l.Size=UDim2.new(1,0,1,0)l.BackgroundTransparency=1 l.Text=p.Name l.TextColor3=Color3.fromHSV(tick()%5/5,1,1)l.TextScaled=true end end)
else pcall(function()S.espcon:Disconnect()end)pcall(function()G.CoreGui.AMESP:Destroy()end)end
end})
local TS=Win:Tab({Title="设置",Icon="settings"})
TS:Button({Title="复制QQ群179051448",Callback=function()pcall(function()(setclipboard or function()end)("179051448")end)end})
TS:Toggle({Title="全局总开关",Value=true,Callback=function(v)
if not v then for k,_ in pairs(S)do if type(S[k])=="boolean"then S[k]=false end end
pcall(function()Hm().WalkSpeed=O.W Hm().JumpPower=O.J end)WS.Gravity=O.G
pcall(function()S.flycon:Disconnect()FLY:Destroy()S.nccon:Disconnect()S.ijcon:Disconnect()S.espcon:Disconnect()end)
end
end})
TS:Button({Title="彻底销毁脚本",Callback=function()_G.AM_L=false pcall(function()Win:Destroy()end)end})
print("[AM脚本] 压缩版加载完成 ✅")
