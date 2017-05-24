function GUIMainMenu:CreatePlayFooter()

    self.playFooter = CreateMenuElement(self.playWindow, "Form")
    self.playFooter:SetCSSClass("serverbrowser_footer_bg")

    self.playFooter.playNow = CreateMenuElement(self.playFooter, "MenuButton")
    self.playFooter.playNow:SetCSSClass("serverbrowser_footer_playnow")
    self.playFooter.playNow:SetText(Locale.ResolveString("PLAY_NOW"))--(Locale.ResolveString("JOIN")) --deceptive
    self.playFooter.playNow:AddEventCallbacks{
        OnClick = function (playNow)
            if self.serverDetailsWindow:GetIsVisible() then
                self:ProcessJoinServer()
            else
                self:OnPlayClicked(true)
            end
        end,
    }

    local divider = CreateMenuElement(self.playFooter, "Image")
    divider:SetCSSClass("serverbrowser_footer_divider_1")

    divider = CreateMenuElement(self.playFooter, "Image")
    divider:SetCSSClass("serverbrowser_footer_divider_2")

    self.playFooter.createServer = CreateMenuElement(self.playFooter, "MenuButton")
    self.playFooter.createServer:SetCSSClass("serverbrowser_footer_createserver")
    self.playFooter.createServer:SetText(Locale.ResolveString("START_SERVER"))
    self.playFooter.createServer:AddEventCallbacks{
        OnClick = function ()
            if not self.createGame:GetIsVisible() then
                self.createGame:SetIsVisible(true)
            else
                self.hostGameButton:OnClick()
            end
        end
    }

    self.playFooter.back = CreateMenuElement(self.playFooter, "MenuButton")
    self.playFooter.back:SetCSSClass("serverbrowser_footer_back")
    self.playFooter.back:SetText(Locale.ResolveString("BACK"))
    self.playFooter.back:AddEventCallbacks{
        OnClick = function ()
            self.playNowWindow:SetIsVisible(false)
            self.playWindow:SetIsVisible(false)
            Matchmaking_LeaveGlobalLobby()
        end
    }
end

--From stickz' mod

function GUIMainMenu:CreateServerListWindow()

    self.highlightServer = CreateMenuElement(self.playWindow:GetContentBox(), "Image")
    self.highlightServer:SetCSSClass("highlight_server")
    self.highlightServer:SetIgnoreEvents(true)
    self.highlightServer:SetIsVisible(false)

    self.blinkingArrow = CreateMenuElement(self.highlightServer, "Image")
    self.blinkingArrow:SetCSSClass("blinking_arrow")
    self.blinkingArrow:GetBackground():SetInheritsParentStencilSettings(false)
    self.blinkingArrow:GetBackground():SetStencilFunc(GUIItem.Always)

    self.selectServer = CreateMenuElement(self.playWindow:GetContentBox(), "Image")
    self.selectServer:SetCSSClass("select_server")
    self.selectServer:SetIsVisible(false)
    self.selectServer:SetIgnoreEvents(true)

    self.serverRowNames = CreateMenuElement(self.playWindow, "Table")
    self.serverList = CreateMenuElement(self.playWindow:GetContentBox(), "ServerList")

    -- Use a hack for now to partially realign the top bar
    local columnClassNames =
    {
        "rank",
        "favorite",
        "private",
        "servername",
        "game",
        "rate", -- map
        "players", --players
	"rate", -- hive
        "rate",
        "ping"
    }

    local rowNames = { { Locale.ResolveString("SERVERBROWSER_RANK"),
						Locale.ResolveString("SERVERBROWSER_FAVORITE"),
						Locale.ResolveString("SERVERBROWSER_PRIVATE"),
						Locale.ResolveString("SERVERBROWSER_NAME"),
						Locale.ResolveString("SERVERBROWSER_GAME"),
						Locale.ResolveString("SERVERBROWSER_MAP"),
						Locale.ResolveString("SERVERBROWSER_PLAYERS"),
						"HIVE", -- To Do: convert this to a translated locale
						Locale.ResolveString("SERVERBROWSER_PERF"),
						Locale.ResolveString("SERVERBROWSER_PING") } }

    local serverList = self.serverList

    --Default sorting
    UpdateSortOrder(7)
    serverList:SetComparator(SortByPlayers, false)

    local entryCallbacks = {
        { OnClick = function() UpdateSortOrder(1) serverList:SetComparator(SortByRating, true) end },
        { OnClick = function() UpdateSortOrder(2) serverList:SetComparator(SortByFavorite) end },
        { OnClick = function() UpdateSortOrder(3) serverList:SetComparator(SortByPrivate) end },
        { OnClick = function() UpdateSortOrder(4) serverList:SetComparator(SortByName) end },
        { OnClick = function() UpdateSortOrder(5) serverList:SetComparator(SortByMode) end },
        { OnClick = function() UpdateSortOrder(6) serverList:SetComparator(SortByMap) end },
        { OnClick = function() UpdateSortOrder(7) serverList:SetComparator(SortByPlayers) end },
	{ OnClick = function() UpdateSortOrder(7) serverList:SetComparator(SortByPlayers) end }, -- To Do: Add hive skill sorting
        { OnClick = function() UpdateSortOrder(8) serverList:SetComparator(SortByPerformance) end },
        { OnClick = function() UpdateSortOrder(9) serverList:SetComparator(SortByPing) end }
    }

    self.serverRowNames:SetCSSClass("server_list_row_names")
    self.serverRowNames:AddCSSClass("server_list_names")
    self.serverRowNames:SetColumnClassNames(columnClassNames)
    self.serverRowNames:SetEntryCallbacks(entryCallbacks)
    self.serverRowNames:SetRowPattern( { SERVERBROWSER_RANK,
						RenderServerNameEntry,
						RenderServerNameEntry,
						RenderServerNameEntry,
						RenderServerNameEntry,
						RenderServerNameEntry,
						RenderServerNameEntry,
						RenderServerNameEntry,
						RenderServerNameEntry,
						RenderServerNameEntry, } )
    self.serverRowNames:SetTableData(rowNames)

    self.playWindow:AddEventCallbacks({
        OnShow = function()
            self.playWindow:ResetSlideBar()
            self:UpdateServerList()
        end
    })

    self:CreateFilterForm()
    self:CreatePlayFooter()

    self.serverTabs = CreateMenuElement(self.playWindow, "ServerTabs", true)
    self.serverTabs:SetCSSClass("main_server_tabs")
    self.serverTabs:SetServerList(self.serverList)

end
