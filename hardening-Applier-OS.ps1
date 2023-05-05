<# 
NOME:
    hardening-Applier-OS.ps1
DESCRIÇÃO:
    Este script aplica as configurações de Hardening-OS (CIS Control, Windows Services desnecessários, AuditPol, etc);
    
EXEMPLO:
    PS C:\totvs\hardening .\hardening-Applier-OS.ps1 --product generico --version stable 
    Valores da variável product: genérico, datasul, legaldesk, sisjuri, protheus, rm, smartrm, Winthor, Consinco, etc;
    Valores da variável version: stable ou latest
#>

##### GLOBAL VARIABLES
Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $Product,
    [Parameter(Mandatory=$true, Position=1)]
    [string] $Version
)

# Define o diretório local onde os arquivos serão baixados
$HardeningDirectory = "C:\totvs\hardening"

$configFile = "hardening-Config-OS-generic-w2k16.json"
$diffFile = "hardening-Config-OS-$Product-w2k16.json"


#-------------------------------------------FUNCTIONS---------------------------------------------------------

#Função que verifica a execução como Admin
function Admin-check() {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false) {
        Write-Warning "Scritp sendo executado com usuário não-admin. Abortando execução."
        Exit
        
    }

}


#Função que Cria o dicionário de dados e faz o download dos arquivos de configuração dos produtos
function download_hardening_files()
 {

    # Define a URL do repositório
    $repoURI = "http://192.168.1.125:8080/Hardening-OS/"
    
    # Cria o dicionário de dados utilizando JSON com os arquivos de configuração dos produtos
    $json = '
        {
          "generic": [
            {
              "url": "generic/_var_version/hardening-Invoker-OS.ps1"
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
              "url": "generic/_var_version/hardening-Config-OS-generic-w2k16.json"
            },  
            {
              "url": "generic/_var_version/hardening-Invoker-OS.ps1"
            },
            {
              "url": "datasul/_var_version/hardening-Config-OS-Datasul-w2k16.json"
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
       

    
    # Cria o diretório de destino se ele não existir
    if (!(Test-Path -Path $HardeningDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $HardeningDirectory
    }

    # Permeia pelo json para captura da URI de cada arquivo do produto e realiza o download
    foreach ($file in $repository.$product) {
      $uri = [regex]::Replace($repoURI+$file.url,"_var_version",$version)
        $fileName = $uri.Split("/")[-1]
        $filePath = Join-Path -Path $HardeningDirectory -ChildPath $fileName
                       
        Invoke-WebRequest $uri -OutFile $filePath
    }
}

# Função para aplicar o hardening
function Aplica-Hardening {


    $configFilePath = Join-Path -Path $HardeningDirectory -ChildPath $configFile
    $diffFilePath = Join-Path -Path $HardeningDirectory -ChildPath $diffFile
    $invokerPath = Join-Path -Path $HardeningDirectory -ChildPath 'hardening-Invoker-OS.ps1'

    
    if ($product = "generic"){
        & $invokerPath -apply hardening -configfile $configFilePath
        }
    else{
        & $invokerPath -apply hardening -configfile $configFilePath -productfile $diffFilePath
        }
}



# Função para Schedule Task - Hardening-Enforcing (Estado Desejado)
# Admin Rights required
function Hardening-Enforcing() {

  # Caminho do arquivo .ps1 e os parâmetros necessários
        if ($product -match "generic"){
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$HardeningDirectory\hardening-Invoker-OS.ps1`" -apply hardening -configfile `"$HardeningDirectory\hardening-Config-OS-generic-w2k16.json`""
        }
    else{
        write-host $product
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$HardeningDirectory\hardening-Invoker-OS.ps1`" -apply hardening -configfile `"$HardeningDirectory\hardening-Config-OS-generic-w2k16.json`" -productfile `"$HardeningDirectory\$diffFile`"" 
        }
  

  # Define o gatilho para a tarefa agendada
  $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddDays(1) -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration (New-TimeSpan -Days 1)

  # Cria a tarefa agendada
  Register-ScheduledTask -TaskName "Hardening-Enforcing" -Action $action -Trigger $trigger -User "NT AUTHORITY\SYSTEM"
  
}



#-------------------------------------------SCRIPT ---------------------------------------------------------


Clear-Host

# chamada da função que verifica a execução como Admin
Admin-check

# Chamada da função para download dos arquivos de hardening, conforme cada produto
download_hardening_files

# Chamada da função para aplicar o hardening utilizando o script "hardening-Invoker-OS.ps1"
Aplica-Hardening

# chamada da função para configuração do Estado Desejado do Hardening (Enforcing)
Hardening-Enforcing

sleep 4

Write-Host "O Windows será REINICIADO AGUARDE..." -ForegroundColor Yellow

sleep 6

Restart-Computer -Force


 














