-- إعدادات الواجهة
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TeleportBtn = Instance.new("TextButton")
local AutoBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel") -- لعرض حالة البحث
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "UltraTP"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -75, 0.4, 0)
MainFrame.Size = UDim2.new(0, 150, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true -- التحريك بالإصبع

UICorner.Parent = MainFrame

-- نص الحالة (Status)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

-- إعداد الأزرار
TeleportBtn.Size = UDim2.new(0, 130, 0, 30)
TeleportBtn.Position = UDim2.new(0, 10, 0, 25)
TeleportBtn.Text = "Force TP"
TeleportBtn.Parent = MainFrame

AutoBtn.Size = UDim2.new(0, 130, 0, 30)
AutoBtn.Position = UDim2.new(0, 10, 0, 60)
AutoBtn.Text = "Auto: OFF"
AutoBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AutoBtn.Parent = MainFrame

local function getRing()
    -- البحث في كل الـ Workspace حتى لو كان مخفي بسبب المسافة
    local folder = workspace:FindFirstChild("DeliveryLocationEffects")
    if folder then
        local ring = folder:FindFirstChild("RingGlow")
        if ring then return ring end
    end
    return nil
end

local function teleportSafely()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    StatusLabel.Text = "Searching..."
    
    -- محاولة إيجاد الهدف
    local target = getRing()
    
    if target then
        -- إذا وجد الهدف، انتقل فوراً
        character.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 7, 0)
        StatusLabel.Text = "Success!"
    else
        -- الخدعة: إذا لم يجد الهدف، نقوم بعمل "انتظار" حتى يظهر في الـ Workspace
        StatusLabel.Text = "Waiting for Spawn..."
        
        -- سنقوم بمراقبة المجلد مباشرة
        local folder = workspace:WaitForChild("DeliveryLocationEffects", 5)
        if folder then
            local ring = folder:WaitForChild("RingGlow", 5)
            if ring then
                character.HumanoidRootPart.CFrame = ring.CFrame + Vector3.new(0, 7, 0)
                StatusLabel.Text = "Success (Delayed)!"
                return
            end
        end
        StatusLabel.Text = "Not Found in Map!"
    end
end

-- زر النقل اليدوي
TeleportBtn.MouseButton1Click:Connect(teleportSafely)

-- نظام الـ Auto المطور
_G.AutoMode = false
AutoBtn.MouseButton1Click:Connect(function()
    _G.AutoMode = not _G.AutoMode
    if _G.AutoMode then
        AutoBtn.Text = "Auto: ON"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        AutoBtn.Text = "Auto: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- حلقة المراقبة المستمرة (Background Loop)
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoMode then
            local ring = getRing()
            if ring then
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- حساب المسافة: إذا كان بعيداً جداً، انتقل إليه
                    local dist = (hrp.Position - ring.Position).Magnitude
                    if dist > 15 then
                        hrp.CFrame = ring.CFrame + Vector3.new(0, 7, 0)
                        StatusLabel.Text = "Auto TP Done!"
                    end
                end
            end
        end
    end
end)
