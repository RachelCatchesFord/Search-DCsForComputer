
Param(
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
    [String]
    $Computer
)

$DomainControllers = (Get-ADForest).Domains | ForEach-Object{Get-ADDomainController -Filter * -Server $_} | Select-Object -ExpandProperty Name
$DomainControllers | ForEach-Object{
    Write-Output "Searching DC $($_) for Computer $($Computer)"
    $ADSearch = Get-ADComputer -Identity "$Computer" -Property * -Server $_ 
    $Results = $ADSearch | select Name, DistinguishedName, Description

    Write-Output "$DC Found $Results"
   <# Props = @{
        $DC = $_
        $ADSearch.Name = $Computer

    }
    #>
}

##Aaron's Script
#Get a list of all domain controllers
$dcs=Get-ADDomainController -Filter * | Select-Object name
#Computer to search
$computername = Read-Host 'Computer Name'

#Run a foreach cycle to Search a computer across all Domain Controllers
foreach ($dc in $dcs.Name) {
	#Try to run Get-ADComputer and write Computername - DC name, if it fails use Catch to write something else
	Try {	
			$temp = Get-ADComputer ($computername) -Server $dc | select Name
			write-host "$($temp.Name) - $($dc)"
		}
	
	Catch{write-host "Does not exist on $($dc)."}
Finally
{
$Time=Get-Date
write-host "$Time"
}
}
Get-ADComputer "$computername"