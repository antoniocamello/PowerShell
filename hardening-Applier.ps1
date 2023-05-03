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

     Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $Product,
    [Parameter(Mandatory=$true, Position=1)]
    [string] $Version
)


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
                       
        Invoke-WebRequest $uri -OutFile $filePath
    }
}



#-------------------------------------------START SCRIPT----------------------------------------------------------
#Incia a chamada das funções

Admin-check

download_hardening_files -Product "generic" -version "stable"











