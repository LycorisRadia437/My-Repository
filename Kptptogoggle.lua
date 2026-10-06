local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Events = workspace:FindFirstChild("Events")
local Blackout = Events and Events:FindFirstChild("Blackout")

local function notify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Kaiju Paradise GUI",
            Text = msg,
            Duration = 5
        })
    end)
end

if not Blackout or not Blackout.Value then
    notify("Không có sự kiện Blackout!")
else
    notify("Bắt đầu theo dõi sự kiện!")
    notify("Sẽ tự động dịch chuyển khi Goggle xuất hiện...")

    -- Chờ cho đến khi Kính xuất hiện hoặc hết Blackout
    repeat 
        task.wait(0.2) 
    until workspace.Terrain:FindFirstChild("Nightvision") or not Blackout.Value

    if not Blackout.Value then
        notify("Không tìm thấy Goggle...")
    else
        local Nightvision = workspace.Terrain:FindFirstChild("Nightvision")
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if Nightvision and Nightvision:FindFirstChild("Hitbox") and hrp then
            -- [BƯỚC 1] Lưu lại vị trí cũ
            local oldCFrame = hrp.CFrame
            task.wait(0.1)

            -- [BƯỚC 2] Dịch chuyển đến gần kính (Đứng cao hơn 2 block để tránh kẹt sàn)
            hrp.CFrame = Nightvision.Hitbox.CFrame * CFrame.new(0, 2, 0)
            
            -- [BƯỚC 3] Đợi cho đến khi cấu trúc nút nhặt được tải hoàn toàn ở phía Server
            local prompt = nil
            local timeout = 0
            repeat
                task.wait(0.2)
                timeout = timeout + 0.2
                prompt = Nightvision.Hitbox:FindFirstChild("Attachment") 
                    and Nightvision.Hitbox.Attachment:FindFirstChild("GiveItem")
            until prompt or timeout > 3 -- Quá 3 giây sẽ bỏ qua nếu lỗi

            if prompt then
                notify("Tìm thấy nút nhặt! Đang tiến hành bấm...")
                prompt.HoldDuration = 0 -- Chỉnh thời gian giữ phím về 0
                task.wait(0.1)

                -- [BƯỚC 4] Vòng lặp spam nhặt liên tục (Giả lập việc bạn chạy script lần 2, lần 3)
                -- Vòng lặp sẽ dừng khi Kính biến mất khỏi workspace (nhặt thành công) hoặc quá 15 lần thử
                local attempts = 0
                while Nightvision and Nightvision.Parent and attempts < 15 do
                    attempts = attempts + 1
                    
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        -- Cách chữa cháy nếu Executor thiếu hàm fireproximityprompt
                        prompt:InputHoldBegin()
                        task.wait(0.05)
                        prompt:InputHoldEnd()
                    end
                    
                    task.wait(0.2) -- Khoảng cách giữa các lần bấm để tránh anti-cheat spam
                end
                
                notify("Quá trình nhặt hoàn tất!")
            else
                notify("Lỗi: Không load được nút nhặt (Prompt)!")
            end
            
            -- [BƯỚC 5] Đợi một chút rồi dịch chuyển về vị trí cũ
            task.wait(0.5) 
            if hrp and oldCFrame then
                hrp.CFrame = oldCFrame
                notify("Đã quay trở lại vị trí cũ!")
            end
        else
            notify("Lỗi: Không tìm thấy nhân vật hoặc Hitbox goggle!")
        end
    end
end
