local getgenv = (getgenv and getgenv) or function() return shared or _G end
local cloneref = (cloneref and cloneref) or function(ref) return ref end

local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))
local Lighting = cloneref(game:GetService("Lighting"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local TweenService = cloneref(game:GetService("TweenService"))
local Debris = cloneref(game:GetService("Debris"))

local repo = (getgenv().LibraryIs == "Linoria") and 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/' or 'https://raw.githubusercontent.com/mstudio45/Obsidian/main/'

local Library = loadstring(game:HttpGet(repo..'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo..'addons/ThemeManager.lua'))()
local SaveManager  = loadstring(game:HttpGet(repo..'addons/SaveManager.lua'))()
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local ClientModules = ReplicatedStorage:FindFirstChild("ModulesClient") or ReplicatedStorage:FindFirstChild("ClientModules") 
local RemotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("Bricks")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MainUI = PlayerGui:WaitForChild("MainUI")
local Modules = MainUI:WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("RemoteListener"):WaitForChild("Modules")
local Main_Game = require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)

local GameData = ReplicatedStorage:WaitForChild("GameData")
local FloorReplicated = ReplicatedStorage:FindFirstChild("FloorReplicated")
local LiveModifiers = ReplicatedStorage:FindFirstChild("LiveModifiers")
local Drops = workspace:FindFirstChild("Drops")
local Floor = GameData:WaitForChild("Floor").Value
local CurrentRooms = workspace:FindFirstChild("CurrentRooms")
local LatestRoom = GameData:WaitForChild("LatestRoom")

local Functions = {}
local FakePrompts = {}
local Lagging = false

if not LiveModifiers then
	LiveModifiers = Instance.new("Folder")
end

if not FloorReplicated then
	FloorReplicated = Instance.new("Folder")
end

local FinishedLoadingRoom = GameData:FindFirstChild("FinishedLoadingRoom")
if FinishedLoadingRoom then
	FinishedLoadingRoom:Destroy()
end

local FakeEvents = {
	Screech = Instance.new("RemoteEvent"),
	Shade = Instance.new("RemoteEvent"),
	A90 = Instance.new("RemoteEvent"),
	Surge = Instance.new("RemoteEvent"),
}

FakeEvents.Screech.Name  = "Screech"
FakeEvents.Shade.Name = "ShadeResult"
FakeEvents.A90.Name = "A90"
FakeEvents.Surge.Name = "SurgeRemote"

FakeEvents.Screech_Real = RemotesFolder:WaitForChild("Screech")
FakeEvents.Shade_Real = RemotesFolder:WaitForChild("ShadeResult")
FakeEvents.A90_Real = RemotesFolder:FindFirstChild("A90")
FakeEvents.Surge_Real = RemotesFolder:FindFirstChild("SurgeRemote")

local PromptContainer = Instance.new("Folder")
PromptContainer.Name = "PromptContainer"
PromptContainer.Parent = gethui() or CoreGui

local Entities = {
	["RushMoving"] = {
		Alias = "Rush",
		NotifyMessage = { Title = "Entity 'Rush' has spawned.", Body = "Find a hiding spot." }
	},
	["AmbushMoving"] = {
		Alias = "Ambush",
		NotifyMessage = { Title = "Entity 'Ambush' has spawned.", Body = "Find a hiding spot." }
	},
	["Eyes"] = {
		Alias = "Eyes",
		NotifyMessage = { Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it." }
	},
	["Lookman"] = {
		Alias = "Eyes",
		NotifyMessage = { Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it." }
	},
	["BackdoorRush"] = {
		Alias = "Blitz",
		NotifyMessage = { Title = "Entity 'Blitz' has spawned.", Body = "Find a hiding spot." }
	},
	["BackdoorLookman"] = {
		Alias = "Lookman",
		NotifyMessage = { Title = "Entity 'Lookman' has spawned.", Body = "Avoid looking at its eyes." }
	},
	["Groundskeeper"] = {
		Alias = "Groundskeeper",
		NotifyMessage = { Title = "Entity 'Groundskeeper' has spawned.", Body = "Avoid stepping on the grass." }
	},
	["A60"] = {
		Alias = "A-60",
		NotifyMessage = { Title = "Entity 'A-60' has spawned.", Body = "Find a hiding spot." }
	},
	["A120"] = {
		Alias = "A-120",
		NotifyMessage = { Title = "Entity 'A-120' has spawned.", Body = "Find a hiding spot." }
	},
	["GloombatSwarm"] = {
		Alias = "Gloombat Swarm",
		NotifyMessage = { Title = "Entity 'Gloombat Swarm' has spawned.", Body = "Keep all light sources turned off." }
	},
	["GlitchRush"] = {
		Alias = "RNIUSHCG==",
		NotifyMessage = { Title = "Entity 'RNIUSHCG==' has spawned.", Body = "Find a hiding spot." }
	},
	["GlitchAmbush"] = {
		Alias = "AR0xMBUSH",
		NotifyMessage = { Title = "Entity 'AR0xMBUSH' has spawned.", Body = "Find a hiding spot." }
	},
	["MonumentEntity"] = {
		Alias = "Monument",
		NotifyMessage = { Title = "Entity 'Monument' has spawned.", Body = "It can't move while you are looking at it." }
	},
	["JeffTheKiller"] = {
		Alias = "Jeff the Killer",
		NotifyMessage = { Title = "Entity 'Jeff the Killer' has spawned.", Body = "Avoid touching him." }
	},
	["CustomEntity"] = {
		Alias = "Custom Entity",
		NotifyMessage = { Title = "Entity 'Custom Entity' has spawned.", Body = "Find a hiding spot." }
	},
	["FrozenAmbush"] = {
		Alias = "Frozen Ambush",
		NotifyMessage = { Title = "Entity 'Frozen Ambush' has spawned.", Body = "Find a hiding spot." }
	},
	["SallyMoving"] = {
		Alias = "Sally",
		NotifyMessage = { Title = "Entity 'Sally' has spawned.", Body = "Drop an item for her." }
	}
}

local EntityIcons = {
	["RushMoving"]      = "rbxassetid://10716032262",
	["AmbushMoving"]    = "rbxassetid://10110576663",
	["A60"]             = "rbxassetid://12571092295",
	["A120"]            = "rbxassetid://12711591665",
	["BackdoorRush"]    = "rbxassetid://16602023490",
	["Eyes"]            = "rbxassetid://10183704772",
	["Lookman"]         = "rbxassetid://10183704772",
	["BackdoorLookman"] = "rbxassetid://16764872677",
	["GloombatSwarm"]   = "rbxassetid://79221203116470",
	["Halt"]            = "rbxassetid://11331795398",
	["JeffTheKiller"]   = "rbxassetid://94479432156278",
	["GlitchRush"]      = "rbxassetid://73859273102919",
	["GlitchAmbush"]    = "rbxassetid://88369678433359",
	["SallyMoving"]     = "rbxassetid://10840888070",
	["MonumentEntity"]  = "rbxassetid://88933556873017",
	["Groundskeeper"]   = "rbxassetid://114991380115557"
}

local ItemNames = {
	["Lighter"]           = "Lighter",
	["Flashlight"]        = "Flashlight",
	["Lockpick"]          = "Lockpicks",
	["Vitamins"]          = "Vitamins",
	["Bandage"]           = "Bandage",
	["StarVial"]          = "Starlight Vial",
	["StarBottle"]        = "Starlight Bottle",
	["StarJug"]           = "Starlight Barrel",
	["Shakelight"]        = "Gummy Flashlight",
	["Straplight"]        = "Straplight",
	["Bulklight"]         = "Spotlight",
	["Battery"]           = "Battery",
	["Candle"]            = "Candle",
	["Crucifix"]          = "Crucifix",
	["CrucifixWall"]      = "Crucifix",
	["Glowsticks"]        = "Glowstick",
	["SkeletonKey"]       = "Skeleton Key",
	["Candy"]             = "Candy",
	["ShieldMini"]        = "Mini Shield Potion",
	["ShieldBig"]         = "Big Shield Potion",
	["BandagePack"]       = "Bandage Pack",
	["BatteryPack"]       = "Battery Pack",
	["RiftCandle"]        = "Moonlight Candle",
	["LaserPointer"]      = "Laser Pointer",
	["HolyGrenade"]       = "Holy Hand Grenade",
	["Shears"]            = "Shears",
	["Smoothie"]          = "Smoothie",
	["Cheese"]            = "Cheese",
	["Bread"]             = "Bread",
	["AlarmClock"]        = "Alarm Clock",
	["RiftSmoothie"]      = "Moonlight Smoothie",
	["GweenSoda"]         = "Gween Soda",
	["GlitchCube"]        = "Glitch Fragment",
	["Scanner"]           = "Tablet",
	["Bomb"]              = "Bomb",
	["Knockbomb"]         = "Knockbomb",
	["Nanner"]            = "Nanner",
	["BigBomb"]           = "Big Bomb",
	["SnakeBox"]          = "Hiding Box",
	["GoldGun"]           = "Golden Gun",
	["StopSign"]          = "Stop Sign",
	["TipJar"]            = "Tip Jar",
	["Lantern"]           = "Lantern",
	["IronKey"]           = "Iron Key",
	["LotusPetal"]        = "Lotus Petal",
	["Compass"]           = "Compass",
	["LotusPetalPickup"]  = "Lotus Petal",
	["LanternLitItem"]    = "Lantern",
	["KeyIron"]           = "Iron Key",
	["IronKeyForCrypt"]   = "Iron Key",
	["LotusHolder"]       = "Lotus Petal",
	["Multitool"]         = "Multitool",
	["RiftJar"]           = "Rift Jar",
	["AloeVera"]          = "Aloe Vera",
	["Donut"]             = "Donut",
	["Lotus"]             = "Lotus",
	["BoxingGloves"]      = "Boxing Gloves"
}

local CutsceneNames = {
    "Figure",
    "FigureEnd",
    "FigureHotelEnd",
    "FigureHotelFire",
    "SeekIntroFools",
    "SeekIntroHotel",
    "SeekIntroMines",
    "SeekIntroMines2",
    "SerewSeekDrain",
    "SewerSeekLower",
    "GrumbleNestEnd",
    "EyestalkIntro",
}

local NotificationLibrary = {
	LiveNotifications = 0,
	Notifications = 1
}

local Container = Instance.new("ScreenGui")
Container.Name = math.random()
Container.Parent = gethui() or CoreGui
Container.DisplayOrder = 32767
Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if not Library.Scheme then
	Library.Scheme = setmetatable({}, {
		__index = function(Self, Name)
			return Library[Name]
		end
	})
end

function NotificationLibrary:Notify(TitleText, Desc, Delay)
	task.spawn(function()
		local Notification = Instance.new("Frame")
		local Line = Instance.new("Frame")
		local Warning = Instance.new("ImageLabel")
		local UICorner = Instance.new("UICorner")
		local UICorner2 = Instance.new("UICorner")
		local Title = Instance.new("TextLabel")
		local Description = Instance.new("TextLabel")

		Notification.Name = "Notification"
		Notification.Parent = Container
		Notification.BackgroundColor3 = Library.Scheme.BackgroundColor
		Notification.BackgroundTransparency = 0.4
		Notification.BorderSizePixel = 0
		Notification.Position = UDim2.new(1, 5, 0, 60 + (60 * NotificationLibrary.LiveNotifications))
		Notification.Size = UDim2.new(0, 420, 0, 50)
		Notification:SetAttribute("ID", NotificationLibrary.Notifications)
		Notification:SetAttribute("CurrentPosition", Notification.Position)

		Line.Name = "Line"
		Line.Parent = Notification
		Line.BackgroundColor3 = Library.Scheme.AccentColor
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(0, 0, 1, -3)
		Line.Size = UDim2.new(0, 0, 0, 3)

		Warning.Name = "Warning"
		Warning.Parent = Notification
		Warning.BackgroundTransparency = 1
		Warning.Position = UDim2.new(0, 10, 0, 5)
		Warning.Size = UDim2.new(0, 40, 0, 40)
		Warning.Image = "rbxassetid://3944668821"
		Warning.ImageColor3 = Library.Scheme.AccentColor
		Warning.ScaleType = Enum.ScaleType.Fit

		UICorner.CornerRadius = UDim.new(0, 20)
		UICorner.Parent = Warning

		UICorner2.CornerRadius = UDim.new(0, 4)
		UICorner2.Parent = Notification

		Title.Name = "Title"
		Title.Parent = Notification
		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 60, 0.155, 0)
		Title.Size = UDim2.new(0, 205, 0, 15)
		Title.Text = TitleText or "..."
		Title.TextColor3 = Library.Scheme.FontColor
		Title.TextSize = 10
		Title.TextStrokeTransparency = 0.75
		Title.TextXAlignment = Enum.TextXAlignment.Left

		Description.Name = "Description"
		Description.Parent = Notification
		Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Description.BackgroundTransparency = 1
		Description.Position = UDim2.new(0, 60, 0.483, 0)
		Description.Size = UDim2.new(0, 205, 0, 18)
		Description.Text = Desc or "..."
		Description.TextColor3 = Library.Scheme.FontColor
		Description.TextTransparency = 0.1
		Description.TextSize = 10
		Description.TextStrokeTransparency = 0.75
		Description.TextXAlignment = Enum.TextXAlignment.Left

		NotificationLibrary.LiveNotifications += 1
		NotificationLibrary.Notifications += 1

		TweenService:Create(
			Notification,
			TweenInfo.new(1, Enum.EasingStyle.Exponential),
			{ Position = UDim2.new(1, -370, 0, Notification.Position.Y.Offset) }
		):Play()

		task.wait(0.25)
		if typeof(Delay) == "Instance" then
			Delay.Destroying:Wait()
		else
			TweenService:Create(
				Line,
				TweenInfo.new(Delay - 0.25, Enum.EasingStyle.Linear),
				{ Size = UDim2.new(0, 400, 0, 3) }
			):Play()
			task.wait(Delay - 0.25)
		end

		Notification:SetAttribute("Destroying", true)

		TweenService:Create(
			Notification,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 5, 0, Notification.Position.Y.Offset) }
		):Play()

		NotificationLibrary.LiveNotifications -= 1

		local NotifId = Notification:GetAttribute("ID")
		local NotifY = Notification:GetAttribute("CurrentPosition").Y.Offset

		for _, Object in Container:GetChildren() do
			if Object.Name == "Notification"
				and Object:GetAttribute("ID")
				and Object:GetAttribute("ID") > NotifId
				and Object:GetAttribute("Destroying") ~= true
				and Object.Position.Y.Offset ~= 60
			then
				local NewY = Object:GetAttribute("CurrentPosition").Y.Offset - 60
				Object:SetAttribute("CurrentPosition", UDim2.new(1, -450, 0, NewY))
				TweenService:Create(
					Object,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{ Position = UDim2.new(1, -370, 0, NewY) }
				):Play()
			end
		end

		task.wait(0.75)
		Notification:Destroy()
	end)
end

local DoorsNotify = function(NotifyOptions)
	local function PlaySound(Parent, SoundId, Volume)
		local Sound = Instance.new("Sound")
		Sound.SoundId = SoundId
		Sound.Volume = Volume or 1
		Sound.Parent = Parent
		task.spawn(function()
			task.wait(0.1)
			Sound:Play()
			Sound.Ended:Wait()
			Sound:Destroy()
		end)
	end

	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local UIContainer = PlayerGui:FindFirstChild("GlobalUI") or PlayerGui:FindFirstChild("MainUI")
	if not UIContainer then return end

	local AchievementsHolder = UIContainer:FindFirstChild("AchievementsHolder")
	if not AchievementsHolder then return end

	local Achievement = AchievementsHolder.Achievement:Clone()
	Achievement.Size = UDim2.new(0, 0, 0, 0)
	Achievement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
	Achievement.Name = "LiveAchievement"
	Achievement.Visible = true

	Achievement.Frame.TextLabel.Text = NotifyOptions.Style or "NOTIFICATION"
	Achievement.Frame.Details.Title.Text = NotifyOptions.Title or "Sem Título"
	Achievement.Frame.Details.Desc.Text = NotifyOptions.Description or "Sem Descrição"
	Achievement.Frame.Details.Reason.Text = NotifyOptions.Reason or ""
	Achievement.Frame.ImageLabel.Image = (NotifyOptions.Image ~= "" and NotifyOptions.Image) or "rbxassetid://6023426923"

	local Color = NotifyOptions.Color or Color3.new(1, 1, 1)
	Achievement.Frame.TextLabel.TextColor3 = Color
	Achievement.Frame.UIStroke.Color = Color
	Achievement.Frame.Glow.ImageColor3 = Color
	Achievement.Parent = AchievementsHolder

	PlaySound(AchievementsHolder, "rbxassetid://10469938989", 1)

	task.spawn(function()
		Achievement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", 0.8, true)
		task.wait(0.8)
		Achievement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
		TweenService:Create(
			Achievement.Frame.Glow,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ ImageTransparency = 1 }
		):Play()

		if typeof(NotifyOptions.Time) == "Instance" then
			NotifyOptions.Time.Destroying:Wait()
		else
			task.wait(NotifyOptions.Time or 5)
		end

		Achievement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
		task.wait(0.5)
		Achievement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
		task.wait(0.5)
		Achievement:Destroy()
	end)
end

local STX = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/" .. string.reverse("llasybA") .."/refs/heads/main/Components/STX.luau"))()
Functions.Notify = function(Settings)
	local HiddenContainer = gethui() or CoreGui

	if not Settings.Body then
		Settings.Body = "..."
	end

	if not Options.NotifyStyle or Options.NotifyStyle.Value == "Normal" then
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://8784885431"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()
		NotificationLibrary:Notify(Settings.Title, Settings.Body, Settings.Time or 5)
	elseif Options.NotifyStyle.Value == "Doors" then
		local IsEntity = false
		local EntityName = ""
		for Index, Object in pairs(Entities) do
			if Object.NotifyMessage.Title == Settings.Title or Object.NotifyMessage.Body == Settings.Body then
				IsEntity = true
				EntityName = Index
			end
		end
		DoorsNotify({
			Title = "Nebula Hub",
			Description = Settings.Title,
			Reason = Settings.Body,
			Style = IsEntity and "WARNING" or "NOTIFICATION",
			Color = IsEntity and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 222, 189),
			Image = Settings.Image,
			Time = Settings.Time
		})
	elseif Options.NotifyStyle.Value == "STX" then
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://4590657391"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()

		if Settings.Image then
			STX:Notify(
				{Title = "Nebula Hub", Description = Settings.Title .. "\n" .. Settings.Body},
				{OutlineColor = Library.Scheme.AccentColor,Time = Settings.Time or 5, Type = "image"},
				{Image = Settings.Image, ImageColor = Color3.fromRGB(255, 255, 255)}
			)
		else
			STX:Notify(
				{Title = "Nebula Hub", Description = Settings.Title .. "\n" .. Settings.Body},
				{OutlineColor = Library.Scheme.AccentColor,Time = Settings.Time or 5, Type = "default"}
			)
		end
	else
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://4590662766"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()
		Library:OldNotify({ Title = Settings.Title, Description = Settings.Body, Time = Settings.Time })
	end
end

Functions.Caption = function(Text, PlaySound)
	if typeof(PlaySound) ~= "boolean" then
		PlaySound = true
	end
	local CaptionValue = Instance.new("NumberValue")
	local Caption = MainUI:WaitForChild("MainFrame"):WaitForChild("Caption"):Clone()
	local CaptionSound = MainUI:WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("Reminder"):WaitForChild("Caption")
	local CaptionSoundClone = CaptionSound:Clone()
	CaptionSoundClone.Parent = CaptionSound.Parent
	CaptionSoundClone.Volume = 0.1

	Caption.Destroying:Connect(function()
		CaptionValue:Destroy()
	end)

	for _, Child in MainUI:GetChildren() do
		if Child.Name == "LiveCaption" then
			Child:Destroy()
		end
	end

	Caption.Parent = MainUI
	Caption.Visible = true
	Caption.Name = "LiveCaption"
	Caption.Text = Text

	if PlaySound then
		CaptionSoundClone:Play()
	end

	Debris:AddItem(CaptionSoundClone, 5)

	local HolderTween = TweenService:Create(CaptionValue, TweenInfo.new(3), { Value = 100 })
	HolderTween:Play()
	HolderTween.Completed:Connect(function()
		CaptionValue:Destroy()
		TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
		TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextStrokeTransparency = 1 }):Play()
	end)
end

Functions.HasItem = function(Name, OnlyCharacter)
	if not OnlyCharacter and LocalPlayer.Backpack:FindFirstChild(Name) then
		return LocalPlayer.Backpack:FindFirstChild(Name)
	elseif Character:FindFirstChild(Name) then
		return Character:FindFirstChild(Name)
	end
end

Functions.FirePrompt = fireproximityprompt or function()
end
Functions.ForceFirePrompt = fireproximityprompt or function()
end

if Floor == "Hotel" and RemotesFolder.Name == "Bricks" then
	Floor = "OldHotel"
end

local CollisionClone
local CollisionPart

local function SetupCollisionClone(char)
	if not char:WaitForChild("CollisionPart", 5) then return end
        CollisionPart = char.CollisionPart
	CollisionClone = char.CollisionPart:Clone()
	CollisionClone.Name = "CollisionPartClone"
	CollisionClone.Parent = char 
	CollisionClone.Massless = true
	CollisionClone.CanCollide = false

	local crouch = CollisionClone:FindFirstChild("CollisionCrouch")
	if crouch then crouch:Destroy() end
end

SetupCollisionClone(Character)

Functions.IsCrouching = function()
	if Floor == "Fools" or Floor == "OldHotel" then
		return Character:GetAttribute("Crouching")
	end
	return CollisionPart.CollisionGroup == "PlayerCrouching"
end

Functions.GetInjuriesSpeed = function()
	return 0.075 * (Character:WaitForChild("Humanoid").MaxHealth - Character:WaitForChild("Humanoid").Health)
end

Functions.GetCurrentSpeed = function()
	local Speed = 15
	Speed += Character:GetAttribute("SpeedBoost") or 0
	Speed += Character:GetAttribute("SpeedBoostBehind") or 0
	Speed += Character:GetAttribute("SpeedBoostExtra") or 0
	Speed += (Floor == "Party" and 10 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFast") and 3 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFaster") and 6 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFastest") and 20 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlow") and 3 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlowHealth") and Functions.GetInjuriesSpeed() or 0)
	if Functions.IsCrouching() then
		if LiveModifiers:FindFirstChild("PlayerCrouchSlow") then
			Speed -= 8
		elseif LiveModifiers:FindFirstChild("PlayerSlow") then
			Speed -= 8
		else
			Speed -= 5
		end
	end
	return Speed
end

local function isnetworkowner(part)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return false 
	end
	return part:GetNetworkOwner() == LocalPlayer
end

local function addesp(v, txt, color)
	pcall(function()
		ESPLibrary:AddESP({
			Object = v,
			Text = txt,
			Color = color
		})
	end)
end

local function addentityesp(entity, txt)
	task.spawn(function()
		local base = entity.PrimaryPart
		while not base do
			base = entity:FindFirstChildWhichIsA("BasePart") or entity.PrimaryPart
			task.wait()
		end
		base.Transparency = 0.99
		if not entity:FindFirstChildOfClass("Humanoid") then
			Instance.new("Humanoid", entity)
		end
		addesp(entity, txt, Color3.new(1, 0, 0))
	end)
end

local function removeesp(v)
	pcall(function()
		ESPLibrary:RemoveESP(v)
	end)
end

local Window = Library:CreateWindow({
	Title = 'Nebula Hub | ' .. ReplicatedStorage.GameData.Floor.Value,
	Footer = "beta v0.8",
	Center = true,
	AutoShow = true,
	ShowCustomCursor = false,
})

local Tabs = {
	Info = Window:AddTab('Info', "circle-user-round"),
	Main = Window:AddTab('Main', "shield"),
	Exploits = Window:AddTab('Exploits', "axe"),
	Visuals = Window:AddTab('Visuals', "camera"),
	Floors = Window:AddTab('Floors', "monitor-smartphone"),
	UISettings = Window:AddTab('Configuration', "house"),
}

local Information = Tabs.Info:AddLeftGroupbox('Information')
local Movement = Tabs.Main:AddLeftGroupbox('Movement')
local MiscBox = Tabs.Main:AddRightGroupbox('Utilities')
local Exploits = Tabs.Exploits:AddLeftGroupbox('Exploits')
local Anti = Tabs.Exploits:AddRightGroupbox('Anti')
local Visuals = Tabs.Visuals:AddLeftGroupbox('Visuals')
local Floors = Tabs.Floors:AddLeftGroupbox('Coming Soon')
local Settings = Tabs.Visuals:AddRightGroupbox('settings')
local SettingsBox = Tabs.UISettings:AddLeftGroupbox('UI')
local Credits = Tabs.UISettings:AddRightGroupbox("Credits")

MiscBox:AddButton({
	Text = "Play again",
	Tooltip = "Joins a fresh run. Click twice to confirm.",
	DoubleClick = true,
	Func = function()
		if RemotesFolder:FindFirstChild("PlayAgain") then
                    RemotesFolder.PlayAgain:FireServer()
		end
	end
})

MiscBox:AddButton({
	Text = "Back to Lobby",
	Tooltip = "Teleports you back to the main lobby. Click twice.",
	DoubleClick = true,
	Func = function()
		if RemotesFolder:FindFirstChild("Lobby") then
                    RemotesFolder.Lobby:FireServer()
		end
	end
})

MiscBox:AddButton({
	Text = "Revive",
	Tooltip = "Uses your revive if available. Click twice.",
	DoubleClick = true,
	Func = function()
		if RemotesFolder:FindFirstChild("Revive") then
                    RemotesFolder.Revive:FireServer()
		end
	end
})

MiscBox:AddButton({
	Text = "Reset",
	Tooltip = "Resets your character. Click twice.",
	DoubleClick = true,
	Func = function()
            if RemotesFolder:FindFirstChild("Statistics") then
                  RemotesFolder.Statistics:FireServer()
	    end
            task.wait(1)
            Character:WaitForChild("Humanoid").Health = -1
	end
})
Floors:AddLabel("coming soon")

Credits:AddLabel("qai (owner)", true)
Credits:AddLabel("realheckersbrother (main dev)", true)
Credits:AddLabel("firebacon (secondary dev)", true)
Credits:AddLabel("kardincat (coder)", true)

Information:AddLabel("nebula hub:)", true)
Information:AddLabel("any bugs? REPORT IN DISCORD SERVER!", true)
Information:AddLabel("https://discord.gg/2tTc7NmYR3", true)
Information:AddLabel("losso gexos", true)
Information:AddLabel("status:🟢", true)

Visuals:AddToggle('Door', {
	Text = "Door",
	Default = false
})

Visuals:AddToggle('Key',{
	Text = "Key",
	Default = false
})

Visuals:AddToggle('GateLeverEsp', {
	Text = "Gate lever",
	Default = false
})

Visuals:AddToggle('EntitesESP', { 
	Text = "Entity",
	Default = false
})

Visuals:AddToggle('BookESP', { 
	Text = "Books",
	Default = false
})


Visuals:AddToggle('Ambient', { 
	Text = "Ambient", 
	Default = false,
	Tooltip = "makes all rooms bright including dark rooms.",
	Callback = function(Value)
		if not Value then
			Lighting.GlobalShadows = true
			Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		end
	end
})

Visuals:AddToggle('RemoveCameraShake', {
	Text = 'No Camera Shake',
	Tooltip = "just removes cam shake.",
	Default = false
})

Visuals:AddToggle('RemoveCameraBobbing', {
	Text = "No Camera Bobbing",
	Tooltip = "just removes bobbing",
	Default = false
})

local function checkEntity(v)
    local entity = Entities[v.Name]
    if not entity then
        return
    end

    if Toggles.EntitesNotify.Value then
        Functions.Notify({
            Title = entity.NotifyMessage.Title,
            Body = entity.NotifyMessage.Body,
            Image = EntityIcons[v.Name]
        })
    end

    if Toggles.EntitesESP.Value then
        addentityesp(v, entity.Alias)
    end
end

workspace.DescendantAdded:Connect(checkEntity)

Settings:AddSlider("FOVSlider", {
	Text = "FOV Slider",
	Default = 70,
	Min = 10,
	Max = 120,
	Rounding = 1,
	Compact = true
})

Settings:AddToggle('EntitesNotify', {
	Text = "Notify Entities",
	Default = false
})

Settings:AddDivider()

Settings:AddToggle('ThirdPerson', {
	Text = "Third Person",
	Default = false
}):AddKeyPicker("KeyPicker", {
	Default = "T",
	SyncToggleState = true, 
	Mode = "Toggle",
	Text = "Third person"
})

Settings:AddSlider("OffsetX", {
	Text = "X offset",
	Default = 1.4,
	Min = -10,
	Max = 15,
	Rounding = 1,
	Compact = true
})

Settings:AddSlider("OffsetY", {
	Text = "Y offset",
	Default = 0.6,
	Min = -10,
	Max = 15,
	Rounding = 1,
	Compact = true
})

Settings:AddSlider("OffsetZ", {
	Text = "Z offset",
	Default = 7.2,
	Min = -10,
	Max = 15,
	Rounding = 1,
	Compact = true
})

Anti:AddToggle('AntiEyes', {
	Text = "Anti-Eyes",
	Default = false
})

Anti:AddToggle('AntiDupe', {
	Text = "Anti-Dupe",
	Default = false
})

Anti:AddToggle('AntiSnare', {
	Text = "Anti-Snare",
	Default = false
})

Anti:AddToggle('AntiHalt', { 
	Text = "Anti-Halt", 
	Default = false,
	Callback = function(Value)
		local Halt = ClientModules.EntityModules:FindFirstChild("Shade") or ClientModules.EntityModules:FindFirstChild("_Shade") 
		if Halt then
			Halt.Name = Value and "_Shade" or "Shade"
		end
	end
})

Anti:AddToggle('AntiA90', { 
	Text = "Anti-A90", 
	Default = false,
	Callback = function(Value)
		local A90 = Modules:FindFirstChild("A90") or Modules:FindFirstChild("_A90")
		if A90 then
            A90.Name = Value and "_A90" or "A90"
        end
	end
})
Anti:AddToggle('AntiScreech', { 
	Text = "Anti-Screech", 
	Default = false,
	Callback = function(Value)
		local Screech = Modules:FindFirstChild("Screech") or Modules:FindFirstChild("_Screech")
		if Screech then
            Screech.Name = Value and "_Screech" or "Screech"
        end
	end
})
Anti:AddToggle('AntiDread', { 
	Text = "Anti-Dread", 
	Default = false,
	Callback = function(Value)
		local Screech = Modules:FindFirstChild("Dread") or Modules:FindFirstChild("_Dread")
		if Screech then
            Screech.Name = Value and "_Dread" or "Dread"
        end
	end
})
Anti:AddToggle('NoSurgeDamage', { 
	Text = "No Surge Damage", 
	Default = false,
	Callback = function(Value)
        	if RemotesFolder:FindFirstChild("SurgeRemote") then
		if Value then
			FakeEvents.Surge.Parent = RemotesFolder
			FakeEvents.Surge_Real.Parent = nil
		else
			FakeEvents.Surge_Real.Parent = RemotesFolder
			FakeEvents.Surge.Parent = nil
		end
	end
	end
})
Anti:AddToggle('NoA90Damage', { 
	Text = "No A90 Damage", 
	Default = false,
	Callback = function(Value)
	if RemotesFolder:FindFirstChild("A90") then
		if Value then
			FakeEvents.A90.Parent = RemotesFolder
			FakeEvents.A90_Real.Parent = nil
		else
			FakeEvents.A90_Real.Parent = RemotesFolder
			FakeEvents.A90.Parent = nil
		end
	end
	end
})
Anti:AddToggle('NoHaltDamage', { 
	Text = "No Halt Damage", 
	Default = false,
	Callback = function(Value)
	if Value then
		FakeEvents.Shade.Parent = RemotesFolder
		FakeEvents.Shade_Real.Parent = nil
	else
		FakeEvents.Shade_Real.Parent = RemotesFolder
		FakeEvents.Shade.Parent = nil
	end
	end
})
Anti:AddToggle('NoSreechDamage', { 
	Text = "No Screech Damage", 
	Default = false,
	Callback = function(Value)
	if Value then
		FakeEvents.Screech.Parent = RemotesFolder
		FakeEvents.Screech_Real.Parent = nil
	else
		FakeEvents.Screech_Real.Parent = RemotesFolder
		FakeEvents.Screech.Parent = nil
	end
	end
})
Anti:AddToggle('AntiSeekObstructions', { 
	Text = "Anti Seek Obstructions", 
	Default = false,
})

Movement:AddSlider("WalkspeedSlider", {
	Text = "Speed",
	Default = 25,
	Min = 16,
	Max = 85,
	Rounding = 1,
	Compact = true
})

Movement:AddToggle('EnableWalkSpeed', {
	Text = "Speed Boost", 
	Tooltip = "speedboost lol.",
	Default = false
})

Movement:AddToggle('Noclip', {
	Text = "Noclip",
	Default = false
}):AddKeyPicker("KeyPicker1", {
	Default = "N",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Noclip"
})

Movement:AddToggle('Noacceleration', {
	Text = "No Acceleration",
	Tooltip = "no slipping when running.",
	Default = false
})

Movement:AddToggle('FastClosetExit', {
	Text = "Fast Closet Exit",
	Tooltip = "removes closet delay",
	Default = false
})

Movement:AddToggle('EnableJump', {
	Text = "Enable Jump",
	Tooltip = "enables jump for other floors other then mines.",
	Default = false
})

Movement:AddToggle('EnableSlide', {
	Text = "Enable Sliding",
	Tooltip = "enables sliding",
	Default = false
})

Movement:AddToggle('InfiniteJump', {
	Text = "Infinite Jump",
	Tooltip = "jump as many times as u want mid air.",
	Default = false
})

Exploits:AddToggle('CrouchSpoof', {
	Text = "Crouch Spoof",
	Tooltip = "figure wont hear you so it technically makes the game think you are crouching",
	Default = false
})

Exploits:AddToggle('DoorReach', {
	Text = "Door Reach",
	Tooltip = "if you use this u will open doors in longer range.",
	Default = false
})

Exploits:AddSlider("DoorReachRange", {
	Text = "Door Reach Range",
	Default = 15,
	Min = 15,
	Max = 30,
	Rounding = 1,
	Tooltip = "range slider for door reach",
	Compact = true
})

Exploits:AddDivider()

Exploits:AddToggle('KnobCollector', {
	Text = "Auto Collect",
	Tooltip = "automatically collects gold knobs in the current room.",
	Default = false
})

Exploits:AddSlider("KnobRadius", {
	Text = "Collect Radius",
	Default = 5,
	Min = 5,
	Max = 60,
	Rounding = 0,
	Tooltip = "how close a knob needs to be to get collected.",
	Compact = true
})

Exploits:AddToggle('RemoveCutscenes', {
	Text = "Remove Cutscenes",
	Tooltip = "Removes cutscenes",
    Callback = function(Value)
    local Cutscenes = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI").Initiator.Main_Game.RemoteListener.Cutscenes
    for _, Object in pairs(Cutscenes:GetChildren()) do
        if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
            Object.Name = (Value and "_" .. Object.Name or Object:GetAttribute("OriginalName"))
        end
    end
    for _, Object in pairs(FloorReplicated:GetChildren()) do
        if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
            Object.Name = (Value and "_" .. Object.Name or Object:GetAttribute("OriginalName"))
        end
    end
    end,
	Default = false
})

Exploits:AddToggle('InfiniteItems', { 
	Text = "Infinite Items", 
	Default = false,
	Tooltip = "Makes it so you have infinite items"
})

Exploits:AddDropdown("InfiniteItemsList", {
    Text = "Infinite Items Selection",
    Values = {
        "Lockpicks",
        "Skeleton Key",
        "Shears",
        "Multitool",
    },
    Multi = true,
    Default = {
        ["Lockpicks"] = true,
        ["Skeleton Key"] = true,
        ["Shears"] = true,
        ["Multitool"] = true,
    }
})

Exploits:AddToggle('InstantInteract', { 
	Text = "Instant Interact", 
	Default = false,
	Tooltip = "Instantly Interact with any prompt"
})

Exploits:AddToggle('InteractNoclip', { 
	Text = "Interact Noclip", 
	Default = false,
	Tooltip = "Interact through walls"
})

Exploits:AddSlider("InteractRange", {
	Text = "Interact Range",
	Default = 25,
	Min = 16,
	Max = 50,
	Rounding = 1,
	Compact = true
})

task.spawn(function()
    while true do
        for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = Toggles.InstantInteract.Value and 0 or prompt.HoldDuration
                prompt.RequiresLineOfSight = not Toggles.InteractNoclip.Value or prompt.RequiresLineOfSight
                prompt.MaxActivationDistance = Options.InteractRange.Value
            end
        end

        task.wait(0.25)
    end
end)

Toggles.EnableWalkSpeed:OnChanged(function(Value)
	if Character:FindFirstChildOfClass("Humanoid") then
		Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Functions.GetCurrentSpeed() + (Value and Options.WalkspeedSlider.Value or 0)
	end
end)

local PartProperties = {}
local props = Character:WaitForChild("HumanoidRootPart").CustomPhysicalProperties
    or PhysicalProperties.new(0.7, 0.3, 0.5)

CustomPhysics = PhysicalProperties.new(
    100,
    props.Friction,
    props.Elasticity,
    props.FrictionWeight,
    props.ElasticityWeight
)

	for _, Part in Character:GetDescendants() do
		if Part:IsA("BasePart") then
			PartProperties[Part] = Part.CustomPhysicalProperties
		end
	end

Toggles.Noacceleration:OnChanged(function(Value)
	for Index, Old in PartProperties do
		Index.CustomPhysicalProperties = Value and CustomPhysics or Old
	end
end)

local Connections = {}

local function UpdateRoomAssets()
	local currentRoomIdx = LocalPlayer:GetAttribute("CurrentRoom")
	if not currentRoomIdx or not workspace.CurrentRooms:FindFirstChild(tostring(currentRoomIdx)) then return end

	local room = workspace.CurrentRooms[tostring(currentRoomIdx)]

	if Toggles.AntiDupe.Value then
		for _, v in ipairs(room:GetChildren()) do
			if v.Name == "SideroomDupe" then
				pcall(function()
					v:WaitForChild("DoorFake"):WaitForChild("Hidden").CanTouch = false
					if v.DoorFake:FindFirstChild("Lock") then
						v.DoorFake.Lock:FindFirstChildOfClass("ProximityPrompt").Enabled = false
					end
				end)
			end
		end
	end

	if Toggles.AntiSnare.Value then
		for _, v in ipairs(room:GetChildren()) do
			if v.Name == "Snare" and v:FindFirstChild("Hitbox") then
				v.Hitbox.CanTouch = false
			end
		end
	end

	if Toggles.Door.Value and room:FindFirstChild("Door") and room.Door:FindFirstChild("Door") then
		local lastroom = currentRoomIdx - 1
		if lastroom >= 0 and workspace.CurrentRooms:FindFirstChild(tostring(lastroom)) and workspace.CurrentRooms[tostring(lastroom)]:FindFirstChild("Door") then
			removeesp(workspace.CurrentRooms[tostring(lastroom)].Door.Door)
		end
		addesp(room.Door.Door, "Door " .. (room.Door:GetAttribute("RoomID") or currentRoomIdx), Color3.new(0, 1, 0))
	end

	if Toggles.Key.Value then
		local Key = workspace:FindFirstChild("KeyObtain", true)
		if Key then
			addesp(Key, "Key", Color3.new(1, 0, 0))
		end
	end

	if Toggles.GateLeverEsp.Value then
		local GateLever = workspace:FindFirstChild("LeverForGate", true)
		if GateLever then
			addesp(GateLever, "Gate Lever", Color3.new(0, 0, 0.5))
		end
	end
end

UpdateRoomAssets()

table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(UpdateRoomAssets))

table.insert(Connections, UserInputService.JumpRequest:Connect(function()
	if Toggles.InfiniteJump.Value and Character:FindFirstChildOfClass("Humanoid") then
		task.wait(0.05)
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))

Options.WalkspeedSlider:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("Crouch") then
		RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
	end
end)

local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }

local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }

local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }

local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }

local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }

local UseAnimation
local UseAnimationBreak

table.insert(Connections, Character.ChildAdded:Connect(function()
		local Tool
		for _, Name in ToolNames do
			Tool = Character:FindFirstChild(Name)
			if Tool then break end
		end
		if not Tool then return end

		local UseAnim = Tool:FindFirstChild("use", true) or Tool:FindFirstChild("promptanim", true)
		if UseAnim then
			UseAnim = Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(UseAnim)
			UseAnim.Priority = Enum.AnimationPriority.Action4
			UseAnimation = UseAnim
		end
		local UseAnimBreak = Tool:FindFirstChild("usefinish", true) or Tool:FindFirstChild("promptanimend", true) or Tool:FindFirstChild("lockpickuse", true)
		if UseAnimBreak then
			UseAnimBreak = Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(UseAnimBreak)
			UseAnimBreak.Priority = Enum.AnimationPriority.Action4
			UseAnimationBreak = UseAnimBreak
		end
	end))

table.insert(Connections, ProximityPromptService.PromptTriggered:Connect(function(Object)
    if not Object:GetAttribute("FakePrompt") then 
        return 
    end

    local Tool
    for _, N in ToolNames do 
        Tool = Character:FindFirstChild(N) 
        if Tool then 
            break 
        end 
    end
    if not Tool then

    end

    local Prompt = Object

    local IsLockPrompt = LockPromptNames[Object.Name]
        or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
        or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
    
    if IsLockPrompt then
        --[[if Options.AutoInteractIgnoreList.Value["Locks"] then 
            return 
        end]]

        local HasKey = false
        for _, K in KeyItems do 
            if Functions.HasItem(K, true) then 
                HasKey = true 
                break 
            end 
        end
        for _, K in OffhandKeyItems do 
            if Functions.HasItem(K) then 
                HasKey = true 
                break 
            end 
        end
        if not HasKey then 
            return 
        end
    end

    if (Prompt.Parent.Name == "CuttableVines" or Prompt.Parent.Name == "Chest_Vine" or Prompt.Parent.Name == "Cellar") 
       and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then
        return 
    end

    if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then
        return 
    end

    if (Prompt.Parent.Name == "Lock1" or Prompt.Parent.Name == "Lock2") 
       and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then
        return 
    end

    if Functions.HasItem("Shears", true) and IsLockPrompt 
       and Prompt.Parent.Name ~= "CuttableVines" 
       and Prompt.Parent.Name ~= "Chest_Vine" 
       and Prompt.Parent.Name ~= "Cellar" then
        return 
    end

    if Tool and table.find(AnimateToolNames, Tool.Name) and UseAnimation and UseAnimationBreak then
        UseAnimation:Stop()
        UseAnimationBreak:Stop()
        UseAnimationBreak:Play()
        if Tool.Name == "Shears" then 
            local sound = Tool:FindFirstChild("Handle") and Tool.Handle:FindFirstChild("sound_prompt")
            if sound then sound:Play() end
        end
    end

    local AnyTool = Character:FindFirstChildOfClass("Tool")
    local ToolData = AnyTool and ItemNames[AnyTool.Name]

    if AnyTool and ToolData and Toggles.InfiniteItems.Value and Options.InfiniteItemsList.Value[ToolData] then        
        Drops.ChildAdded:Once(function(NewTool)
            local Prompt = NewTool:FindFirstChild("ModulePrompt")
            local RealPrompt = FakePrompts[Object]
            if Prompt then Functions.FirePrompt(Prompt) end
            if RealPrompt then Functions.FirePrompt(RealPrompt) end
        end)
        
        Character.ChildAdded:Once(function(NewTool)
            if NewTool.Name == "Shears" then 
                local sound = NewTool:FindFirstChild("Handle") and NewTool.Handle:FindFirstChild("sound_promptend")
                if sound then sound:Play() end
            end
        end)
        
        RemotesFolder.DropItem:FireServer(AnyTool)
    else
        local RealPrompt = FakePrompts[Object]
        if RealPrompt then
            Functions.FirePrompt(RealPrompt)
        else

        end
    end
end))

--[[table.insert(Connections, ProximityPromptService.PromptTriggered:Connect(function(Object)
	if not Object:GetAttribute("FakePrompt") then return end

	local Tool
	for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end

	local Prompt = Object

	local IsLockPrompt = LockPromptNames[Object.Name]
		or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
		or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
	if IsLockPrompt then
		-- if Options.AutoInteractIgnoreList.Value["Locks"] then return end
		local HasKey = false
		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
		if not HasKey then return end
	end

	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end

	if Tool and table.find(AnimateToolNames, Tool.Name) and UseAnimation and UseAnimationBreak then
		UseAnimation:Stop()
		UseAnimationBreak:Stop()
		UseAnimationBreak:Play()
		if Tool.Name == "Shears" then Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end
	end

	local AnyTool = Character:FindFirstChildOfClass("Tool")
	local ToolData = AnyTool and ItemNames[AnyTool.Name]
	if AnyTool and ToolData and Toggles.InfiniteItems.Value and Options.InfiniteItemsList.Value[ToolData] then
		Drops.ChildAdded:Once(function(NewTool)
			local Prompt = NewTool:FindFirstChild("ModulePrompt")
			local RealPrompt = FakePrompts[Object]
			Functions.FirePrompt(Prompt)
			Functions.FirePrompt(RealPrompt)
		end)
		Character.ChildAdded:Once(function(NewTool)
			if NewTool.Name == "Shears" then NewTool:WaitForChild("Handle"):WaitForChild("sound_promptend"):Play() end
		end)
		RemotesFolder.DropItem:FireServer(AnyTool)
	else
		local RealPrompt = FakePrompts[Object]
		Functions.FirePrompt(RealPrompt)
	end
end))]]

table.insert(Connections, CollisionPart:GetPropertyChangedSignal("Anchored"):Connect(function()
    if CollisionClone and CollisionPart.Anchored and not Character:GetAttribute("Hiding") then
	    Lagging = true
	    CollisionClone.Massless = true
	    task.wait(1)
	    Lagging = false
    end
end))

local QueneDone = false
local ObjectQueue = {}
local AllowedInstances = {
	Lava=true, GoldPile=true, KeyObtain=true, KeyObtainFake=true, Drakobloxxer=true, FuseObtain=true,
	MinesGenerator=true, JeffTheKiller=true, Snare=true, FakeDoor=true, DoorFake=true, SideroomSpace=true,
	ChestBox=true, ChestBoxLocked=true, Chest_Vine=true, Locker_Small_Locked=true, Toolbox=true,
	Toolbox_Locked=true, Wardrobe=true, ["Wardrobe-FOOLS26"]=true, Toolshed=true, Toolshed_Small=true,
	Bed=true, MinesAnchor=true, Double_Bed=true, RetroWardrobe=true, Backdoor_Wardrobe=true,
	Rooms_Locker=true, Rooms_Locker_Fridge=true, Locker_Large=true, FigureRig=true, FigureRagdoll=true,
	TimerLever=true, Lever=true, Seek_Arm=true, ChandelierObstruction=true, ScaryWall=true, Ladder=true,
	CircularVent=true, Dumpster=true, SquareGrate=true, TriggerEventCollision=true, GrumbleRig=true,
	GiggleCeiling=true, MinesGateButton=true, ElectricalKeyObtain=true, LibraryHintPaper=true,
	WaterPump=true, CringlePresent=true, Wheel=true, PickupItem=true, LiveHintBook=true,
	LiveBreakerPolePickup=true, LeverForGate=true, GloomPile=true, SeekFloodline=true, Door=true,
	Green_Herb=true, Bridge=true, MouseHole=true, BananaPeel=true, NannerPeel=true, PowerupPad=true,
	IndustrialGate=true, CollisionFloor=true, ElevatorCar=true, Wax_Door=true, ThingToOpen=true,
	MovingDoor=true, StardustPickup=true, Hole=true, Groundskeeper=true, MandrakeLive=true,
	GardenGateButton=true, LotusPetalPickup=true, VineGuillotine=true, LiveEntityBramble=true,
	RiftSpawn=true, ElevatorBreaker=true, RunnerNodes=true, PathLights=true, DuckBoard=true,
	Padlock=true, EyestalkEndCutscene=true, MinecartRig=true, SeekMovingNewClone=true
}

Functions.QueueObject = function(Object)
	if not AllowedInstances[Object.Name] and Object.ClassName ~= "ProximityPrompt" and Object.Parent ~= CurrentRooms and not ItemNames[Object.Name] then
		return
	end
	table.insert(ObjectQueue, Object)
end

for _, Object in workspace:GetDescendants() do
	task.spawn(function()
        Functions.QueueObject(Object)
    end)
end

QueneDone = true
table.insert(Connections, workspace.DescendantAdded:Connect(function(Object)
	Functions.QueueObject(Object)
end))

Functions.Hiding = function()
	for _, Object in pairs(CurrentRooms:GetDescendants()) do
        if Object:IsA("ObjectValue") and Object.Value == LocalPlayer then
            return true
        end
	end
	return false
end

game.DescendantAdded:Connect(function(Child)
    if Toggles.BookESP and Child.Name == 'LiveHintBook' then
        addesp(Child, "Book", Color3.new(1, 0, 0))
    end
end)

task.spawn(function()
	while task.wait(0.1) do
		local room = CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
		if not room then
			continue
		end

		local assets = room:FindFirstChild("Assets")
		if not assets then
			continue
		end

		if Toggles.AntiSeekObstructions.Value then
			for _, obj in ipairs(assets:GetChildren()) do
				if obj.Name == "ChandelierObstruction" and obj:FindFirstChild("HurtPart") then
					obj.HurtPart.CanTouch = false
				elseif obj.Name == "Seek_Arm" and obj:FindFirstChild("AnimatorPart") then
					obj.AnimatorPart.CanTouch = false
					obj.AnimatorPart.Transparency = 0.7
					obj.AnimatorPart.Color = Color3.fromRGB(0, 255, 0)
				end
			end
		else
			for _, obj in ipairs(assets:GetChildren()) do
				if obj.Name == "ChandelierObstruction" and obj:FindFirstChild("HurtPart") then
					obj.HurtPart.CanTouch = true
				elseif obj.Name == "Seek_Arm" and obj:FindFirstChild("AnimatorPart") then
					obj.AnimatorPart.CanTouch = true
					obj.AnimatorPart.Transparency = 1
					obj.AnimatorPart.Color = Color3.fromRGB(255, 255, 255)
				end
			end
		end
	end
end)

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local Object = table.remove(ObjectQueue, 1)
    if not Object then return end

    if Object.ClassName ~= "ProximityPrompt" then
        return
    end

    if Object:GetAttribute("FakePrompt") then
        return
    end

    local LockPromptNames = {
        UnlockPrompt = true,
        SkullPrompt = true,
        LockPrompt = true,
        ThingToEnable = true,
        FusesPrompt = true,
        ActivateEventPrompt = true,
    }

    local IsLockPrompt = LockPromptNames[Object.Name]
        or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
        or (
            Object.Parent
            and Object.Parent.Parent
            and Object.Parent.Parent.Name == "Locker_Small_Locked"
            and Object.Name == "ActivateEventPrompt"
        )

    if not IsLockPrompt then
        return
    end

    local FakePrompt = Object:Clone()
    FakePrompt:SetAttribute("FakePrompt", true)
    FakePrompt.Name = Object.Name .. "_Fake"
    FakePrompt.Parent = Object.Parent

    FakePrompts[FakePrompt] = Object

    Object.Parent = PromptContainer

    Object.Destroying:Once(function()
        if FakePrompt and FakePrompt.Parent then
            FakePrompt:Destroy()
        end
    end)
end))

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if not Character or not Character:FindFirstChildOfClass("Humanoid") or Character.Humanoid.Health <= 0 then
		return
	end

	if Toggles.EnableWalkSpeed.Value then
		Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Functions.GetCurrentSpeed() + Options.WalkspeedSlider.Value
	end

	--[[if CollisionClone and Character:FindFirstChild("CollisionPart") then
		CollisionClone.Massless = Character.CollisionPart.Anchored
	end]]

	if Lagging or (Options.WalkspeedSlider.Value <= 6 --[[and Options.FlySpeed.Value <= 21]]) then
		CollisionClone.Massless = true
	end

	if Toggles.Noclip.Value then
		for _, v in ipairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end

	if Main_Game then
        if Toggles.RemoveCameraShake.Value then
            Main_Game.csgo = CFrame.new() 
        end
        Main_Game.spring.Speed = Toggles.RemoveCameraBobbing.Value and 9e9 or 9
    end

	Camera.FieldOfView = Options.FOVSlider.Value

	if Toggles.AntiEyes.Value and workspace:FindFirstChild("Eyes") then
		RemotesFolder.MotorReplication:FireServer(-890)
	end

	if Toggles.ThirdPerson.Value then
		Camera.CFrame = Camera.CFrame * CFrame.new(Options.OffsetX.Value, Options.OffsetY.Value, Options.OffsetZ.Value)
    end

	for _, part in ipairs(Character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name == "Head" then
			part.LocalTransparencyModifier = Toggles.ThirdPerson.Value and 0 or 1
		elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
			part.Handle.LocalTransparencyModifier = Toggles.ThirdPerson.Value and 0 or 1
		end
	end

	if Toggles.FastClosetExit.Value and Character.Humanoid.MoveDirection.Magnitude > 0 then
		local camLock = RemotesFolder:FindFirstChild("CamLock") or ReplicatedStorage:FindFirstChild("CamLock", true)
		if camLock then
			camLock:FireServer()
		end
	end

	if Toggles.CrouchSpoof.Value then
		local crouchRem = RemotesFolder:FindFirstChild("Crouch") or ReplicatedStorage:FindFirstChild("Crouch", true)
		if crouchRem then
			crouchRem:FireServer(true) 
		end
	end
	
	if Toggles.DoorReach.Value and game.ReplicatedStorage:FindFirstChild("GameData") and game.ReplicatedStorage.GameData:FindFirstChild("LatestRoom") then
		local latestRoomIdx = tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
		local room = workspace.CurrentRooms:FindFirstChild(latestRoomIdx)
		if room and room:FindFirstChild("Door") and room.Door:FindFirstChild("ClientOpen") then
			if (Character.HumanoidRootPart.Position - room.Door.Door.Position).Magnitude < Options.DoorReachRange.Value then
				room.Door.ClientOpen:FireServer()
			end
		end
	end

	if Toggles.Ambient.Value then
		Lighting.GlobalShadows = false 
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	end

	Character:SetAttribute("CanJump", Toggles.EnableJump.Value)
	Character:SetAttribute("CanSlide", Toggles.EnableSlide.Value)

    if Toggles.EnableWalkSpeed.Value and not Functions.Hiding() then
		RemotesFolder.Crouch:FireServer(true, true)
	end
end))

task.spawn(function()
	while true do
		task.wait(0.5)
		if not Toggles.KnobCollector or not Toggles.KnobCollector.Value then continue end
		local root = Character and Character:FindFirstChild("HumanoidRootPart")
		if not root then continue end
		local grabRange = Options.KnobRadius and Options.KnobRadius.Value or 20
		for _, pile in ipairs(workspace:GetDescendants()) do
			if (pile.Name == "GoldPile" or pile.Name == "Knob" or pile.Name == "GoldKnob") then
				local hitbox = pile:IsA("BasePart") and pile or pile:FindFirstChildWhichIsA("BasePart")
				if hitbox and (root.Position - hitbox.Position).Magnitude <= grabRange then
					for _, prompt in ipairs(pile:GetDescendants()) do
						if prompt:IsA("ProximityPrompt") and prompt.Enabled then
							Functions.FirePrompt(prompt)
						end
					end
				end
			end
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
	repeat task.wait() until LocalPlayer:HasAppearanceLoaded()
	Character = newChar
	Modules = LocalPlayer.PlayerGui:WaitForChild("MainUI"):WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("RemoteListener"):WaitForChild("Modules")
	Camera = workspace.CurrentCamera
	SetupCollisionClone(Character)
	UpdateRoomAssets()
end)

SettingsBox:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder("NebulaHub")
SaveManager:SetFolder("Nebula hub/DOORS")
SaveManager:SetSubFolder("DOORS")
SaveManager:BuildConfigSection(Tabs['UISettings'])
ThemeManager:ApplyToTab(Tabs['UISettings'])

Library.ToggleKeybind = Options.MenuKeybind 

SettingsBox:AddToggle("ShowKeybinds", {
	Text = "Show Keybinds",
	Default = false,
	Tooltip = "shows keybinds for toggles",
}):OnChanged(function()
	Library.KeybindFrame.Visible = Toggles.ShowKeybinds.Value
end)

SettingsBox:AddToggle("ShowCustomCursor", {
	Text = "Show Custom Cursor",
	Default = Library.IsMobile == true and true or false,
	Tooltip = "shows u a custom cursor",
}):OnChanged(function()
	Library.ShowCustomCursor = Toggles.ShowCustomCursor.Value
end)

SettingsBox:AddButton({
	Text = "Unload",
	Func = function()
		Library:Unload()
		ESPLibrary:Unload()

		for _, con in ipairs(Connections) do
			if con then
				con:Disconnect()
				con = nil
			end
		end
	end
})

SettingsBox:AddButton({
	Text = "Copy discord invite",
	Func = function()
        local Success, Result = pcall(function()
        local Clipboard = toclipboard or setclipboard
            Clipboard("https://discord.gg/UVZzD4TdDY")
        end)
        if Success then
            Functions.Notify({
                Title = "Notification",
                Body = "Set invite to clipboard!"
            })
        else
            Functions.Notify({
                Title = "Error",
                Body = "Failed to copy invite, copy this: https://discord.gg/UVZzD4TdDY"
            })
        end
    end
})
