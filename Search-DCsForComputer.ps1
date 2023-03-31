Function Get-ComputerFromAD{   
    <#
        .SYNOPSIS

        .DESCRIPTION
    
        .PARAMETER Computer
        String. Required. Computer name that you wish to search all of your Domain Controllers for.

        .PARAMETER LogPath
        String. Path to save log files to.
    
        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .LINK
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
        [String]$Computer,
        [Parameter(Mandatory = $false, HelpMessage = 'Path to Save Log Files')]
        [string]$LogPath = "$env:Windir\Logs\Software\ActiveDirectory"
    )

    begin{
        #-- BEGIN: Executes First. Executes once. Useful for setting up and initializing. Optional
        if($LogPath -match '\\$'){
            $LogPath = $LogPath.Substring(0,($LogPath.Length - 1))
        }
        Write-Verbose -Message "Creating log file at $LogPath."
        #-- Use Start-Transcript to create a .log file
        #-- If you use "Throw" you'll need to use "Stop-Transcript" before to stop the logging.
        #-- Major Benefit is that Start-Transcript also captures -Verbose and -Debug messages.
        Start-Transcript -Path "$LogPath\Get-ComputerFromAD.log"
        $Status = 'Starting'
        Write-Verbose -Message "Script Status: $Status"
        Write-Verbose -Message "Getting a list of Domain Controllers."
        $DomainControllers = Get-ADDomainController -Filter *  #| Where-Object{($_.Name -notlike '*DC*')}
        
    }
    process{
        #-- PROCESS: Executes second. Executes multiple times based on how many objects are sent to the function through the pipeline. Optional.
        $Status = 'In Progress'
        try{
            #-- Try the things
            $DomainControllers | ForEach-Object{
                Write-Verbose "Searching DC $($_) for Computer $($Computer)"
                $ADSearch = Get-ADComputer -Identity "$Computer" -Property * -Server $_ 
                $Results = $ADSearch | Select-Object Name, DistinguishedName, Description
                Write-Host "$($_) Found $Results" -ForegroundColor "Green"

            }
        } catch {
            #-- Catch the error
            Write-Error $_.Exception.Message
            Write-Error $_.Exception.ItemName
            $Status = 'Failed'
        }
    }
    end{
        # END: Executes Once. Executes Last. Useful for all things after process, like cleaning up after script. Optional.
        
        if($Status -ne 'Failed'){
            $Status = 'Completed'
            Write-Verbose -Message "Script Status: $Status"
            Stop-Transcript
            Return 'Fully Replicated'
        } else {
            Write-Verbose -Message "Script Status: $Status"
            Stop-Transcript
            Return 'Not Fully Replicated'
        }
    }
    
}

Function Remove-ComputerFromAD{
    <#
        .SYNOPSIS

        .DESCRIPTION
    
        .PARAMETER Computer
        String. Required. Computer name that you wish to remove from AD.

        .PARAMETER LogPath
        String. Path to save log files to.
    
        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .LINK
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
        [String]$Computer,
        [Parameter(Mandatory = $false, HelpMessage = 'Path to Save Log Files')]
        [string]$LogPath = "$env:Windir\Logs"
    )

    begin{
        #-- BEGIN: Executes First. Executes once. Useful for setting up and initializing. Optional
        if($LogPath -match '\\$'){
            $LogPath = $LogPath.Substring(0,($LogPath.Length - 1))
        }
        Write-Verbose -Message "Creating log file at $LogPath."
        #-- Use Start-Transcript to create a .log file
        #-- If you use "Throw" you'll need to use "Stop-Transcript" before to stop the logging.
        #-- Major Benefit is that Start-Transcript also captures -Verbose and -Debug messages.
        Start-Transcript -Path "$LogPath\Remove-ComputerFromAD.log"
        $Status = 'Starting'
        Write-Verbose -Message "Script Status: $Status"
        Write-Verbose -Message "Getting a list of Domain Controllers."
        $DomainControllers = Get-ADDomainController -Filter *  #| Where-Object{($_.Name -notlike '*DC*')}
    }
    process{
        #-- PROCESS: Executes second. Executes multiple times based on how many objects are sent to the function through the pipeline. Optional. 
        $Status = 'In Progress'      
        try{
            #-- Try the things
            $DomainControllers | ForEach-Object{
                Write-Verbose "Searching DC $($_) for Computer $($Computer)"
                $ADSearch = Get-ADComputer -Identity "$Computer" -Property * -Server $_ 
                Write-Warning -Message  "Removing $($Computer) from DC $($_)"
                $ADSearch | Remove-ADObject -Recursive -Verbose -Confirm:$false
            }
        } catch {
            #-- Catch the error
            Write-Error $_.Exception.Message
            Write-Error $_.Exception.ItemName
            $Status = 'Failed'
        }
    }
    end{
        # END: Executes Once. Executes Last. Useful for all things after process, like cleaning up after script. Optional.
        if($Status -ne 'Failed'){
            $Status = 'Completed'
            Write-Verbose -Message "Script Status: $Status"
            Stop-Transcript
            Return 'Removed'
        } else {
            Write-Verbose -Message "Script Status: $Status"
            Stop-Transcript
            Return 'Failed to Remove'
        }
    }
    
}

Function Remove-ComputerFromSCCM{
    <#
        .SYNOPSIS

        .DESCRIPTION
    
        .PARAMETER Computer
        String. Required. Computer name that you wish to remove from SCCM.

        .PARAMETER LogPath
        String. Path to save log files to.
    
        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .LINK
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,HelpMessage='Computer name to search for.')]
        [String]$Computer,
        [Parameter(Mandatory = $false, HelpMessage = 'Path to Save Log Files')]
        [string]$LogPath = "$env:Windir\Logs"
    )

    begin{
        #-- BEGIN: Executes First. Executes once. Useful for setting up and initializing. Optional
        if($LogPath -match '\\$'){
            $LogPath = $LogPath.Substring(0,($LogPath.Length - 1))
        }
        Write-Verbose -Message "Creating log file at $LogPath."
        #-- Use Start-Transcript to create a .log file
        #-- If you use "Throw" you'll need to use "Stop-Transcript" before to stop the logging.
        #-- Major Benefit is that Start-Transcript also captures -Verbose and -Debug messages.
        Start-Transcript -Path "$LogPath\NameofScript.log"
        $Status = 'Starting'
        Write-Verbose -Message "Script Status: $Status"
        Write-Verbose -Message "Getting SCCM Path."
        $CMAdminPath = $env:SMS_ADMIN_UI_PATH.Substring(0,$env:SMS_ADMIN_UI_PATH.Length - 5)
    }
    process{
        #-- PROCESS: Executes second. Executes multiple times based on how many objects are sent to the function through the pipeline. Optional.
        $Status = 'In Progress'
        
        try{
            #-- Try the things
            if(Test-Path -Path $CMAdminPath){
                # Import the module for SCCM
                Write-Verbose "Importing modules from $CMAdminPath."
                Import-Module ($CMAdminPath + '\ConfigurationManager.psd1') | Out-Null
                
                ## Get the CMSite
                # In order for this next line to work, you must login to your computer with the correct privs
                Write-Verbose -Message "Setting SMS Site as a PSDrive."
                $Site=Get-PSDrive | Where-Object{$_.Provider -like '*CMSite'}
                Write-Debug "Site: $Site"
        
                ## Mount the CMSite PS Drive
                Write-Verbose -Message "Setting location to $Site"
                Set-Location $Site':'
        
                #Get the resource ID of the device and remove it from SCCM.
                Write-Verbose -Message "Getting Resource ID for $Computer from SCCM"
                $CMResourceID = (Get-CMDevice -Name $Computer).ResourceID
                Write-Host ("Found $Computer in SCCM.") -ForegroundColor "Green"
                Write-Verbose -Message "Removing $CMResourceID from SCCM."
                Remove-CMResource -ResourceID $CMResourceID -Force
            }else{
                Write-Error "CMAdmin Path Not Found. Please make sure the SCCM Admin Console is installed."
                $Status = 'Failed'
            }
        } catch {
            #-- Catch the error
            Write-Error $_.Exception.Message
            Write-Error $_.Exception.ItemName
            $Status = 'Failed'
        }
    }
    end{
        # END: Executes Once. Executes Last. Useful for all things after process, like cleaning up after script. Optional.
        if($Status -ne 'Failed'){
            $Status = 'Completed'
            Write-Verbose -Message "Script Status: $Status"
            Stop-Transcript
            Return 'Removed'
        } else {
            Write-Verbose -Message "Script Status: $Status"
            Stop-Transcript
            Return 'Failed to Remove'
        }
    }
}