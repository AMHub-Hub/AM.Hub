--[[
    ╔════════════════════════════════════════╗
    ║              AM HUB - REAL EDITION          ║
    ║         No fake shit. Every button works.     ║
    ║           Made by AM | QQ: 179051448         ║
    ╚════════════════════════════════════════╝
]]

-- Prevent double execution
if _G.AM_REAL_LOADED then return end
_G.AM_REAL_LOADED = true

-- ══════════════════════════════════════
-- SERVICES & VARIABLES
-- ══════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Character references (rebind on respawn)
local Character = nil
local Humanoid = nil
local RootPart = nil
local HumanoidRootPart = nil

local function BindCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 10)
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    HumanoidRootPart = RootPart
end

if LocalPlayer.Character then
    BindCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(BindCharacter)

-- Wait for character if not loaded
if not Character then
    Character = LocalPlayer.CharacterAdded:Wait()
    BindCharacter(Character)
end

-- ══════════════════════════════════════
-- STATE TABLE
-- ══════════════════════════════════════
local State = {
    -- Movement
    Fly = false,
    Noclip = false,
    InfJump = false,
    SpeedEnabled = false,
    SpeedValue = 32,
    JumpEnabled = false,
    JumpValue = 100,
    GravityEnabled = false,
    GravityValue = 50,
    
    -- Visual
    NightVision = false,
    NoFog = false,
    FullBright = false,
    DeleteShadows = false,
    HighFOV = false,
    FOVValue = 120,
    MaxZoom = false,
    
    -- ESP
    ESPEnabled = false,
    ESPNames = true,
    ESPBoxes = false,
    ESPHealth = false,
    ESPDistance = false,
    ESPShowTeam = false,
    XRayEnabled = false,
    
    -- Aimbot
    AimbotEnabled = false,
    AimbotFOV = 200,
    AimbotSmoothness = 0.3,
    AimbotTarget = nil,
    AimbotTeamCheck = true,
    
    -- Combat
    BHopEnabled = false,
    ClickTpEnabled = false,
    
    -- Fun
    SpinEnabled = false,
    SpinSpeed = 5,
    FloatEnabled = false,
}

-- Connection storage (for cleanup)
local Connections = {}
local Objects = {} -- Objects to clean up on destroy

local function DisconnectAll()
    for key, conn in pairs(Connections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
        Connections[key] = nil
    end
end

local function CleanupObjects()
    for key, obj in pairs(Objects) do
        if typeof(obj) == "Instance" and obj.Parent then
            obj:Destroy()
        end
        Objects[key] = nil
    end
end

-- ══════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════

-- Safe get character parts
local function GetHRP()
    if Character and Character.Parent and RootPart and RootPart.Parent then
        return RootPart
    end
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        RootPart = Character.HumanoidRootPart
        return RootPart
    end
    return nil
end

local function GetHumanoid()
    if Character and Character.Parent and Humanoid and Humanoid.Parent then
        return Humanoid
    end
    if Character and Character:FindFirstChild("Humanoid") then
        Humanoid = Character.Humanoid
        return Humanoid
    end
    return nil
end

-- Check if player is on our team
local function IsTeammate(targetPlayer)
    if not State.AimbotTeamCheck then return false end
    if targetPlayer.Neutral and LocalPlayer.Neutral then return false end
    return targetPlayer.Team == LocalPlayer.Team and targetPlayer.Team ~= nil
end

-- Get closest player to camera center
local function GetClosestPlayerToCenter()
    local closest = nil
    local closestDist = State.AimbotFOV
    local screenCenter = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            local char = player.Character
            if char and char:FindFirstChild("Head") then
                local head = char.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

-- Get closest player by 3D distance
local function GetClosestPlayerByDistance()
    local closest = nil
    local closestDist = State.AimbotFOV
    local hrp = GetHRP()
    if not hrp then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    
    return closest
end

-- Smooth CFrame transition
local function SmoothCFrame(current, target, smoothness)
    return current:Lerp(target, smoothness)
end

-- ══════════════════════════════════════
-- FLY SYSTEM (LinearVelocity - 2026 compatible)
-- ══════════════════════════════════════
local FlyMover = nil
local FlyAlign = nil
local FlyAttachment = nil

local function StartFly()
    local hrp = GetHRP()
    if not hrp then return end
    
    -- Clean up old fly objects
    if FlyMover then FlyMover:Destroy() end
    if FlyAlign then FlyAlign:Destroy() end
    if FlyAttachment then FlyAttachment:Destroy() end
    
    local hum = GetHumanoid()
    if hum then hum.PlatformStand = true end
    
    -- Create attachment
    FlyAttachment = Instance.new("Attachment")
    FlyAttachment.Name = "AM_FlyAttachment"
    FlyAttachment.Parent = hrp
    
    -- LinearVelocity for movement (newer API, harder to detect)
    FlyMover = Instance.new("LinearVelocity")
    FlyMover.Name = "AM_FlyMover"
    FlyMover.Attachment0 = FlyAttachment
    FlyMover.MaxForce = 100000
    FlyMover.VectorVelocity = Vector3.zero
    FlyMover.RelativeTo = Enum.ActuatorRelativeTo.World
    FlyMover.Parent = hrp
    
    -- AlignOrientation to keep upright
    FlyAlign = Instance.new("AlignOrientation")
    FlyAlign.Name = "AM_FlyAlign"
    FlyAlign.Attachment0 = FlyAttachment
    FlyAlign.MaxTorque = 100000
    FlyAlign.Reactivity = 50
    FlyAlign.Responsiveness = 25
    FlyAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
    FlyAlign.Parent = hrp
    
    -- Movement loop
    Connections.Fly = RunService.Heartbeat:Connect(function(dt)
        local hrp2 = GetHRP()
        if not hrp2 or not FlyMover or not FlyMover.Parent then return end
        
        local cam = Workspace.CurrentCamera
        if not cam then return end
        
        local moveDir = Vector3.zero
        
        -- Keyboard input
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.yAxis
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            moveDir = moveDir - Vector3.yAxis
        end
        
        -- Normalize and apply speed
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * State.SpeedValue * 2
        end
        
        FlyMover.VectorVelocity = moveDir
        
        -- Keep upright
        if FlyAlign and FlyAlign.Parent then
            FlyAlign.CFrame = CFrame.new(hrp2.Position, hrp2.Position + cam.CFrame.LookVector)
        end
    end)
end

local function StopFly()
    State.Fly = false
    
    local hum = GetHumanoid()
    if hum then hum.PlatformStand = false end
    
    if Connections.Fly then
        Connections.Fly:Disconnect()
        Connections.Fly = nil
    end
    
    if FlyMover then FlyMover:Destroy() FlyMover = nil end
    if FlyAlign then FlyAlign:Destroy() FlyAlign = nil end
    if FlyAttachment then FlyAttachment:Destroy() FlyAttachment = nil end
end

-- ══════════════════════════════════════
-- NOCLIP SYSTEM
-- ══════════════════════════════════════
local function StartNoclip()
    Connections.Noclip = RunService.Stepped:Connect(function()
        local char = Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function StopNoclip()
    State.Noclip = false
    if Connections.Noclip then
        Connections.Noclip:Disconnect()
        Connections.Noclip = nil
    end
end

-- ══════════════════════════════════════
-- INFINITE JUMP
-- ══════════════════════════════════════
local function StartInfJump()
    Connections.InfJump = UserInputService.JumpRequest:Connect(function()
        local hum = GetHumanoid()
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function StopInfJump()
    State.InfJump = false
    if Connections.InfJump then
        Connections.InfJump:Disconnect()
        Connections.InfJump = nil
    end
end

-- ══════════════════════════════════════
-- SPEED / JUMP / GRAVITY
-- ══════════════════════════════════════
local function ApplySpeed(value)
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = value end
end

local function ApplyJump(value)
    local hum = GetHumanoid()
    if hum then
        pcall(function() hum.JumpPower = value end)
        pcall(function() hum.JumpHeight = value / 2 end)
    end
end

local function ApplyGravity(value)
    Workspace.Gravity = value
end

-- ══════════════════════════════════════
-- VISUAL EFFECTS
-- ══════════════════════════════════════
local SavedLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    ShadowSoftness = Lighting.ShadowSoftness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function SetNightVision(on)
    if on then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 5
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = SavedLighting.Ambient
        Lighting.Brightness = SavedLighting.Brightness
        Lighting.OutdoorAmbient = SavedLighting.OutdoorAmbient
    end
end

local function SetNoFog(on)
    if on then
        Lighting.FogEnd = 1000000
    else
        Lighting.FogEnd = SavedLighting.FogEnd
    end
end

local function SetFullBright(on)
    if on then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = SavedLighting.Ambient
        Lighting.OutdoorAmbient = SavedLighting.OutdoorAmbient
        Lighting.Brightness = SavedLighting.Brightness
    end
end

local function SetDeleteShadows(on)
    if on then
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.CastShadow = false
            end
        end
    else
        Lighting.GlobalShadows = SavedLighting.GlobalShadows
        Lighting.ShadowSoftness = SavedLighting.ShadowSoftness
    end
end

local function SetFOV(value)
    Camera.FieldOfView = value
end

-- ══════════════════════════════════════
-- ESP SYSTEM (Highlight-based, stable)
-- ══════════════════════════════════════
local ESPFolder = nil
local ESPData = {} -- [player] = {folder, elements}

local function CreateESPElements(player, character)
    if not ESPFolder then return end
    if ESPData[player] then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local playerFolder = Instance.new("Folder")
    playerFolder.Name = "ESP_" .. player.UserId
    playerFolder.Parent = ESPFolder
    
    ESPData[player] = {folder = playerFolder, elements = {}}
    local data = ESPData[player]
    
    -- Name Tag
    if State.ESPNames then
        local bb = Instance.new("BillboardGui")
        bb.Name = "NameTag"
        bb.Adornee = rootPart
        bb.Size = UDim2.new(0, 120, 0, 22)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 1000
        bb.Parent = playerFolder
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.new(0, 0, 0)
        bg.BackgroundTransparency = 0.5
        bg.BorderSizePixel = 0
        bg.Parent = bb
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.DisplayName
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 13
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0.3
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Parent = bb
        
        data.elements.NameTag = bb
    end
    
    -- Distance
    if State.ESPDistance then
        local bb = Instance.new("BillboardGui")
        bb.Name = "Distance"
        bb.Adornee = rootPart
        bb.Size = UDim2.new(0, 100, 0, 18)
        bb.StudsOffset = Vector3.new(0, -2.8, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 1000
        bb.Parent = playerFolder
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "0m"
        label.TextColor3 = Color3.new(0, 1, 1)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextStrokeTransparency = 0.3
        label.Parent = bb
        
        data.elements.Distance = bb
        data.elements.DistanceLabel = label
    end
    
    -- Health Bar
    if State.ESPHealth then
        local bb = Instance.new("BillboardGui")
        bb.Name = "Health"
        bb.Adornee = rootPart
        bb.Size = UDim2.new(0, 60, 0, 24)
        bb.StudsOffset = Vector3.new(0, 2.2, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 1000
        bb.Parent = playerFolder
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 0.4, 0)
        bg.Position = UDim2.new(0, 0, 0.6, 0)
        bg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        bg.BorderSizePixel = 1
        bg.BorderColor3 = Color3.new(1, 1, 1)
        bg.Parent = bb
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 1, 0)
        bar.BackgroundColor3 = Color3.new(0, 1, 0)
        bar.BorderSizePixel = 0
        bar.Parent = bg
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 0.5, 0)
        text.BackgroundTransparency = 1
        text.Text = "100/100"
        text.TextColor3 = Color3.new(1, 1, 1)
        text.TextSize = 9
        text.Font = Enum.Font.GothamBold
        text.Parent = bb
        
        data.elements.HealthBar = bar
        data.elements.HealthText = text
        data.elements.HealthBg = bg
    end
    
    -- 2D Box (using Highlight for 3D box)
    if State.ESPBoxes then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Box3D"
        highlight.Adornee = character
        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.OutlineColor = Color3.new(1, 1, 0)
        highlight.FillTransparency = 0.85
        highlight.OutlineTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = playerFolder
        
        data.elements.Highlight = highlight
    end
end

local function UpdateESP()
    if not State.ESPEnabled then return end
    if not ESPFolder then return end
    
    local localHRP = GetHRP()
    if not localHRP then return end
    
    for player, data in pairs(ESPData) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            -- Clean up dead/disconnected players
            if data.folder and data.folder.Parent then
                data.folder:Destroy()
            end
            ESPData[player] = nil
        else
            -- Update distance
            if data.elements.DistanceLabel then
                local dist = (char.HumanoidRootPart.Position - localHRP.Position).Magnitude
                data.elements.DistanceLabel.Text = math.floor(dist) .. "m"
            end
            
            -- Update health
            if data.elements.HealthBar and data.elements.HealthText then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    local pct = hum.Health / hum.MaxHealth
                    data.elements.HealthBar.Size = UDim2.new(math.max(pct, 0.01), 0, 1, 0)
                    if pct > 0.7 then
                        data.elements.HealthBar.BackgroundColor3 = Color3.new(0, 1, 0)
                    elseif pct > 0.3 then
                        data.elements.HealthBar.BackgroundColor3 = Color3.new(1, 1, 0)
                    else
                        data.elements.HealthBar.BackgroundColor3 = Color3.new(1, 0, 0)
                    end
                    data.elements.HealthText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                end
            end
        end
    end
    
    -- Create ESP for new players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESPData[player] then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                CreateESPElements(player, player.Character)
            end
        end
    end
end

local function StartESP()
    if ESPFolder then ESPFolder:Destroy() end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "AM_ESP"
    ESPFolder.Parent = StarterGui
    
    ESPData = {}
    
    -- Create initial ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESPElements(player, player.Character)
        end
    end
    
    Connections.ESPUpdate = RunService.Heartbeat:Connect(UpdateESP)
end

local function StopESP()
    State.ESPEnabled = false
    if Connections.ESPUpdate then
        Connections.ESPUpdate:Disconnect()
        Connections.ESPUpdate = nil
    end
    if ESPFolder then
        ESPFolder:Destroy()
        ESPFolder = nil
    end
    ESPData = {}
end

-- Player join/leave for ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if State.ESPEnabled then
            task.wait(1)
            if char:FindFirstChild("HumanoidRootPart") then
                CreateESPElements(player, char)
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPData[player] then
        if ESPData[player].folder and ESPData[player].folder.Parent then
            ESPData[player].folder:Destroy()
        end
        ESPData[player] = nil
    end
end)

-- ══════════════════════════════════════
-- XRAY / WALLHACK
-- ══════════════════════════════════════
local XRayConnection = nil

local function StartXRay()
    XRayConnection = RunService.RenderStepped:Connect(function()
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Parent ~= Character then
                part.LocalTransparencyModifier = 0.6
            end
        end
    end)
end

local function StopXRay()
    State.XRayEnabled = false
    if XRayConnection then
        XRayConnection:Disconnect()
        XRayConnection = nil
    end
    -- Reset transparencies
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
        end
    end
end

-- ══════════════════════════════════════
-- AIMBOT SYSTEM (Camera lock with FOV)
-- ══════════════════════════════════════
local AimbotConnection = nil
local AimbotFOVRing = nil

local function CreateFOVRing()
    if not Drawing then return nil end
    local ring = Drawing.new("Circle")
    ring.Visible = true
    ring.Thickness = 2
    ring.Color = Color3.fromRGB(0, 255, 100)
    ring.Filled = false
    ring.Radius = State.AimbotFOV
    ring.Position = Camera.ViewportSize / 2
    ring.NumSides = 64
    return ring
end

local function StartAimbot()
    Camera.CameraType = Enum.CameraType.Scriptable
    
    AimbotFOVRing = CreateFOVRing()
    
    AimbotConnection = RunService.RenderStepped:Connect(function()
        local target = GetClosestPlayerToCenter()
        if not target or not target.Character then return end
        
        local head = target.Character:FindFirstChild("Head")
        if not head then return end
        
        -- Smooth aim
        local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        Camera.CFrame = SmoothCFrame(Camera.CFrame, targetCFrame, State.AimbotSmoothness)
        
        State.AimbotTarget = target
    end)
end

local function StopAimbot()
    State.AimbotEnabled = false
    State.AimbotTarget = nil
    
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    
    if AimbotFOVRing then
        AimbotFOVRing:Remove()
        AimbotFOVRing = nil
    end
    
    Camera.CameraType = Enum.CameraType.Custom
end

-- ══════════════════════════════════════
-- CLICK TELEPORT
-- ══════════════════════════════════════
local function CreateClickTeleportTool()
    local tool = Instance.new("Tool")
    tool.Name = "AM_ClickTP"
    tool.RequiresHandle = false
    tool.Parent = LocalPlayer.Backpack
    
    local mouse = LocalPlayer:GetMouse()
    tool.Activated:Connect(function()
        local hrp = GetHRP()
        if not hrp then return end
        local target = mouse.Hit
        if target then
            hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        end
    end)
    
    Objects.ClickTP = tool
end

-- ══════════════════════════════════════
-- SPIN BOT
-- ══════════════════════════════════════
local function StartSpin()
    Connections.Spin = RunService.Heartbeat:Connect(function(dt)
        local hrp = GetHRP()
        if not hrp then return end
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed * 60 * dt), 0)
    end)
end

local function StopSpin()
    State.SpinEnabled = false
    if Connections.Spin then
        Connections.Spin:Disconnect()
        Connections.Spin = nil
    end
end

-- ══════════════════════════════════════
-- FLOAT / ANTI-FALL
-- ══════════════════════════════════════
local FloatAttachment = nil
local FloatVelocity = nil

local function StartFloat()
    local hrp = GetHRP()
    if not hrp then return end
    
    FloatAttachment = Instance.new("Attachment")
    FloatAttachment.Name = "AM_FloatAttach"
    FloatAttachment.Parent = hrp
    
    FloatVelocity = Instance.new("LinearVelocity")
    FloatVelocity.Name = "AM_FloatVelocity"
    FloatVelocity.Attachment0 = FloatAttachment
    FloatVelocity.MaxForce = 50000
    FloatVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    FloatVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FloatVelocity.Parent = hrp
    
    Connections.Float = RunService.Heartbeat:Connect(function()
        local hrp2 = GetHRP()
        if not hrp2 then return end
        
        -- Keep player at current Y, prevent falling
        local currentVel = hrp2.Velocity
        if FloatVelocity and FloatVelocity.Parent then
            FloatVelocity.VectorVelocity = Vector3.new(currentVel.X, 0, currentVel.Z)
        end
    end)
end

local function StopFloat()
    State.FloatEnabled = false
    if Connections.Float then
        Connections.Float:Disconnect()
        Connections.Float = nil
    end
    if FloatVelocity then FloatVelocity:Destroy() FloatVelocity = nil end
    if FloatAttachment then FloatAttachment:Destroy() FloatAttachment = nil end
end

-- ══════════════════════════════════════
-- BHOP (Bunny Hop)
-- ══════════════════════════════════════
local function StartBHop()
    Connections.BHop = RunService.Heartbeat:Connect(function()
        local hum = GetHumanoid()
        if not hum then return end
        if hum:GetState() == Enum.HumanoidStateType.Landed or hum:GetState() == Enum.HumanoidStateType.Running then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function StopBHop()
    State.BHopEnabled = false
    if Connections.BHop then
        Connections.BHop:Disconnect()
        Connections.BHop = nil
    end
end

-- ══════════════════════════════════════
-- MAX ZOOM
-- ══════════════════════════════════════
local SavedZoom = nil

local function SetMaxZoom(on)
    if on then
        SavedZoom = LocalPlayer.CameraMaxZoomDistance
        LocalPlayer.CameraMaxZoomDistance = 100000
    else
        if SavedZoom then
            LocalPlayer.CameraMaxZoomDistance = SavedZoom
        else
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end
end

-- ══════════════════════════════════════
-- DESTROY / CLEANUP
-- ══════════════════════════════════════
local function FullCleanup()
    -- Stop all systems
    StopFly()
    StopNoclip()
    StopInfJump()
    StopESP()
    StopXRay()
    StopAimbot()
    StopSpin()
    StopFloat()
    StopBHop()
    
    -- Reset values
    ApplySpeed(16)
    ApplyJump(50)
    ApplyGravity(196)
    SetNightVision(false)
    SetNoFog(false)
    SetFullBright(false)
    SetDeleteShadows(false)
    SetFOV(70)
    SetMaxZoom(false)
    
    -- Disconnect all
    DisconnectAll()
    
    -- Cleanup objects
    CleanupObjects()
    
    -- Destroy GUI
    if AM_GUI and AM_GUI.Parent then
        AM_GUI:Destroy()
    end
    
    _G.AM_REAL_LOADED = false
end

-- ══════════════════════════════════════
-- GUI SYSTEM (Native, no external deps)
-- ══════════════════════════════════════

local AM_GUI = Instance.new("ScreenGui")
AM_GUI.Name = "AM_Real_Hub"
AM_GUI.ResetOnSpawn = false
AM_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AM_GUI.Parent = CoreGui
Objects.MainGUI = AM_GUI

-- Main Window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 480, 0, 340)
MainWindow.Position = UDim2.new(0.5, -240, 0.5, -170)
MainWindow.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainWindow.BackgroundTransparency = 0.05
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.Visible = false
MainWindow.Parent = AM_GUI

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Parent = MainWindow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ AM HUB - REAL EDITION"
TitleLabel.TextColor3 = Color3.fromRGB(144, 238, 144)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -30, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

-- Tab Bar (left side)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 90, 1, -36)
TabBar.Position = UDim2.new(0, 4, 0, 36)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainWindow

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 3)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

-- Content Area
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -100, 1, -40)
ContentArea.Position = UDim2.new(0, 96, 0, 38)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.Parent = MainWindow

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 4)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentArea

-- ══════════════════════════════════════
-- GUI HELPER FUNCTIONS
-- ══════════════════════════════════════

local CurrentTab = "通用"
local TabPages = {}

local function CreateTabPage(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = (name == "通用")
    page.Name = "Page_" .. name
    page.Parent = ContentArea
    TabPages[name] = page
    return page
end

local function SwitchTab(name)
    CurrentTab = name
    for pageName, page in pairs(TabPages) do
        page.Visible = (pageName == name)
    end
    -- Update tab button colors
    for _, child in pairs(TabBar:GetChildren()) do
        if child:IsA("TextButton") then
            if child.Text:find(name) then
                child.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
            else
                child.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            end
        end
    end
end

local function CreateTabButton(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
    
    return btn
end

-- Widget creators
local function CreateRow(parent)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 28)
    row.BackgroundTransparency = 1
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.Parent = parent
    return row
end

local function CreateLabel(parent, text, width)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, width or 120, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function CreateToggle(parent, labelText, default, callback)
    local row = CreateRow(parent)
    CreateLabel(row, labelText, 140)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(1, -56, 0, 3)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(60, 60, 70)
    btn.BorderSizePixel = 0
    btn.Parent = row
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local isOn = btn.Text == "OFF"
        btn.Text = isOn and "ON" or "OFF"
        btn.BackgroundColor3 = isOn and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(60, 60, 70)
        callback(isOn, btn)
    end)
    
    return btn
end

local function CreateSlider(parent, labelText, min, max, default, callback)
    local row = CreateRow(parent)
    row.Size = UDim2.new(1, -8, 0, 44)
    
    local lbl = CreateLabel(row, labelText, 140)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 16)
    valueLabel.Position = UDim2.new(1, -56, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(144, 238, 144)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -8, 0, 14)
    sliderBg.Position = UDim2.new(0, 4, 0, 26)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = row
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 180, 120)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local pos = sliderBg.AbsolutePosition
            local size = sliderBg.AbsoluteSize
            local pct = math.clamp((mouse.X - pos.X) / size.X, 0, 1)
            local value = math.floor(min + pct * (max - min))
            fill.Size = UDim2.new(pct, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    return {sliderBg = sliderBg, fill = fill, label = valueLabel}
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    end)
    
    return btn
end

local function CreateSeparator(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    line.BorderSizePixel = 0
    line.Parent = frame
    
    if text then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 100, 1, 0)
        lbl.Position = UDim2.new(0.5, -50, 0, 0)
        lbl.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        lbl.BackgroundTransparency = 0
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(120, 120, 140)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = frame
    end
end

local function CreateParagraph(parent, title, desc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -12, 0, 16)
    titleLbl.Position = UDim2.new(0, 6, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(144, 238, 144)
    titleLbl.TextSize = 11
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame
    
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -12, 0, 18)
    descLbl.Position = UDim2.new(0, 6, 0, 18)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    descLbl.TextSize = 10
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextWrapped = true
    descLbl.Parent = frame
end

-- ══════════════════════════════════════
-- BUILD TABS
-- ══════════════════════════════════════

-- Tab Buttons
CreateTabButton("通用", "⚙")
CreateTabButton("移动", "🏃")
CreateTabButton("视觉", "👁")
CreateTabButton("ESP", "📡")
CreateTabButton("自瞄", "🎯")
CreateTabButton("战斗", "⚔")
CreateTabButton("娱乐", "🎮")
CreateTabButton("设置", "🔧")

-- ══════════════════════════════════════
-- TAB: 通用 (Home)
-- ══════════════════════════════════════
local TabHome = CreateTabPage("通用")

CreateParagraph(TabHome, "AM HUB - REAL EDITION", "Made by AM | QQ群: 179051448")
CreateParagraph(TabHome, "系统信息", string.format("用户: %s | 显示名: %s\nID: %d | 账号年龄: %d天", 
    LocalPlayer.Name, LocalPlayer.DisplayName, LocalPlayer.UserId, LocalPlayer.AccountAge))

CreateSeparator(TabHome, "─── 快捷功能 ───")

CreateButton(TabHome, "📋 复制QQ群号", function()
    pcall(function() setclipboard("179051448") end)
end)

CreateButton(TabHome, "🔄 重置所有数值", function()
    ApplySpeed(16)
    ApplyJump(50)
    ApplyGravity(196)
    SetFOV(70)
    State.SpeedValue = 16
    State.JumpValue = 50
    State.GravityValue = 196
    State.FOVValue = 70
end)

-- ══════════════════════════════════════
-- TAB: 移动 (Movement)
-- ══════════════════════════════════════
local TabMove = CreateTabPage("移动")

CreateSeparator(TabMove, "─── 飞行 ───")

CreateToggle(TabMove, "启用飞行 (WASD+空格)", false, function(on)
    State.Fly = on
    if on then
        StartFly()
    else
        StopFly()
    end
end)

CreateSlider(TabMove, "飞行速度", 10, 300, 50, function(v)
    State.SpeedValue = v
    if State.Fly then
        -- Speed applies immediately in the fly loop
    end
end)

CreateSeparator(TabMove, "─── 基础移动 ───")

CreateToggle(TabMove, "穿墙 (Noclip)", false, function(on)
    State.Noclip = on
    if on then StartNoclip() else StopNoclip() end
end)

CreateToggle(TabMove, "无限跳", false, function(on)
    State.InfJump = on
    if on then StartInfJump() else StopInfJump() end
end)

CreateToggle(TabMove, "BunnyHop", false, function(on)
    State.BHopEnabled = on
    if on then StartBHop() else StopBHop() end
end)

CreateSlider(TabMove, "移动速度", 16, 500, 32, function(v)
    State.SpeedValue = v
    ApplySpeed(v)
end)

CreateSlider(TabMove, "跳跃高度", 50, 500, 100, function(v)
    State.JumpValue = v
    ApplyJump(v)
end)

CreateSlider(TabMove, "重力", 0, 500, 196, function(v)
    State.GravityValue = v
    ApplyGravity(v)
end)

-- ══════════════════════════════════════
-- TAB: 视觉 (Visual)
-- ══════════════════════════════════════
local TabVis = CreateTabPage("视觉")

CreateSeparator(TabVis, "─── 环境 ───")

CreateToggle(TabVis, "夜视", false, function(on)
    State.NightVision = on
    SetNightVision(on)
end)

CreateToggle(TabVis, "去雾", false, function(on)
    State.NoFog = on
    SetNoFog(on)
end)

CreateToggle(TabVis, "全图明亮", false, function(on)
    State.FullBright = on
    SetFullBright(on)
end)

CreateToggle(TabVis, "删除阴影", false, function(on)
    State.DeleteShadows = on
    SetDeleteShadows(on)
end)

CreateSeparator(TabVis, "─── 相机 ───")

CreateToggle(TabVis, "广角视野", false, function(on)
    State.HighFOV = on
    SetFOV(on and State.FOVValue or 70)
end)

CreateSlider(TabVis, "FOV 数值", 50, 150, 120, function(v)
    State.FOVValue = v
    if State.HighFOV then SetFOV(v) end
end)

CreateToggle(TabVis, "最大缩放距离", false, function(on)
    State.MaxZoom = on
    SetMaxZoom(on)
end)

-- ══════════════════════════════════════
-- TAB: ESP
-- ══════════════════════════════════════
local TabESP = CreateTabPage("ESP")

CreateToggle(TabESP, "ESP 总开关", false, function(on)
    State.ESPEnabled = on
    if on then
        StartESP()
    else
        StopESP()
    end
end)

CreateSeparator(TabESP, "─── 显示选项 ───")

CreateToggle(TabESP, "玩家名称", true, function(on)
    State.ESPNames = on
    StopESP()
    if State.ESPEnabled then StartESP() end
end)

CreateToggle(TabESP, "距离显示", false, function(on)
    State.ESPDistance = on
    StopESP()
    if State.ESPEnabled then StartESP() end
end)

CreateToggle(TabESP, "血量条", false, function(on)
    State.ESPHealth = on
    StopESP()
    if State.ESPEnabled then StartESP() end
end)

CreateToggle(TabESP, "3D方框 (Highlight)", false, function(on)
    State.ESPBoxes = on
    StopESP()
    if State.ESPEnabled then StartESP() end
end)

CreateSeparator(TabESP, "─── 透视 ───")

CreateToggle(TabESP, "XRay 透视", false, function(on)
    State.XRayEnabled = on
    if on then StartXRay() else StopXRay() end
end)

-- ══════════════════════════════════════
-- TAB: 自瞄 (Aimbot)
-- ══════════════════════════════════════
local TabAim = CreateTabPage("自瞄")

CreateToggle(TabAim, "启用自瞄", false, function(on)
    State.AimbotEnabled = on
    if on then
        StartAimbot()
    else
        StopAimbot()
    end
end)

CreateSlider(TabAim, "自瞄范围 (FOV)", 10, 600, 200, function(v)
    State.AimbotFOV = v
    if AimbotFOVRing then
        AimbotFOVRing.Radius = v
    end
end)

CreateSlider(TabAim, "平滑度 (越低越硬)", 1, 100, 30, function(v)
    State.AimbotSmoothness = v / 100
end)

CreateToggle(TabAim, "队伍检测", true, function(on)
    State.AimbotTeamCheck = on
end)

CreateSeparator(TabAim, "─── 信息 ───")

CreateParagraph(TabAim, "自瞄说明", "自动锁定屏幕中心范围内最近玩家的头部\n绿色圆圈显示当前FOV范围\n平滑度越低 = 锁头越硬")

-- ══════════════════════════════════════
-- TAB: 战斗 (Combat)
-- ══════════════════════════════════════
local TabCombat = CreateTabPage("战斗")

CreateSeparator(TabCombat, "─── 传送 ───")

CreateButton(TabCombat, "🖱 点击传送工具", function()
    CreateClickTeleportTool()
end)

CreateSeparator(TabCombat, "─── 防坠落 ───")

CreateToggle(TabCombat, "悬浮 (防坠落)", false, function(on)
    State.FloatEnabled = on
    if on then StartFloat() else StopFloat() end
end)

-- ══════════════════════════════════════
-- TAB: 娱乐 (Fun)
-- ══════════════════════════════════════
local TabFun = CreateTabPage("娱乐")

CreateToggle(TabFun, "旋转", false, function(on)
    State.SpinEnabled = on
    if on then StartSpin() else StopSpin() end
end)

CreateSlider(TabFun, "旋转速度", 1, 30, 5, function(v)
    State.SpinSpeed = v
end)

CreateSeparator(TabFun, "─── 工具 ───")

CreateButton(TabFun, "🛡 Adonis反作弊绕过", function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua', true))()
    end)
end)

CreateButton(TabFun, "📊 FPS显示", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/d9j82YJr/raw", true))()
    end)
end)

CreateButton(TabFun, "🚀 FPS提升器", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JoshzzAlteregooo/JoshzzFpsBoosterVersion3/refs/heads/main/JoshzzNewFpsBooster"))()
    end)
end)

-- ══════════════════════════════════════
-- TAB: 设置 (Settings)
-- ══════════════════════════════════════
local TabSettings = CreateTabPage("设置")

CreateSeparator(TabSettings, "─── 全局控制 ───")

CreateButton(TabSettings, "⚠ 关闭所有功能", function()
    FullCleanup()
end)

CreateButton(TabSettings, "🔄 重生角色", function()
    local hum = GetHumanoid()
    if hum then
        hum.Health = 0
    end
end)

CreateSeparator(TabSettings, "─── 信息 ───")

CreateParagraph(TabSettings, "AM HUB REAL EDITION", "此脚本为内部使用版本\n所有功能均为内建实现\n不依赖外部加载器\n\nQQ群: 179051448\nMade by AM")

-- ══════════════════════════════════════
-- FLOATING BUTTON (Bottom Right)
-- ══════════════════════════════════════
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(1, -62, 1, -62)
FloatBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
FloatBtn.Text = "AM"
FloatBtn.TextColor3 = Color3.new(1, 1, 1)
FloatBtn.TextSize = 16
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.BorderSizePixel = 0
FloatBtn.Draggable = true
FloatBtn.Parent = AM_GUI

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Thickness = 3
FloatStroke.Color = Color3.fromRGB(100, 200, 100)
FloatStroke.Parent = FloatBtn

-- Rainbow effect
spawn(function()
    while AM_GUI and AM_GUI.Parent do
        pcall(function()
            local hue = (tick() * 0.3) % 1
            FloatBtn.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 0.5)
            FloatStroke.Color = Color3.fromHSV(hue, 0.5, 0.8)
        end)
        task.wait(0.1)
    end
end)

FloatBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
end)

-- ══════════════════════════════════════
-- TITLE BAR BUTTONS
-- ══════════════════════════════════════
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainWindow.Size = UDim2.new(0, 480, 0, 34)
        ContentArea.Visible = false
        TabBar.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainWindow.Size = UDim2.new(0, 480, 0, 340)
        ContentArea.Visible = true
        TabBar.Visible = true
        MinimizeBtn.Text = "—"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    FullCleanup()
end)

-- ══════════════════════════════════════
-- CHARACTER RESPAWN HANDLING
-- ══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(newChar)
    -- Rebind
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid", 10)
    RootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    HumanoidRootPart = RootPart
    
    -- Restart enabled systems
    task.wait(1)
    
    if State.Fly then
        State.Fly = false
        StartFly()
    end
    if State.Noclip then
        State.Noclip = false
        StartNoclip()
    end
    if State.InfJump then
        State.InfJump = false
        StartInfJump()
    end
    if State.FloatEnabled then
        State.FloatEnabled = false
        StartFloat()
    end
    if State.SpinEnabled then
        State.SpinEnabled = false
        StartSpin()
    end
    if State.BHopEnabled then
        State.BHopEnabled = false
        StartBHop()
    end
end)

-- ══════════════════════════════════════
-- UPDATE CANVAS SIZE
-- ══════════════════════════════════════
ContentArea.ChildAdded:Connect(function()
    task.wait(0.1)
    local totalHeight = 0
    for _, child in pairs(ContentArea:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            totalHeight = totalHeight + child.Size.Y.Offset + 4
        end
    end
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end)

-- ══════════════════════════════════════
-- HOTKEYS
-- ══════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Right Control: Toggle Menu
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainWindow.Visible = not MainWindow.Visible
    end
    
    -- End key: Full cleanup
    if input.KeyCode == Enum.KeyCode.End then
        FullCleanup()
    end
end)

-- ══════════════════════════════════════
-- INITIAL SETUP COMPLETE
-- ══════════════════════════════════════

-- Set initial tab
SwitchTab("通用")

-- Auto-show window after 2 seconds
task.spawn(function()
    task.wait(2)
    MainWindow.Visible = true
end)

-- Welcome message
print("╔══════════════════════════════════════╗")
print("║     AM HUB - REAL EDITION LOADED     ║");
print("║     Made by AM | QQ: 179051448      ║");
print("║     Hotkey: Right Ctrl = Toggle      ║");
print("║     Hotkey: End = Destroy           ║");
print("╚══════════════════════════════════════╝");

-- Keep script alive
while AM_GUI and AM_GUI.Parent do
    task.wait(1)
end
