local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Enabled = false,
    FOVRadius = 150,
    TargetPart = "Head",
    HitChance = 100,
    SilentAimRange = 1000,
    VisibleCheck = false,
    TeamCheck = true,
    FriendCheck = true,
    ForceFieldCheck = true,
    TargetTeams = {} -- Vai guardar os times selecionados
}

local currentTarget = nil
local CurrentFOVColor = Color3.fromRGB(65, 145, 255)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHubFOV"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
if not pcall(function() ScreenGui.Parent = game.CoreGui end) then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
CircleStroke.Color = CurrentFOVColor
CircleStroke.Thickness = 1.5
CircleStroke.Parent = FOVCircle

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.fromOffset(50, 50)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(16, 19, 24)
ToggleButton.Text = "Apex"
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = CurrentFOVColor
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = CurrentFOVColor
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Library:Toggle()
end)

local function isVisible(targetCharacter)
    if not Settings.VisibleCheck then return true end
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return false end

    local char = LocalPlayer.Character
    local localHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not localHRP then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character, targetCharacter }

    local result = workspace:Raycast(targetHRP.Position, localHRP.Position - targetHRP.Position, params)
    return result == nil
end

local function isValidTarget(plr)
    if plr == LocalPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end

    -- Lógica de TeamCheck do Prison Life
    if Settings.TeamCheck then
        if LocalPlayer.Team and plr.Team == LocalPlayer.Team then return false end
    end
    
    -- Lógica de TargetTeams (se tiver algum time marcado, só ataca eles)
    if plr.Team and Settings.TargetTeams then
        local hasSelection = false
        for _, _ in pairs(Settings.TargetTeams) do hasSelection = true break end
        
        if hasSelection then
            if not Settings.TargetTeams[plr.Team.Name] then return false end
        end
    end

    if Settings.FriendCheck and LocalPlayer:IsFriendsWith(plr.UserId) then return false end
    if Settings.ForceFieldCheck and plr.Character:FindFirstChildOfClass("ForceField") then return false end

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

RunService.RenderStepped:Connect(function()
    FOVCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
    FOVCircle.Visible = Settings.Enabled
    currentTarget = getTarget()
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
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function tryGetOriginDirection(Method, Arguments)
    if Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist" or Method == "FindPartOnRay" then
        local A_Ray = Arguments[2]
        if typeof(A_Ray) == "Ray" then
            return A_Ray.Origin, A_Ray.Direction
        end
    elseif Method == "Raycast" then
        local A_Origin = Arguments[2]
        local A_Direction = Arguments[3]
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

    if Origin and (Origin - Camera.CFrame.Position).Magnitude <= 5 then
        return true
    end

    local ignoreList = nil
    if Method == "Raycast" then
        local params = Arguments[4]
        if typeof(params) == "RaycastParams" then
            ignoreList = params.FilterDescendantsInstances
        end
    elseif Method == "FindPartOnRayWithIgnoreList" then
        if typeof(Arguments[3]) == "table" then ignoreList = Arguments[3] end
    elseif Method == "FindPartOnRay" then
        if typeof(Arguments[3]) == "table" then ignoreList = Arguments[3] end
    end

    if ignoreList then
        for _, inst in next, ignoreList do
            if inst == LocalChar then return true end
        end
    end
    return false
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = { ... }
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

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
if not isMobile then
    local platform
    pcall(function() platform = UserInputService:GetPlatform() end)
    if platform == Enum.Platform.Android or platform == Enum.Platform.IOS then
        isMobile = true
    end
end

Library.Scheme.AccentColor = CurrentFOVColor
Library.Scheme.BackgroundColor = Color3.fromRGB(10, 12, 16)
Library.Scheme.MainColor = Color3.fromRGB(16, 19, 24)
Library.Scheme.OutlineColor = Color3.fromRGB(35, 65, 105)
Library:UpdateColorsUsingRegistry()

local Window = Library:CreateWindow({
    Title = "Apex Hub",
    Footer = "Apex Hub • Mobile",
    FooterLeft = "v1.0",
    FooterRight = "Apex",
    Icon = "zap",
    Size = isMobile and UDim2.fromOffset(520, 340) or UDim2.fromOffset(640, 480),
    AutoShow = true,
    Center = true,
    Resizable = true,
    CornerRadius = 8,
    Font = Enum.Font.Gotham,
    NotifySide = "Right",
    ToggleKeybind = Enum.KeyCode.RightShift,
    ShowMobileButtons = true,
    MobileButtonsSide = "Right",
    Animations = {
        ToggleWindow = true,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true,
    },
    TabTransitionTime = 0.22,
    TabSwipeFrom = "bottom",
    TabButtonsStyle = {
        Gap = 4,
        Padding = 4,
        CornerRadius = 6,
        Indicator = true,
        IndicatorWidth = 3,
        IndicatorHeight = 18,
    },
})

local MainTab = Window:AddTab({
    Name = "Silent Aim",
    Icon = "crosshair",
    Description = "Configurações do Silent Aim",
})

local VisualTab = Window:AddTab({
    Name = "Visual",
    Icon = "eye",
    Description = "Aparência do FOV",
})

local SettingsTab = Window:AddTab({
    Name = "Settings",
    Icon = "settings",
    Description = "Configurações gerais",
})

local MainGroup = MainTab:AddGroupbox({
    Name = "Main",
    Side = 1,
    IconName = "crosshair",
})

MainGroup:AddToggle("Enabled", {
    Text = "Ativar Silent Aim",
    Default = false,
    Tooltip = "Liga/desliga o silent aim",
    Callback = function(v) Settings.Enabled = v end,
})

MainGroup:AddSlider("FOVRadius", {
    Text = "Raio do FOV",
    Default = 150,
    Min = 25,
    Max = 600,
    Rounding = 0,
    Suffix = " px",
    Tooltip = "Tamanho do círculo de mira",
    Callback = function(v) Settings.FOVRadius = v end,
})

MainGroup:AddSlider("HitChance", {
    Text = "Chance de Acerto",
    Default = 100,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Tooltip = "Probabilidade de aplicar o silent aim",
    Callback = function(v) Settings.HitChance = v end,
})

local TargetGroup = MainTab:AddGroupbox({
    Name = "Alvo",
    Side = 2,
    IconName = "target",
})

TargetGroup:AddDropdown("TargetPart", {
    Text = "Parte do Alvo",
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Tooltip = "Onde mirar no inimigo",
    Callback = function(v) Settings.TargetPart = v end,
})

TargetGroup:AddSlider("SilentAimRange", {
    Text = "Alcance",
    Default = 1000,
    Min = 50,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(v) Settings.SilentAimRange = v end,
})

local CheckGroup = MainTab:AddGroupbox({
    Name = "Verificações",
    Side = 1,
    IconName = "shield-check",
})

CheckGroup:AddToggle("VisibleCheck", {
    Text = "Checar Visibilidade",
    Default = false,
    Tooltip = "Só mira se o alvo estiver visível",
    Callback = function(v) Settings.VisibleCheck = v end,
})

CheckGroup:AddToggle("TeamCheck", {
    Text = "Checar Time",
    Default = true,
    Tooltip = "Ignora jogadores do mesmo time",
    Callback = function(v) Settings.TeamCheck = v end,
})

CheckGroup:AddToggle("FriendCheck", {
    Text = "Checar Amigos",
    Default = true,
    Tooltip = "Ignora amigos",
    Callback = function(v) Settings.FriendCheck = v end,
})

CheckGroup:AddToggle("ForceFieldCheck", {
    Text = "Checar ForceField",
    Default = true,
    Tooltip = "Ignora jogadores com ForceField",
    Callback = function(v) Settings.ForceFieldCheck = v end,
})

-- Lógica de Target Teams (Prison Life)
local TeamsGroup = TargetGroup:AddDropdown("TargetTeams", {
    Text = "Times Alvo",
    Values = { "Inmates", "Guards", "Criminals", "Neutral" },
    Default = {},
    Multi = true,
    Tooltip = "Selecione quais times você quer atacar (deixe vazio para todos)",
    Callback = function(Value)
        Settings.TargetTeams = Value
    end,
})

local VisualGroup = VisualTab:AddGroupbox({
    Name = "FOV",
    Side = 1,
    IconName = "circle-dashed",
})

VisualGroup:AddColorPicker("FOVColor", {
    Text = "Cor do FOV",
    Default = CurrentFOVColor,
    Transparency = 0,
    Title = "Cor do Círculo",
    Callback = function(color) 
        CircleStroke.Color = color
        ToggleButton.TextColor3 = color
        ToggleStroke.Color = color
    end,
})

VisualGroup:AddSlider("FOVThickness", {
    Text = "Espessura",
    Default = 1.5,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(v) CircleStroke.Thickness = v end,
})

VisualGroup:AddSlider("FOVTransparency", {
    Text = "Transparência",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v) CircleStroke.Transparency = v end,
})

local InfoGroup = VisualTab:AddGroupbox({
    Name = "Info",
    Side = 2,
    IconName = "info",
})

InfoGroup:AddLabel({ Text = "Apex Hub • Mobile", DoesWrap = true })
InfoGroup:AddLabel({ Text = "Use o botão 'Apex' na tela pra abrir/fechar.", DoesWrap = true })
InfoGroup:AddLabel({ Text = "O menu pode ser arrastado.", DoesWrap = true })

local SettingsGroup = SettingsTab:AddGroupbox({
    Name = "UI",
    Side = 1,
    IconName = "settings",
})

SettingsGroup:AddSlider("DPIScale", {
    Text = "Escala da UI",
    Default = 100,
    Min = 50,
    Max = 150,
    Rounding = 0,
    Suffix = "%",
    Callback = function(v) Library:SetDPIScale(v) end,
})

SettingsGroup:AddButton({
    Text = "Resetar Configurações",
    Risky = true,
    DoubleClick = true,
    Callback = function()
        Settings.Enabled = false
        Settings.FOVRadius = 150
        Settings.TargetPart = "Head"
        Settings.HitChance = 100
        Settings.SilentAimRange = 1000
        Settings.VisibleCheck = false
        Settings.TeamCheck = true
        Settings.FriendCheck = true
        Settings.ForceFieldCheck = true
        Settings.TargetTeams = {}
        Library:Notify({
            Title = "Configurações",
            Description = "Resetadas com sucesso!",
            Time = 4,
        })
    end,
})

local DangerGroup = SettingsTab:AddGroupbox({
    Name = "Zona de Perigo",
    Side = 2,
    IconName = "alert-triangle",
})

DangerGroup:AddButton({
    Text = "Descarregar Script",
    Risky = true,
    DoubleClick = true,
    Tooltip = "Toque duas vezes para confirmar",
    Callback = function()
        Library:Notify({
            Title = "Apex Hub",
            Description = "Script descarregado.",
            Time = 3,
        })
        task.wait(0.5)
        ScreenGui:Destroy()
        Library:Unload()
    end,
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("ApexHub")
SaveManager:SetFolder("ApexHub/Universal")
SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)
SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = "Apex Hub",
    Description = "Carregado! " .. (isMobile and "Modo Mobile" or "Modo PC"),
    Icon = "zap",
    Time = 5,
})
