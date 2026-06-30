-- إنشاء الواجهة البرمجية (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TeleportBtn = Instance.new("TextButton")
local NewLocBtn = Instance.new("TextButton") -- الزر الجديد
local ResetBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- إعدادات الواجهة
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ATMScript_Updated"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -90) -- تعديل الموقع قليلاً
MainFrame.Size = UDim2.new(0, 200, 0, 190) -- زيادة الطول ليستوعب الزر الجديد
MainFrame.Active = true
MainFrame.Draggable = true 

local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- العنوان
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "ATM HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

-- زر الـ ATM (الأصلي)
TeleportBtn.Name = "TeleportBtn"
TeleportBtn.Parent = MainFrame
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TeleportBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
TeleportBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
TeleportBtn.Font = Enum.Font.Gotham
TeleportBtn.Text = "Go to next ATM"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 14
Instance.new("UICorner", TeleportBtn)

-- [[ الزر الجديد: الانتقال للإحداثيات المحددة ]]
NewLocBtn.Name = "NewLocBtn"
NewLocBtn.Parent = MainFrame
NewLocBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- لون أخضر مريح
NewLocBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
NewLocBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
NewLocBtn.Font = Enum.Font.Gotham
NewLocBtn.Text = "Teleport to Pos"
NewLocBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NewLocBtn.TextSize = 14
Instance.new("UICorner", NewLocBtn)

-- زر الريسيت (الأصلي)
ResetBtn.Name = "ResetBtn"
ResetBtn.Parent = MainFrame
ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
ResetBtn.Position = UDim2.new(0.3, 0, 0.75, 0)
ResetBtn.Size = UDim2.new(0.4, 0, 0.15, 0)
ResetBtn.Font = Enum.Font.Gotham
ResetBtn.Text = "Reset Cache"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 12
Instance.new("UICorner", ResetBtn)

-- المنطق البرمجي
local visitedATMs = {}

-- وظيفة الانتقال للـ ATM
local function teleportToATM()
    local character = game.Players.LocalPlayer.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local spawnerFolder = workspace.Game.Jobs.CriminalATMSpawners
    local found = false

    for _, spawner in pairs(spawnerFolder:GetChildren()) do
        local atmPart = spawner:FindFirstChild("CriminalATM") 
            and spawner.CriminalATM:FindFirstChild("NormalModel") 
            and spawner.CriminalATM.NormalModel:FindFirstChild("ATM")

        if atmPart and atmPart:IsA("BasePart") then
            if not visitedATMs[atmPart] then
                rootPart.CFrame = atmPart.CFrame + Vector3.new(0, 3, 0)
                visitedATMs[atmPart] = true
                found = true
                break
            end
        end
    end

    if not found then
        TeleportBtn.Text = "Finished!"
        wait(1)
        TeleportBtn.Text = "Go to next ATM"
    end
end

-- وظيفة الزر الجديد (Vector3)
NewLocBtn.MouseButton1Click:Connect(function()
    local character = game.Players.LocalPlayer.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-2532.9, 14.9, 4034.1)
    end
end)

TeleportBtn.MouseButton1Click:Connect(teleportToATM)

ResetBtn.MouseButton1Click:Connect(function()
    visitedATMs = {}
    ResetBtn.Text = "Cleared!"
    wait(1)
    ResetBtn.Text = "Reset Cache"
end)

-- نظام السحب للجوال
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
