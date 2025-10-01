local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- รอ Data และ Character โหลด
repeat task.wait() until LocalPlayer:FindFirstChild("Data") 
    and LocalPlayer.Data:FindFirstChild("Level")
    and LocalPlayer.Data:FindFirstChild("Beli")
    and LocalPlayer.Data:FindFirstChild("Beli")
    and LocalPlayer.Character

-- GUI Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerStats"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (เต็มจอ)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "StatsContainer"
mainFrame.Size = UDim2.new(1, 0, 1.5, 0)
mainFrame.Position = UDim2.new(0, 0, -0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
mainFrame.BackgroundTransparency = 0.5
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Layout จัดตรงกลาง
local uiList = Instance.new("UIListLayout")
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Center
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 10)
uiList.Parent = mainFrame

-- Avatar
-- local avatar = Instance.new("ImageLabel")
-- avatar.Size = UDim2.new(0, 150, 0, 150)
-- avatar.BackgroundTransparency = 1
-- avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
-- avatar.LayoutOrder = 1
-- avatar.Parent = mainFrame

-- local avatarCorner = Instance.new("UICorner")
-- avatarCorner.CornerRadius = UDim.new(1, 0)
-- avatarCorner.Parent = avatar

-- ฟังก์ชันสร้าง Value Text
local function createValueCard(value, order, accentColor, textSize)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 400, 0, 60)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Text = value
    label.TextColor3 = accentColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize or 70 -- ถ้าไม่ได้ส่ง textSize จะใช้ 70 เป็นค่าเริ่มต้น
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.LayoutOrder = order
    label.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = accentColor
    stroke.Thickness = 1
    stroke.Parent = label

    return label
end

local function formatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 100000 then
        return string.format("%.1fK", num / 1000)
    elseif num >= 10000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

local name = LocalPlayer.Character.Name
local level = LocalPlayer.Data.Level.Value
local beli = LocalPlayer.Data.Beli.Value
local fragments = LocalPlayer.Data.Fragments.Value

-- Values
local nameValue = createValueCard(name, 2, Color3.fromRGB(255, 115, 0), 75)
local levelValue = createValueCard("LV : " .. tostring(level), 3, Color3.fromRGB(234, 255, 0), 50) -- ตัวใหญ่
local BeliValue = createValueCard("$ : " .. tostring(beli), 4, Color3.fromRGB(0, 255, 47), 50)
local FragmentsValue = createValueCard("F : " .. tostring(fragments), 5, Color3.fromRGB(238, 0, 255), 50)
local timeValue = createValueCard("0s", 6, Color3.fromRGB(59, 130, 246), 40)


-- อัปเดต Level
-- อัปเดต Level, Beli และ Fragments
LocalPlayer.Data.Level:GetPropertyChangedSignal("Value"):Connect(function()
    levelValue.Text = "LV : " .. tostring(LocalPlayer.Data.Level.Value)
end)

LocalPlayer.Data.Beli:GetPropertyChangedSignal("Value"):Connect(function()
    local formatted = formatNumber(LocalPlayer.Data.Beli.Value)
    BeliValue.Text = "$ : " .. formatted
end)

-- อัปเดต Fragments
LocalPlayer.Data.Fragments:GetPropertyChangedSignal("Value"):Connect(function()
    local formatted = formatNumber(LocalPlayer.Data.Fragments.Value)
    FragmentsValue.Text = "F : " .. formatted
end)


-- ตัวนับเวลาออนไลน์
local startTime = tick()
task.spawn(function()
    while true do
        task.wait(1)
        local elapsed = math.floor(tick() - startTime)
        local displayTime
        if elapsed < 60 then
            displayTime = elapsed .. "s"
        elseif elapsed < 3600 then
            local m = math.floor(elapsed / 60)
            local s = elapsed % 60
            displayTime = m .. "m " .. s .. "s"
        else
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            displayTime = h .. "h " .. m .. "m"
        end
        timeValue.Text = displayTime
    end
end)

-- เปลี่ยนชื่อเมื่อ Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    nameValue.Text = char.Name
end)
