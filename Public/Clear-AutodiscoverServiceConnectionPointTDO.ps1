#region CLEAR_AUTODISCOVERSERVICECONNECTIONPOINTTDO ; #*------v FUNCTION Clear-AutodiscoverServiceConnectionPointTDO v------
Function Clear-AutodiscoverServiceConnectionPointTDO {
        <#
        .SYNOPSIS
        Clear-AutodiscoverServiceConnectionPointTDO - Clears any existing configured Autodiscover SCP (as set normally via Set-ClientAccessServer -AutoDiscoverServiceInternalUri https://FQDN/Autodiscover/Autodiscover.xml)
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Clear-AutodiscoverServiceConnectionPointTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL
        REVISIONS
        * 2:36 PM 9/25/2025 reflects 4.20 github vers update:  not a common admin task, skip vx10 add: park in uwes\Set-AutodiscoverServiceConnectionPointTDO_func.ps1 ; 
        add CBH, and Adv Function specs    
        .DESCRIPTION
        Clear-AutodiscoverServiceConnectionPointTDO - Clears any existing configured Autodiscover SCP (as set normally via Set-ClientAccessServer -AutoDiscoverServiceInternalUri https://FQDN/Autodiscover/Autodiscover.xml)
        
        .PARAMETER Name
        Server Name[-Name 'Server']
        .PARAMETER Wait
        Switch to wait for completion of an express Background Job[-Wait]
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> Clear-AutodiscoverServiceConnectionPoint -Name $ENV:COMPUTERNAME -Wait
        Demo pulling setup CAB version
        .EXAMPLE
        PS> write-verbose "pre-configure backgroundjobs and auto-cleanup via separate xopBuildLibrary\Stop-BackgroundJobs() on exit trap" ; 
        PS> $BackgroundJobs= @() ; 
        PS> Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
        PS>     Stop-BackgroundJobs 
        PS> } | Out-Null ; 
        PS> TRAP {
        PS>     Write-MyWarning 'Script termination detected, cleaning up background jobs...'
        PS>     Stop-BackgroundJobs
        PS>     break
        PS> } ; 
        PS> write-verbose "run clear, or set on -SCP driver flag" ; 
        PS> switch( $State["SCP"]) {
        PS>     '' {
        PS>             # Do nothing
        PS>     }
        PS>     '-' {
        PS>         Clear-AutodiscoverServiceConnectionPoint $ENV:COMPUTERNAME -Wait
        PS>     }
        PS>     default {
        PS>         Set-AutodiscoverServiceConnectionPoint $ENV:COMPUTERNAME $State['SCP'] -Wait
        PS>     }
        PS> } ; 
        PS> write-verbose "Install-Exchange15_ here" ; 
        PS> write-verbose "Then Cleanup any background jobs" ; 
        PS> Stop-BackgroundJobs ; 
        Demo preconfiguring backgroundjobs cleanup, run SCP config pass, run install pass, and then post-cleanup backgroundjobs
        .LINK
        https://github.org/tostka/powershellBB/
        #>
        [CmdletBinding()]
        [alias('Clear-AutodiscoverServiceConnectionPoint')]
        PARAM(
            [Parameter(Mandatory=$true,Position=0,HelpMessage = "Server Name[-Name 'Server']")]
                [string]$Name, 
            [Parameter(Mandatory=$true,Position=1,HelpMessage = "Switch to wait for completion of an express Background Job[-Wait]")]
                [switch]$Wait            
        ) ;
        $ConfigNC = Get-ForestConfigurationNC
        if ($Wait) {
            $ScriptBlock = {
                param($ServerName, $ConfigNC)
                do {
                    if ($null -ne $ConfigNC) {
                        $LDAPSearch = New-Object System.DirectoryServices.DirectorySearcher
                        $LDAPSearch.SearchRoot = 'LDAP://{0}' -f $ConfigNC
                        $LDAPSearch.Filter = '(&(cn={0})(objectClass=serviceConnectionPoint)(serviceClassName=ms-Exchange-AutoDiscover-Service)(|(keywords=67661d7F-8FC4-4fa7-BFAC-E1D7794C1F68)(keywords=77378F46-2C66-4aa9-A6A6-3E7A48B19596)))' -f $ServerName

                        $Results = $LDAPSearch.FindAll()
                        if ($Results.Count -gt 0) {
                            $Results | ForEach-Object {
                                Write-Host ('Removing object {0}' -f $_.Path)
                                Try {
                                   ([ADSI]($_.Path)).DeleteTree()
                                   Write-Host ('Successfully cleared AutodiscoverServiceConnectionPoint for {0}' -f $ServerName)
                                }
                                Catch {
                                    Write-Error ('Problem clearing AutodiscoverServiceConnectionPoint for {0}: {1}' -f $ServerName, $Error[0].ExceptionMessage)
                                }
                            }
                            return $true
                        }
                        Else {
                            Write-Host ('AutodiscoverServiceConnectionPoint not found for {0}, waiting a bit ..' -f $ServerName)
                            Start-Sleep -Seconds 10
                        }
                    }
                } while ($true)
            }

            if (-not $Global:BackgroundJobs) {
                $Global:BackgroundJobs = @()
            }
            $Job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Name, $ConfigNC -Name ('Clear-AutodiscoverSCP-{0}' -f $Name)
            $Global:BackgroundJobs += $Job
            Write-MyVerbose ('Started background job to clear AutodiscoverServiceConnectionPoint for {0} (Job ID: {1})' -f $Name, $Job.Id)
            return $Job
        }
        else {
            $LDAPSearch= New-Object System.DirectoryServices.DirectorySearcher
            $LDAPSearch.SearchRoot= 'LDAP://{0}' -f $ConfigNC
            $LDAPSearch.Filter= '(&(cn={0})(objectClass=serviceConnectionPoint)(serviceClassName=ms-Exchange-AutoDiscover-Service)(|(keywords=67661d7F-8FC4-4fa7-BFAC-E1D7794C1F68)(keywords=77378F46-2C66-4aa9-A6A6-3E7A48B19596)))' -f $Name
            $LDAPSearch.FindAll() | ForEach-Object {

                Write-MyVerbose ('Removing object {0}' -f $_.Path)
                Try {
                    ([ADSI]($_.Path)).DeleteTree()
                }
                Catch {
                    Write-MyError ('Problem clearing serviceBindingInformation property on {0}: {1}' -f $_.Path, $Error[0].ExceptionMessage)
                }
            }
        }
    }
#endregion CLEAR_AUTODISCOVERSERVICECONNECTIONPOINTTDO ; #*------^ END FUNCTION Clear-AutodiscoverServiceConnectionPointTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUW5Oy21xxG8f9EQL+rGsqRD6k
# zJCgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTkwWQM
# lGsARGVFFykY07IISRQNLTANBgkqhkiG9w0BAQEFAASBgAIOZFvFNggatYJkM0wm
# +q4aPekDRvck7UniQ1peTmQFzl7NeOLSuoiPzIJuAyuCl9T6dS7n50UTc6z2I04v
# asWHbl+3L/1B3zbVzAgPz/6YbAjWkiXPn7dWCNaSzHDNXhM0cALRXJeo3Ip4EPe6
# voJGq99yS/Xo9f93MQNqvYsq
# SIG # End signature block
