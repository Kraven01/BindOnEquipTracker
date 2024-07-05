-- Main frame
-- ,"BasicFrameTemplateWithInset"
local frame = CreateFrame("Frame", "MyEmptyFrame", UIParent)
frame:SetSize(350, 200)
frame:SetPoint("CENTER")
frame.texture = frame:CreateTexture()
frame.texture:SetAllPoints(frame)
frame.texture:SetColorTexture(0, 0, 0, 0.5)
frame:Hide()

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local WindowButtons = {}
local lastWindowButtonDistance = -8

-- Store all created buttons
local dungeonButtons = {}
local itemButtons = {}
local buttonStates = {}

-- Create the scroll frame
local scrollFrame = CreateFrame("ScrollFrame", "ScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

-- Create the scroll child frame (content frame)
local content = CreateFrame("Frame", "ScrollFrameContent", scrollFrame)
content:SetSize(260, 800) -- Width, Height (adjust height based on content)
scrollFrame:SetScrollChild(content)

-- Create a scroll bar
local scrollBar = CreateFrame("Slider", "ScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
scrollBar:SetPoint("TOPLEFT", mainFrame, "TOPRIGHT", -20, -20)
scrollBar:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMRIGHT", -20, 20)
scrollBar:SetMinMaxValues(1, 400) -- Min, Max scroll values (adjust based on content height)
scrollBar:SetValueStep(1)
scrollBar.scrollStep = 1
scrollBar:SetValue(0)
scrollBar:SetWidth(16)
scrollBar:SetScript("OnValueChanged", function(self, value)
    self:GetParent():SetVerticalScroll(value)
end)


-- Table to store dungeons and their associated items
local dungeons = {
    ["Molten Core"] = {
        icon = "Interface\\ICONS\\INV_Spear_01",
        items = {17182, 17076, 18803}
    },
    ["Test Core"] = {
        icon = "Interface\\ICONS\\INV_Spear_02",
        items = {17186, 19803, 18203}
    },
    ["Zul Gurub"] = {
        icon = "Interface\\ICONS\\Achievement_Boss_Hakkar",
        items = {1728, 19336, 19802, 1727}
    },
}

local defaultAnchor = "TOP"
local defaultDungeonButtonXOffset = -40
local defaultItemButtonXOffset = -30
local elementHeight = 30




local function getKeyPosition(key, tbl)
    local position = 1
    for k, _ in pairs(tbl) do
        if k == key then
            return position
        end
        position = position + 1
    end
    return nil  -- key not found
end

local lastWindowButton = content
local lastItemButton = nil
-- Function to create a dungeon button
local function CreateDungeonButton(name, iconPath, yOffset)
    local dungeonButton = CreateFrame("Button", name.."Button", content, "UIPanelButtonTemplate");
    if lastWindowButton == content then
        dungeonButton:SetPoint("TOP", lastWindowButton,"TOP", 0, lastWindowButtonDistance);
    else 
        dungeonButton:SetPoint("TOP", lastWindowButton,"BOTTOM", 0, lastWindowButtonDistance);
    end
        
    dungeonButton:SetPoint("LEFT", lastWindowButton, "LEFT", 300, 0)
    dungeonButton:SetPoint("RIGHT", lastWindowButton, "LEFT", 0, 0);
    dungeonButton:SetHeight(17);
    dungeonButton:DisableDrawLayer("BACKGROUND");

    dungeonButton:SetText(name);
    dungeonButton:GetFontString():SetPoint("LEFT", dungeonButton, "LEFT", 5 ,0)
    WindowButtons[name] = {}
    tinsert(WindowButtons[name], dungeonButton)
    tinsert(WindowButtons[name], lastWindowButton)
    tinsert(WindowButtons[name], lastItemButton)
    lastWindowButtonDistance = -1;
    lastWindowButton = dungeonButton;
    
    return dungeonButton
end

local function UpdatePositions(dungeonButton)
    local pressedButtonReached = false;
    local reachedTrue = false;
    for name, positionData in pairs(WindowButtons) do
        local currentDungeonButton = positionData[1]
        local lastDungeonButton = positionData[2]
        local lastItemButton = positionData[3]
        if pressedButtonReached then
            if reachedTrue then 
                currentDungeonButton:SetPoint("TOP", lastDungeonButton, "BOTTOM", 0 , lastWindowButtonDistance)
            else
                currentDungeonButton:SetPoint("TOP", lastItemButton, "BOTTOM", 0 , lastWindowButtonDistance)
            end
            break
        end
        
        if name == dungeonButton:GetText() then
            pressedButtonReached = true;
            reachedTrue = buttonStates[name];
        end
    end
end
local lastButtonInserted = nil
-- Function to create an item button
local function CreateItemButton(itemID, yOffset, parent)
    local itemButton = CreateFrame("Button", "ItemButton"..itemID, parent, "UIPanelButtonTemplate")
    if lastButtonInserted == nil then
        lastButtonInserted = parent
    end
    itemButton:SetPoint("TOP", lastButtonInserted, "BOTTOM", 0, lastWindowButtonDistance)
    itemButton:SetPoint("LEFT", parent, "LEFT", 300, -8)
    itemButton:SetPoint("RIGHT", parent, "LEFT", 8, -8);
    itemButton:SetHeight(17); 
    itemButton:DisableDrawLayer("BACKGROUND");
    lastButtonInserted = itemButton

    itemButton:Hide()
    
    local function UpdateItemInfo()
        local itemNameText, _, _, _, _, _, _, _, _, itemIconPath = GetItemInfo(itemID)
        if itemNameText and itemIconPath then
            itemButton:SetText(itemNameText)
            itemButton:GetFontString():SetPoint("LEFT", itemButton, "LEFT", 5 ,0)
        else
            C_Timer.After(1, UpdateItemInfo)
        end
    end
    
    UpdateItemInfo()
    
    local function ShowItemTooltip(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(itemID)
        GameTooltip:Show()
    end
    
    local function HideItemTooltip(self)
        GameTooltip:Hide()
    end
    
    itemButton:SetScript("OnEnter", ShowItemTooltip)
    itemButton:SetScript("OnLeave", HideItemTooltip)
    
    return itemButton
end


-- Function to toggle item buttons for a specific dungeon
local function ToggleItemButtons(dungeonName)
    for _, button in ipairs(itemButtons[dungeonName]) do
        buttonStates[dungeonName] = button:IsShown();
        if button:IsShown() then
            button:Hide()
        else
            button:Show()
        end
    end
end

local function PreLoadItemButtons(dungeonName, dungeonData, dungeonButton)
    local position = getKeyPosition(dungeonName, dungeons)
    local yOffset = position * -50
    itemButtons[dungeonName] = {}
    lastButtonInserted = nil
    local itemButton;
    for i, itemID in ipairs(dungeonData.items) do
        itemButton = CreateItemButton(itemID, yOffset, dungeonButton)
        yOffset = yOffset - 40
        table.insert(itemButtons[dungeonName], itemButton)
    end
    return itemButton
end

local function CountElementInList(list)
    local counter = 0
    for _ in pairs(list) do
        counter = counter +1 
    end
    return counter
end

-- Create dungeon buttons and corresponding item buttons
local yOffset = -10
for dungeonName, dungeonData in pairs(dungeons) do
    local dungeonButton = CreateDungeonButton(dungeonName, dungeonData.icon, yOffset)
    dungeonButtons[dungeonName] = {}
    buttonStates[dungeonName] = false
    table.insert(dungeonButtons[dungeonName], dungeonButton)
    yOffset = yOffset - 40
    lastItemButton = PreLoadItemButtons(dungeonName, dungeonData, dungeonButton)
    dungeonButton:SetScript("OnClick", function()
        -- UpdateButtonPositions(dungeonName, dungeonButton)
        ToggleItemButtons(dungeonName)
        UpdatePositions(dungeonButton)
    end)
end


local function SlashCmdHandler(msg, editBox)
    if msg == "show" then
        frame:Show()
    elseif msg == "hide" then
        frame:Hide()
    else
        print("Usage: /bt show or /bt hide")
    end
end

SLASH_BINDONEQUIPTRACKER1  = "/bt"
SLASH_BINDONEQUIPTRACKER2  = "/boetracker"
SlashCmdList["BINDONEQUIPTRACKER"] = SlashCmdHandler

local function OnPlayerLogin(self, event, ...)
    print("boetracker addon loaded. Type /boetracker show to display the frame or /boetracker hide to hide it.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", OnPlayerLogin)
