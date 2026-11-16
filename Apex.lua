local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:AddTheme({
    Name = "Amber",
    Primary = Color3.fromHex("#F59E0B"),
    White   = Color3.new(1, 1, 1),
    Black   = Color3.new(0, 0, 0),
    Dialog     = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    BackgroundTransparency = 0,
    Hover = Color3.fromHex("#FFFFFF"),
    PanelBackground = Color3.new(1, 1, 1),
    PanelBackgroundTransparency = 0.95,
    WindowBackground = Color3.fromHex("#101010"),
    WindowShadow = Color3.new(0, 0, 0),
    WindowTopbarTitle  = Color3.fromHex("#FFFFFF"),
    WindowTopbarAuthor = Color3.fromHex("#FFFFFF"),
    WindowTopbarIcon   = Color3.fromHex("#a1a1aa"),
    WindowTopbarButtonIcon = Color3.fromHex("#a1a1aa"),
    WindowSearchBarBackground = Color3.fromHex("#101010"),
    TabBackground = Color3.fromHex("#FFFFFF"),
    TabBackgroundHover = Color3.fromHex("#FFFFFF"),
    TabBackgroundHoverTransparency = 0.97,
    TabBackgroundActive = Color3.fromHex("#FFFFFF"),
    TabBackgroundActiveTransparency = 0.93,
    TabText = Color3.fromHex("#FFFFFF"),
    TabTextTransparency = 0.3,
    TabTextTransparencyActive = 0,
    TabTitle = Color3.fromHex("#FFFFFF"),
    TabIcon  = Color3.fromHex("#a1a1aa"),
    TabIconTransparency = 0.4,
    TabIconTransparencyActive = 0.1,
    TabBorderTransparency = 1,
    TabBorderTransparencyActive = 0.75,
    TabBorder = Color3.new(1, 1, 1),
    ElementBackground = Color3.fromHex("#FFFFFF"),
    ElementBackgroundTransparency = 0.93,
    ElementBackgroundHover = Color3.fromHex("#2a2a2a"),
    ElementTitle = Color3.fromHex("#FFFFFF"),
    ElementDesc  = Color3.fromHex("#FFFFFF"),
    ElementIcon  = Color3.fromHex("#a1a1aa"),
    PopupBackground = Color3.fromHex("#101010"),
    PopupBackgroundTransparency = 0,
    PopupTitle   = Color3.fromHex("#FFFFFF"),
    PopupContent = Color3.fromHex("#FFFFFF"),
    PopupIcon    = Color3.fromHex("#a1a1aa"),
    DialogBackground = Color3.fromHex("#101010"),
    DialogBackgroundTransparency = 0,
    DialogTitle   = Color3.fromHex("#FFFFFF"),
    DialogContent = Color3.fromHex("#FFFFFF"),
    DialogIcon    = Color3.fromHex("#a1a1aa"),
    Toggle    = Color3.fromHex("#52525b"),
    ToggleBar = Color3.new(1, 1, 1),
    Checkbox = Color3.fromHex("#F59E0B"),
    CheckboxIcon = Color3.new(1, 1, 1),
    CheckboxBorder = Color3.new(1, 1, 1),
    CheckboxBorderTransparency = 0.75,
    SliderIcon = Color3.fromHex("#a1a1aa"),
    Slider     = Color3.fromHex("#F59E0B"),
    SliderThumb = Color3.new(1, 1, 1),
    SliderIconFrom = Color3.fromHex("#a1a1aa"),
    SliderIconTo   = Color3.fromHex("#a1a1aa"),
    Tooltip = Color3.fromHex("#4C4C4C"),
    TooltipText = Color3.new(1, 1, 1),
    TooltipSecondary = Color3.fromHex("#F59E0B"),
    TooltipSecondaryText = Color3.new(1, 1, 1),
    TabSectionIcon = Color3.fromHex("#a1a1aa"),
    SectionIcon    = Color3.fromHex("#a1a1aa"),
    SectionExpandIcon = Color3.new(1, 1, 1),
    SectionExpandIconTransparency = 0.4,
    SectionBox = Color3.new(1, 1, 1),
    SectionBoxTransparency = 0.95,
    SectionBoxBorder = Color3.new(1, 1, 1),
    SectionBoxBorderTransparency = 0.75,
    SectionBoxBackground = Color3.new(1, 1, 1),
    SectionBoxBackgroundTransparency = 0.95,
    SearchBarBorder = Color3.new(1, 1, 1),
    SearchBarBorderTransparency = 0.75,
    Notification = Color3.fromHex("#101010"),
    NotificationTitle   = Color3.fromHex("#FFFFFF"),
    NotificationTitleTransparency = 0,
    NotificationContent = Color3.fromHex("#FFFFFF"),
    NotificationContentTransparency = 0.4,
    NotificationDuration = Color3.new(1, 1, 1),
    NotificationDurationTransparency = 0.95,
    NotificationBorder = Color3.new(1, 1, 1),
    NotificationBorderTransparency = 0.75,
    DropdownTabBorder = Color3.new(1, 1, 1),
    LabelBackground = Color3.new(1, 1, 1),
    LabelBackgroundTransparency = 0.95,
})

local Window = WindUI:CreateWindow({
    Title = "Opções",
    Folder = "ApexHub",
    Theme = "Amber",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    SideBarWidth = 180,
    HasOutline = false,
})

-- Aba do Silent Aim (Fantasminha)
local TabSilent = Window:Tab({ 
    Title = "", 
    Desc = "", 
    Icon = "lucide:ghost", 
    ShowTabTitle = false 
})

-- Aqui começa o seu código original (com a adição do Visible Check Azul)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Enabled = false, -- Começa desativado
    FOVRadius = 150,
    TargetPart = "Head",
    HitChance = 100,
    SilentAimRange = 1000,
    VisibleCheck = false,
    DelayMin = 0.05,
    DelayMax = 0.15,
}

local currentTarget = nil
local HighlightsFolder = Instance.new("Folder")
HighlightsFolder.Name = "SilentHighlights"
HighlightsFolder.Parent = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSilentAim"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(65, 145, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Parent = FOVCircle

local function randomDelay()
    local d = Settings.DelayMin + math.random() * (Settings.DelayMax - Settings.DelayMin)
    task.wait(d)
end

local function isVisible(targetCharacter)
    if not Settings.VisibleCheck then return true end
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return false end
    local char = LocalPlayer.Character
    local localHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not localHRP then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    local result = workspace:Raycast(targetHRP.Position, localHRP.Position - targetHRP.Position, params)
    return result == nil
end

local function isValidTarget(plr)
    if plr == LocalPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRoot and (hrp.Position - localRoot.Position).Magnitude > Settings.SilentAimRange then return false end
    if not isVisible(plr.Character) then return false end
    return true
end

local function getTarget()
    if not Settings.Enabled then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest = nil
    local shortestDist = Settings.FOVRadius
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = plr.Character:FindFirstChild(Settings.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        closest = part
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

-- LOOP PRINCIPAL (FOV + VISIBLE CHECK AZUL)
RunService.RenderStepped:Connect(function()
    FOVCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
    FOVCircle.Visible = Settings.Enabled -- Só mostra o FOV se estiver ativado
    
    pcall(function()
        currentTarget = getTarget()
    end)

    -- Limpa os highlights antigos
    for _, highlight in ipairs(HighlightsFolder:GetChildren()) do
        highlight:Destroy()
    end

    -- Se o Visible Check estiver ligado e tiver um alvo, marca de AZUL
    if Settings.VisibleCheck and Settings.Enabled and currentTarget and currentTarget.Parent then
        local targetChar = currentTarget.Parent
        local highlight = Instance.new("Highlight")
        highlight.Name = "TargetHighlight"
        highlight.Adornee = targetChar
        highlight.FillColor = Color3.fromRGB(65, 145, 255) -- Azul
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Branco
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = HighlightsFolder
    end
end)

local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = { ArgCountRequired = 3, Args = { "Instance", "Ray", "table", "boolean", "boolean" } },
    FindPartOnRayWithWhitelist = { ArgCountRequired = 3, Args = { "Instance", "Ray", "table", "boolean" } },
    FindPartOnRay = { ArgCountRequired = 2, Args = { "Instance", "Ray", "Instance", "boolean", "boolean" } },
    Raycast = { ArgCountRequired = 3, Args = { "Instance", "Vector3", "Vector3", "RaycastParams" } }
}

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then return false end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then Matches = Matches + 1 end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function tryGetOriginDirection(Method, Arguments)
    if Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist" or Method == "FindPartOnRay" then
        local A_Ray = Arguments[2]
        if typeof(A_Ray) == "Ray" then return A_Ray.Origin, A_Ray.Direction end
    elseif Method == "Raycast" then
        local A_Origin, A_Direction = Arguments[2], Arguments[3]
        if typeof(A_Origin) == "Vector3" and typeof(A_Direction) == "Vector3" then
            return A_Origin, A_Direction
        end
    end
    return nil, nil
end

local function isLocalPlayerShooting(Arguments, Method, Origin, OriginalDirection)
    local LocalChar = LocalPlayer.Character
    if not LocalChar then return false end
    local rayLength = OriginalDirection and OriginalDirection.Magnitude or 0
    if rayLength < 30 then return false end
    if Origin and (Origin - Camera.CFrame.Position).Magnitude <= 5 then return true end
    local ignoreList = nil
    if Method == "Raycast" then
        local params = Arguments[4]
        if typeof(params) == "RaycastParams" then ignoreList = params.FilterDescendantsInstances end
    elseif Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay" then
        if typeof(Arguments[3]) == "table" then ignoreList = Arguments[3] end
    end
    if ignoreList then
        for _, inst in next, ignoreList do
            if inst == LocalChar then return true end
        end
    end
    return false
end

local hookOk, hookErr = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Arguments = {...}
        local self = Arguments[1]

        if self == workspace and not checkcaller() then
            local Origin, Direction = tryGetOriginDirection(Method, Arguments)
            if Origin and Direction and isLocalPlayerShooting(Arguments, Method, Origin, Direction) then
                if Settings.Enabled and currentTarget and currentTarget.Parent then
                    if math.random(1, 100) <= Settings.HitChance then
                        local newDir = (currentTarget.Position - Origin).Unit * Direction.Magnitude
                        if Method == "FindPartOnRayWithIgnoreList" and ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                            Arguments[2] = Ray.new(Origin, newDir)
                        elseif Method == "FindPartOnRayWithWhitelist" and ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
                            Arguments[2] = Ray.new(Origin, newDir)
                        elseif Method == "FindPartOnRay" and ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
                            Arguments[2] = Ray.new(Origin, newDir)
                        elseif Method == "Raycast" and ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                            Arguments[3] = newDir
                        end
                    end
                end
                local rets = table.pack(oldNamecall(unpack(Arguments)))
                return table.unpack(rets, 1, rets.n)
            end
        end
        return oldNamecall(...)
    end))
end)

if hookOk then
    print("[SA] hook instalado")
else
    warn("[SA] hook falhou:", hookErr)
end

_G.SA_randomDelay = randomDelay

-- CONTROLES DO SILENT AIM NA GUI
TabSilent:Toggle({
    Title = "Ativar Silent Aim",
    Desc = "Liga/desliga a mira invisível",
    Icon = "lucide:ghost",
    Flag = "SilentEnabled",
    Value = Settings.Enabled, 
    Callback = function(value)
        Settings.Enabled = value
    end,
})

TabSilent:Toggle({
    Title = "Visible Check",
    Desc = "Marca APENAS o alvo focado de azul",
    Flag = "SilentVisibleCheck",
    Value = Settings.VisibleCheck,
    Callback = function(value)
        Settings.VisibleCheck = value
    end,
})

TabSilent:Dropdown({
    Title = "Parte do Corpo",
    Desc = "Onde a mira vai puxar",
    Flag = "SilentTargetPart",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Value = Settings.TargetPart,
    Callback = function(value)
        Settings.TargetPart = value
    end,
})

TabSilent:Slider({
    Title = "FOV Radius",
    Desc = "Tamanho do círculo de mira",
    Flag = "SilentFOVRadius",
    Value = { Min = 30, Max = 500, Default = Settings.FOVRadius },
    Callback = function(value)
        Settings.FOVRadius = value
    end,
})

TabSilent:Slider({
    Title = "Hit Chance (%)",
    Desc = "Porcentagem de chance de acertar",
    Flag = "SilentHitChance",
    Value = { Min = 0, Max = 100, Default = Settings.HitChance },
    Callback = function(value)
        Settings.HitChance = value
    end,
})

TabSilent:Slider({
    Title = "Alcance (Range)",
    Desc = "Distância máxima para puxar a mira",
    Flag = "SilentRange",
    Value = { Min = 100, Max = 2000, Default = Settings.SilentAimRange },
    Callback = function(value)
        Settings.SilentAimRange = value
    end,
})
