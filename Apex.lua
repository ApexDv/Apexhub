
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- ==========================================
-- ESTADO GLOBAL
-- ==========================================
local AimlockOn = false
local AimPart = "Head"
local AimFOV = 150
local AimSmooth = 1
local ShowFOV = false
local TriggerBotOn = false

local ESPOn = false
local ESPBox = false
local ESPName = false
local ESPHealth = false
local ESPDistance = false
local ESPSkeleton = false
local ESPColor = Color3.fromRGB(255, 50, 50)
local ESPObjs = {}
local SkeletonObjs = {}

local HitboxOn = false
local HitboxSize = 5
local HitboxTransparency = 0.5
local HitboxColor = Color3.fromRGB(255, 0, 0)
local HitboxParts = {}

-- ==========================================
-- MÓDULO 1: AIMLOCK
-- ==========================================
local function GetClosestTarget()
    local closest = nil
    local closestDist = AimFOV
    local center = Camera.ViewportSize / 2
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(AimPart) 
                        or player.Character:FindFirstChild("Head")
                        or player.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = AimFOV
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if ShowFOV and AimlockOn then
        FOVCircle.Visible = true
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = AimFOV
    else
        FOVCircle.Visible = false
    end
    if AimlockOn then
        local target = GetClosestTarget()
        if target then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, target.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, AimSmooth)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if TriggerBotOn then
            local target = GetClosestTarget()
            if target then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(500, 500))
                end)
            end
        end
    end
end)

-- ==========================================
-- MÓDULO 2: HITBOX
-- ==========================================
local function CreateHitbox(player)
    if HitboxParts[player] then return end
    local char = player.Character
    if not char then return end
    local hitbox = Instance.new("Part")
    hitbox.Name = "ApexHitbox"
    hitbox.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    hitbox.Transparency = HitboxTransparency
    hitbox.Color = HitboxColor
    hitbox.Material = Enum.Material.Neon
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Parent = char
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = root
        weld.Part1 = hitbox
        weld.Parent = hitbox
        hitbox.CFrame = root.CFrame
    end
    HitboxParts[player] = hitbox
end

local function RemoveHitbox(player)
    if HitboxParts[player] then
        pcall(function() HitboxParts[player]:Destroy() end)
        HitboxParts[player] = nil
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if not HitboxOn then
            for player, _ in pairs(HitboxParts) do
                RemoveHitbox(player)
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not HitboxParts[player] then
                        CreateHitbox(player)
                    else
                        local hb = HitboxParts[player]
                        if hb and hb.Parent then
                            hb.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                            hb.Transparency = HitboxTransparency
                            hb.Color = HitboxColor
                        else
                            HitboxParts[player] = nil
                            CreateHitbox(player)
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- MÓDULO 3: ESP
-- ==========================================
local R15Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6Bones = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function GetBoneTable(char)
    if char:FindFirstChild("UpperTorso") then return R15Bones else return R6Bones end
end

local function CreateSkeleton(player)
    if SkeletonObjs[player] then return end
    local lines = {}
    for i = 1, #R15Bones do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = ESPColor
        line.Transparency = 1
        line.Visible = false
        table.insert(lines, line)
    end
    SkeletonObjs[player] = lines
end

local function UpdateSkeleton(player, char)
    local lines = SkeletonObjs[player]
    if not lines then return end
    local boneTable = GetBoneTable(char)
    for i, bonePair in ipairs(boneTable) do
        local part1 = char:FindFirstChild(bonePair[1])
        local part2 = char:FindFirstChild(bonePair[2])
        if part1 and part2 then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
            if onScreen1 and onScreen2 and lines[i] then
                lines[i].From = Vector2.new(pos1.X, pos1.Y)
                lines[i].To = Vector2.new(pos2.X, pos2.Y)
                lines[i].Color = ESPColor
                lines[i].Visible = true
            elseif lines[i] then
                lines[i].Visible = false
            end
        elseif lines[i] then
            lines[i].Visible = false
        end
    end
end

local function CreateESP(player)
    if ESPObjs[player] then return end
    local obj = {}
    obj.name = Drawing.new("Text")
    obj.name.Center = true
    obj.name.Outline = true
    obj.name.Size = 14
    obj.name.Font = 2
    obj.name.Color = Color3.fromRGB(255, 255, 255)
    obj.name.Visible = false
    obj.box = Drawing.new("Square")
    obj.box.Thickness = 1.5
    obj.box.Color = ESPColor
    obj.box.Filled = false
    obj.box.Visible = false
    obj.health = Drawing.new("Text")
    obj.health.Outline = true
    obj.health.Size = 12
    obj.health.Font = 2
    obj.health.Visible = false
    obj.distance = Drawing.new("Text")
    obj.distance.Center = true
    obj.distance.Outline = true
    obj.distance.Size = 12
    obj.distance.Font = 2
    obj.distance.Color = Color3.fromRGB(200, 200, 200)
    obj.distance.Visible = false
    ESPObjs[player] = obj
end

local function UpdateESP(player, char)
    local obj = ESPObjs[player]
    if not obj then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if head and root and hum then
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos = Camera:WorldToViewportPoint(root.Position)
        if onScreen then
            if ESPName then
                obj.name.Text = player.Name
                obj.name.Position = Vector2.new(headPos.X, headPos.Y - 20)
                obj.name.Visible = true
            else obj.name.Visible = false end
            if ESPBox then
                local height = math.abs(headPos.Y - rootPos.Y) * 2
                local width = height / 2
                obj.box.Size = Vector2.new(width, height)
                obj.box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/2)
                obj.box.Color = ESPColor
                obj.box.Visible = true
            else obj.box.Visible = false end
            if ESPHealth then
                local hpPct = hum.Health / hum.MaxHealth
                obj.health.Text = math.floor(hum.Health) .. " HP"
                obj.health.Position = Vector2.new(headPos.X + 30, headPos.Y)
                obj.health.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0)
                obj.health.Visible = true
            else obj.health.Visible = false end
            if ESPDistance then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    obj.distance.Text = math.floor(dist) .. "m"
                    obj.distance.Position = Vector2.new(headPos.X, headPos.Y + 10)
                    obj.distance.Visible = true
                else obj.distance.Visible = false end
            else obj.distance.Visible = false end
        else
            obj.name.Visible = false
            obj.box.Visible = false
            obj.health.Visible = false
            obj.distance.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if ESPOn then
                if not ESPObjs[player] then CreateESP(player) end
                if not SkeletonObjs[player] then CreateSkeleton(player) end
                UpdateESP(player, char)
                if ESPSkeleton then
                    UpdateSkeleton(player, char)
                else
                    if SkeletonObjs[player] then
                        for _, line in pairs(SkeletonObjs[player]) do line.Visible = false end
                    end
                end
            else
                if ESPObjs[player] then
                    for _, obj in pairs(ESPObjs[player]) do obj.Visible = false end
                end
                if SkeletonObjs[player] then
                    for _, line in pairs(SkeletonObjs[player]) do line.Visible = false end
                end
            end
        end
    end
end)

-- ==========================================
-- INTERFACE WINDUI
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "Apex Hub | Universal",
    Icon = "rbxassetid://13148284531",
    Author = "Apex",
    Folder = "ApexUniversal",
    Size = UDim2.fromOffset(420, 300),
    Theme = "Dark",
    Transparent = true,
    SideBarWidth = 120,
})

-- ABA 1: AIMLOCK
local AimTab = Window:Tab({ Title = "Aimlock", Icon = "crosshair" })
AimTab:Section({ Title = "Mira Cravada" })
AimTab:Toggle({
    Title = "Ativar Aimlock",
    Value = false,
    Callback = function(state) AimlockOn = state end
})
AimTab:Dropdown({
    Title = "Parte do Corpo",
    Values = {"Head", "HumanoidRootPart"},
    Value = "Head",
    Callback = function(option) AimPart = option end
})
AimTab:Slider({
    Title = "FOV (Raio de Mira)",
    Value = { Min = 10, Max = 500, Default = 150 },
    Callback = function(v) AimFOV = v end
})
AimTab:Slider({
    Title = "Suavidade (1 = Cravado)",
    Value = { Min = 0.05, Max = 1, Default = 1 },
    Callback = function(v) AimSmooth = v end
})
AimTab:Toggle({
    Title = "Mostrar FOV Circle",
    Value = false,
    Callback = function(state) ShowFOV = state end
})
AimTab:Section({ Title = "Extras" })
AimTab:Toggle({
    Title = "Trigger Bot (Atira sozinho)",
    Value = false,
    Callback = function(state) TriggerBotOn = state end
})

-- ABA 2: HITBOX
local HitboxTab = Window:Tab({ Title = "Hitbox", Icon = "box" })
HitboxTab:Section({ Title = "Hitbox Expander" })
HitboxTab:Toggle({
    Title = "Ativar Hitbox Expander",
    Desc = "Aumenta a hitbox dos inimigos",
    Value = false,
    Callback = function(state) HitboxOn = state end
})
HitboxTab:Slider({
    Title = "Tamanho da Hitbox",
    Value = { Min = 2, Max = 20, Default = 5 },
    Callback = function(v) HitboxSize = v end
})
HitboxTab:Slider({
    Title = "Transparência",
    Value = { Min = 0, Max = 1, Default = 0.5 },
    Callback = function(v) HitboxTransparency = v end
})
HitboxTab:ColorPicker({
    Title = "Cor da Hitbox",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(color) HitboxColor = color end
})

-- ABA 3: ESP
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
ESPTab:Section({ Title = "ESP Principal" })
ESPTab:Toggle({
    Title = "Ativar ESP",
    Value = false,
    Callback = function(state)
        ESPOn = state
        if not state then
            for _, obj in pairs(ESPObjs) do
                for _, v in pairs(obj) do pcall(function() v.Visible = false end) end
            end
            for _, lines in pairs(SkeletonObjs) do
                for _, line in pairs(lines) do pcall(function() line.Visible = false end) end
            end
        end
    end
})
ESPTab:ColorPicker({
    Title = "Cor do ESP",
    Color = Color3.fromRGB(255, 50, 50),
    Callback = function(color) 
        ESPColor = color
        for _, obj in pairs(ESPObjs) do
            pcall(function() obj.box.Color = color end)
        end
        for _, lines in pairs(SkeletonObjs) do
            for _, line in pairs(lines) do pcall(function() line.Color = color end) end
        end
    end
})
ESPTab:Section({ Title = "Escolha o que mostrar" })
ESPTab:Toggle({ Title = "Mostrar Nome", Value = false, Callback = function(state) ESPName = state end })
ESPTab:Toggle({ Title = "Mostrar Caixa (Box)", Value = false, Callback = function(state) ESPBox = state end })
ESPTab:Toggle({ Title = "Mostrar Vida", Value = false, Callback = function(state) ESPHealth = state end })
ESPTab:Toggle({ Title = "Mostrar Distância", Value = false, Callback = function(state) ESPDistance = state end })
ESPTab:Toggle({ Title = "Mostrar Esqueleto (Skeleton)", Value = false, Callback = function(state) ESPSkeleton = state end })

-- ABA 4: CONFIG
local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })
ConfigTab:Button({
    Title = "Restaurar Tudo",
    Callback = function()
        AimlockOn = false
        TriggerBotOn = false
        ESPOn = false
        ESPBox = false
        ESPName = false
        ESPHealth = false
        ESPDistance = false
        ESPSkeleton = false
        ShowFOV = false
        HitboxOn = false
        for _, obj in pairs(ESPObjs) do
            for _, v in pairs(obj) do pcall(function() v.Visible = false end) end
        end
        for _, lines in pairs(SkeletonObjs) do
            for _, line in pairs(lines) do pcall(function() line.Visible = false end) end
        end
        for player, _ in pairs(HitboxParts) do
            RemoveHitbox(player)
        end
        FOVCircle.Visible = false
        WindUI:Notify({ Title = "Apex Hub", Content = "Tudo restaurado.", Icon = "check", Duration = 3 })
    end
})

WindUI:Notify({
    Title = "Apex Hub | Universal",
    Content = "13 funções carregadas com sucesso!",
    Duration = 5,
    Icon = "check"
})
        else
            obj.name.Visible = false
            obj.box.Visible = false
            obj.health.Visible = false
            obj.distance.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if ESPOn then
                if not ESPObjs[player] then CreateESP(player) end
                if not SkeletonObjs[player] then CreateSkeleton(player) end
                UpdateESP(player, char)
                if ESPSkeleton then
                    UpdateSkeleton(player, char)
                else
                    if SkeletonObjs[player] then
                        for _, line in pairs(SkeletonObjs[player]) do line.Visible = false end
                    end
                end
            else
                if ESPObjs[player] then
                    for _, obj in pairs(ESPObjs[player]) do obj.Visible = false end
                end
                if SkeletonObjs[player] then
                    for _, line in pairs(SkeletonObjs[player]) do line.Visible = false end
                end
            end
        end
    end
end)

-- ==========================================
-- INTERFACE WINDUI
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "Apex Hub | Universal",
    Icon = "rbxassetid://13148284531",
    Author = "Apex",
    Folder = "ApexUniversal",
    Size = UDim2.fromOffset(420, 300),
    Theme = "Dark",
    Transparent = true,
    SideBarWidth = 120,
})

-- ABA 1: AIMLOCK
local AimTab = Window:Tab({ Title = "Aimlock", Icon = "crosshair" })
AimTab:Section({ Title = "Mira Cravada" })
AimTab:Toggle({
    Title = "Ativar Aimlock",
    Value = false,
    Callback = function(state) AimlockOn = state end
})
AimTab:Dropdown({
    Title = "Parte do Corpo",
    Values = {"Head", "HumanoidRootPart"},
    Value = "Head",
    Callback = function(option) AimPart = option end
})
AimTab:Slider({
    Title = "FOV (Raio de Mira)",
    Value = { Min = 10, Max = 500, Default = 150 },
    Callback = function(v) AimFOV = v end
})
AimTab:Slider({
    Title = "Suavidade (1 = Cravado)",
    Value = { Min = 0.05, Max = 1, Default = 1 },
    Callback = function(v) AimSmooth = v end
})
AimTab:Toggle({
    Title = "Mostrar FOV Circle",
    Value = false,
    Callback = function(state) ShowFOV = state end
})
AimTab:Section({ Title = "Extras" })
AimTab:Toggle({
    Title = "Trigger Bot (Atira sozinho)",
    Value = false,
    Callback = function(state) TriggerBotOn = state end
})

-- ABA 2: HITBOX
local HitboxTab = Window:Tab({ Title = "Hitbox", Icon = "box" })
HitboxTab:Section({ Title = "Hitbox Expander" })
HitboxTab:Toggle({
    Title = "Ativar Hitbox Expander",
    Desc = "Aumenta a hitbox dos inimigos",
    Value = false,
    Callback = function(state) HitboxOn = state end
})
HitboxTab:Slider({
    Title = "Tamanho da Hitbox",
    Value = { Min = 2, Max = 20, Default = 5 },
    Callback = function(v) HitboxSize = v end
})
HitboxTab:Slider({
    Title = "Transparência",
    Value = { Min = 0, Max = 1, Default = 0.5 },
    Callback = function(v) HitboxTransparency = v end
})
HitboxTab:ColorPicker({
    Title = "Cor da Hitbox",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(color) HitboxColor = color end
})

-- ABA 3: ESP
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
ESPTab:Section({ Title = "ESP Principal" })
ESPTab:Toggle({
    Title = "Ativar ESP",
    Value = false,
    Callback = function(state)
        ESPOn = state
        if not state then
            for _, obj in pairs(ESPObjs) do
                for _, v in pairs(obj) do pcall(function() v.Visible = false end) end
            end
            for _, lines in pairs(SkeletonObjs) do
                for _, line in pairs(lines) do pcall(function() line.Visible = false end) end
            end
        end
    end
})
ESPTab:ColorPicker({
    Title = "Cor do ESP",
    Color = Color3.fromRGB(255, 50, 50),
    Callback = function(color) 
        ESPColor = color
        for _, obj in pairs(ESPObjs) do
            pcall(function() obj.box.Color = color end)
        end
        for _, lines in pairs(SkeletonObjs) do
            for _, line in pairs(lines) do pcall(function() line.Color = color end) end
        end
    end
})
ESPTab:Section({ Title = "Escolha o que mostrar" })
ESPTab:Toggle({ Title = "Mostrar Nome", Value = false, Callback = function(state) ESPName = state end })
ESPTab:Toggle({ Title = "Mostrar Caixa (Box)", Value = false, Callback = function(state) ESPBox = state end })
ESPTab:Toggle({ Title = "Mostrar Vida", Value = false, Callback = function(state) ESPHealth = state end })
ESPTab:Toggle({ Title = "Mostrar Distância", Value = false, Callback = function(state) ESPDistance = state end })
ESPTab:Toggle({ Title = "Mostrar Esqueleto (Skeleton)", Value = false, Callback = function(state) ESPSkeleton = state end })

-- ABA 4: CONFIG
local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })
ConfigTab:Button({
    Title = "Restaurar Tudo",
    Callback = function()
        AimlockOn = false
        TriggerBotOn = false
        ESPOn = false
        ESPBox = false
        ESPName = false
        ESPHealth = false
        ESPDistance = false
        ESPSkeleton = false
        ShowFOV = false
        HitboxOn = false
        for _, obj in pairs(ESPObjs) do
            for _, v in pairs(obj) do pcall(function() v.Visible = false end) end
        end
        for _, lines in pairs(SkeletonObjs) do
            for _, line in pairs(lines) do pcall(function() line.Visible = false end) end
        end
        for player, _ in pairs(HitboxParts) do
            RemoveHitbox(player)
        end
        FOVCircle.Visible = false
        WindUI:Notify({ Title = "Apex Hub", Content = "Tudo restaurado.", Icon = "check", Duration = 3 })
    end
})

WindUI:Notify({
    Title = "Apex Hub | Universal",
    Content = "13 funções carregadas com sucesso!",
    Duration = 5,
    Icon = "check"
})
