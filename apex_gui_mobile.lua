-- // Apex Hub - Interface Mobile
-- // Adaptada pra celular (tela pequena, touch, scrollável)

local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local player           = Players.LocalPlayer

local Settings = {
    Enabled         = true,
    FOVRadius       = 150,
    TargetPart      = "Head",
    HitChance       = 100,
    SilentAimRange  = 1000,
    VisibleCheck    = false,
    TeamCheck       = true,
    FriendCheck     = true,
    ForceFieldCheck = true,
}

-- ══════════════════════════════════════════════════════════════
--  DETECTA TAMANHO DE TELA
-- ══════════════════════════════════════════════════════════════
local VP      = workspace.CurrentCamera.ViewportSize
local SW, SH  = VP.X, VP.Y
-- GUI ocupa 92% da largura e 85% da altura (máx 420 × 680)
local GW = math.min(math.floor(SW * 0.92), 420)
local GH = math.min(math.floor(SH * 0.85), 680)

-- ══════════════════════════════════════════════════════════════
--  SCREENGUI
-- ══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "ApexHubMobile"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = player.PlayerGui

-- ══════════════════════════════════════════════════════════════
--  FRAME PRINCIPAL
-- ══════════════════════════════════════════════════════════════
local Main = Instance.new("Frame")
Main.Name              = "Main"
Main.Size              = UDim2.fromOffset(GW, GH)
Main.Position          = UDim2.new(0.5, -GW/2, 0.5, -GH/2)
Main.BackgroundColor3  = Color3.fromRGB(6, 9, 15)
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.Parent            = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(59, 138, 255); MainStroke.Thickness = 1.5; MainStroke.Parent = Main
TweenService:Create(MainStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Thickness = 2.5}):Play()

-- ══════════════════════════════════════════════════════════════
--  ANIMAÇÃO DE FUNDO
-- ══════════════════════════════════════════════════════════════
-- hex grid leve (menos hexágonos pra não travar celular)
local HexCont = Instance.new("Frame")
HexCont.Size = UDim2.new(1,0,1,0); HexCont.BackgroundTransparency = 1
HexCont.BorderSizePixel = 0; HexCont.ZIndex = 1; HexCont.Parent = Main

local function criarHex(px, py)
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(28, 28); f.Position = UDim2.fromOffset(px, py)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 1; f.Parent = HexCont
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(59,138,255); s.Thickness = 0.5; s.Parent = f
    local dur = math.random(25, 55) / 10
    local d   = math.random(0, 300) / 100
    task.spawn(function()
        while true do
            task.wait(d)
            TweenService:Create(s, TweenInfo.new(dur/2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.78}):Play()
            task.wait(dur/2)
            TweenService:Create(s, TweenInfo.new(dur/2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.97}):Play()
            task.wait(dur/2)
        end
    end)
end

local hs = 38
for r = 0, math.ceil(GH / hs) + 1 do
    for c = 0, math.ceil(GW / hs) + 1 do
        criarHex(c * hs + (r%2==0 and 0 or hs/2) - hs, r * hs - hs)
    end
end

-- brilho central
local CG = Instance.new("Frame")
CG.Size = UDim2.fromOffset(GW * 0.8, GH * 0.5); CG.AnchorPoint = Vector2.new(.5,.5)
CG.Position = UDim2.new(.5,0,.5,0); CG.BackgroundColor3 = Color3.fromRGB(26,95,214)
CG.BackgroundTransparency = 0.9; CG.BorderSizePixel = 0; CG.ZIndex = 2; CG.Parent = Main
Instance.new("UICorner", CG).CornerRadius = UDim.new(1,0)
TweenService:Create(CG, TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true), {BackgroundTransparency=0.84}):Play()

-- scanline
local Scan = Instance.new("Frame")
Scan.Size = UDim2.new(1,0,0,1); Scan.BackgroundColor3 = Color3.fromRGB(59,138,255)
Scan.BackgroundTransparency = 0.55; Scan.BorderSizePixel = 0; Scan.ZIndex = 4; Scan.Parent = Main
local sg = Instance.new("UIGradient")
sg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(.3, Color3.fromRGB(59,138,255)),
    ColorSequenceKeypoint.new(.7, Color3.fromRGB(59,138,255)),
    ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
}); sg.Parent = Scan
local sY = 0
RunService.Heartbeat:Connect(function(dt)
    sY += dt * 0.26; if sY > 1.02 then sY = -0.02 end
    Scan.Position = UDim2.new(0,0,sY,0)
    Scan.BackgroundTransparency = (sY<.03 or sY>.97) and 1 or .55
end)

-- partículas (reduzido pra mobile)
local function spawnP()
    local p = Instance.new("Frame")
    local sz = math.random(2,3)
    p.Size = UDim2.fromOffset(sz,sz); p.AnchorPoint = Vector2.new(.5,.5)
    p.Position = UDim2.new(math.random(5,95)/100, 0, 1.02, 0)
    p.BackgroundColor3 = Color3.fromRGB(79,163,255)
    p.BackgroundTransparency = math.random(30,60)/100
    p.BorderSizePixel = 0; p.ZIndex = 3; p.Parent = Main
    Instance.new("UICorner",p).CornerRadius = UDim.new(1,0)
    local t = TweenService:Create(p, TweenInfo.new(math.random(4,8), Enum.EasingStyle.Linear), {
        Position = UDim2.new(p.Position.X.Scale + (math.random(-6,6)/100), 0, -0.04, 0),
        BackgroundTransparency = 1
    })
    t:Play(); t.Completed:Connect(function() p:Destroy() end)
end
local acc = 0
RunService.Heartbeat:Connect(function(dt)
    acc += dt; if acc >= 0.5 then acc = 0; spawnP() end
end)

-- cantos
local function canto(ax, ay, px, py)
    local f = Instance.new("Frame"); f.Size = UDim2.fromOffset(14,14)
    f.AnchorPoint = Vector2.new(ax,ay)
    f.Position = UDim2.new(px, ax==0 and 8 or -8, py, ay==0 and 8 or -8)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 5; f.Parent = Main
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(100,180,255); s.Thickness = 2; s.Parent = f
end
canto(0,0,0,0); canto(1,0,1,0); canto(0,1,0,1); canto(1,1,1,1)

-- ══════════════════════════════════════════════════════════════
--  TOPBAR
-- ══════════════════════════════════════════════════════════════
local TB_H = 44
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1,0,0,TB_H)
Topbar.BackgroundColor3 = Color3.fromRGB(10,16,30)
Topbar.BackgroundTransparency = 0.1
Topbar.BorderSizePixel = 0; Topbar.ZIndex = 10; Topbar.Parent = Main
local TStroke = Instance.new("UIStroke"); TStroke.Color = Color3.fromRGB(26,95,214); TStroke.Thickness = 0.5; TStroke.Parent = Topbar

-- ícone triângulo
local TriBg = Instance.new("Frame")
TriBg.Size = UDim2.fromOffset(28,28); TriBg.Position = UDim2.fromOffset(10, 8)
TriBg.BackgroundColor3 = Color3.fromRGB(26,95,214); TriBg.BackgroundTransparency = 0.5
TriBg.BorderSizePixel = 0; TriBg.ZIndex = 11; TriBg.Parent = Topbar
Instance.new("UICorner",TriBg).CornerRadius = UDim.new(0,6)
TweenService:Create(TriBg, TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true), {BackgroundTransparency=0.3}):Play()

local TitleL = Instance.new("TextLabel")
TitleL.Size = UDim2.fromOffset(160, TB_H); TitleL.Position = UDim2.fromOffset(46, 0)
TitleL.BackgroundTransparency = 1; TitleL.RichText = true
TitleL.Text = '<font color="#ffffff" weight="800">APEX</font> <font color="#3b8aff" weight="800">HUB</font>'
TitleL.Font = Enum.Font.GothamBold; TitleL.TextSize = 16
TitleL.TextColor3 = Color3.fromRGB(255,255,255)
TitleL.TextXAlignment = Enum.TextXAlignment.Left
TitleL.ZIndex = 11; TitleL.Parent = Topbar

-- ponto status
local SDot = Instance.new("Frame")
SDot.Size = UDim2.fromOffset(7,7); SDot.AnchorPoint = Vector2.new(0,.5)
SDot.Position = UDim2.new(0,210,.5,0)
SDot.BackgroundColor3 = Color3.fromRGB(59,138,255)
SDot.BorderSizePixel = 0; SDot.ZIndex = 11; SDot.Parent = Topbar
Instance.new("UICorner",SDot).CornerRadius = UDim.new(1,0)
TweenService:Create(SDot, TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true), {BackgroundTransparency=0.5}):Play()

-- versão
local VerL = Instance.new("TextLabel")
VerL.Size = UDim2.fromOffset(100, TB_H); VerL.AnchorPoint = Vector2.new(1,0)
VerL.Position = UDim2.new(1,-50,0,0)
VerL.BackgroundTransparency = 1; VerL.Text = "v2.0"
VerL.Font = Enum.Font.Gotham; VerL.TextSize = 11
VerL.TextColor3 = Color3.fromRGB(80,130,200)
VerL.TextXAlignment = Enum.TextXAlignment.Right
VerL.ZIndex = 11; VerL.Parent = Topbar

-- fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(32, 32); CloseBtn.AnchorPoint = Vector2.new(1,.5)
CloseBtn.Position = UDim2.new(1,-6,.5,0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160,40,40); CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "✕"; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BorderSizePixel = 0; CloseBtn.ZIndex = 12; CloseBtn.Parent = Topbar
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(0,8)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {BackgroundTransparency=1, Size=UDim2.fromOffset(GW*.8, GH*.8)}):Play()
    task.wait(.28); ScreenGui:Destroy()
end)

-- ══════════════════════════════════════════════════════════════
--  TAB BAR (ícones + texto pequeno)
-- ══════════════════════════════════════════════════════════════
local TAB_H = 36
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,TAB_H); TabBar.Position = UDim2.fromOffset(0, TB_H)
TabBar.BackgroundColor3 = Color3.fromRGB(8,12,22); TabBar.BackgroundTransparency = 0.1
TabBar.BorderSizePixel = 0; TabBar.ZIndex = 10; TabBar.Parent = Main
local TBStroke = Instance.new("UIStroke"); TBStroke.Color = Color3.fromRGB(26,95,214); TBStroke.Thickness = 0.5; TBStroke.Parent = TabBar

local tabDefs = {
    {name="PRINCIPAL", short="MIRA"},
    {name="ARMAS",     short="ARMAS"},
    {name="VISUAL",    short="ESP"},
    {name="CONFIG",    short="CFG"},
}
local TabBtns  = {}
local TabPages = {}
local ActiveTab = "PRINCIPAL"

for i, td in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabDefs, 0, 1, 0)
    btn.Position = UDim2.new((i-1)/#tabDefs, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = td.short; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(80,130,200)
    btn.ZIndex = 11; btn.Parent = TabBar

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(1,0,0,2); ind.Position = UDim2.new(0,0,1,-2)
    ind.BackgroundColor3 = Color3.fromRGB(59,138,255); ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0; ind.ZIndex = 12; ind.Parent = btn

    TabBtns[td.name] = {btn=btn, ind=ind}
    btn.MouseButton1Click:Connect(function() switchTab(td.name) end)
end

-- ══════════════════════════════════════════════════════════════
--  SCROLL CONTAINER (área de conteúdo)
-- ══════════════════════════════════════════════════════════════
local CONTENT_Y = TB_H + TAB_H
local FOOTER_H  = 24
local CONTENT_H = GH - CONTENT_Y - FOOTER_H

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,0,0,CONTENT_H)
ScrollFrame.Position = UDim2.fromOffset(0, CONTENT_Y)
ScrollFrame.BackgroundTransparency = 1; ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3; ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(59,138,255)
ScrollFrame.ScrollBarImageTransparency = 0.5
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)   -- ajustado por tab
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ZIndex = 6; ScrollFrame.Parent = Main

-- layout do scroll
local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Padding = UDim.new(0,8)
ScrollLayout.Parent = ScrollFrame

local ScrollPad = Instance.new("UIPadding")
ScrollPad.PaddingLeft = UDim.new(0,8); ScrollPad.PaddingRight = UDim.new(0,8)
ScrollPad.PaddingTop = UDim.new(0,8); ScrollPad.PaddingBottom = UDim.new(0,8)
ScrollPad.Parent = ScrollFrame

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function newGroup(title, order)
    local g = Instance.new("Frame")
    g.Size = UDim2.new(1, 0, 0, 0)
    g.AutomaticSize = Enum.AutomaticSize.Y
    g.BackgroundColor3 = Color3.fromRGB(14,22,44)
    g.BackgroundTransparency = 0.3
    g.BorderSizePixel = 0; g.LayoutOrder = order; g.ZIndex = 7; g.Parent = ScrollFrame
    Instance.new("UICorner",g).CornerRadius = UDim.new(0,8)
    local gs = Instance.new("UIStroke"); gs.Color = Color3.fromRGB(26,95,214); gs.Thickness = 0.5; gs.Parent = g

    local lay = Instance.new("UIListLayout")
    lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Padding = UDim.new(0,0); lay.Parent = g

    -- header
    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1,0,0,30); hdr.BackgroundColor3 = Color3.fromRGB(59,138,255)
    hdr.BackgroundTransparency = 0.86; hdr.BorderSizePixel = 0; hdr.LayoutOrder = 0; hdr.ZIndex = 8; hdr.Parent = g
    Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,8)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-12,1,0); lbl.Position = UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency = 1; lbl.Text = title
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(100,160,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 9; lbl.Parent = hdr
    return g
end

local ROW_H = 44
local function addToggle(group, text, default, order, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,ROW_H); row.BackgroundTransparency = 1
    row.BorderSizePixel = 0; row.LayoutOrder = order; row.ZIndex = 8; row.Parent = group

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-70,1,0); lbl.Position = UDim2.fromOffset(14,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(210,225,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 9; lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(44, 22); pill.AnchorPoint = Vector2.new(1,.5)
    pill.Position = UDim2.new(1,-12,.5,0)
    pill.BackgroundColor3 = default and Color3.fromRGB(59,138,255) or Color3.fromRGB(30,45,80)
    pill.BorderSizePixel = 0; pill.ZIndex = 9; pill.Parent = row
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16,16); knob.AnchorPoint = Vector2.new(.5,.5)
    knob.Position = default and UDim2.new(1,-11,.5,0) or UDim2.new(0,11,.5,0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0; knob.ZIndex = 10; knob.Parent = pill
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    -- separador
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1,-24,0,1); sep.Position = UDim2.fromOffset(12, ROW_H-1)
    sep.BackgroundColor3 = Color3.fromRGB(26,60,120); sep.BackgroundTransparency = 0.7
    sep.BorderSizePixel = 0; sep.ZIndex = 8; sep.Parent = row

    local state = default
    local function tap()
        state = not state
        TweenService:Create(pill,TweenInfo.new(.18),{BackgroundColor3=state and Color3.fromRGB(59,138,255) or Color3.fromRGB(30,45,80)}):Play()
        TweenService:Create(knob,TweenInfo.new(.18),{Position=state and UDim2.new(1,-11,.5,0) or UDim2.new(0,11,.5,0)}):Play()
        if cb then cb(state) end
    end
    row.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then tap() end
    end)
    return row
end

local SL_H = 56
local function addSlider(group, text, default, min, max, order, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,SL_H); row.BackgroundTransparency = 1
    row.BorderSizePixel = 0; row.LayoutOrder = order; row.ZIndex = 8; row.Parent = group

    local head = Instance.new("Frame")
    head.Size = UDim2.new(1,0,0,22); head.BackgroundTransparency = 1
    head.Position = UDim2.fromOffset(0,4); head.ZIndex = 9; head.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(.7,0,1,0); lbl.Position = UDim2.fromOffset(14,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(210,225,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 9; lbl.Parent = head

    local valL = Instance.new("TextLabel")
    valL.Size = UDim2.new(.3,0,1,0); valL.AnchorPoint = Vector2.new(1,0)
    valL.Position = UDim2.new(1,-12,0,0); valL.BackgroundTransparency = 1
    valL.Text = tostring(default); valL.Font = Enum.Font.GothamBold; valL.TextSize = 13
    valL.TextColor3 = Color3.fromRGB(59,138,255)
    valL.TextXAlignment = Enum.TextXAlignment.Right; valL.ZIndex = 9; valL.Parent = head

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-24,0,5); track.Position = UDim2.fromOffset(12, 30)
    track.BackgroundColor3 = Color3.fromRGB(30,45,80); track.BorderSizePixel = 0
    track.ZIndex = 9; track.Parent = row
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local pct = (default-min)/(max-min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = Color3.fromRGB(59,138,255)
    fill.BorderSizePixel = 0; fill.ZIndex = 10; fill.Parent = track
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    local ug = Instance.new("UIGradient")
    ug.Color = ColorSequence.new(Color3.fromRGB(26,95,214), Color3.fromRGB(100,180,255)); ug.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.fromOffset(18,18); thumb.AnchorPoint = Vector2.new(.5,.5)
    thumb.Position = UDim2.new(pct,0,.5,0)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel = 0; thumb.ZIndex = 11; thumb.Parent = track
    Instance.new("UICorner",thumb).CornerRadius = UDim.new(1,0)
    local tStroke = Instance.new("UIStroke"); tStroke.Color = Color3.fromRGB(59,138,255); tStroke.Thickness = 1.5; tStroke.Parent = thumb

    -- sep
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1,-24,0,1); sep.Position = UDim2.fromOffset(12,SL_H-1)
    sep.BackgroundColor3 = Color3.fromRGB(26,60,120); sep.BackgroundTransparency = 0.7
    sep.BorderSizePixel = 0; sep.ZIndex = 8; sep.Parent = row

    -- drag touch
    local sliding = false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseMovement) then
            local relX = inp.Position.X - track.AbsolutePosition.X
            local p = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(p,0,1,0)
            thumb.Position = UDim2.new(p,0,.5,0)
            local v = math.round(min + (max-min)*p)
            valL.Text = tostring(v)
            if cb then cb(v) end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  PÁGINAS
-- ══════════════════════════════════════════════════════════════

-- guarda quais grupos pertencem a qual tab
local tabGroups = {PRINCIPAL={}, ARMAS={}, VISUAL={}, CONFIG={}}

local function hideAll()
    for _, grps in pairs(tabGroups) do
        for _, g in ipairs(grps) do g.Visible = false end
    end
end

local function showTab(name)
    hideAll()
    for _, g in ipairs(tabGroups[name] or {}) do g.Visible = true end
end

local function reg(tabName, group)
    table.insert(tabGroups[tabName], group)
    group.Visible = false
    return group
end

-- ── PRINCIPAL ────────────────────────────────────────────────
local gAim = reg("PRINCIPAL", newGroup("AIM SETTINGS", 1))
addToggle(gAim,"Silent Aim",    Settings.Enabled,       1, function(v) Settings.Enabled=v end)
addToggle(gAim,"Auto Shoot",    false,                  2, function(v) Settings.AutoShoot=v end)
addToggle(gAim,"Wall Check",    Settings.VisibleCheck,  3, function(v) Settings.VisibleCheck=v end)
addToggle(gAim,"Team Check",    Settings.TeamCheck,     4, function(v) Settings.TeamCheck=v end)
addToggle(gAim,"Friend Check",  Settings.FriendCheck,   5, function(v) Settings.FriendCheck=v end)
addToggle(gAim,"Force Field",   Settings.ForceFieldCheck,6,function(v) Settings.ForceFieldCheck=v end)

local gSmooth = reg("PRINCIPAL", newGroup("SMOOTHING & ALCANCE", 2))
addSlider(gSmooth,"Alcance da Mira", Settings.SilentAimRange, 30,2000, 1, function(v) Settings.SilentAimRange=v end)
addSlider(gSmooth,"Hit Chance",      Settings.HitChance,      0,100,   2, function(v) Settings.HitChance=v end)

local gFOV = reg("PRINCIPAL", newGroup("FOV", 3))
addSlider(gFOV,"FOV Radius", Settings.FOVRadius, 30,500, 1, function(v)
    Settings.FOVRadius=v
    -- FOVCircle.Size = UDim2.fromOffset(v*2,v*2)
end)

local gHitbox = reg("PRINCIPAL", newGroup("HITBOX EXPANDER", 4))
addToggle(gHitbox,"Hitbox Expander", false, 1, function(v) Settings.HitboxExpanderEnabled=v end)
addToggle(gHitbox,"Team Check",      true,  2, function(v) Settings.HitboxTeamCheck=v end)
addSlider(gHitbox,"Tamanho",         1, 1,15, 3, function(v) Settings.HitboxSize=v end)

-- ── ARMAS ────────────────────────────────────────────────────
local gWep = reg("ARMAS", newGroup("WEAPON MOD", 1))
addToggle(gWep,"Modificar Armas",    false,1,function(v) end)
addToggle(gWep,"Auto Fire",          false,2,function(v) end)
addToggle(gWep,"Tiro Rápido",        false,3,function(v) end)
addToggle(gWep,"Recarga Automática", false,4,function(v) end)

local gSwitch = reg("ARMAS", newGroup("GUN SWITCHER", 2))
addToggle(gSwitch,"Fast Switch",      false,1,function(v) end)
addToggle(gSwitch,"Cycle All Weapons",false,2,function(v) end)
addSlider(gSwitch,"Switch Delay",0.001,0.001,1,3,function(v) end)

-- ── VISUAL ───────────────────────────────────────────────────
local gESP = reg("VISUAL", newGroup("HIGHLIGHT ESP", 1))
addToggle(gESP,"Highlight ESP",      false,1,function(v) Settings.ESPEnabled=v end)
addToggle(gESP,"Name ESP",           true, 2,function(v) Settings.ESPNamesEnabled=v end)
addToggle(gESP,"Target Name ESP",    false,3,function(v) Settings.ESPTargetNameEnabled=v end)
addToggle(gESP,"Tracer ESP",         false,4,function(v) Settings.TracerESPEnabled=v end)

local gFull = reg("VISUAL", newGroup("AMBIENTE", 2))
addToggle(gFull,"Fullbright",   false,1,function(v)
    game:GetService("Lighting").Brightness = v and 10 or 1
end)
addToggle(gFull,"Remove Fog",   false,2,function(v)
    local L = game:GetService("Lighting")
    L.FogEnd=v and 100000 or 5000; L.FogStart=v and 100000 or 500
end)

-- ── CONFIG ───────────────────────────────────────────────────
local gMenu = reg("CONFIG", newGroup("MENU", 1))
addToggle(gMenu,"Custom Cursor", true, 1,function(v) end)
addToggle(gMenu,"Always On Top", false,2,function(v) end)

local gPlayer = reg("CONFIG", newGroup("PLAYER", 2))
addToggle(gPlayer,"Infinite Jump", false,1,function(v)
    getgenv().InfJump = v
    if v then
        UserInputService.JumpRequest:Connect(function()
            if getgenv().InfJump then
                local char = player.Character
                if char then char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)
addToggle(gPlayer,"Noclip", false,2,function(v)
    getgenv().NoclipEnabled = v
    if v then
        RunService.Stepped:Connect(function()
            if getgenv().NoclipEnabled and player.Character then
                for _, p in ipairs(player.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end
        end)
    end
end)
addSlider(gPlayer,"Walk Speed", 16, 16, 150, 3, function(v)
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
    end
end)
addSlider(gPlayer,"Jump Power", 50, 50, 300, 4, function(v)
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").JumpPower = v
    end
end)

-- ══════════════════════════════════════════════════════════════
--  SWITCH DE TAB
-- ══════════════════════════════════════════════════════════════
function switchTab(name)
    for n, data in pairs(TabBtns) do
        local on = (n == name)
        TweenService:Create(data.btn,TweenInfo.new(.15),{TextColor3=on and Color3.fromRGB(59,138,255) or Color3.fromRGB(80,130,200)}):Play()
        TweenService:Create(data.ind,TweenInfo.new(.15),{BackgroundTransparency=on and 0 or 1}):Play()
    end
    showTab(name)
    ScrollFrame.CanvasPosition = Vector2.new(0,0)
    ActiveTab = name
end

switchTab("PRINCIPAL")

-- ══════════════════════════════════════════════════════════════
--  FOOTER
-- ══════════════════════════════════════════════════════════════
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1,0,0,FOOTER_H); Footer.AnchorPoint = Vector2.new(0,1)
Footer.Position = UDim2.new(0,0,1,0)
Footer.BackgroundColor3 = Color3.fromRGB(8,12,22); Footer.BackgroundTransparency = 0.1
Footer.BorderSizePixel = 0; Footer.ZIndex = 10; Footer.Parent = Main
local FStroke = Instance.new("UIStroke"); FStroke.Color = Color3.fromRGB(26,95,214); FStroke.Thickness = 0.5; FStroke.Parent = Footer

local FLeft = Instance.new("TextLabel")
FLeft.Size = UDim2.new(.5,0,1,0); FLeft.Position = UDim2.fromOffset(10,0)
FLeft.BackgroundTransparency = 1; FLeft.Text = "APEX HUB · Prison Life"
FLeft.Font = Enum.Font.Gotham; FLeft.TextSize = 10
FLeft.TextColor3 = Color3.fromRGB(70,110,180)
FLeft.TextXAlignment = Enum.TextXAlignment.Left; FLeft.ZIndex = 11; FLeft.Parent = Footer

local FRight = Instance.new("TextLabel")
FRight.Size = UDim2.new(.5,-8,1,0); FRight.AnchorPoint = Vector2.new(1,0)
FRight.Position = UDim2.new(1,-8,0,0); FRight.BackgroundTransparency = 1
FRight.Font = Enum.Font.GothamBold; FRight.TextSize = 10
FRight.TextColor3 = Color3.fromRGB(59,138,255)
FRight.TextXAlignment = Enum.TextXAlignment.Right; FRight.ZIndex = 11; FRight.Parent = Footer

task.spawn(function()
    while Main.Parent do
        FRight.Text = "● SA " .. (Settings.Enabled and "ON" or "OFF")
        FRight.TextColor3 = Settings.Enabled and Color3.fromRGB(59,138,255) or Color3.fromRGB(180,60,60)
        task.wait(.9); FRight.TextTransparency=.5; task.wait(.4); FRight.TextTransparency=0
    end
end)

-- ══════════════════════════════════════════════════════════════
--  BOTÃO FLUTUANTE (reabre a GUI, canto da tela)
-- ══════════════════════════════════════════════════════════════
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.fromOffset(44,44)
FloatBtn.Position = UDim2.fromOffset(10, SH - 60)
FloatBtn.BackgroundColor3 = Color3.fromRGB(14,22,44)
FloatBtn.BackgroundTransparency = 0.1
FloatBtn.Text = "A"; FloatBtn.Font = Enum.Font.GothamBold; FloatBtn.TextSize = 16
FloatBtn.TextColor3 = Color3.fromRGB(59,138,255)
FloatBtn.BorderSizePixel = 0; FloatBtn.ZIndex = 20; FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui
Instance.new("UICorner",FloatBtn).CornerRadius = UDim.new(0,10)
local FBStroke = Instance.new("UIStroke"); FBStroke.Color = Color3.fromRGB(59,138,255); FBStroke.Thickness = 1.5; FBStroke.Parent = FloatBtn

FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = true; FloatBtn.Visible = false
end)
CloseBtn.MouseButton1Click:Connect(function()
    task.wait(.3); FloatBtn.Visible = true
end)

-- drag no botão flutuante
local fbDrag, fbStart, fbPos = false, nil, nil
FloatBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
        fbDrag=true; fbStart=inp.Position; fbPos=FloatBtn.Position
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then fbDrag=false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if fbDrag and (inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseMovement) then
        local d=inp.Position-fbStart
        FloatBtn.Position=UDim2.new(fbPos.X.Scale,fbPos.X.Offset+d.X,fbPos.Y.Scale,fbPos.Y.Offset+d.Y)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  ANIMAÇÃO DE ENTRADA
-- ══════════════════════════════════════════════════════════════
Main.Size = UDim2.fromOffset(GW*.85, GH*.85)
Main.BackgroundTransparency = 1
TweenService:Create(Main, TweenInfo.new(.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.fromOffset(GW,GH), BackgroundTransparency=0}):Play()

-- ══════════════════════════════════════════════════════════════
--  COLE O SEU SILENT AIM ABAIXO
-- ══════════════════════════════════════════════════════════════
