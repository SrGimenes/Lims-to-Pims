Import-Module Osisoft.PowerShell
Import-Module dotenv

$envPath = Join-Path $PSScriptRoot ".\.env"
$envVars = Get-Content $envPath | ConvertFrom-StringData

foreach($key in $envVars){
    [Environment]::SetEnvironmentVariable($key, $envVars[$key], "Process")
}

$inPIServer = $env:inPIServer
$User = $env:User
$Pword = ConvertTo-SecureString -String "$env:Pword" -AsPlainText -Force

$Credential= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$conn = Connect-PIDataArchive - PIDataArchiveMachineName $inPIServer
$TimeStamp = Get-Date



function GetAndProcessData($url, $token){
    
    $headers = @{
        'x-access-key' = $token
        'Accept' = 'application/json'
    }

    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    $results = $response.Result
                           
    foreach ($attribute in $results) {
        $value = $attribute.DisplayValue
        $data = $attribute.Sample.TakenDateTime
        $date = Get-Date $data -Format "dd/MM/yyyy HH:mm:ss"
        $Id = $attribute.Info.Id
        $Identify = $attribute.Info.Identification
        $valor = $associations[$globalId][$specifyId] 
        $tagnamelist = @(valor)
        $tags = $tagnamelist | % {Get-Point - Connection $conn -Name $_ -AllAtributes}
        $DatePIMS = Get-PIValue - PIPoint $tags -Time $TimeStamp | % {$_.TimeStamp.tolocaltime()}
        $DatePIMSF = Get-Date $DatePIMS -Format "dd/MM/yyyy HH:mm:ss"

        if($date -gt $DatePIMSF){
            ADD-PIValue - PointName $valor -Time $date -value -Connection $conn
        }
    }
    $results | ConvertTo-Json | Set-Content -Path 'Your path here, to see a resul of json'
}

$associations = @{
    10047 = @{
        1062 = "myLIMS-P2O5-DMA"
        1061 = "myLIMS-P2O5-DMB"
    }
    10016 = @{
        1057 = "myLIMS-P2O5-DMA"
        1106 = "myLIMS-P2O5-DMB"
        1062 = "myLIMS-P2O5-PFGF"
        1061 = "myLIMS-P2O5-PFF"
        1115 = "myLIMS-P2O5-RRA"
        1116 = "myLIMS-P2O5-RRB"
    }
    10017 = @{
        1057 = "myLIMS-Fe2O3-DMA"
        1106 = "myLIMS-Fe2O3-DMB"
        1062 = "myLIMS-Fe2O3-PFGF"
        1061 = "myLIMS-Fe2O3-PFF"
        1115 = "myLIMS-Fe2O3-RRA"
        1116 = "myLIMS-Fe2O3-RRB"
    }
    10018 = @{
        1057 = "myLIMS-MgO-DMA"
        1106 = "myLIMS-MgO-DMB"
        1062 = "myLIMS-MgO-PFGF"
        1061 = "myLIMS-MgO-PFF"
        1115 = "myLIMS-MgO-RRA"
        1116 = "myLIMS-MgO-RRB"
    }
    10019 = @{
        1057 = "myLIMS-CaO-DMA"
        1106 = "myLIMS-CaO-DMB"
        1062 = "myLIMS-CaO-PFGF"
        1061 = "myLIMS-CaO-PFF"
        1115 = "myLIMS-CaO-RRA"
        1116 = "myLIMS-CaO-RRB"
    }
    10020 = @{
        1057 = "myLIMS-Al2O3-DMA"
        1106 = "myLIMS-Al2O3-DMB"
        1062 = "myLIMS-Al2O3-PFGF"
        1061 = "myLIMS-Al2O3-PFF"
        1115 = "myLIMS-Al2O3-RRA"
        1116 = "myLIMS-Al2O3-RRB"
    }
    10021 = @{
        1057 = "myLIMS-SiO-DMA"
        1106 = "myLIMS-SiO-DMB"
        1062 = "myLIMS-SiO-PFGF"
        1061 = "myLIMS-SiO-PFF"
        1115 = "myLIMS-SiO-RRA"
        1116 = "myLIMS-SiO-RRB"
    }
    10022 = @{
        1057 = "myLIMS-TiO-DMA"
        1106 = "myLIMS-TiO-DMB"
        1062 = "myLIMS-TiO-PFGF"
        1061 = "myLIMS-TiO-PFF"
        1115 = "myLIMS-TiO-RRA"
        1116 = "myLIMS-TiO-RRB"
    }
    10023 = @{
        1057 = "myLIMS-MnO-DMA"
        1106 = "myLIMS-MnO-DMB"
        1062 = "myLIMS-MnO-PFGF"
        1061 = "myLIMS-MnO-PFF"
        1115 = "myLIMS-MnO-RRA"
        1116 = "myLIMS-MnO-RRB"
    }
    10024 = @{
        1057 = "myLIMS-K2O-DMA"
        1106 = "myLIMS-K2O-DMB"
        1062 = "myLIMS-K2O-PFGF"
        1061 = "myLIMS-K2O-PFF"
        1115 = "myLIMS-K2O-RRA"
        1116 = "myLIMS-K2O-RRB"
    }
}

$apiUrl = $env:apiURL
$token = $env:token

$dtAtual = Get-Date       

$dtIni = $dtAtual.AddDays(-20).ToUniversalTime()                          
$dtIniFormated = $dtIni.ToString("yyyy-MM-ddTHH:mm:ssZ")            
$dtFin = $dtAtual.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$orderby = "orderby=Sample/TakenDateTime desc &$"
$top = "top=1"

foreach ($globalId in $associations.Keys) {
    $specifyIds = $associations[$globalId]

    foreach ($specifyId in $specifyIds.Keys) {
        $filter = "filter=(Sample/Published eq true) and (Sample/Active eq true) and (Sample/Reviewed eq false) and (Sample/SampleReason/Id eq 1) and (Sample/SampleType/Id eq $specifyId) and (Info/Id eq $globalId) and (Sample/TakenDateTime ge datetime'$dtIniFormated' and Sample/TakenDateTime le datetime'$dtFin') and (ValueFloat ne null) &$"
        $url = "$apiUrl$filter$orderby$top"
        GetAndProcessData $url $token
    }
}