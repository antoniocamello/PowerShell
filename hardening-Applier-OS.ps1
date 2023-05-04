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

# Definir as variáveis globais
$global:Product = $null
$global:Version = $null

# Obter os parâmetros passados pelo usuário
Param(
  [Parameter(Mandatory = $true)]
  [string]$Product,
  [Parameter(Mandatory = $true)]
  [string]$Version
)

# Atribuir os valores dos parâmetros às variáveis globais
$global:Product = $Product
$global:Version = $Version


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
  # Usando as variáveis globais definidas no escopo do script
  $product = $global:Product
  $version = $global:Version



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
              "url": "generic/_var_version/hardening-Invoker-OS.ps1"
            },
            {
              "url": "datasul/_var_version/hardening-Config-OS-Datasul-w2k16.json"
            },
            {
              "url": "datasul/_var_version/hardening-Complementary-Datasul-AuditPol.ps1"
            },
            {
              "url": "datasul/_var_version/hardening-Complementary-Datasul-UnwantedSVCs.ps1"
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
    $uri = [regex]::Replace($repoURI + $file.url, "_var_version", $version)
    $fileName = $uri.Split("/")[-1]
    $filePath = Join-Path -Path $destPath -ChildPath $fileName
                       
    Invoke-WebRequest $uri -OutFile $filePath
  }
}

download_hardening_files 

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

function Aplica-Hardening {

  # Usar as variáveis globais definidas no escopo do script
  $product = $global:Product
  $version = $global:Version
    
  $BaseDirectory = 'c:\totvs\hardening'
   
  $configFile = "hardening-Config-OS-$Product-w2k16.json"
  $configFilePath = Join-Path -Path $BaseDirectory -ChildPath $configFile
  $invokerPath = Join-Path -Path $BaseDirectory -ChildPath 'hardening-Invoker-OS.ps1'

  & $invokerPath -apply hardening -configfile $configFilePath
}

Aplica-Hardening -Product generic -Version stable


#-------------------------------------------START SCRIPT----------------------------------------------------------

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



#Incia a chamada das funções

Admin-check

 














