-- [[ Scary UI: Item Transformer & Revealer - MOBILE OPTIMIZED ]] --

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- 1. إنشاء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ItemTransformer"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- زر فتح/إغلاق الواجهة (الذي يظهر في منتصف الشاشة)
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Name = "ToggleButton"
OpenCloseBtn.Size = UDim2.new(0, 60, 0, 60)
OpenCloseBtn.Position = UDim2.new(0.02, 0, 0.4, 0) -- مكانه في يسار الشاشة ليسهل ضغطه
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
OpenCloseBtn.Text = "💀"
OpenCloseBtn.TextColor3 = Color3.new(1, 0, 0)
OpenCloseBtn.TextSize = 30
OpenCloseBtn.Parent = ScreenGui
Instance.new("UICorner", OpenCloseBtn).CornerRadius = UDim.new(1, 0) -- شكل دائري

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -90) -- في منتصف الشاشة تماماً
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true -- يبدأ ظاهراً
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TRANSFORMER"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.Creepster
Title.TextSize = 24
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- الزر الرئيسي (تم توسيطه الآن)
local TransformBtn = Instance.new("TextButton")
TransformBtn.Size = UDim2.new(0.85, 0, 0, 45)
TransformBtn.Position = UDim2.new(0.075, 0, 0.45, 0) -- توسيط أفقي وعمودي
TransformBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
TransformBtn.Text = "CONVERT ALL ITEMS"
TransformBtn.TextColor3 = Color3.white
TransformBtn.Font = Enum.Font.SourceSansBold
TransformBtn.TextSize = 16
TransformBtn.Parent = MainFrame
Instance.new("UICorner", TransformBtn)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0.8, 0)
Status.Text = "Ready to Hack..."
Status.TextColor3 = Color3.fromRGB(120, 120, 120)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.SourceSansItalic
Status.TextSize = 14
Status.Parent = MainFrame

-----------------------------------------------------------
-- ميكانيكية السحب (Dragging) للهاتف
-----------------------------------------------------------
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(MainFrame)
makeDraggable(OpenCloseBtn) -- تقدر تحرك زر الفتح أيضاً

-----------------------------------------------------------
-- ميكانيكية التحويل (The Logic)
-----------------------------------------------------------

local function transformItems()
    local debrisGarages = workspace:FindFirstChild("_Debris") and workspace._Debris:FindFirstChild("Garages")
    if not debrisGarages then 
        Status.Text = "Garages not found!"
        return 
    end

    local fakeCarryables = workspace:FindFirstChild("_Carryables") or Instance.new("Folder", workspace)
    fakeCarryables.Name = "_Carryables"

    local count = 0
    for _, garage in pairs(debrisGarages:GetChildren()) do
        local floorspace = garage:FindFirstChild("Floorspace")
        if floorspace then
            for _, model in pairs(floorspace:GetChildren()) do
                if model:IsA("Model") then
                    model.Name = "Harvesting Tool"
                    local mainPart = model:FindFirstChild("Part") or model:FindFirstChildWhichIsA("BasePart")
                    if mainPart then
                        mainPart.Name = "Base"
                        model.Parent = fakeCarryables
                        local hl = Instance.new("Highlight", model)
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        count = count + 1
                    end
                end
            end
        end
    end
    Status.Text = "Transformed " .. count .. " Items!"
end

-----------------------------------------------------------
-- البرمجة
-----------------------------------------------------------

-- زر الفتح والإغلاق
OpenCloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- زر التحويل
TransformBtn.MouseButton1Click:Connect(function()
    Status.Text = "Processing..."
    TransformBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    transformItems()
    task.wait(1)
    TransformBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
end)

print("💀 Item Transformer Loaded with Toggle Button!")
