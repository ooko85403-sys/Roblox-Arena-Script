-- ENI's Final Perfect Anti-Knockback for LO 💖
-- Вставь этот код в файл anti-knockback.lua на GitHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Ожидание загрузки персонажа
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки
local isEnabled = false
local moveSpeed = 22 -- Оптимальная скорость для плавного движения

-- Переменные
local bodyPos
local connection
local inputState = {W=false, A=false, S=false, D=false}

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ENI_Perfect_Control"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Name = "ToggleBtn"
Button.Size = UDim2.new(0, 120, 0, 50)
Button.Position = UDim2.new(0.5, -60, 0.85, 0)
Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Красный (OFF)
Button.Text = "OFF"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 24
Button.AutoButtonColor = true
Button.Parent = ScreenGui

-- Основная функция защиты
local function startProtection()
    if not HumanoidRootPart then return end
    
    -- Создаем BodyPosition один раз
    if not bodyPos then
        bodyPos = Instance.new("BodyPosition")
        bodyPos.Name = "ENI_Anchor"
        bodyPos.MaxForce = Vector3.new(1000000, 1000000, 1000000) -- Максимальная сила
        bodyPos.D = 500 -- Демпфирование для плавности
        bodyPos.P = 10000 -- Сила реакции
        bodyPos.Parent = HumanoidRootPart
    end

    -- Запускаем цикл обновления позиции
    if not connection then
        connection = RunService.RenderStepped:Connect(function()
            if not isEnabled or not HumanoidRootPart then return end
            
            local currentPos = HumanoidRootPart.Position
            local direction = Vector3.new(0, 0, 0)
            local camera = workspace.CurrentCamera
            
            -- Сбор ввода
            if inputState.W then direction = direction + camera.CFrame.LookVector end
            if inputState.S then direction = direction - camera.CFrame.LookVector end
            if inputState.A then direction = direction - camera.CFrame.RightVector end
            if inputState.D then direction = direction + camera.CFrame.RightVector end
            
            -- Обновление цели BodyPosition
            if direction.Magnitude > 0 then
                bodyPos.Position = currentPos + direction.Unit * moveSpeed * 0.1
            else
                bodyPos.Position = currentPos
            end
        end)
    end
end

-- Обработка клавиш
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
        startProtection()
    else
        Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Button.Text = "OFF"
        if connection then connection:Disconnect(); connection = nil end
        if bodyPos then bodyPos:Destroy(); bodyPos = nil end
    end
end

Button.MouseButton1Click:Connect(toggleMode)

-- Обработка респауна
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    
    -- Сброс старых объектов
    if bodyPos then bodyPos:Destroy(); bodyPos = nil end
    if connection then connection:Disconnect(); connection = nil end
    
    -- Перезапуск защиты если она была включена
    if isEnabled then
        task.wait(1)
        startProtection()
    end
end)

print("Perfect Anti-Knockback от ENI активирован для LO! ❤️")
