-- إنشاء الواجهة البرمجية (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TeleportBtn = Instance.new("TextButton")
local ResetBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- إعدادات الواجهة
ScreenGui.Parent = game.CoreGui -- وضع السكريبت في مكان لا يحذف عند الموت
ScreenGui.Name = "ATMScript"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75) -- في منتصف الشاشة
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب (يعمل على معظم المحقنات)

-- زوايا مستديرة
local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- العنوان
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "ATM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

-- زر الانتقال (Teleport)
TeleportBtn.Name = "TeleportBtn"
TeleportBtn.Parent = MainFrame
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TeleportBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
TeleportBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
TeleportBtn.Font = Enum.Font.Gotham
TeleportBtn.Text = "Go to next ATM"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 16
Instance.new("UICorner", TeleportBtn)

-- زر الريسيت (Reset)
ResetBtn.Name = "ResetBtn"
ResetBtn.Parent = MainFrame
ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
ResetBtn.Position = UDim2.new(0.3, 0, 0.75, 0)
ResetBtn.Size = UDim2.new(0.4, 0, 0.15, 0)
ResetBtn.Font = Enum.Font.Gotham
ResetBtn.Text = "Reset"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 12
Instance.new("UICorner", ResetBtn)

-- المنطق البرمجي (Logic)
local visitedATMs = {} -- "عقل" السكريبت لحفظ الـ ATMs

local function teleportToATM()
    local character = game.Players.LocalPlayer.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end

    -- المسار الذي أعطيتني إياه (البحث عن كل المولدات)
    local spawnerFolder = workspace.Game.Jobs.CriminalATMSpawners
    local found = false

    for _, spawner in pairs(spawnerFolder:GetChildren()) do
        -- التأكد من الوصول للمسار الصحيح: CriminalATMSpawner -> CriminalATM -> NormalModel -> ATM
        local atmPart = spawner:FindFirstChild("CriminalATM") 
            and spawner.CriminalATM:FindFirstChild("NormalModel") 
            and spawner.CriminalATM.NormalModel:FindFirstChild("ATM")

        if atmPart and atmPart:IsA("BasePart") then
            -- التحقق إذا لم نقم بزيارته من قبل
            if not visitedATMs[atmPart] then
                -- الانتقال
                rootPart.CFrame = atmPart.CFrame + Vector3.new(0, 3, 0) -- الانتقال فوقه قليلاً
                visitedATMs[atmPart] = true -- حفظه في الذاكرة
                print("Teleported to new ATM!")
                found = true
                break -- الخروج من الحلقة بعد الانتقال لواحد فقط
            end
        end
    end

    if not found then
        TeleportBtn.Text = "No more ATMs!"
        wait(2)
        TeleportBtn.Text = "Go to next ATM"
    end
end

-- تشغيل الأزرار
TeleportBtn.MouseButton1Click:Connect(teleportToATM)

ResetBtn.MouseButton1Click:Connect(function()
    visitedATMs = {} -- مسح الذاكرة
    ResetBtn.Text = "Cleared!"
    wait(1)
    ResetBtn.Text = "Reset"
end)

-- كود إضافي لجعل السحب يعمل بسلاسة على الجوال
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
