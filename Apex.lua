-- Hub — Universal Silent Aim
if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not LPH_OBFUSCATED then
    local function Passthrough(fn) return fn end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local environment = getgenv and getgenv() or _G
if type(environment.HubUnload) == "function" then
    pcall(environment.HubUnload)
end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local VirtualUser      = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local osClock = os.clock

local hub = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

hub.Config = {
    UiSource = "https://raw.githubusercontent.com/xDTaraZz/Roblox-Scripts/refs/heads/main/ui.lua",
    Discord = "https://discord.gg/FHVfmeSceA",
    UpdateLog = {
        { "2026-11-16", "Universal build: no game guard\nNamecall hook + camera snap fallback\nSmoother menu and faster target lock" },
        { "2026-10-10", "Previous build" },
    },
    LoadTimeout = 10,
    AlertTries  = 20,
    AlertGap    = 0.5,
    MaxFails    = 5,
    FailWindow  = 10,
    FovColor    = Color3.fromRGB(65, 145, 255),
    BannerCaps  = { "HookFunction", "Namecall", "Drawing", "Connections", "FileSystem" },
    AimRenderPriority = Enum.RenderPriority.Camera.Value + 5,
}

hub.State = {
    Alive       = true,
    Connections = {},
    Halted      = {},
    Overlay     = nil,
}

hub.Options = {
    SilentAimEnabled      = false,
    SilentAimFov          = 150,
    SilentAimRange        = 1000,
    SilentAimHitChance    = 100,
    SilentAimVisibleCheck = false,
    SilentAimDelayMin     = 0.05,
    SilentAimDelayMax     = 0.15,
    TargetPart            = "Head",
    ShowFov               = true,
    CameraSnapEnabled     = false,
    CameraSnapSmooth      = 1,
    AntiAfk               = false,
}

hub.Util = {}
local Util = hub.Util

local function Resolve(...)
    for index = 1, select("#", ...) do
        local candidate = select(index, ...)
        if type(candidate) == "function" then return candidate end
    end
    return nil
end

Util.Request         = Resolve(request, http_request, syn and syn.request, http and http.request)
Util.SetClipboard    = Resolve(setclipboard, toclipboard)
Util.GetHui          = Resolve(gethui, get_hidden_gui)
Util.GetRawMetatable = Resolve(getrawmetatable)

hub.Probes = {}
function hub.Probes.Namecall()
    return type(hookmetamethod) == "function" and type(newcclosure) == "function" and Util.GetRawMetatable ~= nil
end
function hub.Probes.Drawing()
    return type(Drawing) == "table" and type(Drawing.new) == "function"
end

hub.Caps = setmetatable({}, {
    __index = function(caps, name)
        local probe = hub.Probes[name]
        if probe then
            local has = probe()
            rawset(caps, name, has)
            return has
        end
        return false
    end,
})

function Util.HttpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" then return body end
    if not Util.Request then error("HttpGet failed: " .. url) end
    local sent, response = pcall(Util.Request, { Url = url, Method = "GET" })
    if not sent then error(response) end
    local status = type(response) == "table" and tonumber(response.StatusCode) or nil
    if status == 200 and type(response.Body) == "string" then return response.Body end
    error("HttpGet " .. url .. ": status " .. tostring(status))
end

function Util.Alert(text, detail)
    warn("[Hub] menu: " .. tostring(detail or text))
    task.spawn(function()
        for _ = 1, hub.Config.AlertTries do
            local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
                Title = "Hub", Text = text, Duration = 10,
            })
            if shown then return end
            task.wait(hub.Config.AlertGap)
        end
    end)
end

function Util.LoadLibrary(url)
    local fetched, source = pcall(Util.HttpGet, url)
    if not fetched or type(source) ~= "string" or not source:sub(-64):find("return Library%s*$") then
        Util.Alert("Could not download the menu. Check your connection and run it again.", fetched and "response is not the full menu" or source)
        return nil
    end
    local chunk, problem = loadstring(source)
    if type(chunk) ~= "function" then
        Util.Alert("The menu failed to load on this executor: " .. tostring(problem))
        return nil
    end
    local ran, lib = pcall(chunk)
    if not ran or type(lib) ~= "table" then
        Util.Alert("The menu failed to load on this executor: " .. tostring(lib))
        return nil
    end
    return lib
end

function Util.Overlay()
    local screen = hub.State.Overlay
    if screen and screen.Parent then return screen end
    screen = Instance.new("ScreenGui")
    screen.Name = "HubOverlay"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 50
    local mounts = { function() return game:GetService("CoreGui") end }
    if Util.GetHui then table.insert(mounts, 1, Util.GetHui) end
    for _, mount in ipairs(mounts) do
        if pcall(function() screen.Parent = mount() end) and screen.Parent then break end
    end
    if not screen.Parent then
        screen.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", hub.Config.LoadTimeout)
    end
    hub.State.Overlay = screen
    return screen
end

function hub:Connect(signal, handler)
    local connection = signal:Connect(handler)
    table.insert(self.State.Connections, connection)
    return connection
end

hub.Banner = {
    Print = print,
    Started = osClock(),
    Last = osClock(),
    Done = 0,
    Total = 4,
    Title = [[
  _   _ _   _ ____  
 | | | | | | | __ ) 
 | |_| | | | |  _ \ 
 |  _  | |_| | |_) |
 |_| |_|\___/|____/ 
]],
}

pcall(function()
    local renv = getrenv()
    if type(renv.print) == "function" then hub.Banner.Print = renv.print end
end)

function hub.Banner.Show()
    local ok, executor = pcall(identifyexecutor)
    if not ok or type(executor) ~= "string" then executor = "Unknown" end
    local rule = string.rep("=", 54)
    hub.Banner.Print(table.concat({
        "",
        hub.Banner.Title,
        rule,
        "   UNIVERSAL SILENT AIM  //  " .. hub.Config.Discord,
        "   executor: " .. tostring(executor) .. "   //   player: " .. LocalPlayer.Name,
        rule,
    }, "\n"))
end

function hub.Banner.Step(label)
    local b = hub.Banner
    local now = osClock()
    b.Done = math.min(b.Done + 1, b.Total)
    local filled = math.floor(b.Done / b.Total * 20 + 0.5)
    local bar = string.rep("#", filled) .. string.rep(".", 20 - filled)
    b.Print(string.format("[Hub] [%s] %3d%%  %-24s +%dms",
        bar, math.floor(b.Done / b.Total * 100), label, math.floor((now - b.Last) * 1000)))
    b.Last = now
end

function hub.Banner.Ready()
    local names = hub.Config.BannerCaps
    local caps = 0
    for _, name in ipairs(names) do
        if hub.Caps[name] then caps += 1 end
    end
    local rule = string.rep("=", 54)
    hub.Banner.Print(table.concat({
        rule,
        string.format("   >> READY in %dms  //  caps %d/%d  //  LeftCtrl = menu",
            math.floor((osClock() - hub.Banner.Started) * 1000), caps, #names),
        rule,
    }, "\n"))
end

pcall(hub.Banner.Show)
pcall(hub.Banner.Step, "Core")

hub.Faults = { Streaks = {}, Said = {} }

function hub.Faults.Say(name, err)
    local text, now = tostring(err), osClock()
    local last = hub.Faults.Said[name]
    if last and last[1] == text and now - last[2] < hub.Config.FailWindow then return end
    hub.Faults.Said[name] = { text, now }
    warn("[Hub] " .. name .. ": " .. text)
end

function hub.Faults.Clear(name)
    hub.Faults.Streaks[name] = nil
end

function hub.Faults.Report(name, err)
    local now = osClock()
    local streak = hub.Faults.Streaks[name]
    if not streak then
        streak = { Count = 0, First = now, Warned = false }
        hub.Faults.Streaks[name] = streak
    end
    streak.Count += 1
    if streak.Count == 1 then hub.Faults.Say(name, err) end
    if streak.Warned then return false end
    if streak.Count < hub.Config.MaxFails or now - streak.First < hub.Config.FailWindow then return false end
    streak.Warned = true
    warn("[Hub] " .. name .. " keeps failing: " .. tostring(err))
    return false
end

hub.Scheduler = { Jobs = {}, Booted = false }

function hub.Scheduler.Every(name, interval, work)
    hub.Scheduler.Jobs[name] = { Interval = interval, Fn = work, Last = 0, Running = false, Error = nil }
end

function hub.Scheduler.Step()
    if not hub.State.Alive then return end
    local now = osClock()
    for name, job in pairs(hub.Scheduler.Jobs) do
        if job.Running then continue end
        if job.Error ~= nil then
            local err = job.Error; job.Error = nil
            if err then hub.Faults.Report(name, err) else hub.Faults.Clear(name) end
        end
        if now - job.Last < job.Interval then continue end
        job.Last = now
        job.Running = true
        task.spawn(function()
            local ok, err = pcall(job.Fn)
            job.Error = (not ok) and tostring(err) or false
            job.Running = false
        end)
    end
end

function hub.Scheduler.Boot()
    if hub.Scheduler.Booted then return end
    hub.Scheduler.Booted = true
    hub:Connect(RunService.Heartbeat, hub.Scheduler.Step)
end

hub.AntiAfk = { Connection = nil, Status = "Off" }

function hub.AntiAfk.OnIdled()
    if not hub.Options.AntiAfk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end

function hub.AntiAfk.SetEnabled(on)
    hub.Options.AntiAfk = on
    if on then
        if not hub.AntiAfk.Connection then
            hub.AntiAfk.Connection = hub:Connect(LocalPlayer.Idled, hub.AntiAfk.OnIdled)
        end
        hub.AntiAfk.Status = "Armed"
    else
        if hub.AntiAfk.Connection then
            hub.AntiAfk.Connection:Disconnect()
            hub.AntiAfk.Connection = nil
        end
        hub.AntiAfk.Status = "Off"
    end
end

hub.SilentAim = {
    Target        = nil,
    LastShotAt    = 0,
    Hooked        = false,
    OldNamecall   = nil,
    CircleDrawing = nil,
    CircleFrame   = nil,
    InputConn     = nil,
}
local SA = hub.SilentAim

function SA.GetPart(character)
    if not character then return nil end
    local partName = hub.Options.TargetPart or "Head"
    local direct = character:FindFirstChild(partName)
    if direct and direct:IsA("BasePart") then return direct end
    if partName == "UpperTorso" then
        local torso = character:FindFirstChild("Torso")
        if torso then return torso end
    end
    if partName == "Head" then
        local head = character:FindFirstChild("Head")
        if head then return head end
    end
    local collider = character:FindFirstChild("Collider")
    local custom = collider and collider:FindFirstChild(partName)
    if custom and custom:IsA("BasePart") then return custom end
    return character:FindFirstChild("HumanoidRootPart")
end

function SA.IsValidTarget(player)
    if player == LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local part = SA.GetPart(char)
    if not part then return false end
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if localRoot and (part.Position - localRoot.Position).Magnitude > hub.Options.SilentAimRange then
        return false
    end
    if hub.Options.SilentAimVisibleCheck then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LocalPlayer.Character, char }
        local camera = Workspace.CurrentCamera
        if not camera then return false end
        local result = Workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
        if result then return false end
    end
    return true, part
end

function SA.FindTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local radius = hub.Options.SilentAimFov
    local bestPart, bestDist = nil, radius
    for _, player in ipairs(Players:GetPlayers()) do
        local ok, part = SA.IsValidTarget(player)
        if ok and part then
            local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < bestDist then
                    bestPart, bestDist = part, dist
                end
            end
        end
    end
    return bestPart
end

local RayMethods = {
    FindPartOnRayWithIgnoreList = { MinArgs = 3, Types = { "Instance", "Ray", "table", "boolean", "boolean" } },
    FindPartOnRayWithWhitelist  = { MinArgs = 3, Types = { "Instance", "Ray", "table", "boolean" } },
    FindPartOnRay               = { MinArgs = 2, Types = { "Instance", "Ray", "Instance", "boolean", "boolean" } },
    Raycast                     = { MinArgs = 3, Types = { "Instance", "Vector3", "Vector3", "RaycastParams" } },
}

local function ArgsMatch(args, spec)
    if #args < spec.MinArgs then return false end
    local matches = 0
    for pos, arg in next, args do
        if typeof(arg) == spec.Types[pos] then matches += 1 end
    end
    return matches >= spec.MinArgs
end

local function ExtractOriginDir(method, args)
    if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" then
        local ray = args[2]
        if typeof(ray) == "Ray" then return ray.Origin, ray.Direction end
    elseif method == "Raycast" then
        local origin, direction = args[2], args[3]
        if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
            return origin, direction
        end
    end
    return nil, nil
end

local function IsLocalShooting(args, method, origin, direction)
    local localChar = LocalPlayer.Character
    if not localChar then return false end
    if not direction or direction.Magnitude < 1 then return false end
    local camera = Workspace.CurrentCamera
    if camera and origin and (origin - camera.CFrame.Position).Magnitude <= 15 then return true end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if localRoot and origin and (origin - localRoot.Position).Magnitude <= 10 then return true end
    local ignoreList
    if method == "Raycast" then
        local params = args[4]
        if typeof(params) == "RaycastParams" then ignoreList = params.FilterDescendantsInstances end
    elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
        if typeof(args[3]) == "table" then ignoreList = args[3] end
    end
    if ignoreList then
        for _, inst in next, ignoreList do
            if inst == localChar or inst == localRoot then return true end
        end
    end
    return false
end

local function RewriteArgs(method, args, newDir)
    if method == "FindPartOnRayWithIgnoreList" and ArgsMatch(args, RayMethods.FindPartOnRayWithIgnoreList) then
        args[2] = Ray.new(args[2].Origin, newDir)
    elseif method == "FindPartOnRayWithWhitelist" and ArgsMatch(args, RayMethods.FindPartOnRayWithWhitelist) then
        args[2] = Ray.new(args[2].Origin, newDir)
    elseif method == "FindPartOnRay" and ArgsMatch(args, RayMethods.FindPartOnRay) then
        args[2] = Ray.new(args[2].Origin, newDir)
    elseif method == "Raycast" and ArgsMatch(args, RayMethods.Raycast) then
        args[3] = newDir
    end
end

function SA.RandomDelay()
    local minD = hub.Options.SilentAimDelayMin
    local maxD = hub.Options.SilentAimDelayMax
    if maxD < minD then maxD = minD end
    return minD + math.random() * (maxD - minD)
end

function SA.Apply()
    if SA.Hooked then return end
    if not hub.Caps.Namecall then
        warn("[Hub] SilentAim: executor lacks hookmetamethod")
        return
    end
    local ok, err = pcall(function()
        local mt = Util.GetRawMetatable(game)
        local old = mt.__namecall
        SA.OldNamecall = old
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(...)
            local method = getnamecallmethod()
            local args = { ... }
            local self = args[1]
            if self == Workspace and not checkcaller() then
                local origin, direction = ExtractOriginDir(method, args)
                if origin and direction and IsLocalShooting(args, method, origin, direction) then
                    local targetPart = SA.Target
                    if hub.Options.SilentAimEnabled and targetPart and targetPart.Parent then
                        local now = osClock()
                        if now - SA.LastShotAt >= SA.RandomDelay() then
                            if math.random(1, 100) <= hub.Options.SilentAimHitChance then
                                SA.LastShotAt = now
                                local newDir = (targetPart.Position - origin).Unit * direction.Magnitude
                                RewriteArgs(method, args, newDir)
                            end
                        end
                    end
                    local packed = table.pack(old(unpack(args)))
                    return table.unpack(packed, 1, packed.n)
                end
            end
            return old(...)
        end)
        setreadonly(mt, true)
        SA.Hooked = true
    end)
    if not ok then
        warn("[Hub] SilentAim hook failed: " .. tostring(err))
        SA.Hooked = false
    end
end

function SA.Restore()
    if not SA.Hooked or not SA.OldNamecall then return end
    pcall(function()
        local mt = Util.GetRawMetatable(game)
        setreadonly(mt, false)
        mt.__namecall = SA.OldNamecall
        setreadonly(mt, true)
    end)
    SA.OldNamecall = nil
    SA.Hooked = false
end

function SA.CameraSnap()
    if not hub.Options.CameraSnapEnabled then return end
    local target = SA.Target
    if not target or not target.Parent then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local origin = camera.CFrame.Position
    local want = CFrame.lookAt(origin, target.Position)
    local smooth = math.clamp(hub.Options.CameraSnapSmooth or 1, 1, 30)
    if smooth <= 1 then
        camera.CFrame = want
    else
        camera.CFrame = camera.CFrame:Lerp(want, 1 / smooth)
    end
end

function SA.OnInputBegan(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.KeyCode == Enum.KeyCode.ButtonR2 then
        SA.CameraSnap()
    end
end

function SA.StartCameraSnap()
    if SA.InputConn then return end
    SA.InputConn = UserInputService.InputBegan:Connect(SA.OnInputBegan)
end

function SA.StopCameraSnap()
    if SA.InputConn then
        SA.InputConn:Disconnect()
        SA.InputConn = nil
    end
end

function SA.BuildCircle()
    if SA.CircleDrawing or SA.CircleFrame then return end
    if hub.Caps.Drawing then
        local circle = Drawing.new("Circle")
        circle.Thickness = 1.5
        circle.NumSides  = 64
        circle.Filled    = false
        circle.Color     = hub.Config.FovColor
        circle.Visible   = false
                SA.CircleDrawing = circle
        return
    end
    local ring = Instance.new("Frame")
    ring.Name = "Circle"
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ring
    local stroke = Instance.new("UIStroke")
    stroke.Color = hub.Config.FovColor
    stroke.Thickness = 1.5
    stroke.Parent = ring
    ring.Parent = Util.Overlay()
    SA.CircleFrame = ring
end

function SA.UpdateCircle()
    if not hub.Options.ShowFov then
        if SA.CircleDrawing then SA.CircleDrawing.Visible = false end
        if SA.CircleFrame then SA.CircleFrame.Visible = false end
        return
    end
    SA.BuildCircle()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local radius = hub.Options.SilentAimFov
    if SA.CircleDrawing then
        SA.CircleDrawing.Position = center
        SA.CircleDrawing.Radius   = radius
        SA.CircleDrawing.Visible  = true
        return
    end
    if SA.CircleFrame then
        SA.CircleFrame.Position = UDim2.fromOffset(center.X, center.Y)
        SA.CircleFrame.Size     = UDim2.fromOffset(radius * 2, radius * 2)
        SA.CircleFrame.Visible  = true
    end
end

function SA.Destroy()
    SA.Restore()
    SA.StopCameraSnap()
    if SA.CircleDrawing then
        pcall(function() SA.CircleDrawing:Remove() end)
        SA.CircleDrawing = nil
    end
    if SA.CircleFrame then
        SA.CircleFrame:Destroy()
        SA.CircleFrame = nil
    end
end

hub.Scheduler.Every("SA.Target", 0.05, function()
    if not (hub.Options.SilentAimEnabled or hub.Options.CameraSnapEnabled) then
        SA.Target = nil
        return
    end
    SA.Target = SA.FindTarget()
end)

hub.Scheduler.Every("SA.Circle", 0, function()
    SA.UpdateCircle()
end)

hub.Scheduler.Every("SA.Hook", 1, function()
    if hub.Options.SilentAimEnabled and not SA.Hooked then
        SA.Apply()
    elseif not hub.Options.SilentAimEnabled and SA.Hooked then
        SA.Restore()
    end
    if hub.Options.CameraSnapEnabled then
        SA.StartCameraSnap()
    else
        SA.StopCameraSnap()
    end
end)

local Library = Util.LoadLibrary(hub.Config.UiSource)
if not Library then
    warn("[Hub] menu unavailable, aborting UI build")
    return
end
hub.Library = Library
pcall(hub.Banner.Step, "Library")

local Window = Library:Window({
    Title = "Hub",
    SubTitle = "Universal Silent Aim",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 460),
    Theme = "Dark",
})

local AimTab = Window:Tab({ Title = "Silent Aim", Icon = "crosshair" })

AimTab:Toggle({
    Title = "Silent Aim",
    Description = "Rewrites your shot direction to the locked target.",
    Default = false,
    Flag = "SilentAimEnabled",
}, function(state)
    hub.Options.SilentAimEnabled = state
    if not state then SA.Target = nil end
end)

AimTab:Toggle({
    Title = "Camera Snap (fallback)",
    Description = "Snaps your view to the target on click. Works in games without local raycast.",
    Default = false,
    Flag = "CameraSnapEnabled",
}, function(state)
    hub.Options.CameraSnapEnabled = state
end)

AimTab:Slider({
    Title = "Camera Snap Smooth",
    Min = 1, Max = 30, Default = 1,
    Flag = "CameraSnapSmooth",
}, function(value)
    hub.Options.CameraSnapSmooth = value
end)

AimTab:Toggle({
    Title = "Show FOV",
    Default = true,
    Flag = "ShowFov",
}, function(state)
    hub.Options.ShowFov = state
end)

AimTab:Slider({
    Title = "FOV Radius",
    Min = 20, Max = 600, Default = 150,
    Flag = "SilentAimFov",
}, function(value)
    hub.Options.SilentAimFov = value
end)

AimTab:Slider({
    Title = "Max Range",
    Min = 100, Max = 3000, Default = 1000,
    Flag = "SilentAimRange",
}, function(value)
    hub.Options.SilentAimRange = value
end)

AimTab:Slider({
    Title = "Hit Chance (%)",
    Min = 1, Max = 100, Default = 100,
    Flag = "SilentAimHitChance",
}, function(value)
    hub.Options.SilentAimHitChance = value
end)

AimTab:Slider({
    Title = "Delay Min (s)",
    Min = 0, Max = 1, Default = 0.05, Decimals = 2,
    Flag = "SilentAimDelayMin",
}, function(value)
    hub.Options.SilentAimDelayMin = value
end)

AimTab:Slider({
    Title = "Delay Max (s)",
    Min = 0, Max = 1, Default = 0.15, Decimals = 2,
    Flag = "SilentAimDelayMax",
}, function(value)
    hub.Options.SilentAimDelayMax = value
end)

AimTab:Dropdown({
    Title = "Target Part",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Flag = "TargetPart",
}, function(value)
    hub.Options.TargetPart = value
end)

AimTab:Toggle({
    Title = "Visible Check",
    Description = "Require line of sight from camera to target.",
    Default = false,
    Flag = "SilentAimVisibleCheck",
}, function(state)
    hub.Options.SilentAimVisibleCheck = state
end)

local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

MiscTab:Toggle({
    Title = "Anti AFK",
    Default = false,
    Flag = "AntiAfk",
}, function(state)
    hub.AntiAfk.SetEnabled(state)
end)

MiscTab:Button({ Title = "Copy Discord" }, function()
    if Util.SetClipboard then Util.SetClipboard(hub.Config.Discord) end
end)

MiscTab:Button({ Title = "Unload Script" }, function()
    if type(environment.HubUnload) == "function" then
        pcall(environment.HubUnload)
    end
end)

local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })

local logLines = {}
for _, entry in ipairs(hub.Config.UpdateLog) do
    table.insert(logLines, string.format("[%s]  %s", entry[1], entry[2]))
end

InfoTab:Label({ Title = "Update Log" })
InfoTab:Paragraph({ Title = table.concat(logLines, "\n\n") })
InfoTab:Label({ Title = "Discord: " .. hub.Config.Discord })
InfoTab:Label({ Title = "Build: Universal Silent Aim" })

pcall(hub.Banner.Step, "UI")

function environment.HubUnload()
    if not hub.State.Alive then return end
    hub.State.Alive = false

    pcall(SA.Destroy)
    pcall(hub.AntiAfk.SetEnabled, false)
    if hub.AntiAfk.Connection then
        pcall(function() hub.AntiAfk.Connection:Disconnect() end)
        hub.AntiAfk.Connection = nil
    end

    for _, conn in ipairs(hub.State.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(hub.State.Connections)

    if hub.State.Overlay then
        pcall(function() hub.State.Overlay:Destroy() end)
        hub.State.Overlay = nil
    end

    if Library and Library.Unload then pcall(Library.Unload, Library) end
    warn("[Hub] unloaded")
end

hub.Scheduler.Boot()
pcall(hub.Banner.Step, "Boot")
pcall(hub.Banner.Ready)
