
--[[
    VOID X | MM2 STUDIO
    Version 1.1 FIXED
    Place in StarterPlayerScripts as a LocalScript.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BLUE = Color3.fromRGB(35, 145, 255)
local DARK = Color3.fromRGB(8, 11, 19)
local PANEL = Color3.fromRGB(16, 23, 36)
local WHITE = Color3.fromRGB(235, 243, 255)

local settings = {
    Fly = false,
    Speed = false,
    AntiLag = false
}

local walkSpeed = 32
local flySpeed = 55

local savedEffects = {}
local savedLighting = {}
local flyConnection
local velocity
local gyro
local originalSpawn

-- CHARACTER

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- GUI

local oldGui = playerGui:FindFirstChild("VOID_X")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "VOID_X"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(340, 490)
main.Position = UDim2.new(0.5, -170, 0.5, -245)
main.BackgroundColor3 = DARK
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius =
    UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = BLUE
stroke.Thickness = 2
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 65)
header.BackgroundColor3 = Color3.fromRGB(12, 22, 39)
header.BorderSizePixel = 0
header.Parent = main

Instance.new("UICorner", header).CornerRadius =
    UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -65, 0, 35)
title.Position = UDim2.fromOffset(15, 5)
title.BackgroundTransparency = 1
title.Text = "VOID X"
title.TextColor3 = BLUE
title.TextSize = 27
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -65, 0, 20)
subtitle.Position = UDim2.fromOffset(17, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "ULTIMATE MM2 HUB"
subtitle.TextColor3 = WHITE
subtitle.TextSize = 10
subtitle.Font = Enum.Font.GothamBold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 35)
minimize.Position = UDim2.new(1, -45, 0, 15)
minimize.BackgroundColor3 = PANEL
minimize.Text = "—"
minimize.TextColor3 = BLUE
minimize.TextSize = 23
minimize.Parent = header

Instance.new("UICorner", minimize).CornerRadius =
    UDim.new(0, 8)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -105)
content.Position = UDim2.fromOffset(10, 75)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = BLUE
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new()
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

-- MINIMIZE

local minimized = false

minimize.Activated:Connect(function()
    minimized = not minimized
    content.Visible = not minimized

    main.Size = minimized
        and UDim2.fromOffset(340, 65)
        or UDim2.fromOffset(340, 490)

    minimize.Text = minimized and "+" or "—"
end)

-- DRAGGING

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- STATUS

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -5, 0, 30)
status.BackgroundColor3 = PANEL
status.Text = "VOID X READY"
status.TextColor3 = BLUE
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.Parent = content

Instance.new("UICorner", status).CornerRadius =
    UDim.new(0, 7)

local function setStatus(message)
    status.Text = message
end

-- BUTTON SYSTEM (FIXED)

local function makeButton(name, callback)
    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, -5, 0, 40)
    button.BackgroundColor3 = PANEL
    button.Text = name
    button.TextColor3 = WHITE
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = content

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(35, 65, 100)
    border.Parent = button

    button.Activated:Connect(function()
        callback(button)
    end)

    return button
end

local function makeToggle(name, key, callback)
    makeButton(name .. " : OFF", function(button)
        settings[key] = not settings[key]

        button.Text = name ..
            (settings[key] and " : ON" or " : OFF")

        button.TextColor3 =
            settings[key] and BLUE or WHITE

        if callback then
            callback(settings[key])
        end
    end)
end

local function section(name)
    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, -5, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.TextColor3 = BLUE
    label.TextSize = 13
    label.Font = Enum.Font.GothamBlack
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

-- SPEED

section("MOVEMENT")

local function applySpeed()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = settings.Speed and walkSpeed or 16
    end
end

makeToggle("WalkSpeed", "Speed", function(enabled)
    applySpeed()
    setStatus(enabled and "SPEED ENABLED" or "SPEED NORMAL")
end)

makeButton("Increase Speed", function()
    walkSpeed = math.clamp(walkSpeed + 5, 16, 100)
    applySpeed()
    setStatus("WALK SPEED: " .. walkSpeed)
end)

makeButton("Decrease Speed", function()
    walkSpeed = math.clamp(walkSpeed - 5, 16, 100)
    applySpeed()
    setStatus("WALK SPEED: " .. walkSpeed)
end)

-- FLY

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if velocity then
        velocity:Destroy()
        velocity = nil
    end

    if gyro then
        gyro:Destroy()
        gyro = nil
    end
end

local function startFly()
    stopFly()

    local root = getRoot()
    local hum = getHumanoid()

    if not root or not hum then
        setStatus("CHARACTER NOT READY")
        settings.Fly = false
        return
    end

    velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    velocity.Velocity = Vector3.zero
    velocity.Parent = root

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    gyro.P = 10000
    gyro.CFrame = root.CFrame
    gyro.Parent = root

    flyConnection = RunService.Heartbeat:Connect(function()
        if not settings.Fly or not root.Parent then
            stopFly()
            return
        end

        local direction = hum.MoveDirection
        local vertical = 0

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = -1
        end

        velocity.Velocity =
            direction * flySpeed +
            Vector3.new(0, vertical * flySpeed, 0)

        gyro.CFrame = workspace.CurrentCamera.CFrame
    end)
end

makeToggle("Fly", "Fly", function(enabled)
    if enabled then
        startFly()
    else
        stopFly()

        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    setStatus(enabled and "FLY ENABLED" or "FLY DISABLED")
end)

makeButton("Increase Fly Speed", function()
    flySpeed = math.clamp(flySpeed + 10, 10, 150)
    setStatus("FLY SPEED: " .. flySpeed)
end)

makeButton("Decrease Fly Speed", function()
    flySpeed = math.clamp(flySpeed - 10, 10, 150)
    setStatus("FLY SPEED: " .. flySpeed)
end)

-- LOBBY / MAP TELEPORT

section("TELEPORTS")

local function teleportTo(position)
    local root = getRoot()

    if not root then
        setStatus("CHARACTER NOT READY")
        return
    end

    root.CFrame = CFrame.new(position + Vector3.new(0, 4, 0))
    setStatus("TELEPORT COMPLETE")
end

makeButton("Lobby TP", function()
    local lobby = workspace:FindFirstChild("LobbySpawn")

    if lobby and lobby:IsA("BasePart") then
        teleportTo(lobby.Position)
    elseif originalSpawn then
        teleportTo(originalSpawn)
    else
        setStatus("LOBBY SPAWN NOT FOUND")
    end
end)

makeButton("Main Map TP", function()
    local map = workspace:FindFirstChild("CurrentMap")

    if not map then
        setStatus("NO ACTIVE MAP")
        return
    end

    local spawnPart = map:FindFirstChild("MapSpawn", true)
        or map:FindFirstChildWhichIsA("SpawnLocation", true)

    if spawnPart and spawnPart:IsA("BasePart") then
        teleportTo(spawnPart.Position)
    elseif map:IsA("Model") then
        teleportTo(map:GetPivot().Position)
    elseif map:IsA("Folder") then
        local part = map:FindFirstChildWhichIsA("BasePart", true)

        if part then
            teleportTo(part.Position)
        else
            setStatus("MAP SPAWN NOT FOUND")
        end
    end
end)

-- ANTI-LAG

section("PERFORMANCE")

makeButton("Anti-Lag Optimization", function()
    if settings.AntiLag then
        setStatus("ALREADY OPTIMIZED")
        return
    end

    settings.AntiLag = true

    for i = 5, 1, -1 do
        setStatus("OPTIMIZING... " .. i)
        task.wait(1)
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Fire")
            or obj:IsA("Smoke")
            or obj:IsA("Sparkles") then

            savedEffects[obj] = obj.Enabled
            obj.Enabled = false
        end
    end

    setStatus("OPTIMIZATION COMPLETE")
end)

makeButton("Restore Visual Effects", function()
    for obj, enabled in pairs(savedEffects) do
        if obj and obj.Parent then
            obj.Enabled = enabled
        end
    end

    table.clear(savedEffects)
    settings.AntiLag = false

    setStatus("VISUAL EFFECTS RESTORED")
end)

-- CHARACTER RESPAWN

local function onCharacter(char)
    stopFly()

    local root = char:WaitForChild("HumanoidRootPart", 10)

    if root and not originalSpawn then
        originalSpawn = root.Position
    end

    task.wait(0.5)

    applySpeed()

    if settings.Fly then
        startFly()
    end
end

player.CharacterAdded:Connect(onCharacter)

if player.Character then
    task.spawn(onCharacter, player.Character)
end

-- KEYBOARD MENU

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

print("VOID X VERSION 1.1 LOADED")
setStatus("VOID X READY")
