-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- --- CONFIGURATION & STATES ---
local toggles = {
    Outlines = false,
    Username = false,
    Distance = false,
    HP = false,
    Team = false
}

local activeHighlights = {}
local activeBillboards = {}

-- --- MODERN UI SETUP ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumTrackerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Container Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 280)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Top Modern Header (Titanium)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 45)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Text = "TITANIUM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = MainFrame

local TitlePadding = Instance.new("UIPadding")
TitlePadding.PaddingLeft = UDim.new(0, 16)
TitlePadding.Parent = Title

-- Content Container Frame
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -32, 1, -55)
Container.Position = UDim2.new(0, 16, 0, 45)
Container.BackgroundTransparency = 1
Container.ZIndex = 3
Container.Parent = MainFrame

-- Layout constraints to automatically arrange rows correctly
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- --- FLOATING LOGO TOGGLE BUTTON (MINIMIZED STATE) ---
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 20, 0, 20)
OpenButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
OpenButton.BorderSizePixel = 0
OpenButton.Text = ""
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.ZIndex = 2
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 85, 255)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

-- --- NATIVE LOGO RENDERER ---
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 30, 0, 30)
LogoContainer.Position = UDim2.new(0.5, -15, 0.5, -15)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 3
LogoContainer.Parent = OpenButton

local function createLogoBar(pos, size)
    local bar = Instance.new("Frame")
    bar.Position = pos
    bar.Size = size
    bar.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
    bar.BorderSizePixel = 0
    bar.ZIndex = 4
    bar.Parent = LogoContainer
end
createLogoBar(UDim2.new(0,0,0,0), UDim2.new(1,0,0,3))     
createLogoBar(UDim2.new(0,0,0,0), UDim2.new(0,3,1,0))     
createLogoBar(UDim2.new(1,-3,0,0), UDim2.new(0,3,1,0))    
createLogoBar(UDim2.new(0,0,1,-3), UDim2.new(1,0,0,3))    
createLogoBar(UDim2.new(0.2,0,0.2,0), UDim2.new(0.6,0,0,3)) 
createLogoBar(UDim2.new(0.5,-1,0.2,0), UDim2.new(0,3,0.4,0))

-- Close Button (X) on Main Panel
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 7)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(120, 120, 130)
CloseButton.Font = Enum.Font.GothamBook
CloseButton.TextSize = 24
CloseButton.ZIndex = 3
CloseButton.Parent = MainFrame

-- Window Actions
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- --- MODERN TOGGLE FABRICATOR ---
local function createModernToggle(labelName, orderIndex, stateKey, onToggleCallback)
    local row = Instance.new("Frame")
    row.Name = labelName .. "Row"
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundTransparency = 1
    row.LayoutOrder = orderIndex
    row.ZIndex = 4
    row.Parent = Container

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelName
    textLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 13
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.ZIndex = 5
    textLabel.Parent = row

    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -44, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    track.Text = ""
    track.AutoButtonColor = false
    track.ZIndex = 5
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    track.MouseButton1Click:Connect(function()
        toggles[stateKey] = not toggles[stateKey]
        local active = toggles[stateKey]

        local targetColor = active and Color3.fromRGB(45, 185, 105) or Color3.fromRGB(35, 35, 42)
        local targetKnobColor = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 205)
        local targetKnobPos = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

        TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetKnobPos, BackgroundColor3 = targetKnobColor}):Play()
        
        onToggleCallback()
    end)
end

-- --- DYNAMIC VISUAL ENGINE ---
local function getTeamColor(player)
    return (player.TeamColor and player.TeamColor.Color) or Color3.fromRGB(255, 255, 255)
end

local function applyHighlight(character, player)
    if player == LocalPlayer or not toggles.Outlines then return end
    if character:FindFirstChild("ModernVisualTracker") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ModernVisualTracker"
    highlight.FillColor = getTeamColor(player)
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = getTeamColor(player)
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    activeHighlights[player] = highlight
end

local function applyBillboard(character, player)
    if player == LocalPlayer then return end
    local head = character:WaitForChild("Head", 5)
    if not head or head:FindFirstChild("ModernInfoTag") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ModernInfoTag"
    billboard.Size = UDim2.new(0, 200, 0, 75)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = getTeamColor(player)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 12
    textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    textLabel.Text = ""
    textLabel.Parent = billboard

    billboard.Parent = head
    activeBillboards[player] = textLabel
end

local function clearOutlines()
    for player, obj in pairs(activeHighlights) do
        if obj then obj:Destroy() end
        activeHighlights[player] = nil
    end
end

-- --- TRACKING EVENT REFRESH LOOP ---
RunService.Heartbeat:Connect(function()
    if not toggles.Outlines then clearOutlines() end

    for player, label in pairs(activeBillboards) do
        -- CRITICAL FIX: Explicit check to ensure the UI element hasn't been garbage collected or destroyed
        if label and label.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local displayLines = {}
            
            if toggles.Username then table.insert(displayLines, player.Name) end
            if toggles.Team then table.insert(displayLines, "Team: " .. (player.Team and player.Team.Name or "None")) end
            
            if toggles.Distance then
                local dist = math.floor((player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                table.insert(displayLines, tostring(dist) .. " studs")
            end
            
            if toggles.HP then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                table.insert(displayLines, "HP: " .. (humanoid and math.floor(humanoid.Health) or 0))
            end

            label.Text = table.concat(displayLines, "\n")
            label.TextColor3 = getTeamColor(player)

            if activeHighlights[player] then
                activeHighlights[player].OutlineColor = getTeamColor(player)
                activeHighlights[player].FillColor = getTeamColor(player)
            end
        else
            activeBillboards[player] = nil
        end
    end
end)

local function evaluatePlayer(player)
    if player.Character then applyHighlight(player.Character, player) applyBillboard(player.Character, player) end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.1) applyHighlight(char, player) applyBillboard(char, player)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do evaluatePlayer(p) end
Players.PlayerAdded:Connect(evaluatePlayer)

-- --- GENERATE ROWS NATIVELY ---
createModernToggle("Show Outlines", 1, "Outlines", function()
    if toggles.Outlines then
        for _, p in ipairs(Players:GetPlayers()) do if p.Character then applyHighlight(p.Character, p) end end
    end
end)
createModernToggle("Track Username", 2, "Username", function() end)
createModernToggle("Track Team", 3, "Team", function() end)
createModernToggle("Track Distance", 4, "Distance", function() end)
createModernToggle("Track Health (HP)", 5, "HP", function() end)