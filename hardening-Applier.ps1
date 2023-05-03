param (
    [string]$product = "generic",
    [string]$version = "stable"
)

# Define o diretório local onde os arquivos serão baixados
$localDirectory = "C:\totvs\hardening"
if (!(Test-Path $localDirectory)) {
    New-Item -ItemType Directory -Path $localDirectory
}

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
    $repoUrl = "http://192.168.1.125:8080/Hardening-OS/generic/$version"
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
    $repoUrl = "http://192.168.1.125:8080/Hardening-OS/datasul/$version"
    $urls = @{
        "datasul" = @(
            @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Generic.ps1" },
            @{ "hardening-Config-OS-Datasul-w2k16.json" = "$repoUrl/hardening-Config-OS-Datasul-w2k16.json" },
            @{ "hardening-Complementary-Datasul-AuditPol.ps1" = "$repoUrl/hardening-Complementary-Datasul-AuditPol.ps1" },
            @{ "hardening-Complementary-Datasul-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-Datasul-UnwantedSVCs.ps1" }
        )
    }
}
elseif ($product -eq "legaldesk") {
    $repoUrl = "http://192.168.1.125:8080/Hardening-OS/legaldesk/$version"
    $urls = @{
        "legaldesk" = @(
            @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Legaldesk.ps1" },
            @{ "hardening-Config-OS-Legaldesk-w2k16.json" = "$repoUrl/hardening-Config-OS-Legaldesk-w2k16.json" },
            @{ "hardening-Complementary-Legaldesk-AuditPol.ps1" = "$repoUrl/hardening-Complementary-Legaldesk-AuditPol.ps1" },
            @{ "hardening-Complementary-Legaldesk-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-Legaldesk-UnwantedSVCs.ps1" }
        )
    }
}

} 
elseif ($product -eq "protheus") {
    $repoUrl = "http://192.168.1.125:8080/Hardening-OS/protheus/$version"
    $urls = @{
        "protheus" = @(
            @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-Protheus.ps1" },
            @{ "hardening-Config-OS-Protheus-w2k16.json" = "$repoUrl/hardening-Config-OS-Protheus-w2k16.json" },
            @{ "hardening-Complementary-Protheus-AuditPol.ps1" = "$repoUrl/hardening-Complementary-Protheus-AuditPol.ps1" },
            @{ "hardening-Complementary-Protheus-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-Protheus-UnwantedSVCs.ps1" }
        )
    }
} elseif ($product -eq "rm") {
    $repoUrl = "http://192.168.1.125:8080/Hardening-OS/rm/$version"
    $urls = @{
        "rm" = @(
            @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-RM.ps1" },
            @{ "hardening-Config-OS-RM-w2k16.json" = "$repoUrl/hardening-Config-OS-RM-w2k16.json" },
            @{ "hardening-Complementary-RM-AuditPol.ps1" = "$repoUrl/hardening-Complementary-RM-AuditPol.ps1" },
            @{ "hardening-Complementary-RM-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-RM-UnwantedSVCs.ps1" }
        )
    }
} elseif ($product -eq "smartrm") {
    $repoUrl = "http://192.168.1.125:8080/Hardening-OS/smartrm/$version"
    $urls = @{
        "smartrm" = @(
            @{ "hardening-Invoker-OS.ps1" = "$repoUrl/hardening-Invoker-OS-SmartRM.ps1" },
            @{ "hardening-Config-OS-SmartRM-w2k16.json" = "$repoUrl/hardening-Config-OS-SmartRM-w2k16.json" },
            @{ "hardening-Complementary-SmartRM-AuditPol.ps1" = "$repoUrl/hardening-Complementary-SmartRM-AuditPol.ps1" },
            @{ "hardening-Complementary-SmartRM-UnwantedSVCs.ps1" = "$repoUrl/hardening-Complementary-SmartRM-UnwantedSVCs.ps1" }
        )
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
