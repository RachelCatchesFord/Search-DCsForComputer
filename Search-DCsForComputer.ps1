
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