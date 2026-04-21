# Tool_IECS

Repository này chỉ chứa script cài đặt.

## Chạy script trên Windows (PowerShell)

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
iwr -useb https://raw.githubusercontent.com/bthien235/Tool_IECS/main/install-win.ps1 | iex
```

Hoặc dùng `irm`:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
irm https://raw.githubusercontent.com/bthien235/Tool_IECS/main/install-win.ps1 | iex
```

### Tùy chọn truyền tham số

```powershell
powershell -ExecutionPolicy Bypass -File .\install-win.ps1 -Owner bthien235 -Repo Tool_IECS -AssetName ZaloTool.exe
```

## Chạy script trên macOS

```bash
curl -fsSL https://raw.githubusercontent.com/bthien235/Tool_IECS/main/install-mac.sh | bash
```

### Tùy chọn truyền tham số

```bash
bash ./install-mac.sh bthien235 Tool_IECS "$HOME/Applications"
```

## Lưu ý

- Script sẽ tải file từ GitHub Releases mới nhất của repo này.
- Nếu cần đổi nguồn tải, truyền lại `Owner`/`Repo` bằng tham số.
