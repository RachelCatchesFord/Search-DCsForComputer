
Param(
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')][String]$Computer,
    [switch]$Delete,
    [switch]$CMDelete
)

$DomainControllers = Get-ADDomainController -Filter *  | Where-Object{($_.Name -notlike 'DHSAZDC11') -and ($_.Name -notlike 'CDHS-ESSP-DC1') -and ($_.Name -notlike 'DHSAZDC12')}
$DomainControllers | ForEach-Object{
    Write-Output "Searching DC $($_) for Computer $($Computer)"
    $ADSearch = Get-ADComputer -Identity "$Computer" -Property * -Server $_ 
    $Results = $ADSearch | select Name, DistinguishedName, Description

    Write-Output "$DC Found $Results"

    if ($Delete -eq $true) {
        Write-Output "Removing $($Computer) from DC $($_)"
        $ADSearch | Remove-ADObject -Recursive -Verbose -Confirm:$false
    }

    if ($CMDelete -eq $true) {
        Write-Output "Removing $($Computer) from SCCM"
        Import-Module ($env:SMS_ADMIN_UI_PATH.Substring(0,$env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1') | Out-Null
        ## Get the CMSite
        # In order for this next line to work, you must login to your computer as your SafeGuard account (the same account that is running this script)
        $Site=Get-PSDrive | Where-Object{$_.Provider -like '*CMSite'}
        ## Mount the CMSite PS Drive
        Set-Location $Site':'

        #Get the resource ID of the device and remove it from SCCM.
        $CMResourceID = (Get-CMDevice -Name $Computer).ResourceID
        Write-Host ("Found $Computer in SCCM. Removing.")
        Remove-CMResource -ResourceID $CMResourceID -Force

    }
}


<#
##Aaron's Script
#Get a list of all domain controllers
$dcs=Get-ADDomainController -Filter * | Select-Object name
#Computer to search
$computername = $env:COMPUTERNAME #Read-Host 'Computer Name'

#Run a foreach cycle to Search a computer across all Domain Controllers
foreach ($dc in $dcs.Name) {
	#Try to run Get-ADComputer and write Computername - DC name, if it fails use Catch to write something else
	Try{	
		$temp = Get-ADComputer ($computername) -Server $dc | select Name, DistinguishedName, Description
		Write-host "$($temp.Name) - $($dc)"
	}Catch{
        Write-host "Does not exist on $($dc)."
        }
    Finally{
        $Time=Get-Date
        write-host "$Time"
    }
}
#>