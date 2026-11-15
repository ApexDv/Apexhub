-- // Apex Hub - Interface Completa
-- // Compatível com o seu Silent Aim script
-- // Cola o seu silent aim script DEPOIS dessa GUI

local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local Players         = game:GetService("Players")
local player          = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  SETTINGS (conecta com o seu script de silent aim)
-- ══════════════════════════════════════════════════════════════
local Settings = {
    Enabled        = true,
    FOVRadius      = 150,
    TargetPart     = "Head",
    HitChance      = 100,
    SilentAimRange = 1000,
    VisibleCheck   = false,
    TeamCheck      = true,
    FriendCheck    = true,
    ForceFieldCheck= true,
}
-- se o seu script usa getgenv(), troca por:
-- local Settings = getgenv().Settings  ou  getgenv().SilentAimSettings
-- ══════════════════════════════════════════════════════════════
--  SCREENGUI
-- ══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "ApexHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = player.PlayerGui

-- ══════════════════════════════════════════════════════════════
--  FRAME PRINCIPAL  (700 × 500, centralizando)
-- ══════════════════════════════════════════════════════════════
local W, H = 700, 500

local Main = Instance.new("Frame")
Main.Name                   = "Main"
Main.Size                   = UDim2.fromOffset(W, H)
Main.Position               = UDim2.new(.5,-W/2,.5,-H/2)
Main.BackgroundColor3       = Color3.fromRGB(6, 9, 15)
Main.BorderSizePixel        = 0
Main.ClipsDescendants       = true
Main.Parent                 = ScreenGui
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,10)

-- borda neon pulsando
local MainStroke = Instance.new("UIStroke")
MainStroke.Color     = Color3.fromRGB(59,138,255)
MainStroke.Thickness = 1.5
MainStroke.Parent    = Main
TweenService:Create(MainStroke,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Thickness=2.5}):Play()

-- ══════════════════════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════════════════════
local dragging,dragStart,startPos
Main.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; startPos=Main.Position
        inp.Changed:Connect(function()
            if inp.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseMovement and dragging then
        local d=inp.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
-- ══════════════════════════════════════════════════════════════
--  ANIMAÇÃO DE FUNDO
-- ══════════════════════════════════════════════════════════════

-- hex grid
local HexContainer = Instance.new("Frame")
HexContainer.Size=UDim2.new(1,0,1,0)
HexContainer.BackgroundTransparency=1
HexContainer.BorderSizePixel=0
HexContainer.ZIndex=1
HexContainer.Parent=Main

local function criarHex(px,py)
    local f=Instance.new("Frame")
    f.Size=UDim2.fromOffset(26,26)
    f.Position=UDim2.fromOffset(px,py)
    f.BackgroundTransparency=1
    f.BorderSizePixel=0
    f.ZIndex=1
    f.Parent=HexContainer
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(59,138,255);s.Thickness=0.5;s.Parent=f
    local d=math.random(0,300)/100
    local dur=math.random(20,50)/10
    task.spawn(function()
        while true do
            task.wait(d)
            TweenService:Create(s,TweenInfo.new(dur/2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.78}):Play()
            task.wait(dur/2)
            TweenService:Create(s,TweenInfo.new(dur/2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.97}):Play()
            task.wait(dur/2)
        end
    end)
end
local hs=34
for r=0,math.ceil(H/hs)+1 do
    for c=0,math.ceil(W/hs)+1 do
        criarHex(c*hs+(r%2==0 and 0 or hs/2)-hs, r*hs-hs)
    end
end
-- brilho central
local CG=Instance.new("Frame")
CG.Size=UDim2.fromOffset(500,300)
CG.AnchorPoint=Vector2.new(.5,.5)
CG.Position=UDim2.new(.5,0,.5,0)
CG.BackgroundColor3=Color3.fromRGB(26,95,214)
CG.BackgroundTransparency=0.9
CG.BorderSizePixel=0
CG.ZIndex=2
CG.Parent=Main
Instance.new("UICorner",CG).CornerRadius=UDim.new(1,0)
TweenService:Create(CG,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.84}):Play()

-- beams
local function criarBeam(ax,ay,px,py,rot)
    local b=Instance.new("Frame")
    b.Size=UDim2.fromOffset(360,2)
    b.AnchorPoint=Vector2.new(ax,.5)
    b.Position=UDim2.new(px,0,py,0)
    b.Rotation=rot
    b.BackgroundColor3=Color3.fromRGB(59,138,255)
    b.BackgroundTransparency=0.72
    b.BorderSizePixel=0
    b.ZIndex=2
    b.Parent=Main
    local g=Instance.new("UIGradient")
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(59,138,255)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
    g.Parent=b
    TweenService:Create(b,TweenInfo.new(2+math.random()*1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.52}):Play()
end
criarBeam(0,0,0,.22,-30); criarBeam(1,0,1,.22,30)
criarBeam(0,0,0,.78,30);  criarBeam(1,0,1,.78,-30)

-- partículas
local function spawn()
    local p=Instance.new("Frame")
    local sz=math.random(2,4)
    p.Size=UDim2.fromOffset(sz,sz)
    p.AnchorPoint=Vector2.new(.5,.5)
    p.Position=UDim2.new(math.random(5,95)/100,0,1.02,0)
    p.BackgroundColor3=Color3.fromRGB(79,163,255)
    p.BackgroundTransparency=math.random(20,55)/100
    p.BorderSizePixel=0;p.ZIndex=3;p.Parent=Main
    Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
    local t=TweenService:Create(p,TweenInfo.new(math.random(35,65)/10,Enum.EasingStyle.Linear),{
        Position=UDim2.new(p.Position.X.Scale+(math.random(-8,8)/100),0,-0.04,0),
        BackgroundTransparency=1})
    t:Play(); t.Completed:Connect(function() p:Destroy() end)
end
local acc=0
RunService.Heartbeat:Connect(function(dt)
    acc+=dt; if acc>=0.28 then acc=0; spawn() end
end)

-- scanline
local Scan=Instance.new("Frame")
Scan.Size=UDim2.new(1,0,0,1)
Scan.BackgroundColor3=Color3.fromRGB(59,138,255)
Scan.BackgroundTransparency=0.55
Scan.BorderSizePixel=0;Scan.ZIndex=4;Scan.Parent=Main
local sg=Instance.new("UIGradient")
sg.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(.25,Color3.fromRGB(59,138,255)),
    ColorSequenceKeypoint.new(.75,Color3.fromRGB(59,138,255)),
    ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
sg.Parent=Scan
local sY=0
RunService.Heartbeat:Connect(function(dt)
    sY+=dt*.28; if sY>1.02 then sY=-0.02 end
    Scan.Position=UDim2.new(0,0,sY,0)
    Scan.BackgroundTransparency=(sY<.03 or sY>.97) and 1 or .55
end)

-- cantos decorativos
local function canto(ax,ay,px,py)
    local f=Instance.new("Frame")
    f.Size=UDim2.fromOffset(14,14)
    f.AnchorPoint=Vector2.new(ax,ay)
    f.Position=UDim2.new(px,ax==0 and 8 or -8,py,ay==0 and 8 or -8)
    f.BackgroundTransparency=1;f.BorderSizePixel=0;f.ZIndex=5;f.Parent=Main
    local s=Instance.new("UIStroke");s.Color=Color3.fromRGB(100,180,255);s.Thickness=2;s.Parent=f
end
canto(0,0,0,0);canto(1,0,1,0);canto(0,1,0,1);canto(1,1,1,1)
-- ══════════════════════════════════════════════════════════════
--  TOPBAR
-- ══════════════════════════════════════════════════════════════
local Topbar=Instance.new("Frame")
Topbar.Size=UDim2.new(1,0,0,42)
Topbar.BackgroundColor3=Color3.fromRGB(10,16,30)
Topbar.BackgroundTransparency=0.15
Topbar.BorderSizePixel=0;Topbar.ZIndex=10;Topbar.Parent=Main
local TopStroke=Instance.new("UIStroke")
TopStroke.Color=Color3.fromRGB(26,95,214);TopStroke.Thickness=0.5;TopStroke.Parent=Topbar

-- logo triângulo
local Logo=Instance.new("ImageLabel")
Logo.Size=UDim2.fromOffset(24,24)
Logo.Position=UDim2.fromOffset(12,9)
Logo.BackgroundTransparency=1;Logo.ZIndex=11;Logo.Parent=Topbar
-- SVG inline não funciona no Roblox, então usamos UI shapes
local TriOuter=Instance.new("Frame")
TriOuter.Size=UDim2.fromOffset(20,20);TriOuter.Position=UDim2.fromOffset(12,11)
TriOuter.BackgroundColor3=Color3.fromRGB(59,138,255);TriOuter.BackgroundTransparency=0.6
TriOuter.BorderSizePixel=0;TriOuter.Rotation=0;TriOuter.ZIndex=11;TriOuter.Parent=Topbar
Instance.new("UICorner",TriOuter).CornerRadius=UDim.new(0,3)
TweenService:Create(TriOuter,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.4}):Play()

local TitleLabel=Instance.new("TextLabel")
TitleLabel.Size=UDim2.new(0,120,1,0)
TitleLabel.Position=UDim2.fromOffset(40,0)
TitleLabel.BackgroundTransparency=1
TitleLabel.Text="APEX HUB"
TitleLabel.Font=Enum.Font.GothamBold
TitleLabel.TextSize=15
TitleLabel.TextColor3=Color3.fromRGB(255,255,255)
TitleLabel.TextXAlignment=Enum.TextXAlignment.Left
TitleLabel.ZIndex=11;TitleLabel.Parent=Topbar

-- "HUB" em azul via RichText
TitleLabel.RichText=true
TitleLabel.Text='<font color="#ffffff">APEX </font><font color="#3b8aff">HUB</font>'

-- ponto pulsando (status ativo)
local StatusDot=Instance.new("Frame")
StatusDot.Size=UDim2.fromOffset(8,8)
StatusDot.AnchorPoint=Vector2.new(0,.5)
StatusDot.Position=UDim2.new(0,170,.5,0)
StatusDot.BackgroundColor3=Color3.fromRGB(59,138,255)
StatusDot.BorderSizePixel=0;StatusDot.ZIndex=11;StatusDot.Parent=Topbar
Instance.new("UICorner",StatusDot).CornerRadius=UDim.new(1,0)
TweenService:Create(StatusDot,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.4}):Play()

local VerLabel=Instance.new("TextLabel")
VerLabel.Size=UDim2.new(0,120,1,0)
VerLabel.AnchorPoint=Vector2.new(1,0)
VerLabel.Position=UDim2.new(1,-50,0,0)
VerLabel.BackgroundTransparency=1
VerLabel.Text="v2.0 · Prison Life"
VerLabel.Font=Enum.Font.Gotham;VerLabel.TextSize=11
VerLabel.TextColor3=Color3.fromRGB(100,160,220)
VerLabel.TextXAlignment=Enum.TextXAlignment.Right
VerLabel.ZIndex=11;VerLabel.Parent=Topbar

-- botão fechar
local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.fromOffset(28,28)
CloseBtn.AnchorPoint=Vector2.new(1,.5)
CloseBtn.Position=UDim2.new(1,-8,.5,0)
CloseBtn.BackgroundColor3=Color3.fromRGB(160,40,40)
CloseBtn.BackgroundTransparency=0.4
CloseBtn.Text="✕";CloseBtn.Font=Enum.Font.GothamBold;CloseBtn.TextSize=14
CloseBtn.TextColor3=Color3.fromRGB(255,255,255)
CloseBtn.BorderSizePixel=0;CloseBtn.ZIndex=12;CloseBtn.Parent=Topbar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1,Size=UDim2.fromOffset(W*.8,H*.8)}):Play()
    task.wait(.3); ScreenGui:Destroy()
end)
-- ══════════════════════════════════════════════════════════════
--  TAB BAR
-- ══════════════════════════════════════════════════════════════
local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,0,0,32)
TabBar.Position=UDim2.fromOffset(0,42)
TabBar.BackgroundColor3=Color3.fromRGB(8,12,22)
TabBar.BackgroundTransparency=0.2
TabBar.BorderSizePixel=0;TabBar.ZIndex=10;TabBar.Parent=Main
local TabStroke=Instance.new("UIStroke")
TabStroke.Color=Color3.fromRGB(26,95,214);TabStroke.Thickness=0.5;TabStroke.Parent=TabBar

local tabNames={"PRINCIPAL","ARMAS","VISUAL","CONFIG"}
local TabBtns={}
local ActiveTab="PRINCIPAL"
local TabPages={}

local function makeTab(name,idx)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1/#tabNames,0,1,0)
    btn.Position=UDim2.new((idx-1)/#tabNames,0,0,0)
    btn.BackgroundTransparency=1
    btn.Text=name;btn.Font=Enum.Font.GothamBold;btn.TextSize=10
    btn.TextColor3=Color3.fromRGB(100,150,220)
    btn.ZIndex=11;btn.Parent=TabBar
    -- indicador
    local ind=Instance.new("Frame")
    ind.Size=UDim2.new(1,0,0,2)
    ind.Position=UDim2.new(0,0,1,-2)
    ind.BackgroundColor3=Color3.fromRGB(59,138,255)
    ind.BackgroundTransparency=1
    ind.BorderSizePixel=0;ind.ZIndex=12;ind.Parent=btn
    TabBtns[name]={btn=btn,ind=ind}
    return btn,ind
end

for i,n in ipairs(tabNames) do makeTab(n,i) end

-- página container
local PageContainer=Instance.new("Frame")
PageContainer.Size=UDim2.new(1,0,1,-96)
PageContainer.Position=UDim2.fromOffset(0,74)
PageContainer.BackgroundTransparency=1
PageContainer.BorderSizePixel=0;PageContainer.ZIndex=5;PageContainer.Parent=Main
-- ══════════════════════════════════════════════════════════════
--  HELPERS DE UI
-- ══════════════════════════════════════════════════════════════
local function newPage()
    local p=Instance.new("Frame")
    p.Size=UDim2.new(1,0,1,0)
    p.BackgroundTransparency=1
    p.BorderSizePixel=0;p.ZIndex=6;p.Visible=false;p.Parent=PageContainer
    return p
end

local function group(parent,title,x,y,w,h)
    local g=Instance.new("Frame")
    g.Size=UDim2.fromOffset(w,h)
    g.Position=UDim2.fromOffset(x,y)
    g.BackgroundColor3=Color3.fromRGB(14,22,44)
    g.BackgroundTransparency=0.3
    g.BorderSizePixel=0;g.ClipsDescendants=false;g.ZIndex=7;g.Parent=parent
    Instance.new("UICorner",g).CornerRadius=UDim.new(0,8)
    local gs=Instance.new("UIStroke");gs.Color=Color3.fromRGB(26,95,214);gs.Thickness=0.5;gs.Parent=g
    -- titulo
    local hdr=Instance.new("Frame")
    hdr.Size=UDim2.new(1,0,0,26)
    hdr.BackgroundColor3=Color3.fromRGB(59,138,255)
    hdr.BackgroundTransparency=0.88
    hdr.BorderSizePixel=0;hdr.ZIndex=8;hdr.Parent=g
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,8)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-12,1,0)
    lbl.Position=UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency=1
    lbl.Text=title;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=10
    lbl.TextColor3=Color3.fromRGB(100,160,255)
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=9;lbl.Parent=hdr
    return g
end

local function toggle(parent,text,default,y,callback)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-16,0,28)
    row.Position=UDim2.fromOffset(8,y)
    row.BackgroundColor3=Color3.fromRGB(18,26,56)
    row.BackgroundTransparency=0.5
    row.BorderSizePixel=0;row.ZIndex=8;row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-50,1,0)
    lbl.Position=UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency=1
    lbl.Text=text;lbl.Font=Enum.Font.Gotham;lbl.TextSize=12
    lbl.TextColor3=Color3.fromRGB(200,220,255)
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=9;lbl.Parent=row
    -- toggle pill
    local pill=Instance.new("Frame")
    pill.Size=UDim2.fromOffset(32,16)
    pill.AnchorPoint=Vector2.new(1,.5)
    pill.Position=UDim2.new(1,-8,.5,0)
    pill.BackgroundColor3=default and Color3.fromRGB(59,138,255) or Color3.fromRGB(30,45,80)
    pill.BorderSizePixel=0;pill.ZIndex=9;pill.Parent=row
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.fromOffset(12,12)
    knob.AnchorPoint=Vector2.new(.5,.5)
    knob.Position=default and UDim2.new(1,-8,.5,0) or UDim2.new(0,8,.5,0)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0;knob.ZIndex=10;knob.Parent=pill
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=default
    row.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            state=not state
            TweenService:Create(pill,TweenInfo.new(.2),{BackgroundColor3=state and Color3.fromRGB(59,138,255) or Color3.fromRGB(30,45,80)}):Play()
            TweenService:Create(knob,TweenInfo.new(.2),{Position=state and UDim2.new(1,-8,.5,0) or UDim2.new(0,8,.5,0)}):Play()
            if callback then callback(state) end
        end
    end)
    return row
end
local function slider(parent,text,default,min,max,y,callback)
    local container=Instance.new("Frame")
    container.Size=UDim2.new(1,-16,0,42)
    container.Position=UDim2.fromOffset(8,y)
    container.BackgroundColor3=Color3.fromRGB(18,26,56)
    container.BackgroundTransparency=0.5
    container.BorderSizePixel=0;container.ZIndex=8;container.Parent=parent
    Instance.new("UICorner",container).CornerRadius=UDim.new(0,6)
    local head=Instance.new("Frame")
    head.Size=UDim2.new(1,0,0,20)
    head.BackgroundTransparency=1;head.ZIndex=9;head.Parent=container
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(.7,0,1,0)
    lbl.Position=UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency=1;lbl.Text=text
    lbl.Font=Enum.Font.Gotham;lbl.TextSize=12
    lbl.TextColor3=Color3.fromRGB(200,220,255)
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=9;lbl.Parent=head
    local val=Instance.new("TextLabel")
    val.Size=UDim2.new(.3,0,1,0)
    val.AnchorPoint=Vector2.new(1,0);val.Position=UDim2.new(1,-8,0,0)
    val.BackgroundTransparency=1
    val.Text=tostring(default)
    val.Font=Enum.Font.GothamBold;val.TextSize=12
    val.TextColor3=Color3.fromRGB(59,138,255)
    val.TextXAlignment=Enum.TextXAlignment.Right
    val.ZIndex=9;val.Parent=head
    -- track
    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-20,0,4)
    track.Position=UDim2.fromOffset(10,28)
    track.BackgroundColor3=Color3.fromRGB(30,45,80)
    track.BorderSizePixel=0;track.ZIndex=9;track.Parent=container
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local pct=(default-min)/(max-min)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(59,138,255)
    fill.BorderSizePixel=0;fill.ZIndex=10;fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local UIGrad=Instance.new("UIGradient")
    UIGrad.Color=ColorSequence.new(Color3.fromRGB(26,95,214),Color3.fromRGB(100,180,255))
    UIGrad.Parent=fill
    local thumb=Instance.new("Frame")
    thumb.Size=UDim2.fromOffset(12,12)
    thumb.AnchorPoint=Vector2.new(.5,.5)
    thumb.Position=UDim2.new(pct,0,.5,0)
    thumb.BackgroundColor3=Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel=0;thumb.ZIndex=11;thumb.Parent=track
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local ThStroke=Instance.new("UIStroke");ThStroke.Color=Color3.fromRGB(59,138,255);ThStroke.Thickness=1.5;ThStroke.Parent=thumb
    -- drag no slider
    local sliding=false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            sliding=true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            sliding=false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local relX=inp.Position.X-track.AbsolutePosition.X
            local p=math.clamp(relX/track.AbsoluteSize.X,0,1)
            fill.Size=UDim2.new(p,0,1,0)
            thumb.Position=UDim2.new(p,0,.5,0)
            local v=math.round(min+(max-min)*p)
            val.Text=tostring(v)
            if callback then callback(v) end
        end
    end)
    return container
end
-- ══════════════════════════════════════════════════════════════
--  PÁGINA: PRINCIPAL
-- ══════════════════════════════════════════════════════════════
local PrincipalPage=newPage()
TabPages["PRINCIPAL"]=PrincipalPage

local AimGroup=group(PrincipalPage,"AIM SETTINGS",8,8,330,220)
toggle(AimGroup,"Silent Aim",Settings.Enabled,30,function(v) Settings.Enabled=v end)
toggle(AimGroup,"Auto Shoot",false,62,function(v) Settings.AutoShoot=v end)
toggle(AimGroup,"Wall Check",Settings.VisibleCheck,94,function(v) Settings.VisibleCheck=v end)
toggle(AimGroup,"Team Check",Settings.TeamCheck,126,function(v) Settings.TeamCheck=v end)
toggle(AimGroup,"Friend Check",Settings.FriendCheck,158,function(v) Settings.FriendCheck=v end)
toggle(AimGroup,"Force Field Check",Settings.ForceFieldCheck,190,function(v) Settings.ForceFieldCheck=v end)

local SmoothGroup=group(PrincipalPage,"SMOOTHING",8,236,330,140)
slider(SmoothGroup,"Alcance da Mira",Settings.SilentAimRange,30,2000,30,function(v) Settings.SilentAimRange=v end)
slider(SmoothGroup,"Hit Chance",Settings.HitChance,0,100,78,function(v) Settings.HitChance=v end)

local FOVGroup=group(PrincipalPage,"FOV",348,8,336,100)
slider(FOVGroup,"FOV Radius",Settings.FOVRadius,30,500,30,function(v)
    Settings.FOVRadius=v
    -- atualiza o círculo FOV do seu script
    -- FOVCircle.Size = UDim2.fromOffset(v*2,v*2)
end)

local HitboxGroup=group(PrincipalPage,"HITBOX",348,116,336,120)
toggle(HitboxGroup,"Hitbox Expander",false,30,function(v) Settings.HitboxExpanderEnabled=v end)
toggle(HitboxGroup,"Team Check",true,62,function(v) Settings.HitboxTeamCheck=v end)
slider(HitboxGroup,"Tamanho",1,1,15,94,function(v) Settings.HitboxSize=v end)
-- ══════════════════════════════════════════════════════════════
--  PÁGINA: ARMAS (placeholder)
-- ══════════════════════════════════════════════════════════════
local ArmasPage=newPage()
TabPages["ARMAS"]=ArmasPage
local WGroup=group(ArmasPage,"WEAPON MOD",8,8,330,180)
toggle(WGroup,"Modificar Armas",false,30,function(v) end)
toggle(WGroup,"Auto Fire",false,62,function(v) end)
toggle(WGroup,"Tiro Rápido",false,94,function(v) end)
toggle(WGroup,"Recarga Automática",false,126,function(v) end)
local WGroup2=group(ArmasPage,"GUN SWITCHER",8,196,330,100)
toggle(WGroup2,"Fast Switch",false,30,function(v) end)
toggle(WGroup2,"Cycle All Weapons",false,62,function(v) end)

-- ══════════════════════════════════════════════════════════════
--  PÁGINA: VISUAL (placeholder)
-- ══════════════════════════════════════════════════════════════
local VisualPage=newPage()
TabPages["VISUAL"]=VisualPage
local ESPGroup=group(VisualPage,"ESP",8,8,330,120)
toggle(ESPGroup,"Highlight ESP",false,30,function(v) end)
toggle(ESPGroup,"Name ESP",true,62,function(v) end)
toggle(ESPGroup,"Tracer ESP",false,94,function(v) end)

-- ══════════════════════════════════════════════════════════════
--  PÁGINA: CONFIG (placeholder)
-- ══════════════════════════════════════════════════════════════
local ConfigPage=newPage()
TabPages["CONFIG"]=ConfigPage
local MenuGroup2=group(ConfigPage,"MENU",8,8,330,100)
toggle(MenuGroup2,"Custom Cursor",true,30,function(v) end)
toggle(MenuGroup2,"Always On Top",false,62,function(v) end)
-- ══════════════════════════════════════════════════════════════
--  LÓGICA DAS TABS
-- ══════════════════════════════════════════════════════════════
local function switchTab(name)
    for n,data in pairs(TabBtns) do
        local on=(n==name)
        TweenService:Create(data.btn,TweenInfo.new(.15),{TextColor3=on and Color3.fromRGB(59,138,255) or Color3.fromRGB(100,150,220)}):Play()
        TweenService:Create(data.ind,TweenInfo.new(.15),{BackgroundTransparency=on and 0 or 1}):Play()
    end
    for n,page in pairs(TabPages) do page.Visible=(n==name) end
    ActiveTab=name
end

for _,n in ipairs(tabNames) do
    if TabBtns[n] then
        TabBtns[n].btn.MouseButton1Click:Connect(function() switchTab(n) end)
    end
end
switchTab("PRINCIPAL")

-- ══════════════════════════════════════════════════════════════
--  FOOTER
-- ══════════════════════════════════════════════════════════════
local Footer=Instance.new("Frame")
Footer.Size=UDim2.new(1,0,0,22)
Footer.AnchorPoint=Vector2.new(0,1)
Footer.Position=UDim2.new(0,0,1,0)
Footer.BackgroundColor3=Color3.fromRGB(8,12,22)
Footer.BackgroundTransparency=0.15
Footer.BorderSizePixel=0;Footer.ZIndex=10;Footer.Parent=Main
local FStroke=Instance.new("UIStroke");FStroke.Color=Color3.fromRGB(26,95,214);FStroke.Thickness=0.5;FStroke.Parent=Footer

local FLeft=Instance.new("TextLabel")
FLeft.Size=UDim2.new(.5,0,1,0);FLeft.Position=UDim2.fromOffset(10,0)
FLeft.BackgroundTransparency=1;FLeft.Text="APEX HUB · by Apex"
FLeft.Font=Enum.Font.Gotham;FLeft.TextSize=10
FLeft.TextColor3=Color3.fromRGB(80,120,200)
FLeft.TextXAlignment=Enum.TextXAlignment.Left;FLeft.ZIndex=11;FLeft.Parent=Footer

local FRight=Instance.new("TextLabel")
FRight.Size=UDim2.new(.5,-10,1,0)
FRight.AnchorPoint=Vector2.new(1,0);FRight.Position=UDim2.new(1,-8,0,0)
FRight.BackgroundTransparency=1
FRight.Font=Enum.Font.GothamBold;FRight.TextSize=10
FRight.TextColor3=Color3.fromRGB(59,138,255)
FRight.TextXAlignment=Enum.TextXAlignment.Right;FRight.ZIndex=11;FRight.Parent=Footer

-- status piscando
task.spawn(function()
    while Main.Parent do
        FRight.Text="● SILENT AIM "..(Settings.Enabled and "ON" or "OFF")
        FRight.TextColor3=Settings.Enabled and Color3.fromRGB(59,138,255) or Color3.fromRGB(180,60,60)
        task.wait(.8)
        FRight.TextTransparency=.5; task.wait(.4); FRight.TextTransparency=0
    end
end)

-- ══════════════════════════════════════════════════════════════
--  ANIMAÇÃO DE ENTRADA
-- ══════════════════════════════════════════════════════════════
Main.Size=UDim2.fromOffset(W*.85,H*.85)
Main.BackgroundTransparency=1
TweenService:Create(Main,TweenInfo.new(.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Size=UDim2.fromOffset(W,H),
    BackgroundTransparency=0}):Play()

-- ══════════════════════════════════════════════════════════════
--  KEYBIND PARA ABRIR/FECHAR (RightShift)
-- ══════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        Main.Visible=not Main.Visible
    end
end)

-- ══════════════════════════════════════════════════════════════
--  COLE O SEU SILENT AIM SCRIPT ABAIXO DESTA LINHA
-- ══════════════════════════════════════════════════════════════
