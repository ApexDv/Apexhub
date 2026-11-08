local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- ==========================================
-- VARIÁVEIS GLOBAIS
-- ==========================================
local AimbotOn, AimbotFOV, AimbotPart = false, 150, "Head"
local TeamCheckOn = false
local HitboxOn, HitboxSize = false, 10
local HitboxParts = {}

-- ==========================================
-- JANELA PRINCIPAL
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "Apex | Universal",
    Icon = "rbxassetid://1794099698676",
    Author = "",
    Folder = "ApexUniversal",
    Size = UDim2.fromOffset(450, 360),
    Theme = "Dark",
    Transparent = true,
    KeySystem = {
        Title = "Verification",
        KeyValidator = function(key) return string.lower(key) == "apex67" end,
        SaveKey = false
    }
})

-- ==========================================
-- ABAS
-- ==========================================
local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })

-- ==========================================
-- ABA COMBAT (Botões e Funções Juntos)
-- ==========================================
TabCombat:Section({ Title = "Aimbot" })
TabCombat:Toggle({ Title = "Aimbot", Value = false, Callback = function(s) AimbotOn = s end })
TabCombat:Toggle({ Title = "Team Check", Value = false, Callback = function(s) TeamCheckOn = s end })
TabCombat:Dropdown({ Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Value = "Head", Callback = function(v) AimbotPart = v end })
TabCombat:Slider({ Title = "FOV", Value = { Min = 10, Max = 500, Default = 150 }, Callback = function(v) AimbotFOV = v end })

TabCombat:Section({ Title = "Hitbox" })
TabCombat:Toggle({ Title = "Hitbox", Value = false, Callback = function(s) HitboxOn = s end })
TabCombat:Slider({ Title = "Hitbox Size", Value = { Min = 2, Max = 30, Default = 10 }, Callback = function(v) HitboxSize = v end })

-- ==========================================
-- LOOP DE AÇÃO (AIMBOT E HITBOX)
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- 1. Lógica do Aimbot
    if AimbotOn then
        local closest, minDist = nil, AimbotFOV
        local center = Camera.ViewportSize / 2
        local myTeam = LP.Team
        local myShirt = LP.Character and LP.Character:FindFirstChild("Shirt")
        local myColor = myShirt and myShirt.ShirtTemplate or nil
        
        for _, p in pairs(Players:GetPlayers()) do
            local isTeammate = false
            
            -- Team Check (Time Oficial, Camisa ou Tag no Nome)
            if TeamCheckOn and myTeam and p.Team and myTeam == p.Team then isTeammate = true end
            if TeamCheckOn and not isTeammate and myColor then
                local pShirt = p.Character and p.Character:FindFirstChild("Shirt")
                if pShirt and pShirt.ShirtTemplate == myColor then isTeammate = true end
            end
            if TeamCheckOn and not isTeammate then
                local myName = string.match(LP.Name, "^%[%w+%]")
                local pName = string.match(p.Name, "^%[%w+%]")
                if myName and pName and myName == pName then isTeammate = true end
            end

            -- Se não for do time e tiver o personagem, mira
            if p ~= LP and not isTeammate and p.Character and p.Character:FindFirstChild(AimbotPart) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = p.Character[AimbotPart]
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < minDist then minDist = dist closest = part end
                    end
                end
            end
        end
        if closest then pcall(function() Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 1) end) end
    end

    -- 2. Lógica da Hitbox
    if HitboxOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not HitboxParts[p] then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local hb = Instance.new("Part")
                    hb.Name = "ApexHitbox"
                    hb.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hb.Transparency = 1 
                    hb.CanCollide = false
                    hb.CanQuery = true 
                    hb.Massless = true
                    hb.Parent = p.Character
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = root
                    weld.Part1 = hb
                    weld.Parent = hb
                    hb.CFrame = root.CFrame
                    
                    HitboxParts[p] = hb
                end
            elseif p.Character and HitboxParts[p] then
                local hb = HitboxParts[p]
                if hb and hb.Parent then
                    hb.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                else
                    HitboxParts[p] = nil 
                end
            end
        end
    else
        for p, hb in pairs(HitboxParts) do 
            if hb then hb:Destroy() HitboxParts[p] = nil end 
        end
    end
end)
-- ==========================================
-- CRIAÇÃO DAS OUTRAS ABAS
-- ==========================================
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })
local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
local TabInfo = Window:Tab({ Title = "Info", Icon = "info" })

-- ==========================================
-- ABA PLAYER (SPEED E JUMP)
-- ==========================================
local SpeedOn, SpeedVal = false, 16
local JumpOn, JumpVal = false, 50
local InfJumpOn = false

TabPlayer:Section({ Title = "Movement" })
TabPlayer:Toggle({ 
    Title = "Speed", Value = false, 
    Callback = function(s) 
        SpeedOn = s 
        if not s and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function() LP.Character.Humanoid.WalkSpeed = 16 end)
        end
    end 
})
TabPlayer:Slider({ Title = "Speed Value", Value = { Min = 16, Max = 200, Default = 16 }, Callback = function(v) SpeedVal = v end })

TabPlayer:Toggle({ 
    Title = "Jump", Value = false, 
    Callback = function(s) 
        JumpOn = s 
        if not s and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function() LP.Character.Humanoid.JumpPower = 50 end)
        end
    end 
})
TabPlayer:Slider({ Title = "Jump Power", Value = { Min = 50, Max = 300, Default = 50 }, Callback = function(v) JumpVal = v end })

TabPlayer:Toggle({ Title = "Infinite Jump", Value = false, Callback = function(s) InfJumpOn = s end })

-- Loop do Player
RunService.RenderStepped:Connect(function()
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LP.Character.Humanoid
        if SpeedOn then pcall(function() hum.WalkSpeed = SpeedVal end) end
        if JumpOn then pcall(function() hum.JumpPower = JumpVal hum.UseJumpPower = true end) end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJumpOn and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then 
        pcall(function() LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) 
    end
end)

-- ==========================================
-- ABA VISUALS (ESP)
-- ==========================================
local ESPOn, ESPBox, ESPLine, ESPHealth = false, false, false, false
local ESPObjs = {}

TabVisuals:Section({ Title = "Player ESP" })
TabVisuals:Toggle({ Title = "Enable ESP", Icon = "eye", Value = false, Callback = function(s) ESPOn = s end })
TabVisuals:Toggle({ Title = "Box", Icon = "box", Value = false, Callback = function(s) ESPBox = s end })
TabVisuals:Toggle({ Title = "Tracer Line", Icon = "route", Value = false, Callback = function(s) ESPLine = s end })
TabVisuals:Toggle({ Title = "Health Bar", Icon = "heart", Value = false, Callback = function(s) ESPHealth = s end })

-- Loop do ESP
RunService.RenderStepped:Connect(function()
    if not ESPOn then
        for _, obj in pairs(ESPObjs) do 
            obj.Box.Visible = false obj.BoxFill.Visible = false obj.Line.Visible = false obj.Health.Visible = false obj.HealthOutline.Visible = false
        end
        return
    end
    
    for player, obj in pairs(ESPObjs) do
        if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            obj.Box:Remove() obj.BoxFill:Remove() obj.Line:Remove() obj.Health:Remove() obj.HealthOutline:Remove() ESPObjs[player] = nil
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local rightFoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if head and root and rightFoot and hum and hum.Health > 0 then
                if not ESPObjs[p] then
                    local box = Drawing.new("Square") box.Thickness = 1.5 box.Filled = false
                    local boxFill = Drawing.new("Square") boxFill.Thickness = 1 boxFill.Filled = true boxFill.Color = Color3.new(0,0,0) boxFill.Transparency = 0.5
                    local line = Drawing.new("Line") line.Thickness = 1
                    local health = Drawing.new("Line") health.Thickness = 2
                    local healthOutline = Drawing.new("Line") healthOutline.Thickness = 3 healthOutline.Color = Color3.new(0,0,0)
                    ESPObjs[p] = {Box = box, BoxFill = boxFill, Line = line, Health = health, HealthOutline = healthOutline}
                end
                
                local obj = ESPObjs[p]
                local hPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                local fPos = Camera:WorldToViewportPoint(rightFoot.Position - Vector3.new(0, 1, 0))
                
                if onScreen then
                    local espColor = Color3.fromRGB(255, 255, 255)
                    if LP.Team and p.Team and LP.Team == p.Team then espColor = Color3.fromRGB(50, 255, 50) end
                    
                    local height = math.abs(hPos.Y - fPos.Y)
                    local width = height / 2.5 
                    local posX = hPos.X - width/2
                    local posY = hPos.Y

                    obj.Box.Size = Vector2.new(width, height)
                    obj.Box.Position = Vector2.new(posX, posY)
                    obj.Box.Color = espColor
                    obj.Box.Visible = ESPBox
                    
                    obj.BoxFill.Size = Vector2.new(width, height)
                    obj.BoxFill.Position = Vector2.new(posX, posY)
                    obj.BoxFill.Visible = ESPBox
                    
                    obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    obj.Line.To = Vector2.new(hPos.X, hPos.Y)
                    obj.Line.Color = espColor
                    obj.Line.Visible = ESPLine

                    if ESPHealth then
                        local hpPct = hum.Health / hum.MaxHealth
                        if hpPct < 0 then hpPct = 0 end
                        if hpPct > 1 then hpPct = 1 end
                        local barHeight = height * hpPct
                        
                        obj.HealthOutline.From = Vector2.new(posX - 6, posY + height)
                        obj.HealthOutline.To = Vector2.new(posX - 6, posY)
                        obj.HealthOutline.Visible = true
                        
                        obj.Health.From = Vector2.new(posX - 6, posY + height)
                        obj.Health.To = Vector2.new(posX - 6, posY + height - barHeight)
                        obj.Health.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0)
                        obj.Health.Visible = true
                    else
                        obj.Health.Visible = false
                        obj.HealthOutline.Visible = false
                    end
                else
                    obj.Box.Visible, obj.BoxFill.Visible, obj.Line.Visible, obj.Health.Visible, obj.HealthOutline.Visible = false, false, false, false, false
                end
            end
        end
    end
end)

-- ==========================================
-- ABA INFO (DISCORD E ATUALIZAÇÕES)
-- ==========================================
TabInfo:Section({ Title = "Discord Server" })
TabInfo:Paragraph({
    Title = "Não perca as atualizações!",
    Content = "Entre no nosso servidor do Discord para ficar por dentro das novidades e não perder nenhuma versão nova do script."
})

TabInfo:Paragraph({
    Title = "Link do Servidor:",
    Content = "https://discord.gg/9uQjBAAaP"
})

TabInfo:Button({
    Title = "Copiar Link do Discord",
    Icon = "copy",
    IconAlign = "Left",
    Callback = function()
        setclipboard("https://discord.gg/9uQjBAAaP")
        WindUI:Notify({ 
            Title = "Copiado!", 
            Content = "O link já está na sua área de transferência.", 
            Duration = 3, 
            Icon = "check" 
        })
    end
})
