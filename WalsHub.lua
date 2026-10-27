-- Pegar en WalsHub_v3.lua justo ANTES de la línea:  selectTab(tPlayer)

state.eggRange = 50
local tEgg = addTab("Egg")
addSection(tEgg, "Huevos")
addToggle(tEgg, "Auto romper / robar", "eggAuto")
addSelector(tEgg, "Radio de búsqueda", { 20, 50, 100, 200 }, 50, function(v) state.eggRange = v end)

local KEYWORDS = { "egg", "huevo", "steal", "robar", "break", "romper", "crack" }

local function matches(p)
    local text = string.lower((p.ActionText or "") .. " " .. (p.ObjectText or "") .. " " .. p.Parent.Name)
    for _, k in ipairs(KEYWORDS) do
        if string.find(text, k, 1, true) then return true end
    end
    return false
end

local prompts, lastScan = {}, 0
local function scan()
    prompts = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and matches(d) then
            table.insert(prompts, d)
        end
    end
    lastScan = os.clock()
end

task.spawn(function()
    while gui.Parent do
        task.wait(0.25)
        if state.eggAuto and fireproximityprompt then
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if os.clock() - lastScan > 3 then scan() end
                local best, bestDist
                for _, p in ipairs(prompts) do
                    local part = p.Parent
                    if p.Enabled and part and part:IsA("BasePart") then
                        local d = (part.Position - hrp.Position).Magnitude
                        if d <= state.eggRange and (not bestDist or d < bestDist) then
                            best, bestDist = p, d
                        end
                    end
                end
                if best then
                    if bestDist > best.MaxActivationDistance - 2 then
                        hrp.CFrame = best.Parent.CFrame + Vector3.new(0, 3, 0)
                    end
                    best.HoldDuration = 0
                    fireproximityprompt(best)
                end
            end
        end
    end
end)-- Wals Hub (Delta)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local lp = Players.LocalPlayer
local parent = (gethui and gethui()) or game:GetService("CoreGui")

local state = { speedOn = false, speed = 50, infJump = false, noclip = false, esp = false }

-- Scripts por juego (los que ya tenías)
local SCRIPTS = {
    [10563114921] = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/StealAnEggg",
    [10035204815] = "https://api.luarmor.net/files/v4/loaders/0dbcaa9e992477523d38a8284d7dbdef.lua",
    [10690360998] = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/JumpForAnimals",
    [7709344486]  = "https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/Steal-a-Brainrot",
    [66654135]    = "https://api.luarmor.net/files/v4/loaders/2bf348894416e1d3deee40be756d42ff.lua",
    [1686885941]  = "https://api.luarmor.net/files/v4/loaders/89190a03fd337349cef140d576357ba3.lua",
}

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Wals Hub", Text = text, Duration = 3 })
    end)
end

local function loadGameScript()
    local url = SCRIPTS[game.GameId]
    if not url then return notify("Juego no soportado") end
    local ok, src = pcall(game.HttpGet, game, url)
    local fn = ok and type(src) == "string" and loadstring(src)
    if fn then fn() else notify("Error al cargar") end
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "WalsHub"
gui.ResetOnSpawn = false
gui.Parent = parent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 330)
main.Position = UDim2.new(0.5, -115, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(110, 60, 220)
header.Text = "Wals Hub"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 18
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local list = Instance.new("Frame")
list.Size = UDim2.new(1, -16, 1, -46)
list.Position = UDim2.new(0, 8, 0, 42)
list.BackgroundTransparency = 1
list.Parent = main
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 6)

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 30, 0, 30)
mini.Position = UDim2.new(1, -34, 0, 3)
mini.BackgroundTransparency = 1
mini.Text = "–"
mini.TextColor3 = Color3.new(1, 1, 1)
mini.TextSize = 22
mini.Font = Enum.Font.GothamBold
mini.Parent = main
mini.MouseButton1Click:Connect(function()
    list.Visible = not list.Visible
    main.Size = list.Visible and UDim2.new(0, 230, 0, 330) or UDim2.new(0, 230, 0, 36)
end)

-- Arrastrar (mouse y táctil)
do
    local dragging, startPos, startInput
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startPos, startInput = true, main.Position, i.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local function button(text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 15
    b.Parent = list
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() cb(b) end)
    return b
end

local function toggle(text, key, onChange)
    button(text .. ": OFF", function(b)
        state[key] = not state[key]
        b.Text = text .. (state[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = state[key] and Color3.fromRGB(110, 60, 220) or Color3.fromRGB(40, 40, 52)
        if onChange then onChange(state[key]) end
    end)
end

-- Funciones
toggle("Velocidad", "speedOn")
button("Velocidad: 50 (toca para cambiar)", function(b)
    state.speed = state.speed >= 150 and 30 or state.speed + 20
    b.Text = "Velocidad: " .. state.speed .. " (toca para cambiar)"
end)
toggle("Salto infinito", "infJump")
toggle("Noclip", "noclip")

local highlights = {}
local function clearESP()
    for _, h in pairs(highlights) do h:Destroy() end
    highlights = {}
end
local function applyESP()
    clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(110, 60, 220)
            h.Parent = p.Character
            table.insert(highlights, h)
        end
    end
end
toggle("ESP jugadores", "esp", function(on)
    if on then applyESP() else clearESP() end
end)
task.spawn(function()
    while task.wait(3) do
        if state.esp then applyESP() end
    end
end)

button("Cargar script del juego", function() loadGameScript() end)

-- Lógica
local function humanoid()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

RS.Heartbeat:Connect(function()
    local h = humanoid()
    if h and state.speedOn then h.WalkSpeed = state.speed end
end)

RS.Stepped:Connect(function()
    if state.noclip and lp.Character then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    local h = humanoid()
    if state.infJump and h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Anti-AFK
lp.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

notify("Wals Hub cargado")
