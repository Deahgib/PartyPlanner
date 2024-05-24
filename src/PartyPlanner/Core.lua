
local function LoadSettings()
    if PartyPlannerSettings == nil then 
        PartyPlannerSettings = {}
    end
    if PartyPlannerSettings.miniMapIcon == nil then
        PartyPlannerSettings.miniMapIcon = {
            iconName = "PartyPlanner",
            hide = false,
            minimapPos = 213.7
        }
    end

    if PartyPlannerSettings.defaultMessage == nil then
        PartyPlannerSettings.defaultMessage = "LF%nM %i need %r"
    end

    if PartyPlannerSettings.message == nil then
        PartyPlannerSettings.message = PartyPlannerSettings.defaultMessage
    end

    if PartyPlannerSettings.useRoleAll == nil then
        PartyPlannerSettings.useRoleAll = false
    end

    if PartyPlannerSettings.useGroupSizeMin == nil then
        PartyPlannerSettings.useGroupSizeMin = false
    end

    if PartyPlannerSettings.groupSizeMin == nil then
        PartyPlannerSettings.groupSizeMin = 3
    end

    if PartyPlannerSettings.channelSettings == nil then
        PartyPlannerSettings.channelSettings = {}

        local channels = {GetChannelList()}
        for i = 1, #channels, 3 do
            local id, name = channels[i], channels[i+1]
            PartyPlannerSettings.channelSettings[name] = {
                id = id,
                name = name,
                disabled = true
            }
        end
    end

    if PartyPlannerSettings.useAbreviation == nil then
        PartyPlannerSettings.useAbreviation = false
    end
end

local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("PLAYER_LOGOUT")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- EventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
-- EventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventFrame:RegisterEvent("CHANNEL_UI_UPDATE")

local function On_AddonLoaded()
    -- print("Addon loaded")
    LoadSettings()
    PartyPlanner.UI:Build()
end

local function On_PlayerLogout()
    -- print("Player logging out")
end

local function On_PlayerEnteringWorld()
    -- print("Player entering world")
end

local function On_SomethingInterestingChanged()
    -- print("Something interesting changed")
end

local function On_GroupRosterUpdate()
    -- print("Group roster updated")
    PartyPlanner.UI:UpdatePreviewText()
end

local function On_ChatChannelChanged()
    -- print("Chat channel changed")
    PartyPlanner.UI:UpdateChannelOptions()
end

EventFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    if event == "ADDON_LOADED" and arg1 == "PartyPlanner" then
        On_AddonLoaded()
    elseif event == "PLAYER_LOGOUT" then
        On_PlayerLogout()
    elseif event == "PLAYER_ENTERING_WORLD" then
        On_PlayerEnteringWorld()
    elseif event == "UNIT_INVENTORY_CHANGED" or 
    event == "PLAYER_EQUIPMENT_CHANGED" or
    event == "SKILL_LINES_CHANGED" then
        On_SomethingInterestingChanged()
    elseif event == "GROUP_ROSTER_UPDATE" then
        On_GroupRosterUpdate()
    elseif event == "CHANNEL_UI_UPDATE" or
    event == "CHANNEL_LEFT" then
        On_ChatChannelChanged()
    end
end)

local function OnCommand(msg)
    PartyPlanner.UI:ToggleUI()
end
SLASH_PARTYPLANNER_TOGGLE1 = "/pp"
SLASH_PARTYPLANNER_TOGGLE2 = "/partyplanner"
SlashCmdList["PARTYPLANNER_TOGGLE"] = OnCommand

