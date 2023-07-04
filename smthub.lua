        repeat  task.wait() until game:IsLoaded()
        if game.PlaceId == 8304191830 then
            repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
            repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("collection"):FindFirstChild("grid"):FindFirstChild("List"):FindFirstChild("Outer"):FindFirstChild("UnitFrames")
        else
            repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
            game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
            repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
        end

        local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
        local repo2 = 'https://raw.githubusercontent.com/smtxtx1/smthubzx/main/'

        local Library = loadstring(game:HttpGet(repo2 .. 'LinoriaUI.lua'))()
        local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
        local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
        local plr = game:GetService("Players").LocalPlayer
        local exec = tostring(identifyexecutor())
        local Window = Library:CreateWindow({
            Title = 'SMTHUB | Anime Adventures',
            Center = true,
            AutoShow = true,
            TabPadding = 8,
            MenuFadeTime = 0,

        })
        local a = 'SMTHUB' -- Paste Name
        local b = game:GetService('Players').LocalPlayer.Name .. '_AnimeAdventures.json'
        local Settings = {
            Worlds = 0,
            Levels = 0,
            LevelsDrop = {},
            WorldsDrop = {},
            upgunit1 = 0,
            upgunit2 = 0,
            upgunit3 = 0,
            upgunit4 = 0,
            upgunit5 = 0,
            upgunit6 = 0,
            upgwave1 = 0,
            upgwave2 = 0,
            upgwave3 = 0,
            upgwave4 = 0,
            upgwave5 = 0,
            upgwave6 = 0,
            MenuKeybind = "End",
            autoleaveWaveX = 0,
            AutoLeaveWave = false,
            OptionsPlace = 0,
            autofarm = false,
            AutoPlaceUnit2 = false,
            KeyPicker = "G",
            KeyPicker2 = "H",
            KeyPicker3 = "J",
            lagsec = 0,
            lagstr = 0,
            lager = 0,
            lager2 = 0,
            lagtoggle = false,
            Pinglimiter = 0,
        }

        function saveSettings()
            local HttpService = game:GetService('HttpService')
            local folderPath = a .. "/"
            local filePath = folderPath .. b

            if not isfolder(folderPath) then
                makefolder(folderPath)
            end

            writefile(filePath, HttpService:JSONEncode(Settings))
        end

        function ReadSetting()
            local HttpService = game:GetService('HttpService')
            local folderPath = a .. "/"
            local filePath = folderPath .. b

            if not isfile(filePath) then
                saveSettings()
                return Settings
            end

            local success, decodedSettings = pcall(function()
                return HttpService:JSONDecode(readfile(filePath))
            end)

            if success and type(decodedSettings) == "table" then
                return decodedSettings
            else
                warn("Error reading settings file. Resetting settings to default.")
                saveSettings()
                return Settings
            end
        end

        Settings = ReadSetting()
        function antiafk()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                game:GetService("Players").LocalPlayer.Idled:connect(function()
                    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                end)
                game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
            end)
        end
        antiafk()
        local Tabs = {
            Main = Window:AddTab('Main'),
            ['LAG SWITCH'] = Window:AddTab('LAG & INF Range Settings'),
            ['UI Settings'] = Window:AddTab('Settings'),
            
        }
        local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

        MenuGroup:AddButton('Unload', function() Library:Unload() end)
        MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = Settings.MenuKeybind, NoUI = true, Text = 'Menu keybind' })

        Options.MenuKeybind:OnChanged(function() print(Options.MenuKeybind.Value) Settings.MenuKeybind = Options.MenuKeybind.Value saveSettings() end)

        Library.ToggleKeybind = Options.MenuKeybind


        local WorldsName

        local uuidUnits = {}
        local UnitSkillDrops = {}
        local MapSelected
        local infUnitId1
        local infUnitId2
        local infUnitId3
        game.Players.LocalPlayer.PlayerGui.MessageGui.Enabled = false



        function AddWorlds()
            if #Settings.WorldsDrop >1 then
                Settings.WorldsDrop = {}
                end
            
            for i, v in pairs(game:GetService("ReplicatedStorage").src.Data.Worlds:GetChildren()) do
                if v:IsA("ModuleScript") then
                    local allmodule = require(v)
                    for _, child in pairs(allmodule) do
                        print(_, child.name)
                        table.insert(Settings.WorldsDrop, child.name)
                    end
                end
            end
        end

        AddWorlds()

        function AutosUnitAdd()
            for i, v in pairs(game:GetService("ReplicatedStorage").src.Data.Units:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    local getunit = require(v)
                    for key1, UnitData in pairs(getunit) do
                        if type(UnitData) == "table" then
                            if UnitData.active_attack then
                                table.insert(UnitSkillDrops, UnitData.name)
                            end
                            if UnitData.id then
                                if UnitData.upgrade then
                                    for key2, upgunit in pairs(UnitData.upgrade) do
                                        for key3, getunit in pairs(upgunit) do
                                            if key3 == "active_attack" then
                                                table.insert(UnitSkillDrops, UnitData.name)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        AutosUnitAdd()
        function LevelSelection()
            if #Settings.LevelsDrop >1 then
            Settings.LevelsDrop = {}
            end
            for i, v in pairs(game:GetService("ReplicatedStorage").src.Data.Levels:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    allLevel = require(v)
                    for _, childLevels in pairs(allLevel) do
                        if type(childLevels) == "table" and childLevels.Name ~= "template" then
                            if childLevels.world == tostring(MapSelected) then
                                if childLevels.name then
                                    table.insert(Settings.LevelsDrop, childLevels.name)
                                    saveSettings()
                                end
                            end
                        end
                    end
                end
            end
            Options.Levels:SetValues(Settings.LevelsDrop)
        end
        function placeAny()
            local services = require(game.ReplicatedStorage.src.Loader)
            local placement_service = services.load_client_service(script, "PlacementServiceClient")
            
                task.spawn(function()
                    while task.wait() do
                        placement_service.can_place = true
                    end
                end)
            end
        function placeunittwin() 
            if game.Workspace:WaitForChild("_UNITS") then
            for i, v in ipairs(game:GetService("Workspace")["_UNITS"]:GetChildren()) do
                repeat task.wait() until v:WaitForChild("_stats")
                if v.Name == name and tostring(v["_stats"].player.Value) == game.Players.LocalPlayer.Name and v.Name:FindFirstChild("_hitbox") then
                    v:Destroy() end
                    end
                end
            end

            local UnitDrops = {}

        function UnitSelection()
                UnitDrops = {}
                local UnitsModule = game:GetService("ReplicatedStorage").src.Data.Units
                local NameUnits = {}  -- Store all NameUnits in a table
                if #UnitDrops < 1 then
                    for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui["spawn_units"].Lives.Frame.Units:GetChildren()) do
                        if v:IsA("ImageButton") then
                            for _, SpawnUnit in pairs(v.Main.petimage.WorldModel:GetChildren()) do
                                local unitName = SpawnUnit.Name
                                if string.find(unitName, ":") then
                                    unitName = string.gsub(unitName, ":%g+", "") -- Remove ":" and everything after it
                                end
                                table.insert(NameUnits, unitName) -- Store each NameUnit in the table
                            end
                        end
                    end
                    
            
                for _, v in pairs(UnitsModule:GetDescendants()) do
                    if v:IsA("ModuleScript") then
                        local UnitsChild = require(v)
                        for key, UnitsData in pairs(UnitsChild) do
                            pcall(function()
                                for _, NameUnit in ipairs(NameUnits) do
                                    if UnitsData.id == NameUnit then
                                        table.insert(UnitDrops,UnitsData.name)
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
            
            UnitSelection()

        function LevelsJoin()
            for i, v in pairs(game:GetService("ReplicatedStorage").src.Data.Levels:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    allLevel = require(v)
                    for _, childLevels in pairs(allLevel) do
                        if type(childLevels) == "table" and childLevels.Name ~= "template" then
                            if childLevels.world == tostring(MapSelected) then
                                if childLevels.name == LevelsXX then
                                    MapID = childLevels.id
                                    diff = "Normal"
                                end
                                if childLevels.name == "Infinite Mode" then
                                    diff = "Hard"
                                end
                            end
                        end
                    end
                end
            end
        end
            

        local TabBox = Tabs.Main:AddLeftTabbox()

        local Tab1 = TabBox:AddTab('Story')
        function WorldsSelection()
            for i , v in pairs(game:GetService("ReplicatedStorage").src.Data.Worlds:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    allmodule = require(v)
                    for _ , child in pairs(allmodule) do
                        if child.name == tostring(WorldsName) then
                            MapSelected =  _

                        end
                    end
                end
            end
        end

        local diff
        local MapID

        Tab1:AddDropdown('Worlds', {
            Values = Settings.WorldsDrop,
            Default = Settings.Worlds,
            Multi = false,
            Text = 'Select Worlds',
            Tooltip = 'Select World Before Levels',
        })
        Tab1:AddDropdown('Levels', {
            Values = Settings.LevelsDrop,
            Multi = false,
            Text = 'Select Level',
            Default = Settings.Levels, -- Set the default based on Settings.Levels index
            Callback = function(Value)
                for i, v in pairs(game:GetService("ReplicatedStorage").src.Data.Levels:GetDescendants()) do
                    if v:IsA("ModuleScript") then
                        allLevel = require(v)
                        for _, childLevels in pairs(allLevel) do
                            if type(childLevels) == "table" and childLevels.Name ~= "template" then
                                if childLevels.world == tostring(MapSelected) then
                                    if childLevels.name == Value then
                                        MapID = childLevels.id
                                        diff = "Normal"
                                    end
                                    if childLevels.name == "Infinite Mode" then
                                        diff = "Hard"
                                    end
                                end
                            end
                        end
                    end
                end
            end
        })



        waitthis = Options.Worlds:OnChanged(function(Value)
            local index = nil
            WorldsName = Value
            WorldsSelection()
            for i, v in ipairs(Settings.WorldsDrop) do
                if v == Value then
                    index = i
                    break
                end
            end
            print(index)
            if index then
                Settings.Worlds = index
            end
            saveSettings()
            LevelSelection()
        end)


        Options.Levels:OnChanged(function(Value)
            local index
            for i, v in ipairs(Settings.LevelsDrop) do
                if v == Value then
                    index = i
                    break
                end
            end
            print(index)
            if index then
            Settings.Levels = index
            end
            saveSettings() 
            for i, v in pairs(game:GetService("ReplicatedStorage").src.Data.Levels:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    allLevel = require(v)
                    for _, childLevels in pairs(allLevel) do
                        if type(childLevels) == "table" and childLevels.Name ~= "template" then
                            if childLevels.world == tostring(MapSelected) then
                                if childLevels.name == Value then
                                    MapID = childLevels.id
                                    diff = "Normal"
                                end
                                if childLevels.name == "Infinite Mode" then
                                    diff = "Hard"
                                end
                            end
                        end
                    end
                end
            end
        end)

        local infCFrame = CFrame.new(0, 0, 0)
        local infCFrame2 = CFrame.new(0, 0, 0)
        local infCFrame3 = CFrame.new(0, 0, 0)

        local function createPart()
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Position = Vector3.new(0, 1.5, 0)
            
            part.Parent = workspace
            part.Material = Enum.Material.Neon
            
            local mouse = game.Players.LocalPlayer:GetMouse()
            local partClicked = false
            
            mouse.Move:Connect(function()
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
                raycastParams.FilterDescendantsInstances = {workspace["_terrain"]}
            
                local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 100, raycastParams)
                if raycastResult then
                    part.CFrame = CFrame.new(raycastResult.Position) + Vector3.new(0, 2, 0) -- added 2 to the y-coordinate to move the part above the ground
                end 
            end)
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = game.Players.LocalPlayer.PlayerGui
            
            local textButton = Instance.new("TextButton")
            textButton.Text = ""
            textButton.Size = UDim2.new(1, 0, 1, 0)
            textButton.BackgroundColor3 = Color3.new(0, 0, 0)
            textButton.BackgroundTransparency = 1
            textButton.Parent = screenGui
            part.Anchored = true
            textButton.MouseButton1Click:Connect(function()
                partClicked = true
            end)
            
            while not partClicked do
                wait()
            end
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            raycastParams.FilterDescendantsInstances = {workspace["_terrain"]}
            
            local raycastResult = workspace:Raycast(part.Position, Vector3.new(0, -4, 0), raycastParams) -- changed direction to point upwards
            if raycastResult then
                Library:Notify('Position is Selected')
                infCFrame = CFrame.new(raycastResult.Position)
            else
                Library:Notify("No ground detected")
            end
            
            part:Destroy()
            screenGui:Destroy()
            wait()
        end
        local function  createPart2()
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Position = Vector3.new(0, 1.5, 0)
            
            part.Parent = workspace
            part.Material = Enum.Material.Neon
            
            local mouse = game.Players.LocalPlayer:GetMouse()
            local partClicked = false
            
            mouse.Move:Connect(function()
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
                raycastParams.FilterDescendantsInstances = {workspace["_terrain"]}
            
                local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 100, raycastParams)
                if raycastResult then
                    part.CFrame = CFrame.new(raycastResult.Position) + Vector3.new(0, 2, 0) -- added 2 to the y-coordinate to move the part above the ground
                end 
            end)
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = game.Players.LocalPlayer.PlayerGui
            
            local textButton = Instance.new("TextButton")
            textButton.Text = ""
            textButton.Size = UDim2.new(1, 0, 1, 0)
            textButton.BackgroundColor3 = Color3.new(0, 0, 0)
            textButton.BackgroundTransparency = 1
            textButton.Parent = screenGui
            part.Anchored = true
            textButton.MouseButton1Click:Connect(function()
                partClicked = true
            end)
            
            while not partClicked do
                wait()
            end
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            raycastParams.FilterDescendantsInstances = {workspace["_terrain"]}
            
            local raycastResult = workspace:Raycast(part.Position, Vector3.new(0, -4, 0), raycastParams) -- changed direction to point upwards
            if raycastResult then
                Library:Notify('Position is Selected')
                infCFrame2 = CFrame.new(raycastResult.Position)
            else
                Library:Notify("No ground detected")
            end
            
            part:Destroy()
            screenGui:Destroy()
            wait()
        end
        local function createPart3()
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Position = Vector3.new(0, 1.5, 0)
            
            part.Parent = workspace
            part.Material = Enum.Material.Neon
            
            local mouse = game.Players.LocalPlayer:GetMouse()
            local partClicked = false
            
            mouse.Move:Connect(function()
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
                raycastParams.FilterDescendantsInstances = {workspace["_terrain"]}
            
                local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 100, raycastParams)
                if raycastResult then
                    part.CFrame = CFrame.new(raycastResult.Position) + Vector3.new(0, 2, 0) -- added 2 to the y-coordinate to move the part above the ground
                end 
            end)
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = game.Players.LocalPlayer.PlayerGui
            
            local textButton = Instance.new("TextButton")
            textButton.Text = ""
            textButton.Size = UDim2.new(1, 0, 1, 0)
            textButton.BackgroundColor3 = Color3.new(0, 0, 0)
            textButton.BackgroundTransparency = 1
            textButton.Parent = screenGui
            part.Anchored = true
            textButton.MouseButton1Click:Connect(function()
                partClicked = true
            end)
            
            while not partClicked do
                wait()
            end
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            raycastParams.FilterDescendantsInstances = {workspace["_terrain"]}
            
            local raycastResult = workspace:Raycast(part.Position, Vector3.new(0, -4, 0), raycastParams) -- changed direction to point upwards
            if raycastResult then
                Library:Notify('Position is Selected')
                infCFrame3 = CFrame.new(raycastResult.Position)
            else
                Library:Notify("No ground detected")
            end
            
            part:Destroy()
            screenGui:Destroy()
            wait()
        end

        local function updateUnits()
            for _, unit in ipairs(game.Workspace._UNITS:GetChildren()) do
                if Toggles.manualposi.Value == true then
                    local targetCFrame
                    if unit.Name == infUnitId1 then
                        targetCFrame = infCFrame * CFrame.new(0, 1.5, 0)
                    elseif unit.Name == infUnitId2 then
                        targetCFrame = infCFrame2 * CFrame.new(0, 1.5, 0) -- Modify this part for infUnitId3 as needed
                    elseif unit.Name == infUnitId3 then
                        targetCFrame = infCFrame3 * CFrame.new(0, 1.5, 0) -- Modify this part for infUnitId3 as needed
                    end
                    
                    if targetCFrame then
                        unit.HumanoidRootPart.CFrame = targetCFrame 
                        unit._shadow.CFrame = targetCFrame
                        unit._hitbox.CFrame = targetCFrame
                        if unit:FindFirstChild("Range") then
                            unit.Range.CFrame = targetCFrame
                            unit.range_sphere.CFrame = targetCFrame
                        end
                    end
                end
            end
        end

        local function toggleCallback(bool)
            if bool then
                game:GetService("RunService").RenderStepped:Connect(updateUnits)
            else
                game:GetService("RunService").RenderStepped:Disconnect(updateUnits)
            end
        end

        local Units = {}
        local Lane = {}

        function Check()
            if #uuidUnits <1 then 
                uuidUnits = {}
            end
            local DataUnits = require(game:GetService("ReplicatedStorage").src.Data.Units)
            for i, v in pairs(getgenv().profile_data.equipped_units) do
                if DataUnits[v.unit_id] and v.equipped_slot then
                    table.insert(uuidUnits, v.uuid)
                    print(v.uuid)
                end
            end
        end


        function InfCastle()
            if game.PlaceId == 8304191830 then
                while Toggles.infcastleAT.Value == true do
                        local FurthestRoom = game:GetService("Players").LocalPlayer.PlayerGui.InfiniteTowerUI.InfiniteLeaderboard.Ranking.Wrapper.Frame.FurthestRoom.V
                        local CurrentRoom = FurthestRoom.Text

                        local args = {
                            [1] = tonumber(CurrentRoom)
                        }
                        game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower:InvokeServer(unpack(args))
                        wait()
                        Library:Notify('Joining Infinite Castle Room: '..CurrentRoom)
                        break
                end
            end
        end

local http = game:GetService("HttpService")
local url = "https://discord.com/api/webhooks/1113239626354794536/aS4oQVMxQkGZ_mNZUJ7YTW44-6kwDHiUZZx9PczdLJqYZnxPrF-YSJlcEk4GZ3ZJ1bLV" -- Replace with your webhook URL

local function SendWebhook()
    local currentINF = game:GetService("Workspace"):FindFirstChild("_MAP_CONFIG"):FindFirstChild("GetLevelData"):InvokeServer()["name"]
    totaltime =  ResultHolder:FindFirstChild("Middle"):FindFirstChild("Timer").Text
    totalwaves = ResultHolder:FindFirstChild("Middle"):FindFirstChild("WavesCompleted").Text
    result = ResultHolder.Title.Text
    if result == "VICTORY" then result = "VICTORY" end
    if result == "DEFEAT" then result = "DEFEAT" end
    local data = {
        ["embeds"] = {
            {
                ["title"] = "**SMT-HUB**",
                ["description"] = "Username: **" .. game.Players.LocalPlayer.Name .. "**\n:"..currentINF,

                ["type"] = "rich",
                ["color"] = tonumber(0x7269da),
                ["image"] = {
                    ["url"] = "http://www.roblox.com/Thumbs/Avatar.ashx?x=150&y=150&Format=Png&username=" ..
                               tostring(game:GetService("Players").LocalPlayer.Name)
                }
            }
        }
    }
    
    local jsonData = http:JSONEncode(data)
    
    local headers = {
        ["content-type"] = "application/json"
    }
    
    local requestFunction = http_request or request or HttpPost or syn.request
    local requestParams = {
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = jsonData
    }
    
    requestFunction(requestParams)
end



        Tab1:AddToggle('autofarm2', {
            Text = 'Auto Farm',
            Default = Settings.autofarm,
        })
        Toggles.autofarm2:OnChanged(function(bool) print(bool) Settings.autofarm = bool saveSettings() end)
        
        local Tab2 = TabBox:AddTab('Infinite Castle')
        task.spawn(function()
            local FurthestRoom = game:GetService("Players").LocalPlayer.PlayerGui.InfiniteTowerUI.InfiniteLeaderboard.Ranking.Wrapper.Frame.FurthestRoom.V
            local CurrentRoom = FurthestRoom.Text
            if game.PlaceId == 8304191830 then
            Tab2:AddLabel('Your Room: '..CurrentRoom)
            else
                local currentINF = game:GetService("Workspace"):FindFirstChild("_MAP_CONFIG"):FindFirstChild("GetLevelData"):InvokeServer()["name"]
            Tab2:AddLabel(currentINF)
            end
        end)

        Tab2:AddToggle('infcastleAT',{
            Text = 'Auto Infinite Castle',
            Default = Settings.infcastleAT,
        })
        Toggles.infcastleAT:OnChanged(function(bool)
            print(bool) 
            Settings.infcastleAT = bool
            saveSettings() 
            task.spawn(function()
                InfCastle()
                wait()   
            end)
            end)

            Tab2:AddToggle('autonext', {
            Text = 'Auto Next Room',
            Default = Settings.autonext,
        })

        local section3 = Tabs.Main:AddLeftTabbox()
        local Tabsection3 = section3:AddTab('Auto')
        Tabsection3:AddToggle('autoreplay', {
            Text = 'Auto Retry',
            Default = Settings.autoreplay,
        })
        Toggles.autoreplay:OnChanged(function(bool) print(bool) Settings.autoreplay = bool saveSettings() end)
        function AutoReplay()
            print("AutoReplay Worked")
            task.spawn(function()
                local GameFinished = game:GetService("Workspace"):WaitForChild("_DATA"):WaitForChild("GameFinished")
                    GameFinished:GetPropertyChangedSignal("Value"):Connect(function()
                        if GameFinished.Value == true then
                        repeat task.wait() until  game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI.Enabled == true
                        print("Pressed Replay Worked")
                        local a={[1]="replay"} game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
                        end
                    end)
                end)
        end

        function AutoNext()
            task.spawn(function()
                local GameFinished = game:GetService("Workspace"):WaitForChild("_DATA"):WaitForChild("GameFinished")
                    GameFinished:GetPropertyChangedSignal("Value"):Connect(function()
                        if GameFinished.Value == true then
                            local currentINF2 = game:GetService("Workspace"):FindFirstChild("_MAP_CONFIG"):FindFirstChild("GetLevelData"):InvokeServer()["name"]
                            local numericalPart = currentINF2:match("%d+") -- Extract the numerical part from the string
                            local incrementedValue = tonumber(numericalPart) + 1 -- Convert to number and increment by 1
                            local updatedINF = currentINF2:gsub("%d+", incrementedValue) 
                        repeat task.wait() until  game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI.Enabled == true
                        local a={[1]="NextRetry"} 
                        game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower_from_game:InvokeServer(unpack(a))
                        Library:Notify('Joining '..updatedINF)
                        end
                    end)
                end)
            end

        Toggles.autonext:OnChanged(function(bool) 
            print(bool) 
            Settings.autonext = bool 
            saveSettings() 
            wait()
            if Toggles.autonext.Value == true then
                task.spawn(function()
                    AutoNext()
                end)
            end
        end)
        Toggles.autoreplay:OnChanged(function(bool)
            print(bool)
            Settings.autoreplay = bool
            saveSettings()
                if Toggles.autoreplay.Value == true then 
                    task.spawn(function()
                        AutoReplay()
                    end)
                end
            end)

        function AutoJoinRoom()
            while wait() do
                if Toggles.autofarm2.Value == true then
                    if game.PlaceId == 8304191830 then
                        pcall(function()
                            for i, v in pairs(game:GetService("Workspace")["_LOBBIES"].Story:GetDescendants()) do
                                if v.Name == "Owner" and v.Value == nil then
                                    local args = { [1] = tostring(v.Parent.Name) }
                                    game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))

                                    task.wait()

                                    local args = {
                                        [1] = tostring(v.Parent.Name), -- Lobby 
                                        [2] = MapID, -- World/Level
                                        [3] = true, -- Friends Only or not
                                        [4] = diff }

                                    game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))

                                    local args = { [1] =tostring(v.Parent.Name) }
                                    game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
                                    getgenv().door = v.Parent.Name print(v.Parent.Name) --v.Parent:GetFullName()
                                    break
                                end
                            end
                        end)
                    end
                end 
            end
        end

        task.spawn(function()
        AutoJoinRoom()
        end)



        Tabsection3:AddToggle('AutoPlaceUnit2', {
            Text = 'Auto Place',
            Default = Settings.AutoPlaceUnit2,
            Callback = toggleCallback2
        })
        Toggles.AutoPlaceUnit2:OnChanged(function(bool) print(bool) Settings.AutoPlaceUnit2 = bool saveSettings() end)
        Tabsection3:AddDropdown('OptionsPlace', {
            Values = {'Place Front','Place Mid'},
            Default = Settings.OptionsPlace,
            Multi = false,
            Text = 'Place Method',
        })
        Options.OptionsPlace:OnChanged(function(Value)
            local index
            for i, v in ipairs({'Place Front','Place Mid'}) do
                if v == Value then
                    index = i
                    break
                end
            end
            print(index)
            if index then
            Settings.OptionsPlace = index
            end
                saveSettings()
            end)





        Tabsection3:AddInput('autoleaveWaveX', {
            Default = Settings.autoleaveWaveX,
            Numeric = true,
            Finished = true,
            Text = 'Leave When Wave: ',
            Tooltip = 'Press Enter',
            Placeholder = 'Press Enter',
        })

        Options.autoleaveWaveX:OnChanged(function(value)
            Settings.autoleaveWaveX = value
            saveSettings()
        end)

        Tabsection3:AddToggle('AutoLeaveWave', {
            Text = 'Auto Leave',
            Default = Settings.AutoLeaveWave,
        })

        local function leaveWave()
            if game.PlaceId == 8304191830 then
                wait()
            else
                local continueWave = true -- Flag variable to control the loop
                while Settings.AutoLeaveWave and continueWave do
                    wait()
                    local autoleaveWaveX = Options.autoleaveWaveX.Value
                    local WaveX = game:GetService("Workspace")["_wave_num"].Value
                    if WaveX >= tonumber(autoleaveWaveX) then
                        continueWave = false -- Set flag to false to break out of the loop
                        wait()
                        game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
                    end
                end
            end

            -- Code to be executed after leaving the wave
            -- Add your code here
        end

        local OtherOption = Tabs.Main:AddRightTabbox()
        local other1 = OtherOption:AddTab('Misc')
        other1:AddToggle('Anywhere', {
            Text = 'Place Anywhere',
            Default = Settings.Anywhere, -- Default value (true / false)
        })
        other1:AddToggle('DeleteMap',{
            Text = 'Delete Map',
            Default = Settings.DeleteMap,
        })
        other1:AddToggle('DeleteHill',{
            Text = 'Delete Hill',
            Default = Settings.DeleteHill,
        })

        other1:AddButton('Lobby',function() game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer) end)
        Toggles.Anywhere:OnChanged(function(bool) print(bool) Settings.Anywhere = bool saveSettings() end)
        task.spawn(function()
        placeAny()
        placeunittwin()
        end)

        Toggles.DeleteMap:OnChanged(function(bool)
            Settings.DeleteMap = bool
            saveSettings()
        if bool == true then
            repeat wait() until game:IsLoaded()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "terrain" then
                    for _, child in pairs(v:GetDescendants()) do
                        child:Destroy()
                    end
                end
                
                if v.Name == "_map" then
                    v:Destroy()
                end
            end

            end
        end
        )
        Toggles.DeleteHill:OnChanged(function(bool)
            Settings.DeleteHill = bool
            saveSettings()
                if bool == true then
                    repeat wait() until game:IsLoaded()
                    for _, v in ipairs(workspace:GetDescendants()) do                    
                        if v.Name == "hill" then 
                            v:Destroy()
                        end
                    end
                end
            end
            )


        local OtherOption2 = Tabs.Main:AddRightTabbox()
        local other2 = OtherOption2:AddTab('Auto Upgrade')
        local other3 = OtherOption2:AddTab('Configs Upgrade')

        other2:AddToggle('autoupgs', {
            Text = 'Auto Upgrade Units',
            Default = Settings.autoupgs, -- Default value (true / false)
        })
        Toggles.autoupgs:OnChanged(function(bool) print(bool) Settings.autoupgs = bool saveSettings() end)



        other3:AddSlider('upgunit1', {
            Text = 'Unit 1',
            Default = Settings.upgunit1,
            Min = 0,
            Max = 15,
            Rounding = 0,
            Compact = true,
        })
        Options.upgunit1:OnChanged(function(Value) print(Value) Settings.upgunit1 = Value saveSettings() end)
        other3:AddSlider('upgwave1', {
            Text = 'Upgrade Wave:',
            Default = Settings.upgwave1,
            Min = 0,
            Max = 50,
            Rounding = 0,
            Compact = true,
        })
        Options.upgwave1:OnChanged(function(Value) print(Value) Settings.upgwave1 = Value saveSettings() end)
        other3:AddDivider()
        other3:AddSlider('upgunit2', {
            Text = 'Unit 2',
            Default = Settings.upgunit2,
            Min = 0,
            Max = 15,
            Rounding = 0,
            Compact = true,
        })
        Options.upgunit2:OnChanged(function(Value) print(Value) Settings.upgunit2 = Value saveSettings() end)
        other3:AddSlider('upgwave2', {
            Text = 'Upgrade Wave:',
            Default = Settings.upgwave2,
            Min = 0,
            Max = 50,
            Rounding = 0,
            Compact = true,
        })
        Options.upgwave2:OnChanged(function(Value) print(Value) Settings.upgwave2 = Value saveSettings() end)
        other3:AddDivider()
        other3:AddSlider('upgunit3', {
            Text = 'Unit 3',
            Default = Settings.upgunit3,
            Min = 0,
            Max = 15,
            Rounding = 0,
            Compact = true,
        })
        Options.upgunit3:OnChanged(function(Value) print(Value) Settings.upgunit3 = Value saveSettings() end)
        other3:AddSlider('upgwave3', {
            Text = 'Upgrade Wave:',
            Default = Settings.upgwave3,
            Min = 0,
            Max = 50,
            Rounding = 0,
            Compact = true,
        })
        Options.upgwave3:OnChanged(function(Value) print(Value) Settings.upgwave3 = Value saveSettings() end)
        other3:AddDivider()
        other3:AddSlider('upgunit4', {
            Text = 'Unit 4',
            Default = Settings.upgunit4,
            Min = 0,
            Max = 15,
            Rounding = 0,
            Compact = true,
        })
        Options.upgunit4:OnChanged(function(Value) print(Value) Settings.upgunit4 = Value saveSettings() end)
        other3:AddSlider('upgwave4', {
            Text = 'Upgrade Wave:',
            Default = Settings.upgwave4,
            Min = 0,
            Max = 50,
            Rounding = 0,
            Compact = true,
        })
        Options.upgwave4:OnChanged(function(Value) print(Value) Settings.upgwave4 = Value saveSettings() end)
        other3:AddDivider()
        other3:AddSlider('upgunit5', {
            Text = 'Unit 5',
            Default = Settings.upgunit5,
            Min = 0,
            Max = 15,
            Rounding = 0,
            Compact = true,
        })
        Options.upgunit5:OnChanged(function(Value) print(Value) Settings.upgunit5 = Value saveSettings() end)
        other3:AddSlider('upgwave5', {
            Text = 'Upgrade Wave:',
            Default = Settings.upgwave5,
            Min = 0,
            Max = 50,
            Rounding = 0,
            Compact = true,
        })
        Options.upgwave5:OnChanged(function(Value) print(Value) Settings.upgwave5 = Value saveSettings() end)
        other3:AddDivider()
        other3:AddSlider('upgunit6', {
            Text = 'Unit 6',
            Default = Settings.upgunit6,
            Min = 0,
            Max = 15,
            Rounding = 0,
            Compact = true,
        })
        Options.upgunit6:OnChanged(function(Value) print(Value) Settings.upgunit6 = Value saveSettings() end)
        other3:AddSlider('upgwave6', {
            Text = 'Upgrade Wave:',
            Default = Settings.upgwave6,
            Min = 0,
            Max = 50,
            Rounding = 0,
            Compact = true,
        })
        Options.upgwave6:OnChanged(function(Value) print(Value) Settings.upgwave6 = Value saveSettings() end)
        function UpgradeCaps()
            if game.PlaceId == 8304191830 then
                wait()
            else
                repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
            end
            
            while true do
                wait()
                repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
                
                if Toggles.autoupgs.Value == true then
                    wait()
                    
                    local units = game:GetService("Players").LocalPlayer.PlayerGui["spawn_units"].Lives.Frame.Units:GetChildren()
                    pcall(function()
                        for _, v in ipairs(units) do
                            if v:IsA("ImageButton") then
                                local unitName = tonumber(v.Name)
                                if unitName then
                                    local unitChildren = v.Main.petimage.WorldModel:GetChildren()
                                    for _, unit in ipairs(unitChildren) do
                                        if unit.Name then
                                            local waveKey = "upgwave" .. unitName
                                            local unitKey = "upgunit" .. unitName
                                            
                                            local upgradeValue = Options[unitKey].Value
                                            local waveValue = Options[waveKey].Value
                                            
                                            for _, PlacedUnit in ipairs(game:GetService("Workspace")["_UNITS"]:GetChildren()) do
                                                if PlacedUnit.Name == unit.Name then
                                                    local currentWave = game:GetService("Workspace")["_wave_num"].Value
                                                    
                                                    if currentWave >= waveValue and PlacedUnit._stats.upgrade.Value < upgradeValue then
                                                        game:GetService("ReplicatedStorage").endpoints.client_to_server.upgrade_unit_ingame:InvokeServer(PlacedUnit)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end



        task.spawn(function()
        UpgradeCaps()
        end)

        getgenv().profile_data = { equipped_units = {} }

        repeat
            wait()
            for i, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "xp") then
                    table.insert(getgenv().profile_data.equipped_units, v)
                end
            end
        until #getgenv().profile_data.equipped_units > 0

        local infbox = Tabs['LAG SWITCH']:AddRightTabbox()
        local infsection = infbox:AddTab('Inf Range')
        local infsection2 = infbox:AddTab('Move Position')



        function getUnitIdByName(name)
            name = tostring(name)  -- Ensure name is a string
            local UnitsModule = game:GetService("ReplicatedStorage").src.Data.Units
            for _, v in pairs(UnitsModule:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    local UnitsChild = require(v)
                    if type(UnitsChild) == "table" then
                        for key, UnitsData in pairs(UnitsChild) do
                            if type(UnitsData) == "table" and UnitsData.name == name then
                                for i, unit in pairs(game:GetService("Players").LocalPlayer.PlayerGui["spawn_units"].Lives.Frame.Units:GetDescendants()) do
                                    if string.find(unit.Name,UnitsData.id ) then
                                        print(unit.Name)
                                        return unit.Name
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return nil
        end


        function coneinfrange()
            pcall(function()
                local final_position = game:GetService("Workspace")._BASES.pve.LANES[1].final.Position
                local units = game.Workspace._UNITS:GetChildren()
                
                for _, unit in ipairs(units) do
                    local unitId = unit.Name
                    if unitId == infUnitId1 or unitId == infUnitId2 or unitId == infUnitId3 then
                        local closestUnit = nil
                        local closestDistance = math.huge
                        local closestToFinal = math.huge
                        
                        for _, otherUnit in ipairs(units) do 
                            if otherUnit._stats.player.Value == nil and otherUnit ~= unit then
                                local distance = (unit.HumanoidRootPart.Position - otherUnit.HumanoidRootPart.Position).Magnitude
                                local distToFinal = (otherUnit.HumanoidRootPart.Position - final_position).Magnitude
                                if distToFinal < closestToFinal or (distToFinal == closestToFinal and distance < closestDistance) then
                                    closestToFinal = distToFinal
                                    closestDistance = distance
                                    closestUnit = otherUnit
                                end
                            end
                        end
                        
                        local targetPosition = final_position
                        if closestUnit then
                            local offset = closestUnit.HumanoidRootPart.CFrame.lookVector * tonumber(Options.RangeInf.Value)
                            targetPosition = closestUnit.HumanoidRootPart.Position + offset 
                        end
                        
                        if targetPosition ~= final_position then
                            local renderSteppedConnection
                            renderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                                unit.HumanoidRootPart.CFrame = CFrame.new(targetPosition) * CFrame.fromEulerAnglesYXZ(0, math.rad(180), 0) 
                                if unit:FindFirstChild("Range") then
                                unit.Range.CFrame = CFrame.new(targetPosition) * CFrame.fromEulerAnglesYXZ(0, math.rad(180), 0)
                                end
                                renderSteppedConnection:Disconnect()
                            end)
                        end
                    end
                end
            end)
            
            game:GetService("RunService").RenderStepped:Wait()

        end





        infsection:AddToggle('infrange',{
            Text = 'Inf Range',
            Default = false,
            Callback = function(bool) 
            while Toggles.infrange.Value == true do
                coneinfrange()
                end
            end
            })
            infsection:AddSlider('RangeInf', {
                Text = 'Range From Enemy',
                Default = 0,
                Min = 0,
                Max = 10,
                Rounding = 1,
                Compact = false,
            })
        infsection:AddDropdown('infunit', {
            Values = UnitDrops,
            Default = 0,
            Multi = false,
            Text = 'Unit 1',
            Callback = function(Value)
                infUnitId1 = getUnitIdByName(Value)
            end
        })

        infsection:AddDropdown('infunit2', {
            Values = UnitDrops,
            Default = 0,
            Multi = false,
            Text = 'Unit 2',
            Callback = function(Value)
                infUnitId2 = getUnitIdByName(Value)
            end
        })

        infsection:AddDropdown('infunit3', {
            Values = UnitDrops,
            Default = 0,
            Multi = false,
            Text = 'Unit 3',
            Callback = function(Value)
                infUnitId3 = getUnitIdByName(Value)
            end
        })
        infsection:AddButton('Refresh Units',function()
            Options.infunit:SetValue(nil)
            Options.infunit2:SetValue(nil)
            Options.infunit3:SetValue(nil)
        end)
        infsection2:AddToggle('manualposi',{
            Text = 'Manual Position',
            Default = false,
            Callback = toggleCallback
        })

        infsection2:AddLabel('Unit 1'):AddKeyPicker('KeyPicker', {

            Default = Settings.KeyPicker, 
            SyncToggleState = false,
            Mode = 'Toggle', -- Modes: Always, Toggle, Hold
            Text = 'Change Position', -- Text to display in the keybind menu
            NoUI = false,
            Callback = function(Value)
                createPart()
            end,
        })
        infsection2:AddLabel('Unit 2'):AddKeyPicker('KeyPicker2', {

            Default = Settings.KeyPicker2, 
            SyncToggleState = false,
            Mode = 'Toggle', -- Modes: Always, Toggle, Hold
            Text = 'Change Position', -- Text to display in the keybind menu
            NoUI = false,

            Callback = function(Value)
                createPart2()
            end,
        })
        infsection2:AddLabel('Unit 3'):AddKeyPicker('KeyPicker3', {

            Default = Settings.KeyPicker3, 
            SyncToggleState = false,
            Mode = 'Toggle', -- Modes: Always, Toggle, Hold
            Text = 'Change Position', -- Text to display in the keybind menu
            NoUI = false,

            Callback = function(Value)
                createPart3()
            end,
        })

        Options.KeyPicker3:OnChanged(function() print(Options.KeyPicker3.Value) Settings.KeyPicker3 = Options.KeyPicker3.Value saveSettings() end)
        local AutoskillBox = Tabs.Main:AddRightTabbox()
        slash = "\\"
        local autoskilltab = AutoskillBox:AddTab('Auto Skill')

        autoskilltab:AddDropdown('UnitSkills', {
            Text = "Select Unit",
            Values = UnitSkillDrops,
            Default = 0,
            Multi = true,
            Callback = function(SelectedValues)
                for index, value in ipairs(UnitSkillDrops) do
                    if SelectedValues[value] then
                        print(value)
                    end
                end
            end
        })




        autoskilltab:AddToggle('AutoSkill',{
            Text = 'Auto Skill',
            Default = false,
            Callback = function(bool) end
        })



        local offsetRange = 2
        local workspaceService = game:GetService("Workspace")
        local replicatedStorage = game:GetService("ReplicatedStorage")

        local function Autoplace()
            local lanes = workspaceService["_BASES"].pve.LANES["1"]:GetDescendants()
            local roadParts = workspaceService["_road"]:GetDescendants()
            local optionsPlaceValue = Options.OptionsPlace.Value

            while true do
                if game.PlaceId == 8304191830 then
                    wait()
                else
                    if Toggles.AutoPlaceUnit2.Value then
                        wait(0.8) -- Adjust the delay to your desired value
                        pcall(function()
                            for i, v in pairs(lanes) do
                                if v:IsA("Part") and v.Name ~= "final" and v.Name ~= "spawn" then
                                    local excludePlacement = false
                                    for _, roadPart in pairs(roadParts) do
                                        if roadPart:IsA("Part") and v.CFrame:PointToObjectSpace(roadPart.Position).Magnitude < 1 then
                                            excludePlacement = true
                                            break
                                        end
                                    end
                                    if not excludePlacement and #uuidUnits > 0 then
                                        for y = 1, 6 do
                                            local jStart, jEnd
                                            if optionsPlaceValue == "Place Front" then
                                                jStart = y + 1
                                                jEnd = y + 1
                                            else
                                                jStart = y + 5
                                                jEnd = y + 5
                                            end

                                            if optionsPlaceValue ~= "Place Front" and y == 1 and front then
                                                jEnd = jEnd + 1
                                            end

                                            for j = jStart, jEnd do
                                                if v.Name == tostring(j) then
                                                    local offset = Vector3.new(
                                                        math.random(-offsetRange, offsetRange),
                                                        0,
                                                        math.random(-offsetRange, offsetRange)
                                                    )
                                                    local args = {
                                                        [1] = uuidUnits[y],
                                                        [2] = v.CFrame + offset
                                                    }
                                                    replicatedStorage.endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if #uuidUnits == 0 then
                                Check()
                            end
                        end)
                    end
                end
                wait()
            end
        end

        local function toggleCallback2(bool)
            if bool then
                game:GetService("RunService").RenderStepped:Connect(Autoplace)
            else
                game:GetService("RunService").RenderStepped:Disconnect(Autoplace)
            end
        end

        task.spawn(function()
        Autoplace()
        end)

        --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ LAG SECTION \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--


        local TabLagsetting = Tabs['LAG SWITCH']:AddLeftTabbox() 
        local tabsettings = TabLagsetting:AddTab('LAG Settings')
        tabsettings:AddSlider('lagsec', {
            Text = 'LAGSEC',
            Default = Settings.lagsec,
            Min = 0,
            Max = 10,
            Rounding = 1,
            Compact = true, -- If set to true, then it will hide the label
        })
        Options.lagsec:OnChanged(function(Value) Value = tonumber(Value) Settings.lagsec = Value saveSettings() end)
        tabsettings:AddSlider('lagstr', {
            Text = 'LAG IMPACT',
            Default = Settings.lagstr,
            Min = 0,
            Max = 500000,
            Rounding = 0,
            Compact = true, -- If set to true, then it will hide the label
        })
        Options.lagstr:OnChanged(function(Value) Value = tonumber(Value) Settings.lagstr = Value saveSettings() end)


        tabsettings:AddSlider('lager', {
            Text = 'LAG VALUE',
            Default = Settings.lager,
            Min = 0,
            Max = 10,
            Rounding = 0,
            Compact = true, -- If set to true, then it will hide the label
        })
        Options.lager:OnChanged(function(Value) Value = tonumber(Value) Settings.lager = Value saveSettings() end)
        tabsettings:AddSlider('lager2', {
            Text = 'LAG LOOP',
            Default = Settings.lager2,
            Min = 0,
            Max = 10,
            Rounding = 0,
            Compact = true, -- If set to true, then it will hide the label
        })
        Options.lager2:OnChanged(function(Value) Value = tonumber(Value) Settings.lager2 = Value saveSettings() end)
        tabsettings:AddSlider('Pinglimiter', {
            Text = 'Ping Limit',
            Default = Settings.Pinglimiter,
            Min = 0,
            Max = 10000,
            Rounding = 0,
            Compact = true,
        })

        Options.Pinglimiter:OnChanged(function(Value)
            Value = tonumber(Value)
            Settings.Pinglimiter = Value
            saveSettings()
        end)
        tabsettings:AddToggle('Pingtoggle', {
            Default = Settings.Pingtoggle,
            Text = 'Ping limiter',
            Callback = function(bool)
                local pingLimit = tonumber(Options.Pinglimiter.Value)
                local lagToggle = Toggles.lagtoggle

                while Toggles.Pingtoggle.Value do
                    wait()

                    if Toggles.Pingtoggle.Value and pingLimit < game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() then
                        lagToggle:SetValue(false)
                    else
                        lagToggle:SetValue(true)
                    end
                end
            end
        })

        


        tabsettings:AddToggle('lagtoggle',{
            Default = Settings.lagtoggle,
            Text = 'Toggle Lag',
            
        })

        Toggles.lagtoggle:OnChanged(function(bool) print(bool) Settings.lagtoggle = bool saveSettings() end)



        local autoToggle = false
        local MAX_VALUE = math.huge
        local DEFAULT_VALUE = 99999

        -- Define functions
        local function calculateMaxValue(val, mainValue)
        if type(val) ~= "number" then
            return nil
        end
        local calculatedValue = (mainValue / (val + 2))
        return calculatedValue
        end

        local function bomb(tableIncrease, tries, mainValue)
        local mainTable = {}
        local spammedTable = {{}}
        local z = spammedTable[1]
        for i = 1, tableIncrease do
            local tableIns = {}
            table.insert(z, tableIns)
            z = tableIns
        end
        local calculatedMax = calculateMaxValue(tableIncrease, mainValue)
        local maximum = calculatedMax and calculatedMax or DEFAULT_VALUE
        for i = 1, maximum do
            table.insert(mainTable, spammedTable)
        end
        for i = 1, tries do
            game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(mainTable)
        end
        end

        -- Run tasks
        task.spawn(function()
        while true do
            autoToggle = Toggles.lagtoggle.Value
            task.wait(0.1)
        end
        end)

        task.spawn(function()
        while true do
            task.wait(0.1)
            if autoToggle then
            game:GetService("NetworkClient"):SetOutgoingKBPSLimit(MAX_VALUE)
            bomb(Options.lager.Value, Options.lager2.Value, Options.lagstr.Value)
            task.wait(Options.lagsec.Value)
            end
        end
        end)

      

        -- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('ThemeSMTHUB-Settings')



-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])


Toggles.AutoLeaveWave:OnChanged(function(bool)
    Settings.AutoLeaveWave = bool
    saveSettings()
    if bool == true then
        leaveWave()
    end
end)


