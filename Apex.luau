local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local SCRIPT_VERSION = "1.0.8"

local Window = Library:CreateWindow({
    Title = "Apex Hub",
    Footer = "Jailbreak | " .. SCRIPT_VERSION,
    Icon = 95816097006870,
    ToggleKeybind = Enum.KeyCode.RightControl,
    SidebarCompacted = true,
})

local Tabs = {
    Home     = Window:AddTab("Home", "house"),
    Profile  = Window:AddTab("Profile", "user"),
    Combat   = Window:AddTab("Combat", "hand-fist"),
    Visuals  = Window:AddTab("Visuals", "eye"),
    World    = Window:AddTab("World", "globe"),
    Settings = Window:AddTab("Settings", "settings"),
}


local Profile = Tabs.Home:AddLeftGroupbox("Profile")

Profile:AddImage("Avatar", {
    Image = "rbxthumb://type=Avatar&id=" .. LocalPlayer.UserId .. "&w=420&h=420",
    Height = 220,
})

Profile:AddLabel(LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")")

local Info = Tabs.Home:AddRightGroupbox("Rendex")

Info:AddLabel("Versão: " .. SCRIPT_VERSION)
Info:AddDivider()
Info:AddLabel({
    Text = "Bem-vindo ao Apex Hub! Obrigado por usar o script. Em breve teremos novas funções, então fique ligado nas atualizações.",
    DoesWrap = true,
})


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("Rendex")
SaveManager:SetFolder("Rendex/Jailbreak")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()
