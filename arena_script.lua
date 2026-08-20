local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local isEnabled = false
local lastSafePos = nil
local renderConn, heartbeatConn

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

local function start()
    if renderConn then renderConn:Disconnect() end
    if heartbeatConn then heartbeatConn:Disconnect() end

    renderConn = RunService.RenderStepped:Connect(function()
        if not isEnabled or not hrp then return end
        lastSafePos = hrp.Position
    end)

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not isEnabled or not hrp or not hum or not lastSafePos then return end

        local vel = hrp.AssemblyLinearVelocity
        local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
        local maxSpeed = hum.WalkSpeed + 2 

        if horizontalSpeed > maxSpeed then
            hrp.CFrame = CFrame.new(lastSafePos.X, hrp.Position.Y, lastSafePos.Z) * hrp.CFrame.Rotation
            hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
        end
    end)
end

Btn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        Btn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        Btn.Text = "ON"
        start()
    else
        Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Btn.Text = "OFF"
        if renderConn then renderConn:Disconnect() end
        if heartbeatConn then heartbeatConn:Disconnect() end
    end
end)

player.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
    if isEnabled then task.wait(0.5); start() end
end)
