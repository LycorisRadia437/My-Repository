-- CÀI ĐẶT DÀNH CHO DELTA EXECUTOR (ĐÃ SỬA LỖI RAYCAST)
local CHECK_INTERVAL = 0.35 -- Tăng nhẹ thời gian chờ để máy không bị lag
local MAX_CULL_DISTANCE = 900 -- Khoảng cách tối đa để render vật thể

-- BIẾN HỆ THỐNG
local camera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- TỰ ĐỘNG GOM DANH SÁCH PART TRONG MAP
local targetParts = {}
for _, obj in ipairs(workspace:GetDescendants()) do
    if (obj:IsA("MeshPart") or obj:IsA("BasePart")) 
       and not obj:IsDescendantOf(game.Players.LocalPlayer.Character or workspace.CurrentCamera) 
       and obj.Name ~= "Baseplate" 
       and obj.Name ~= "Terrain" then
        table.insert(targetParts, obj)
    end
end

-- HÀM KIỂM TRA ĐIỀU KIỆN NHÌN THẤY
local function checkVisibility(part, playerChar)
    if not part or not part:IsA("BasePart") then return false end
    local partPos = part.Position
    local camPos = camera.CFrame.Position
    
    -- 1. Kiểm tra khoảng cách
    local distance = (partPos - camPos).Magnitude
    if distance > MAX_CULL_DISTANCE then return false end

    -- 2. Frustum Culling (Góc nhìn màn hình)
    local _, onScreen = camera:WorldToScreenPoint(partPos)
    if not onScreen then return false end

    -- 3. Occlusion Culling (Vật cản - ĐÃ SỬA LỖI TẠI ĐÂY)
    if playerChar then
        raycastParams.FilterDescendantsInstances = {playerChar, part}
    else
        raycastParams.FilterDescendantsInstances = {part}
    end

    local direction = partPos - camPos
    local rayResult = workspace:Raycast(camPos, direction, raycastParams)

    if rayResult and rayResult.Instance then
        -- Nếu bị tường chắn và tường đó không trong suốt
        if rayResult.Instance.CanCollide and rayResult.Instance.Transparency < 0.5 then
            return false 
        end
    end

    return true
end

-- VÒNG LẶP CHẠY CHÍNH
task.spawn(function()
    while true do
        local localPlayer = game.Players.LocalPlayer
        local char = localPlayer and localPlayer.Character
        
        for _, object in ipairs(targetParts) do
            if object and object.Parent then
                if checkVisibility(object, char) then
                    object.LocalTransparencyModifier = 0 -- Hiện khi nhìn thấy
                else
                    object.LocalTransparencyModifier = 1 -- Ẩn khi bị che/ngoài màn hình
                end
            end
        end
        task.wait(CHECK_INTERVAL)
    end
end)
