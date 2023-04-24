
Clear-Host
# Verifica se o diretório existe, caso não exista, cria o diretório
if (!(Test-Path "C:\totvs\hardening")) {
    New-Item -ItemType Directory -Path "C:\totvs\hardening"
    Write-Host "Diretório 'hardening' criado com sucesso!"
}

# Faz o download do arquivo 'hardening-Invoker-OS'

$fileUrl = "http://192.168.1.125/hardening/datasul/hardening_os/1.0/hardening-Invoker-OS.ps1"
$filePath = "C:\totvs\hardening\hardening-Invoker-OS.ps1"
Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
$file = Get-Item -Path $filePath

#Calcula o hash do arquivo usando o algoritmo SHA256
$hash = Get-FileHash -Path $file.FullName -Algorithm SHA256

#Compara o hash calculado com o hash conhecido do script hardening-Invoker-OS
if ($hash.Hash -eq "AEC1D24EDAB7D2D2CFA0253AFC1FF5FC09D3643A1C913E3A8B957E91E8B66D88") {
    
    # Se o hash for válido, executa o script
    .\newhardening.ps1 -apply hardening -configfile "c:\totvs\cis_hardening_windows_server_2016_default_v0.4.json"
} else {
    # Casp O hash seja inválido, imprima uma mensagem de erro e saia do script
    Write-Host "O hash do arquivo baixado é inválido. O download pode ter sido comprometido. Não é seguro continuar com a execução do script." -ForegroundColor Red
    Exit 1
}

