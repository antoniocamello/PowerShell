# Este script instala o Hardening V1 do no Datasul
# Verifica se o diretório existe, caso não exista, cria o diretório
if (!(Test-Path "C:\totvs\hardening")) {
    New-Item -ItemType Directory -Path "C:\totvs\hardening"
    Write-Host "Diretório 'hardening' criado com sucesso!"
}

# Faz o download do arquivo 'newhardening.ps1'
#C:\totvs\hardening\datasul\hardening_os\1.0
Invoke-WebRequest -Uri http://192.168.1.125/hardening/datasul/hardening_os/1.0/newhardening.ps1 -OutFile C:\totvs\hardening\invoker.ps1

# Verifica se o arquivo foi baixado corretamente
# Validar comparar o hash do arquivo sha256
if (Test-Path "C:\totvs\hardening\invoker.ps1") {
    Write-Host "Arquivo baixado com sucesso!" -ForegroundColor Yellow
    
    sleep 1

    Write-Host "Preparando para execução AGUARDE..." -ForegroundColor Yellow

    sleep 2
    
    # Executa o arquivo com os parâmetros especificados
    .\newhardening.ps1 -apply hardening -configfile "c:\totvs\cis_hardening_windows_server_2016_default_v0.4.json"
} else {
    Write-Host "Erro ao baixar o arquivo 'newhardening.ps1'!"


}
    #Cria Schedule task
    #Gerar arquivo de log da execução do script com timestamp das ações
    #Restart
    #Verificar o caminho do diretório padrão c:\totvs\.
