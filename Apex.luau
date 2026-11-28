local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local SCRIPT_VERSION = "1.0.8"

local Window = Library:CreateWindow({
    Title = "Rendex",
    Footer = "Jailbreak | " .. SCRIPT_VERSION,
    Icon = 95816097006870,
    ToggleKeybind = Enum.KeyCode.RightControl,
    SidebarCompacted = true,
})

local Tabs = {
    Home     = Window:AddTab("Home", "house"),
    Combat   = Window:AddTab("Combat", "hand-fist"),
    Visuals  = Window:AddTab("Visuals", "eye"),
    World    = Window:AddTab("World", "globe"),
    Settings = Window:AddTab("Settings", "settings"),
}

local Settings = {
    -- Silent Aim
    Enabled = false,
    FOVRadius = 150,
    TargetPart = "Head",
    HitChance = 100,
    SilentAimRange = 1000,
    VisibleCheck = false,
    ShowFOV = false,
    FOVFilled = false,
    
    -- Aimbot
    AimEnabled = false,
    AimFOV = 200,
    AimPart = "Head",
    AimSmooth = 0.18,
    AimPredict = true,
    AimPredictTime = 0.12,
    AimMaxRange = 1500,
    AimSticky = true,
    
    -- Hitbox
    HitboxEnabled = false,
    HitboxSize = 17,
    HitboxShowVisual = true,
    
    -- ESP
    ESPEnabled = false,
    ESPShowBox = true,
    ESPShowHealth = true,
    ESPMaxDistance = 1000,
    ESPColor = Color3.fromRGB(0, 120, 255),
    ESPHealthColor = Color3.fromRGB(0, 255, 0),
    
    -- Stretch
    StretchEnabled = false,
    StretchFactor = 0.65,
}

local Profile = Tabs.Home:AddLeftGroupbox("Profile")
Profile:AddImage("Avatar", {
    Image = "rbxthumb://type=Avatar&id=" .. LocalPlayer.UserId .. "&w=420&h=420",
    Height = 220,
})
Profile:AddLabel(LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")")

local Info = Tabs.Home:AddRightGroupbox("Rendex")
Info:AddLabel("Versão: " .. SCRIPT_VERSION)
Info:AddDivider()
Info:AddLabel({
    Text = "Bem-vindo ao Rendex! Obrigado por usar o script. Em breve teremos novas funções, então fique ligado nas atualizações.",
    DoesWrap = true,
})

local CombatGroup = Tabs.Combat:AddLeftGroupbox("Silent Aim")
CombatGroup:AddToggle("EnableSA", {
    Text = "Enabled", Default = false,
    Callback = function(Value) Settings.Enabled = Value end
})
CombatGroup:AddDropdown("TargetPart", {
    Text = "Target Part", Values = {"Head", "HumanoidRootPart", "UpperTorso"},
    Default = "Head",
    Callback = function(Value) Settings.TargetPart = Value end
})
CombatGroup:AddToggle("Wallcheck", {
    Text = "Wallcheck", Default = false,
    Callback = function(Value) Settings.VisibleCheck = Value end
})

local FOVGroup = Tabs.Combat:AddLeftGroupbox("Silent FOV")
FOVGroup:AddToggle("ShowFOV", {
    Text = "FOV Circle", Default = false,
    Callback = function(Value) 
        Settings.ShowFOV = Value
        if _G.FOVCircle then _G.FOVCircle.Visible = Value end 
    end
})
FOVGroup:AddToggle("FOVFilled", {
    Text = "FOV Circle Filled", Default = false,
    Callback = function(Value) 
        Settings.FOVFilled = Value
        if _G.FOVCircle then 
            _G.FOVCircle.BackgroundTransparency = Value and 0.8 or 1
        end
    end
})
FOVGroup:AddSlider("FOVRadius", {
    Text = "Radius", Min = 50, Max = 1000, Default = 150, Rounding = 0,
    Callback = function(Value) 
        Settings.FOVRadius = Value 
        if _G.FOVCircle then _G.FOVCircle.Size = UDim2.fromOffset(Value * 2, Value * 2) end
    end
})

local AimGroup = Tabs.Combat:AddRightGroupbox("Aimbot")
AimGroup:AddToggle("AimEnabled", {
    Text = "Enabled", Default = false,
    Callback = function(Value) Settings.AimEnabled = Value end
})
AimGroup:AddDropdown("AimPart", {
    Text = "Target Part", Values = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(Value) Settings.AimPart = Value end
})
AimGroup:AddSlider("AimFOV", {
    Text = "FOV Radius", Min = 50, Max = 800, Default = 200, Rounding = 0,
    Callback = function(Value) Settings.AimFOV = Value end
})
AimGroup:AddSlider("AimSmooth", {
    Text = "Smoothness", Min = 0.01, Max = 0.9, Default = 0.18, Rounding = 2,
    Callback = function(Value) Settings.AimSmooth = Value end
})
AimGroup:AddToggle("AimSticky", {
    Text = "Sticky", Default = true,
    Callback = function(Value) Settings.AimSticky = Value end
})

local HitboxGroup = Tabs.Combat:AddRightGroupbox("Hitbox")
HitboxGroup:AddToggle("HitboxEnabled", {
    Text = "Enabled", Default = false,
    Callback = function(Value) 
        Settings.HitboxEnabled = Value 
        if not Value then resetHitbox() end
    end
})
HitboxGroup:AddSlider("HitboxSize", {
    Text = "Size", Min = 5, Max = 60, Default = 17, Rounding = 0,
    Callback = function(Value) 
        Settings.HitboxSize = Value 
        if Settings.HitboxEnabled then applyHitbox() end
    end
})
HitboxGroup:AddToggle("HitboxShowVisual", {
    Text = "Show Visual", Default = true,
    Callback = function(Value) 
        Settings.HitboxShowVisual = Value 
        if Settings.HitboxEnabled then applyHitbox() end
    end
})

local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP")
ESPGroup:AddToggle("ESPEnabled", {
    Text = "Enabled", Default = false,
    Callback = function(Value) Settings.ESPEnabled = Value end
})
ESPGroup:AddToggle("ESPShowBox", {
    Text = "Show Box", Default = true,
    Callback = function(Value) Settings.ESPShowBox = Value end
})
ESPGroup:AddToggle("ESPShowHealth", {
    Text = "Show Health", Default = true,
    Callback = function(Value) Settings.ESPShowHealth = Value end
})
ESPGroup:AddSlider("ESPMaxDistance", {
    Text = "Max Distance", Min = 100, Max = 3000, Default = 1000, Rounding = 0,
    Callback = function(Value) Settings.ESPMaxDistance = Value end
})

local StretchGroup = Tabs.World:AddLeftGroupbox("Camera Stretch")
StretchGroup:AddToggle("StretchEnabled", {
    Text = "Enabled", Default = false,
    Callback = function(Value) 
        Settings.StretchEnabled = Value 
        if not Value then stopStretch() end
    end
})
StretchGroup:AddSlider("StretchFactor", {
    Text = "Factor", Min = 0.50, Max = 1.00, Default = 0.65, Rounding = 2,
    Callback = function(Value) Settings.StretchFactor = Value end
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Rendex")
SaveManager:SetFolder("Rendex/Jailbreak")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RendexFOV"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(65, 145, 255)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(65, 145, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Parent = FOVCircle
_G.FOVCircle = FOVCircle

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Visible = false

local currentTarget = nil
local currentPlr = nil
local target, targetPart, targetPlr = nil, nil, nil

local function isVisible(targetCharacter)
    if not Settings.VisibleCheck then return true end 
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
    local char = LocalPlayer.Character
    local localHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not localHRP then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    local direction = (targetHRP.Position - localHRP.Position)
    local result = workspace:Raycast(localHRP.Position, direction, params)
    if result then return false end
    return true
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
    if not Settings.Enabled then return nil, nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestPlr = nil
    local closestPart = nil
    local shortestDist = Settings.FOVRadius
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = plr.Character:FindFirstChild(Settings.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
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

local function rnd(a, b) return a + math.random()*(b-a) end
local function hasLOS(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not lhrp then return false end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Blacklist
    p.FilterDescendantsInstances = {LocalPlayer.Character, char}
    local r = workspace:Raycast(Camera.CFrame.Position, hrp.Position - Camera.CFrame.Position, p)
    return r == nil
end

local function validTargetAim(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end
    local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if lhrp and (hrp.Position - lhrp.Position).Magnitude > Settings.AimMaxRange then return false end
    if not hasLOS(plr.Character) then return false end
    return true
end

local function getAimPos(plr, part)
    if not Settings.AimPredict then return part.Position end
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    local vel = hrp.AssemblyLinearVelocity
    local predicted = part.Position + vel * Settings.AimPredictTime
    if (predicted - Camera.CFrame.Position).Magnitude > Settings.AimMaxRange then
        return part.Position
    end
    return predicted
end

local function findBestAim()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestPlr, bestPart, bestD = nil, nil, nil, Settings.AimFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if validTargetAim(plr) then
            local part = plr.Character:FindFirstChild(Settings.AimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
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

local function resolveTargetAim()
    if Settings.AimSticky and targetPlr and validTargetAim(targetPlr) then
        local p = targetPlr.Character:FindFirstChild(Settings.AimPart) or targetPlr.Character:FindFirstChild("HumanoidRootPart")
        if p then
            local sp, on = Camera:WorldToViewportPoint(p.Position)
            if on and sp.Z > 0 then
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if d <= Settings.AimFOV * 1.2 then
                    return targetPlr, p
                end
            end
        end
    end
    return findBestAim()
end

local function aimAt(worldPos)
    local camPos = Camera.CFrame.Position
    local desired = CFrame.lookAt(camPos, worldPos)
    local j = rnd(0.0004, 0.0018)
    desired = desired * CFrame.Angles(rnd(-j, j), rnd(-j, j), 0)
    local t = 1 - math.clamp(Settings.AimSmooth, 0.001, 0.999)
    Camera.CFrame = Camera.CFrame:Lerp(desired, t)
end

RunService.RenderStepped:Connect(function()
    if _G.FOVCircle then
        _G.FOVCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
    end
    pcall(function()
        local targetPlr, targetPart = getTarget()
        currentTarget = targetPart
        currentPlr = targetPlr
    end)
    
    if Settings.AimEnabled then
        local lp = LocalPlayer.Character
        if lp then
            local lhum = lp:FindFirstChildOfClass("Humanoid")
            if lhum and lhum.Health > 0 then
                pcall(function()
                    local plr, part = resolveTargetAim()
                    targetPlr, targetPart = plr, part
                    if part then
                        aimAt(getAimPos(plr, part))
                    end
                end)
            end
        end
    end
    
    if (Settings.AimEnabled) and not Settings.ShowFOV then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Position = center
        fovCircle.Radius = Settings.AimFOV
        fovCircle.Color = Color3.fromRGB(0, 120, 255)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)

local hitboxOriginals = {}

local function applyHitbox()
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            pcall(function()
                local character = v.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local hrp = character.HumanoidRootPart
                    if not hitboxOriginals[hrp] then
                        hitboxOriginals[hrp] = {
                            Size = hrp.Size,
                            Transparency = hrp.Transparency,
                            BrickColor = hrp.BrickColor,
                            Material = hrp.Material,
                            CanCollide = hrp.CanCollide
                        }
                    end
                    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hrp.CanCollide = false
                    if Settings.HitboxShowVisual then
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Bright red")
                        hrp.Material = Enum.Material.Neon
                    else
                        hrp.Transparency = 1
                        hrp.Material = Enum.Material.Plastic
                    end
                end
            end)
        end
    end
end

local function resetHitbox()
    for hrp, original in pairs(hitboxOriginals) do
        if hrp and hrp.Parent then
            pcall(function()
                hrp.Size = original.Size
                hrp.Transparency = original.Transparency
                hrp.BrickColor = original.BrickColor
                hrp.Material = original.Material
                hrp.CanCollide = original.CanCollide
            end)
        end
    end
    hitboxOriginals = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if Settings.HitboxEnabled then
            applyHitbox()
        end
    end
end)

local espDrawings = {}

local function clearDrawings()
    for _, d in pairs(espDrawings) do
        if d.Remove then d:Remove() end
    end
    espDrawings = {}
end

local function drawESP()
    clearDrawings()
    if not Settings.ESPEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local cf, size = plr.Character:GetBoundingBox()
                local topPos = cf.Position + Vector3.new(0, size.Y / 2, 0)
                local bottomPos = cf.Position - Vector3.new(0, size.Y / 2, 0)
                local distance = (cf.Position - Camera.CFrame.Position).Magnitude
                if distance <= Settings.ESPMaxDistance then
                    local topScreen, onScreenTop = Camera:WorldToViewportPoint(topPos)
                    local bottomScreen, onScreenBottom = Camera:WorldToViewportPoint(bottomPos)
                    if onScreenTop and onScreenBottom and topScreen.Z > 0 and bottomScreen.Z > 0 then
                        local height = math.abs(bottomScreen.Y - topScreen.Y)
                        local width = height
                        if height > 5 and height < 1000 then
                            if Settings.ESPShowBox then
                                local box = Drawing.new("Square")
                                box.Size = Vector2.new(width, height)
                                box.Position = Vector2.new(topScreen.X - width / 2, topScreen.Y)
                                box.Color = Settings.ESPColor
                                box.Thickness = 1
                                box.Filled = false
                                box.Visible = true
                                table.insert(espDrawings, box)
                            end
                            if Settings.ESPShowHealth then
                                local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                local barWidth = 3
                                local barHeight = height * healthPct
                                local bg = Drawing.new("Square")
                                bg.Size = Vector2.new(barWidth, height)
                                bg.Position = Vector2.new(topScreen.X - width / 2 - barWidth - 2, topScreen.Y)
                                bg.Color = Color3.fromRGB(0, 0, 0)
                                bg.Thickness = 1
                                bg.Filled = true
                                bg.Visible = true
                                table.insert(espDrawings, bg)
                                local bar = Drawing.new("Square")
                                bar.Size = Vector2.new(barWidth, barHeight)
                                bar.Position = Vector2.new(topScreen.X - width / 2 - barWidth - 2, topScreen.Y + (height - barHeight))
                                                              bar.Color = Settings.ESPHealthColor
                                bar.Thickness = 1
                                bar.Filled = true
                                bar.Visible = true
                                table.insert(espDrawings, bar)
                            end
                        end
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(drawESP)
end)

local function applyStretch()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local m = CFrame.new(0, 0, 0, 1, 0, 0, 0, Settings.StretchFactor, 0, 0, 0, 1)
    cam.CFrame = cam.CFrame * m
end

RunService:BindToRenderStep("ApexStretch", Enum.RenderPriority.Camera.Value + 1, function()
    if Settings.StretchEnabled then
        applyStretch()
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
    print("[SA] hook instalado com sucesso")
else
    warn("[SA] hook falhou:", hookErr)
end
