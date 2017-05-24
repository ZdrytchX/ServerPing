kServerEntryHeight = 34 -- little bit bigger than highlight server
local kDefaultWidth = 350

local kFavoriteIconSize = Vector(26, 26, 0)
local kFavoriteIconPos = Vector(5, 4, 0)
local kFavoriteTexture = PrecacheAsset("ui/menu/favorite.dds")
local kNonFavoriteTexture = PrecacheAsset("ui/menu/nonfavorite.dds")

local kFavoriteMouseOverColor = Color(1, 0.2, 0)
local kFavoriteColor = Color(212/255, 175/255, 55/255, 0.9)

local kPrivateIconSize = Vector(26, 26, 0)
local kPrivateIconTexture = PrecacheAsset("ui/lock.dds")

--local kPingIconSize = Vector(37, 24, 0)
--local kPingIconTextures = {
--    {100,  PrecacheAsset("ui/icons/ping_5.dds")},
--    {200, PrecacheAsset("ui/icons/ping_4.dds")},
--    {300, PrecacheAsset("ui/icons/ping_3.dds")},
--    {400, PrecacheAsset("ui/icons/ping_2.dds")},
--    {999, PrecacheAsset("ui/icons/ping_1.dds")},
--}

--local kPerfIconSize = Vector(26, 26, 0)
--local kPerfIconTexture = PrecacheAsset("ui/icons/smiley_meh.dds")

--local kSkillIconSize = Vector(26, 26, 0)
--local kSkillIconTextures = {
--    PrecacheAsset("ui/menu/skill_equal.dds"),
--    PrecacheAsset("ui/menu/skill_low.dds"),
--    PrecacheAsset("ui/menu/skill_high.dds")
--}

local kBlue = Color(0, 168/255 ,255/255) --used for ranked
local kGreen = Color(0, 208/255, 103/255) --dark green
local kLime = Color(128/255, 255/255, 35/255)--apple green Used for servers that are being seeding

local kYellow = Color(1, 1, 0)--Used for slots available
local kOrange = Color(1, 0.5, 0) --Used for nearly full - 20% or less remaining
--local kGold = Color(212/255, 175/255, 55/255)
local kPurple = Color(1, 0, 0.5)--dused for reserved full
local kRed = Color(1, 0 ,0)--kBlue --Color(1, 0 ,0) --used for full


function ServerEntry:Initialize()

    self:DisableBorders()

    MenuElement.Initialize(self)

    self.serverName = CreateTextItem(self, true)
    self.mapName = CreateTextItem(self, true)
    self.mapName:SetTextAlignmentX(GUIItem.Align_Center)
    --self.ping = CreateGraphicItem(self, true)
    --self.ping:SetTexture(kPingIconTextures[1][2])
    self.ping = CreateTextItem(self, true)--SetSize(kPingIconSize)
    self.ping:SetFontName(Fonts.kAgencyFB_Small)
    self.ping:SetTextAlignmentX(GUIItem.Align_Center)

--"performance" smileys
    --self.tickRate = CreateGraphicItem(self, true)
    --self.tickRate:SetTexture(kPerfIconTexture)
    --self.tickRate:SetSize(kPerfIconSize)

    self.hiveskillaverage = CreateTextItem(self, true)
    self.hiveskillaverage:SetFontName(Fonts.kAgencyFB_Small)
    self.hiveskillaverage:SetTextAlignmentX(GUIItem.Align_Center)

    self.modName = CreateTextItem(self, true)
    self.modName:SetTextAlignmentX(GUIItem.Align_Center)
    self.modName.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")

    self.playerCount = CreateTextItem(self, true)
    self.playerCount:SetTextAlignmentX(GUIItem.Align_Center)

    self.favorite = CreateGraphicItem(self, true)
    self.favorite:SetSize(kFavoriteIconSize)
    self.favorite:SetPosition(kFavoriteIconPos)
    self.favorite:SetTexture(kNonFavoriteTexture)
    self.favorite:SetColor(kFavoriteColor)

    self.private = CreateGraphicItem(self, true)
    self.private:SetSize(kPrivateIconSize)
    self.private:SetTexture(kPrivateIconTexture)

    self:SetFontName(Fonts.kAgencyFB_Small)

    self:SetTextColor(kWhite)
    self:SetHeight(kServerEntryHeight)
    self:SetWidth(kDefaultWidth)
    self:SetBackgroundColor(kNoColor)

    --Has no children, but just to keep sure, we do that.
    self:SetChildrenIgnoreEvents(true)

    local eventCallbacks =
    {
        OnMouseIn = function(self, buttonPressed)
            MainMenu_OnMouseIn()
        end,

        OnMouseOver = function(self)

            local height = self:GetHeight()
            local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
            self.scriptHandle.highlightServer:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
            self.scriptHandle.highlightServer:SetIsVisible(true)

            if GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen()) then
                self.favorite:SetColor(kFavoriteMouseOverColor)
            else
                self.favorite:SetColor(kFavoriteColor)
            end

            if self.modName.tooltipText and GUIItemContainsPoint(self.modName, Client.GetCursorPosScreen()) then
                self.modName.tooltip:SetText(self.modName.tooltipText)
                self.modName.tooltip:Show()
            else
                self.modName.tooltip:Hide()
            end
        end,

        OnMouseOut = function(self)

            self.scriptHandle.highlightServer:SetIsVisible(false)
            self.favorite:SetColor(kFavoriteColor)

            if self.lastOneClick then
                self.lastOneClick = nil
                if not self.scriptHandle.serverDetailsWindow:GetIsVisible() then
                    self.scriptHandle.serverDetailsWindow:SetIsVisible(true)
                end
            end

        end,

        OnMouseDown = function(self, key, doubleClick)

            if GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen()) then

                if not self.serverData.favorite then

                    self.favorite:SetTexture(kFavoriteTexture)
                    self.serverData.favorite = true
                    SetServerIsFavorite(self.serverData, true)

                else

                    self.favorite:SetTexture(kNonFavoriteTexture)
                    self.serverData.favorite = false
                    SetServerIsFavorite(self.serverData, false)

                end

                self.parentList:UpdateEntry(self.serverData, true)

            else

                SelectServerEntry(self)

                if doubleClick then

                    if (self.timeOfLastClick ~= nil and (Shared.GetTime() < self.timeOfLastClick + 0.3)) then
                        self.lastOneClick = nil
                        self.scriptHandle:ProcessJoinServer()
                    end

                else

                    self.scriptHandle.serverDetailsWindow:SetServerData(self.serverData, self.serverData.serverId or -1)
                    self.lastOneClick = Shared.GetTime()

                end

                self.timeOfLastClick = Shared.GetTime()

            end

        end
    }

    self:AddEventCallbacks(eventCallbacks)

end

function ServerEntry:SetParentList(parentList)
    self.parentList = parentList
end

function ServerEntry:SetFontName(fontName)

    self.serverName:SetFontName(fontName)
    self.serverName:SetScale(GetScaledVector())
    self.mapName:SetFontName(fontName)
    self.mapName:SetScale(GetScaledVector())
    self.modName:SetFontName(fontName)
    self.modName:SetScale(GetScaledVector())
    self.playerCount:SetFontName(fontName)
    self.playerCount:SetScale(GetScaledVector())

end

function ServerEntry:SetTextColor(color)

    self.serverName:SetColor(color)
    self.mapName:SetColor(color)
    self.modName:SetColor(color)
    self.playerCount:SetColor(color)

end

--[[
-- Returns the local clients hive skill or -1 if the hive service is not avaible
 ]]
function Client.GetSkill()
    return tonumber(GetGUIMainMenu().playerSkill) or -1
end

function ServerEntry:SetServerData(serverData)

    PROFILE("ServerEntry:SetServerData")

    if self.serverData ~= serverData then

        local numReservedSlots = GetNumServerReservedSlots(serverData.serverId)
        self.playerCount:SetText(string.format("%d/%d+%d", serverData.numPlayers, serverData.maxPlayers - numReservedSlots, numReservedSlots))
        if serverData.numPlayers >= serverData.maxPlayers then
            self.playerCount:SetColor(kRed)--Full
        elseif serverData.numPlayers >= serverData.maxPlayers - numReservedSlots then
            self.playerCount:SetColor(kPurple)--VIP access only
        elseif serverData.numPlayers >= serverData.maxPlayers * 0.8 - numReservedSlots then
            self.playerCount:SetColor(kOrange)--Almost full
        elseif serverData.numPlayers >= serverData.maxPlayers * 0.3 then
            self.playerCount:SetColor(kYellow)--moderate
        elseif (serverData.numPlayers < serverData.maxPlayers * 0.3) and (serverData.numPlayers > 0) then
            self.playerCount:SetColor(kLime)--Seedme
        else
            self.playerCount:SetColor(kWhite)
        end

        self.serverName:SetText(serverData.name)

        if serverData.rookieOnly then
            self.serverName:SetColor(kGreen)
        else
            self.serverName:SetColor(kWhite)
        end

        self.mapName:SetText(serverData.map)

        --for _, pingTexture in ipairs(kPingIconTextures) do
        --    if serverData.ping < pingTexture[1] then
        --        self.ping:SetTexture(pingTexture[2])
        --        break
        --    end
        --end

        self.ping:SetText(string.format("%d", serverData.ping))

        local lmaxping = 600--value where pure red starts
        local lping = Clamp(serverData.ping, 0, 999)
        local lcmod = 1000/lmaxping
        --green at 0, yellow at 0.5maxpig, red at maxping
        local lRedRange = Clamp(lcmod * lping/lmaxping, 0, 1)
        local lGreenRange = Clamp(lcmod - lcmod * lping/lmaxping, 0, 1)

        self.ping:SetColor(Color(lRedRange, lGreenRange, 0))

        --if serverData.performanceScore ~= nil then
        if serverData.playerSkill ~= nil then
            --self.tickRate:SetTexture(ServerPerformanceData.GetPerformanceIcon(serverData.performanceQuality, serverData.performanceScore))
            -- Log("%s: score %s, q %s", serverData.name, serverData.performanceScore, serverData.performanceQuality)
            --self.tickRate:SetTexture(kPerfIconTexture)
            self.hiveskillaverage:SetText(string.format("%d", serverData.playerSkill))
            if serverData.playerSkill == 0 or serverData.playerSkill == -1 then
                self.hiveskillaverage:SetText(string.format("N/A"))
            end
        end

        if serverData.playerSkill == nil or serverData.playerSkill == 0 or serverData.playerSkill == -1 then
          --special condition where it is 0 / nil
          self.hiveskillaverage:SetColor(Color(0.5, 0.5, 0.5))

        else
          --give some colours
            local lmaxhivescore = 2500--value where pure red starts
            local lhivescore = Clamp(serverData.playerSkill, 0, 4000)
            lhmod = 1000/lmaxping
            --green at 0, yellow at 0.5maxpig, red at maxping
            lhRedRange = Clamp(lhmod * lhivescore/lmaxhivescore, 0, 1)
            lhGreenRange = Clamp(lhmod - lcmod * lhivescore/lmaxhivescore, 0, 1)
            self.hiveskillaverage:SetColor(Color(lhRedRange, lhGreenRange, 0))
        end

        self.private:SetIsVisible(serverData.requiresPassword)

        self.modName:SetText(serverData.mode)
        self.modName:SetColor(kWhite)
        self.modName.tooltipText = nil

        if serverData.mode == "ns2" and serverData.ranked then
            self.modName:SetColor(kBlue)
            self.modName.tooltipText = Locale.ResolveString(string.format("SERVERBROWSER_RANKED_TOOLTIP"))
        end

        if serverData.favorite then
            self.favorite:SetTexture(kFavoriteTexture)
        else
            self.favorite:SetTexture(kNonFavoriteTexture)
        end

        local skillColor = kGreen
        local skillAngle = 0
        local skillTextureId = 1
        local toolTipId = 1

        self:SetId(serverData.serverId)
        self.serverData = { }
        for name, value in pairs(serverData) do
            self.serverData[name] = value
        end

    end

end


function ServerEntry:SetWidth(width, isPercentage, time, animateFunc, callBack)

    if width ~= self.storedWidth then
        -- The percentages and padding for each column are defined in the CSS
        -- We can use them here to set the position correctly instead of guessing like previously
        MenuElement.SetWidth(self, width, isPercentage, time, animateFunc, callBack)
        local currentPos = 0
        local currentWidth = self.favorite:GetSize().x
        local currentPercentage = width * 0.03
        local kPaddingSize = 4
        self.favorite:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))

        currentPos = currentPercentage + kPaddingSize
        currentPercentage = width * 0.03
        currentWidth = self.private:GetSize().x
        self.private:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.46
        self.serverName:SetPosition(Vector((currentPos + kPaddingSize), 0, 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScale(self.modName:GetTextWidth(self.modName:GetText()))
        self.modName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.15
        currentWidth = GUIScale(self.mapName:GetTextWidth(self.mapName:GetText()))
        self.mapName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.14
        currentWidth = GUIScale(self.playerCount:GetTextWidth(self.playerCount:GetText()))
        self.playerCount:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        --currentWidth = GUIScaleWidth(26)
        currentWidth = GUIScale(self.hiveskillaverage:GetTextWidth(self.hiveskillaverage:GetText()))
        self.hiveskillaverage:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.05
        currentWidth = GUIScaleWidth(60)
        self.ping:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 2, 0))

        self.storedWidth = width

    end

end

function ServerEntry:UpdateVisibility(minY, maxY, desiredY)

    if not self:GetIsFiltered() then

        if not desiredY then
            desiredY = self:GetBackground():GetPosition().y
        end

        local yPosition = self:GetBackground():GetPosition().y
        local ySize = self:GetBackground():GetSize().y

        local inBoundaries = ((yPosition + ySize) > minY) and yPosition < maxY
        self:SetIsVisible(inBoundaries)

    else
        self:SetIsVisible(false)
    end

end

function ServerEntry:SetBackgroundTexture()
    Print("ServerEntry:SetBackgroundTexture")
end

-- do nothing, save performance, save the world
function ServerEntry:SetCSSClass(cssClassName, updateChildren)
end

function ServerEntry:GetTagName()
    return "serverentry"
end

function ServerEntry:SetId(id)

    assert(type(id) == "number")
    self.rowId = id

end

function ServerEntry:GetId()
    return self.rowId
end
