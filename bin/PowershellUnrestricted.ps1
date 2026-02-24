# powershell.exe -ExecutionPolicy Unrestricted -Command "& $args"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
Get-ExecutionPolicy -List
& $args
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope LocalMachine -Force
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Get-ExecutionPolicy -List
