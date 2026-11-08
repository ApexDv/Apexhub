obj.Line.Colorlocal Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
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

-- ==========================================================
-- CRIAÇÃO DAS TABS (PRIMEIRO!)
-- ==========================================================
local TabMain    = Window:Tab({ Title = "Info",    Icon = "info" })
local TabCombat  = Window:Tab({ Title = "Combat",  Icon = "crosshair" })
local TabPlayer  = Window:Tab({ Title = "Player",  Icon = "user" })
local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
local TabTheme   = Window:Tab({ Title = "Themes",  Icon = "palette" })
local TabConfig  = Window:Tab({ Title = "Settings",Icon = "settings" })

-- ==========================================================
-- ABA INFO
-- ==========================================================
TabMain:Section({ Title = "Informações" })
TabMain:Image({ Image = "rbxassetid://137832913582842", Height = 150, Width = 400 })
TabMain:Paragraph({
    Title = "Bem-vindo!",
    Content = "Ative as funções nas abas Combat, Player e Visuals. Cuidado com o anti-cheat!"
})
TabMain:Section({ Title = "Community" })
TabMain:Button({ Title = "Copy Discord Link", Icon = "link", IconAlign = "Left", Callback = function() setclipboard("https://discord.gg/9uQjBAAaP") end })

-- ==========================================================
-- ABA THEMES
-- ==========================================================
TabTheme:Section({ Title = "Select Theme" })
TabTheme:Dropdown({
    Title = "UI Theme", Values = {"Rose", "Black"}, Value = "Rose",
    Callback = function(selected)
        pcall(function()
            Window:SetTheme(selected)
            local OldSize = Window.Size
            Window:SetSize(UDim2.fromOffset(451, 361))
            task.wait(0.05)
            Window:SetSize(OldSize)
        end)
    end
})

-- ==========================================================
-- ABA COMBAT
-- ==========================================================
local AimbotOn, AimbotFOV, AimbotPart = false, 150, "Head"
local TeamCheckOn = false
local HitboxOn, HitboxSize = false, 10
local HitboxParts = {}

TabCombat:Section({ Title = "Aimbot" })
TabCombat:Toggle({ Title = "Aimbot", Icon = "crosshair", Value = false, Callback = function(s) AimbotOn = s end })
TabCombat:Toggle({ Title = "Team Check", Icon = "users", Value = false, Callback = function(s) TeamCheckOn = s end })
TabCombat:Dropdown({ Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Value = "Head", Callback = function(v) AimbotPart = v end })
TabCombat:Slider({ Title = "FOV", Value = { Min = 10, Max = 500, Default = 150 }, Callback = function(v) AimbotFOV = v end })

TabCombat:Section({ Title = "Hitbox" })
TabCombat:Toggle({
    Title = "Hitbox", Icon = "box", Value = false,
    Callback = function(s)
        HitboxOn = s
        if not s then
            for p, hb in pairs(HitboxParts) do
                if hb and hb.Parent then hb:Destroy() end
                HitboxParts[p] = nil
            end
        end
    end
})
TabCombat:Slider({ Title = "Hitbox Size", Value = { Min = 2, Max = 30, Default = 10 }, Callback = function(v) HitboxSize = v end })

local function clearPlayerHitbox(player)
    local hb = HitboxParts[player]
    if hb and hb.Parent then hb:Destroy() end
    HitboxParts[player] = nil
end
Players.PlayerRemoving:Connect(clearPlayerHitbox)

RunService.RenderStepped:Connect(function()
    if not AimbotOn then return end
    local closest, minDist = nil, AimbotFOV
    local center = Camera.ViewportSize / 2

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local isTeammate = false
            if TeamCheckOn and LP.Team and p.Team and LP.Team == p.Team then
                isTeammate = true
            end
            if not isTeammate and p.Character then
                local part = p.Character:FindFirstChild(AimbotPart)
                local hum  = p.Character:FindFirstChildOfClass("Humanoid")
                if part and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end

    if closest then
        pcall(function()
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.lookAt(camPos, closest.Position)
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if not HitboxOn then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then
                clearPlayerHitbox(p)
            else
                local hb = HitboxParts[p]
                if not hb or not hb.Parent then
                    local newHb = Instance.new("Part")
                    newHb.Name = "ApexHitbox"
                    newHb.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    newHb.Transparency = 1
                    newHb.CanCollide = false
                    newHb.CanQuery = true
                    newHb.Massless = true
                    newHb.Anchored = false
                    newHb.Parent = p.Character

                    newHb.CFrame = hrp.CFrame
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = hrp
                    weld.Part1 = newHb
                    weld.Parent = newHb

                    HitboxParts[p] = newHb
                else
                    hb.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                end
            end
        end
    end
end)

-- ==========================================================
-- ABA PLAYER
-- ==========================================================
local SpeedOn, SpeedVal = false, 16
local JumpOn, JumpVal = false, 50
local InfJumpOn = false

TabPlayer:Section({ Title = "Movement" })
TabPlayer:Toggle({ 
    Title = "Speed", 
    Icon = "zap", 
    Value = false, 
    Callback = function(s) 
        SpeedOn = s 
        if not s and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function() LP.Character.Humanoid.WalkSpeed = 16 end)
        end
    end 
})
TabPlayer:Slider({ Title = "Speed Value", Value = { Min = 16, Max = 200, Default = 16 }, Callback = function(v) SpeedVal = v end })

TabPlayer:Toggle({ 
    Title = "Jump", 
    Icon = "arrow-up", 
    Value = false, 
    Callback = function(s) 
        JumpOn = s 
        if not s and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function() LP.Character.Humanoid.JumpPower = 50 end)
        end
    end 
})
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

-- ==========================================================
-- ABA VISUALS (ESP COM HEALTH BAR)
-- ==========================================================
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
            obj.Line.Visible = false 
            obj.Health.Visible = false 
            obj.HealthOutline.Visible = false
        end
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local head, root = char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if head and root and hum and hum.Health > 0 then
                if not ESPObjs[p] then
                    ESPObjs[p] = {
                        Box = Drawing.new("Square"), 
                        Line = Drawing.new("Line"),
                        Health = Drawing.new("Line"),
                        HealthOutline = Drawing.new("Line")
                    }
                    ESPObjs[p].Box.Thickness, ESPObjs[p].Box.Filled = 1, false
                    ESPObjs[p].Line.Thickness = 1
                    ESPObjs[p].Health.Thickness = 2
                    ESPObjs[p].HealthOutline.Thickness = 3
                    ESPObjs[p].HealthOutline.Color = Color3.new(0,0,0)
                end
                local obj = ESPObjs[p]
                local hPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local rPos = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local espColor = Color3.fromRGB(255, 255, 255)
                    if LP.Team and p.Team and LP.Team == p.Team then espColor = Color3.fromRGB(50, 255, 50) end
                    
                    local height = math.abs(hPos.Y - rPos.Y) * 2
                    local width = height / 2
                    local posX = hPos.X - width/2
                    local posY = hPos.Y - height/2

                    obj.Box.Size = Vector2.new(width, height)
                    obj.Box.Position = Vector2.new(posX, posY)
                    obj.Box.Color = espColor
                    obj.Box.Visible = ESPBox
                    
                    obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                                        obj.Line.To = Vector2.new(hPos.X, hPos.Y)
                    obj.Line.Color = espColor
                    obj.Line.Visible = ESPLine

                    if ESPHealth then
                        local hpPct = hum.Health / hum.MaxHealth
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
                    obj.Box.Visible, obj.Line.Visible, obj.Health.Visible, obj.HealthOutline.Visible = false, false, false, false
                end
            end
        end
    end
    for player, obj in pairs(ESPObjs) do
        if not player or not player.Parent or not player.Character or not player.Character:FindFirstChildOfClass("Humanoid") or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            obj.Box:Remove() obj.Line:Remove() obj.Health:Remove() obj.HealthOutline:Remove() ESPObjs[player]=nil
        end
    end
end)

-- ==========================================================
-- ABA CONFIG (vazia)
-- ==========================================================
TabConfig:Section({ Title = "Configurações" })
TabConfig:Paragraph({ Title = "Em breve", Content = "Mais opções de configuração serão adicionadas." })
