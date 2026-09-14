-- TRÌNH DIỄN DỊCH NGƯỢC CHẶN BẮT TRONG ISH
local function xu_ly_code_goc(chuoi_code)
    print("\n============================================================")
    print("  MÃ NGUỒN GỐC ĐÃ ĐƯỢC GIẢI MÃ THÀNH CÔNG TRONG ISH:")
    print("============================================================\n")
    print(chuoi_code) 
    print("\n============================================================")
    os.exit(0) 
end

-- Chặn đứng loadstring và load của VM
loadstring = function(str)
    if type(str) == "string" then xu_ly_code_goc(str) end
    return function() end
end
load = function(chunk)
    if type(chunk) == "string" then xu_ly_code_goc(chunk)
    elseif type(chunk) == "function" then
        local success, result = pcall(chunk)
        if success and type(result) == "string" then xu_ly_code_goc(result) end
    end
    return function() end
end

if getfenv then
    getfenv(0).loadstring = loadstring
    getfenv(0).load = load
else
    _ENV.loadstring = loadstring
    _ENV.load = load
end

-- DÁN TOÀN BỘ ĐOẠN CODE LUA VM GỐC CỦA BẠN VÀO DƯỚI ĐÂY
-- TRÌNH DIỄN DỊCH NGƯỢC CHẶN BẮT TRONG ISH
local function xu_ly_code_goc(chuoi_code)
    print("\n============================================================")
    print("  MÃ NGUỒN GỐC ĐÃ ĐƯỢC GIẢI MÃ THÀNH CÔNG TRONG ISH:")
    print("============================================================\n")
    print(chuoi_code) 
    print("\n============================================================")
    os.exit(0) 
end

-- Chặn đứng loadstring và load của VM
loadstring = function(str)
    if type(str) == "string" then xu_ly_code_goc(str) end
    return function() end
end
load = function(chunk)
    if type(chunk) == "string" then xu_ly_code_goc(chunk)
    elseif type(chunk) == "function" then
        local success, result = pcall(chunk)
        if success and type(result) == "string" then xu_ly_code_goc(result) end
    end
    return function() end
end

if getfenv then
    getfenv(0).loadstring = loadstring
    getfenv(0).load = load
else
    _ENV.loadstring = loadstring
    _ENV.load = load
end

-- DÁN TOÀN BỘ ĐOẠN CODE LUA VM GỐC CỦA BẠN VÀO DƯỚI ĐÂY

