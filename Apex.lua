local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Hitbox = {
    Enabled = false,
    Part = "Hitbox",
    Size = 5, 
    Hide = false, 
    TeamCheck = true,
    Jitter = true,
}

local hitboxOriginals = {}

local function getHitboxPart(character)
    return character:FindFirstChild("Hitbox") or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function isAlly(plr)
    if not Hitbox.TeamCheck then return false end
    return plr.Team ~= nil and plr.Team == LocalPlayer.Team
end

local function applyHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not isAlly(plr) then
            local part = getHitboxPart(plr.Character)
            if part then
                if not hitboxOriginals[part] then
                    hitboxOriginals[part] = part.Size
                end
                
                local finalSize = Hitbox.Size
                if Hitbox.Jitter then
                    local j = math.random(-2, 2) / 10
                    finalSize = finalSize + j
                end
                
                part.Size = hitboxOriginals[part] * finalSize
                part.CanCollide = false
                part.Transparency = Hitbox.Hide and 1 or 0.5
            end
        end
    end
end

local function resetHitbox()
    for part, originalSize in pairs(hitboxOriginals) do
        if part and part.Parent then
            part.Size = originalSize
            part.Transparency = 0
            part.CanCollide = true
        end
    end
    hitboxOriginals = {}
end

task.spawn(function()
    while task.wait(math.random(8, 15) / 10) do 
        if Hitbox.Enabled then
            pcall(applyHitbox)
        else
            pcall(resetHitbox)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if Hitbox.Enabled then
        hitboxOriginals = {}
    end
end)
local S = {
    on          = false,
    keybind     = Enum.KeyCode.Q,
    fov         = 200,   
    part        = "Head",
    smooth      = 0.18,  
    predict     = true,  
    predictTime = 0.12,  
    visCheck    = true,
    teamCheck   = true,
    maxRange    = 1500,  
    sticky      = true,
    humanize    = true,  
    showFov     = false,
    hideFov     = false,
    fovColor    = Color3.fromRGB(255, 0, 128),
}

local SA = {
    Enabled     = false,
    FOVRadius   = 150,
    TargetPart  = "Head",
    HitChance   = 100,
    Range       = 1000,
    HideFov     = false,
}

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if (S.on or S.showFov) and not S.hideFov then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Position = center
        fovCircle.Radius = S.fov
        fovCircle.Color = S.fovColor
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)

local target, targetPart, targetPlr = nil, nil, nil

local function rnd(a, b) return a + math.random()*(b-a) end

local function isAlly(plr)
    if not S.teamCheck then return false end
    return plr.Team ~= nil and plr.Team == LocalPlayer.Team
end

local function hasLOS(char)
    if not S.visCheck then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not lhrp then return false end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Blacklist
    p.FilterDescendantsInstances = {LocalPlayer.Character, char}
    local r = workspace:Raycast(Camera.CFrame.Position, hrp.Position - Camera.CFrame.Position, p)
    return r == nil
end

local function validTarget(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end
    local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if lhrp and (hrp.Position - lhrp.Position).Magnitude > S.maxRange then return false end
    if isAlly(plr) then return false end
    if not hasLOS(plr.Character) then return false end
    return true
end

local function getAimPos(plr, part)
    if not S.predict then return part.Position end
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    local vel = hrp.AssemblyLinearVelocity
    local predicted = part.Position + vel * S.predictTime
    if (predicted - Camera.CFrame.Position).Magnitude > S.maxRange then
        return part.Position
    end
    return predicted
end

local function findBest()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestPlr, bestPart, bestD = nil, nil, nil, S.fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if validTarget(plr) then
            local part = plr.Character:FindFirstChild(S.part) or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                if on and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestD then
                        best, bestPlr, bestPart, bestD = plr, plr, part, d
                    end
                end
            end
        end
    end
    return best, bestPart
end

local function resolveTarget()
    if S.sticky and targetPlr and validTarget(targetPlr) then
        local p = targetPlr.Character:FindFirstChild(S.part) or targetPlr.Character:FindFirstChild("HumanoidRootPart")
        if p then
            local sp, on = Camera:WorldToViewportPoint(p.Position)
            if on and sp.Z > 0 then
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if d <= S.fov * 1.2 then
                    return targetPlr, p
                end
            end
        end
    end
    return findBest()
end

local function aimAt(worldPos)
    local camPos = Camera.CFrame.Position
    local desired = CFrame.lookAt(camPos, worldPos)
    if S.humanize then
        local j = rnd(0.0004, 0.0018)
        desired = desired * CFrame.Angles(rnd(-j, j), rnd(-j, j), 0)
    end
    local t = 1 - math.clamp(S.smooth, 0.001, 0.999)
    Camera.CFrame = Camera.CFrame:Lerp(desired, t)
end

UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == S.keybind then
        S.on = not S.on
        if not S.on then
            target, targetPart, targetPlr = nil, nil, nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not S.on then return end
    local lp = LocalPlayer.Character
    if not lp then return end
    local lhum = lp:FindFirstChildOfClass("Humanoid")
    if not lhum or lhum.Health <= 0 then return end

    pcall(function()
        local plr, part = resolveTarget()
        targetPlr, targetPart = plr, part
        if part then
            aimAt(getAimPos(plr, part))
        end
    end)
end)

local Window = WindUI:CreateWindow({
    Title = "APEX HUB",
    Icon = "crown",
    Author = "APEX",
    Folder = "ApexHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = { Enabled = true, Anonymous = true },
    SideBarWidth = 200,
    HasOutline = true,
})

local AimbotTab = Window:Tab({ Title = "", Icon = "rbxassetid://122878673716704" })
local SilentTab = Window:Tab({ Title = "", Icon = "rbxassetid://122014945028597" })
local HitboxTab = Window:Tab({ Title = "", Icon = "rbxassetid://117329818290748" })
local EspTab    = Window:Tab({ Title = "", Icon = "rbxassetid://127234874352422" })
local ConfigTab = Window:Tab({ Title = "", Icon = "rbxassetid://106205298246017" })

local AimSection = AimbotTab:Section({ Title = "Aimbot" })

AimSection:Toggle({
    Title = "Aimbot",
    Desc = "Crava sua Mira na Cabeça doa player",
    Icon = "crosshair",
    Value = false,
    Callback = function(v)
        S.on = v
        S.showFov = v
        if not v then 
            target, targetPart, targetPlr = nil, nil, nil 
        end
    end,
})

AimSection:Dropdown({
    Title = "Alvo",
    Values = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Value = "Head",
    Multi = false,
    Callback = function(o) S.part = o end,
})

AimSection:Slider({
    Title = "Ajustar FOV",
    Desc = "Ajusta o raio do círculo na tela",
    Step = 1,
    Value = {
        Min = 50,
        Max = 800,
        Default = 200,
    },
    Callback = function(val) 
        S.fov = val 
    end,
})

AimSection:Slider({
    Title = "Distância",
    Desc = "Alcance máximo para travar no alvo",
    Step = 10,
    Value = {
        Min = 100,
        Max = 3000,
        Default = 1500,
    },
    Callback = function(val) 
        S.maxRange = val 
    end,
})

AimSection:Toggle({
    Title = "Sticky",
    Desc = "Mantém o mesmo alvo",
    Value = true,
    Callback = function(v) S.sticky = v end,
})

AimSection:Toggle({
    Title = "Esconder FOV",
    Desc = "Deixa o FOV invisível (mesmo com o Aimbot ligado)",
    Value = false,
    Callback = function(v) 
        S.hideFov = v 
    end,
})

AimSection:Colorpicker({
    Title = "Cor do FOV",
    Default = Color3.fromRGB(255, 0, 128),
    Callback = function(c) S.fovColor = c end,
})

local SilentSection = SilentTab:Section({ Title = "Silent Aim" })

SilentSection:Toggle({
    Title = "Silent Aim",
    Value = false,
    Callback = function(v) SA.Enabled = v end,
})

SilentSection:Dropdown({
    Title = "Alvo",
    Values = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Value = "Head",
    Multi = false,
    Callback = function(o) SA.TargetPart = o end,
})

SilentSection:Slider({
    Title = "Tamanho da FOV",
    Desc = "Raio da área de busca do alvo",
    Step = 1,
    Value = {
        Min = 50,
        Max = 800,
        Default = 150,
    },
    Callback = function(val) 
        SA.FOVRadius = val 
    end,
})

SilentSection:Slider({
    Title = "Alcance",
    Desc = "Distância máxima do alvo",
    Step = 10,
    Value = {
        Min = 100,
        Max = 3000,
        Default = 1000,
    },
    Callback = function(val) 
        SA.Range = val 
    end,
})

SilentSection:Slider({
    Title = "Acertos",
    Desc = "Chance de acerto do silent (0 a 100%)",
    Step = 1,
    Value = {
        Min = 0,
        Max = 100,
        Default = 100,
    },
    Callback = function(val) 
        SA.HitChance = val 
    end,
})

SilentSection:Toggle({
    Title = "Esconder FOV",
    Value = false,
    Callback = function(v) SA.HideFov = v end,
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSilentAimFOV"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.fromOffset(SA.FOVRadius * 2, SA.FOVRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(65, 145, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Parent = FOVCircle

local currentTarget = nil
local currentHighlight = nil
local currentPlr = nil

local function isValidTarget(plr)
    if plr == LocalPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end
    
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRoot and (hrp.Position - localRoot.Position).Magnitude > SA.Range then return false end
    return true
end

local function getTarget()
    if not SA.Enabled then return nil, nil end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestPlr = nil
    local closestPart = nil
    local shortestDist = SA.FOVRadius
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = plr.Character:FindFirstChild(SA.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        closestPlr = plr
                        closestPart = part
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closestPlr, closestPart
end

RunService.RenderStepped:Connect(function()
    if SA.Enabled and not SA.HideFov then
        FOVCircle.Visible = true
        FOVCircle.Size = UDim2.fromOffset(SA.FOVRadius * 2, SA.FOVRadius * 2)
    else
        FOVCircle.Visible = false
    end
    
    pcall(function()
        local targetPlr, targetPart = getTarget()
        currentTarget = targetPart
        currentPlr = targetPlr
        
        if targetPlr then
            if currentHighlight and currentHighlight.Parent ~= targetPlr.Character then
                currentHighlight:Destroy()
                currentHighlight = nil
            end
            
            if not currentHighlight then
                currentHighlight = Instance.new("Highlight")
                currentHighlight.FillColor = Color3.fromRGB(65, 145, 255)
                currentHighlight.OutlineColor = Color3.fromRGB(65, 145, 255)
                currentHighlight.FillTransparency = 1
                currentHighlight.OutlineTransparency = 0
                currentHighlight.Parent = targetPlr.Character
            end
        else
            if currentHighlight then
                currentHighlight:Destroy()
                currentHighlight = nil
            end
        end
    end)
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

pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Arguments = {...}
        local self = Arguments[1]

        if self == workspace and not checkcaller() then
            local Origin, Direction = tryGetOriginDirection(Method, Arguments)
            if Origin and Direction and isLocalPlayerShooting(Arguments, Method, Origin, Direction) then
                if SA.Enabled and currentTarget and currentTarget.Parent then
                    if math.random(1, 100) <= SA.HitChance then
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

local HitboxSection = HitboxTab:Section({ Title = "📦 Hitbox" })
local HitboxSection = HitboxTab:Section({ Title = "📦 Hitbox" })

HitboxSection:Toggle({
    Title = "Ativar Hitbox",
    Value = false,
    Callback = function(v) 
        Hitbox.Enabled = v 
        if not v then resetHitbox() end
    end,
})

HitboxSection:Slider({
    Title = "Tamanho da Hitbox",
    Desc = "Ajusta o multiplicador de tamanho (2x a 20x)",
    Step = 1,
    Value = { Min = 2, Max = 20, Default = 5 },
    Callback = function(val) Hitbox.Size = val end,
})

HitboxSection:Toggle({
    Title = "Deixar Invisível",
    Desc = "Deixa a hitbox invisível",
    Value = false,
    Callback = function(v) Hitbox.Hide = v end,
})

HitboxSection:Toggle({
    Title = "Ignorar Time",
    Desc = "Não aplica hitbox nos aliados",
    Value = true,
    Callback = function(v) Hitbox.TeamCheck = v end,
})

HitboxSection:Toggle({
    Title = "Humanize",
    Desc = "Varia o tamanho aleatoriamente pra não ser óbvio",
    Value = true,
    Callback = function(v) Hitbox.Jitter = v end,
})
local EspSection = EspTab:Section({ Title = "👁️ ESP" })
EspSection:Toggle({ Title = "Ativar ESP", Value = false, Callback = function(v) end })
EspSection:Toggle({ Title = "Box", Value = true, Callback = function(v) end })
EspSection:Toggle({ Title = "Nome", Value = true, Callback = function(v) end })
EspSection:Toggle({ Title = "Barra de Vida", Value = true, Callback = function(v) end })
EspSection:Toggle({ Title = "Tracer", Value = false, Callback = function(v) end })
EspSection:Toggle({ Title = "Distância", Value = false, Callback = function(v) end })
EspSection:Colorpicker({ Title = "Cor do ESP", Default = Color3.fromRGB(255, 0, 128), Callback = function(c) end })
EspSection:Toggle({ Title = "Cor do Time", Value = false, Callback = function(v) end })

local ConfigSection = ConfigTab:Section({ Title = "⚙️ Configurações" })
ConfigSection:Button({ Title = "💾 Salvar Config", Callback = function()
    WindUI:Notify({ Title = "APEX HUB", Content = "Config salva!", Duration = 3 })
end })
ConfigSection:Button({ Title = "📂 Carregar Config", Callback = function()
    WindUI:Notify({ Title = "APEX HUB", Content = "Config carregada!", Duration = 3 })
end })
ConfigSection:Button({ Title = "🔄 Resetar Tudo", Callback = function()
    WindUI:Notify({ Title = "APEX HUB", Content = "Tudo resetado!", Duration = 3 })
end })
ConfigSection:Button({ Title = "💬 Discord", Callback = function()
    setclipboard("https://discord.gg/apexhub")
    WindUI:Notify({ Title = "APEX HUB", Content = "Link copiado!", Duration = 3 })
end })

WindUI:Notify({
    Title = "🚀 APEX HUB",
    Content = "Aimbot carregado!",
    Icon = "check",
    Duration = 5,
})
