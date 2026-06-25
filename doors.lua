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
	Title = 'Nebula Hub',
	Center = true,
	AutoShow = true
})

local Tabs = {
	Info = Window:AddTab('Info', "circle-user-round"),
	Main = Window:AddTab('Main', "shield"),
	Exploits = Window:AddTab('Exploits', "axe"),
	Visuals = Window:AddTab('Visuals', "camera"),
	Fun = Window:AddTab('Fun & Trolling', "car"),
	Scripts = Window:AddTab('Scripts', "code"),
	UISettings = Window:AddTab('Configuration', "house"),
}

local Information = Tabs.Info:AddLeftGroupbox('Information')
local Movement = Tabs.Main:AddLeftGroupbox('Movement')
local Exploits = Tabs.Exploits:AddLeftGroupbox('Bypass')
local Anti = Tabs.Exploits:AddRightGroupbox('Anti')
local Visuals = Tabs.Visuals:AddLeftGroupbox('Visuals')
local Settings = Tabs.Visuals:AddRightGroupbox('settings')
local SettingsBox = Tabs.UISettings:AddLeftGroupbox('UI')
local Fun = Tabs.Fun:AddLeftGroupbox('Fun & Trolling')
local ScriptsBox = Tabs.Scripts:AddLeftGroupbox('Scripts')
local Credits = Tabs.UISettings:AddRightGroupbox("Credits")

ScriptsBox:AddButton({
	Text = "Load IYHUB",
	Func = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/RedTree1222/IYHUB/refs/heads/main/IYHUB.luau"))()
	end
})

ScriptsBox:AddButton({
	Text = "Load ContentHub",
	Func = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/RedTree1222/Content/refs/heads/main/ContentHub.luau"))()
	end
})

Credits:AddLabel("qai (owner)", true)
Credits:AddLabel("firebacon (credits maker)", true)
Credits:AddLabel("realheckersbrother (main dev)", true)
Credits:AddLabel("kardincat (coder)", true)

Information:AddLabel("nebula hub:)", true)
Information:AddLabel("any bugs? REPORT IN DISCORD SERVER!", true)
Information:AddLabel("https://discord.gg/2tTc7NmYR3", true)
Fun:AddButton({
	Text = "Fling doors",
	Func = function()
		for _, Door in ipairs(workspace:GetDescendants()) do
			if Door.Name == "Door" and isnetworkowner(Door) then
				local vel = Door:FindFirstChild("DoorBreakVelocity") or Instance.new("BodyPosition")
				vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				vel.Name = "DoorBreakVelocity"
				vel.Position = (Door:GetAttribute("OriginalPosition") or Door.Position) + Vector3.new(math.random(-125, 125), math.random(-125, 125), math.random(-125, 125))
				vel.Parent = Door
			end
		end
	end
})

Visuals:AddToggle('Door', {
	Text = "Door",
	Default = false
})

Visuals:AddToggle('Key',{
	Text = "Key",
	Default = false
})

Visuals:AddToggle('GateLeverEsp', {
	Text = "Gate lever Esp",
	Default = false
})

Visuals:AddToggle('EntitesESP', { 
	Text = "Entities ESP",
	Default = false
})

Visuals:AddDropdown("EntitiesPicker", {
	Values = { 
		"Rush", "Ambush" 
	},
	Default = 1,
	Multi = true,
	Text = "Entities"
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
	Default = 90,
	Min = 10,
	Max = 120,
	Rounding = 1,
	Compact = true
})

Settings:AddToggle('SpectateEntity', {
	Text = "Entity POV",
	Default = false 
})

Settings:AddToggle('EntitesNotify', {
	Text = "Entities Notify",
	Default = false
})

Settings:AddDivider()

Settings:AddToggle('ThirdPerson', {
	Text = "Third Person",
	Default = false
}):AddKeyPicker("KeyPicker", {
	Default = "V",
	SyncToggleState = true, 
	Mode = "Toggle",
	Text = "Third person"
})

Settings:AddSlider("OffsetX", {
	Text = "X offset",
	Default = -1,
	Min = -10,
	Max = 15,
	Rounding = 1,
	Compact = true
})

Settings:AddSlider("OffsetY", {
	Text = "Y offset",
	Default = -0.1,
	Min = -10,
	Max = 15,
	Rounding = 1,
	Compact = true
})

Settings:AddSlider("OffsetZ", {
	Text = "Z offset",
	Default = 1,
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
	Max = 60,
	Rounding = 1,
	Compact = true
})

Movement:AddToggle('EnableWalkSpeed', {
	Text = "Enable Speed", 
	Tooltip = "enable a walkspeed as fast as u would like.",
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
	Default = false
}):AddKeyPicker("KeyPicker3", {
	Default = "J",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Infinite jump"
})

Exploits:AddToggle('BypassSpeed', {
	Text = "Speed Bypass",
	Tooltip = "bypasses the server speed check while using speed boost.",
	Default = false
})

Exploits:AddToggle('CrouchSpoof', {
	Text = "Crouch Spoof",
	Tooltip = "figure wont hear you so it technically makes the game thing you are crouching",
	Default = false
})

Exploits:AddToggle('DoorReach', {
	Text = "Door Reach",
	Tooltip = "if you use this u will open doors in longer range.",
	Default = false
})

Exploits:AddSlider("DoorReachRange", {
	Text = "Door Reach Range",
	Default = 30,
	Min = 15,
	Max = 30,
	Rounding = 1,
	Tooltip = "range slider for door reach",
	Compact = true
})

Visuals:AddToggle('Ambient', { 
	Text = "Ambient", 
	Default = false,
	Tooltip = "makes all rooms bright",
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

Toggles.Noacceleration:OnChanged(function(Value)
	if not Value and Character:FindFirstChild("HumanoidRootPart") then 
		Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(100, 0.5, 0.5)
		-- Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0.5, 0.5) 
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
			if Toggles.BypassSpeed.Value then
				local crouchRem = RemoteFolder:FindFirstChild("Crouch") or ReplicatedStorage:FindFirstChild("Crouch", true)
				if crouchRem then
					crouchRem:FireServer(false, Options.WalkspeedSlider.Value)
				end
			end
		end
	end
end))

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
