local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local defaultCameraFOV = camera.FieldOfView

getgenv().SilentAimSettings = {
    Enabled = false, ForceFieldCheck = true, TargetPart = "HumanoidRootPart", Method = "Raycast",
    VisibleCheck = true, TeamCheck = true, Smoothing = 0, HitChance = 100, FOVEnabled = true,
    FOVRadius = 120, FOVColor = Color3.fromRGB(255, 255, 255), FOVThickness = 1,
    FriendCheck = true, SpinbotSpeed = 0, ESPEnabled = false, ESPNamesEnabled = true,
    ESPTargetColor = Color3.fromRGB(255, 182, 255), TargetTeams = { Inmates = true, Guards = true, Criminals = true },
    HostileCheck = false, TrespassCheck = false, TracerColor = Color3.fromRGB(255, 182, 255),
    TracerThickness = 0.1, TracerESPEnabled = false, TracerTargetOnly = false, Autoshoot = false,
    SilentAimRange = 500, CameraFOVEnabled = false, CameraFOV = 70, NoclipEnabled = false,
    InfiniteJumpEnabled = false, InvisibleEnabled = false, AntiInvisibleEnabled = false,
    TargetOnPlayer = {}, IgnoreTargets = {}, AimMode = "FOV", GunModEnabled = false,
    AutoFire = false, FastFirerateEnabled = false, FireRateValue = 0.01, AutoReloadEnabled = false,
    HitboxExpanderEnabled = false, HitboxTeamCheck = true, GetWeaponsList = {}, AutoGetWeapons = false,
    InfiniteStamina = false, HitboxSize = 1, HitboxTransparency = 0.5, HitboxShape = "Box",
    GunSwitchList = {}, GunSwitchDelay = 0.01, GunSwitchEnabled = false, GunSwitchCycleAll = false,
    AntiSitEnabled = false, VehicleFlyEnabled = false, VehicleSpeedEnabled = false
}
local Settings = getgenv().SilentAimSettings
local currentTarget = nil
local shootRemote = nil
local smoothedTargetPosition = nil

pcall(function()
    local gunRemotes = ReplicatedStorage:WaitForChild("GunRemotes", 5)
    if gunRemotes then shootRemote = gunRemotes:WaitForChild("ShootEvent", 5) end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FOVGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local fovCircle = Instance.new("Frame", screenGui)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
fovCircle.BackgroundTransparency = 1
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Settings.FOVColor
fovStroke.Thickness = Settings.FOVThickness
fovCircle.Visible = false

local function isVisible(targetCharacter)
    if not targetCharacter then return false end
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
    local localChar = player.Character
    local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not localHRP then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {player.Character, targetCharacter}
    return workspace:Raycast(targetHRP.Position, localHRP.Position - targetHRP.Position, params) == nil
end

local function isValidTarget(plr)
    if not plr or plr == player or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end
    if Settings.TeamCheck and player.Team and plr.Team == player.Team then return false end
    if Settings.VisibleCheck and not isVisible(plr.Character) then return false end
    return true
end

local function getClosestTarget()
    local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    local closest, shortestDistance = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = plr.Character:FindFirstChild(Settings.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist <= Settings.FOVRadius then
                        local worldDist = (part.Position - localRoot.Position).Magnitude
                        if worldDist < shortestDistance then closest = part; shortestDistance = worldDist end
                    end
                end
            end
        end
    end
    return closest
end

task.spawn(function()
    while task.wait(0.1) do if Settings.Enabled then currentTarget = getClosestTarget() else currentTarget = nil end end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Settings.Enabled and currentTarget and self == workspace and (method == "Raycast" or method == "FindPartOnRay") then
        local origin = args[2]
        if method == "Raycast" then args[3] = (currentTarget.Position - origin).Unit * 1000 end
    end
    return oldNamecall(self, table.unpack(args))
end))

RunService.RenderStepped:Connect(function(dt)
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
        if fovCircle:FindFirstChild("UIStroke") then fovCircle.UIStroke.Thickness = Settings.FOVThickness end
    end
    if Settings.Enabled and currentTarget and currentTarget.Parent then
        if not smoothedTargetPosition then smoothedTargetPosition = currentTarget.Position
        else smoothedTargetPosition = smoothedTargetPosition:Lerp(currentTarget.Position, 1) end
    else smoothedTargetPosition = nil end
end)

local function updateFOVPosition()
    if not fovCircle then return end
    if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
        fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        local m = UserInputService:GetMouseLocation()
        fovCircle.Position = UDim2.new(0, m.X, 0, m.Y)
    end
end
local espFolder = Instance.new("Folder", game:GetService("CoreGui"))
espFolder.Name = "ApexESP"

RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if Settings.ESPEnabled and hum and hum.Health > 0 then
                if not char:FindFirstChild("ApexHL") then
                    local hl = Instance.new("Highlight", char)
                    hl.Name = "ApexHL"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    local color = plr.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255, 0, 0)
                    hl.FillColor = color; hl.OutlineColor = color
                end
            else
                local oldHl = char:FindFirstChild("ApexHL")
                if oldHl then oldHl:Destroy() end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Settings.HitboxExpanderEnabled then
                    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hrp.Transparency = 0.5; hrp.CanCollide = false; hrp.Material = Enum.Material.ForceField
                else
                    hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1
                end
            end
        end
    end
    local myChar = player.Character
    if myChar and Settings.NoclipEnabled then
        for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJumpEnabled then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local getEquippedWeapon = function()
    local char = player.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do if child:IsA("Tool") then return child end end
    return nil
end

RunService.Heartbeat:Connect(function()
    if Settings.AutoReloadEnabled then
        local weapon = getEquippedWeapon()
        if weapon then
            local currentAmmo = weapon:GetAttribute("Local_CurrentAmmo") or 0
            local reloadSession = weapon:GetAttribute("Local_ReloadSession") or 0
            if currentAmmo <= 0 and reloadSession == 0 then
                local FuncReloadRemote = ReplicatedStorage:FindFirstChild("GunRemotes") and ReplicatedStorage.GunRemotes:FindFirstChild("FuncReload")
                if FuncReloadRemote then FuncReloadRemote:InvokeServer() end
            end
        end
    end
    local antiJump = player.Character and player.Character:FindFirstChild("AntiJump")
    if antiJump then antiJump.Disabled = Settings.InfiniteStamina end
end)

RunService.RenderStepped:Connect(function()
    if Settings.VehicleFlyEnabled or Settings.VehicleSpeedEnabled then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            local car = hum.SeatPart.Parent
            if car then
                local main = car:FindFirstChild("Main")
                if Settings.VehicleFlyEnabled and main then car:PivotTo(main.CFrame * CFrame.new(0, 1.5, 0)) end
                if Settings.VehicleSpeedEnabled then
                    local rwd = car:FindFirstChild("RWD")
                    local lw = car:FindFirstChild("LW") and car.LW:FindFirstChild("VS")
                    local rw = car:FindFirstChild("RW") and car.RW:FindFirstChild("VS")
                    if rwd and lw and rw then rwd.MaxSpeed = 500; lw.MaxSpeed = 500; rw.MaxSpeed = 500 end
                end
            end
        end
    end
end)

local function hookAntiSit()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Seated:Connect(function(active, seat)
            if Settings.AntiSitEnabled and active and seat then hum.Sit = false; hum.Jump = true end
        end)
    end
end
player.CharacterAdded:Connect(function(c) task.wait(1); hookAntiSit() end)
if player.Character then hookAntiSit() end

task.spawn(function()
    local gettingWeapon = false
    getgenv().GetWeapons = function()
        task.spawn(function()
            for _, ToolName in ipairs({"AK-47", "Remington 870", "M9", "M700", "M4A1"}) do
                if not gettingWeapon then
                    gettingWeapon = true
                    local Char = player.Character
                    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
                    if Root and not player.Backpack:FindFirstChild(ToolName) then
                        local Giver
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v.Name == "TouchGiver" and v:GetAttribute("ToolName") == ToolName then Giver = v:FindFirstChildWhichIsA("BasePart"); break end
                        end
                        if Giver then
                            local oldCF = Giver.CFrame
                            Giver.CFrame = oldCF - Vector3.new(0, 15.5, 0)
                            Root.Anchored = true
                            Char:PivotTo(Giver.CFrame + Vector3.new(0, 5, 0))
                            task.wait(0.2)
                            firetouchinterest(Giver, Root, 0)
                            task.wait(0.2)
                            firetouchinterest(Giver, Root, 1)
                            Giver.CFrame = oldCF
                            Root.Anchored = false
                        end
                    end
                    gettingWeapon = false
                end
                task.wait(0.5)
            end
        end)
    end
end)
local wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local window = wind:CreateWindow({
    Title = "Apex | Prison Life",
    Author = "by APEX",
    Folder = "ApexPrisonLife",
    Size = UDim2.fromOffset(600, 420),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
})
local AimTab = window:Tab({ Title = "Combat", Icon = "crosshair" })
AimTab:Toggle({ Title = "Silent Aim", Desc = "Puxa o tiro para o inimigo", Default = false, Callback = function(v) Settings.Enabled = v end })
AimTab:Toggle({ Title = "Visible Check", Desc = "Só atira se visível", Default = true, Callback = function(v) Settings.VisibleCheck = v end })
AimTab:Toggle({ Title = "Team Check", Desc = "Não atira no time", Default = true, Callback = function(v) Settings.TeamCheck = v end })
AimTab:Toggle({ Title = "Autoshoot", Desc = "Atira automaticamente", Default = false, Callback = function(v) Settings.Autoshoot = v end })
AimTab:Slider({ Title = "FOV Radius", Step = 5, Value = { Min = 10, Max = 500, Default = 120 }, Callback = function(v) Settings.FOVRadius = v end })
AimTab:Slider({ Title = "Hit Chance (%)", Step = 1, Value = { Min = 0, Max = 100, Default = 100 }, Callback = function(v) Settings.HitChance = v end })
AimTab:Dropdown({ Title = "Target Part", Values = {"HumanoidRootPart", "Head", "Torso"}, Default = "HumanoidRootPart", Callback = function(v) Settings.TargetPart = v end })

local VisTab = window:Tab({ Title = "Visuals", Icon = "eye" })
VisTab:Toggle({ Title = "Enable ESP", Desc = "Destaque nos inimigos", Default = false, Callback = function(v) Settings.ESPEnabled = v end })
VisTab:Toggle({ Title = "Hitbox Expander", Desc = "Aumenta a hitbox", Default = false, Callback = function(v) Settings.HitboxExpanderEnabled = v end })
VisTab:Slider({ Title = "Hitbox Size", Step = 1, Value = { Min = 2, Max = 20, Default = 5 }, Callback = function(v) Settings.HitboxSize = v end })
local WepTab = window:Tab({ Title = "Weapons", Icon = "target" })
WepTab:Toggle({ Title = "Auto Reload", Desc = "Recarrega sozinho", Default = false, Callback = function(v) Settings.AutoReloadEnabled = v end })
WepTab:Toggle({ Title = "Infinite Stamina", Desc = "Corre sem cansar", Default = false, Callback = function(v) Settings.InfiniteStamina = v end })
WepTab:Button({ Title = "Get Weapons", Desc = "Puxa armas do mapa", Callback = function() getgenv().GetWeapons() end })

local CarTab = window:Tab({ Title = "Cars", Icon = "car" })
CarTab:Toggle({ Title = "Car Fly", Desc = "Faz o carro voar", Default = false, Callback = function(v) Settings.VehicleFlyEnabled = v end })
CarTab:Toggle({ Title = "Car Speed", Desc = "Velocidade máxima", Default = false, Callback = function(v) Settings.VehicleSpeedEnabled = v end })

local MiscTab = window:Tab({ Title = "Misc", Icon = "folder" })
MiscTab:Toggle({ Title = "Infinite Jump", Desc = "Pula sem parar", Default = false, Callback = function(v) Settings.InfiniteJumpEnabled = v end })
MiscTab:Toggle({ Title = "Noclip", Desc = "Atravessa paredes", Default = false, Callback = function(v) Settings.NoclipEnabled = v end })
MiscTab:Toggle({ Title = "Anti-Sit", Desc = "Não deixa ser sentado", Default = false, Callback = function(v) Settings.AntiSitEnabled = v end })

RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Size = UDim2.fromOffset(Settings.FOVRadius * 2, Settings.FOVRadius * 2)
        if fovCircle:FindFirstChild("UIStroke") then fovCircle.UIStroke.Thickness = Settings.FOVThickness end
    end
    updateFOVPosition()
end)
