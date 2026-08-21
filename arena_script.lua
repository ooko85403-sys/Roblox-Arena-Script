-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

-- Initialize Luraph globals if they do not exist.
loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()

-- Constants.
local HIGH_DENSITY = 10000

-- Services.
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")

-- State.
local localPlayer = playersService.LocalPlayer
local isActive = false
local descendantConnection = nil
local namecallHook = nil
local uiButton = nil
local screenGui = nil

---This is called when initialization errors.
---@param error string
local function onInitializeError(error)
	warn("Failed to initialize Anti-Knockback.")
	warn(error)
	warn(debug.traceback())
end

---Applies heavy physical properties to all character parts.
---@param character Model
local function applyDensity(character)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CustomPhysicalProperties = PhysicalProperties.new(HIGH_DENSITY, 0.3, 0.5, 1, 1)
		end
	end
end

---Removes heavy physical properties.
---@param character Model
local function removeDensity(character)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CustomPhysicalProperties = nil
		end
	end
end

---Destroys external physics objects added to the character.
---@param descendant Instance
local function onDescendantAdded(descendant)
	if descendant:IsA("BodyVelocity") or descendant:IsA("VectorForce") or descendant:IsA("BodyForce") or descendant:IsA("LinearVelocity") then
		task.spawn(function()
			descendant:Destroy()
		end)
	end
end

---Toggles the anti-knockback features on or off.
local function toggleScript()
	isActive = not isActive
	local character = localPlayer.Character

	if isActive then
		uiButton.Text = "ON"
		uiButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)

		if character then
			applyDensity(character)
			if descendantConnection then descendantConnection:Disconnect() end
			descendantConnection = character.DescendantAdded:Connect(onDescendantAdded)
		end
	else
		uiButton.Text = "OFF"
		uiButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)

		if character then
			removeDensity(character)
		end

		if descendantConnection then
			descendantConnection:Disconnect()
			descendantConnection = nil
		end
	end
end

---Creates the toggle UI.
local function createUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SumoAntiKnockback"
	screenGui.ResetOnSpawn = false

	-- Try to parent to hidden UI container, fallback to CoreGui.
	local success, hiddenUI = pcall(gethui)
	if success and hiddenUI then
		screenGui.Parent = hiddenUI
	else
		screenGui.Parent = coreGui
	end

	uiButton = Instance.new("TextButton")
	uiButton.Name = "ToggleButton"
	uiButton.Size = UDim2.new(0, 100, 0, 50)
	uiButton.Position = UDim2.new(0, 20, 1, -70)
	uiButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	uiButton.Text = "OFF"
	uiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	uiButton.TextSize = 24
	uiButton.Font = Enum.Font.GothamBold
	uiButton.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = uiButton

	uiButton.MouseButton1Click:Connect(toggleScript)
end

---Main initialization function.
local function initializeScript()
	createUI()

	-- Hook namecall to block impulses globally.
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local method = getnamecallmethod()

		if not checkcaller() and isActive and typeof(self) == "Instance" and localPlayer.Character and self:IsDescendantOf(localPlayer.Character) then
			if method == "ApplyImpulse" or method == "ApplyImpulseAtCenterOfMass" then
				return
			end
		end

		return oldNamecall(self, ...)
	end))
	namecallHook = oldNamecall

	-- Re-apply state on respawn.
	localPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		if isActive then
			applyDensity(character)
			if descendantConnection then descendantConnection:Disconnect() end
			descendantConnection = character.DescendantAdded:Connect(onDescendantAdded)
		end
	end)
end

-- Safely profile and initialize the script as well as handle errors.
xpcall(initializeScript, onInitializeError)
