
Param(
    [Parameter(Mandatory,ParameterSetName="Computer",ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
    [String]
    $Computer,
    [Parameter(Mandatory,ParameterSetName="CSV")]
    [ValidatePattern('\.csv$')]
    [string]
    $CSV,
    [switch]
    $ADDelete,
    [switch]
    $CMDelete
)

## Global Variables
$DomainControllers = Get-ADDomainController -Filter *  | Where-Object{($_.Name -notlike 'DHSAZDC11') -and ($_.Name -notlike 'CDHS-ESSP-DC1') -and ($_.Name -notlike 'DHSAZDC12')}
$CurrentLoc = Get-Location


Function Get-ComputerFromAD{   
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
        [String]$Computer
    )
    $DomainControllers | ForEach-Object{
        Write-Output "Searching DC $($_) for Computer $($Computer)"
        $ADSearch = Get-ADComputer -Identity "$Computer" -Property * -Server $_ 
        $Results = $ADSearch | select Name, DistinguishedName, Description
        Write-Output "$DC Found $Results"
    }
}

Function Remove-ComputerFromAD{
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
        [String]$Computer
    )
    $DomainControllers | ForEach-Object{
        $ADSearch = Get-ADComputer -Identity "$Computer" -Property * -Server $_ 
        Write-Output "Removing $($Computer) from DC $($_)"
        $ADSearch | Remove-ADObject -Recursive -Verbose -Confirm:$false
    }
}

Function Remove-ComputerFromSCCM{
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
        [String]$Computer
    )
    $CMAdminPath = $env:SMS_ADMIN_UI_PATH.Substring(0,$env:SMS_ADMIN_UI_PATH.Length - 5)
    if(Test-Path -Path $CMAdminPath){
        # Import the module for SCCM
        Import-Module ($CMAdminPath + '\ConfigurationManager.psd1') | Out-Null
        
        ## Get the CMSite
        # In order for this next line to work, you must login to your computer as your SafeGuard account (the same account that is running this script)
        $Site=Get-PSDrive | Where-Object{$_.Provider -like '*CMSite'}

        ## Mount the CMSite PS Drive
        Set-Location $Site':'

        #Get the resource ID of the device and remove it from SCCM.
        $CMResourceID = (Get-CMDevice -Name $Computer).ResourceID
        Write-Host ("Found $Computer in SCCM. Removing.")
        Remove-CMResource -ResourceID $CMResourceID -Force
    }else{
        Write-Error "CMAdmin Path Not Found. Please make sure the SCCM Admin Console is installed."
        Exit 1
    }
}

if($null -ne $Computer){
    Get-ComputerFromAD -Computer $Computer
    if ($ADDelete -eq $true){
        Remove-ComputerFromAD -Computer $Computer
    }
    if ($CMDelete -eq $true){
        Remove-ComputerFromSCCM -Computer $Computer
    }        
}else{ # if CSV 
    $ComputerCSV = Import-Csv -Path $CSV
    $ComputerCSV | Foreach-Object{
        Get-ComputerFromAD -Computer $_.ComputerName
    }
    if ($ADDelete -eq $true){
        $ComputerCSV| Foreach-Object{
            Remove-ComputerFromAD -Computer $_.ComputerName
        }
    }
    if ($CMDelete -eq $true){
        $ComputerCSV | Foreach-Object{
            Remove-ComputerFromSCCM -Computer $_.ComputerName
        }
    } 
}

Set-Location $CurrentLoc