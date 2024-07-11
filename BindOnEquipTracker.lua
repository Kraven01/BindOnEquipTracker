local frame = CreateFrame("Frame", "BindOnEquipTrackerFrame", UIParent)
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
frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Leftclick -> Move / Zoom in \nRightclick -> Zoom out")
    GameTooltip:Show()
end)
frame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
closeButton:SetSize(30,30)
closeButton:SetScript("OnClick", function()
    frame:Hide()
end)

-- Create the title bar
local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetSize(350, 30)
titleBar:SetPoint("TOP", frame, "TOP")
titleBar.texture = titleBar:CreateTexture()
titleBar.texture:SetAllPoints(titleBar)
titleBar.texture:SetColorTexture(0, 0, 0, 0.8)
titleBar:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Leftclick -> Move / Zoom in \nRightclick -> Zoom out")
    GameTooltip:Show()
end)
titleBar:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Add the title text
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER")
titleText:SetText("Bind on Equip Tracker")

-- Adjust frame drag behavior to include title bar
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function()
    frame:StartMoving()
end)
titleBar:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
end)

local lastWindowButtonDistance = -1


local cachedExpensionButtons = {}
local cachedCategoryButtons = {}
local cachedDungeonButtons = {}
local spawnedButtons = {}
-- Create the scroll frame
local scrollFrame = CreateFrame("ScrollFrame", "ScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

-- Create the scroll child frame (content frame)
local content = CreateFrame("Frame", "ScrollFrameContent", scrollFrame)
content:SetSize(260, 400) -- Width, Height (adjust height based on content)
scrollFrame:SetScrollChild(content)

local lastWindowButton = content


local function ShowButton(pressedButton)
    tinsert(spawnedButtons, pressedButton)
    if lastWindowButton == content then
        pressedButton:SetPoint("TOP", lastWindowButton,"TOP", 0, lastWindowButtonDistance);
    else 
        pressedButton:SetPoint("TOP", lastWindowButton,"BOTTOM", 0, lastWindowButtonDistance);
    end
    pressedButton:SetPoint("LEFT", lastWindowButton, "LEFT", 300, 0);
    pressedButton:SetPoint("RIGHT", lastWindowButton, "LEFT", 0, 0);
    pressedButton:Show();
    lastWindowButton = pressedButton;
end

local function HideButtons()
    for _, buttonToHide in ipairs(spawnedButtons) do
        buttonToHide:Hide()
    end
    spawnedButtons = {}
    lastWindowButton = content
end

local function HandleMouseClick(self, button)
    scrollFrame:SetVerticalScroll(0)
    if self:GetName() == "ScrollFrame" and button == "RightButton" then
        local child = spawnedButtons[1]
        self = child
    end
    if button == "RightButton" then 
        HideButtons()
        for _, parentButton in pairs(self.showOnRightClick) do

            local mergedNameOfButton = self.mergedParentName .. _
            if self.mergedName == "item" then 
                mergedNameOfButton = self.mergedParentName .. parentButton
            end
            local correspondingButton = cachedExpensionButtons[mergedNameOfButton] or cachedCategoryButtons[mergedNameOfButton] or cachedDungeonButtons[mergedNameOfButton]
            ShowButton(correspondingButton)
        end
    else
        if self.mergedName == "item" or self:GetName() == "ScrollFrame" then
            return
        end
        HideButtons()
        for _, childButton in ipairs(self.spawnedChildButtons) do
            ShowButton(childButton)
        end
    end
end

scrollFrame:SetScript("OnMouseUp",HandleMouseClick);

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
            "Blackwing Lair",
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
["Blackwing Lair"] = {18562},
["Ruins of Ahn'Qiraj"] = {14968,14971,14967,14974,14970,14972,14854,14859,14855,14857,14975,14977,14976,14978,14981,14983,15646,15640,15645,14798,14802,14805,14803,14922,14924,14926,14928,14317,14310,14314,14309,14311,14315,15649,15651,15654,15656,15650,15655,15694,15426,15431,15425,15429,15433,15658,15660,15663,15666,15659,15662,15665,15668,15672,15674,15669,15673,15676, 21801,21804,21803,21805,21800,21802},
}

 
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

local function CreateButton(buttonText, parentName)
    isItem = isItem or false
    local currentButton = CreateFrame("Button", buttonText.."Button", content, "UIPanelButtonTemplate");
    currentButton:SetHeight(17);
    currentButton:DisableDrawLayer("BACKGROUND");
    currentButton:SetText(buttonText);
    currentButton:GetFontString():SetPoint("LEFT", currentButton, "LEFT", 5 ,0)
    currentButton.spawnedChildButtons = {}
    currentButton:Hide()
    currentButton.mergedName = parentName .. buttonText;
    currentButton:SetScript("OnMouseUp",HandleMouseClick);
    return currentButton
end

for expansion, content in pairs(expensions) do
    local expensionButton = CreateButton(expansion, "");
    ShowButton(expensionButton)
    cachedExpensionButtons[expensionButton.mergedName] = expensionButton;
    expensionButton.showOnRightClick = expensions;
    expensionButton.mergedParentName = "";
    for contentType, contentList in pairs(content) do
        local categoryButton = CreateButton(contentType, expensionButton.mergedName);
        categoryButton.showOnRightClick = expensions
        categoryButton.mergedParentName = ""
        tinsert(expensionButton.spawnedChildButtons, categoryButton)
        cachedCategoryButtons[categoryButton.mergedName] = categoryButton;
        for _, instance in ipairs(contentList) do
            local dungeonButton = CreateButton(instance, categoryButton.mergedName);
            tinsert(categoryButton.spawnedChildButtons, dungeonButton)
            dungeonButton.showOnRightClick = expensions[expansion]
            dungeonButton.mergedParentName = expansion
            cachedDungeonButtons[dungeonButton.mergedName] = dungeonButton;
            for _, itemData in pairs(dungeons[instance]) do

                local function UpdateItemInfo()
                    local itemNameText, _, itemQuality , _, _, _, _, _, _, itemIconPath = GetItemInfo(itemData)
                    if itemNameText and itemIconPath and itemQuality then
                        local itemButton = CreateButton(itemNameText, dungeonButton.mergedName)
                        itemButton.showOnRightClick = expensions[expansion][contentType]
                        itemButton.mergedParentName = expansion .. contentType
                        tinsert(dungeonButton.spawnedChildButtons, itemButton)
                        itemButton:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetItemByID(itemData)
                            GameTooltip:Show()
                        end)
                        itemButton:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)
                        local customFont = rarityFontMapping[itemQuality]
                        itemButton:SetNormalFontObject(customFont);
                        local icon = itemButton:CreateTexture(nil, "ARTWORK")
                        icon:SetTexture(itemIconPath);
                        icon:SetSize(15,15);
                        icon:SetPoint("LEFT", itemButton, "LEFT", 5, 0)
                        itemButton:GetFontString():SetPoint("LEFT", icon, "RIGHT", 5 ,0)
                        itemButton.mergedName = "item"
                    else
                        C_Timer.After(1, UpdateItemInfo)
                    end
                end
                    
                UpdateItemInfo()
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
    print("boetracker addon loaded. Type /bt show to display the frame or /bt hide to hide it.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", OnPlayerLogin)