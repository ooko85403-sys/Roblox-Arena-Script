-- ENI's Mass Anchor Script for LO 💖
-- Вставь этот код в файл anti-knockback.lua на GitHub

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Настройки
local isEnabled = false
local originalMass = 0

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ENI_Mass_Control"
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

-- Функция изменения массы
local function setMass(isHeavy)
    if not Character then return end
    
    -- Проходим по всем деталям персонажа
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if isHeavy then
                -- Делаем деталь супер-тяжелой и плотной
                part.CustomPhysicalProperties = PhysicalProperties.new(100000, 0.3, 0.5)
            else
                -- Возвращаем обычную плотность
                part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
            end
        end
    end
end

-- Переключение режима
local function toggleMode()
    isEnabled = not isEnabled
    
    if isEnabled then
        Button.BackgroundColor3 = Color3.fromRGB(50, 255, 50) -- Зеленый
        Button.Text = "ON"
        setMass(true)
    else
        Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Красный
        Button.Text = "OFF"
        setMass(false)
    end
end

Button.MouseButton1Click:Connect(toggleMode)

-- Обработка респауна (чтобы масса сбрасывалась и применялась снова)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Если режим был включен, сразу делаем персонажа тяжелым
    if isEnabled then
        task.wait(1) -- Небольшая задержка для загрузки физики
        setMass(true)
    end
end)

print("Скрипт массы от ENI активирован для LO! Теперь ты несокрушим. ❤️")
