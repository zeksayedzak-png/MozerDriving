-- إنشاء الواجهة (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TeleportBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- إعدادات الواجهة
ScreenGui.Name = "TeleportGui"
ScreenGui.Parent = game.CoreGui -- وضعها في CoreGui لضمان عدم اختفائها عند الموت
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- إعدادات الإطار (الذي ستحركه بإصبعك)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.5, -50, 0.5, -25) -- في منتصف الشاشة
MainFrame.Size = UDim2.new(0, 100, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل خاصية السحب للهواتف

-- إضافة زوايا دائرية للجمالية
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- إعدادات الزر
TeleportBtn.Name = "TeleportBtn"
TeleportBtn.Parent = MainFrame
TeleportBtn.BackgroundColor3 = Color3.fromRGB(218, 133, 65) -- نفس لون الـ RingGlow الذي ذكرته
TeleportBtn.Size = UDim2.new(1, 0, 1, 0)
TeleportBtn.Font = Enum.Font.SourceSansBold
TeleportBtn.Text = "TP TO RING"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 18.0

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 10)
UICornerBtn.Parent = TeleportBtn

-- دالة الانتقال (Teleport Logic)
TeleportBtn.MouseButton1Click:Connect(function()
    local targetPath = workspace:FindFirstChild("DeliveryLocationEffects")
    
    if targetPath and targetPath:FindFirstChild("RingGlow") then
        local ring = targetPath.RingGlow
        local player = game.Players.LocalPlayer
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- الانتقال إلى موقع الجزء + 7 وحدات للأعلى (مسافة آمنة)
            local targetPos = ring.CFrame + Vector3.new(0, 7, 0)
            player.Character.HumanoidRootPart.CFrame = targetPos
        end
    else
        -- إذا لم يجد المنطقة (ربما لم تظهر بعد)
        TeleportBtn.Text = "Not Found!"
        wait(1)
        TeleportBtn.Text = "TP TO RING"
    end
end)

-- كود إضافي لجعل السحب يعمل بسلاسة أكبر على الهواتف (اختياري)
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

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
