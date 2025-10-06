-- Lua for Executor: ส่งค่า Diamons เป็น JSON ไปยัง http://127.0.0.1:5000/diamons
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- รอให้ LocalPlayer โหลด
local player = Players.LocalPlayer
while not player do
    task.wait(0.1)
    player = Players.LocalPlayer
end

-- รอให้ชื่อผู้เล่นพร้อม
while not player.Name or player.Name == "" do
    task.wait(0.1)
end

-- ฟังก์ชันช่วย encode เป็น JSON
local function safeJsonEncode(v)
    local ok, out = pcall(function() return HttpService:JSONEncode(v) end)
    if ok then return out end
    if type(v) == "table" then
        local t = {}
        for k,val in pairs(v) do
            table.insert(t, tostring(k) .. "=" .. tostring(val))
        end
        return "["..table.concat(t, ",").."]"
    end
    return tostring(v)
end

-- ฟังก์ชันส่งข้อมูลไป Flask
local function send_to_local(data)
    local url = "https://wexstorelog.onrender.com/send_data" -- ✅ เปลี่ยนเป็น URL ของ Render และ endpoint /send_data
    local body = HttpService:JSONEncode(data)

    if http_request then
        pcall(function()
            http_request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)
    elseif syn and syn.request then
        pcall(function()
            syn.request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)
    else
        pcall(function()
            HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
    end
end


-- เตรียม payload
local function prepare_payload()
    local username = tostring(player.Name)  -- บังคับ string จริง
    local diamonds = tonumber(player:GetAttribute("Diamonds")) or 0
    print(diamonds)
    local payload = {
        username = username,
        diamonds = diamonds
    }

    return payload
end

-- Loop ส่งข้อมูลทุก 1 วินาที
spawn(function()
    while true do
        local payload = prepare_payload()
        send_to_local(payload)

        task.wait(1) -- เวลาหน่วง (วินาที) สามารถปรับได้ตามต้องการ
    end
end)
