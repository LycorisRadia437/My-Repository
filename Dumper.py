import base64
import re

# Copy mảng G hoặc k từ file Lua của bạn và dán vào đây
encoded_data = [
    "\120\054\052\102\108\052...", # Thêm các chuỗi từ file của bạn vào đây
    "\080\097\077\076\098\102..."
]

print("=== DANH SÁCH HẰNG SỐ CHỨA TÍNH NĂNG ===")
for item in encoded_data:
    # Chuyển đổi chuỗi escape ký tự \ddd của Lua thành byte thô
    cleaned = bytes(re.sub(r'\\(\d{3})', lambda m: chr(int(m.group(1))), item), 'utf-8')
    try:
        # Giả lập giải mã lớp bảo vệ Base64 ngoại vi
        decoded = base64.b64decode(cleaned)
        # Chỉ lọc ra các chuỗi chữ/số đọc được (ASCII)
        printable = "".join([chr(b) for b in decoded if 32 <= b <= 126])
        if len(printable) > 1:
            print(f"[Tìm thấy]: {printable}")
    except:
        continue
