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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
-- ANTI-DETECÇÃO GLOBAL (HOOK DE PROTEÇÃO)
-- ══════════════════════════════════════════════════════════════
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Arguments = {...}
        local self = Arguments[1]

        if (Method == "Destroy" or Method == "ClearAllChildren") and self == game:GetService("CoreGui") then
            return 
        end
        if (Method == "Destroy" or Method == "Remove") and self and (self.Name == "ESP_Drawings" or self.Name == "SilentHighlights" or self.Name == "HitboxExpanders") then
            return
        end

        return oldNamecall(...)
    end))
end)

-- ══════════════════════════════════════════════════════════════
-- ABA MIRA
-- ══════════════════════════════════════════════════════════════
local TabMira = Window:Tab({ Title = "", Desc = "", Icon = "lucide:crosshair", ShowTabTitle = false })
TabMira:Section({ Title = "Mira" })
TabMira:Toggle({
    Title = "Ativar Mira",
    Desc = "Configurações de mira",
    Icon = "lucide:crosshair",
    Flag = "MiraAtiva",
    Value = false,
    Callback = function(value) print("Mira:", value) end,
})

-- ══════════════════════════════════════════════════════════════
-- ABA SILENT AIM
-- ══════════════════════════════════════════════════════════════
local TabSilent = Window:Tab({ Title = "", Desc = "", Icon = "lucide:ghost", ShowTabTitle = false })
TabSilent:Section({ Title = "Silent Aim" })

local SilentSettings = {
    Enabled = false, 
    FOVRadius = 150,
    TargetPart = "Head",
    HitChance = 100,
    SilentAimRange = 1000,
    VisibleCheck = false,
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
FOVCircle.Size = UDim2.fromOffset(SilentSettings.FOVRadius * 2, SilentSettings.FOVRadius * 2)
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

local function isVisible(targetCharacter)
    if not SilentSettings.VisibleCheck then return true end
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
    if localRoot and (hrp.Position - localRoot.Position).Magnitude > SilentSettings.SilentAimRange then return false end
    if not isVisible(plr.Character) then return false end
    return true
end

local function getTarget()
    if not SilentSettings.Enabled then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest = nil
    local shortestDist = SilentSettings.FOVRadius
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = plr.Character:FindFirstChild(SilentSettings.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
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
    FOVCircle.Size = UDim2.fromOffset(SilentSettings.FOVRadius * 2, SilentSettings.FOVRadius * 2)
    
    if SilentSettings.Enabled then
        FOVCircle.Visible = true
        pcall(function()
            currentTarget = getTarget()
        end)
    else
        FOVCircle.Visible = false
        currentTarget = nil
    end

    for _, highlight in ipairs(HighlightsFolder:GetChildren()) do
        highlight:Destroy()
    end

    if SilentSettings.VisibleCheck and SilentSettings.Enabled and currentTarget and currentTarget.Parent then
        local targetChar = currentTarget.Parent
        local highlight = Instance.new("Highlight")
        highlight.Name = "TargetHighlight"
        highlight.Adornee = targetChar
        highlight.FillColor = Color3.fromRGB(65, 145, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
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
                if SilentSettings.Enabled and currentTarget and currentTarget.Parent then
                    if math.random(1, 100) <= SilentSettings.HitChance then
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

TabSilent:Toggle({
    Title = "Ativar Silent Aim",
    Desc = "Liga/desliga a mira invisível",
    Icon = "lucide:ghost",
    Flag = "SilentEnabled",
    Value = SilentSettings.Enabled, 
    Callback = function(value)
        SilentSettings.Enabled = value
    end,
})

TabSilent:Toggle({
    Title = "Visible Check",
    Desc = "Marca APENAS o alvo focado de azul e checa visão",
    Flag = "SilentVisibleCheck",
    Value = SilentSettings.VisibleCheck,
    Callback = function(value)
        SilentSettings.VisibleCheck = value
    end,
})

TabSilent:Dropdown({
    Title = "Parte do Corpo",
    Desc = "Onde a mira vai puxar",
    Flag = "SilentTargetPart",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Value = SilentSettings.TargetPart,
    Callback = function(value)
        SilentSettings.TargetPart = value
    end,
})

TabSilent:Slider({
    Title = "FOV Radius",
    Desc = "Tamanho do círculo de mira",
    Flag = "SilentFOVRadius",
    Value = { Min = 30, Max = 500, Default = SilentSettings.FOVRadius },
    Callback = function(value)
        SilentSettings.FOVRadius = value
    end,
})

TabSilent:Slider({
    Title = "Hit Chance (%)",
    Desc = "Porcentagem de chance de acertar",
    Flag = "SilentHitChance",
    Value = { Min = 0, Max = 100, Default = SilentSettings.HitChance },
    Callback = function(value)
        SilentSettings.HitChance = value
    end,
})

TabSilent:Slider({
    Title = "Alcance (Range)",
    Desc = "Distância máxima para puxar a mira",
    Flag = "SilentRange",
    Value = { Min = 100, Max = 2000, Default = SilentSettings.SilentAimRange },
    Callback = function(value)
        SilentSettings.SilentAimRange = value
    end,
})

-- ══════════════════════════════════════════════════════════════
-- ABA ESP
-- ══════════════════════════════════════════════════════════════
local TabESP = Window:Tab({ Title = "", Desc = "", Icon = "lucide:eye", ShowTabTitle = false })
TabESP:Section({ Title = "ESP 2D Visual" })

local ESPSettings = {
    Enabled = false,
    TeamCheck = false,
    ShowBox = true,
    ShowHealth = true,
    ShowName = true
}

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Drawings"
ESPFolder.Parent = game:GetService("CoreGui")
local ESPObjects = {}

local function CreateLine(parent, color, thickness)
    local line = Drawing.new("Line")
    line.Color = color
    line.Thickness = thickness or 1
    line.Transparency = 1
    line.Visible = false
    line.Parent = parent 
    return line
end

local function CleanupESP(plrName)
    if ESPObjects[plrName] then
        for _, obj in pairs(ESPObjects[plrName]) do
            if obj.Remove then obj:Remove() end
        end
        ESPObjects[plrName] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not ESPFolder.Parent then
        ESPFolder.Parent = game:GetService("CoreGui")
    end

    if not ESPSettings.Enabled then
        for plrName, _ in pairs(ESPObjects) do
            CleanupESP(plrName)
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")

            if not hum or hum.Health <= 0 or not hrp or not head then
                CleanupESP(plr.Name)
            else
                if ESPSettings.TeamCheck and plr.Team == LocalPlayer.Team then
                    CleanupESP(plr.Name)
                else
                    local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)

                    if hrpOnScreen and headOnScreen then
                        local height = math.abs(headPos.Y - hrpPos.Y) * 2.2
                        local width = height / 2.5
                        local x = hrpPos.X - (width / 2)
                        local y = headPos.Y - (height * 0.2)

                        if not ESPObjects[plr.Name] then
                            ESPObjects[plr.Name] = {
                                TopLine = CreateLine(ESPFolder, Color3.new(1,1,1), 1),
                                BottomLine = CreateLine(ESPFolder, Color3.new(1,1,1), 1),
                                LeftLine = CreateLine(ESPFolder, Color3.new(1,1,1), 1),
                                RightLine = CreateLine(ESPFolder, Color3.new(1,1,1), 1),
                                HealthBar = CreateLine(ESPFolder, Color3.new(0,1,0), 2),
                                NameText = Drawing.new("Text")
                            }
                            ESPObjects[plr.Name].NameText.Size = 14
                            ESPObjects[plr.Name].NameText.Center = true
                            ESPObjects[plr.Name].NameText.Outline = true
                            ESPObjects[plr.Name].NameText.OutlineColor = Color3.new(0,0,0)
                        end

                        local esp = ESPObjects[plr.Name]
                        local isAlly = plr.Team and LocalPlayer.Team and (plr.Team == LocalPlayer.Team)
                        local color = isAlly and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

                        if ESPSettings.ShowBox then
                            esp.TopLine.From = Vector2.new(x, y)
                            esp.TopLine.To = Vector2.new(x + width, y)
                                                            esp.TopLine.Color = color
                            esp.TopLine.Visible = true

                            esp.BottomLine.From = Vector2.new(x, y + height)
                            esp.BottomLine.To = Vector2.new(x + width, y + height)
                            esp.BottomLine.Color = color
                            esp.BottomLine.Visible = true

                            esp.LeftLine.From = Vector2.new(x, y)
                            esp.LeftLine.To = Vector2.new(x, y + height)
                            esp.LeftLine.Color = color
                            esp.LeftLine.Visible = true

                            esp.RightLine.From = Vector2.new(x + width, y)
                            esp.RightLine.To = Vector2.new(x + width, y + height)
                            esp.RightLine.Color = color
                            esp.RightLine.Visible = true
                        else
                            esp.TopLine.Visible = false
                            esp.BottomLine.Visible = false
                            esp.LeftLine.Visible = false
                            esp.RightLine.Visible = false
                        end

                        if ESPSettings.ShowHealth and hum then
                            local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            esp.HealthBar.From = Vector2.new(x - 4, y + height)
                            esp.HealthBar.To = Vector2.new(x - 4, y + (height - (height * healthPct)))
                            
                            if healthPct > 0.5 then
                                esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                            elseif healthPct > 0.2 then
                                esp.HealthBar.Color = Color3.fromRGB(255, 255, 0)
                            else
                                esp.HealthBar.Color = Color3.fromRGB(255, 0, 0)
                            end
                            esp.HealthBar.Visible = true
                        else
                            esp.HealthBar.Visible = false
                        end

                        if ESPSettings.ShowName then
                            esp.NameText.Text = plr.Name
                            esp.NameText.Position = Vector2.new(x + (width / 2), y - 16)
                            esp.NameText.Color = color
                            esp.NameText.Visible = true
                        else
                            esp.NameText.Visible = false
                        end
                    else
                        if ESPObjects[plr.Name] then
                            for _, obj in pairs(ESPObjects[plr.Name]) do
                                obj.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end

    for name, _ in pairs(ESPObjects) do
        if not Players:FindFirstChild(name) then
            CleanupESP(name)
        end
    end
end)

TabESP:Toggle({
    Title = "Ativar ESP 2D",
    Desc = "Desenha caixas e informações",
    Icon = "lucide:eye",
    Flag = "ESPAtivo",
    Value = ESPSettings.Enabled,
    Callback = function(value)
        ESPSettings.Enabled = value
        if not value then
            for plrName, _ in pairs(ESPObjects) do
                CleanupESP(plrName)
            end
        end
    end,
})

TabESP:Toggle({
    Title = "Team Check",
    Desc = "Não mostra aliados",
    Flag = "ESPTeamCheck",
    Value = ESPSettings.TeamCheck,
    Callback = function(value)
        ESPSettings.TeamCheck = value
    end,
})

TabESP:Toggle({
    Title = "Mostrar Caixa",
    Desc = "Desenha a caixa 2D",
    Flag = "ESPShowBox",
    Value = ESPSettings.ShowBox,
    Callback = function(value)
        ESPSettings.ShowBox = value
    end,
})

TabESP:Toggle({
    Title = "Mostrar Barra de Vida",
    Desc = "Desenha a vida ao lado",
    Flag = "ESPShowHealth",
    Value = ESPSettings.ShowHealth,
    Callback = function(value)
        ESPSettings.ShowHealth = value
    end,
})

TabESP:Toggle({
    Title = "Mostrar Nome",
    Desc = "Desenha o nome acima",
    Flag = "ESPShowName",
    Value = ESPSettings.ShowName,
    Callback = function(value)
        ESPSettings.ShowName = value
    end,
})

-- ══════════════════════════════════════════════════════════════
-- ABA PLAYER (SPEED, FLY JUMP, POWER JUMP)
-- ══════════════════════════════════════════════════════════════
local TabPlayer = Window:Tab({ Title = "", Desc = "", Icon = "lucide:user", ShowTabTitle = false })
TabPlayer:Section({ Title = "Movimentação" })

local PlayerSettings = {
    SpeedEnabled = false,
    SpeedValue = 16,
    FlyJumpEnabled = false,
    PowerJumpEnabled = false,
    PowerJumpValue = 50
}

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if PlayerSettings.SpeedEnabled then
                hum.WalkSpeed = PlayerSettings.SpeedValue
            end
            if PlayerSettings.PowerJumpEnabled then
                hum.JumpPower = PlayerSettings.PowerJumpValue
                hum.UseJumpPower = true
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if PlayerSettings.FlyJumpEnabled and hrp and hum then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or game:GetService("UserInputService").TouchEnabled then
            if hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.Jumping then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            end
        end
    end
end)

TabPlayer:Toggle({
    Title = "Ativar Speed",
    Desc = "Liga/desliga a velocidade",
    Icon = "lucide:zap",
    Flag = "PlayerSpeedToggle",
    Value = PlayerSettings.SpeedEnabled,
    Callback = function(value)
        PlayerSettings.SpeedEnabled = value
        if not value then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

TabPlayer:Slider({
    Title = "Velocidade (Speed)",
    Desc = "Ajuste a velocidade",
    Flag = "PlayerSpeedValue",
    Value = { Min = 16, Max = 250, Default = 16 },
    Callback = function(value)
        PlayerSettings.SpeedValue = value
    end,
})

TabPlayer:Toggle({
    Title = "Ativar Fly Jump (Voo)",
    Desc = "Permite flutuar no ar",
    Icon = "lucide:wind",
    Flag = "PlayerFlyJumpToggle",
    Value = PlayerSettings.FlyJumpEnabled,
    Callback = function(value)
        PlayerSettings.FlyJumpEnabled = value
    end,
})

TabPlayer:Toggle({
    Title = "Ativar Power Jump",
    Desc = "Liga/desliga o pulo alto",
    Icon = "lucide:arrow-up",
    Flag = "PlayerPowerJumpToggle",
    Value = PlayerSettings.PowerJumpEnabled,
    Callback = function(value)
        PlayerSettings.PowerJumpEnabled = value
        if not value then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end,
})

TabPlayer:Slider({
    Title = "Força do Pulo (Power Jump)",
    Desc = "Ajuste a força do pulo",
    Flag = "PlayerPowerJumpValue",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(value)
        PlayerSettings.PowerJumpValue = value
    end,
})

-- ══════════════════════════════════════════════════════════════
-- ABA HITBOX
-- ══════════════════════════════════════════════════════════════
local TabHitbox = Window:Tab({ Title = "", Desc = "", Icon = "lucide:radio", ShowTabTitle = false })
TabHitbox:Section({ Title = "Hitbox Expander" })

local HitboxSettings = {
    Enabled = false,
    Size = 5
}

local HitboxFolder = Instance.new("Folder")
HitboxFolder.Name = "HitboxExpanders"
HitboxFolder.Parent = game:GetService("CoreGui")

local function CleanupHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp:FindFirstChild("HitboxOriginalSize") then
                    hrp.Size = hrp.HitboxOriginalSize.Value
                    hrp.HitboxOriginalSize:Destroy()
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                end
            end
        end
    end
    for _, obj in ipairs(HitboxFolder:GetChildren()) do
        obj:Destroy()
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if HitboxSettings.Enabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if not hrp:FindFirstChild("HitboxOriginalSize") then
                            local originalSize = Instance.new("Vector3Value")
                            originalSize.Name = "HitboxOriginalSize"
                            originalSize.Value = hrp.Size
                            originalSize.Parent = hrp
                        end
                        
                        hrp.Size = Vector3.new(HitboxSettings.Size, HitboxSettings.Size, HitboxSettings.Size)
                        hrp.CanCollide = false
                        
                        local visualBox = HitboxFolder:FindFirstChild(plr.Name)
                        if not visualBox then
                            visualBox = Instance.new("BoxHandleAdornment")
                            visualBox.Name = plr.Name
                            visualBox.Adornee = hrp
                            visualBox.AlwaysOnTop = true
                            visualBox.ZIndex = 5
                            visualBox.Color3 = Color3.fromRGB(255, 0, 0)
                            visualBox.Transparency = 0.7
                            visualBox.Parent = HitboxFolder
                        end
                        visualBox.Size = hrp.Size
                    end
                end
            end
        end
    end
end)

TabHitbox:Toggle({
    Title = "Ativar Hitbox Expander",
    Desc = "Aumenta a hitbox de todos os inimigos",
    Icon = "lucide:radio",
    Flag = "HitboxExpandida",
    Value = HitboxSettings.Enabled,
    Callback = function(value)
        HitboxSettings.Enabled = value
        if not value then
            CleanupHitboxes()
        end
    end,
})

TabHitbox:Slider({
    Title = "Tamanho da Hitbox",
    Desc = "Ajuste o tamanho da caixa de colisão",
    Flag = "HitboxTamanho",
    Value = { Min = 1, Max = 50, Default = 5 },
    Callback = function(value)
        HitboxSettings.Size = value
    end,
})

-- ══════════════════════════════════════════════════════════════
-- OUTRAS ABAS
-- ══════════════════════════════════════════════════════════════
local TabNuvem = Window:Tab({ Title = "", Desc = "", Icon = "lucide:cloud", ShowTabTitle = false })
TabNuvem:Section({ Title = "Nuvem - Configurações" })

local ConfigManager = Window.ConfigManager
local CurrentConfigName = "default"

local ConfigNameInput = TabNuvem:Input({
    Title = "Nome da Config",
    Desc = "Digite o nome da config",
    Icon = "lucide:file-text",
    Value = CurrentConfigName,
    Callback = function(value)
        CurrentConfigName = value
    end
})

TabNuvem:Button({
    Title = "Salvar Config",
    Desc = "Salva as opções atuais",
    Icon = "lucide:save",
    IconAlign = "Right",
    IconColor = Color3.fromHex("#FCD34D"),
    Color = Color3.fromHex("#F59E0B"),
    Justify = "Between",
    Callback = function()
        if CurrentConfigName and CurrentConfigName ~= "" then
            local config = ConfigManager:CreateConfig(CurrentConfigName)
            if config:Save() then
                ConfigDropdown:Refresh(ConfigManager:AllConfigs())
                WindUI:Notify({ Title = "Sucesso", Content = "Config '"..CurrentConfigName.."' salva!", Icon = "lucide:check" })
            end
        end
    end
})

TabNuvem:Button({
    Title = "Carregar Config",
    Desc = "Puxa as opções salvas",
    Icon = "lucide:upload",
    IconAlign = "Right",
    IconColor = Color3.fromHex("#FCD34D"),
    Color = Color3.fromHex("#FFFFFF"),
    Justify = "Between",
    Callback = function()
        if CurrentConfigName and CurrentConfigName ~= "" then
            local config = ConfigManager:CreateConfig(CurrentConfigName)
            if config:Load() then
                WindUI:Notify({ Title = "Carregado", Content = "Config '"..CurrentConfigName.."' aplicada!", Icon = "lucide:check" })
            end
        end
    end
})

TabNuvem:Button({
    Title = "Deletar Config",
    Desc = "Apaga a config selecionada",
    Icon = "lucide:trash-2",
    IconAlign = "Right",
    IconColor = Color3.fromHex("#FF6B6B"),
    Color = Color3.fromHex("#FF4444"),
    Justify = "Between",
    Callback = function()
        if CurrentConfigName and CurrentConfigName ~= "" then
            local config = ConfigManager:CreateConfig(CurrentConfigName)
            config:Delete()
            ConfigDropdown:Refresh(ConfigManager:AllConfigs())
            WindUI:Notify({ Title = "Deletado", Content = "Config removida.", Icon = "lucide:trash" })
        end
    end
})

ConfigDropdown = TabNuvem:Dropdown({
    Title = "Configs Salvas",
    Desc = "Escolha uma config para carregar",
    Icon = "lucide:folder-open",
    Values = ConfigManager:AllConfigs(),
    Callback = function(value)
        if value and value ~= "" then
            CurrentConfigName = value
            ConfigNameInput:Set(value)
        end
    end
})

local TabConfig = Window:Tab({ Title = "", Desc = "", Icon = "lucide:wrench", ShowTabTitle = false })
TabConfig:Section({ Title = "Configurações" })
TabConfig:Button({ 
    Title = "Sobre", 
    Desc = "Apex Hub", 
    Icon = "lucide:info", 
    IconAlign = "Right", 
    IconColor = Color3.fromHex("#FCD34D"), 
    Color = Color3.fromHex("#F59E0B"), 
    Justify = "Between", 
    Callback = function() end 
})

TabMira:Select()
