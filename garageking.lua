-- [[ Ultimate Scary Garage Scanner + X-Ray + Price Linker ]] --

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- 1. إنشاء الواجهة (Scary UI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScaryXrayScanner"
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true 

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "GARAGE SCANNER v2"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.Creepster 
Title.TextSize = 18
Title.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Text = "Status: Waiting..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextSize = 14

local ScanBtn = Instance.new("TextButton")
ScanBtn.Parent = MainFrame
ScanBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
ScanBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
ScanBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
ScanBtn.Text = "START DEEP SCAN"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 16

Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 8)

-----------------------------------------------------------
-- وظيفة الربط: جلب البيانات من الـ Leaderboard وتطبيقها
-----------------------------------------------------------
local function startDeepScan()
    local priceData = {}
    
    -- المسار الذي أعطيتني إياه للوحة
    local rowsFolder = workspace:FindFirstChild("Leaderboards")
    if rowsFolder then
        rowsFolder = rowsFolder:FindFirstChild("Leaderboard Item Value")
        if rowsFolder then
            local rows = rowsFolder.Board.LeaderboardGui_A.Root.Rows:GetChildren()
            for _, row in pairs(rows) do
                -- نبحث عن النص داخل الـ Row (الاسم والسعر)
                if row:IsA("Frame") then
                    local itemName = row:FindFirstChild("ItemName") or row:FindFirstChild("Title") -- افتراض اسم العنصر
                    local priceLabel = row:FindFirstChild("Value")
                    
                    if priceLabel then
                        -- تخزين السعر بناءً على اسم الـ Row أو النص داخله
                        local key = itemName and itemName.Text or row.Name
                        priceData[key] = priceLabel.Text
                    end
                end
            end
        end
    end

    -- البحث في الجراجات وتطبيق الـ X-ray والسعر
    local garages = workspace._Debris:FindFirstChild("Garages")
    if garages then
        for _, garage in pairs(garages:GetChildren()) do
            local floorspace = garage:FindFirstChild("Floorspace")
            if floorspace then
                for _, model in pairs(floorspace:GetDescendants()) do
                    -- نطبق السكربت على الموديلات أو الأجزاء (Parts)
                    if model:IsA("Model") or (model:IsA("BasePart") and model.Name ~= "Part") then
                        
                        -- 1. إضافة الـ Highlight الأحمر (X-Ray)
                        if not model:FindFirstChild("Xray") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "Xray"
                            hl.Parent = model
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.FillTransparency = 0.4
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        end

                        -- 2. وضع السعر فوقه (Billboard)
                        if not model:FindFirstChild("PriceTag") then
                            local bill = Instance.new("BillboardGui")
                            bill.Name = "PriceTag"
                            bill.Parent = model
                            bill.Size = UDim2.new(0, 100, 0, 40)
                            bill.AlwaysOnTop = true
                            bill.ExtentsOffset = Vector3.new(0, 4, 0)

                            local txt = Instance.new("TextLabel")
                            txt.Parent = bill
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(255, 255, 0)
                            txt.TextStrokeTransparency = 0
                            txt.TextSize = 18
                            txt.Font = Enum.Font.SourceSansBold
                            
                            -- محاولة مطابقة السعر من الجدول الذي جمعناه
                            local foundPrice = "Checking..."
                            for name, price in pairs(priceData) do
                                -- إذا كان اسم القطعة موجود في اسم الـ Row
                                if string.find(string.lower(model.Name), string.lower(name)) or string.find(string.lower(name), string.lower(model.Name)) then
                                    foundPrice = price
                                    break
                                end
                            end
                            
                            -- إذا لم يجد مطابقة بالاسم، يضع القيمة من Row_X حسب الترتيب (اختياري)
                            txt.Text = (foundPrice ~= "Checking...") and foundPrice or "Price: Unknown"
                        end
                    end
                end
            end
        end
    end
end

-- تشغيل الزر
ScanBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Status: Scanning Board..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    startDeepScan()
    wait(1)
    StatusLabel.Text = "Status: X-RAY ACTIVE"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

-- كود السحب للموبايل
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
