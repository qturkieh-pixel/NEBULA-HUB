local getgenv = (getgenv and getgenv) or function() return shared or _G end
local cloneref = (cloneref and cloneref) or function(ref) return ref end

local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))
local Lighting = cloneref(game:GetService("Lighting"))

local repo = (getgenv().LibraryIs == "Linoria") and 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/' or 'https://raw.githubusercontent.com/mstudio45/Obsidian/main/'

local Library = loadstring(game:HttpGet(repo..'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo..'addons/ThemeManager.lua'))()
local SaveManager  = loadstring(game:HttpGet(repo..'addons/SaveManager.lua'))()
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local ClientModules = ReplicatedStorage:FindFirstChild("ModulesClient") or ReplicatedStorage:FindFirstChild("ClientModules") 
local RemoteFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("Bricks")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Modules = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("RemoteListener"):WaitForChild("Modules")

local CollisionClone

local function SetupCollisionClone(char)
	if not char:WaitForChild("CollisionPart", 5) then return end
	CollisionClone = char.CollisionPart:Clone()
	CollisionClone.Name = "CollisionPartClone"
	CollisionClone.Parent = char 
	CollisionClone.Massless = true
	CollisionClone.CanCollide = false

	local crouch = CollisionClone:FindFirstChild("CollisionCrouch")
	if crouch then crouch:Destroy() end
end

SetupCollisionClone(Character)

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
	Footer = "beta",
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
local Exploits = Tabs.Exploits:AddLeftGroupbox('Bypass')
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
		local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("Bricks")
		if rf and rf:FindFirstChild("PlayAgain") then rf.PlayAgain:FireServer() end
	end
})

MiscBox:AddButton({
	Text = "Back to Lobby",
	Tooltip = "Teleports you back to the main lobby. Click twice.",
	DoubleClick = true,
	Func = function()
		local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("Bricks")
		if rf and rf:FindFirstChild("Lobby") then rf.Lobby:FireServer() end
	end
})

MiscBox:AddButton({
	Text = "Revive",
	Tooltip = "Uses your revive if available. Click twice.",
	DoubleClick = true,
	Func = function()
		local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("Bricks")
		if rf and rf:FindFirstChild("Revive") then rf.Revive:FireServer() end
	end
})

MiscBox:AddButton({
	Text = "Kill Self",
	Tooltip = "Kills your character. May take a moment. Click twice.",
	DoubleClick = true,
	Func = function()
		local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("Bricks")
		local hum = Character and Character:FindFirstChildOfClass("Humanoid")
		if rf and rf:FindFirstChild("Underwater") then
			rf.Underwater:FireServer(true)
		elseif hum then
			hum.Health = 0
		end
	end
})
Floors:AddLabel("coming soon")

Credits:AddLabel("qai (owner)", true)
Credits:AddLabel("realheckersbrother (main dev)", true)
Credits:AddLabel("kardincat (coder)", true)

Information:AddLabel("nebula hub:)", true)
Information:AddLabel("any bugs? REPORT IN DISCORD SERVER!", true)
Information:AddLabel("https://discord.gg/2tTc7NmYR3", true)
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

local function checkEntity(v)
	if not Options.EntitiesPicker then
		return
	end
	local picker = Options.EntitiesPicker.Value
	if v.Name == "RushMoving" and picker["Rush"] then
		if Toggles.EntitesNotify.Value then
			Library:Notify("Rush has spawned! HIDE!", 3)
		end
		if Toggles.EntitesESP.Value then
			addentityesp(v, "Rush") 
		end
	elseif v.Name == "AmbushMoving" and picker["Ambush"] then
		if Toggles.EntitesNotify.Value then
			Library:Notify("Ambush has spawned! HIDE!", 3)
		end
		if Toggles.EntitesESP.Value then
			addentityesp(v, "Ambush")
		end
	end
end

workspace.ChildAdded:Connect(checkEntity)

Settings:AddSlider("FOVSlider", {
	Text = "FOV Slider",
	Default = 70,
	Min = 10,
	Max = 120,
	Rounding = 1,
	Compact = true
})

Settings:AddToggle('SpectateEntity', {
	Text = "Spectate Entity",
	Default = false 
})

Settings:AddToggle('EntitesNotify', {
	Text = "Notify Entities",
	Default = false
})
Settings:AddDropdown("EntitiesPicker", {
	Values = { 
		"Rush", "Ambush" 
	},
	Default = 1,
	Multi = true,
	Text = "Entities"
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
		if A90 then A90.Name = Value and "_A90" or "A90" end
	end
})
Anti:AddToggle('AntiScreech', { 
	Text = "Anti-Screech", 
	Default = false,
	Callback = function(Value)
		local Screech = Modules:FindFirstChild("Screech") or Modules:FindFirstChild("_Screech")
		if Screech then Screech.Name = Value and "_Screech" or "Screech" end
	end
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
	Text = "Gold Knob Farm",
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

Toggles.EnableWalkSpeed:OnChanged(function(Value)
	if not Value and Character:FindFirstChildOfClass("Humanoid") then
		Character.Humanoid.WalkSpeed = Options.WalkspeedSlider.Value 
	end
end)
local PartProperties = {}
	CustomPhysics = PhysicalProperties.new(
		100,
		Character.HumanoidRootPart.CustomPhysicalProperties.Friction,
		Character.HumanoidRootPart.CustomPhysicalProperties.Elasticity,
		Character.HumanoidRootPart.CustomPhysicalProperties.FrictionWeight,
		Character.HumanoidRootPart.CustomPhysicalProperties.ElasticityWeight
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

table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(UpdateRoomAssets))

table.insert(Connections, UserInputService.JumpRequest:Connect(function()
	if Toggles.InfiniteJump.Value and Character:FindFirstChildOfClass("Humanoid") then
		task.wait(0.05)
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if not Character or not Character:FindFirstChildOfClass("Humanoid") or Character.Humanoid.Health <= 0 then
		return
	end

	if CollisionClone and Character:FindFirstChild("CollisionPart") then
		CollisionClone.Massless = Character.CollisionPart.Anchored or true
	end

	if Toggles.Noclip.Value then
		for _, v in ipairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end

	Camera.FieldOfView = Options.FOVSlider.Value

	if Toggles.AntiEyes.Value and workspace:FindFirstChild("Eyes") then
		RemoteFolder.MotorReplication:FireServer(-890)
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

	if Toggles.SpectateEntity.Value then
		local entity = workspace:FindFirstChild("RushMoving") or workspace:FindFirstChild("AmbushMoving")
		if entity and entity.PrimaryPart then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, entity.PrimaryPart.Position)
		end
	end

	if Toggles.FastClosetExit.Value and Character.Humanoid.MoveDirection.Magnitude > 0 then
		local camLock = RemoteFolder:FindFirstChild("CamLock") or ReplicatedStorage:FindFirstChild("CamLock", true)
		if camLock then
			camLock:FireServer()
		end
	end

	if Toggles.CrouchSpoof.Value then
		local crouchRem = RemoteFolder:FindFirstChild("Crouch") or ReplicatedStorage:FindFirstChild("Crouch", true)
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

	if Toggles.EnableWalkSpeed.Value then
		local hum = Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = Options.WalkspeedSlider.Value
				game:GetService("ReplicatedStorage").RemotesFolder.Crouch:FireServer(true, true)
		end
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
							fireproximityprompt(prompt)
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
	Text = "copy discord invite",
	Func = function()
		toclipboard("https://discord.gg/UVZzD4TdDY")
	end
})	
