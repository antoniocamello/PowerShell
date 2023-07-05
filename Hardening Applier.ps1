<# 
NOME:
    hardening-Applier-OS.ps1
DESCRIÇÃO:
    Este script aplica as configurações de Hardening-OS (CIS Control, Windows Services desnecessários, AuditPol, etc);
    
EXEMPLO:
    PS C:\totvs\hardening .\hardening-Applier-OS.ps1 -product generico -version stable 
    Valores da variável product: genérico, datasul, legaldesk, sisjuri, protheus, rm, smartrm, Winthor, Consinco, etc;
    Valores da variável version: stable ou latest

VERSION:
    1.0
#>


#-------------------------------------------GLOBAL VARIABLES SECTOR---------------------------------------------------------
Param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string] $Product,
  [Parameter(Mandatory = $true, Position = 1)]
  [string] $Version
)

"Product = $product"
"Version = $Version"

# Define o diretório local onde os arquivos serão baixados
$HardeningDirectory = "C:\totvs\hardening"

$configFile = "hardening-Config-OS-generic-w2k16.json"
$diffFile = "hardening-Config-OS-$Product-w2k16.json"


# Define a URL do repositório
$repoURI = "http://repo-$($env:CloudEdgeEnv).cloudtotvs.com.br/windows/hardening-os/"

# Cria o log de execução do Script "hardening-Invoker-OS.ps1"
New-Folder "c:\totvs\hardening\log\"
$logFilePath = "c:\totvs\hardening\log\hardeningApplier$(hostname)-$((Get-Date).ToString('dd-MM-yyyy')).txt"
Start-Transcript -Path $logFilePath


#-------------------------------------------END GLOBAL VARIABLES SECTOR---------------------------------------------------------




#------------------------------------------- FUNCTIONS SECTOR---------------------------------------------------------

#Função que verifica a execução como Admin
function Get-Admin-check() {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false) {
    Write-Warning "Scritp sendo executado com usuário não-admin. Abortando execução."
    Exit
        
  }

}


#Função que Cria o dicionário de dados e faz o download dos arquivos de configuração dos produtos
function Get-Download_hardening_files() {


    
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
          ],
          "legaldesk": [
            {
              "url": "generic/_var_version/hardening-Config-OS-generic-w2k19.json"
            },  
            {
              "url": "generic/_var_version/hardening-Invoker-OS.ps1"
            },
            {
              "url": "legaldesk/_var_version/hardening-Config-OS-legaldesk-w2k19.json"
            },
            {
              "url": "generic/_var_version/hardening-Complementary-generic-AuditPol.ps1"
            },
            {
              "url": "generic/_var_version/hardening-Complementary-generic-UnwantedSVCs.ps1"
            },
            {
              "url": "legaldesk/_var_version/hardening-Complementary-legaldesk-IIS.ps1"
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
    $uri = [regex]::Replace($repoURI + $file.url, "_var_version", $version)
    $fileName = $uri.Split("/")[-1]
    $filePath = Join-Path -Path $HardeningDirectory -ChildPath $fileName
                       
    Invoke-WebRequest $uri -OutFile $filePath -UseBasicParsing
  }
}

# Função para aplicar o hardening
function Set-Aplica-Hardening {


  $configFilePath = Join-Path -Path $HardeningDirectory -ChildPath $configFile
  $diffFilePath = Join-Path -Path $HardeningDirectory -ChildPath $diffFile
  $invokerPath = Join-Path -Path $HardeningDirectory -ChildPath 'hardening-Invoker-OS.ps1'

  write-host $Product
    
  if ($Product -match "generic") {
    & $invokerPath -apply hardening -configfile $configFilePath
  }
  else {
    & $invokerPath -apply hardening -configfile $configFilePath -productfile $diffFilePath
  }
}



# Função para Schedule Task - Hardening-Enforcing (Estado Desejado)
# Admin Rights required
function Set-Hardening-Enforcing() {

  # Caminho do arquivo .ps1 e os parâmetros necessários
  if ($product -match "generic") {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$HardeningDirectory\hardening-Invoker-OS.ps1`" -apply hardening -configfile `"$HardeningDirectory\hardening-Config-OS-generic-w2k16.json`""
  }
  else {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$HardeningDirectory\hardening-Invoker-OS.ps1`" -apply hardening -configfile `"$HardeningDirectory\hardening-Config-OS-generic-w2k16.json`" -productfile `"$HardeningDirectory\$diffFile`"" 
  }
  

  # Define o gatilho para a tarefa agendada
  $trigger = New-ScheduledTaskTrigger -Daily -At "05:00" -RandomDelay $(New-TimeSpan -Hours 16)

  # Cria a tarefa agendada
  Register-ScheduledTask -TaskName "Hardening-Enforcing" -Action $action -Trigger $trigger -User "NT AUTHORITY\SYSTEM" -Description "Created At: $(get-date)" -RunLevel Highest -Force
  if ($? -eq $true) {
    write-host "$(Get-Date) - Hardening-Enforcing criada com sucesso."
    return $true
  }
  Write-Warning "Falha ao criar Hardening-Enforcing"
  return false
}

#------------------------------------------END FUNCTIONS SECTOR---------------------------------------------------------


#------------------------------------------- SCRIPT SECTOR---------------------------------------------------------


Clear-Host

# chamada da função que verifica a execução como Admin
Get-Admin-check

# Chamada da função para download dos arquivos de hardening, conforme cada produto
Get-Download_hardening_files

# Chamada da função para aplicar o hardening utilizando o script "hardening-Invoker-OS.ps1"
Set-Aplica-Hardening

# chamada da função para configuração do Estado Desejado do Hardening (Enforcing)
Set-Hardening-Enforcing

# Reinicializa o sistema
Write-Host "O Windows será REINICIADO AGUARDE..." -ForegroundColor Yellow

# Cria e exporta o log de execução do Script "hardening-Invoker-OS.ps1"
Stop-Transcript

#Restart-Computer -Force



#-------------------------------------------END SCRIPT SECTOR---------------------------------------------------------

 
