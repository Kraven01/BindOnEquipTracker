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
local dungeonButtonsList = {}
local itemButtons = {}

-- Key: CombinedName 1. button 2. originalAnchorPoint
local buttonStates = {}
local expensionButtons = {}
local expensionCategoryButtons = {}
local expensionCategoryInnerButtons = {}

local buttonMappings = {}

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

local expensions = {
    ["Classic"] = {
        Dungeons = {
            "Zul Gurub",
            "Molten Core"
        },
        Raids = {
            "Test Core"
        }
    },
    ["Cataclysm"] = {
        Dungeons = {
            "Zul Gurub",
            "Molten Core"
        },
        Raids = {
            "Test Core"
        }
    },
    ["Pandaria"] = {
        Dungeons = {
            "Zul Gurub",
            "Molten Core"
        },
        Raids = {
            "Test Core"
        }
    },
}

-- Table to store dungeons and their associated items
local dungeons = {
    ["Molten Core"] = {17182, 17076, 18803},
    ["Test Core"] = {17186, 19803, 18203},
    ["Zul Gurub"] = {1728, 19336, 19802, 1727},
}


local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end


local lastWindowButton = content
local lastItemButton = nil
local function CreateExpensionButton(name)
    local expensionButton = CreateFrame("Button", name.."Button", content, "UIPanelButtonTemplate");
    if lastWindowButton == content then
        expensionButton:SetPoint("TOP", lastWindowButton,"TOP", 0, lastWindowButtonDistance);
    else 
        expensionButton:SetPoint("TOP", lastWindowButton,"BOTTOM", 0, lastWindowButtonDistance);
    end
        
    expensionButton:SetPoint("LEFT", lastWindowButton, "LEFT", 300, 0)
    expensionButton:SetPoint("RIGHT", lastWindowButton, "LEFT", 0, 0);
    expensionButton:SetHeight(17);
    expensionButton:DisableDrawLayer("BACKGROUND");
    expensionButton:SetText(name);
    expensionButton:GetFontString():SetPoint("LEFT", expensionButton, "LEFT", 5 ,0)
    expensionButtons[name] = {}

    buttonMappings[name] = {}
    tinsert(buttonMappings[name], expensionButton)
    tinsert(buttonMappings[name], lastWindowButton)
    lastWindowButtonDistance = -1;

    lastWindowButton = expensionButton
    return expensionButton
end

local lastCategoryInserted = nil
local function CreateCategoryButton(name, parent)
    local categoryButton = CreateFrame("Button", name.."Button", parent, "UIPanelButtonTemplate");
    if lastCategoryInserted == nil then 
        lastCategoryInserted = parent
    end
    
    categoryButton:SetPoint("TOP", lastCategoryInserted,"BOTTOM", 0, lastWindowButtonDistance);
   
    categoryButton:SetPoint("LEFT", parent, "LEFT", 300, -8)
    categoryButton:SetPoint("RIGHT", parent, "LEFT", 8, -8);
    categoryButton:SetHeight(17);
    categoryButton:DisableDrawLayer("BACKGROUND");

    categoryButton:SetText(name);
    categoryButton:GetFontString():SetPoint("LEFT", categoryButton, "LEFT", 5 ,0)
    categoryButton:Hide()
    local parentText = parent:GetText()
    tinsert(expensionButtons[parentText], categoryButton)
    local combinedName = parentText .. name;
    expensionCategoryButtons[combinedName] = {};

    buttonMappings[combinedName] = {}
    tinsert(buttonMappings[combinedName], categoryButton)
    tinsert(buttonMappings[combinedName], lastCategoryInserted)

    lastCategoryInserted = categoryButton;
    return categoryButton
end


local lastDungeonInserted = nil
-- Function to create a dungeon button
local function CreateDungeonButton(name, parent, tableName)
    local dungeonButton = CreateFrame("Button", name.."Button", parent, "UIPanelButtonTemplate");
    if lastDungeonInserted == nil then 
        lastDungeonInserted = parent
    end
    
    dungeonButton:SetPoint("TOP", lastDungeonInserted,"BOTTOM", 0, lastWindowButtonDistance);
   
    dungeonButton:SetPoint("LEFT", parent, "LEFT", 300, -8)
    dungeonButton:SetPoint("RIGHT", parent, "LEFT", 8, -8);
    dungeonButton:SetHeight(17);
    dungeonButton:DisableDrawLayer("BACKGROUND");

    dungeonButton:SetText(name);
    dungeonButton:GetFontString():SetPoint("LEFT", dungeonButton, "LEFT", 5 ,0)
    dungeonButton:Hide()
    tinsert(expensionCategoryButtons[tableName], dungeonButton)
    local combinedName = tableName .. name
    expensionCategoryInnerButtons[combinedName] = {}

    buttonMappings[combinedName] = {}
    tinsert(buttonMappings[combinedName], dungeonButton)
    tinsert(buttonMappings[combinedName], lastDungeonInserted)


    lastDungeonInserted = dungeonButton
    
    -- WindowButtons[name] = {}
    -- tinsert(WindowButtons[name], dungeonButton)
    -- tinsert(WindowButtons[name], lastWindowButton)
    -- tinsert(WindowButtons[name], lastItemButton)
    lastWindowButtonDistance = -1;
    
    return dungeonButton
end

local function UpdateTopAnchor(listToSearchForButton, buttonPressed, parentButton, lastButtonInUpperElement, prefix)
    local pressedButton = false;
    for name, _ in pairs(listToSearchForButton) do 
        if pressedButton then
            local mergedName = prefix .. name
            local currentButton = buttonMappings[mergedName][1]
            if lastButtonInUpperElement:IsShown() then 
                currentButton:SetPoint("TOP", lastButtonInUpperElement, "BOTTOM", 0, lastWindowButtonDistance)
            else 
                currentButton:SetPoint("TOP", buttonPressed, "BOTTOM", lastWindowButtonDistance) 
            end
            return
        end
        if parentButton:GetText() == name then
            pressedButton = true;
        end;
    end
    return true;
end


local function CheckLastVisibleForCategory(categoryName, expansionName)
    local elementsInList = tablelength(expensionCategoryButtons[expansionName .. categoryName]);
    local lastButtonInList = expensionCategoryButtons[expansionName .. categoryName][elementsInList]
    local lastButtonText = lastButtonInList:GetText()
    local mergedText = expansionName .. categoryName .. lastButtonText;
    local elementsInInstanceList = tablelength(expensionCategoryInnerButtons[mergedText])
    local lastDungeonButton = expensionCategoryInnerButtons[mergedText][elementsInInstanceList];
    if lastDungeonButton:IsShown() then
        return lastDungeonButton;
    else
        return lastButtonInList;
    end

end

local function CheckLastsVisible(expensionName)
    local elementsInList = tablelength(expensionButtons[expensionName]);
    local lastButtonInList = expensionButtons[expensionName][elementsInList]
    local lastButtonText = lastButtonInList:GetText()
    local mergedText = expensionName .. lastButtonText;
    local elementsInInstanceList = tablelength(expensionCategoryButtons[mergedText])
    local lastDungeonButton = expensionCategoryButtons[mergedText][elementsInInstanceList];
    if lastDungeonButton:IsShown() then
        local mergedInstanceName = mergedText .. lastDungeonButton:GetText()
        local elementsInItemList = tablelength(expensionCategoryInnerButtons[mergedInstanceName])
        local lastItemButton = expensionCategoryInnerButtons[mergedInstanceName][elementsInItemList]
        if lastItemButton:IsShown() then
            return lastItemButton;
        else
            return lastDungeonButton;
        end
    else
        return lastButtonInList;
    end

end


local function UpdateExpensionPositions(expensionButtonPressed, expensionList)
    local pressedButton = false;
    local lastButtonInUpperElement
    for name , data in pairs(expensionList) do
        if pressedButton then
            local currentButton = buttonMappings[name][1]
            local elementsInUpperList = tablelength(expensionButtons[expensionButtonPressed:GetText()])
            local lastButtonInUpperElement = expensionButtons[expensionButtonPressed:GetText()][elementsInUpperList]
            -- local categoryName = expensionButtonPressed:GetText() .. lastButtonInUpperElement:GetText()
            local lastVisibleButton = CheckLastsVisible(expensionButtonPressed:GetText())
            -- local hit = CheckLastsVisible(categoryName, expensionCategoryButtons)
            if (lastButtonInUpperElement:IsShown()) then 
                currentButton:SetPoint("TOP", lastVisibleButton, "BOTTOM", 0, lastWindowButtonDistance)
            else 
                currentButton:SetPoint("TOP", buttonMappings[name][2], "BOTTOM", 0, lastWindowButtonDistance)
            end
            break
        end
        if name == expensionButtonPressed:GetText() then
            pressedButton = true;
        end
    end
end


-- local function UpdateAnchorOfCategory(listToSearchFor, )

-- TODO: Handle case last category pressed
local function UpdateCategoryPositions(categoryButtonPressed, expensionButtonParent)
    local parentText = expensionButtonParent:GetText()
    local mergedCategoryButtonPressed = parentText .. categoryButtonPressed:GetText()
    local pressedButton = false;
    local lastButtonInUpperElement = nil;
    local test = nil
    for category, _ in pairs(expensions[parentText]) do
        local mergedName = parentText .. category;
        local currentButton = buttonMappings[mergedName][1]
        local elementsInUpperList = tablelength(expensionCategoryButtons[mergedCategoryButtonPressed]);
        lastButtonInUpperElement = expensionCategoryButtons[mergedCategoryButtonPressed][elementsInUpperList]
        if pressedButton then
            if (lastButtonInUpperElement:IsShown()) then 
                currentButton:SetPoint("TOP", test, "BOTTOM", 0, lastWindowButtonDistance)
            else 
                currentButton:SetPoint("TOP", buttonMappings[mergedName][2], "BOTTOM", 0, lastWindowButtonDistance)
            end
            return;

        end
        if currentButton:GetText() == categoryButtonPressed:GetText() then
            pressedButton = true;
            test = CheckLastVisibleForCategory(category, parentText)
        end
    end
    UpdateExpensionPositions(expensionButtonParent, expensions)
end

local function UpdateInstancePositions(instanceButtonPressed, categoryButtonParent, expensionName, expensionButton)
    local categoryText = categoryButtonParent:GetText()
    local mergedName = expensionName .. categoryText .. instanceButtonPressed:GetText()
    local pressedButton = false;
    local lastButtonInUpperElement = nil;
    for _, instanceName in ipairs(expensions[expensionName][categoryText]) do
        local mergedNameOfCurrentButton = expensionName .. categoryText .. instanceName;
        local currentButton = buttonMappings[mergedNameOfCurrentButton][1];
        local elementsInUpperList = tablelength(expensionCategoryInnerButtons[mergedName]);
        lastButtonInUpperElement = expensionCategoryInnerButtons[mergedName][elementsInUpperList];
        if pressedButton then
            if (lastButtonInUpperElement:IsShown()) then 
                currentButton:SetPoint("TOP", lastButtonInUpperElement, "BOTTOM", 0, lastWindowButtonDistance)
            else 
                currentButton:SetPoint("TOP", buttonMappings[mergedNameOfCurrentButton][2], "BOTTOM", 0, lastWindowButtonDistance)
            end
            return;
        end
        if currentButton:GetText() == instanceButtonPressed:GetText() then
            pressedButton = true
        end
    end
    -- 
    --UpdateCategoryPositions(categoryButtonParent, expensionButton)
    local couldNotFindSuccesor = UpdateTopAnchor(expensions[expensionName], instanceButtonPressed, categoryButtonParent, lastButtonInUpperElement, expensionName)
    if couldNotFindSuccesor then
        UpdateExpensionPositions(expensionButton, expensions)
    end
end

local lastitemButtonInserted = nil
-- Function to create an item button
local function CreateItemButton(itemID, parent, tableName)
    local itemButton = CreateFrame("Button", "ItemButton"..itemID, parent, "UIPanelButtonTemplate")
    if lastitemButtonInserted == nil then
        lastitemButtonInserted = parent
    end
    itemButton:SetPoint("TOP", lastitemButtonInserted, "BOTTOM", 0, lastWindowButtonDistance)
    itemButton:SetPoint("LEFT", parent, "LEFT", 300, -8)
    itemButton:SetPoint("RIGHT", parent, "LEFT", 8, -8);
    itemButton:SetHeight(17); 
    itemButton:DisableDrawLayer("BACKGROUND");
    local combinedName = tableName .. itemID
    buttonMappings[combinedName] = {}
    tinsert(buttonMappings[combinedName], itemButton)
    tinsert(buttonMappings[combinedName], lastitemButtonInserted)


    lastitemButtonInserted = itemButton
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
    tinsert(expensionCategoryInnerButtons[tableName], itemButton)
    return itemButton
end



local function ToggleButtons(listOfButtons, prefix, tableToSearch)
    for _, button in ipairs(listOfButtons) do
        if button:IsShown() then
            button:Hide()
        else
            button:Show()
        end
    end
end

for expansion, content in pairs(expensions) do
    print(expansion)
    local expensionButton = CreateExpensionButton(expansion)
    lastCategoryInserted = nil
    expensionButton:SetScript("OnClick", function()
        ToggleButtons(expensionButtons[expansion], expansion, expensionCategoryButtons)
        UpdateExpensionPositions(expensionButton, expensions)
    end)
    for contentType, contentList in pairs(content) do
        local categoryButton = CreateCategoryButton(contentType, expensionButton)
        lastDungeonInserted = nil;
        local mergedName = expansion .. contentType
        categoryButton:SetScript("OnClick", function()
            ToggleButtons(expensionCategoryButtons[mergedName], expansion, expensionCategoryButtons)
            UpdateCategoryPositions(categoryButton, expensionButton)
        end);
        for _, instance in ipairs(contentList) do
            local dungeonButton = CreateDungeonButton(instance, categoryButton, mergedName)
            lastitemButtonInserted = nil
            local mergedNameForItemTable = mergedName .. instance
            dungeonButton:SetScript("OnClick", function()
                ToggleButtons(expensionCategoryInnerButtons[mergedNameForItemTable], mergedName)
                UpdateInstancePositions(dungeonButton, categoryButton, expansion, expensionButton)
            end);
            for _, itemData in pairs(dungeons[instance]) do
                local itemButton = CreateItemButton(itemData, dungeonButton, mergedNameForItemTable)
            end
        end
    end
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
