local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Cấu hình
local MAX_DISTANCE = 200 -- Khoảng cách tối đa để tải vật thể (studs)
local REFRESH_RATE = 0.1 -- Thời gian chờ giữa các lần kiểm tra (giây)

-- Tạo thư mục lưu trữ tạm thời trong ReplicatedStorage để không bị Render
local StorageFolder = ReplicatedStorage:FindFirstChild("RenderStorage") or Instance.new("Folder")
StorageFolder.Name = "RenderStorage"
StorageFolder.Parent = ReplicatedStorage

-- Tạo thư mục chứa các Part của Map trong Workspace để dễ quản lý
local MapFolder = Workspace:FindFirstChild("ManagedMap") or Instance.new("Folder")
MapFolder.Name = "ManagedMap"
MapFolder.Parent = Workspace

-- Di chuyển các vật thể hiện có trong Workspace vào thư mục quản lý (trừ Nhân vật và Camera)
for _, object in ipairs(Workspace:GetChildren()) do
    if object:IsA("BasePart") or object:IsA("Model") then
        if not Players:GetPlayerFromCharacter(object) and object ~= Camera and object.Name ~= "Terrain" then
            object.Parent = MapFolder
        end
    end
end

-- Danh sách lưu trữ thông tin vị trí gốc của vật thể
local ObjectRegistry = {}

local function registerObjects(folder)
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") and not ObjectRegistry[obj] then
            ObjectRegistry[obj] = {
                Position = obj.Position,
                OriginalParent = obj.Parent
            }
        end
    end
end

registerObjects(MapFolder)

-- Hàm kiểm tra vật thể có nằm trong góc nhìn (Frustum) của Camera không
local function isInCameraView(position)
    local _, onScreen = Camera:WorldToScreenPoint(position)
    return onScreen
end

-- Sử dụng task.spawn và task.wait để chạy vòng lặp tối ưu không gây nghẽn game
task.spawn(function()
    while true do
        task.wait(REFRESH_RATE) -- Sử dụng task.wait để giảm tải cho CPU thay vì quét theo khung hình
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local charPos = character.HumanoidRootPart.Position

            for obj, info in pairs(ObjectRegistry) do
                if obj then
                    local distance = (info.Position - charPos).Magnitude
                    
                    -- Nếu thỏa mãn: Gần + Nằm trong tầm nhìn Camera -> Đưa về Map để Render
                    if distance <= MAX_DISTANCE and isInCameraView(info.Position) then
                        if obj.Parent == StorageFolder then
                            obj.Parent = info.OriginalParent
                        end
                    else
                        -- Nếu khuất màn hình hoặc quá xa -> Cất vào kho tạm (Ngừng render hoàn toàn)
                        if obj.Parent ~= StorageFolder then
                            obj.Parent = StorageFolder
                        end
                    end
                end
            end
        end
    end
end)
