# Project Name

This should of been a powershell command but I made it with (claude.ai/deepseek) since I kept getting issues with other application for some reason needed to run in User Mode.

## 📦 Installation
Run this PowerShell command to install:
```powershell
irm "https://raw.githubusercontent.com/buglister/Start-UserMode/refs/heads/master/Install.ps1" | iex or Invoke-Expression (Invoke-WebRequest -Uri https://raw.githubusercontent.com/buglister/Start-UserMode/refs/heads/master/Install.ps1 -UseBasicParsing).Content
```

## OR
```powershell
Invoke-Expression (Invoke-WebRequest -Uri https://raw.githubusercontent.com/buglister/Start-UserMode/refs/heads/master/Install.ps1 -UseBasicParsing).Content
```

## 🚨 Troubleshooting 
# Temporary execution policy bypass:
```powershell
-ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/YourUsername/YourRepo/main/Install.ps1 | iex"
```

## 🛠️ Usage
```powershell
Start-UserMode "path/app.exe"
```

## 📃 Example
![image](https://github.com/user-attachments/assets/1457848c-a06b-4eee-ae27-652020845c4b)
