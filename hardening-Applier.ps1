<# 
NOME:
    hardening-Applier-OS.ps1
DESCRIÇÃO:
    Este script aplica as configurações de Hardening Especificadas pelo CIS no Sistama Operacional
    
EXEMPLO:hardening-Invoker-OS
    PS C:\totvs\hardening .\hardening-Applier-OS.ps1 --product generico --version stable 
    Valores da variável product: genérico, datasul, legaldesk, sisjuri, protheus, rm, smartrm, Winthor, Consinco, etc;
    Valores da variável version: stable ou latest
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

# Define o diretório local onde os arquivos serão baixados
$localDirectory = "C:\totvs\hardening"
if (!(Test-Path $localDirectory)) {
    New-Item -ItemType Directory -Path $localDirectory
}

#Função que Cria o dicionário de dados com os arquivos de configuração dos produtos
function download_hardening_files()
 {

     Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $product,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $version
    )


    # Define a URL do repositório
    $repoURI = "http://192.168.1.125:8080/Hardening-OS/"
    
    # Cria o dicionário de dados utilizando JSON com os arquivos de configuração dos produtos
    $json = '
        {
          "generic": [
            {
              "url": "generic/_var_version/hardening-Invoker-OS-Generic.ps1"
            },
            {
              "url": "generic/_var_version/hardening-Config-OS-generic-w2k16.json"
            },
            {
              "url": "generic/_var_version/hardening-Complementary-generic-AuditPol.ps1"
            },
            {
              "url": "generic/_var_version/hardening-Complementary-generic-UnwantedSVCs.ps1"
            }
          ],
          "datasul": [
            {
              "url": "generic/_var_version/hardening-Invoker-OS-Generic.ps1"
            },
            {
              "url": "datasul/_var_version/hardening-Config-OS-datasul.json"
            },
            {
              "url": "generic/_var_version/hardening-Complementary-generic-AuditPol.ps1"
            },
            {
              "url": "generic/_var_version/hardening-Complementary-generic-UnwantedSVCs.ps1"
            }
          ]
        }
    '
    $repository = $json | ConvertFrom-Json
       

    # Define o diretório de destino
    $destPath = "c:\totvs\hardening\"
    
    # Cria o diretório de destino se ele não existir
    if (!(Test-Path -Path $destPath -PathType Container)) {
        New-Item -ItemType Directory -Path $destPath
    }

    # Permeia pelo json para captura da URI de cada arquivo do produto e realiza o download
    foreach ($file in $repository.$product) {
        $uri = [regex]::Replace($repoURI+$file.url,"_var_version",$version)
        $fileName = $uri.Split("/")[-1]
        $filePath = Join-Path -Path $destPath -ChildPath $fileName

        write-host $uri
                
        Invoke-WebRequest $url -OutFile $filePath
    }
}
##Cria o agendamento do enforcement no task scheduler
function enforcement-Hardening {
    # Define o nome da tarefa agendada
    $taskName = "Enforcement-Hardening" 

    # Caminho do arquivo .ps1 e os parâmetros necessários
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"C:\totvs\hardening\hardening-Invoker-OS.ps1`" -apply hardening -configfile `"c:\totvs\hardening\cis_hardening_windows_server_2016_default.json`" -productfile `"c:\totvs\hardening\diff.json`"" 

    # Define o gatilho para a tarefa agendada
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddDays(1) -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration (New-TimeSpan -Days 1)

    # Cria a tarefa agendada
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User "NT AUTHORITY\SYSTEM"
}




#-------------------------------------------START SCRIPT----------------------------------------------------------
#Incia a chamada das funções

Admin-check

download_hardening_files -Product "generic" -version "stable"

enforcement-Hardening


