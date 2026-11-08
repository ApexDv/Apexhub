local Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
Icons.SetIconsType("geist")

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- TEMAS
WindUI:AddTheme({
    Name = "Rose", Primary = Color3.fromHex("#ff4d6d"), White = Color3.new(1,1,1), Black = Color3.new(0,0,0), Dialog = Color3.fromHex("#1a0b12"), Background = Color3.fromHex("#14080e"), BackgroundTransparency = 0, Hover = Color3.fromHex("#FFFFFF"), PanelBackground = Color3.new(1,1,1), PanelBackgroundTransparency = .95, WindowBackground = Color3.fromHex("#14080e"), WindowShadow = Color3.new(0,0,0), WindowTopbarTitle = Color3.fromHex("#FFFFFF"), WindowTopbarAuthor = Color3.fromHex("#FFFFFF"), WindowTopbarIcon = Color3.fromHex("#ff4d6d"), WindowTopbarButtonIcon = Color3.fromHex("#ff4d6d"), WindowSearchBarBackground = Color3.fromHex("#14080e"), TabBackground = Color3.fromHex("#FFFFFF"), TabBackgroundHover = Color3.fromHex("#FFFFFF"), TabBackgroundHoverTransparency = .97, TabBackgroundActive = Color3.fromHex("#FFFFFF"), TabBackgroundActiveTransparency = 0.93, TabText = Color3.fromHex("#FFFFFF"), TabTextTransparency = 0.3, TabTextTransparencyActive = 0, TabTitle = Color3.fromHex("#FFFFFF"), TabIcon = Color3.fromHex("#ff4d6d"), TabIconTransparency = 0.4, TabIconTransparencyActive = 0.1, TabBorderTransparency = 1, TabBorderTransparencyActive = 0.75, TabBorder = Color3.fromHex("#ff4d6d"), ElementBackground = Color3.fromHex("#FFFFFF"), ElementBackgroundTransparency = .93, ElementBackgroundHover = WindUI.Creator:AddColor("ElementBackground", "#ffffff", 1/10), ElementTitle = Color3.fromHex("#FFFFFF"), ElementDesc = Color3.fromHex("#FFFFFF"), ElementIcon = Color3.fromHex("#ff4d6d"), PopupBackground = Color3.fromHex("#14080e"), PopupBackgroundTransparency = "BackgroundTransparency", PopupTitle = Color3.fromHex("#FFFFFF"), PopupContent = Color3.fromHex("#FFFFFF"), PopupIcon = Color3.fromHex("#ff4d6d"), DialogBackground = Color3.fromHex("#14080e"), DialogBackgroundTransparency = "BackgroundTransparency", DialogTitle = Color3.fromHex("#FFFFFF"), DialogContent = Color3.fromHex("#FFFFFF"), DialogIcon = Color3.fromHex("#ff4d6d"), Toggle = Color3.fromHex("#ff4d6d"), ToggleBar = Color3.new(1,1,1), Checkbox = Color3.fromHex("#ff4d6d"), CheckboxIcon = Color3.new(1,1,1), CheckboxBorder = Color3.new(1,1,1), CheckboxBorderTransparency = .75, SliderIcon = Color3.fromHex("#ff4d6d"), Slider = Color3.fromHex("#ff4d6d"), SliderThumb = Color3.new(1,1,1), SliderIconFrom = Color3.fromHex("#ff4d6d"), SliderIconTo = Color3.fromHex("#ff4d6d"), Tooltip = Color3.fromHex("4C4C4C"), TooltipText = Color3.new(1,1,1), TooltipSecondary = Color3.fromHex("#ff4d6d"), TooltipSecondaryText = Color3.new(1,1,1), TabSectionIcon = Color3.fromHex("#ff4d6d"), SectionIcon = Color3.fromHex("#ff4d6d"), SectionExpandIcon = Color3.new(1,1,1), SectionExpandIconTransparency = .4, SectionBox = Color3.new(1,1,1), SectionBoxTransparency = .95, SectionBoxBorder = Color3.new(1,1,1), SectionBoxBorderTransparency = .75, SectionBoxBackground = Color3.new(1,1,1), SectionBoxBackgroundTransparency = .95, SearchBarBorder = Color3.new(1,1,1), SearchBarBorderTransparency = .75, Notification = Color3.fromHex("#14080e"), NotificationTitle = Color3.fromHex("#FFFFFF"), NotificationTitleTransparency = 0, NotificationContent = Color3.fromHex("#FFFFFF"), NotificationContentTransparency = .4, NotificationDuration = Color3.new(1,1,1), NotificationDurationTransparency = .95, NotificationBorder = Color3.new(1,1,1), NotificationBorderTransparency = .75, DropdownTabBorder = Color3.new(1,1,1), LabelBackground = Color3.new(1,1,1), LabelBackgroundTransparency = .95,
})
WindUI:AddTheme({
    Name = "Black", Primary = Color3.fromHex("#ffffff"), White = Color3.new(1,1,1), Black = Color3.new(0,0,0), Dialog = Color3.fromHex("#0a0a0a"), Background = Color3.fromHex("#000000"), BackgroundTransparency = 0, Hover = Color3.fromHex("#FFFFFF"), PanelBackground = Color3.new(1,1,1), PanelBackgroundTransparency = .95, WindowBackground = Color3.fromHex("#000000"), WindowShadow = Color3.new(0,0,0), WindowTopbarTitle = Color3.fromHex("#FFFFFF"), WindowTopbarAuthor = Color3.fromHex("#FFFFFF"), WindowTopbarIcon = Color3.fromHex("#FFFFFF"), WindowTopbarButtonIcon = Color3.fromHex("#FFFFFF"), WindowSearchBarBackground = Color3.fromHex("#000000"), TabBackground = Color3.fromHex("#FFFFFF"), TabBackgroundHover = Color3.fromHex("#FFFFFF"), TabBackgroundHoverTransparency = .97, TabBackgroundActive = Color3.fromHex("#FFFFFF"), TabBackgroundActiveTransparency = 0.93, TabText = Color3.fromHex("#FFFFFF"), TabTextTransparency = 0.3, TabTextTransparencyActive = 0, TabTitle = Color3.fromHex("#FFFFFF"), TabIcon = Color3.fromHex("#FFFFFF"), TabIconTransparency = 0.4, TabIconTransparencyActive = 0.1, TabBorderTransparency = 1, TabBorderTransparencyActive = 0.75, TabBorder = Color3.fromHex("#FFFFFF"), ElementBackground = Color3.fromHex("#FFFFFF"), ElementBackgroundTransparency = .93, ElementBackgroundHover = WindUI.Creator:AddColor("ElementBackground", "#ffffff", 1/10), ElementTitle = Color3.fromHex("#FFFFFF"), ElementDesc = Color3.fromHex("#FFFFFF"), ElementIcon = Color3.fromHex("#FFFFFF"), PopupBackground = Color3.fromHex("#000000"), PopupBackgroundTransparency = "BackgroundTransparency", PopupTitle = Color3.fromHex("#FFFFFF"), PopupContent = Color3.fromHex("#FFFFFF"), PopupIcon = Color3.fromHex("#FFFFFF"), DialogBackground = Color3.fromHex("#000000"), DialogBackgroundTransparency = "BackgroundTransparency", DialogTitle = Color3.fromHex("#FFFFFF"), DialogContent = Color3.fromHex("#FFFFFF"), DialogIcon = Color3.fromHex("#FFFFFF"), Toggle = Color3.fromHex("#FFFFFF"), ToggleBar = Color3.new(1,1,1), Checkbox = Color3.fromHex("#FFFFFF"), CheckboxIcon = Color3.new(1,1,1), CheckboxBorder = Color3.new(1,1,1), CheckboxBorderTransparency = .75, SliderIcon = Color3.fromHex("#FFFFFF"), Slider = Color3.fromHex("#FFFFFF"), SliderThumb = Color3.new(1,1,1), SliderIconFrom = Color3.fromHex("#FFFFFF"), SliderIconTo = Color3.fromHex("#FFFFFF"), Tooltip = Color3.fromHex("4C4C4C"), TooltipText = Color3.new(1,1,1), TooltipSecondary = Color3.fromHex("#FFFFFF"), TooltipSecondaryText = Color3.new(1,1,1), TabSectionIcon = Color3.fromHex("#FFFFFF"), SectionIcon = Color3.fromHex("#FFFFFF"), SectionExpandIcon = Color3.new(1,1,1), SectionExpandIconTransparency = .4, SectionBox = Color3.new(1,1,1), SectionBoxTransparency = .95, SectionBoxBorder = Color3.new(1,1,1), SectionBoxBorderTransparency = .75, SectionBoxBackground = Color3.new(1,1,1), SectionBoxBackgroundTransparency = .95, SearchBarBorder = Color3.new(1,1,1), SearchBarBorderTransparency = .75, Notification = Color3.fromHex("#000000"), NotificationTitle = Color3.fromHex("#FFFFFF"), NotificationTitleTransparency = 0, NotificationContent = Color3.fromHex("#FFFFFF"), NotificationContentTransparency = .4, NotificationDuration = Color3.new(1,1,1), NotificationDurationTransparency = .95, NotificationBorder = Color3.new(1,1,1), NotificationBorderTransparency = .75, DropdownTabBorder = Color3.new(1,1,1), LabelBackground = Color3.new(1,1,1), LabelBackgroundTransparency = .95,
})

local Window = WindUI:CreateWindow({
    Title = "Apex | Universal", Icon = "rbxassetid://1794099698676", Author = "", Folder = "ApexUniversal",
    Size = UDim2.fromOffset(450, 360), Theme = "Rose", Transparent = true,
    KeySystem = { Title = "Verification", KeyValidator = function(key) return string.lower(key) == "apex67" end, SaveKey = false }
})

local FPSTag = Window:Tag({ Title = "FPS: 0", Color = Color3.fromRGB(100, 150, 255) })
local PingTag = Window:Tag({ Title = "Ping: 0ms", Color = Color3.fromRGB(100, 200, 255) })
local lastUpdate = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        local fps = math.floor(frameCount / (now - lastUpdate))
        FPSTag:SetTitle("FPS: " .. fps)
        if fps >= 50 then FPSTag:SetColor(Color3.fromRGB(0, 255, 0)) elseif fps >= 30 then FPSTag:SetColor(Color3.fromRGB(255, 200, 0)) else FPSTag:SetColor(Color3.fromRGB(255, 0, 0)) end
        frameCount = 0; lastUpdate = now
    end
end)
task.spawn(function()
    while true do
        local success, ping = pcall(function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        if success and ping then
            PingTag:SetTitle("Ping: " .. ping .. "ms")
            if ping <= 50 then PingTag:SetColor(Color3.fromRGB(0, 255, 0)) elseif ping <= 100 then PingTag:SetColor(Color3.fromRGB(255, 200, 0)) elseif ping <= 200 then PingTag:SetColor(Color3.fromRGB(255, 150, 0)) else PingTag:SetColor(Color3.fromRGB(255, 0, 0)) end
        end
        task.wait(2)
    end
end)

local TabMain = Window:Tab({ Title = "Main", Icon = "house" })
TabMain:Section({ Title = "Bem-vindo" })

-- 1. STATUS DO JOGO COM FOTO DE ANIME
TabMain:Paragraph({
    Title = "Status do Jogo",
    Desc = "O script está rodando perfeitamente. Use as funções com moderação.",
    Image = "gamepad-2",
    ImageSize = 24,
    Thumbnail = "rbxassetid://6239940100", -- Foto de anime (Gojo)
    ThumbnailSize = 60,
    Color = Color3.fromRGB(100, 200, 255)
})

-- 2. AVISO IMPORTANTE COM FOTO DE ANIME
TabMain:Paragraph({
    Title = "Aviso Importante",
    Desc = "O uso de scripts pode resultar em banimento. Use por sua conta e risco.",
    Image = "alert-triangle",
    ImageSize = 24,
    Thumbnail = "rbxassetid://5444301611", -- Foto de anime (Nezuko)
    ThumbnailSize = 60,
    Color = Color3.fromRGB(255, 50, 50)
})

-- 3. CRÉDITOS COM FOTO DE ANIME E NOME DO JOGO
local NomeDoJogo = "Desconhecido"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    NomeDoJogo = info.Name
end)

TabMain:Paragraph({
    Title = "Créditos",
    Desc = "Script feito por Apex.\nJogo atual: " .. NomeDoJogo,
    Image = "user",
    ImageSize = 24,
    Thumbnail = "rbxassetid://5252447904", -- Foto de anime (Aesthetic)
    ThumbnailSize = 60,
    Color = Color3.fromRGB(255, 77, 109)
})
local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })
local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
local TabTheme = Window:Tab({ Title = "Themes", Icon = "palette" })
local TabConfig = Window:Tab({ Title = "Settings", Icon = "settings" })
local TabInfo = Window:Tab({ Title = "Info", Icon = "info" })
TabInfo:Section({ Title = "Aviso" })

-- A IMAGEM FICA AQUI
TabInfo:Image({
    Image = "rbxassetid://6239940100", -- ID da imagem de anime
    Height = 150, 
    Width = 380
})

-- ABAIXO DELA, APARECEM AS COISAS
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
-- ABA THEMES
TabTheme:Section({ Title = "Select Theme" })
TabTheme:Dropdown({ Title = "UI Theme", Values = {"Rose", "Black"}, Value = "Rose", Callback = function(selected) pcall(function() Window:SetTheme(selected) local OldSize = Window.Size Window:SetSize(UDim2.fromOffset(451, 361)) task.wait(0.05) Window:SetSize(OldSize) end) end })

-- ABA COMBAT
-- ==========================================
-- ABA COMBAT (BOTÕES + FUNÇÕES JUNTAS)
-- ==========================================

-- 1. CRIANDO OS BOTÕES NA TELA
TabCombat:Section({ Title = "Aimbot" })
TabCombat:Toggle({ Title = "Aimbot", Value = false, Callback = function(s) AimbotOn = s end })
TabCombat:Toggle({ Title = "Team Check", Value = false, Callback = function(s) TeamCheckOn = s end })
TabCombat:Dropdown({ Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Value = "Head", Callback = function(v) AimbotPart = v end })
TabCombat:Slider({ Title = "FOV", Value = { Min = 10, Max = 500, Default = 150 }, Callback = function(v) AimbotFOV = v end })

TabCombat:Section({ Title = "Hitbox" })
TabCombat:Toggle({ Title = "Hitbox", Value = false, Callback = function(s) HitboxOn = s end })
TabCombat:Slider({ Title = "Hitbox Size", Value = { Min = 2, Max = 30, Default = 10 }, Callback = function(v) HitboxSize = v end })

-- 2. LOOP DO AIMBOT (Ação)
RunService.RenderStepped:Connect(function()
    if AimbotOn then
        local closest, minDist = nil, AimbotFOV
        local center = Camera.ViewportSize / 2
        
        local myTeam = LP.Team
        local myShirt = LP.Character and LP.Character:FindFirstChild("Shirt")
        local myColor = myShirt and myShirt.ShirtTemplate or nil
        
        for _, p in pairs(Players:GetPlayers()) do
            local isTeammate = false
            
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
        if closest then 
            pcall(function() Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 1) end) 
        end
    end
end)

-- 3. LOOP DA HITBOX (Ação)
RunService.RenderStepped:Connect(function()
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
-- ABA PLAYER
local SpeedOn, SpeedVal = false, 16
local JumpOn, JumpVal = false, 50
local InfJumpOn = false

TabPlayer:Section({ Title = "Movement" })
TabPlayer:Toggle({ Title = "Speed", Icon = "zap", Value = false, Callback = function(s) SpeedOn = s if not s and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then pcall(function() LP.Character.Humanoid.WalkSpeed = 16 end) end end })
TabPlayer:Slider({ Title = "Speed Value", Value = { Min = 16, Max = 200, Default = 16 }, Callback = function(v) SpeedVal = v end })
TabPlayer:Toggle({ Title = "Jump", Icon = "arrow-up", Value = false, Callback = function(s) JumpOn = s if not s and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then pcall(function() LP.Character.Humanoid.JumpPower = 50 end) end end })
TabPlayer:Slider({ Title = "Jump Power", Value = { Min = 50, Max = 300, Default = 50 }, Callback = function(v) JumpVal = v end })
TabPlayer:Toggle({ Title = "Infinite Jump", Icon = "infinity", Value = false, Callback = function(s) InfJumpOn = s end })

RunService.RenderStepped:Connect(function()
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LP.Character.Humanoid
        if SpeedOn then pcall(function() hum.WalkSpeed = SpeedVal end) end
        if JumpOn then pcall(function() hum.JumpPower = JumpVal hum.UseJumpPower = true end) end
    end
end)
UIS.JumpRequest:Connect(function()
    if InfJumpOn and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then pcall(function() LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

-- ABA VISUALS (ESP CORRIGIDO)
local ESPOn, ESPBox, ESPLine, ESPHealth = false, false, false, false
local ESPObjs = {}

TabVisuals:Section({ Title = "Player ESP" })
TabVisuals:Toggle({ Title = "Enable ESP", Icon = "eye", Value = false, Callback = function(s) ESPOn = s end })
TabVisuals:Toggle({ Title = "Box", Icon = "box", Value = false, Callback = function(s) ESPBox = s end })
TabVisuals:Toggle({ Title = "Tracer Line", Icon = "route", Value = false, Callback = function(s) ESPLine = s end })
TabVisuals:Toggle({ Title = "Health Bar", Icon = "heart", Value = false, Callback = function(s) ESPHealth = s end })

RunService.RenderStepped:Connect(function()
    if not ESPOn then
        for _, obj in pairs(ESPObjs) do 
            obj.Box.Visible = false 
            obj.BoxFill.Visible = false 
            obj.Line.Visible = false 
            obj.Health.Visible = false 
            obj.HealthOutline.Visible = false
        end
        return
    end
    
    for player, obj in pairs(ESPObjs) do
        if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            obj.Box:Remove() 
            obj.BoxFill:Remove() 
            obj.Line:Remove() 
            obj.Health:Remove() 
            obj.HealthOutline:Remove() 
            ESPObjs[player] = nil
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
                    local box = Drawing.new("Square") 
                    box.Thickness = 1.5 
                    box.Filled = false
                    
                    local boxFill = Drawing.new("Square") 
                    boxFill.Thickness = 1 
                    boxFill.Filled = true 
                    boxFill.Color = Color3.new(0,0,0) 
                    boxFill.Transparency = 0.5
                    
                    local line = Drawing.new("Line") 
                    line.Thickness = 1
                    
                    local health = Drawing.new("Line") 
                    health.Thickness = 2
                    
                    local healthOutline = Drawing.new("Line") 
                    healthOutline.Thickness = 3 
                    healthOutline.Color = Color3.new(0,0,0)
                    
                    ESPObjs[p] = {
                        Box = box, 
                        BoxFill = boxFill, 
                        Line = line, 
                        Health = health, 
                        HealthOutline = healthOutline
                    }
                end
                
                local obj = ESPObjs[p]
                local hPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                local fPos = Camera:WorldToViewportPoint(rightFoot.Position - Vector3.new(0, 1, 0))
                
                if onScreen then
                    local espColor = Color3.fromRGB(255, 255, 255)
                    if LP.Team and p.Team and LP.Team == p.Team then 
                        espColor = Color3.fromRGB(50, 255, 50) 
                    end
                    
                    local height = math.abs(hPos.Y - fPos.Y)
                    local width = height / 2.5 
                    local posX = hPos.X - width/2
                    local posY = hPos.Y

                    -- Box e Fundo
                    obj.Box.Size = Vector2.new(width, height)
                    obj.Box.Position = Vector2.new(posX, posY)
                    obj.Box.Color = espColor
                    obj.Box.Visible = ESPBox
                    
                    obj.BoxFill.Size = Vector2.new(width, height)
                    obj.BoxFill.Position = Vector2.new(posX, posY)
                    obj.BoxFill.Visible = ESPBox
                    
                    -- Tracer
                    obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    obj.Line.To = Vector2.new(hPos.X, hPos.Y)
                    obj.Line.Color = espColor
                    obj.Line.Visible = ESPLine

                    -- Barra de Vida
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

-- ABA CONFIG (VAZIA)
TabConfig:Section({ Title = "" })
