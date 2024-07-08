local frame = CreateFrame("Frame", "BindOnEquipTracerFrame", UIParent)
frame:SetSize(350, 400)
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
            "Blackfathom Deeps",
            "Blackrock Depths",
            "Deadmines",
            "Dire Maul",
            "Gnomeregan",
            "Lower Blackrock Spire",
            "Razorfen Downs",
            "Razorfen Kraul",
            "Scarlet Halls",
            "Scarlet Monastery",
            "Scholomance",
            "Shadowfang Keep",
            "Stratholme",
            "The Temple of Atal'hakkr",
            "Uldaman",
            "Wailing Caverns",
            "Zul'Farrak",
        },
        Raids = {
            "Molten Core",
            "Blackwin Lair",
            "Ruins of Ahn'Qiraj"
        }
    },
}

local dungeons = {
["Blackfathom Deeps"] = { 15311, 14565, 1486, 14370, 15500, 14372, 14172, 14125, 14133, 14746, 14747,14742,14749,14748,14743,15891, 3416,1491,3413,2567,3417,1454,1481,3414,3415,2271,4410},
["Blackrock Depths"] = { 12552,12551,12542,12546,12550,12547,12549,12555,12531,12535,12527,12528,12532,15781,15770,16053,16049,16048,18654,18661,11754,11078,18945,64304,64313},
["Deadmines"] = { 10401,10400,1951,1928,1925,1943,1936,1944,8492,1958,1930,120138,1926,1945,5787},
["Dire Maul"] = {9434,18295,18344,18298,18296,18289,18340,18338,18487,18339,18337,18365},
["Gnomeregan"] = {6592,6590,6595,6594,6596,6597,6591,6395,7110,6394,4036,6393,4037,4035,4714,9508,9491,9509,9510,9538,9487,9485,9488,9486,9490,9327,5108,},
["Lower Blackrock Spire"] = {14513,16250,15749,15775,13494},
["Razorfen Downs"] = {1981, 14834, 14838, 14841, 14833, 14839, 14843, 14840, 10581,10578,10574,10583,10582,10584,10567,10571,10573,10570,10572},
["Razorfen Kraul"] = {15518, 15541, 15542, 15534, 15536, 15540, 2264,1978,1488,4438,2039,776,1727,2549,1976,1975},
["Scarlet Halls"] = {7754,7786,7787,8226,7727},
["Scarlet Monastery"] = {7759,7728,7753,7729,7730,7752,7736,7755,7754,7786,7787,7758,10329,10332,10328,10331,10333,5756,7761,5819,1992,8225,8226,7760,7727,7757},
["Scholomance"] = {16255,18702,14536,18697,18699,18700,18698},
["Shadowfang Keep"] = {14175,1935,3194,2205,1483,1489,2807,1974,2292,1318,1482,1484},
["Stratholme"] = {206374,142337,18743,17061,18741,18744,18736,18745,18742,12811,16249,18658,16052,16248,74274},
["The Temple of Atal'hakkr"] = {78346,78345,10627,10628,10626,10625,10624,10623,10630,10632,10631,10633,10629},
["Uldaman"] = {9420,9392,9393,9465,9381,9397,9386,9424,9396,9429,9426,9383,9431,9425,9422,9432,9430,9406,9427,9384,9423,9391,9428,9378,9375,9382},
["Wailing Caverns"] = {48114,10413,132743},
["Zul'Farrak"] = {940,1168,14263,14441,15622,15628,15619,15627,15623,14796,14792,14794,14793,14948,14953,14955,14951,14949,14950,14842,14840,14843,14839,14835,14841,14838,14834,14920,14918,14914,14917,14970,14974,14966, 142402,9512,9511,9480,9483,5616,9484,9481,2040,9482,204406},
["Molten Core"] = {16802,16799,16864,16861,16828,16830,16838,16840,16806,16804,16851,16850,16817,16858,16857,16827,16825,16819,170100,17011,18260,18259,21371,18265,18257,11382},
["Blackwin Lair"] = {18562},
["Ruins of Ahn'Qiraj"] = {14968,14971,14967,14974,14970,14972,14854,14859,14855,14857,14975,14977,14976,14978,14981,14983,15646,15640,15645,14798,14802,14805,14803,14922,14924,14926,14928,14317,14310,14314,14309,14311,14315,15649,15651,15654,15656,15650,15655,15694,15426,15431,15425,15429,15433,15658,15660,15663,15666,15659,15662,15665,15668,15672,15674,15669,15673,15676, 21801,21804,21803,21805,21800,21802},
}
local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end
 
  local rarityColorMapping = {
    [0] = {
        ["r"] = 0.62,
        ["g"] = 0.62,
        ["b"] = 0.62
    },
    [1] = {
        ["r"] = 1.00,
        ["g"] = 1.00,
        ["b"] = 1.00
    },
    [2] = {
        ["r"] = 0.12,
        ["g"] = 1.00,
        ["b"] = 0.00
    },
    [3] = {
        ["r"] = 0.00,
        ["g"] = 0.44,
        ["b"] = 0.87
    },
    [4] = {
        ["r"] = 0.64,
        ["g"] = 0.21,
        ["b"] = 0.93
    },
    [5] = {
        ["r"] = 1.00,
        ["g"] = 0.50,
        ["b"] = 1.00
    }
}


local rarityFontMapping = {}

local function createRarityFontMapping()
    for key, rgb in pairs(rarityColorMapping) do
        local r = rgb["r"]
        local g = rgb["g"]
        local b = rgb["b"]

        local customFont = CreateFont(key);
        customFont:SetTextColor(r,g,b);
        rarityFontMapping[key] = customFont;
    end
end
createRarityFontMapping()

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
            local lastVisibleButton = CheckLastsVisible(expensionButtonPressed:GetText())
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
    local couldNotFindSuccesor = UpdateTopAnchor(expensions[expensionName], instanceButtonPressed, categoryButtonParent, lastButtonInUpperElement, expensionName)
    if couldNotFindSuccesor then
        UpdateExpensionPositions(expensionButton, expensions)
    end
end

local lastitemButtonInserted = nil
local function CreateItemButton(itemID, parent, tableName)
    local itemButton = CreateFrame("Button", "ItemButton"..itemID, parent, "UIPanelButtonTemplate")
    if lastitemButtonInserted == nil then
        lastitemButtonInserted = parent
    end
    itemButton:SetPoint("TOP", lastitemButtonInserted, "BOTTOM", 0, lastWindowButtonDistance)
    itemButton:SetPoint("LEFT", parent, "LEFT", 300, -8)
    itemButton:SetPoint("RIGHT", parent, "LEFT", 8, -8);
    itemButton:SetHeight(17); 
    local combinedName = tableName .. itemID
    buttonMappings[combinedName] = {}
    tinsert(buttonMappings[combinedName], itemButton)
    tinsert(buttonMappings[combinedName], lastitemButtonInserted)


    lastitemButtonInserted = itemButton
    itemButton:Hide()
    
    local function UpdateItemInfo()
    local itemNameText, _, itemQuality , _, _, _, _, _, _, itemIconPath = GetItemInfo(itemID)
    if itemNameText and itemIconPath then
        local icon = itemButton:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(itemIconPath);
        icon:SetSize(15,15);
        icon:SetPoint("LEFT", itemButton, "LEFT", 5, 0)
        itemButton:SetText(itemNameText)
        itemButton:GetFontString():SetPoint("LEFT", icon, "RIGHT", 5 ,0)
        local customFont = rarityFontMapping[itemQuality]
        itemButton:SetNormalFontObject(customFont);

        itemButton:DisableDrawLayer("BACKGROUND");
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
