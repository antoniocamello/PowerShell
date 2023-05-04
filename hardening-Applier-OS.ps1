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

function Apply-Hardening {
    param (
        [string]$Product,
        [string]$Version
    )

    # Cria o diretório base para os arquivos de hardening
    $BaseDirectory = Join-Path -Path $PSScriptRoot -ChildPath 'hardening'

    # Cria o dicionário de dados utilizando JSON com os arquivos de configuração dos produtos
    $json = @"
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
"@

    # Verifica se o produto existe no dicionário de dados
    if ($json -match "`"$Product`":\s*\[(.*?)\]") {
    # Extrai os arquivos de configuração do produto do dicionário
        $productFiles = $matches[1] -replace '\s+', '' | ConvertFrom-Json

        # Percorre a lista de arquivos do produto e baixa cada arquivo
        foreach ($file in $productFiles) {
            $url = $file.url -replace '_var_version', $Version
            $path = Join-Path -Path $BaseDirectory -ChildPath $url

            # Verifica se o arquivo já existe no diretório de hardening, se não existir, baixa o arquivo
            if (!(Test-Path -Path $path)) {
                Download-Hardening-Files -Url $url -Path $path
            }
        }
    } else {
        Write-Error "Product '$Product' not found in hardening data."
    }

    # Aplica a configuração de hardening do produto
    $invokerPath = Join-Path -Path $BaseDirectory -ChildPath 'hardening-Invoker-OS.ps1'
    & $invokerPath
}

function Download-Hardening-Files {
    param (
        [string]$Url,
        [string]$Path
    )

    # Cria o diretório se ele não existir
    $dir = Split-Path $Path
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }

    # Faz download do arquivo
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($Url, $Path)
}


#Apply-Hardening -Product datasul -Version stable
