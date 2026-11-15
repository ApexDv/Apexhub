-- =====================================================
-- APEX HUB - UNIVERSAL SILENT AIM + ESP
-- Compatível com R6 / R15 / Custom Rigs
-- =====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- CONFIGURAÇÕES
-- =====================================================
local Settings = {
    Enabled = true,
    FOVRadius = 200,
    TargetPart = "Auto",  -- "Auto" = escolhe a melhor parte
    HitChance = 100,
    SilentAimRange = 1500,
    VisibleCheck = false,
    TeamCheck = true,
    FriendCheck = true,
    ForceFieldCheck = true,
    TargetTeams = {},
    ShowFOV = true,
    FOVColor = Color3.fromRGB(120, 60, 255),
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(255, 80, 80),
    ESPTargetColor = Color3.fromRGB(80, 255, 120),
    ESPNamesEnabled = true,
    -- Universal extras
    WallCheck = false,
    PredictionEnabled = false,
    PredictionAmount = 0.15,
    UseHRPAlways = false,
}

local currentTarget = nil
local currentTargetPlr = nil

-- =====================================================
-- DETECÇÃO DE RIG / PARTE DO CORPO
-- =====================================================
local function getBestPart(char)
    if not char then return nil end
    -- Se o usuário escolheu uma parte específica
    if Settings.TargetPart ~= "Auto" then
        local p = char:FindFirstChild(Settings.TargetPart)
        if p then return p end
    end
    -- Auto: tenta Head > UpperTorso > Torso > HumanoidRootPart
    local order = {"Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso"}
    for _, name in ipairs(order) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            return p
        end
    end
    return nil
end

-- =====================================================
-- CHECAGEM DE TIME (funciona mesmo sem Team)
-- =====================================================
local function checkTeam(plr)
    if not Settings.TeamCheck then return true end
    if LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then
        return false
    end
    if plr.Team and Settings.TargetTeams then
        local hasSel = false
        for _ in pairs(Settings.TargetTeams) do hasSel = true break end
        if hasSel and not Settings.TargetTeams[plr.Team.Name] then
            return false
        end
    end
    return true
end

-- =====================================================
-- VISIBILIDADE
-- =====================================================
local function isVisible(targetChar)
    if not Settings.VisibleCheck then return true end
    local tHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not tHRP then return false end
    local char = LocalPlayer.Character
    local lHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not lHRP then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    local res = workspace:Raycast(tHRP.Position, lHRP.Position - tHRP.Position, params)
    return res == nil
end

-- =====================================================
-- VALIDAÇÃO
-- =====================================================
local function isValidTarget(plr)
    if plr == LocalPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local part = getBestPart(plr.Character)
    if not part then return false end
    if not checkTeam(plr) then return false end
    if Settings.FriendCheck and LocalPlayer:IsFriendsWith(plr.UserId) then return false end
    if Settings.ForceFieldCheck and plr.Character:FindFirstChildOfClass("ForceField") then return false end
    local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if lRoot then
        local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
        if tRoot and (tRoot.Position - lRoot.Position).Magnitude > Settings.SilentAimRange then
            return false
        end
    end
    if not isVisible(plr.Character) then return false end
    return true
end

-- =====================================================
-- GET TARGET
-- =====================================================
local function getTarget()
    if not Settings.Enabled then return nil, nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestPlr = nil, nil
    local shortestDist = Settings.FOVRadius

    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = getBestPart(plr.Character)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        closest, closestPlr = part, plr
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closest, closestPlr
end

-- =====================================================
-- ESP
-- =====================================================
local function aplicarESP(plr, isTarget)
    local char = plr.Character
    if not char then return end
    local cor = isTarget and Settings.ESPTargetColor or Settings.ESPColor
    local h = char:FindFirstChild("ApexESP")
    if not h then
        h = Instance.new("Highlight")
        h.Name = "ApexESP"
        h.Parent = char
    end
    h.FillColor = cor
    h.OutlineColor = cor
    h.FillTransparency = isTarget and 0.4 or 0.7
    local head = char:FindFirstChild("Head")
    if head and Settings.ESPNamesEnabled then
        local b = head:FindFirstChild("ApexNameESP")
        if not b then
            b = Instance.new("BillboardGui")
            b.Name = "ApexNameESP"
            b.Size = UDim2.new(0, 200, 0, 30)
            b.StudsOffset = Vector3.new(0, 1.5, 0)
            b.AlwaysOnTop = true
            b.Parent = head
            local lbl = Instance.new("TextLabel")
            lbl.Name = "Label"
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextStrokeTransparency = 0
            lbl.Parent = b
        end
        local lbl = b:FindFirstChild("Label")
        if lbl then
            lbl.Text = plr.Name
            lbl.TextColor3 = cor
            lbl.TextSize = 13
        end
    end
end

local function limparESP(plr)
    local char = plr.Character
    if not char then return end
    local h = char:FindFirstChild("ApexESP")
    if h then h:Destroy() end
    local head = char:FindFirstChild("Head")
    if head then
        local b = head:FindFirstChild("ApexNameESP")
        if b then b:Destroy() end
    end
end

-- =====================================================
-- FOV CIRCLE
-- =====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHubFOV"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui
Instance.new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = FOVCircle })
local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Settings.FOVColor
CircleStroke.Thickness = 1.5
CircleStroke.Parent = FOVCircle

-- =====================================================
-- LOOP
-- =====================================================
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
    CircleStroke.Color = Settings.FOVColor

    local t, tPlr = getTarget()
    currentTarget, currentTargetPlr = t, tPlr

    if Settings.ESPEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                aplicarESP(plr, plr == currentTargetPlr)
            end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            limparESP(plr)
        end
    end
end)

-- =====================================================
-- HOOK SILENT AIM (UNIVERSAL)
-- =====================================================
local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {3, {"Instance","Ray","table","boolean","boolean"}},
    FindPartOnRayWithWhitelist = {3, {"Instance","Ray","table","boolean"}},
    FindPartOnRay = {2, {"Instance","Ray","Instance","boolean","boolean"}},
    Raycast = {3, {"Instance","Vector3","Vector3","RaycastParams"}},
}

local function ValidateArguments(Args, M)
    local m = 0
    if #Args < M[1] then return false end
    for i, a in next, Args do
        if typeof(a) == M[2][i] then m = m + 1 end
    end
    return m >= M[1]
end

local function tryOriginDir(Method, Args)
    if Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist" or Method == "FindPartOnRay" then
        local r = Args[2]
        if typeof(r) == "Ray" then return r.Origin, r.Direction end
    elseif Method == "Raycast" then
        if typeof(Args[2]) == "Vector3" and typeof(Args[3]) == "Vector3" then
            return Args[2], Args[3]
        end
    end
    return nil, nil
end

local function isLocalShooting(Args, Method, Origin, Dir)
    local LChar = LocalPlayer.Character
    if not LChar then return false end
    if Dir and Dir.Magnitude < 20 then return false end
    if Origin and (Origin - Camera.CFrame.Position).Magnitude <= 6 then return true end
    local ignore
    if Method == "Raycast" then
        local p = Args[4]
        if typeof(p) == "RaycastParams" then ignore = p.FilterDescendantsInstances end
    elseif Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay" then
        if typeof(Args[3]) == "table" then ignore = Args[3] end
    end
    if ignore then
        for _, i in next, ignore do
            if i == LChar then return true end
        end
    end
    return false
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Args = {...}
    if Args[1] == workspace and not checkcaller() then
        local O, D = tryOriginDir(Method, Args)
        if O and D and isLocalShooting(Args, Method, O, D) then
            if Settings.Enabled and currentTarget and currentTarget.Parent then
                if math.random(1, 100) <= Settings.HitChance then
                    local newDir = (currentTarget.Position - O).Unit * D.Magnitude
                    if Method == "FindPartOnRayWithIgnoreList" and ValidateArguments(Args, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                        Args[2] = Ray.new(O, newDir)
                    elseif Method == "FindPartOnRayWithWhitelist" and ValidateArguments(Args, ExpectedArguments.FindPartOnRayWithWhitelist) then
                        Args[2] = Ray.new(O, newDir)
                    elseif Method == "FindPartOnRay" and ValidateArguments(Args, ExpectedArguments.FindPartOnRay) then
                        Args[2] = Ray.new(O, newDir)
                    elseif Method == "Raycast" and ValidateArguments(Args, ExpectedArguments.Raycast) then
                        Args[3] = newDir
                    end
                end
            end
            local rets = table.pack(oldNamecall(unpack(Args)))
            return table.unpack(rets, 1, rets.n)
        end
    end
    return oldNamecall(...)
end))

-- =====================================================
-- APEX HUB GUI
-- =====================================================
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    return o
end

local Theme = {
    BG = Color3.fromRGB(15, 15, 20),
    Panel = Color3.fromRGB(24, 22, 32),
    Card = Color3.fromRGB(32, 30, 42),
    Accent = Color3.fromRGB(140, 60, 255),
    Accent2 = Color3.fromRGB(80, 120, 255),
    Text = Color3.fromRGB(235, 235, 245),
    Sub = Color3.fromRGB(150, 145, 170),
    Stroke = Color3.fromRGB(55, 50, 70),
    Danger = Color3.fromRGB(255, 70, 100),
}

local GUI = New("ScreenGui", {
    Name = "ApexHubGUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
    Parent = LocalPlayer:WaitForChild("PlayerGui")
})

local Main = New("Frame", {
    Size = UDim2.fromOffset(430, 500),
    Position = UDim2.new(0.5, -215, 0.5, -250),
    BackgroundColor3 = Theme.BG,
    BorderSizePixel = 0,
    Parent = GUI
})
New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Main })
New("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Parent = Main })

local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    Parent = Main
})
New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Header })
New("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Parent = Header })

New("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(15, 0),
    BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
    Text = "⚡ APEX HUB  |  UNIVERSAL", TextColor3 = Theme.Text, TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
})

local AccentBar = New("Frame", {
    Size = UDim2.fromOffset(3, 22), Position = UDim2.new(0, 6, 0.5, -11),
    BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = Header
})
New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = AccentBar })

local CloseBtn = New("TextButton", {
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -38, 0.5, -15),
    BackgroundColor3 = Theme.Danger, Text = "✕", Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text, TextSize = 14, BorderSizePixel = 0, Parent = Header
})
New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CloseBtn })
CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)

local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local Scroll = New("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -60), Position = UDim2.fromOffset(10, 55),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
    ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Main
})
New("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), Parent = Scroll })
New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Scroll })

local function SectionTitle(t)
    return New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, Text = t, TextColor3 = Theme.Accent,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Scroll
    })
end

local function Toggle(label, getter, setter)
    local c = New("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Parent = Scroll })
    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = c })
    New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = c })
    New("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = label,
        TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = c
    })
    local sw = New("Frame", {
        Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = getter() and Theme.Accent or Theme.Stroke, BorderSizePixel = 0, Parent = c
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
    local knob = New("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = getter() and UDim2.new(1, -20, 0.5, -8) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = sw
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    local b = New("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", Parent = sw })
    b.MouseButton1Click:Connect(function()
        setter(not getter())
        local on = getter()
        TweenService:Create(sw, TweenInfo.new(0.2), { BackgroundColor3 = on and Theme.Accent or Theme.Stroke }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), { Position = on and UDim2.new(1, -20, 0.5, -8) or UDim2.fromOffset(3, 3) }):Play()
    end)
    return c
end

local function Slider(label, mn, mx, getter, setter)
    local c = New("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Parent = Scroll })
    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = c })
    New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = c })
    local lbl = New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18), Position = UDim2.fromOffset(12, 6),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = label .. ": " .. tostring(getter()),
        TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = c
    })
    local track = New("Frame", {
        Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 1, -18),
        BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = c
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    local fill = New("Frame", {
        Size = UDim2.new((getter() - mn) / (mx - mn), 0, 1, 0),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = track
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    local drag = false
    local function upd(x)
        local r = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * r + 0.5)
        fill.Size = UDim2.new(r, 0, 1, 0)
        lbl.Text = label .. ": " .. tostring(v)
        setter(v)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; upd(i.Position.X)
        end
    end)
        UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    return c
end

local function Dropdown(label, opts, getter, setter)
    local c = New("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Parent = Scroll })
    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = c })
    New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = c })
    New("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = label,
        TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = c
    })
    local v = New("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = tostring(getter()),
        TextColor3 = Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = c
    })
    local b = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = c })
    local idx = 1
    for i, o in ipairs(opts) do if o == getter() then idx = i end end
    b.MouseButton1Click:Connect(function()
        idx = idx % #opts + 1
        setter(opts[idx])
        v.Text = tostring(opts[idx])
    end)
    return c
end

-- =====================================================
-- SEÇÕES DA GUI
-- =====================================================

-- SILENT AIM
SectionTitle("⚡ SILENT AIM (Universal)")
Toggle("Ativar Silent Aim", function() return Settings.Enabled end, function(v) Settings.Enabled = v end)
Slider("FOV (Raio)", 20, 600, function() return Settings.FOVRadius end, function(v) Settings.FOVRadius = v end)
Slider("Hit Chance (%)", 0, 100, function() return Settings.HitChance end, function(v) Settings.HitChance = v end)
Slider("Alcance (studs)", 100, 3000, function() return Settings.SilentAimRange end, function(v) Settings.SilentAimRange = v end)
Dropdown("Parte do alvo", {"Auto", "Head", "UpperTorso", "Torso", "HumanoidRootPart"}, function() return Settings.TargetPart end, function(v) Settings.TargetPart = v end)

-- FILTROS
SectionTitle("⚡ FILTROS")
Toggle("Visibilidade", function() return Settings.VisibleCheck end, function(v) Settings.VisibleCheck = v end)
Toggle("Checar Time", function() return Settings.TeamCheck end, function(v) Settings.TeamCheck = v end)
Toggle("Checar Amigos", function() return Settings.FriendCheck end, function(v) Settings.FriendCheck = v end)
Toggle("Checar ForceField", function() return Settings.ForceFieldCheck end, function(v) Settings.ForceFieldCheck = v end)

-- ESP
SectionTitle("⚡ ESP")
Toggle("Ativar ESP", function() return Settings.ESPEnabled end, function(v) Settings.ESPEnabled = v end)
Toggle("Mostrar Nomes", function() return Settings.ESPNamesEnabled end, function(v) Settings.ESPNamesEnabled = v end)

-- VISUAL
SectionTitle("⚡ VISUAL")
Toggle("Mostrar FOV Circle", function() return Settings.ShowFOV end, function(v) Settings.ShowFOV = v end)

-- PREDICTION
SectionTitle("⚡ PREDICTION")
Toggle("Ativar Prediction", function() return Settings.PredictionEnabled end, function(v) Settings.PredictionEnabled = v end)
Slider("Prediction Amount (x100)", 1, 50, function() return math.floor(Settings.PredictionAmount * 100) end, function(v) Settings.PredictionAmount = v / 100 end)

-- =====================================================
-- SISTEMA DE KEYBIND (tecla para abrir/fechar GUI)
-- =====================================================
local guiVisible = true
local KeybindKey = Enum.KeyCode.RightShift

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == KeybindKey then
        guiVisible = not guiVisible
        Main.Visible = guiVisible
        FOVCircle.Visible = guiVisible and Settings.ShowFOV
    end
end)

-- =====================================================
-- BOTÃO DE TOGGLE FLUTUANTE (para reabrir a GUI)
-- =====================================================
local FloatBtn = New("TextButton", {
    Size = UDim2.fromOffset(46, 46),
    Position = UDim2.new(0, 15, 0, 55),
    BackgroundColor3 = Theme.BG,
    Text = "⚡",
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Accent,
    TextSize = 22,
    BorderSizePixel = 0,
    Parent = GUI
})
New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = FloatBtn })
New("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Parent = FloatBtn })

FloatBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    Main.Visible = guiVisible
end)

-- Arrastar botão flutuante
local fDrag, fStart, fPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDrag = true
        fStart = input.Position
        fPos = FloatBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if fDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - fStart
        FloatBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDrag = false
    end
end)

-- =====================================================
-- BOTÃO RESET / UNLOAD
-- =====================================================
local ResetBtn = New("TextButton", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Theme.Danger,
    Text = "✕ Descarregar Apex Hub",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13,
    BorderSizePixel = 0,
    Parent = Scroll
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ResetBtn })
ResetBtn.MouseButton1Click:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local h = char:FindFirstChild("ApexESP")
            if h then h:Destroy() end
            local head = char:FindFirstChild("Head")
            if head then
                local b = head:FindFirstChild("ApexNameESP")
                if b then b:Destroy() end
            end
        end
    end
    if GUI then GUI:Destroy() end
    if ScreenGui then ScreenGui:Destroy() end
    if oldNamecall then
        hookmetamethod(game, "__namecall", oldNamecall)
    end
end)

print("[Apex Hub] Carregado ✓ Universal Mode | Keybind: RightShift para abrir/fechar")
