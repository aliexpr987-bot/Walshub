-- Wals Hub v3 Premium (Delta)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TeleportService")
local Tween = game:GetService("TweenService")
local lp = Players.LocalPlayer
local parent = (gethui and gethui()) or game:GetService("CoreGui")

-- Paleta
local PURPLE = Color3.fromRGB(124, 58, 237)
local PINK = Color3.fromRGB(236, 72, 153)
local CYAN = Color3.fromRGB(34, 211, 238)
local GREEN = Color3.fromRGB(16, 240, 160)
local BG = Color3.fromRGB(13, 13, 22)
local PANEL = Color3.fromRGB(20, 20, 34)
local ROW = Color3.fromRGB(30, 30, 48)
local ROW_HOVER = Color3.fromRGB(42, 42, 66)
local GREY = Color3.fromRGB(62, 62, 86)
local WHITE = Color3.new(1, 1, 1)
local GRAD = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PURPLE),
    ColorSequenceKeypoint.new(0.5, PINK),
    ColorSequenceKeypoint.new(1, CYAN),
})
local GRAD2 = ColorSequence.new(PURPLE, PINK)

local state = { speedOn = false, speed = 50, infJump = false, noclip = false, esp = false, afk = true }
local connections = {}
local highlights = {}
local spinners = {}

-- Scripts por juego
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

-- Helpers
local function new(class, props, par)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = par
    return o
end
local function round(o, r)
    new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o)
end
local function tween(o, t, props, style, dir)
    local tw = Tween:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end
local function gradient(o, seq, rot)
    return new("UIGradient", { Color = seq or GRAD, Rotation = rot or 0 }, o)
end
local function spin(g, speed)
    table.insert(spinners, { g = g, s = speed or 40 })
end

-- Ventana principal
local gui = new("ScreenGui", { Name = "WalsHub", ResetOnSpawn = false }, parent)
local main = new("Frame", {
    Size = UDim2.new(0, 480, 0, 280),
    Position = UDim2.new(0.5, -240, 0.5, -140),
    BackgroundColor3 = BG, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
round(main, 12)
local scale = new("UIScale", { Scale = 0.6 }, main)

local mainStroke = new("UIStroke", { Color = WHITE, Thickness = 2 }, main)
spin(gradient(mainStroke, GRAD), 60)

local header = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    Text = "WALS HUB", TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextSize = 18,
}, main)
round(header, 12)
spin(gradient(header, GRAD), 35)

local function headerBtn(text, x, size)
    local b = new("TextButton", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, x, 0, 3),
        BackgroundTransparency = 1, Text = text, TextColor3 = WHITE,
        Font = Enum.Font.GothamBold, TextSize = size,
    }, header)
    b.MouseEnter:Connect(function() tween(b, 0.15, { TextTransparency = 0.4 }) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, { TextTransparency = 0 }) end)
    return b
end
local closeBtn = headerBtn("X", -34, 16)
local miniBtn = headerBtn("–", -66, 22)

local body = new("Frame", {
    Size = UDim2.new(1, 0, 1, -36), Position = UDim2.new(0, 0, 0, 36), BackgroundTransparency = 1,
}, main)

local tabBar = new("ScrollingFrame", {
    Size = UDim2.new(0, 112, 1, -10), Position = UDim2.new(0, 6, 0, 5),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, body)
new("UIListLayout", { Padding = UDim.new(0, 6) }, tabBar)

local content = new("Frame", {
    Size = UDim2.new(1, -130, 1, -10), Position = UDim2.new(0, 124, 0, 5),
    BackgroundColor3 = PANEL, BorderSizePixel = 0,
}, body)
round(content, 10)

local search = new("TextBox", {
    Size = UDim2.new(1, -12, 0, 30), Position = UDim2.new(0, 6, 0, 6),
    BackgroundColor3 = ROW, BorderSizePixel = 0, Text = "", PlaceholderText = "Buscar función...",
    PlaceholderColor3 = Color3.fromRGB(140, 140, 170), TextColor3 = WHITE,
    Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = false,
}, content)
round(search, 8)
local searchStroke = new("UIStroke", { Color = GREY, Thickness = 1.5 }, search)
search.Focused:Connect(function() tween(searchStroke, 0.2, { Color = PINK }) end)
search.FocusLost:Connect(function() tween(searchStroke, 0.2, { Color = GREY }) end)

local pagesHolder = new("Frame", {
    Size = UDim2.new(1, -12, 1, -48), Position = UDim2.new(0, 6, 0, 42), BackgroundTransparency = 1,
}, content)

-- Pestañas
local pages, tabs, current = {}, {}, nil

local function applySearch()
    if not current then return end
    local q = string.lower(search.Text)
    for _, r in ipairs(pages[current].rows) do
        r.frame.Visible = q == "" or string.find(string.lower(r.name), q, 1, true) ~= nil
    end
end

local function selectTab(name)
    current = name
    for n, p in pairs(pages) do
        local on = (n == name)
        p.group.Visible = on
        if on then
            p.group.GroupTransparency = 1
            tween(p.group, 0.3, { GroupTransparency = 0 })
        end
        tween(tabs[n].fill, 0.25, { BackgroundTransparency = on and 0 or 1 })
    end
    applySearch()
end
search:GetPropertyChangedSignal("Text"):Connect(applySearch)

local function addTab(name)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = ROW, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false,
    }, tabBar)
    round(b, 8)
    local fill = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 1, BorderSizePixel = 0,
    }, b)
    round(fill, 8)
    spin(gradient(fill, GRAD), 50)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = name,
        TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 14,
    }, b)

    local group = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
    }, pagesHolder)
    local f = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = PINK, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, group)
    new("UIListLayout", { Padding = UDim.new(0, 6) }, f)

    pages[name] = { group = group, frame = f, rows = {} }
    tabs[name] = { button = b, fill = fill }
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    return name
end

-- Filas
local function addRow(tab, name)
    local fr = new("Frame", {
        Size = UDim2.new(1, -8, 0, 38), BackgroundColor3 = ROW, BorderSizePixel = 0,
    }, pages[tab].frame)
    round(fr, 8)
    new("UIStroke", { Color = GREY, Thickness = 1, Transparency = 0.6 }, fr)
    new("TextLabel", {
        Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, fr)
    fr.MouseEnter:Connect(function() tween(fr, 0.15, { BackgroundColor3 = ROW_HOVER }) end)
    fr.MouseLeave:Connect(function() tween(fr, 0.15, { BackgroundColor3 = ROW }) end)
    table.insert(pages[tab].rows, { frame = fr, name = name })
    return fr
end

local function addSection(tab, text)
    local l = new("TextLabel", {
        Size = UDim2.new(1, -8, 0, 24), BackgroundTransparency = 1, Text = text,
        TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, pages[tab].frame)
    gradient(l, GRAD)
    table.insert(pages[tab].rows, { frame = l, name = "" })
end

local function gradButton(fr, text, w)
    local b = new("TextButton", {
        Size = UDim2.new(0, w, 0, 26), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -(w / 2 + 10), 0.5, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        Text = text, TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
    }, fr)
    round(b, 7)
    gradient(b, GRAD2, 0)
    return b
end

local function pop(b, w)
    b.Size = UDim2.new(0, w + 8, 0, 30)
    tween(b, 0.3, { Size = UDim2.new(0, w, 0, 26) }, Enum.EasingStyle.Back)
end

local function addToggle(tab, name, key, onChange)
    local fr = addRow(tab, name)
    local sw = new("Frame", {
        Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = GREY, BorderSizePixel = 0,
    }, fr)
    round(sw, 12)
    local glow = new("UIStroke", { Color = GREEN, Thickness = 2, Transparency = 1 }, sw)
    local knob = new("Frame", {
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, sw)
    round(knob, 9)
    local function render(animate)
        local on = state[key]
        local t = animate and 0.25 or 0
        tween(sw, t, { BackgroundColor3 = on and GREEN or GREY })
        tween(glow, t, { Transparency = on and 0.3 or 1 })
        tween(knob, t, { Position = on and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3) }, Enum.EasingStyle.Back)
    end
    local hit = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, fr)
    hit.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        render(true)
        if onChange then onChange(state[key]) end
    end)
    render(false)
end

local function addSelector(tab, name, options, default, onChange)
    local fr = addRow(tab, name)
    local idx = table.find(options, default) or 1
    local b = gradButton(fr, tostring(options[idx]) .. "  ▾", 90)
    b.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        b.Text = tostring(options[idx]) .. "  ▾"
        pop(b, 90)
        onChange(options[idx])
    end)
end

local function addButton(tab, name, cb)
    local fr = addRow(tab, name)
    local b = gradButton(fr, "Ejecutar", 90)
    b.MouseButton1Click:Connect(function()
        pop(b, 90)
        cb()
    end)
end

-- ESP
local function clearESP()
    for _, h in pairs(highlights) do h:Destroy() end
    highlights = {}
end
local function applyESP()
    clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local h = new("Highlight", { FillColor = PINK, OutlineColor = CYAN, FillTransparency = 0.5 }, p.Character)
            table.insert(highlights, h)
        end
    end
end

-- Contenido
local tPlayer = addTab("Player")
local tVisual = addTab("Visual")
local tGames = addTab("Games")
local tMisc = addTab("Misc")
local tSettings = addTab("Settings")

addSection(tPlayer, "Movimiento")
addToggle(tPlayer, "Velocidad", "speedOn")
addSelector(tPlayer, "Valor de velocidad", { 30, 50, 80, 120, 150 }, 50, function(v) state.speed = v end)
addToggle(tPlayer, "Salto infinito", "infJump")
addToggle(tPlayer, "Noclip", "noclip")

addSection(tVisual, "Jugadores")
addToggle(tVisual, "ESP jugadores", "esp", function(on)
    if on then applyESP() else clearESP() end
end)

addSection(tGames, "Scripts por juego")
addButton(tGames, SCRIPTS[game.GameId] and "Cargar script del juego" or "Juego no soportado", loadGameScript)

addSection(tMisc, "Utilidades")
addToggle(tMisc, "Anti-AFK", "afk")
addButton(tMisc, "Reconectar", function() TS:Teleport(game.PlaceId, lp) end)

addSection(tSettings, "Wals Hub")
local destroyHub
addButton(tSettings, "Cerrar el hub", function() destroyHub() end)

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
end)

selectTab(tPlayer)

-- Minimizar y cerrar (animados)
local minimized = false
miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if not minimized then body.Visible = true end
    local tw = tween(main, 0.3, {
        Size = minimized and UDim2.new(0, 480, 0, 36) or UDim2.new(0, 480, 0, 280),
    }, Enum.EasingStyle.Back)
    if minimized then
        tw.Completed:Connect(function() if minimized then body.Visible = false end end)
    end
end)

destroyHub = function()
    local tw = tween(scale, 0.25, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tw.Completed:Connect(function()
        clearESP()
        for _, c in ipairs(connections) do c:Disconnect() end
        gui:Destroy()
    end)
end
closeBtn.MouseButton1Click:Connect(function() destroyHub() end)

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
    table.insert(connections, UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end

-- Lógica
local function humanoid()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- Degradados animados
table.insert(connections, RS.RenderStepped:Connect(function()
    local t = os.clock()
    for _, s in ipairs(spinners) do
        s.g.Rotation = (t * s.s) % 360
    end
end))

table.insert(connections, RS.Heartbeat:Connect(function()
    local h = humanoid()
    if h and state.speedOn then h.WalkSpeed = state.speed end
end))

table.insert(connections, RS.Stepped:Connect(function()
    if state.noclip and lp.Character then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

table.insert(connections, UIS.JumpRequest:Connect(function()
    local h = humanoid()
    if state.infJump and h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

table.insert(connections, lp.Idled:Connect(function()
    if not state.afk then return end
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end))

task.spawn(function()
    while gui.Parent do
        task.wait(3)
        if state.esp then applyESP() end
    end
end)

-- Animación de entrada
tween(scale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
notify("Wals Hub cargado")
