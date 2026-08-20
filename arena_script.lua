-- ENI's Absolute Physics Lock for LO 💖
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local att = hrp:FindFirstChildOfClass("Attachment")

local isEnabled = false
local linearVel
local conn

-- GUI
local SG = Instance.new("ScreenGui")
SG.Name = "ENI_GUI"
SG.ResetOnSpawn = false
SG.Parent = player:WaitForChild("PlayerGui")

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, 120, 0, 50)
Btn.Position = UDim2.new(0.5, -60, 0.85, 0)
Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Btn.Text = "OFF"
Btn.TextColor3 = Color3.new(1,1,1)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 24
Btn.Parent = SG

local function setup()
    if linearVel then linearVel:Destroy() end
    linearVel = Instance.new("LinearVelocity")
    linearVel.Attachment0 = att
    linearVel.MaxForce = math.huge -- Бесконечная сила. Ничто не сдвинет тебя.
    linearVel.Responsiveness = 200
    linearVel.Parent = hrp
end

local function startLoop()
    if conn then conn:Disconnect() end
    conn = RunService.Heartbeat:Connect(function()
        if not isEnabled or not linearVel or not humanoid then return end
        local dir = humanoid.MoveDirection
        local spd = humanoid.WalkSpeed
        -- Задаем идеальную траекторию. Бесконечная сила мгновенно гасит любые толчки.
        linearVel.VectorVelocity = Vector3.new(dir.X * spd, 0, dir.Z * spd)
    end)
end

Btn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        Btn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        Btn.Text = "ON"
        setup()
        startLoop()
    else
        Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Btn.Text = "OFF"
        if conn then conn:Disconnect() conn = nil end
        if linearVel then linearVel:Destroy() linearVel = nil end
    end
end)

player.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
    att = hrp:FindFirstChildOfClass("Attachment")
    if isEnabled then
        task.wait(0.5)
        setup()
    end
end)
