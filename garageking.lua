-- [[ Scary UI: Item Transformer & Revealer ]] --

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- 1. إعداد الواجهة السوداء (تحكم كامل)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ItemTransformer"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TRANSFORMER"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.Creepster
Title.TextSize = 24
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local TransformBtn = Instance.new("TextButton")
TransformBtn.Size = UDim2.new(0.8, 0, 0, 40)
TransformBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
TransformBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
TransformBtn.Text = "CONVERT ALL ITEMS"
TransformBtn.TextColor3 = Color3.white
TransformBtn.Font = Enum.Font.SourceSansBold
TransformBtn.TextSize = 16
TransformBtn.Parent = MainFrame
Instance.new("UICorner", TransformBtn)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.85, 0)
Status.Text = "Ready to Hack..."
Status.TextColor3 = Color3.fromRGB(100, 100, 100)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.SourceSansItalic
Status.Parent = MainFrame

-----------------------------------------------------------
-- ميكانيكية التحويل (The Transformation Logic)
-----------------------------------------------------------

-- إنشاء مجلد وهمي لـ Carryables إذا لم يكن موجوداً لضمان عمل المسار
local fakeCarryables = workspace:FindFirstChild("_Carryables") or Instance.new("Folder", workspace)
fakeCarryables.Name = "_Carryables"

local function transformItems()
    local debrisGarages = workspace._Debris:FindFirstChild("Garages")
    if not debrisGarages then 
        Status.Text = "Garages not found!"
        return 
    end

    local count = 0
    -- البحث في كل جراج
    for _, garage in pairs(debrisGarages:GetChildren()) do
        local floorspace = garage:FindFirstChild("Floorspace")
        if floorspace then
            for _, model in pairs(floorspace:GetChildren()) do
                if model:IsA("Model") then
                    -- 1. تغيير اسم الموديل (نحاول تخمينه من اللوحة أو نعطيه اسم مؤقت)
                    -- سنعطيه اسم "Revealed_Item" ليقبله نظام اللعبة
                    model.Name = "Harvesting Tool" -- يمكنك تغيير هذا ليطابق أي اسم من اللوحة
                    
                    -- 2. الدخول للـ Part وتحويله لـ Base
                    local mainPart = model:FindFirstChild("Part") or model:FindFirstChildWhichIsA("BasePart")
                    if mainPart then
                        mainPart.Name = "Base" -- تغيير الاسم من Part إلى Base كما طلبت
                        
                        -- 3. العملية السحرية: نقل المسار
                        -- ننقله من الجراج إلى مجلد الـ Carryables (محاكاة الشراء)
                        model.Parent = fakeCarryables
                        
                        -- 4. إضافة تأثير بصري (Highlight) لنعرف أنه تحول
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(0, 255, 0) -- أخضر لأنه "تم شراؤه"
                        hl.Parent = model
                        
                        count = count + 1
                    end
                end
            end
        end
    end
    Status.Text = "Transformed " .. count .. " Items!"
end

-----------------------------------------------------------
-- تشغيل وبرمجة الأزرار
-----------------------------------------------------------

TransformBtn.MouseButton1Click:Connect(function()
    Status.Text = "Processing..."
    TransformBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
    transformItems()
    wait(1)
    TransformBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
end)

-- دعم السحب باللمس (Mobile Dragging)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input)
    dragging = false
end)
