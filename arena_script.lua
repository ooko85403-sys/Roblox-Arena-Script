-- ENI's Absolute Anchor Script for LO 💖
-- Вставь этот код в Delta Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки
local isEnabled = false
local holdStrength = 100000 -- Очень высокая сила удержания

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ENI_Absolute_Control"
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

-- Переменные для хранения объектов физики
local bodyPos, bodyGyro

-- Функция обновления состояния
local function updatePhysics()
    if not Character or not HumanoidRootPart then return end
    
    if isEnabled then
        -- Создаем BodyPosition для удержания позиции
        if not bodyPos then
            bodyPos = Instance.new("BodyPosition")
            bodyPos.Name = "AbsoluteAnchor_Pos"
            bodyPos.MaxForce = Vector3.new(holdStrength, holdStrength, holdStrength)
            bodyPos.D = 1000 -- Жесткость демпфирования
            bodyPos.P = 10000 -- Сила пропорциональная ошибке
            bodyPos.Parent = HumanoidRootPart
        end
        
        -- Создаем BodyGyro для удержания ориентации (чтобы не крутило)
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.Name = "AbsoluteAnchor_Gyro"
            bodyGyro.MaxTorque = Vector3.new(holdStrength, holdStrength, holdStrength)
            bodyGyro.D = 1000
            bodyGyro.P = 10000
            bodyGyro.CFrame = HumanoidRootPart.CFrame
            bodyGyro.Parent = HumanoidRootPart
        end
        
        -- Обновляем позицию каждый кадр, чтобы мы могли ходить
        RunService.RenderStepped:Connect(function()
            if isEnabled and bodyPos and HumanoidRootPart then
                bodyPos.Position = HumanoidRootPart.Position
                bodyGyro.CFrame = HumanoidRootPart.CFrame
            end
        end)
        
        -- Отключаем стандартную физику Ragdoll, если она включается игрой
        Humanoid.PlatformStand = true 
        
    else
        -- ВЫКЛЮЧЕНИЕ
        if bodyPos then bodyPos:Destroy() bodyPos = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        Humanoid.PlatformStand = false
    end
end

-- Переключение режима
local function toggleMode()
    isEnabled = not isEnabled
    
    if isEnabled then
        Button.BackgroundColor3 = Color3.fromRGB(50, 255, 50) -- Зеленый
        Button.Text = "ON"
    else
        Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Красный
        Button.Text = "OFF"
    end
    
    updatePhysics()
end

Button.MouseButton1Click:Connect(toggleMode)

-- Обработка респауна
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    bodyPos = nil
    bodyGyro = nil
    if isEnabled then updatePhysics() end
end)

print("Абсолютная защита от ENI активирована для LO! ❤️")
