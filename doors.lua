-- ==========================================
-- 1. ระบบ Loading Screen (พื้นหลังโปร่งใส BackgroundTransparency = 1 นับถอยหลัง 10 วิ)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "DoorsScriptLoading"
LoadingGui.Parent = CoreGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Parent = LoadingGui
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1 -- พื้นหลังโปร่งใสสมบูรณ์
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 28
LoadingText.Font = Enum.Font.SourceSansBold

for i = 10, 1, -1 do
    LoadingText.Text = "กำลังโหลดสคริปต์... กรุณารอ " .. i .. " วินาที"
    task.wait(1)
end
LoadingGui:Destroy()

-- ==========================================
-- 2. โหลด Rayfield UI Library
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "DOORS Hub | Ultimate",
    LoadingTitle = "กำลังเริ่มระบบ...",
    LoadingSubtitle = "by Developer",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("ฟังก์ชันหลัก", 4483362458)

-- ==========================================
-- 3. ระบบปรับความเร็ว (Speed System)
-- ==========================================
local SpeedEnabled = false
local TargetSpeed = 16

MainTab:CreateToggle({
    Name = "เปิด/ปิด ระบบความเร็ว",
    CurrentValue = false,
    Callback = function(Value)
        SpeedEnabled = Value
        if not Value and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end,
})

MainTab:CreateSlider({
    Name = "ปรับระดับความเร็ว (WalkSpeed)",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        TargetSpeed = Value
    end,
})

task.spawn(function()
    while task.wait(0.1) do
        if SpeedEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = TargetSpeed
        end
    end
end)

-- ==========================================
-- 4. ระบบ ESP มองทะลุ (ตัวกรอบสีขาว / ขอบสีดำ)
-- ==========================================
local EspEnabled = false

local function AddESP(object)
    if not object:FindFirstChild("DoorsESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "DoorsESP"
        highlight.Adornee = object
        highlight.FillColor = Color3.fromRGB(255, 255, 255)  -- ตัวกรอบสีขาว
        highlight.FillTransparency = 0.5                      -- ความโปร่งแสงภายใน
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)     -- ขอบสีดำ
        highlight.OutlineTransparency = 0                     -- ขอบเข้มชัดเจน
        highlight.Parent = object
    end
end

local function RemoveESP()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "DoorsESP" then
            v:Destroy()
        end
    end
end

MainTab:CreateToggle({
    Name = "เปิด/ปิด ระบบ ESP (มองทะลุ)",
    CurrentValue = false,
    Callback = function(Value)
        EspEnabled = Value
        if not Value then
            RemoveESP()
        end
    end,
})

task.spawn(function()
    while task.wait(1) do
        if EspEnabled then
            for _, obj in pairs(workspace:GetChildren()) do
                -- สแกนหาประตูและไอเทมที่มี ProximityPrompt
                if obj.Name:find("Door") or obj:FindFirstChildOfClass("ProximityPrompt") then
                    AddESP(obj)
                end
            end
        end
    end
end)

-- ==========================================
-- 5. ระบบ Auto Pickup Item (เก็บของอัตโนมัติ)
-- ==========================================
local AutoPickupEnabled = false

MainTab:CreateToggle({
    Name = "เปิด/ปิด ระบบ Auto Pickup (เก็บของออโต้)",
    CurrentValue = false,
    Callback = function(Value)
        AutoPickupEnabled = Value
    end,
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoPickupEnabled then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)
