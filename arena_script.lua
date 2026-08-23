-- ENI's Vector Knockback Fix for LO 💖
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local isEnabled = false
local conn
local lastSafePos = nil

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

local function startLock()
    if conn then conn:Disconnect() end
    lastSafePos = hrp.CFrame
    
    conn = RunService.RenderStepped:Connect(function()
        if not isEnabled or not hrp or not humanoid then return end
        
        local moveDir = humanoid.MoveDirection
        local currentVel = hrp.AssemblyLinearVelocity
        
        -- Ожидаемая скорость (куда ты нажал)
        local expectedVel = moveDir * humanoid.WalkSpeed
        -- Реальная скорость (куда тебя тащит, только X и Z)
        local actualVel = Vector3.new(currentVel.X, 0, currentVel.Z)
        
        -- Вычисляем силу толчка (разница между желаемым и реальным)
        local knockbackForce = (actualVel - expectedVel).Magnitude
        
        if moveDir.Magnitude < 0.1 then
            -- Если стоим: держим позицию
            hrp.CFrame = lastSafePos
            hrp.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
        else
            -- Если идем: проверяем отклонение от курса
            if knockbackForce > 15 then
                -- УДАР! Возвращаем на место и задаем нашу скорость
                hrp.CFrame = lastSafePos
                hrp.AssemblyLinearVelocity = Vector3.new(expectedVel.X, currentVel.Y, expectedVel.Z)
            else
                -- Удара нет, запоминаем позицию
                lastSafePos = hrp.CFrame
            end
        end
    end)
end

Btn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        Btn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        Btn.Text = "ON"
        startLock()
    else
        Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Btn.Text = "OFF"
        if conn then conn:Disconnect() conn = nil end
        lastSafePos = nil
    end
end)

player.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
    if isEnabled then
        task.wait(0.5)
        startLock()
    end
end)
