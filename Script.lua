--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// STATE
local toggles = {
    ESP = false,
    Boxes = false,
    Tracers = false,
    Names = false,
    Distance = false,
    HP = false
}

local espObjects = {}

--// UI
local gui = Instance.new("ScreenGui")
gui.Name = "TitaniumESP"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 220)
frame.Position = UDim2.new(0.5, -130, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

--// HELPERS
local function getColor(plr)
    return plr.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255,255,255)
end

local function createDrawing()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Filled = false

    local line = Drawing.new("Line")
    line.Visible = false
    line.Thickness = 1

    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 13
    text.Center = true
    text.Outline = true

    return {
        Box = box,
        Line = line,
        Text = text
    }
end

--// PLAYER SETUP
local function setupPlayer(plr)
    if plr == LocalPlayer then return end

    espObjects[plr] = createDrawing()

    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
    end)
end

for _,p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end

Players.PlayerAdded:Connect(setupPlayer)

--// MAIN RENDER LOOP (SMOOTH, NOT HEARTBEAT SPAM)
RunService.RenderStepped:Connect(function()

    if not toggles.ESP then
        for _,v in pairs(espObjects) do
            v.Box.Visible = false
            v.Line.Visible = false
            v.Text.Visible = false
        end
        return
    end

    for plr, esp in pairs(espObjects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum then

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then

                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude

                local size = math.clamp(2000 / dist, 20, 120)

                local color = getColor(plr)

                -- BOX
                if toggles.Boxes then
                    esp.Box.Visible = true
                    esp.Box.Size = Vector2.new(size, size * 1.5)
                    esp.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    esp.Box.Color = color
                else
                    esp.Box.Visible = false
                end

                -- TRACER
                if toggles.Tracers then
                    esp.Line.Visible = true
                    esp.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.Line.To = Vector2.new(pos.X, pos.Y)
                    esp.Line.Color = color
                else
                    esp.Line.Visible = false
                end

                -- TEXT
                local textLines = {}

                if toggles.Names then
                    table.insert(textLines, plr.Name)
                end

                if toggles.Distance then
                    table.insert(textLines, math.floor(dist) .. "m")
                end

                if toggles.HP then
                    table.insert(textLines, math.floor(hum.Health) .. " HP")
                end

                if #textLines > 0 then
                    esp.Text.Visible = true
                    esp.Text.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    esp.Text.Color = color
                    esp.Text.Text = table.concat(textLines, " | ")
                else
                    esp.Text.Visible = false
                end

            else
                esp.Box.Visible = false
                esp.Line.Visible = false
                esp.Text.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Line.Visible = false
            esp.Text.Visible = false
        end
    end
end)

--// SIMPLE TOGGLES (NO UI STRESS)
local function toggleButton(name, key, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 28)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35,35,40)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Parent = frame

    b.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        b.BackgroundColor3 = toggles[key] and Color3.fromRGB(0,170,80) or Color3.fromRGB(35,35,40)
    end)
end

toggleButton("ESP", "ESP", 10)
toggleButton("Boxes", "Boxes", 45)
toggleButton("Tracers", "Tracers", 80)
toggleButton("Names", "Names", 115)
toggleButton("Distance", "Distance", 150)
toggleButton("HP", "HP", 185)
