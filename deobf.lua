-- TRÌNH DIỄN DỊCH HẰNG SỐ & CHUỖI KHÔI PHỤC (ĐÃ SỬA LỖI)
local xu_ly_chuoi = {}
local string_char = string.char

-- Hook trực tiếp vào hàm tạo ký tự để thu thập dữ liệu thô
string.char = function(...)
    local b = { ... }
    local s = ""
    for i = 1, #b do
        if b[i] >= 32 and b[i] <= 126 or b[i] == 10 or b[i] == 9 then
            s = s .. string_char(b[i])
        end
    end
    if #s > 0 then
        table.insert(xu_ly_chuoi, s)
    end
    return string_char(...)
end

-- Tự động in ra màn hình hoặc ghi lại khi chương trình kết thúc
local old_exit = os.exit
os.exit = function(...)
    local code_goc = table.concat(xu_ly_chuoi, "")
    print("\n==============================================")
    print("MÃ NGUỒN / CHUỖI KÝ TỰ KHÔI PHỤC ĐƯỢC:")
    print("==============================================\n")
    print(code_goc)
    print("\n==============================================")
    if old_exit then old_exit(...) end
end

-- Chặn đứng lệnh load nguy hiểm nhưng vẫn cho phép VM giải mã dữ liệu
loadstring = function() return function() os.exit(0) end end
load = function() return function() os.exit(0) end end
if getfenv then
    getfenv(0).loadstring = loadstring
    getfenv(0).load = load
else
    _ENV.loadstring = loadstring
    _ENV.load = load
end

-- [DÁN ĐOẠN CODE LUA VM GỐC CỦA BẠN VÀO NGAY DƯỚI ĐÂY]
return(function(...)local C={"\069\068\056\107\047\070\072\054\073\117\056\117\111\053\114\121\108\081\106\061"; ...
