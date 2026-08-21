-- Version: 1.0.3

-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

-- Initialize Luraph globals if they do not exist.
loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()
getfenv().PP_SCRAMBLE_NUM = function(...) return ... end
getfenv().PP_SCRAMBLE_STR = function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = function(...) return ... end

-- Services.
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")

-- State.
local localPlayer = playersService.LocalPlayer
local isActive = false
local heartbeatConnection = nil
local uiButton = nil
local screenGui = nil

---This is called when initialization errors.
---@param error string
local function onInitializeError(error)
	warn("Failed to initialize Anti-Knockback.")
	warn(error)
	warn(debug.traceback())
end

---Forces the character's horizontal velocity to match only local movement input.
local function protectCharacter()
	local character = localPlayer.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then return end

	local moveDirection = humanoid.MoveDirection
	local currentVelocity = hrp.AssemblyLinearVelocity

	local walkSpeed = humanoid.WalkSpeed
	if typeof(walkSpeed) ~= "number" or walkSpeed ~= walkSpeed then
		walkSpeed = 16
	end

	local yVelocity = currentVelocity.Y
	if yVelocity ~= yVelocity then
		yVelocity = 0
	end

	-- Cancel external horizontal movement while keeping normal walking and falling.
	if moveDirection.Magnitude > 0 then
		hrp.AssemblyLinearVelocity = Vector3.new(moveDirection.X * walkSpeed, yVelocity, moveDirection.Z * walkSpeed)
	else
		hrp.AssemblyLinearVelocity = Vector3.new(0, yVelocity, 0)
	end
end

---Starts the protection loop.
local function startProtection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	heartbeatConnection = runService.Heartbeat:Connect(function()
		if not isActive then return end
		pcall(protectCharacter)
	end)
end

---Stops the protection loop.
local function stopProtection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

---Toggles the anti-knockback features on or off.
local function toggleScript()
	isActive = not isActive

	if isActive then
		uiButton.Text = "ON"
		uiButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		startProtection()
	else
		uiButton.Text = "OFF"
		uiButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
		stopProtection()
	end
end

---Creates the toggle UI.
local function createUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SumoAntiKnockback"
	screenGui.ResetOnSpawn = false

	-- Try to parent to hidden UI container, fallback to CoreGui.
	local success, hiddenUI = pcall(function()
		return gethui()
	end)

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

	-- Protect the click callback from unexpected errors.
	uiButton.MouseButton1Click:Connect(function()
		xpcall(toggleScript, onInitializeError)
	end)
end

---Main initialization function.
local function initializeScript()
	createUI()
end

-- Safely initialize the script and handle errors.
xpcall(initializeScript, onInitializeError)
