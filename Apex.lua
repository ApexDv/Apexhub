-- Sniper Arena.lua — UI only + Silent Aim
-- Mario Hub shell preserved. All original combat/movement/economy logic removed.
-- Silent Aim hook (namecall rewrite) dropped in as a scheduler module.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.GameId ~= 9534705677 then
    game:GetService("Players").LocalPlayer:Kick("Mario Hub: this script is for Sniper Arena only")
    return
end

if not LPH_OBFUSCATED then
    local function Passthrough(fn) return fn end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local environment = getgenv and getgenv() or _G
if type(environment.SniperArenaUnload) == "function" then
    pcall(environment.SniperArenaUnload)
end

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local osClock = os.clock

local xDTaraZ = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

xDTaraZ.Config = {
    UiSource = "https://raw.githubusercontent.com/xDTaraZz/Roblox-Scripts/refs/heads/main/ui.lua",
    Discord = "https://discord.gg/FHVfmeSceA",
    UpdateLog = {
        { "2026-11-16", "Sniper Arena shell + custom Silent Aim\nFOV circle, hit chance, part picker, per-shot delay" },
        { "2026-10-10", "Previous Mario Hub build" },
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

xDTaraZ.State = {
    Alive       = true,
    Connections = {},
    Halted      = {},
    Overlay     = nil,
}

xDTaraZ.Options = {
    -- Silent Aim
    SilentAimEnabled      = false,
    SilentAimFov          = 150,
    SilentAimRange        = 1000,
    SilentAimHitChance    = 100,
    SilentAimVisibleCheck = false,
    SilentAimDelayMin     = 0.05,
    SilentAimDelayMax     = 0.15,
    TargetPart            = "Head",
    ShowFov               = true,
    -- Misc
    AntiAfk               = false,
}

xDTaraZ.Util = {}
local Util = xDTaraZ.Util

local function Resolve(...)
    for index = 1, select("#", ...) do
        local candidate = select(index, ...)
        if type(candidate) == "function" then return candidate end
    end
    return nil
end

Util.Request        = Resolve(request, http_request, syn and syn.request, http and http.request)
Util.SetClipboard   = Resolve(setclipboard, toclipboard)
Util.GetHui         = Resolve(gethui, get_hidden_gui)
Util.GetRawMetatable = Resolve(getrawmetatable)
Util.GetUpvalues    = Resolve(getupvalues, debug and debug.getupvalues)

xDTaraZ.Probes = {}
function xDTaraZ.Probes.Namecall()
    return type(hookmetamethod) == "function" and type(newcclosure) == "function" and Util.GetRawMetatable ~= nil
end
function xDTaraZ.Probes.Drawing()
    return type(Drawing) == "table" and type(Drawing.new) == "function"
end

xDTaraZ.Caps = setmetatable({}, {
    __index = function(caps, name)
        local probe = xDTaraZ.Probes[name]
        if probe then
            local has = probe()
            rawset(caps, name, has)
            return has
        end
        local lib = xDTaraZ.Library
        if not (lib and lib.Compat) then return false end
        return lib.Compat.Caps and lib.Compat.Caps[name] == true
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
    warn("[SniperArena] menu: " .. tostring(detail or text))
    task.spawn(function()
        for _ = 1, xDTaraZ.Config.AlertTries do
            local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
                Title = "Mario Hub", Text = text, Duration = 10,
            })
            if shown then return end
            task.wait(xDTaraZ.Config.AlertGap)
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

function Util.Try(label, callback, ...)
    local ok, err = pcall(callback, ...)
    if not ok then warn("[SniperArena] " .. label .. ": " .. tostring(err)) end
    return ok
end

function Util.Overlay()
    local screen = xDTaraZ.State.Overlay
    if screen and screen.Parent then return screen end
    screen = Instance.new("ScreenGui")
    screen.Name = "MarioHubOverlay"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 50
    local mounts = { function() return game:GetService("CoreGui") end }
    if Util.GetHui then table.insert(mounts, 1, Util.GetHui) end
    for _, mount in ipairs(mounts) do
        if pcall(function() screen.Parent = mount() end) and screen.Parent then break end
    end
    if not screen.Parent then
        screen.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", xDTaraZ.Config.LoadTimeout)
    end
    xDTaraZ.State.Overlay = screen
    return screen
end

function Util.SortedKeys(map)
    local keys = {}
    for key in pairs(map or {}) do keys[#keys + 1] = tostring(key) end
    table.sort(keys)
    return keys
end

function xDTaraZ:Connect(signal, handler)
    local connection = signal:Connect(handler)
    table.insert(self.State.Connections, connection)
    return connection
end

xDTaraZ.Banner = {
    Print = print,
    Started = osClock(),
    Last = osClock(),
    Done = 0,
    Total = 4,
    Title = [[
  __  __    _    ____  ___ ___    _   _ _   _ ____
 |  \/  |  / \  |  _ \|_ _/ _ \  | | | | | | | __ )
 | |\/| | / _ \ | |_) || | | | | | |_| | | | |  _ \
 | |  | |/ ___ \|  _ < | | |_| | |  _  | |_| | |_) |
 |_|  |_/_/   \_\_| \_\___\___/  |_| |_|\___/|____/
]],
}

pcall(function()
    local renv = getrenv()
    if type(renv.print) == "function" then xDTaraZ.Banner.Print = renv.print end
end)

function xDTaraZ.Banner.Show()
    local ok, executor = pcall(identifyexecutor)
    if not ok or type(executor) ~= "string" then executor = "Unknown" end
    local rule = string.rep("=", 54)
    xDTaraZ.Banner.Print(table.concat({
        "",
        xDTaraZ.Banner.Title,
        rule,
        "   SNIPER ARENA  //  Silent Aim build  //  " .. xDTaraZ.Config.Discord,
        "   executor: " .. tostring(executor) .. "   //   player: " .. LocalPlayer.Name,
        rule,
    }, "\n"))
end

function xDTaraZ.Banner.Step(label)
    local b = xDTaraZ.Banner
    local now = osClock()
    b.Done = math.min(b.Done + 1, b.Total)
    local filled = math.floor(b.Done / b.Total * 20 + 0.5)
    local bar = string.rep("#", filled) .. string.rep(".", 20 - filled)
    b.Print(string.format("[Mario Hub] [%s] %3d%%  %-24s +%dms",
        bar, math.floor(b.Done / b.Total * 100), label, math.floor((now - b.Last) * 1000)))
    b.Last = now
end

function xDTaraZ.Banner.Ready()
    local rule = string.rep("=", 54)
    xDTaraZ.Banner.Print(table.concat({
        rule,
        string.format("   >> READY in %dms  //  LeftCtrl = menu",
            math.floor((osClock() - xDTaraZ.Banner.Started) * 1000)),
        rule,
    }, "\n"))
end

pcall(xDTaraZ.Banner.Show)
pcall(xDTaraZ.Banner.Step, "Core")

xDTaraZ.Faults = { Streaks = {}, Said = {} }

function xDTaraZ.Faults.Say(name, err)
    local text, now = tostring(err), osClock()
    local last = xDTaraZ.Faults.Said[name]
    if last and last[1] == text and now - last[2] < xDTaraZ.Config.FailWindow then return end
    xDTaraZ.Faults.Said[name] = { text, now }
    warn("[SniperArena] " .. name .. ": " .. text)
end

function xDTaraZ.Faults.Clear(name)
    xDTaraZ.Faults.Streaks[name] = nil
end

function xDTaraZ.Faults.Report(name, err)
    local now = osClock()
    local streak = xDTaraZ.Faults.Streaks[name]
    if not streak then
        streak = { Count = 0, First = now, Warned = false }
        xDTaraZ.Faults.Streaks[name] = streak
    end
    streak.Count += 1
    if streak.Count == 1 then xDTaraZ.Faults.Say(name, err) end
    if streak.Warned then return false end
    if streak.Count < xDTaraZ.Config.MaxFails or now - streak.First < xDTaraZ.Config.FailWindow then return false end
    streak.Warned = true
    warn("[SniperArena] " .. name .. " keeps failing: " .. tostring(err))
    return false
end

xDTaraZ.Scheduler = { Jobs = {}, Booted = false }

function xDTaraZ.Scheduler.Every(name, interval, work)
    xDTaraZ.Scheduler.Jobs[name] = { Interval = interval, Fn = work, Last = 0, Running = false, Error = nil }
end

function xDTaraZ.Scheduler.Step()
    if not xDTaraZ.State.Alive then return end
    local now = osClock()
    for name, job in pairs(xDTaraZ.Scheduler.Jobs) do
        if job.Running then continue end
        if job.Error ~= nil then
            local err = job.Error; job.Error = nil
            if err then xDTaraZ.Faults.Report(name, err) else xDTaraZ.Faults.Clear(name) end
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

function xDTaraZ.Scheduler.Boot()
    if xDTaraZ.Scheduler.Booted then return end
    xDTaraZ.Scheduler.Booted = true
    xDTaraZ:Connect(RunService.Heartbeat, xDTaraZ.Scheduler.Step)
end

xDTaraZ.Player = { Client = LocalPlayer }
function xDTaraZ.Player:Bind(character)
    self.Character = character
    self.Humanoid = character:WaitForChild("Humanoid", xDTaraZ.Config.LoadTimeout)
    self.Root = character:WaitForChild("HumanoidRootPart", xDTaraZ.Config.LoadTimeout)
end
if LocalPlayer.Character then xDTaraZ.Player:Bind(LocalPlayer.Character) end
xDTaraZ:Connect(LocalPlayer.CharacterAdded, function(char) pcall(xDTaraZ.Player.Bind, xDTaraZ.Player, char) end)

-- =========================================================================
-- Anti AFK (isolated, stays from original shell)
-- =========================================================================
xDTaraZ.AntiAfk = { Connection = nil, Status = "Off" }
local VirtualUser = game:GetService("VirtualUser")

function xDTaraZ.AntiAfk.OnIdled()
    if not xDTaraZ.Options.AntiAfk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end

function xDTaraZ.AntiAfk.SetEnabled(on)
    xDTaraZ.Options.AntiAfk = on
    if on then
        if not xDTaraZ.AntiAfk.Connection then
            xDTaraZ.AntiAfk.Connection = xDTaraZ:Connect(LocalPlayer.Idled, xDTaraZ.AntiAfk.OnIdled)
        end
        xDTaraZ.AntiAfk.Status = "Armed"
    else
        if xDTaraZ.AntiAfk.Connection then
            xDTaraZ.AntiAfk.Connection:Disconnect()
            xDTaraZ.AntiAfk.Connection = nil
        end
        xDTaraZ.AntiAfk.Status = "Off"
    end
end

-- =========================================================================
-- SILENT AIM  (hook + FOV + target acquisition)
-- =========================================================================
xDTaraZ.SilentAim = {
    Target       = nil,
    TargetPart   = nil,
    LastShotAt   = 0,
    Hooked       = false,
    OldNamecall  = nil,
    CircleDrawing = nil,
    CircleFrame  = nil,
}

local SA = xDTaraZ.SilentAim

function SA.GetPart(character)
    if not character then return nil end
    local partName = xDTaraZ.Options.TargetPart or "Head"
    local collider = character:FindFirstChild("Collider")
    local part = collider and collider:FindFirstChild(partName)
    if part and part:IsA("BasePart") then return part end
    part = character:FindFirstChild(partName)
    if part and part:IsA("BasePart") then return part end
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
    if localRoot and (part.Position - localRoot.Position).Magnitude > xDTaraZ.Options.SilentAimRange then
        return false
    end

    if xDTaraZ.Options.SilentAimVisibleCheck then
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
    local radius = xDTaraZ.Options.SilentAimFov
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

-- ----- hook helpers -----------------------------------------------------
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
    local length = direction and direction.Magnitude or 0
    if length < 30 then return false end
    local camera = Workspace.CurrentCamera
    if camera and origin and (origin - camera.CFrame.Position).Magnitude <= 5 then return true end

    local ignoreList
    if method == "Raycast" then
        local params = args[4]
        if typeof(params) == "RaycastParams" then ignoreList = params.FilterDescendantsInstances end
    elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
        if typeof(args[3]) == "table" then ignoreList = args[3] end
    end
    if ignoreList then
        for _, inst in next, ignoreList do
            if inst == localChar then return true end
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
    local minD = xDTaraZ.Options.SilentAimDelayMin
    local maxD = xDTaraZ.Options.SilentAimDelayMax
    if maxD < minD then maxD = minD end
    return minD + math.random() * (maxD - minD)
end

-- ----- apply / remove hook ---------------------------------------------
function SA.Apply()
    if SA.Hooked then return end
    if not xDTaraZ.Caps.Namecall then
        warn("[SniperArena] SilentAim: executor lacks hookmetamethod")
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
                    if xDTaraZ.Options.SilentAimEnabled and targetPart and targetPart.Parent then
                        local now = osClock()
                        if now - SA.LastShotAt >= SA.RandomDelay() then
                            if math.random(1, 100) <= xDTaraZ.Options.SilentAimHitChance then
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
        warn("[SniperArena] SilentAim hook failed: " .. tostring(err))
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

-- ----- FOV circle -------------------------------------------------------
function SA.BuildCircle()
    if SA.CircleDrawing or SA.CircleFrame then return end
    if xDTaraZ.Caps.Drawing then
        local circle = Drawing.new("Circle")
        circle.Thickness = 1.5
        circle.NumSides  = 64
        circle.Filled    = false
        circle.Color     = xDTaraZ.Config.FovColor
        circle.Visible   = false
        SA.CircleDrawing = circle
        return
    end
    local ring = Instance.new("Frame")
    ring.Name = "SilentAimFov"
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ring
    local stroke = Instance.new("UIStroke")
    stroke.Color = xDTaraZ.Config.FovColor
    stroke.Thickness = 1.5
    stroke.Parent = ring
    ring.Parent = Util.Overlay()
    SA.CircleFrame = ring
end

function SA.UpdateCircle()
    if not xDTaraZ.Options.ShowFov then
        if SA.CircleDrawing then SA.CircleDrawing.Visible = false end
        if SA.CircleFrame then SA.CircleFrame.Visible = false end
        return
    end
    SA.BuildCircle()

    local camera = Workspace.CurrentCamera
    if not camera then return end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local radius = xDTaraZ.Options.SilentAimFov

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
    if SA.CircleDrawing then
        pcall(function() SA.CircleDrawing:Remove() end)
        SA.CircleDrawing = nil
    end
    if SA.CircleFrame then
        SA.CircleFrame:Destroy()
        SA.CircleFrame = nil
    end
end

-- ----- scheduler jobs ---------------------------------------------------
xDTaraZ.Scheduler.Every("SilentAim.Target", 0.05, function()
    if not xDTaraZ.Options.SilentAimEnabled then
        SA.Target = nil
        return
    end
    SA.Target = SA.FindTarget()
end)

xDTaraZ.Scheduler.Every("SilentAim.Circle", 0, function()
    SA.UpdateCircle()
end)

xDTaraZ.Scheduler.Every("SilentAim.Hook", 1, function()
    if xDTaraZ.Options.SilentAimEnabled and not SA.Hooked then
        SA.Apply()
    elseif not xDTaraZ.Options.SilentAimEnabled and SA.Hooked then
        SA.Restore()
    end
end)

-- =========================================================================
-- LOAD UI LIBRARY + BUILD MENU
-- =========================================================================
local Library = Util.LoadLibrary(xDTaraZ.Config.UiSource)
if not Library then
    warn("[SniperArena] menu unavailable, aborting UI build")
    return
end
xDTaraZ.Library = Library
pcall(xDTaraZ.Banner.Step, "Library")

local Window = Library:Window({
    Title = "Mario Hub",
    SubTitle = "Sniper Arena — Silent Aim",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 420),
    Theme = "Dark",
})

-- ----- Silent Aim tab ---------------------------------------------------
local AimTab = Window:Tab({ Title = "Silent Aim", Icon = "crosshair" })

AimTab:Toggle({
    Title = "Silent Aim",
    Description = "Rewrites your shot direction to the locked target.",
    Default = false,
    Flag = "SilentAimEnabled",
}, function(state)
    xDTaraZ.Options.SilentAimEnabled = state
    if not state then SA.Target = nil end
end)

AimTab:Toggle({
    Title = "Show FOV",
    Default = true,
    Flag = "ShowFov",
}, function(state)
    xDTaraZ.Options.ShowFov = state
end)

AimTab:Slider({
    Title = "FOV Radius",
    Min = 20, Max = 600, Default = 150,
    Flag = "SilentAimFov",
}, function(value)
    xDTaraZ.Options.SilentAimFov = value
end)

AimTab:Slider({
    Title = "Max Range",
    Min = 100, Max = 3000, Default = 1000,
    Flag = "SilentAimRange",
}, function(value)
    xDTaraZ.Options.SilentAimRange = value
end)

AimTab:Slider({
    Title = "Hit Chance (%)",
    Min = 1, Max = 100, Default = 100,
    Flag = "SilentAimHitChance",
}, function(value)
    xDTaraZ.Options.SilentAimHitChance = value
end)

AimTab:Slider({
    Title = "Delay Min (s)",
    Min = 0, Max = 1, Default = 0.05, Decimals = 2,
    Flag = "SilentAimDelayMin",
}, function(value)
    xDTaraZ.Options.SilentAimDelayMin = value
end)

AimTab:Slider({
    Title = "Delay Max (s)",
    Min = 0, Max = 1, Default = 0.15, Decimals = 2,
    Flag = "SilentAimDelayMax",
}, function(value)
    xDTaraZ.Options.SilentAimDelayMax = value
end)

AimTab:Dropdown({
    Title = "Target Part",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Flag = "TargetPart",
}, function(value)
    xDTaraZ.Options.TargetPart = value
end)

AimTab:Toggle({
    Title = "Visible Check",
    Description = "Require line of sight from camera to target.",
    Default = false,
    Flag = "SilentAimVisibleCheck",
}, function(state)
    xDTaraZ.Options.SilentAimVisibleCheck = state
end)

-- ----- Misc tab ---------------------------------------------------------
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

MiscTab:Toggle({
    Title = "Anti AFK",
    Default = false,
    Flag = "AntiAfk",
}, function(state)
    xDTaraZ.AntiAfk.SetEnabled(state)
end)

MiscTab:Button({ Title = "Copy Discord" }, function()
    if Util.SetClipboard then Util.SetClipboard(xDTaraZ.Config.Discord) end
end)

MiscTab:Button({ Title = "Unload Script" }, function()
    if type(environment.SniperArenaUnload) == "function" then
        pcall(environment.SniperArenaUnload)
    end
end)

-- ----- Info tab ---------------------------------------------------------
local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })

local logLines = {}
for _, entry in ipairs(xDTaraZ.Config.UpdateLog) do
    table.insert(logLines, string.format("[%s]  %s", entry[1], entry[2]))
end

InfoTab:Label({ Title = "Update Log" })
InfoTab:Paragraph({ Title = table.concat(logLines, "\n\n") })
InfoTab:Label({ Title = "Discord: " .. xDTaraZ.Config.Discord })
InfoTab:Label({ Title = "Build: Silent Aim only. Mario Hub shell." })

pcall(xDTaraZ.Banner.Step, "UI")

-- =========================================================================
-- UNLOAD
-- =========================================================================
function environment.SniperArenaUnload()
    if not xDTaraZ.State.Alive then return end
    xDTaraZ.State.Alive = false

    pcall(SA.Destroy)
    pcall(xDTaraZ.AntiAfk.SetEnabled, false)
    if xDTaraZ.AntiAfk.Connection then
        pcall(function() xDTaraZ.AntiAfk.Connection:Disconnect() end)
        xDTaraZ.AntiAfk.Connection = nil
    end

    for _, conn in ipairs(xDTaraZ.State.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(xDTaraZ.State.Connections)

    if xDTaraZ.State.Overlay then
        pcall(function() xDTaraZ.State.Overlay:Destroy() end)
        xDTaraZ.State.Overlay = nil
    end

    if Library and Library.Unload then pcall(Library.Unload, Library) end
    warn("[SniperArena] unloaded")
end

-- =========================================================================
-- BOOT
-- =========================================================================
xDTaraZ.Scheduler.Boot()
pcall(xDTaraZ.Banner.Step, "Boot")
pcall(xDTaraZ.Banner.Ready)
