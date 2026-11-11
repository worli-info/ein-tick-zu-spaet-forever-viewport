local ADDON_NAME = ...

local PROFILE_DEFAULTS = {
    enabled = true,
    top = 0,
    bottom = 145,
    left = 0,
    right = 0,
    background = true,
    color = { 0, 0, 0, 1 },
}

local BUILTIN_PROFILES = {
    Aktuell = {
        enabled = false,
        top = 0,
        bottom = 0,
        left = 0,
        right = 0,
        background = false,
        color = { 0, 0, 0, 1 },
    },
    Neu = PROFILE_DEFAULTS,
}

local panels = {}
local optionsFrame
local pendingApply = false

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd9a441Ein Tick zu spät – Forever Viewport:|r " .. message)
end

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function CopyTable(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = CopyTable(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function NormalizeProfile(profile)
    for key, value in pairs(PROFILE_DEFAULTS) do
        if profile[key] == nil then
            profile[key] = type(value) == "table" and CopyTable(value) or value
        end
    end

    for _, edge in ipairs({ "top", "bottom", "left", "right" }) do
        profile[edge] = Clamp(tonumber(profile[edge]) or PROFILE_DEFAULTS[edge], 0, 500)
    end

    if type(profile.color) ~= "table" then
        profile.color = CopyTable(PROFILE_DEFAULTS.color)
    end
    for index = 1, 4 do
        profile.color[index] = Clamp(tonumber(profile.color[index]) or PROFILE_DEFAULTS.color[index], 0, 1)
    end
end

local function InitializeDatabase()
    local oldDatabase = EinTickZuSpaetForeverViewportDB

    if type(oldDatabase) ~= "table" or type(oldDatabase.profiles) ~= "table" then
        local migratedProfile
        if type(oldDatabase) == "table" and oldDatabase.bottom ~= nil then
            migratedProfile = CopyTable(oldDatabase)
        else
            migratedProfile = CopyTable(BUILTIN_PROFILES.Neu)
        end

        EinTickZuSpaetForeverViewportDB = {
            version = 2,
            activeProfile = "Neu",
            profiles = {
                Aktuell = CopyTable(BUILTIN_PROFILES.Aktuell),
                Neu = migratedProfile,
            },
        }
    end

    local database = EinTickZuSpaetForeverViewportDB
    database.version = 2
    database.profiles.Aktuell = database.profiles.Aktuell or CopyTable(BUILTIN_PROFILES.Aktuell)
    database.profiles.Neu = database.profiles.Neu or CopyTable(BUILTIN_PROFILES.Neu)
    database.activeProfile = database.profiles[database.activeProfile] and database.activeProfile or "Neu"

    for _, profile in pairs(database.profiles) do
        NormalizeProfile(profile)
    end
end

local function GetProfile()
    return EinTickZuSpaetForeverViewportDB.profiles[EinTickZuSpaetForeverViewportDB.activeProfile]
end

local function FindProfileName(searchName)
    if not searchName then
        return nil
    end
    local lowered = string.lower(searchName)
    for name in pairs(EinTickZuSpaetForeverViewportDB.profiles) do
        if string.lower(name) == lowered then
            return name
        end
    end
end

local function CreatePanel(name)
    local frame = CreateFrame("Frame", ADDON_NAME .. name, UIParent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetFrameLevel(0)
    frame:EnableMouse(false)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    frame.texture = texture
    frame:Hide()
    return frame
end

local function InitializePanels()
    if panels.top then
        return
    end
    panels.top = CreatePanel("TopPanel")
    panels.bottom = CreatePanel("BottomPanel")
    panels.left = CreatePanel("LeftPanel")
    panels.right = CreatePanel("RightPanel")
end

local function PositionPanel(frame, point1, relativePoint1, x1, y1, point2, relativePoint2, x2, y2)
    frame:ClearAllPoints()
    frame:SetPoint(point1, nil, relativePoint1, x1, y1)
    frame:SetPoint(point2, nil, relativePoint2, x2, y2)
end

local function UpdatePanels()
    InitializePanels()
    local profile = GetProfile()

    if not profile.enabled or not profile.background then
        for _, panel in pairs(panels) do
            panel:Hide()
        end
        return
    end

    PositionPanel(panels.top, "TOPLEFT", "TOPLEFT", 0, 0, "BOTTOMRIGHT", "TOPRIGHT", 0, -profile.top)
    PositionPanel(panels.bottom, "TOPLEFT", "BOTTOMLEFT", 0, profile.bottom, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0)
    PositionPanel(panels.left, "TOPLEFT", "TOPLEFT", 0, -profile.top, "BOTTOMRIGHT", "BOTTOMLEFT", profile.left, profile.bottom)
    PositionPanel(panels.right, "TOPLEFT", "TOPRIGHT", -profile.right, -profile.top, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, profile.bottom)

    for edge, panel in pairs(panels) do
        panel.texture:SetColorTexture(profile.color[1], profile.color[2], profile.color[3], profile.color[4])
        panel:SetShown(profile[edge] > 0)
    end
end

local function ValidateInsets(profile)
    local minimumWorldSize = 100
    local width = UIParent:GetWidth()
    local height = UIParent:GetHeight()

    if profile.left + profile.right > width - minimumWorldSize then
        profile.right = math.max(0, width - minimumWorldSize - profile.left)
    end
    if profile.top + profile.bottom > height - minimumWorldSize then
        profile.bottom = math.max(0, height - minimumWorldSize - profile.top)
    end
end

local function ApplyViewport()
    if InCombatLockdown and InCombatLockdown() then
        pendingApply = true
        Print("Profilwechsel wird nach dem Kampf angewendet.")
        return
    end

    local profile = GetProfile()
    ValidateInsets(profile)

    WorldFrame:ClearAllPoints()
    if profile.enabled then
        WorldFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", profile.left, -profile.top)
        WorldFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", -profile.right, profile.bottom)
    else
        WorldFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, 0)
        WorldFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 0)
    end

    UpdatePanels()
    pendingApply = false
end

local function ActivateProfile(name)
    local resolvedName = FindProfileName(name)
    if not resolvedName then
        Print("Profil '" .. tostring(name) .. "' wurde nicht gefunden.")
        return false
    end

    EinTickZuSpaetForeverViewportDB.activeProfile = resolvedName
    ApplyViewport()
    Print("Profil '" .. resolvedName .. "' aktiviert.")
    if optionsFrame and optionsFrame:IsShown() and optionsFrame.Refresh then
        optionsFrame:Refresh()
    end
    return true
end

local function Status()
    local profile = GetProfile()
    Print(string.format(
        "Profil '%s': Viewport %s – oben %d, unten %d, links %d, rechts %d.",
        EinTickZuSpaetForeverViewportDB.activeProfile,
        profile.enabled and "an" or "aus",
        profile.top,
        profile.bottom,
        profile.left,
        profile.right
    ))
end

local function Help()
    Print("/fvp – Einstellungsfenster öffnen")
    Print("/fvp aktuell | /fvp neu – direkt zwischen den Layouts wechseln")
    Print("/fvp profile list|use|save|delete [Name] – Profile verwalten")
    Print("/fvp bottom|top|left|right <0-500> – aktives Profil ändern")
    Print("/fvp on|off | background on|off | status | reset")
end

local function CreateLabel(parent, text, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(text)
    return label
end

local function CreateEditBox(parent, name, x, y)
    local box = CreateFrame("EditBox", ADDON_NAME .. name, parent, "InputBoxTemplate")
    box:SetSize(70, 24)
    box:SetPoint("TOPLEFT", x, y)
    box:SetAutoFocus(false)
    box:SetNumeric(true)
    box:SetMaxLetters(3)
    box:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    box:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        parent:Refresh()
    end)
    return box
end

local function CreateButton(parent, text, width, x, y, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetPoint("TOPLEFT", x, y)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function InitializeOptions()
    if optionsFrame then
        return
    end

    local frame = CreateFrame("Frame", ADDON_NAME .. "Options", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(430, 350)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("Ein Tick zu spät – Forever Viewport")

    frame.activeLabel = CreateLabel(frame, "", 18, -38)
    CreateLabel(frame, "Schnellwechsel", 18, -68)
    frame.currentButton = CreateButton(frame, "Aktuell", 120, 18, -90, function() ActivateProfile("Aktuell") end)
    frame.newButton = CreateButton(frame, "Neu", 120, 148, -90, function() ActivateProfile("Neu") end)

    CreateLabel(frame, "Ränder des aktiven Profils", 18, -130)
    CreateLabel(frame, "Oben", 18, -158)
    CreateLabel(frame, "Unten", 118, -158)
    CreateLabel(frame, "Links", 218, -158)
    CreateLabel(frame, "Rechts", 318, -158)
    frame.topBox = CreateEditBox(frame, "TopInput", 18, -178)
    frame.bottomBox = CreateEditBox(frame, "BottomInput", 118, -178)
    frame.leftBox = CreateEditBox(frame, "LeftInput", 218, -178)
    frame.rightBox = CreateEditBox(frame, "RightInput", 318, -178)

    frame.enabledCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.enabledCheck:SetPoint("TOPLEFT", 14, -220)
    frame.enabledCheck.Text:SetText("Echten Viewport aktivieren")

    frame.backgroundCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.backgroundCheck:SetPoint("TOPLEFT", 214, -220)
    frame.backgroundCheck.Text:SetText("Schwarzen Hintergrund zeichnen")

    frame.applyButton = CreateButton(frame, "Anwenden", 120, 18, -275, function()
        local profile = GetProfile()
        profile.top = Clamp(tonumber(frame.topBox:GetText()) or profile.top, 0, 500)
        profile.bottom = Clamp(tonumber(frame.bottomBox:GetText()) or profile.bottom, 0, 500)
        profile.left = Clamp(tonumber(frame.leftBox:GetText()) or profile.left, 0, 500)
        profile.right = Clamp(tonumber(frame.rightBox:GetText()) or profile.right, 0, 500)
        profile.enabled = frame.enabledCheck:GetChecked() and true or false
        profile.background = frame.backgroundCheck:GetChecked() and true or false
        ApplyViewport()
        frame:Refresh()
        Print("Profil '" .. EinTickZuSpaetForeverViewportDB.activeProfile .. "' gespeichert und angewendet.")
    end)
    frame.closeButton = CreateButton(frame, "Schließen", 120, 148, -275, function() frame:Hide() end)
    frame.resetButton = CreateButton(frame, "Profil zurücksetzen", 130, 278, -275, function()
        local name = EinTickZuSpaetForeverViewportDB.activeProfile
        EinTickZuSpaetForeverViewportDB.profiles[name] = CopyTable(BUILTIN_PROFILES[name] or PROFILE_DEFAULTS)
        ApplyViewport()
        frame:Refresh()
    end)

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hint:SetPoint("BOTTOMLEFT", 18, 18)
    frame.hint:SetPoint("BOTTOMRIGHT", -18, 18)
    frame.hint:SetJustifyH("LEFT")
    frame.hint:SetText("Aktuell stellt den vollen Spielbereich wieder her. Neu reserviert unten Platz für Chat, Threat und Damage.")

    function frame:Refresh()
        local profile = GetProfile()
        self.activeLabel:SetText("Aktives Profil: |cffffffff" .. EinTickZuSpaetForeverViewportDB.activeProfile .. "|r")
        self.topBox:SetText(tostring(math.floor(profile.top + 0.5)))
        self.bottomBox:SetText(tostring(math.floor(profile.bottom + 0.5)))
        self.leftBox:SetText(tostring(math.floor(profile.left + 0.5)))
        self.rightBox:SetText(tostring(math.floor(profile.right + 0.5)))
        self.enabledCheck:SetChecked(profile.enabled)
        self.backgroundCheck:SetChecked(profile.background)
        self.currentButton:SetEnabled(EinTickZuSpaetForeverViewportDB.activeProfile ~= "Aktuell")
        self.newButton:SetEnabled(EinTickZuSpaetForeverViewportDB.activeProfile ~= "Neu")
    end

    frame:SetScript("OnShow", function(self) self:Refresh() end)
    optionsFrame = frame
end

local function OpenOptions()
    InitializeOptions()
    optionsFrame:Show()
end

local function SetInset(edge, value)
    local number = tonumber(value)
    if not number then
        Print("Bitte eine Zahl zwischen 0 und 500 angeben.")
        return
    end
    GetProfile()[edge] = Clamp(math.floor(number + 0.5), 0, 500)
    ApplyViewport()
    Status()
end

local function HandleProfileCommand(arguments)
    local action = arguments[2] and string.lower(arguments[2])
    if action == "list" or not action then
        local names = {}
        for name in pairs(EinTickZuSpaetForeverViewportDB.profiles) do
            names[#names + 1] = name
        end
        table.sort(names)
        Print("Profile: " .. table.concat(names, ", "))
    elseif action == "use" then
        ActivateProfile(arguments[3])
    elseif action == "save" then
        local name = arguments[3]
        if not name or name == "" then
            Print("Verwendung: /fvp profile save <Name>")
            return
        end
        EinTickZuSpaetForeverViewportDB.profiles[name] = CopyTable(GetProfile())
        EinTickZuSpaetForeverViewportDB.activeProfile = name
        Print("Profil '" .. name .. "' gespeichert.")
    elseif action == "delete" then
        local name = FindProfileName(arguments[3])
        if name == "Aktuell" or name == "Neu" then
            Print("Die eingebauten Profile Aktuell und Neu können nicht gelöscht werden.")
        elseif not name then
            Print("Profil wurde nicht gefunden.")
        else
            EinTickZuSpaetForeverViewportDB.profiles[name] = nil
            if EinTickZuSpaetForeverViewportDB.activeProfile == name then
                ActivateProfile("Neu")
            end
            Print("Profil '" .. name .. "' gelöscht.")
        end
    else
        Help()
    end
end

local function HandleSlashCommand(input)
    local arguments = {}
    for word in string.gmatch(input or "", "%S+") do
        arguments[#arguments + 1] = word
    end

    if #arguments == 0 then
        OpenOptions()
        return
    end

    local command = string.lower(arguments[1])
    if command == "aktuell" or command == "neu" then
        ActivateProfile(command)
    elseif command == "profile" or command == "profil" then
        HandleProfileCommand(arguments)
    elseif command == "bottom" or command == "top" or command == "left" or command == "right" then
        SetInset(command, arguments[2])
    elseif tonumber(command) then
        SetInset("bottom", command)
    elseif command == "on" or command == "off" then
        GetProfile().enabled = command == "on"
        ApplyViewport()
        Status()
    elseif command == "background" or command == "bg" then
        if arguments[2] ~= "on" and arguments[2] ~= "off" then
            Print("Verwendung: /fvp background on|off")
            return
        end
        GetProfile().background = arguments[2] == "on"
        UpdatePanels()
    elseif command == "status" then
        Status()
    elseif command == "reset" then
        local activeName = EinTickZuSpaetForeverViewportDB.activeProfile
        EinTickZuSpaetForeverViewportDB.profiles[activeName] = CopyTable(BUILTIN_PROFILES[activeName] or PROFILE_DEFAULTS)
        ApplyViewport()
        Status()
    elseif command == "reload" or command == "apply" then
        ReloadUI()
    elseif command == "help" or command == "hilfe" then
        Help()
    else
        Help()
    end
end

SLASH_EINTICKZUSPAETFOREVERVIEWPORT1 = "/fvp"
SLASH_EINTICKZUSPAETFOREVERVIEWPORT2 = "/viewport"
SlashCmdList.EINTICKZUSPAETFOREVERVIEWPORT = HandleSlashCommand

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("CINEMATIC_STOP")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:RegisterEvent("UI_SCALE_CHANGED")

events:SetScript("OnEvent", function(_, event, argument)
    if event == "ADDON_LOADED" then
        if argument ~= ADDON_NAME then
            return
        end
        InitializeDatabase()
        ApplyViewport()
    elseif event == "PLAYER_REGEN_ENABLED" then
        if pendingApply then
            ApplyViewport()
        end
    else
        ApplyViewport()
    end
end)
