<# 
NOME:
    hardening-Applier-OS-Generic.ps1
DESCRIÇÃO:
    Este script aplica as configurações de Hardening Especificadas pelo CIS no Sistama Operacional
    Sem referencia a nenhum produto TOTVs.
EXEMPLO:hardening-Invoker-OS
    PS C:\totvs\hardening .\hardening-Applier-OS-Generic.ps1

#>

Clear-Host

#Função que verifica a execução como Admin
function Admin-check {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false) {
        Write-Warning "Scritp sendo executado com usuário não-admin. Abortando execução."
        Exit
        
    }

}

#Função para baixar os arquivos do Repositório e salvar no diretório c:\totvs\hardening
param (
    [Parameter(Mandatory=$true)]
    [string]$produto
)

function invoke-hardening {
    param (
        [Parameter(Mandatory=$true)]
        [string]$produto
    )

    # Diretório base para os arquivos de configuração
    $base_directory = 'c:\totvs\hardening'

    # URLs para download dos arquivos de configuração
    $repo_totvs_edge_url = "192.168.1.125"

    $urls = @{
        "generico" = @(
            @{ "file1" = "$repo_totvs_edge_url/Hardening-OS/generic/stable/hardening-Invoker-OS-Generic.ps1" },
            @{ "file2" = "$repo_totvs_edge_url/Hardening-OS/generic/stable/hardening-Config-OS-Generic-w2k16.json" },
            @{ "file2" = "$repo_totvs_edge_url/Hardening-OS/generic/stable/hardening-Complementary-Generic-AuditPol.ps1" },
            @{ "file2" = "$repo_totvs_edge_url/Hardening-OS/generic/stable/hardening-Complementary-Generic-UnwantedSVCs.ps1" }
        ),
        "datasul" = @(
            @{ "file1" = "$repo_totvs_edge_url/Hardening-OS/generic/stable/hardening-Config-OS-Datasul-w2k16.json" },
            @{ "file2" = "" },
            @{ "file3" = "" }
        )
    }

    if (-not $urls.ContainsKey($produto)) {
        Write-Error "Produto inválido: $produto"
        return
    }

    $url_list = $urls[$produto]

    # Cria o diretório base se não existe
    if (-not (Test-Path -Path $base_directory)) {
        New-Item -ItemType Directory -Path $base_directory | Out-Null
    }

    # Download dos arquivos de configuração
    foreach ($file in $url_list) {
        $url = $file.url
        $outfile = Join-Path $base_directory (Split-Path -Leaf $url)

        Write-Host "Baixando arquivo $outfile..."

        # Download do arquivo
        Invoke-WebRequest -Uri $url -OutFile $outfile

        Write-Host "Arquivo $outfile baixado com sucesso."
    }

    # Aplica as configurações
    $config_file = Join-Path $base_directory "hardening-Config-OS-$produto-w2k16.json"
    $invoker_file = Join-Path $base_directory "hardening-Invoker-OS-Generic.ps1"

    if (-not (Test-Path -Path $config_file)) {
        Write-Error "Arquivo de configuração não encontrado: $config_file"
        return
    }

    if (-not (Test-Path -Path $invoker_file)) {
        Write-Error "Arquivo de invocação não encontrado: $invoker_file"
        return
    }

    Write-Host "Aplicando configurações do produto $produto..."

    # Executa o script de invocação para aplicar as configurações
    . $invoker_file -ConfigFile $config_file

    Write-Host "Configurações do produto $produto aplicadas com sucesso."
}

invoke-hardening -produto $produto

    #Função para executar o arquivo hardening-Invoker-OS.ps1
function invoke-hardening {
    param (
        [string]$base_directory = 'c:\totvs\hardening',
        [string]$configfile = 'hardening-Config-OS-Generic-w2k16.json',
        [string]$productfile = 'hardening-Config-OS-datasul-w2k16.json'
    )

    $invoker_path = Join-Path -Path $base_directory -ChildPath 'hardening-Invoker-OS-Generic.ps1'
    & $invoker_path -apply hardening -configfile (Join-Path -Path $base_directory -ChildPath $configfile) 

}
#invoke-hardening -configfile 'cis_hardening_windows_server_2016_default_v0.4.json' -productfile 'diff.json'


#Função para Ativar as configurações de auditoria do Windows
function run-auditpol {
    param (
        [string]$base_directory = 'c:\totvs\hardening'
    )
    
    $script_path = Join-Path -Path $base_directory -ChildPath 'hardening-Complementary-generic-AuditPol'
    & $script_path
}

#Função para Desabilitar os serviços desnecessários do Windows
function run-unwantedservices {
    param (
        [string]$base_directory = 'c:\totvs\hardening'
    )
    
    $script_path = Join-Path -Path $base_directory -ChildPath 'hardening-Complementary-generic-UnwantedSVCs.ps1'
    & $script_path
}


#-------------------- START SCRIPT ----------------------------------------
 #Cria a pasta para salvar os arquivos de log
# RESULT_SECEDIT  tem o log do que foi aplicado via secedit
# RESULT_REGISTRY tem o log do que foi aplicato via registro
$checkfolder = Test-Path "C:\totvs\hardening\log\"
if ($checkfolder -eq $false ) {
    try {
       
        New-Item -ItemType Directory -Force -Path "C:\totvs\hardening\log\" | Out-Null
    }
    catch {
        Write-Warning "Não foi possível criar a pasta em C:\totvs\hardening\log\, utilizada para salvar logs. Abortando execução."
        Exit
    }
}

#Cria a pasta para salvar os arquivos de Backup [rollback]
#HARDENINGBACKUP é o arquivo com as configurações atuais do servidor (antes da aplicação do hardening). 
$checkfolder = Test-Path "C:\totvs\hardening\backup"
if ($checkfolder -eq $false ) {
    try {
        
        New-Item -ItemType Directory -Force -Path "C:\totvs\hardening\backup\" | Out-Null
    }
    catch {
        Write-Warning "Não foi possível criar a pasta em C:\totvs\hardening\backup\, utilizada para salvar logs e o arquivo de rollback. Abortando execução."
        Exit
    }
}

#Executa a chamada das funções

Admin-check

Baixar-Arquivos -produto "generico"
#Baixar-Arquivos -produto "datasul"

invoke-hardening -configfile 'hardening-Config-OS-Generic-w2k16.json' -productfile 'hardening-Config-OS-datasul-w2k16.json'

run-unwantedservices

run-auditpol

#Cria o agendamento do enforcement no task scheduler 
$taskName = "Hardening-OS-Enforcing" 

# Caminho do arquivo .ps1 e os parâmetros necessários
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"C:\totvs\hardening\hardening-Invoker-OS-Generic.ps1`" -apply hardening -configfile `"c:\totvs\hardening\hardening-Config-OS-Generic-w2k16.json`"" 
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddDays(1) -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration (New-TimeSpan -Days 1)

# Cria a tarefa no task schedule do Windows
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User "NT AUTHORITY\SYSTEM"

#Após a aplicação do hardening é necessário fazer um boot na máquina.
Restart-Computer -Force



