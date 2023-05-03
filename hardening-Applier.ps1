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

param (
    [Parameter(Mandatory = $true)]
    $product = "generic",
    [Parameter(Mandatory = $true)]
    $version = "stable"
    )

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
function arquivos-hardening($product, $version) {
    # Define a URL do repositório
    if ($product -eq "generic") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/generic/$version"
    }
    elseif ($product -eq "datasul") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/datasul/$version"
    }
    elseif ($product -eq "legaldesk") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/legaldesk/$version"
    }
    elseif ($product -eq "sisjuri") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/sisjuri/$version"
    }
    elseif ($product -eq "protheus") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/protheus/$version"
    }
    elseif ($product -eq "rm") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/rm/$version"
    }
    elseif ($product -eq "smartrm") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/smartrm/$version"
    }
    elseif ($product -eq "winthor") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/winthor/$version"
    }
    elseif ($product -eq "consinco") {
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/consinco/$version"
    }
    else {
        Write-Host "Produto não reconhecido. Utilizando o produto genérico."
        $repoUrl = "http://192.168.1.125:8080/Hardening-OS/generic/$version"
    }

    # Cria o dicionário de dados com os arquivos de configuração dos produtos
    if ($product -eq "generic") {
        $urls = @{
            "generic" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-Generic-w2k16.json" = "$repoUrl/hardening-Config-OS-Generic-w2k16.json" },
                @{ "hardening-Complementary-Generic-AuditPol.ps1" = "$repoUrl/hardening-Complementary-Generic-AuditPol.ps1" },
                @{ "hardening-Complementary-Generic-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-Generic-UnwantedSVCs.ps1" }
            )
        }
    }
    elseif ($product -eq "datasul") {
        $urls = @{
            "datasul" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-Datasul-w2k16.json" = "$repoUrl/hardening-Config-OS-Datasul-w2k16.json" },
                @{ "hardening-Complementary-Datasul-AuditPol.ps1" = "$repoUrl/hardening-Complementary-Datasul-AuditPol.ps1" },
                @{ "hardening-Complementary-Datasul-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-Datatasul-UnwantedSVCs.ps1" }
            )
        }    
    } 
    elseif ($product -eq "legaldesk") {
        $urls = @{
            "legaldesk" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-legaldesk-w2k16.json" = "$repoUrl/hardening-Config-OS-legldesk-w2k16.json" },
                @{ "hardening-Complementary-legaldesk-AuditPol.ps1" = "$repoUrl/hardening-Complementary-legaldesk-AuditPol.ps1" },
                @{ "hardening-Complementary-legaldesk-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-Legaldesk-UnwantedSVCs.ps1" }
            )
        }    
    }  
    elseif ($product -eq "sisjuri") {
        $urls = @{
            "sisjuri" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-sisjuri-w2k16.json" = "$repoUrl/hardening-Config-OS-sisjuri-w2k16.json" },
                @{ "hardening-Complementary-sisjuri-AuditPol.ps1" = "$repoUrl/hardening-Complementary-sisjuri-AuditPol.ps1" },
                @{ "hardening-Complementary-sisjuri-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-sisjuri-UnwantedSVCs.ps1" }
            )
        }    
    } 
    elseif ($product -eq "rm") {
        $urls = @{
            "rm" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-rm-w2k16.json" = "$repoUrl/hardening-Config-OS-rm-w2k16.json" },
                @{ "hardening-Complementary-rm-AuditPol.ps1" = "$repoUrl/hardening-Complementary-rm-AuditPol.ps1" },
                @{ "hardening-Complementary-rm-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-rm-UnwantedSVCs.ps1" }
            )
        }    
    }  
    elseif ($product -eq "protheus") {
        $urls = @{
            "protheus" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-protheus-w2k16.json" = "$repoUrl/hardening-Config-OS-protheus-w2k16.json" },
                @{ "hardening-Complementary-protheus-AuditPol.ps1" = "$repoUrl/hardening-Complementary-protheus-AuditPol.ps1" },
                @{ "hardening-Complementary-protheus-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-protheus-UnwantedSVCs.ps1" }
            )
        }    
    }
    elseif ($product -eq "smartrm") {
        $urls = @{
            "smartrm" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-smatrm-w2k16.json" = "$repoUrl/hardening-Config-OS-smatrm-w2k16.json" },
                @{ "hardening-Complementary-smartrm-AuditPol.ps1" = "$repoUrl/hardening-Complementary-smartrm-AuditPol.ps1" },
                @{ "hardening-Complementary-smartrm-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-smartrm-UnwantedSVCs.ps1" }
            )
        }    
    } 
    elseif ($product -eq "winthor") {
        $urls = @{
            "winthor" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-winthor-w2k16.json" = "$repoUrl/hardening-Config-OS-winthor-w2k16.json" },
                @{ "hardening-Complementary-winthor-AuditPol.ps1" = "$repoUrl/hardening-Complementary-winthor-AuditPol.ps1" },
                @{ "hardening-Complementary-winthor-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-winthor-UnwantedSVCs.ps1" }
            )
        }    
    }
    elseif ($product -eq "consinco") {
        $urls = @{
            "consinco" = @(
                @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
                @{ "hardening-Config-OS-consinco-w2k16.json" = "$repoUrl/hardening-Config-OS-consinco-w2k16.json" },
                @{ "hardening-Complementary-consinco-AuditPol.ps1" = "$repoUrl/hardening-Complementary-consinco-AuditPol.ps1" },
                @{ "hardening-Complementary-consinco-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-consinco-UnwantedSVCs.ps1" }
            )
        }    
    }                                     
}

    # Verifica se o diretório local existe, caso não exista, cria a estrutura
    if (!(Test-Path $localDirectory)) {
        New-Item -ItemType Directory -Force -Path $localDirectory | Out-Null
        Write-Host "Diretório $localDirectory criado com sucesso."
    }

    # Faz o download dos arquivos
    foreach ($url in $urls.GetEnumerator()) {
        $fileName = $url.Key
        $fileUrl = $url.Value
        $filePath = Join-Path -Path $localDirectory -ChildPath $fileName

        Write-Host "Fazendo download do arquivo $fileName de $fileUrl para $filePath"

        # Verifica se o arquivo já existe localmente, caso exista, pula o download
        if (Test-Path $filePath) {
            Write-Host "O arquivo $fileName já existe localmente, pulando o download."
            continue
        }

        try {
            Invoke-WebRequest -Uri $fileUrl -OutFile $filePath -UseBasicParsing -ErrorAction Stop
            Write-Host "Download do arquivo $fileName concluído com sucesso."
        } catch {
            Write-Host "Erro ao fazer o download do arquivo $fileName de $fileUrl. Detalhes do erro: $_"
        }
    }
