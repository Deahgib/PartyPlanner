-- Create addon interface options tab for PartyPlanner settings
if not LibStub then error("PartyPlanner requires LibStub.") end

local LibDBIcon = LibStub("LibDBIcon-1.0")
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("PartyPlanner", {
    type = "launcher",
    icon = "Interface\\Icons\\Spell_Holy_PrayerofSpirit",
    OnClick = function(self, button)
        PartyPlanner.UI:ToggleUI()
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("Party Planner")
    end,
})

local LibSFDropDown = LibStub("LibSFDropDown-1.5")

function PartyPlanner:Reload()
    SetPortraitTexture(PartyPlanner.UI.characterPortrait.texture, "player");
    PartyPlanner.UI:UpdateChannelOptions()
end

function PartyPlanner.UI:BuildAddonSettings()
    local panel = CreateFrame("Frame")
    panel.name = "PartyPlanner"               -- see panel fields
    InterfaceOptions_AddCategory(panel)  -- see InterfaceOptions API

    -- add widgets to the panel as desired
    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP")
    title:SetText("PartyPlanner")

    local subtitle = panel:CreateFontString("ARTWORK", nil, "GameFontHighlightSmall")
    subtitle:SetHeight(40)
    subtitle:SetPoint("TOPLEFT", 16, -32)
    subtitle:SetPoint("RIGHT", panel, -32, 0)
    subtitle:SetNonSpaceWrap(true)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetJustifyV("TOP")
    subtitle:SetText("PartyPlanner is a tool to help you post messages to find people for dungeons and raids.")

    local info = panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
    info:SetHeight(40)
    info:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    info:SetPoint("RIGHT", panel, -32, 0)
    info:SetNonSpaceWrap(true)
    info:SetJustifyH("LEFT")
    info:SetJustifyV("TOP")
    info:SetText("You can always use /pp or /partyplanner to toggle the Party Planner main window.")

    local showMinimapButton = CreateFrame("CheckButton", "PartyPlannerShowMinimapButton", panel, "InterfaceOptionsCheckButtonTemplate")
    showMinimapButton:SetPoint("TOPLEFT", showSpellbookButton, "BOTTOMLEFT", 0, -8)
    showMinimapButton.text = showMinimapButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    showMinimapButton.text:SetPoint("LEFT", showMinimapButton, "RIGHT", 0, 3)
    showMinimapButton.text:SetText("Show PartyPlanner button on minimap")
    showMinimapButton.tooltipText = "Show PartyPlanner button on minimap"
    showMinimapButton:SetScript("OnClick", function(self)
        PartyPlannerSettings.miniMapIcon.hide = not self:GetChecked()
        LibDBIcon:Refresh("PartyPlanner", PartyPlannerSettings.miniMapIcon)
        -- PartyPlanner.MM:ToggleMinimapButton()
    end)
    showMinimapButton:SetChecked(not PartyPlannerSettings.miniMapIcon.hide)

end

function PartyPlanner.UI:BuildShowButtons()
    -- Minimap icon
    LibDBIcon:Register("PartyPlanner", LDB, PartyPlannerSettings.miniMapIcon)
end


function PartyPlanner.UI:BuildFrameDecorations()
    PartyPlanner.UI.characterPortrait = CreateFrame("FRAME", "partyPlanner-character-portrait", PartyPlanner.UI)
    PartyPlanner.UI.characterPortrait:SetSize(64, 64)
    PartyPlanner.UI.characterPortrait:SetPoint("CENTER", PartyPlanner.UI, "TOPLEFT", 25, -21)
    PartyPlanner.UI.characterPortrait.texture = PartyPlanner.UI.characterPortrait:CreateTexture(nil,'ARTWORK')
    PartyPlanner.UI.characterPortrait.texture:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
    PartyPlanner.UI.characterPortrait.texture:SetAllPoints()

    PartyPlanner.UI.characterPortrait.border = CreateFrame("FRAME", "partyPlanner-character-portrait-border", PartyPlanner.UI.characterPortrait)
    PartyPlanner.UI.characterPortrait.border:SetSize(63*1.28, 63*1.28)
    PartyPlanner.UI.characterPortrait.border:SetPoint("TOPLEFT", PartyPlanner.UI.characterPortrait, "TOPLEFT", -7.5, 1)
    PartyPlanner.UI.characterPortrait.border.texture = PartyPlanner.UI.characterPortrait.border:CreateTexture(nil,'ARTWORK')
    PartyPlanner.UI.characterPortrait.border.texture:SetTexture("Interface\\FrameGeneral\\UI-Frame")
    PartyPlanner.UI.characterPortrait.border.texture:SetAllPoints()
    PartyPlanner.UI.characterPortrait.border.texture:SetTexCoord(0, 0.625, 0, 0.625)   

    PartyPlanner.UI.title = PartyPlanner.UI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    PartyPlanner.UI.title:SetPoint("LEFT", PartyPlanner.UI.TitleBg, "LEFT", 60, 0)
    PartyPlanner.UI.title:SetText("Party Planner")
    PartyPlanner.UI.title:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")

    -- PartyPlanner.UI.topBanner = PartyPlanner.UI:CreateTexture(nil,'ARTWORK')
    -- PartyPlanner.UI.topBanner:SetHorizTile(true)
    -- PartyPlanner.UI.topBanner:SetTexture("Interface\\COMMON\\UI-Goldborder-_tile", "REPEAT", "CLAMP", "LINEAR")
    -- PartyPlanner.UI.topBanner:SetSize(855, 64)
    -- PartyPlanner.UI.topBanner:SetPoint("TOP", PartyPlanner.UI, "TOP", -1, -23)
end

function PartyPlanner.UI:CreateTabManager()
    return {
        infoTabButtons={},
        infoTabs={},
        selectedTab="default",
        Select = function (self, tabName)
            if self.selectedTab == tabName then
                return
            end
            -- print("Selecting tab "..tabName)
            for k, v in pairs(self.infoTabs) do
                if k == tabName then
                    v:Show()
                    if self.infoTabButtons[k] ~= nil then
                        self.infoTabButtons[k]:SetSelected(true)
                    end

                else
                    v:Hide()
                    if self.infoTabButtons[k] ~= nil then
                        self.infoTabButtons[k]:SetSelected(false)
                    end
                end
            end
            self.selectedTab = tabName
        end,
        CreateTabButton = function(self, tabName, parent, tabSelectedText, tabDeselectedText)
            local tabButton = CreateFrame("BUTTON", "partyPlanner-tab-button-"..#self.infoTabButtons+1, parent, "UIPanelButtonTemplate")
            tabButton:SetSize(120, 20)
            tabButton.tabName = tabName
            tabButton.selected = false
            tabButton:SetText(tabDeselectedText)
            tabButton.highlightTexture = tabButton:CreateTexture(nil,'ARTWORK')
            tabButton.highlightTexture:SetTexture("Interface\\UNITPOWERBARALT\\MetalBronze_Horizontal_Frame")
            tabButton.highlightTexture:SetSize(154, 35)
            tabButton.highlightTexture:SetPoint("CENTER", 0, 0)
            tabButton.highlightTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0)
            tabButton.highlightTexture:Hide()
            tabButton:SetScript("OnClick", function()
                if tabButton.selected then
                    self:Select("default")
                    return
                end
                self:Select(tabButton.tabName)
            end)
            tabButton.SetSelected = function(self, selected)
                if selected then
                    self.selected = true
                    self:SetText(tabDeselectedText)
                    self.highlightTexture:Show()
                else
                    self.selected = false
                    self:SetText(tabSelectedText)
                    self.highlightTexture:Hide()
                end
            end
            return tabButton
        end,
        Register = function(self, tabName, tabButton, tabFrame)
            self.infoTabButtons[tabName] = tabButton
            self.infoTabs[tabName] = tabFrame
        end
    }
end


function PartyPlanner.UI:CreateEditBox(frame)
    -- local scroll  = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
    -- scroll:SetSize(frame:GetWidth() - 20, frame:GetHeight() - 25)
    -- scroll:SetPoint("TOPLEFT", frame, 12, -5)
    -- scroll:SetPoint("BOTTOMRIGHT", frame, -10, 5)

    local eb = CreateFrame('EditBox', nil, frame)
    -- scroll:SetScrollChild(eb)
    -- eb:SetSize(frame:GetWidth() - 25, frame:GetHeight())
    eb:SetPoint("TOPLEFT", frame, 15, 0)
    eb:SetPoint("BOTTOMRIGHT", frame, -15, 0)
    eb:EnableMouse(true)
    eb:SetAutoFocus(false)
    eb:SetMultiLine(false)
    eb:SetFontObject(GameTooltipText)
    eb:SetMaxLetters(999999)

    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return eb
end

function PartyPlanner.UI:CreateChannelOption(frame, id, name, disabled)
    local channelOption = CreateFrame("FRAME", "partyPlanner-channel-option-"..id, frame, "BackdropTemplate")
    channelOption:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", 
        tile = true, 
        tileSize = 24, 
        edgeSize = 8, 
        insets = { 
            left = 2, 
            right = 3, 
            top = 5, 
            bottom = 5 
        } 
    });
    channelOption:SetBackdropColor(1.0, 1.0, 1.0, 1.0);
    channelOption:SetSize(frame:GetWidth(), 28)
    channelOption:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -70)
    channelOption.id = id
    channelOption.name = name
    channelOption.disabled = disabled
    channelOption.text = channelOption:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    channelOption.text:SetPoint("LEFT", channelOption, "LEFT", 7, 0)
    channelOption.text:SetText(name)
    channelOption.checkbox = CreateFrame("CheckButton", "partyPlanner-channel-option-checkbox-"..id, channelOption, "InterfaceOptionsCheckButtonTemplate")
    channelOption.checkbox:SetPoint("RIGHT", channelOption, "RIGHT", 0, 0)
    channelOption.checkbox:SetScript("OnClick", function(self)
        -- print("Clicked", self:GetChecked(), channelOption.id, channelOption.name)

        PartyPlannerSettings.channelSettings[channelOption.name].disabled = not self:GetChecked()
    end)
    channelOption.checkbox:SetChecked(not disabled)

    function channelOption:UpdateOption(id, name, disabled)
        channelOption.id = id
        channelOption.name = name
        channelOption.disabled = disabled
        channelOption.text:SetText(id..". "..name)
        channelOption.checkbox:SetChecked(not disabled)
        -- print("Updating", channelOption.id, channelOption.name, channelOption.disabled)
    end
    -- channelOption:Hide()
    return channelOption

end

function PartyPlanner.UI:CreateChannelOptions()
    
    local channelOptionHeight = 28
    local channelOptionPadding = 6

    PartyPlanner.UI.channelOptions = {}

    local channelOptionsContainer = CreateFrame("FRAME", "partyPlanner-inputFieldContainer", PartyPlanner.UI, "BackdropTemplate")
    channelOptionsContainer:SetSize(315, 135)
    channelOptionsContainer:SetPoint("TOPLEFT", PartyPlanner.UI, "TOPLEFT", 10, -65)  -- Adjust position as needed
    channelOptionsContainer:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", 
        tile = true, 
        tileSize = 24, 
        edgeSize = 8, 
        insets = { 
            left = 2, 
            right = 3, 
            top = 5, 
            bottom = 5 
        } 
    });
    channelOptionsContainer:SetBackdropColor(1.0, 1.0, 1.0, 1.0);


    local channelOptionsSF = CreateFrame("ScrollFrame", nil, channelOptionsContainer, "UIPanelScrollFrameTemplate")
    channelOptionsSF:SetPoint("TOPLEFT", 3, -7)
    channelOptionsSF:SetPoint("BOTTOMRIGHT", -27, 6)

    local scrollChild = CreateFrame("Frame")
    channelOptionsSF:SetScrollChild(scrollChild)
    scrollChild:SetWidth(channelOptionsSF:GetWidth()-5)
    scrollChild:SetHeight(1) 

    -- 

    for i = 1, PartyPlanner.DATA.MAX_CHANNELS, 1 do
        -- local id, name, disabled = channels[i], channels[i+1], channels[i+2]
        local channelOption = PartyPlanner.UI:CreateChannelOption(scrollChild, i, "Temp Channel Name "..i, true)
        channelOption:SetPoint("TOPLEFT", channelOptionPadding, -((i-1)*(channelOptionHeight-channelOptionPadding)))
        PartyPlanner.UI.channelOptions[i] = channelOption
    end

    

    return channelOptionsContainer
end


function PartyPlanner.UI:UpdateChannelOptions()
    if not PartyPlanner.UI:IsShown() then
        return
    end
    local channels = {GetChannelList()}
    local joinedLookingForGroup = false
    local joinedLFG = false
    for i = 1, #channels, 3 do
        local name = channels[i+1]
        if string.lower(name) == "lookingforgroup" then
            joinedLookingForGroup = true
        elseif string.lower(name) == "lfg" then
            joinedLFG = true
        end
    end
    local joinedAllChannels = joinedLookingForGroup and joinedLFG

    if joinedAllChannels then
        PartyPlanner.UI.joinLFGButton:Hide()
    else
        PartyPlanner.UI.joinLFGButton:Show()
    end

    -- for i = 1, #channels, 3 do
    --     local id, name, disabled = channels[i], channels[i+1], channels[i+2]
    --     if not disabled then
    --         print(id, name)
    --     end
    -- end

    local validChannels = {}

    for i = 1, #channels, 3 do
        local id, name, disabled = channels[i], channels[i+1], channels[i+2]
        local isValid = true
        for j = 1, #PartyPlanner.DATA.forbidenChannels, 1 do
            if string.lower(PartyPlanner.DATA.forbidenChannels[j]) == string.lower(name) then
                isValid = false
            end
        end

        if isValid then
            validChannels[#validChannels+1] = id
            validChannels[#validChannels+1] = name
            validChannels[#validChannels+1] = disabled

            -- print(id, name, disabled)
        end
    end



    local totChannels = #validChannels/3

    for i = 1, PartyPlanner.DATA.MAX_CHANNELS, 1 do
        local channelOption = PartyPlanner.UI.channelOptions[i]

        if i <= totChannels then
            local id, name = validChannels[i*3-2], validChannels[i*3-1]

            local disabled = true
            if PartyPlannerSettings.channelSettings[name] ~= nil then
                disabled = PartyPlannerSettings.channelSettings[name].disabled
            else
                PartyPlannerSettings.channelSettings[name] = {
                    id = id,
                    name = name,
                    disabled = true
                }
            end

            channelOption:UpdateOption(id, name, disabled)
            channelOption:Show()
        else
            channelOption:Hide()
        end
    end
    
end

function PartyPlanner.UI:GetRolesText()
    local rolesText = ""
    local chosenRoles = {}
    for i = 1, #PartyPlanner.UI.roleCheckboxes do
        local container = PartyPlanner.UI.roleCheckboxes[i]
        if container.checkbox:GetChecked() then
            -- print(container.role)
            chosenRoles[#chosenRoles+1] = container.role
        end
    end

    for i = 1, #chosenRoles do
        if i == 1 then
            rolesText = chosenRoles[i]
        elseif i == #chosenRoles then
            rolesText = rolesText.." and "..chosenRoles[i]
        else
            rolesText = rolesText..", "..chosenRoles[i]
        end
    end

    return rolesText
end

function PartyPlanner.UI:UpdatePreviewText()
    local message = PartyPlanner.UI.editBox:GetText()
    local parsedMessage = message

    if PartyPlanner.DATA.selectedInstance == nil then
        parsedMessage = parsedMessage:gsub("%%i", "")
    else
        if PartyPlannerSettings.useAbreviation then
            parsedMessage = parsedMessage:gsub("%%i", PartyPlanner.DATA.selectedInstance.abr)
        else
            parsedMessage = parsedMessage:gsub("%%i", PartyPlanner.DATA.selectedInstance.name)
        end
    end

    local rolesText = PartyPlanner.UI:GetRolesText()
    parsedMessage = parsedMessage:gsub("%%r", rolesText)

    PartyPlanner.DATA.currentMessage = parsedMessage

    PartyPlanner.UI.previewTextDynamic:SetText(parsedMessage)

    return true
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- UI Build

function PartyPlanner.UI:Build()
    PartyPlanner.UI:SetFrameStrata("DIALOG")
    PartyPlanner.UI:SetSize(338, 422)
    PartyPlanner.UI:SetPoint("CENTER") -- Doesn't need to be ("CENTER", UIParent, "CENTER")
    PartyPlanner.UI:SetMovable(true)
    PartyPlanner.UI:EnableMouse(true)
    PartyPlanner.UI:RegisterForDrag("LeftButton")
    function PartyPlanner.UI:ToggleUI()
        if PartyPlanner.UI:IsShown() then
            PartyPlanner.UI:Hide()
        else
            PartyPlanner.UI:Show()
        end
    end
    PartyPlanner.UI:Hide()
    PartyPlanner.UI:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    PartyPlanner.UI:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)


    PartyPlanner.UI:SetScript("OnShow", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN, "Master");
        PartyPlanner:Reload()
    end)
    PartyPlanner.UI:SetScript("OnHide", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE, "Master");
    end)

    -- Setup the show/hide button
    PartyPlanner.UI:BuildShowButtons()

    -- Pretty up the frame
    PartyPlanner.UI:BuildFrameDecorations()


    

    local ddMenu = LibSFDropDown:CreateButton(PartyPlanner.UI, 150)
    ddMenu:SetPoint("TOPRIGHT", PartyPlanner.UI, "TOPRIGHT", -10, -35)
    ddMenu:ddSetSelectedValue(1)

    local function dudFunction(menuButton) end

    local function selectFunction(menuButton)
        ddMenu:ddSetSelectedValue(menuButton.value)
        local inst = PartyPlanner.DATA.INSTANCES[menuButton.value]
        PartyPlanner.DATA.selectedInstance = inst
        PartyPlanner.UI:UpdatePreviewText()
        -- some code
        -- print("Selected "..inst.name.." ["..inst.abr.."]".." (lvl "..inst.minLevel.."-"..inst.maxLevel..") "..inst.groupSize.." man "..inst.type)
    end

    ddMenu:ddInitialize(function(self, level)
        local info = {}
      
        for i = 1, #PartyPlanner.DATA.INSTANCES do
            local inst = PartyPlanner.DATA.INSTANCES[i]

            if inst.type == "Fill" then
                info.text = "___"
                info.value = i
                info.func = dudFunction
                self:ddAddButton(info, level)
            elseif inst.type == "Dungeon" then
                info.text = inst.name.." ("..inst.minLevel.."-"..inst.maxLevel..")"
                info.value = i
                info.func = selectFunction
                self:ddAddButton(info, level)
            else
                info.text = inst.name
                info.value = i
                info.func = selectFunction
                self:ddAddButton(info, level)
            end
        end
    end)

    local dungeonText = PartyPlanner.UI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dungeonText:SetPoint("RIGHT", ddMenu, "LEFT", -10, 0)
    dungeonText:SetText("Select instance: ")


    local rolesOptionsContainer = CreateFrame("FRAME", "partyPlanner-inputFieldContainer", PartyPlanner.UI, "BackdropTemplate")
    rolesOptionsContainer:SetSize(315, 40)
    rolesOptionsContainer:SetPoint("TOPLEFT", PartyPlanner.UI, "TOPLEFT", 10, -80)  -- Adjust position as needed
    rolesOptionsContainer:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", 
        tile = true, 
        tileSize = 24, 
        edgeSize = 8, 
        insets = { 
            left = 2, 
            right = 3, 
            top = 5, 
            bottom = 5 
        } 
    });
    rolesOptionsContainer:SetBackdropColor(1.0, 1.0, 1.0, 1.0);

    local roleText = rolesOptionsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    roleText:SetPoint("TOPLEFT", rolesOptionsContainer, "TOPLEFT", 5, 12)
    roleText:SetText("Select required roles: ")

    -- Check boxes for the 3 roles
    local roleCheckboxes = {}
    local roles = {"Tank", "Healer", "DPS"}

    for i = 1, #roles do

        local roleContainer = CreateFrame("FRAME", "partyPlanner-role-container-"..roles[i], rolesOptionsContainer, "BackdropTemplate")
        roleContainer:SetSize(80, 28)
        roleContainer:SetPoint("LEFT", rolesOptionsContainer, "LEFT", 5+(i-1)*125, 0)

        roleContainer.checkbox = CreateFrame("CheckButton", nil, roleContainer, "InterfaceOptionsCheckButtonTemplate")        
        roleContainer.checkbox:SetPoint("LEFT", roleContainer, "LEFT", 0, 0)
        roleContainer.checkbox:SetChecked(true)
        -- local left, bottom, width, height = roleContainer.checkbox:GetBoundsRect()
        -- local hitLeft, hitBottom, hitWidth, hitHeight = roleContainer.checkbox:GetHitRectInsets()
        -- local rectLeft, rectBottom, rectWidth, rectHeight = roleContainer.checkbox:GetRect()
        roleContainer.checkbox:SetScript("OnClick", function(self)
            PartyPlanner.UI:UpdatePreviewText()
        end)
        
        roleContainer.text = roleContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        roleContainer.text:SetPoint("LEFT", roleContainer.checkbox, "RIGHT", 0, 0)
        roleContainer.text:SetText(roles[i])

        roleContainer.role = roles[i]

        roleCheckboxes[i] = roleContainer
    end

    PartyPlanner.UI.roleCheckboxes = roleCheckboxes

    local channelOptionsContainer = PartyPlanner.UI:CreateChannelOptions()
    channelOptionsContainer:SetPoint("TOPLEFT", rolesOptionsContainer, "BOTTOMLEFT", 0, -15)

    
    local channelText = channelOptionsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelText:SetPoint("TOPLEFT", channelOptionsContainer, "TOPLEFT", 5, 12)
    channelText:SetText("Select channels to post to: ")

    local joinLFGButton = CreateFrame("BUTTON", "partyPlanner-SEND", PartyPlanner.UI, "UIPanelButtonTemplate")
    joinLFGButton:SetSize(70, 20)
    joinLFGButton:SetPoint("BOTTOMRIGHT", channelOptionsContainer, "TOPRIGHT", 0, -5)
    joinLFGButton:SetText("Join LFG")
    joinLFGButton:SetScript("OnClick", function()
        JoinChannelByName("LookingForGroup")
        JoinChannelByName("lfg")
    end)
    PartyPlanner.UI.joinLFGButton = joinLFGButton



    local inputFieldContainer = CreateFrame("FRAME", "partyPlanner-inputFieldContainer", PartyPlanner.UI, "BackdropTemplate")
    inputFieldContainer:SetSize(315, 32)
    inputFieldContainer:SetPoint("TOPLEFT", channelOptionsContainer, "BOTTOMLEFT", 0, -20)  -- Adjust position as needed
    inputFieldContainer:SetBackdrop({
        -- bgFile = "Interface\\AdventureMap\\AdventureMapParchmentTile", 
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 24,
        edgeSize = 24,
        insets = {
            left = 5,
            right = 5,
            top = 2,
            bottom = 2
        }
    })
    inputFieldContainer:SetBackdropColor(1.0, 1.0, 1.0, 1.0);
    
    local editBoxText = inputFieldContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxText:SetPoint("TOPLEFT", inputFieldContainer, "TOPLEFT", 5, 17)
    editBoxText:SetText("Customise message: ")

    local resetDefaultText = CreateFrame("BUTTON", "partyPlanner-reset-default", PartyPlanner.UI)
    resetDefaultText:SetSize(12, 12)
    resetDefaultText:SetPoint("LEFT", editBoxText, "RIGHT", 5, 0)
    resetDefaultText:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
    
    resetDefaultText:SetScript("OnClick", function ()
        PartyPlannerSettings.message = PartyPlannerSettings.defaultMessage
        PartyPlanner.UI.editBox:SetText(PartyPlannerSettings.message)
        PartyPlanner.UI.editBox:ClearFocus()
        PartyPlanner.UI:UpdatePreviewText()
    end)

    resetDefaultText:SetScript("OnEnter", function()
        GameTooltip:SetOwner(resetDefaultText, "ANCHOR_LEFT", 0, 0)
        GameTooltip:AddLine("Reset to default text")
        GameTooltip:Show()
    end)
    resetDefaultText:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local editBoxInfo = CreateFrame("BUTTON", "partyPlanner-reset-default", PartyPlanner.UI)
    editBoxInfo:SetSize(16, 16)
    editBoxInfo:SetPoint("LEFT", resetDefaultText, "RIGHT", 5, 0)
    editBoxInfo:SetNormalTexture("Interface\\Buttons\\AdventureGuideMicrobuttonAlert")

    editBoxInfo:SetScript("OnEnter", function()
        GameTooltip:SetOwner(editBoxInfo, "ANCHOR_LEFT", 0, 0)
        GameTooltip:AddLine("Message formatting rules, ")
        GameTooltip:AddLine("use these to customise your message:")
        GameTooltip:AddLine("%i - Instance name or abbreviation")
        GameTooltip:AddLine("%r - Required roles")
        -- GameTooltip:AddLine("%n - Remaining player count needed")

        GameTooltip:Show()
    end)
    editBoxInfo:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local editBox = PartyPlanner.UI:CreateEditBox(inputFieldContainer)
    editBox:SetText(PartyPlannerSettings.message)
    PartyPlanner.UI.editBox = editBox
    -- When a character changes
    editBox:SetScript("OnTextChanged", function(self)
        local message = PartyPlanner.UI.editBox:GetText()
        PartyPlannerSettings.message = message
        PartyPlanner.UI:UpdatePreviewText()
    end)

    editBox:SetScript("OnEnterPressed", function(self) 
        PartyPlanner.UI.editBox:ClearFocus() 
        local message = PartyPlanner.UI.editBox:GetText()
        PartyPlannerSettings.message = message
        PartyPlanner.UI:UpdatePreviewText()
    end)


    local previewTextContainer = CreateFrame("FRAME", "partyPlanner-preview-text-container", PartyPlanner.UI)
    previewTextContainer:SetSize(315, 32)
    previewTextContainer:SetPoint("TOPLEFT", inputFieldContainer, "BOTTOMLEFT", 0, -30)  -- Adjust position as needed

    local previewTextDynamic = PartyPlanner.UI:CreateEditBox(previewTextContainer)    
    PartyPlanner.UI.previewTextDynamic = previewTextDynamic
    previewTextDynamic:SetMultiLine(true)
    previewTextDynamic:SetScript("OnTextChanged", function(self)
        PartyPlanner.UI.previewTextDynamic:ClearFocus() 
        PartyPlanner.UI:UpdatePreviewText()
    end)
    previewTextDynamic:SetScript("OnEnterPressed", function(self)
        PartyPlanner.UI.previewTextDynamic:ClearFocus() 
        PartyPlanner.UI:UpdatePreviewText()
    end)

    local previewText = previewTextContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewText:SetPoint("TOPLEFT", previewTextContainer, "TOPLEFT", 5, 17)
    previewText:SetText("Preview: ")

    local useAbrevButton = CreateFrame("BUTTON", "partyPlanner-reset-default", PartyPlanner.UI)
    useAbrevButton:SetSize(24, 24)
    useAbrevButton:SetPoint("LEFT", previewText, "RIGHT", 5, 0)
    useAbrevButton.UpdateTexture = function (self)
        if PartyPlannerSettings.useAbreviation then
            self:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up")
        else
            self:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up")
        end
    end
    useAbrevButton:UpdateTexture()
    useAbrevButton:SetScript("OnClick", function ()
        PartyPlannerSettings.useAbreviation = not PartyPlannerSettings.useAbreviation
        useAbrevButton:UpdateTexture()
        PartyPlanner.UI:UpdatePreviewText()
    end)

    useAbrevButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(useAbrevButton, "ANCHOR_LEFT", 0, 0)
        GameTooltip:AddLine("Toggle instance abbreviation or full name")
        GameTooltip:Show()
    end)
    useAbrevButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)


    local button = CreateFrame("BUTTON", "partyPlanner-SEND", PartyPlanner.UI, "UIPanelButtonTemplate")
    button:SetSize(120, 25)
    button:SetPoint("BOTTOMRIGHT", PartyPlanner.UI, "BOTTOMRIGHT", -8, 8)
    button:SetText("Send Message")
    button:SetScript("OnClick", function()
        local message = PartyPlanner.DATA.currentMessage
        -- print("Message to send:", message)
        local channels = {GetChannelList()}
        for i = 1, #channels, 3 do
            local id, name = channels[i], channels[i+1]
            local disabled = true
            if PartyPlannerSettings.channelSettings[name] ~= nil then
                disabled = PartyPlannerSettings.channelSettings[name].disabled
            else
                PartyPlannerSettings.channelSettings[name] = {
                    id = id,
                    name = name,
                    disabled = true
                }
            end

            if not disabled then
                -- print(id..". "..name..": "..message)
                SendChatMessage(message, "CHANNEL", nil, id)
            end
            
        end

        -- SendChatMessage(message, "CHANNEL", nil, 1)
    end)

    PartyPlanner.UI:BuildAddonSettings()
    
    PartyPlanner.UI:UpdatePreviewText()
end