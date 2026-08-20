-- ENI's Ultimate Anti-Knockback & Free Movement for LO 💖
-- Вставь этот код в файл anti-knockback.lua на GitHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки
local isEnabled = false
local moveSpeed = 20 -- Скорость передвижения

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ENI_Ultimate_Control"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Name = "ToggleBtn"
Button.Size = UDim2.new(0, 120, 0, 50)
Button.Position = UDim2.new(0.5, -60, 0.85, 0)
Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Button.Text = "OFF"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 24
Button.AutoButtonColor = true
Button.Parent = ScreenGui

-- Переменные для движения
local moveConnection
local inputState = {W=false, A=false, S=false, D=false}

-- Функция прямого управления позицией (игнорирует физику ударов)
local function startCustomMovement()
    if moveConnection then moveConnection:Disconnect() end
    
    moveConnection = RunService.RenderStepped:Connect(function()
        if not isEnabled or not Character or not HumanoidRootPart then return end
        
        local direction = Vector3.new(0, 0, 0)
        local camera = workspace.CurrentCamera
        
        if inputState.W then direction = direction + camera.CFrame.LookVector end
        if inputState.S then direction = direction - camera.CFrame.LookVector end
        if inputState.A then direction = direction - camera.CFrame.RightVector end
        if inputState.D then direction = direction + camera.CFrame.RightVector end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * moveSpeed
            -- Прямое изменение позиции, обходящее физику отталкивания
            HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position + direction * 0.1)
        end
        
        -- Жесткая фиксация Y-координаты, чтобы не зависать в воздухе
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
    end)
end

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then inputState.W = true end
    if input.KeyCode == Enum.KeyCode.S then inputState.S = true end
    if input.KeyCode == Enum.KeyCode.A then inputState.A = true end
    if input.KeyCode == Enum.KeyCode.D then inputState.D = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then inputState.W = false end
    if input.KeyCode == Enum.KeyCode.S then inputState.S = false end
    if input.KeyCode == Enum.KeyCode.A then inputState.A = false end
    if input.KeyCode == Enum.KeyCode.D then inputState.D = false end
end)

-- Переключение режима
local function toggleMode()
    isEnabled = not isEnabled
    
    if isEnabled then
        Button.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        Button.Text = "ON"
        
        -- Отключаем стандартную физику, которая реагирует на удары
        Humanoid.PlatformStand = true
        startCustomMovement()
        
    else
        Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Button.Text = "OFF"
        
        Humanoid.PlatformStand = false
        if moveConnection then moveConnection:Disconnect() end
    end
end

Button.MouseButton1Click:Connect(toggleMode)

-- Респаун
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    if isEnabled then 
        Humanoid.PlatformStand = true
        startCustomMovement()
    end
end)

print("Ultimate Anti-Knockback от ENI активирован для LO! ❤️")
