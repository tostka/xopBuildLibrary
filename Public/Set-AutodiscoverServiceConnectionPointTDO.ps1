#region SET_AUTODISCOVERSERVICECONNECTIONPOINTTDO ; #*------v FUNCTION Set-AutodiscoverServiceConnectionPointTDO v------
Function Set-AutodiscoverServiceConnectionPointTDO {
        <#
        .SYNOPSIS
        Set-AutodiscoverServiceConnectionPointTDO - Sets Autodiscover SCP (normally via Set-ClientAccessServer -AutoDiscoverServiceInternalUri https://FQDN/Autodiscover/Autodiscover.xml)
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Set-AutodiscoverServiceConnectionPointTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL
        REVISIONS
        * 4:48 PM 10/6/2025 add TDO to bracket tags
        * 9:38 AM 9/29/2025 CBH revised expls
        * 2:36 PM 9/25/2025 reflects 4.20 github vers update:  not a common admin task, skip vx10 add: park in uwes\Set-AutodiscoverServiceConnectionPointTDO_func.ps1 ; 
        add CBH, and Adv Function specs        
        .DESCRIPTION
        Set-AutodiscoverServiceConnectionPointTDO - Sets Autodiscover SCP (normally via Set-ClientAccessServer -AutoDiscoverServiceInternalUri https://FQDN/Autodiscover/Autodiscover.xml)
        
        .PARAMETER Name
        Server Name[-Name 'Server']
        .PARAMETER Wait
        Switch to wait for completion of an express Background Job[-Wait]
        .INPUTS
        None, no piped input.
        .OUTPUTS
        None
        .EXAMPLE
        AutodiscoverServiceConnectionPointTDO -Name $ENV:COMPUTERNAME -ServiceBinding "https://SUB.DOMAIN.TLD/autodiscover/autodiscover.xml" -Wait
        Typical call using new -Wait param (and -ServiceBinding, which for install-Exchange15-TTC.ps1, is call parameter spec'd as -SCP 'url')
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
        PS>         Clear-AutodiscoverServiceConnectionPointTDO $ENV:COMPUTERNAME -Wait
        PS>     }
        PS>     default {
        PS>         Set-AutodiscoverServiceConnectionPointTDO $ENV:COMPUTERNAME $State['SCP'] -Wait
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
        [alias('Set-AutodiscoverServiceConnectionPoint')]
        # call: AutodiscoverServiceConnectionPointTDO $ENV:COMPUTERNAME $State['SCP'] -Wait
        PARAM(
            [Parameter(Mandatory=$true,Position=0,HelpMessage = "Server Name[-Name 'Server']")]
                [string]$Name, 
            [Parameter(Mandatory=$true,Position=0,HelpMessage = "Server Name[-Name 'Server']")]
                [string]$ServiceBinding,
            [Parameter(Mandatory=$true,Position=1,HelpMessage = "Switch to wait for completion of an express Background Job[-Wait]")]
                [switch]$Wait            
        ) ;
        $ConfigNC = Get-ForestConfigurationNC
        if ($Wait) {
            $ScriptBlock = {
                param($ServerName, $ConfigNC, $serviceBindingValue)
                do {
                    if ($null -ne $ConfigNC) {
                        $LDAPSearch = New-Object System.DirectoryServices.DirectorySearcher
                        $LDAPSearch.SearchRoot = 'LDAP://{0}' -f $ConfigNC
                        $LDAPSearch.Filter = '(&(cn={0})(objectClass=serviceConnectionPoint)(serviceClassName=ms-Exchange-AutoDiscover-Service)(|(keywords=67661d7F-8FC4-4fa7-BFAC-E1D7794C1F68)(keywords=77378F46-2C66-4aa9-A6A6-3E7A48B19596)))' -f $ServerName

                        $Results = $LDAPSearch.FindAll()
                        if ($Results.Count -gt 0) {
                            $Results | ForEach-Object {
                                Write-Host ('Setting serviceBindingInformation on {0} to {1}' -f $_.Path, $ServiceBindingValue)
                                Try {
                                    $SCPObj = $_.GetDirectoryEntry()
                                    $null = $SCPObj.Put('serviceBindingInformation', $ServiceBindingValue)
                                    $SCPObj.SetInfo()
                                    Write-Host ('Successfully set AutodiscoverServiceConnectionPoint for {0}' -f $ServerName)
                                }
                                Catch {
                                    Write-Error ('Problem setting AutodiscoverServiceConnectionPoint for {0}: {1}' -f $ServerName, $Error[0].ExceptionMessage)
                                }
                            }
                            return $true
                        }
                        Else {
                            Write-Verbose ('AutodiscoverServiceConnectionPoint not found for {0}, waiting a bit ..' -f $ServerName)
                            Start-Sleep -Seconds 10
                        }
                    }
                } while ($true)
            }

            if (-not $Global:BackgroundJobs) {
                $Global:BackgroundJobs = @()
            }
            $Job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Name, $ConfigNC, $ServiceBinding -Name ('Set-AutodiscoverSCP-{0}' -f $Name)
            $Global:BackgroundJobs += $Job
            Write-MyVerbose ('Started background job to clear AutodiscoverServiceConnectionPoint for {0} (Job ID: {1})' -f $Name, $Job.Id)
            return $Job
        }
        else {
            $LDAPSearch= New-Object System.DirectoryServices.DirectorySearcher
            $LDAPSearch.SearchRoot= 'LDAP://{0}' -f $ConfigNC
            $LDAPSearch.Filter= '(&(cn={0})(objectClass=serviceConnectionPoint)(serviceClassName=ms-Exchange-AutoDiscover-Service)(|(keywords=67661d7F-8FC4-4fa7-BFAC-E1D7794C1F68)(keywords=77378F46-2C66-4aa9-A6A6-3E7A48B19596)))' -f $Name
            $LDAPSearch.FindAll() | ForEach-Object {
                Write-MyVerbose ('Setting serviceBindingInformation on {0} to {1}' -f $_.Path, $ServiceBinding)
                Try {
                    $SCPObj= $_.GetDirectoryEntry()
                    $null = $SCPObj.Put( 'serviceBindingInformation', $ServiceBinding)
                    $SCPObj.SetInfo()
                }
                Catch {
                    Write-MyError ('Problem setting serviceBindingInformation property on {0}: {1}' -f $_.Path, $Error[0].ExceptionMessage)
                }
            }
        }
    }
#endregion SET_AUTODISCOVERSERVICECONNECTIONPOINTTDO ; #*------^ END FUNCTION Set-AutodiscoverServiceConnectionPointTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbrBtVWfObZLoS7EK407MgNG2
# PDCgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTwhSzB
# FpNdrV0McGSaz/zX0z4nBTANBgkqhkiG9w0BAQEFAASBgB+c+ncCeEL1S06mMNY7
# 98RaJbdoPXf+l2FsuU6kDdT5dQ1U8v8ukTzfcJVFkuCEpzVHNWsdhpyDlHppgpJp
# AfGlP1gr5z75uh1fvKj/BpxLTExagLPYyVe/qJFP1SanPTq5Ie4AA6VNcfjcKx3i
# Xho9q53LRI/Or96xAt6P1RoR
# SIG # End signature block
