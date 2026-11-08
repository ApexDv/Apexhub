local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

-- TEMA ROSA
WindUI:AddTheme({
    Name = "Rose", Primary = Color3.fromHex("#ff4d6d"), White = Color3.new(1,1,1), Black = Color3.new(0,0,0), Dialog = Color3.fromHex("#1a0b12"), Background = Color3.fromHex("#14080e"), BackgroundTransparency = 0, Hover = Color3.fromHex("#FFFFFF"), PanelBackground = Color3.new(1,1,1), PanelBackgroundTransparency = .95, WindowBackground = Color3.fromHex("#14080e"), WindowShadow = Color3.new(0,0,0), WindowTopbarTitle = Color3.fromHex("#FFFFFF"), WindowTopbarAuthor = Color3.fromHex("#FFFFFF"), WindowTopbarIcon = Color3.fromHex("#ff4d6d"), WindowTopbarButtonIcon = Color3.fromHex("#ff4d6d"), WindowSearchBarBackground = Color3.fromHex("#14080e"), TabBackground = Color3.fromHex("#FFFFFF"), TabBackgroundHover = Color3.fromHex("#FFFFFF"), TabBackgroundHoverTransparency = .97, TabBackgroundActive = Color3.fromHex("#FFFFFF"), TabBackgroundActiveTransparency = 0.93, TabText = Color3.fromHex("#FFFFFF"), TabTextTransparency = 0.3, TabTextTransparencyActive = 0, TabTitle = Color3.fromHex("#FFFFFF"), TabIcon = Color3.fromHex("#ff4d6d"), TabIconTransparency = 0.4, TabIconTransparencyActive = 0.1, TabBorderTransparency = 1, TabBorderTransparencyActive = 0.75, TabBorder = Color3.fromHex("#ff4d6d"), ElementBackground = Color3.fromHex("#FFFFFF"), ElementBackgroundTransparency = .93, ElementBackgroundHover = WindUI.Creator:AddColor("ElementBackground", "#ffffff", 1/10), ElementTitle = Color3.fromHex("#FFFFFF"), ElementDesc = Color3.fromHex("#FFFFFF"), ElementIcon = Color3.fromHex("#ff4d6d"), PopupBackground = Color3.fromHex("#14080e"), PopupBackgroundTransparency = "BackgroundTransparency", PopupTitle = Color3.fromHex("#FFFFFF"), PopupContent = Color3.fromHex("#FFFFFF"), PopupIcon = Color3.fromHex("#ff4d6d"), DialogBackground = Color3.fromHex("#14080e"), DialogBackgroundTransparency = "BackgroundTransparency", DialogTitle = Color3.fromHex("#FFFFFF"), DialogContent = Color3.fromHex("#FFFFFF"), DialogIcon = Color3.fromHex("#ff4d6d"), Toggle = Color3.fromHex("#ff4d6d"), ToggleBar = Color3.new(1,1,1), Checkbox = Color3.fromHex("#ff4d6d"), CheckboxIcon = Color3.new(1,1,1), CheckboxBorder = Color3.new(1,1,1), CheckboxBorderTransparency = .75, SliderIcon = Color3.fromHex("#ff4d6d"), Slider = Color3.fromHex("#ff4d6d"), SliderThumb = Color3.new(1,1,1), SliderIconFrom = Color3.fromHex("#ff4d6d"), SliderIconTo = Color3.fromHex("#ff4d6d"), Tooltip = Color3.fromHex("4C4C4C"), TooltipText = Color3.new(1,1,1), TooltipSecondary = Color3.fromHex("#ff4d6d"), TooltipSecondaryText = Color3.new(1,1,1), TabSectionIcon = Color3.fromHex("#ff4d6d"), SectionIcon = Color3.fromHex("#ff4d6d"), SectionExpandIcon = Color3.new(1,1,1), SectionExpandIconTransparency = .4, SectionBox = Color3.new(1,1,1), SectionBoxTransparency = .95, SectionBoxBorder = Color3.new(1,1,1), SectionBoxBorderTransparency = .75, SectionBoxBackground = Color3.new(1,1,1), SectionBoxBackgroundTransparency = .95, SearchBarBorder = Color3.new(1,1,1), SearchBarBorderTransparency = .75, Notification = Color3.fromHex("#14080e"), NotificationTitle = Color3.fromHex("#FFFFFF"), NotificationTitleTransparency = 0, NotificationContent = Color3.fromHex("#FFFFFF"), NotificationContentTransparency = .4, NotificationDuration = Color3.new(1,1,1), NotificationDurationTransparency = .95, NotificationBorder = Color3.new(1,1,1), NotificationBorderTransparency = .75, DropdownTabBorder = Color3.new(1,1,1), LabelBackground = Color3.new(1,1,1), LabelBackgroundTransparency = .95,
})

-- VARIÁVEIS
local TriggerBotOn = false
local ShootThroughWalls = false
local FOV = 300
local FireDelay = 0.2
local ChamsObjects = {}
local lastShotTime = 0

-- JANELA
local Window = WindUI:CreateWindow({
    Title = "Apex | MVSD",
    Icon = "rbxassetid://1794099698676",
    Author = "",
    Folder = "ApexMVSD",
    Size = UDim2.fromOffset(450, 360),
    Theme = "Rose",
    Transparent = true,
    KeySystem = {
        Title = "Verification",
        KeyValidator = function(key) 
            local success, result = pcall(function()
                return string.lower(key) == "apex67" 
            end)
            if success then return result else return false end
        end,
        SaveKey = false
    }
})

-- FUNÇÃO DE LIMPEZA
local function ClearAllESP()
    for player, highlight in pairs(ChamsObjects) do
        if highlight then highlight:Destroy() end
    end
    ChamsObjects = {}
end

-- ABA COMBAT (TRIGGER BOT)
local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
TabCombat:Section({ Title = "Trigger Bot" })
TabCombat:Toggle({ Title = "Tiro Automático", Value = false, Callback = function(s) TriggerBotOn = s end })
TabCombat:Toggle({ Title = "Atirar na Parede", Value = false, Callback = function(s) ShootThroughWalls = s end })
TabCombat:Slider({ Title = "FOV", Value = { Min = 10, Max = 800, Default = 300 }, Callback = function(v) FOV = v end })
TabCombat:Slider({ Title = "Velocidade", Value = { Min = 0.1, Max = 1, Default = 0.2 }, Callback = function(v) FireDelay = v end })

-- FUNÇÃO PRA ACHAR O ALVO
local function GetTarget()
    local closest, minDist = nil, FOV
    local center = Camera.ViewportSize / 2
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

-- FUNÇÃO DE PAREDE (WALL CHECK)
local function HasLineOfSight(targetPart)
    local myChar = LP.Character
    if not myChar then return false end
    local myHead = myChar:FindFirstChild("Head")
    if not myHead then return false end
    local rayOrigin = myHead.Position
    local rayDirection = targetPart.Position - rayOrigin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {myChar, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return result == nil
end

-- LOOP DO TRIGGER BOT
RunService.RenderStepped:Connect(function()
    if TriggerBotOn then
        if tick() - lastShotTime < FireDelay then return end
        local target = GetTarget()
        
        if target and LP.Character then
            local canShoot = true
            if not ShootThroughWalls then
                canShoot = HasLineOfSight(target)
            end

            if canShoot then
                local myHead = LP.Character:FindFirstChild("Head")
                local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ShootGun")
                local hasGun = false
                for _, tool in pairs(LP.Character:GetChildren()) do
                    if tool:IsA("Tool") then hasGun = true break end
                end
                if Remote and myHead and hasGun then
                    lastShotTime = tick()
                    pcall(function()
                        Remote:FireServer(table.unpack({
                            [1] = myHead.Position, [2] = target.Position, [3] = target, [4] = target.Position, 
                        }))
                    end)
                end
            end
        end
    end
end)

-- ABA VISUALS (SÓ O CHAMS AZUL)
local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
TabVisuals:Section({ Title = "Player" })

TabVisuals:Toggle({ Title = "ESP", Value = false, Callback = function(s) 
    if not s then ClearAllESP() end
    _G.ChamsOn = s 
end })

-- LOOP DO CHAMS
RunService.RenderStepped:Connect(function()
    if not _G.ChamsOn then
        for _, highlight in pairs(ChamsObjects) do
            if highlight then highlight:Destroy() end
        end
        ChamsObjects = {}
        return
    end

    for player, highlight in pairs(ChamsObjects) do
        if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            highlight:Destroy()
            ChamsObjects[player] = nil
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if hum and root and hum.Health > 0 then
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local distance = myRoot and (myRoot.Position - root.Position).Magnitude or 9999
                
                if distance < 1000 then 
                    if not ChamsObjects[p] then
                        local highlight = Instance.new("Highlight")
                        highlight.Parent = char
                        highlight.FillColor = Color3.fromRGB(0, 150, 255)
                        highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        ChamsObjects[p] = highlight
                    end
                else
                    if ChamsObjects[p] then
                        ChamsObjects[p]:Destroy()
                        ChamsObjects[p] = nil
                    end
                end
            end
        end
    end
end)

-- ABA SETTINGS
local TabConfig = Window:Tab({ Title = "Settings", Icon = "settings" })
TabConfig:Section({ Title = "Sistema" })
TabConfig:Button({
    Title = "Sair do Script",
    Icon = "log-out",
    Callback = function()
        ClearAllESP()
        _G.ChamsOn = false
        TriggerBotOn = false
        Window:Destroy()
    end
})

-- ABA SOCIAL (DISCORD)
local TabSocial = Window:Tab({ Title = "Social", Icon = "users" })
TabSocial:Section({ Title = "Discord" })
TabSocial:Paragraph({
    Title = "Discord",
    Desc = "Entre para não perder as atualizações!",
    Image = "message-circle",
    ImageSize = 24,
    Thumbnail = "rbxassetid://1794099698676",
    ThumbnailSize = 64,
    Color = Color3.fromRGB(100, 200, 255)
})
TabSocial:Button({
    Title = "Copiar Link",
    Icon = "copy",
    IconAlign = "Left",
    Callback = function()
        setclipboard("https://discord.gg/9uQjBAAaP")
        WindUI:Notify({ Title = "Copiado!", Content = "Link copiado.", Duration = 3, Icon = "check" })
    end
})
