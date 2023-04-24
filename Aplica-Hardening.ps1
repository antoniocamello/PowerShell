<# 
NOME:
    Aplica-Hardening
DESCRIÇÃO:
    Este script aplica as configurações de Hardening V1 no Datasul
EXEMPLO:hardening-Invoker-OS
    PS C:\totvs\hardening .\Aplica-Hardening.ps1

#>

Clear-Host

#Função para baixar os arquivos do Repositório e salvar no diretório c:\totvs\hardening
function Baixar-ArquivosHardening {
    $base_directory = 'c:\totvs\hardening'
    $hardening_list = @(
        @{
            uri = 'http://192.168.1.125/hardening/datasul/hardening_os/1.0/auditpol.ps1'
            outfile = 'auditpol.ps1'
            hash = '597503197E030ED67F9A5519F737C9B0AAD77A67772168435E7442B6DD0EFFD8'
           
        },
        @{
            uri = 'http://192.168.1.125/hardening/datasul/hardening_os/1.0/cis_hardening_windows_server_2016_default_v0.4.json'
            outfile = 'cis_hardening_windows_server_2016_default_v0.4.json'
            hash = '8AC837284D09DD0EDE33222507062BA97141832D95F550D5A7127613D9A21C5E'
        },
        @{
            uri = 'http://192.168.1.125/hardening/datasul/hardening_os/1.0/diff.json'
            outfile = 'diff.json'
            hash = 'FC9B3C15D1885AE494581B2C23708C4213B8E96FF6BD8796F7AC4D683932F564'
        },
        @{
            uri = 'http://192.168.1.125/hardening/datasul/hardening_os/1.0/hardening-Invoker-OS.ps1'
            outfile = 'hardening-Invoker-OS.ps1'
            hash = 'AEC1D24EDAB7D2D2CFA0253AFC1FF5FC09D3643A1C913E3A8B957E91E8B66D88'
        },
        @{
            uri = 'http://192.168.1.125/hardening/datasul/hardening_os/1.0/unwantedservices.ps1'
            outfile = 'unwantedservices.ps1'
            hash = '609EB470E2EB91A744327129CE3F52D6EF775A2D4F358D254C081770F5AF14EC'
        }
    )

    # Cria o diretório base se não existe
    if (-not (Test-Path -Path $base_directory)) {
        New-Item -ItemType Directory -Path $base_directory | Out-Null
    }

    foreach ($file in $hardening_list) {
        $uri = $file.uri
        $outfile = Join-Path $base_directory $file.outfile
        $hash = $file.hash

        Write-Host "Baixando arquivo $outfile..."

        # Download do arquivo
        Invoke-WebRequest -Uri $uri -OutFile $outfile

        # Verifica o hash do arquivo
        $filehash = Get-FileHash -Path $outfile -Algorithm SHA256 | Select-Object -ExpandProperty Hash
        if ($filehash -ne $hash) {
            Write-Warning "O hash do arquivo $outfile não corresponde ao hash esperado."
                        
        }
        else {
            Write-Host "Arquivo $outfile baixado com sucesso."
        }
    }
}

#Função para executar o arquivo hardening-Invoker-OS.ps1
function invoke-hardening {
    param (
        [string]$base_directory = 'c:\totvs\hardening',
        [string]$configfile = 'cis_hardening_windows_server_2016_default_v0.4.json',
        [string]$productfile = 'diff.json'
    )

    $invoker_path = Join-Path -Path $base_directory -ChildPath 'hardening\hardening-Invoker-OS.ps1'
    & $invoker_path -apply hardening -configfile (Join-Path -Path $base_directory -ChildPath $configfile) -productfile (Join-Path -Path $base_directory -ChildPath $productfile)
}


function run-auditpol {
    param (
        [string]$base_directory = 'c:\totvs\hardening'
    )
    
    $script_path = Join-Path -Path $base_directory -ChildPath 'auditpol.ps1'
    & $script_path
}

function run-unwantedservices {
    param (
        [string]$base_directory = 'c:\totvs\hardening'
    )
    
    $script_path = Join-Path -Path $base_directory -ChildPath 'unwantedservices.ps1'
    & $script_path
}

#Função para gerar o log de execução do script
function Execute-HardeningScript {
    $LogFilePath = "hardening\hardening_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    
    Write-Host "Iniciando o script de hardening..."
    # aqui entra o código do script
    
    Write-Host "Registrando saída do script no arquivo de log $LogFilePath ..."
    Out-File -FilePath $LogFilePath -InputObject $Output -Encoding UTF8 -Append
}




#-------------------- START SCRIPT ----------------------------------------

$checkfolder = Test-Path "C:\totvs\hardening\backup"
if ($checkfolder -eq $false ) {
    try {
        #Cria a pasta para salvar os arquivos de log e rollback
        New-Item -ItemType Directory -Force -Path "C:\totvs\hardening\backup\" | Out-Null
    }
    catch {
        Write-Warning "Não foi possível criar a pasta em C:\totvs\hardening\backup\, utilizada para salvar logs e o arquivo de rollback. Abortando execução."
        Exit
    }
}

#Executa a chamada das funções

Baixar-ArquivosHardening

invoke-hardening -base_directory 'c:\totvs\hardening' -configfile 'cis_hardening_windows_server_2016_default_v0.4.json' -productfile 'diff.json'

run-unwantedservices

run-auditpol

Gerar-ArquivoLog "MeuLog" "Iniciando execução do script em $(Get-Date)`n"


Write-Host "Configuração de hardening aplicada com SUCESSO!" -ForegroundColor Green
