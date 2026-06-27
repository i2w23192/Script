-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- STATES
local toggles = {
    Outlines = false,
    Username = false,
    Distance = false,
    HP = false,
    Team = false
}

local activeHighlights = {}
local activeBillboards = {}
local isCollapsed = false -- Tracks collapse state

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumTrackerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 280)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true -- Prevents elements overflowing when closed
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "TITANIUM"
Title.TextColor3 = Color3.fromRGB(240,240,245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

Instance.new("UIPadding", Title).PaddingLeft = UDim.new(0, 16)

-- COLLAPSE BUTTON
local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Size = UDim2.new(0, 30, 0, 30)
CollapseBtn.Position = UDim2.new(1, -40, 0, 7)
CollapseBtn.BackgroundTransparency = 1
CollapseBtn.Text = "-"
CollapseBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 18
CollapseBtn.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -32, 1, -55)
Container.Position = UDim2.new(0, 16, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local layout = Instance.new("UIListLayout", Container)
layout.Padding = UDim.new(0, 8)

-- COLLAPSE LOGIC
CollapseBtn.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    
    local targetSize = isCollapsed and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 280)
    CollapseBtn.Text = isCollapsed and "+" or "-"
    
    -- Hide/Show the container smoothly
    if not isCollapsed then
        Container.Visible = true
    end
    
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize
    })
    
    tween:Play()
    
    tween.Completed:Connect(function()
        if isCollapsed then
            Container.Visible = false
        end
    end)
end)

-- TOGGLES FUNCTION
local function createModernToggle(labelName, orderIndex, stateKey, callback)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundTransparency = 1
    row.LayoutOrder = orderIndex
    row.Parent = Container

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelName
    textLabel.TextColor3 = Color3.fromRGB(160,160,170)
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 13
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -44, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(35,35,42)
    track.Text = ""
    track.Parent = row

    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200,200,205)
    knob.Parent = track

    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    track.MouseButton1Click:Connect(function()
        toggles[stateKey] = not toggles[stateKey]
        local active = toggles[stateKey]

        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = active and Color3.fromRGB(45,185,105) or Color3.fromRGB(35,35,42)
        }):Play()

        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = active and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,205)
        }):Play()

        callback()
    end)
end

-- HELPERS
local function getTeamColor(player)
    return (player.TeamColor and player.TeamColor.Color) or Color3.new(1,1,1)
end

local function applyHighlight(character, player)
    if player == LocalPlayer or not toggles.Outlines then return end
    if character:FindFirstChild("ModernVisualTracker") then return end

    local h = Instance.new("Highlight")
    h.Name = "ModernVisualTracker"
    h.FillColor = getTeamColor(player)
    h.OutlineColor = getTeamColor(player)
    h.Parent = character

    activeHighlights[player] = h
end

local function applyBillboard(character, player)
    if player == LocalPlayer then return end

    local head = character:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("ModernInfoTag") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ModernInfoTag"
    bb.Size = UDim2.new(0,200,0,75)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = getTeamColor(player)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.Parent = bb

    activeBillboards[player] = txt
end

-- FIXED PLAYER SYSTEM
local function setupCharacter(player, character)
    task.wait(0.2)
    applyHighlight(character, player)
    applyBillboard(character, player)
end

local function evaluatePlayer(player)

    if player.Character then
        task.spawn(function()
            setupCharacter(player, player.Character)
        end)
    end

    player.CharacterAdded:Connect(function(char)
        task.spawn(function()
            setupCharacter(player, char)
        end)
    end)
end

task.spawn(function()
    repeat task.wait() until #Players:GetPlayers() > 0
    for _, p in ipairs(Players:GetPlayers()) do
        evaluatePlayer(p)
    end
end)

Players.PlayerAdded:Connect(evaluatePlayer)

-- HEARTBEAT (FIXED NIL SAFE)
RunService.Heartbeat:Connect(function()

    local lpChar = LocalPlayer.Character
    local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    if not lpRoot then return end

    for player, label in pairs(activeBillboards) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if label and label.Parent and root then

            local lines = {}

            if toggles.Username then table.insert(lines, player.Name) end
            if toggles.Team then table.insert(lines, player.Team and player.Team.Name or "None") end

            if toggles.Distance then
                table.insert(lines, math.floor((root.Position - lpRoot.Position).Magnitude) .. " studs")
            end

            if toggles.HP then
                local hum = char:FindFirstChildOfClass("Humanoid")
                table.insert(lines, "HP: " .. (hum and math.floor(hum.Health) or 0))
            end

            label.Text = table.concat(lines, "\n")
            label.TextColor3 = getTeamColor(player)
        end
    end
end)

-- TOGGLES
createModernToggle("Show Outlines", 1, "Outlines", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then applyHighlight(p.Character, p) end
    end
end)

createModernToggle("Track Username", 2, "Username", function() end)
createModernToggle("Track Team", 3, "Team", function() end)
createModernToggle("Track Distance", 4, "Distance", function() end)
createModernToggle("Track Health (HP)", 5, "HP", function() end)
