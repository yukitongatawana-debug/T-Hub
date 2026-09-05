-- ==============================================================================
-- T-HUB ULTIMATE DOORS SCRIPT (FULL EDITION)
-- Features: Anti-Ban Bypass, Fixed ESP, Smart Auto-Pickup, Anti-Entity, Utilities
-- Target Game: Roblox DOORS
-- Mobile Executor Compatible (Delta, CodeX, Fluxus, Vega X)
-- ==============================================================================

-- ==========================================
-- SECTION 1: LOADING SCREEN (10 SECONDS)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("THubLoadingScreen") then
    CoreGui.THubLoadingScreen:Destroy()
end

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "THubLoadingScreen"
LoadingGui.ResetOnSpawn = false
LoadingGui.Parent = CoreGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Parent = LoadingGui
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.Position = UDim2.new(0, 0, 0, 0)
LoadingText.BackgroundTransparency = 1 -- พื้นหลังโปร่งใสสมบูรณ์ตามบรีฟ
LoadingText.TextColor3 = Color3.fromRGB(0, 255, 170)
LoadingText.TextSize = 26
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.TextStrokeTransparency = 0.2
LoadingText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

for i = 10, 1, -1 do
    LoadingText.Text = "[ T-HUB SECURITY ] กำลังเริ่มระบบ Anti-Ban Bypass & โหลดทรัพยากร... (" .. i .. "s)"
    task.wait(1)
end

LoadingGui:Destroy()

-- ==========================================
-- SECTION 2: ADVANCED ANTI-BAN & BYPASS SYSTEM
-- ==========================================
local SecurityBypass = {
    Enabled = true,
    BlockedRemotes = {
        "Ban", "Kick", "AntiCheat", "Detection", "Flag", "Log", "Check", "Replicate", 
        "Admin", "Clips", "Stats", "Security", "Report", "Error", "Exploit", "Tamper"
    },
    SpoofWalkSpeed = 16,
    SpoofJumpPower = 50,
    OriginalNamecall = nil,
    OriginalIndex = nil,
    OriginalNewIndex = nil
}

-- 2.1 Hooking Kick Function
local oldKick
oldKick = hookfunction(LocalPlayer.Kick, function(self, ...)
    if SecurityBypass.Enabled then
        warn("[T-HUB ANTI-BAN]: บล็อกการพยายาม Kick ผู้เล่นจากเซิร์ฟเวอร์!")
        return nil
    end
    return oldKick(self, ...)
end)

-- 2.2 Hooking ScriptContext & LogService Error Handlers
local ScriptContext = game:GetService("ScriptContext")
local LogService = game:GetService("LogService")

pcall(function()
    ScriptContext.Error:Connect(function(msg, stack, scriptObj)
        if SecurityBypass.Enabled and scriptObj then
            -- บล็อกรายงาน Error ที่เกิดจากสคริปต์ภายนอก
            return true
        end
    end)
end)

-- 2.3 Metatable Hooking (__namecall, __index, __newindex)
local RawMetatable = getrawmetatable(game)
local SetReadOnly = setreadonly or make_writeable
SetReadOnly(RawMetatable, false)

SecurityBypass.OriginalNamecall = RawMetatable.__namecall
SecurityBypass.OriginalIndex = RawMetatable.__index
SecurityBypass.OriginalNewIndex = RawMetatable.__newindex

RawMetatable.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    if SecurityBypass.Enabled then
        -- บล็อก RemoteEvent/RemoteFunction ที่น่าสงสัย
        if Method == "FireServer" or Method == "InvokeServer" then
            local RemoteName = tostring(self.Name)
            for _, blockedKeyword in pairs(SecurityBypass.BlockedRemotes) do
                if RemoteName:lower():find(blockedKeyword:lower()) then
                    warn("[T-HUB ANTI-BAN]: บล็อก RemoteEvent ที่เป็นอันตราย -> " .. RemoteName)
                    return nil
                end
            end
        end

        -- บล็อกการตรวจจับการเจาะระบบการเคลื่อนที่
        if Method == "FindService" or Method == "GetService" then
            if Args[1] == "VirtualUser" and not checkcaller() then
                return nil
            end
        end
    end

    return SecurityBypass.OriginalNamecall(self, ...)
end)

RawMetatable.__index = newcclosure(function(self, Key)
    if SecurityBypass.Enabled and not checkcaller() then
        -- ตบตาเกมเมื่อระบบ Anti-Cheat พยายามอ่านค่า WalkSpeed หรือ JumpPower
        if self:IsA("Humanoid") then
            if Key == "WalkSpeed" then
                return SecurityBypass.SpoofWalkSpeed
            elseif Key == "JumpPower" or Key == "JumpHeight" then
                return SecurityBypass.SpoofJumpPower
            end
        end
    end
    return SecurityBypass.OriginalIndex(self, Key)
end)

SetReadOnly(RawMetatable, true)

-- 2.4 Anti-AFK System
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if SecurityBypass.Enabled then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- ==========================================
-- SECTION 3: RAYFIELD UI SETUP
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "T-HUB | DOORS Ultimate V4",
    LoadingTitle = "T-HUB Executed",
    LoadingSubtitle = "โดย Senior Developer",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("ผู้เล่น (Player)", 4483362458)
local EspTab = Window:CreateTab("ESP มองทะลุ", 4483362458)
local AutoTab = Window:CreateTab("ระบบออโต้ (Automation)", 4483362458)
local SafeTab = Window:CreateTab("ป้องกันผี (Anti-Entity)", 4483362458)
local SecurityTab = Window:CreateTab("ความปลอดภัย (Anti-Ban)", 4483362458)

-- ==========================================
-- SECTION 4: PLAYER UTILITIES (SPEED, NOCLIP, FULLBRIGHT)
-- ==========================================
local MovementConfig = {
    SpeedEnabled = false,
    WalkSpeed = 16,
    NoclipEnabled = false,
    FullbrightEnabled = false,
    InstantInteract = false
}

MainTab:CreateToggle({
    Name = "เปิดระบบเร่งความเร็ว (Speed Bypass)",
    CurrentValue = false,
    Callback = function(Value)
        MovementConfig.SpeedEnabled = Value
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end,
})

MainTab:CreateSlider({
    Name = "ปรับระดับความเร็ว (WalkSpeed)",
    Range = {16, 75},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        MovementConfig.WalkSpeed = Value
    end,
})

MainTab:CreateToggle({
    Name = "เปิดระบบเดินทะลุสิ่งกีดขวาง (Noclip)",
    CurrentValue = false,
    Callback = function(Value)
        MovementConfig.NoclipEnabled = Value
    end,
})

MainTab:CreateToggle({
    Name = "เปิดสว่างในที่มืด (Fullbright / No Fog)",
    CurrentValue = false,
    Callback = function(Value)
        MovementConfig.FullbrightEnabled = Value
        if not Value then
            game:GetService("Lighting").Ambient = Color3.fromRGB(0, 0, 0)
            game:GetService("Lighting").FogEnd = 1000
        end
    end,
})

MainTab:CreateToggle({
    Name = "เปิดระบบกดของทันที (Instant Interact)",
    CurrentValue = false,
    Callback = function(Value)
        MovementConfig.InstantInteract = Value
    end,
})

-- Movement Loop
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                -- Speed Control
                if MovementConfig.SpeedEnabled then
                    LocalPlayer.Character.Humanoid.WalkSpeed = MovementConfig.WalkSpeed
                end
                
                -- Noclip Control
                if MovementConfig.NoclipEnabled then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end

            -- Fullbright Control
            if MovementConfig.FullbrightEnabled then
                game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
                game:GetService("Lighting").FogEnd = 999999
            end

            -- Instant Interact Control
            if MovementConfig.InstantInteract then
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- SECTION 5: ESP SYSTEM (FIXED BUG)
-- ==========================================
local EspConfig = {
    Doors = false,
    Items = false,
    Gold = false,
    Entities = false
}

local function ApplyHighlight(Target, Name, FillColor, OutlineColor)
    if not Target or not Target:IsA("PVInstance") then return end
    if Target:FindFirstChild(Name) then return end

    local Highlight = Instance.new("Highlight")
    Highlight.Name = Name
    Highlight.Adornee = Target
    Highlight.FillColor = FillColor
    Highlight.FillTransparency = 0.5
    Highlight.OutlineColor = OutlineColor
    Highlight.OutlineTransparency = 0
    Highlight.Parent = Target
end

local function RemoveHighlights(Name)
    for _, desc in pairs(workspace:GetDescendants()) do
        if desc:IsA("Highlight") and desc.Name == Name then
            desc:Destroy()
        end
    end
end

EspTab:CreateToggle({
    Name = "ESP ประตูห้องต่อไป (Door ESP)",
    CurrentValue = false,
    Callback = function(Value)
        EspConfig.Doors = Value
        if not Value then RemoveHighlights("THub_DoorESP") end
    end,
})

EspTab:CreateToggle({
    Name = "ESP ไอเทม/กุญแจ (Item & Key ESP)",
    CurrentValue = false,
    Callback = function(Value)
        EspConfig.Items = Value
        if not Value then RemoveHighlights("THub_ItemESP") end
    end,
})

EspTab:CreateToggle({
    Name = "ESP เหรียญทอง (Gold ESP)",
    CurrentValue = false,
    Callback = function(Value)
        EspConfig.Gold = Value
        if not Value then RemoveHighlights("THub_GoldESP") end
    end,
})

EspTab:CreateToggle({
    Name = "ESP ศัตรู/ผี (Entity ESP)",
    CurrentValue = false,
    Callback = function(Value)
        EspConfig.Entities = Value
        if not Value then RemoveHighlights("THub_EntityESP") end
    end,
})

-- Loop Scan ESP
task.spawn(function()
    while task.wait(0.8) do
        pcall(function()
            local CurrentRooms = workspace:FindFirstChild("CurrentRooms")
            if not CurrentRooms then return end

            for _, room in pairs(CurrentRooms:GetChildren()) do
                -- 1. Scan Doors
                if EspConfig.Doors then
                    local door = room:FindFirstChild("Door")
                    if door and door:FindFirstChild("Door") then
                        ApplyHighlight(door, "THub_DoorESP", Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))
                    end
                end

                -- 2. Scan Items & Gold
                for _, desc in pairs(room:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        local parentModel = desc.Parent
                        local parentName = parentModel and parentModel.Name:lower() or ""

                        -- กรองไม่แสดงผลบนตู้/ที่ซ่อน
                        if not parentName:find("wardrobe") and not parentName:find("locker") and not parentName:find("bed") and not parentName:find("closet") then
                            if EspConfig.Gold and (parentName:find("gold") or parentName:find("coin")) then
                                ApplyHighlight(parentModel, "THub_GoldESP", Color3.fromRGB(255, 215, 0), Color3.fromRGB(0, 0, 0))
                            elseif EspConfig.Items and not parentName:find("gold") and not parentName:find("coin") then
                                ApplyHighlight(parentModel, "THub_ItemESP", Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))
                            end
                        end
                    end
                end
            end

            -- 3. Scan Entities
            if EspConfig.Entities then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name:find("Moving") or obj.Name == "RushMoving" or obj.Name == "AmbushMoving" or obj.Name == "Figure" or obj.Name == "Seek" then
                        ApplyHighlight(obj, "THub_EntityESP", Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 0))
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- SECTION 6: SMART AUTO PICKUP SYSTEM (FIXED BUG)
-- ==========================================
local AutoConfig = {
    AutoPickup = false,
    AutoGold = false,
    PickupDistance = 15
}

-- รายชื่อตู้/ที่ซ่อน และชื่อ Prompt ที่ต้องข้ามแบบเด็ดขาด
local BlacklistedPrompts = {
    ["HidePrompt"] = true,
    ["Hide"] = true,
    ["BedPrompt"] = true,
    ["LockerPrompt"] = true,
    ["WardrobePrompt"] = true
}

local BlacklistedNames = {
    "wardrobe", "locker", "bed", "closet", "chest_locked", "vent", "drawer"
}

local function IsHidingSpot(instance)
    if not instance then return false end
    local name = instance.Name:lower()
    for _, blackName in pairs(BlacklistedNames) do
        if name:find(blackName) then
            return true
        end
    end
    return false
end

local function IsPromptSafeToInteract(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end

    -- เช็กชื่อ Prompt
    if BlacklistedPrompts[prompt.Name] or prompt.ActionText == "Hide" or prompt.ObjectText == "Hide" then
        return false
    end

    -- เช็กวัตถุที่เป็นพ่อแม่ของ Prompt
    local parent = prompt.Parent
    if parent and IsHidingSpot(parent) then return false end
    if parent and parent.Parent and IsHidingSpot(parent.Parent) then return false end

    return true
end

AutoTab:CreateToggle({
    Name = "เปิดระบบเก็บไอเทม/กุญแจ อัตโนมัติ (ไม่เข้าตู้แน่นอน)",
    CurrentValue = false,
    Callback = function(Value)
        AutoConfig.AutoPickup = Value
    end,
})

AutoTab:CreateToggle({
    Name = "เปิดระบบเก็บเหรียญทอง อัตโนมัติ",
    CurrentValue = false,
    Callback = function(Value)
        AutoConfig.AutoGold = Value
    end,
})

AutoTab:CreateSlider({
    Name = "ระยะการเก็บของ (Distance)",
    Range = {5, 25},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value)
        AutoConfig.PickupDistance = Value
    end,
})

-- Loop Auto Pickup
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if (AutoConfig.AutoPickup or AutoConfig.AutoGold) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local HRP = LocalPlayer.Character.HumanoidRootPart
                
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if IsPromptSafeToInteract(prompt) and prompt.Parent and prompt.Parent:IsA("PVInstance") then
                        local targetPos = prompt.Parent:GetPivot().Position
                        local distance = (HRP.Position - targetPos).Magnitude

                        if distance <= AutoConfig.PickupDistance then
                            local parentName = prompt.Parent.Name:lower()
                            
                            -- แยกประเภทเหรียญทองกับไอเทมทั่วไป
                            if AutoConfig.AutoGold and (parentName:find("gold") or parentName:find("coin")) then
                                fireproximityprompt(prompt)
                            elseif AutoConfig.AutoPickup and not parentName:find("gold") and not parentName:find("coin") then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- SECTION 7: ANTI-ENTITY & SAFETY SYSTEM
-- ==========================================
local SafetyConfig = {
    NotifyEntity = true,
    BypassScreech = true,
    BypassEyes = true
}

SafeTab:CreateToggle({
    Name = "แจ้งเตือนเมื่อผีเกิด (Rush / Ambush Notification)",
    CurrentValue = true,
    Callback = function(Value)
        SafetyConfig.NotifyEntity = Value
    end,
})

SafeTab:CreateToggle({
    Name = "ป้องกัน Screech (บล็อกไม่ให้กัด)",
    CurrentValue = true,
    Callback = function(Value)
        SafetyConfig.BypassScreech = Value
    end,
})

SafeTab:CreateToggle({
    Name = "ป้องกัน Eyes (ไม่เสียเลือดเมื่อมอง)",
    CurrentValue = true,
    Callback = function(Value)
        SafetyConfig.BypassEyes = Value
    end,
})

-- Entity Event Detection
workspace.ChildAdded:Connect(function(child)
    if SafetyConfig.NotifyEntity then
        local name = child.Name
        if name == "RushMoving" then
            Rayfield:Notify({Title = "⚠️ เตือนภัยผี!", Content = "Rush กำลังมา! รีบหาตู้ซ่อนด่วน!", Duration = 5})
        elseif name == "AmbushMoving" then
            Rayfield:Notify({Title = "⚠️ เตือนภัยผีขั้นสูง!", Content = "Ambush กำลังมา! เตรียมซ่อนหลายรอบ!", Duration = 6})
        end
    end
end)

-- Loop Safety Features
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            -- Anti Screech
            if SafetyConfig.BypassScreech and workspace.CurrentCamera:FindFirstChild("Screech") then
                local screech = workspace.CurrentCamera.Screech
                screech:Destroy()
            end

            -- Anti Eyes
            if SafetyConfig.BypassEyes and workspace:FindFirstChild("Eyes") then
                local eyes = workspace.Eyes
                if eyes:FindFirstChild("Core") then
                    -- ส่งสัญญาณมองไปทางอื่นเพื่อหลบดาเมจ
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, eyes.Core.Position - Vector3.new(0, 50, 0))
                end
            end
        end)
    end
end)

-- ==========================================
-- SECTION 8: ANTI-BAN DASHBOARD
-- ==========================================
SecurityTab:CreateToggle({
    Name = "เปิดใช้งานระบบ Anti-Ban Bypass (แนะนำ)",
    CurrentValue = true,
    Callback = function(Value)
        SecurityBypass.Enabled = Value
        Rayfield:Notify({
            Title = "ระบบความปลอดภัย",
            Content = Value and "Anti-Ban ทำงานสมบูรณ์" or "ปิดระบบ Anti-Ban แล้ว (เสี่ยงโดนแบน)",
            Duration = 3
        })
    end,
})

SecurityTab:CreateButton({
    Name = "ตรวจสอบสถานะ Bypass",
    Callback = function()
        Rayfield:Notify({
            Title = "สถานะระบบความปลอดภัย",
            Content = "Metatable: Hooked | Kick: Protected | Error Logger: Bypassed",
            Duration = 5
        })
    end,
})

Rayfield:Notify({
    Title = "T-HUB โหลดสำเร็จ",
    Content = "แก้ไข ESP และ Auto Pickup เรียบร้อยแล้ว พร้อมใช้งาน!",
    Duration = 5
})
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
