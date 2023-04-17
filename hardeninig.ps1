clear-host
Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
Write-Host " "    
Write-Host "                               TOTVS CLOUD - HARDENING NEXT GENERATION                            "    
Write-Host " "    
Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
#Write-Host "::::::" -ForegroundColor DarkYellow
Write-Host " "
Write-Host "                             Escolha a configuração que deseja aplicar:                           " -ForegroundColor Yellow
Write-Host " "

Write-Host "[01] Aplicar hardening de SegInfo"
Write-Host "[02] Aplicar a configuração padrão do Windows"
Write-Host "[03] Aplicar rollback da ultima configuração válida"
Write-Host ""
Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
Write-Host ""

do {
    $opcao = Read-Host "Opção escolhida"
} until ($opcao -in 01..03)

switch ($opcao) {
    01 { 
        $apply = "hardening"
        $configfile = Read-Host "C:\company\hardening-Config-OS-generic-w2k16-v0.4.json"
        ./hardening-Invoker-OS.ps1 -apply $apply -configfile $configfile
    }
    02 {
        $apply = "windowsdefault"
        ./hardening-Invoker-OS.ps1 -apply $apply
    }
    03 {
        $apply = "rollback"
        $configfile = Read-Host "Caminho do arquivo de rollback"
        ./hardening-Invoker-OS.ps1 -apply $apply -configfile $configfile
    }
}
