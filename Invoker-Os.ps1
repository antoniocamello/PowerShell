param (
	#[switch] $disable,
    [parameter(mandatory = $true, HelpMessage="hardening (para aplicar o hardening de SegInfo) | windowsdefault (para aplicar a configuração padrão do Windows) | rollback (para aplicar a última configuração desse servidor antes do hardening ter sido aplicado")]
    [string] $apply = "",
    [parameter(mandatory = $true, HelpMessage="Especificar o caminho do arquivo de hardening ou do arquivo de rollback.")]
    [string] $configfile = "", 
    [parameter(HelpMessage="Especificar o caminho do arquivo de diff (policy do produto).")]
    [string] $productfile = $null
)


#region Registry Functions

function Get-RegistryValue {
    param(
        [parameter(mandatory = $true)]
        [string]$Path,
        [parameter(mandatory = $true)]
        [string]$Name
    )
    $ErrorActionPreference = 'SilentlyContinue'
    $WarningPreference = 'SilentlyContinue'
    try {
        $result = $regValue = Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Name -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "$Name em $Path não encontado."
        $result = $null
    }
    return $result

}

function New-RegistryEntry {
    param(
        [parameter(mandatory = $true)]
        [string]$Path,
        [parameter(mandatory = $true)]
        [string]$Name,
        [parameter(mandatory = $true)]
        $Value,
        $PropertyType,
        [switch]$Force,
        [string]$Description,
        [string]$GID
    )
    if ($Description.Length -eq 0) {
        $Description = "Change Path:$Path Name:$Name Value:$Value"
    }
    $fix = $false

    if (!$Force) {
        try {
            $regValue = Get-RegistryValue  -Path $Path -Name $Name
            $status = $regValue -eq $Value
        }
        catch {
            Write-Warning "Falha ao verificar $Path"
            $status = $false
        }
    }
    else {
        write-host "-Force"
        $status = $false
    }


    if ($status -ne $true) {
        try {
            $ExistPath = Test-Path $Path 
            if ($ExistPath -eq $false) {
                #Start-Sleep -Milliseconds 10
                New-Item $Path -Force | Out-Null 
            }
            New-ItemProperty -path $Path -name $Name -value $Value -PropertyType $PropertyType -Force | Out-Null
            $status = $true  
            $fix = $true 
        }
        catch {
            throw "Falha ao criar p:$Path t:$PropertyType n:$Name v:$Value"
            $status = $false 
            $fix = $false  
        }
    } 

    $result = [PSCustomObject]@{
        Edge          = $env:CloudEdgeEnv
        Hostname      = $(Hostname)
        GID           = $GID
        Description   = $Description
        Path          = $Path
        Name          = $Name
        PropertyType  = $PropertyType
        CurrentConfig = $regValue
        NewConfig     = $Value
        Status        = $status
        Fix           = $fix
        Timestamp     = (get-date).ToString('dd-MM-yyyy HH:mm:ss')
    }

    if ($null -eq $regValue) {
        $regValue = "Remove"
    }

    $backup = [PSCustomObject]@{
        GID            = $GID
        Description    = $Description
        Path           = $Path
        Name           = $Name
        Type           = $PropertyType
        RollbackConfig = $regValue
    }

    return $result, $backup
}

function Remove-RegistryEntry {
    param(
        [parameter(mandatory = $true)]
        [string]$Path,
        [parameter(mandatory = $true)]
        [string]$Name,
        $PropertyType,
        [switch]$Force,
        [string]$Description,
        [string]$GID
    )
    if ($Description.Length -eq 0) {
        $Description = "Change Path:$Path Name:$Name Value:$Value"
    }
    $fix = $false

    if (!$Force) {
        try {
            $regValue = Get-RegistryValue  -Path $Path -Name $Name
            $status = $regValue -eq $Value
        }
        catch {
            Write-Warning "Falha ao verificar $Path"
            $status = $false
        }
    }
    else {
        write-host "-Force"
        $status = $false
    }

    if ($status -ne $true) {
        try {
            #$ExistPath = Test-Path $fullpath
            Remove-ItemProperty -Path $Path -Name $Name | Out-Null 
            $status = $true
            $fix = $true
        }
        catch {
            throw "Falha ao remover p:$Path n:$Name"
            $status = $false 
            $fix = $false  
        }
    } 

    $result = [PSCustomObject]@{
        Edge          = $env:CloudEdgeEnv
        Hostname      = $(Hostname)
        Description   = $Description
        Path          = $Path
        Name          = $Name
        PropertyType  = $PropertyType
        CurrentConfig = $regValue
        NewConfig     = $Value
        Status        = $status
        Fix           = $fix
        Timestamp     = (get-date).ToString('dd-MM-yyyy HH:mm:ss')
    }

    if ($null -eq $regValue) {
        $regValue = "Remove"
    }

    $backup = [PSCustomObject]@{
        GID            = $GID
        Description    = $Description
        Path           = $Path
        Name           = $Name
        Type           = $PropertyType
        RollbackConfig = $regValue
    }

    return $result, $backup
}

function Set-RegistryPolicy {

    #Carrega os itens da policy default removendo os itens que também estiverem no diff do produto
    $defaultregistry = $policy.registrypolicy | Where-Object {($_.GID -notin $productpolicy.registrypolicy.GID)}
    #Carrega os itens da policy de diff do produto
    $diffregistry = $productpolicy.registrypolicy
    
    #Valida se o diff não é $null e junta as duas policies (default + diff)
    if ($null -ne $diffregistry) {
        $allregistry = $defaultregistry + $diffregistry
    }
    else {
        $allregistry = $defaultregistry
    }

    $recursereg = {
        $resultregistry = @()
        $registrybackup = @()
        $resultregistryinc = @()
        $registrybackupinc = @()
        #$resultregistrytemp = @()
        #$resultregistry = New-Object System.Collections.ArrayList
        foreach ($item in @($args[0])) {
            #if ($item.Enable -ne "Remove") {
            if ($item.$policyoption -ne "Remove") {
                #$resultregistry += New-RegistryEntry -path $item.Path -name $item.name -value $item.Enable -PropertyType $item.Type -Description $item.Description
                
                $resultregistry, $registrybackup = New-RegistryEntry -path $item.Path -name $item.name -value $item.$policyoption -PropertyType $item.Type -Description $item.Description -GID $item.GID
                $resultregistryinc += $resultregistry
                $registrybackupinc += $registrybackup 
                #$resultregistrytemp = New-RegistryEntry -path $item.Path -name $item.name -value $item.$policyoption -PropertyType $item.Type -Description $item.Description
                #$resultregistry.Add($resultregistrytemp)
                #Write-Output "New-RegistryEntry -path $($item.Path) -name $($item.name) -value $($item.Enable) -PropertyType $($item.Type) -Description $($item.Description) -GID $($item.GID)"
            }
            else {
                $resultregistry, $registrybackup  = Remove-RegistryEntry -path $item.Path -name $item.name -PropertyType $item.Type -Description $item.Description -GID $item.GID
                $resultregistryinc += $resultregistry
                $registrybackupinc += $registrybackup
                #$resultregistrytemp = Remove-RegistryEntry -path $item.Path -name $item.name -Description $item.Description
                #$resultregistry.Add($resultregistrytemp)
                #Write-Output "Delete-RegistryEntry -path $($item.Path) -name $($item.name) -Description $($item.Description) -GID $($item.GID)"
            }
        }
        return $resultregistryinc, $registrybackupinc
    }
    $resultregistry2, $registrybackup = & $recursereg $allregistry

    return $resultregistry2, $registrybackup

}

function Set-HardeningRegistry {

    foreach ($i in $args) {

        if ( $null -ne $i ){
            $propname = $i.controlversion[0].psobject.properties | Select-Object -ExpandProperty name
    
            $propname = $propname -ne "Edge"
            $propname = $propname -ne "Hostname"
            $propname = $propname -ne "ExecutionTime"
            $propname = $propname -ne "Type"
    
            foreach ($h in $propname) {
                #Write-Output "New-RegistryEntry -path HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\COMPANY\Security\$($policy1.controlversion.Type) -name $($h) -value $($policy1.controlversion.$h) -PropertyType String"
                #Write-Output "New-RegistryEntry -path HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\COMPANY\Security -name $($h) -value $($i.controlversion.$h) -PropertyType String"
                New-RegistryEntry -path "HKLM:\\SOFTWARE\\WOW6432NODE\\COMPANY\\Security\\$($i.controlversion.Type)" -name $($h) -value $($i.controlversion.$h) -PropertyType String | out-null
            }
        }

    }

    #Write-Output "New-RegistryEntry -path HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\COMPANY\Security -name ExecutionTime -value $executiontimedate -PropertyType String"
    New-RegistryEntry -path "HKLM:\\SOFTWARE\\WOW6432NODE\\COMPANY\\Security\\$($i.controlversion.Type)" -name ExecutionTime -value $executiontimedate -PropertyType String  | out-null
    #Write-Output "New-RegistryEntry -path HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\COMPANY\Security -name LastApplyOption -value $policyoption -PropertyType String"
    New-RegistryEntry -path "HKLM:\\SOFTWARE\\WOW6432NODE\\COMPANY\\Security\\$($i.controlversion.Type)" -name LastApplyOption -value $policyoption -PropertyType String | out-null
}

#endregion 


#region Secedit Functions

function Get-SeceditValue {
    param(
        [parameter(mandatory = $true)]
        $value,
        [parameter(mandatory = $true)]
        $runningconfig,
        [string]$Description,
        [string]$GID
    )

    #Itens de controle são incluídos diretamente no arquivo de configuração.
    if ($Description -ieq "Control"){
        $NewSeceditPol = $value
        $Name = $value
        $fix = $false
    }
    else {
        $splitvalue = $value.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
        $splitvalue = $splitvalue.Trim()
        
        $currentSetting = $runningconfig | Where-Object {($_ -like $splitvalue[0]+"*")}
        
        if ($null -ne $currentSetting) {
            $splitcs = $currentSetting.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
            $splitcs = $splitcs.Trim()

            #verifica se a nova configuração é diferente a configuração atual. Se sim, precisa mudar. Se não, não precisa mudar.
            if ($splitvalue[1] -ne $splitcs[1]) {
                #$NewSeceditPol = "Precisa mudar $($splitvalue[0]) de $($splitcs[1]) para $($splitvalue[1])"
                $NewSeceditPol = $value
                $Name = $splitvalue[0]
                $currentconfig = $splitcs[1]
                $newconfig = $splitvalue[1]
                $fix = $true
                #Write-Output "Precisa mudar"
            }
            else {
                #$NewSeceditPol = "Não precisa mudar: $value"
                $NewSeceditPol = $value
                $Name = $splitvalue[0]
                $currentconfig = $splitcs[1]
                $newconfig = $splitvalue[1]
                $fix = $false
            }
        }
        elseif ($null -eq $currentSetting -And $splitvalue[1] -eq "") {
            #Tanto a configuração nova quanto a configuração atual são $null. Então não muda nada.
            $NewSeceditPol = $value
            $Name = $splitvalue[0]
            $currentconfig = '$null'
            $newconfig = $splitvalue[1]
            $fix = $false            
        }
        else {
            #Nova configuração. A configuração atual não foi encontrada/é inexistente.
            $NewSeceditPol = $value
            $Name = $splitvalue[0]
            $currentconfig = '$null'
            $newconfig = $splitvalue[1]
            $fix = $true
        }
    }

    $result = [PSCustomObject]@{
        Edge         = $env:CloudEdgeEnv
        Hostname     = $(Hostname)
        GID          = $GID
        Description  = $Description
        Name         = $Name
        CurrentConfig = $currentconfig
        NewConfig    = $newconfig
        Fix          = $fix
        Timestamp    = (get-date).ToString('dd-MM-yyyy HH:mm:ss')
    }

    if ($Description -eq "Control") {
        $currentconfig1 = $value
    }
    else {
        $currentconfig1 = $name + "=" + $currentconfig
    }

    $backup = [PSCustomObject]@{
        GID            = $GID
        Description    = $Description
        RollbackConfig = $currentconfig1
    }

    return $NewSeceditPol, $result, $backup
    #write-output $NewSeceditPol

}

function Set-SeceditPolicy {
    $NewSeceditPol = @()
    $SecPolResult = @()
    $policybkpobject = @{}
    $a = @()
    $b = @()
    $c = @()
    
    $tmp = [System.IO.Path]::GetTempFileName()
    Write-Host "Export current Local Security Policy" -ForegroundColor DarkCyan
    secedit.exe /export /cfg "$($tmp)" | out-null
    #alterado $tmp = "G:\My Drive\Projetos\New Hardening\Windows 2k16\server\seceditpolicy.tmp"
    $runningconfig = Get-Content -Path $tmp

    if ($null -eq $runningconfig) {
        Write-Warning "Não foi possível carregar as policies via SecEdit. Abortando execução."
        Exit
    }

    $propname = $policy.seceditpolicy[0].psobject.properties | Select-Object -ExpandProperty name

    foreach ($chave in $propname) {
        #Compara os itens da policy default removendo os itens que também estiverem no diff do produto
        $defaultpolicy = $policy.seceditpolicy.$chave | Where-Object {($_.GID -notin $productpolicy.seceditpolicy.$chave.GID)}
        #Carrega os itens da policy de diff do produto
        $diffpolicy = $productpolicy.seceditpolicy.$chave
        
        #valida se o diffpolicy não é null e junta as duas policies.
        if ($null -ne $diffpolicy) {
            $allpolicy = $defaultpolicy + $diffpolicy
        }
        else {
            $allpolicy = $defaultpolicy
        }

        $recursereg = {
            $temppol = @()
            $result = @()
            $backup = @()
            $d = @()
            $e = @()
            $f = @()

            foreach ($item in @($args[0])) {
                #$temppol, $result = Get-SeceditValue -value $item.Enable -Description $item.Description -GID $item.GID -runningconfig $runningconfig
                $temppol, $result, $backup = Get-SeceditValue -value $item.$policyoption -Description $item.Description -GID $item.GID -runningconfig $runningconfig
                $d += $temppol
                $e += $result
                $f += $backup
            }
            return $d, $e, $f
        }
        $a, $b, $c = & $recursereg $allpolicy

        $NewSeceditPol += $a
        $SecPolResult += $b
        $policybkpobject.Add($chave,$c)
    }


    #Write-Output $NewSeceditPol
    #Write-Output $SecPolResult

    #$seceditdoc > "$env:UserProfile\Desktop\policy.inf"
    $NewSeceditPol > "c:\windows\temp\policy.inf"

    #$temp = Get-Content "$env:UserProfile\Desktop\policy.inf" 
    $temp = Get-Content "c:\windows\temp\policy.inf" 
    $tmp2 = [System.IO.Path]::GetTempFileName()

    #problems to reognize certains types, so we convert to unicode
    $temp | Set-Content -Path $tmp2 -Encoding Unicode -Force

    Push-Location (Split-Path $tmp2)

    secedit.exe /configure /db "secedit.sdb" /cfg "$($tmp2)"  | out-null

    #Remove-Item -Path "$env:UserProfile\Desktop\policy.inf" -Force
    Remove-Item -Path "c:\windows\temp\policy.inf" -Force

    return $SecPolResult, $policybkpobject

}

#endregion


function Disable-IPv6 {
    #Disabling IPv6
    $name = Get-NetAdapterBinding -DisplayName "Internet Protocol Version 6 (TCP/IPv6)" -ErrorAction SilentlyContinue | Select-Object -exp Name
    Disable-NetAdapterBinding -Name $name -ComponentID ms_tcpip6 -PassThru -ErrorAction SilentlyContinue
}


function Checkadmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false) {
        Write-Warning "Scritp sendo executado com usuário não-admin. Abortando execução."
        Exit
        #Write-Error "Scritp sendo executado com usuário não-admin. Abortando execução." -ErrorAction Stop
    }

}


#-------------------- START SCRIPT ----------------------------------------

#valida se o script está sendo executado como admin
Checkadmin

$checkfolder = Test-Path "C:\COMPANY\hardening\"
if ($checkfolder -eq $false ) {
    try {
        #Cria a pasta para salvar os arquivos de log e rollback
        New-Item -ItemType Directory -Force -Path "C:\COMPANY\hardening\" | Out-Null
    }
    catch {
        Write-Warning "Não foi possível criar a pasta C:\COMPANY\hardening\, utilizada para salvar logs e o arquivo de rollback. Abortando execução."
        Exit
    }
}

#Variaveis de data usadas no script
$datefile = Get-Date -UFormat "%Y-%m-%d_%H-%M"
$executiontimedate = (get-date).ToString('dd-MM-yyyy HH:mm:ss')

Switch -Exact ($apply)
{
    'hardening' {
        #Aplica a configuração do hardening + diff
        $policyoption = "HardeningConfig"
    }
    'windowsdefault' {
        #Aplica a configuração default do Windows
        $policyoption = "DefaultConfig"
    }
    'rollback' {
        #Aplica a configuração do arquivo de backup
        $policyoption = "RollbackConfig"
        #quando o rollback é aplicado, o parâmetro de product policy (diff) deve ser ignorado
        $productpolicy = $null
    }
    default {
        Write-Warning "Opção incorreta. Escolha entre hardening, windowsdefault ou rollback."
        Exit
    }
}


#valida se o arquivo .JSON do hardening ou de rollback existe
try {
    Get-Item -Path $configfile -ErrorAction Stop
    $policy = Get-Content $configfile | ConvertFrom-Json
}
catch {
    Write-Warning "Arquivo de config|rollback não encontado. Abortando execução."
    Exit
}


#valida se o arquivo de diff do produto foi passado. Se sim, valida se ele existe.
if ( "" -ne $productfile) {
    try {
        Get-Item -Path $productfile -ErrorAction Stop
        $productpolicy = Get-Content $productfile | ConvertFrom-Json
    }
    catch {
        Write-Warning "Arquivo diff não encontado. Abortando execução."
        Exit  
    }
}

if ( $apply -eq "hardening" -or $apply -eq "windowsdefault" ) {

    #Chama função para desabilitar o IPv6
    Disable-IPv6
    
    #Chama o script para remover serviços desnecessários
    . $PSScriptRoot\unwantedservices.ps1

    #Chama o script para configurar as policies de audit
    . $PSScriptRoot\auditpol.ps1
}

$backup1 = @{}

#Inclui informações importantes da máquina no arquivo JSON de backup
$backupinfo = [PSCustomObject]@{
    Edge             = $env:CloudEdgeEnv
    Hostname         = $(Hostname)
    HardeningName    = $policy.controlversion.HardeningName
    HardeningVersion = $policy.controlversion.HardeningVersion
    ExecutionTime    = $executiontimedate
    Type             = "Server"
    JSONType         = "Rollback"
}
$backup1.Add("controlversion",$backupinfo)

#Chama função para aplicar configurações via secedit
$secpolresult, $secpolicybkp = Set-SeceditPolicy
Start-Sleep -Milliseconds 10
$backup1.Add("seceditpolicy",$secpolicybkp)
Start-Sleep -Milliseconds 10

#Chama função para aplicar configurações via registro
$regresult, $regbackup = Set-RegistryPolicy
Start-Sleep -Milliseconds 10
$backup1.Add("registrypolicy",$regbackup)
Start-Sleep -Milliseconds 10

#Chama função que salva no registro da máquina informações sobre o hardening aplicado (versão, horário, etc.)
Set-HardeningRegistry $policy $productpolicy
Start-Sleep -Milliseconds 10

#Arquivos de saída (output).
# * HARDENINGBACKUP é o arquivo com as configurações atuais do servidor (antes da aplicação do hardening). Esse arquivo deve ser armazenado para realização de rollback.
$secpolresult | ConvertTo-Json | out-file "C:\COMPANY\hardening\result_secedit_$datefile.json" -force
$regresult    | ConvertTo-Json | out-file "C:\COMPANY\hardening\result_registry_$datefile.json" -force
$backup1      | ConvertTo-Json -Depth 5 | out-file "C:\COMPANY\hardening\hardeningbackup_$(Hostname)_$datefile.json" -force
New-RegistryEntry -path "HKLM:\\SOFTWARE\\WOW6432NODE\\COMPANY\\Security\\Server" -name LastRollbackFile -value "C:\COMPANY\hardening\hardeningbackup_$(Hostname)_$datefile.json" -PropertyType String | out-null

Write-Host "ARDENING APLICADO COM SUCESSO!" -ForegroundColor Yellow
#Write-Host "Hardening aplicado com sucesso." -ForegroundColor Yellow
