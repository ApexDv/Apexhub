local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    SilentEnabled = false,
    SilentMode = "Players",
    SilentFOV = 150,
    SilentPart = "Head",
    SilentRange = 1000,
    SilentVisible = false, -- Inicia desligado
    SilentHitChance = 100,
    
    AimbotEnabled = false,
    AimbotFOV = 200,
    AimbotSmooth = 0.2,
    AimbotPart = "Head",
    
    ESPEnabled = false,
    ESPBox = false, -- Inicia desligado
    ESPHealthBar = false, -- Inicia desligado
    ESPName = false, -- Inicia desligado
    ESPDistance = false, -- Inicia desligado
    ESPColor = Color3.fromRGB(65, 145, 255),
    
    SpeedEnabled = false,
    SpeedValue = 50,
    JumpEnabled = false,
    JumpValue = 100,
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false,
}

local currentTarget = nil
local currentHighlight = nil
local espObjects = {}
local flyConnection = nil

local function antiDetect()
    local env = getfenv()
    if env.hookmetamethod ~= hookmetamethod then return true end
    if env.debug ~= debug then return true end
    if env.string ~= string then return true end
    return false
end

if antiDetect() then return end

local Window = WindUI:CreateWindow({
    Title = "Apex Hub",
    Icon = "rbxassetid://6031280882",
    Author = "Stealth Edition",
    Folder = "ApexHub",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "Dark",
    Lock = true,
    HideOnClose = true,
    MinimizeKeybind = Enum.KeyCode.RightControl
})

local SilentTab = Window:Tab({ Title = "Silent Aim", Icon = "crosshair" })
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "target" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local MovementTab = Window:Tab({ Title = "Movement", Icon = "move" })

local SilentSection = SilentTab:Section({ Title = "Configurações", TextXAlignment = "Left" })
SilentSection:Toggle({ Title = "Ativar Silent", Value = false, Callback = function(v) Settings.SilentEnabled = v end })
SilentSection:Slider({ Title = "FOV", Value = { Min = 10, Max = 500, Default = 150 }, Callback = function(v) Settings.SilentFOV = v end })
SilentSection:Slider({ Title = "Hit Chance", Value = { Min = 1, Max = 100, Default = 100 }, Suffix = "%", Callback = function(v) Settings.SilentHitChance = v end })
SilentSection:Dropdown({ Title = "Parte do Corpo", Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }, Value = "Head", Callback = function(v) Settings.SilentPart = v end })
SilentSection:Toggle({ Title = "Visible Check", Value = false, Callback = function(v) Settings.SilentVisible = v end })

local AimbotSection = AimbotTab:Section({ Title = "Camera Lock", TextXAlignment = "Left" })
AimbotSection:Toggle({ Title = "Ativar Aimbot", Value = false, Callback = function(v) Settings.AimbotEnabled = v end })
AimbotSection:Slider({ Title = "FOV", Value = { Min = 10, Max = 600, Default = 200 }, Callback = function(v) Settings.AimbotFOV = v end })
AimbotSection:Slider({ Title = "Suavidade", Value = { Min = 0.01, Max = 1, Default = 0.2 }, Callback = function(v) Settings.AimbotSmooth = v end })
AimbotSection:Dropdown({ Title = "Parte do Corpo", Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }, Value = "Head", Callback = function(v) Settings.AimbotPart = v end })

local ESPSection = ESPTab:Section({ Title = "Visual", TextXAlignment = "Left" })
ESPSection:Toggle({ Title = "Ativar ESP", Value = false, Callback = function(v) Settings.ESPEnabled = v end })
ESPSection:Toggle({ Title = "Caixa (Box)", Value = false, Callback = function(v) Settings.ESPBox = v end })
ESPSection:Toggle({ Title = "Barra de Vida", Value = false, Callback = function(v) Settings.ESPHealthBar = v end })
ESPSection:Toggle({ Title = "Nome", Value = false, Callback = function(v) Settings.ESPName = v end })
ESPSection:Toggle({ Title = "Distância", Value = false, Callback = function(v) Settings.ESPDistance = v end })

local MovSection = MovementTab:Section({ Title = "Movimento", TextXAlignment = "Left" })
MovSection:Toggle({ Title = "Speed Hack", Value = false, Callback = function(v) Settings.SpeedEnabled = v end })
MovSection:Slider({ Title = "Velocidade", Value = { Min = 16, Max = 200, Default = 50 }, Callback = function(v) Settings.SpeedValue = v end })
MovSection:Toggle({ Title = "Jump Power", Value = false, Callback = function(v) Settings.JumpEnabled = v end })
MovSection:Slider({ Title = "Força do Pulo", Value = { Min = 50, Max = 500, Default = 100 }, Callback = function(v) Settings.JumpValue = v end })
MovSection:Toggle({ Title = "Fly", Value = false, Callback = function(v) Settings.FlyEnabled = v end })
MovSection:Slider({ Title = "Velocidade do Fly", Value = { Min = 10, Max = 200, Default = 50 }, Callback = function(v) Settings.FlySpeed = v end })
MovSection:Toggle({ Title = "Noclip", Value = false, Callback = function(v) Settings.NoclipEnabled = v end })

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = tostring(math.random(100000, 999999))
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.fromOffset(Settings.SilentFOV * 2, Settings.SilentFOV * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = Settings.SilentEnabled
FOVCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(65, 145, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Parent = FOVCircle

local function isVisible(targetModel)
    if not Settings.SilentVisible then return true end
    local hrp = targetModel:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local char = LocalPlayer.Character
    local localHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not localHRP then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetModel}
    local result = workspace:Raycast(hrp.Position, localHRP.Position - hrp.Position, params)
    return result == nil
end

local function inRange(hrp)
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return true end
    return (hrp.Position - localRoot.Position).Magnitude <= Settings.SilentRange
end

local function getSilentTarget()
    if not Settings.SilentEnabled then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, shortestDist = nil, Settings.SilentFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp and inRange(hrp) and isVisible(plr.Character) then
                local part = plr.Character:FindFirstChild(Settings.SilentPart) or hrp
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if d < shortestDist then
                        closest, shortestDist = part, d
                    end
                end
            end
        end
    end
    return closest
end

local function getAimbotTarget()
    if not Settings.AimbotEnabled then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, shortestDist = nil, Settings.AimbotFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local part = plr.Character:FindFirstChild(Settings.AimbotPart) or hrp
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if d < shortestDist then
                        closest, shortestDist = part, d
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Size = UDim2.fromOffset(Settings.SilentFOV * 2, Settings.SilentFOV * 2)
    FOVCircle.Visible = Settings.SilentEnabled
    
    pcall(function()
        currentTarget = getSilentTarget()
        if currentTarget then
            if currentHighlight and currentHighlight.Parent ~= currentTarget.Parent then
                currentHighlight:Destroy()
                currentHighlight = nil
            end
            if not currentHighlight then
                currentHighlight = Instance.new("Highlight")
                currentHighlight.FillColor = Color3.fromRGB(65, 145, 255)
                currentHighlight.OutlineColor = Color3.fromRGB(65, 145, 255)
                currentHighlight.FillTransparency = 1
                currentHighlight.OutlineTransparency = 0
                currentHighlight.Parent = currentTarget.Parent
            end
        else
            if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
        end

        local aimTarget = getAimbotTarget()
        if aimTarget and Settings.AimbotEnabled then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, aimTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.AimbotSmooth)
        end
    end)
end)

local espTable = {}

local function CreateESP(player)
    if espTable[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.ESPColor
    box.Thickness = 1
    box.Filled = false
    
    local healthBg = Drawing.new("Square")
    healthBg.Visible = false
    healthBg.Color = Color3.fromRGB(40, 40, 40)
    healthBg.Thickness = 1
    healthBg.Filled = true
    
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Filled = true
    
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Font = 2
    
    local distText = Drawing.new("Text")
    distText.Visible = false
    distText.Color = Color3.fromRGB(200, 200, 200)
    distText.Size = 14
    distText.Center = true
    distText.Outline = true
    distText.Font = 2

    espTable[player] = {
        Box = box,
        HealthBg = healthBg,
        HealthBar = healthBar,
        Name = nameText,
        Distance = distText
    }
end

local function RemoveESP(player)
    if espTable[player] then
        for _, drawing in pairs(espTable[player]) do
            drawing:Remove()
        end
        espTable[player] = nil
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and espTable[player] then
            local esp = espTable[player]
            local char = player.Character
            
            if not Settings.ESPEnabled or not char then
                esp.Box.Visible = false
                esp.HealthBg.Visible = false
                esp.HealthBar.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                continue
            end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            
            if hum and hum.Health > 0 and hrp and head then
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 1.5, 0))
                
                if headOnScreen and hrpOnScreen and headPos.Z > 0 then
                    local height = math.abs(hrpPos.Y - headPos.Y)
                    local width = height / 2.5
                    local x = headPos.X - width / 2
                    local y = headPos.Y
                    
                    if Settings.ESPBox then
                        esp.Box.Visible = true
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(x, y)
                        esp.Box.Color = Settings.ESPColor
                    else
                        esp.Box.Visible = false
                    end
                    
                    if Settings.ESPHealthBar and hum.Health > 0 then
                        local hpPercent = hum.Health / hum.MaxHealth
                        local barHeight = height
                        local barWidth = 2
                        local barX = x - 6
                        local barY = y
                        
                        esp.HealthBg.Visible = true
                        esp.HealthBg.Size = Vector2.new(barWidth, barHeight)
                        esp.HealthBg.Position = Vector2.new(barX, barY)
                        
                        esp.HealthBar.Visible = true
                        esp.HealthBar.Size = Vector2.new(barWidth, barHeight * hpPercent)
                        esp.HealthBar.Position = Vector2.new(barX, barY + barHeight - (barHeight * hpPercent))
                        esp.HealthBar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - hpPercent)
                    else
                        esp.HealthBg.Visible = false
                        esp.HealthBar.Visible = false
                    end
                    
                    if Settings.ESPName then
                        esp.Name.Visible = true
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(x + width / 2, y - 18)
                    else
                        esp.Name.Visible = false
                    end
                    
                    if Settings.ESPDistance then
                        esp.Distance.Visible = true
                        local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
                        esp.Distance.Text = "[" .. math.floor(dist) .. "m]"
                        esp.Distance.Position = Vector2.new(x + width / 2, y + height + 5)
                    else
                        esp.Distance.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.HealthBg.Visible = false
                    esp.HealthBar.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.HealthBg.Visible = false
                esp.HealthBar.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
            end
        end
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

    local ignoreList
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
                if Settings.SilentEnabled and currentTarget and currentTarget.Parent then
                    if math.random(1, 100) <= Settings.SilentHitChance then
                        task.wait(math.random(15, 45) / 1000)
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

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Settings.SpeedEnabled then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = Settings.SpeedValue end
            else
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
            end
            
            if Settings.JumpEnabled then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = Settings.JumpValue end
            end
            
            if Settings.NoclipEnabled then
                local char = LocalPlayer.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                    end
                end
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.FlyEnabled then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVel.Velocity = Vector3.zero
            bodyVel.Parent = hrp
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local moveDir = Vector3.zero
                local camCFrame = Camera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then
                    bodyVel.Velocity = moveDir.Unit * Settings.FlySpeed
                else
                    bodyVel.Velocity = Vector3.zero
                end
            end)
            
            while Settings.FlyEnabled and bodyVel.Parent do
                task.wait(0.1)
            end
            connection:Disconnect()
            bodyVel:Destroy()
        end
    end
end)

if not hookOk then
    local cleanErr = string.gsub(tostring(hookErr), "%.lua:%d+:", "")
    warn("[SA] erro interno:", cleanErr)
end
