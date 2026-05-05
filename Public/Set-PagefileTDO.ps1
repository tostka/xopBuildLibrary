#region SET_PAGEFILETDO ; #*------v FUNCTION Set-PagefileTDO v------
Function Set-PagefileTDO {
            <# .NOTES
            REVISIONS
            * 2:35 PM 2/17/2026 correct base alias
            * 9:10 AM 10/7/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
            * 4:55 PM 10/6/2025 add cmdletbinding, param & alias, append TDO to name; patch in non-$State support
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            #>
            [CmdletBinding()]
            [Alias('Set-Pagefile')]
            PARAM()   
            $smsg = "Checking Pagefile Configuration"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            if (get-command get-ciminstance -ea 0) {
                $Drives = get-ciminstance -Class Win32_ComputerSystem -EnableAllPrivileges ; 
            } else {
                $CS = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
            }
            If ($CS.AutomaticManagedPagefile) {
                $smsg = "System configured to use Automatic Managed Pagefile, reconfiguring"
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
                Try {
                    $CS.AutomaticManagedPagefile = $false
                    $InstalledMem = $CS.TotalPhysicalMemory
                    #If ( $State["MajorSetupVersion"] -ge $EX2019_MAJOR) {
                    # 1:01 PM 10/6/2025 patch in non-$State support
                    if($State){
                        If ( ( $State["MajorSetupVersion"] -ge $EX2019_MAJOR) -OR ($MajorSetupVersion -ge $EX2019_MAJOR)) {
                            # 25% of RAM
                            $DesiredSize = [int]($InstalledMem / 4 / 1MB)
                            $smsg = ('Configuring PageFile to 25% of Total Memory: {0}MB' -f $DesiredSize)
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                        } Else {
                            # RAM + 10 MB, with maximum of 32GB + 10MB
                            $DesiredSize = (($InstalledMem + 10MB), (32GB + 10MB) | Measure-Object -Minimum).Minimum / 1MB
                            $smsg = ('Configuring PageFile Total Memory+10MB with maximum of 32GB+10MB: {0}MB' -f $DesiredSize)
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                        }
                        $null = $CS.Put()
                        if (get-command get-ciminstance -ea 0) {
                            $CPF = get-ciminstance  -Class Win32_PageFileSetting
                        } else {
                            $CPF = Get-WmiObject -Class Win32_PageFileSetting
                        } ; 
                        $CPF.InitialSize = $DesiredSize
                        $CPF.MaximumSize = $DesiredSize
                        $null = $CPF.Put()
                    } else { 
                        $smsg = "MISSING DEPENDANT `$STATE[xxx] VARIABLE!"
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        THROW $SMSG ; 
                        BREAK ; 
                    }
                } Catch {
                    $smsg = "Problem reconfiguring pagefile: $($ERROR[0])"
                    if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                }
                if (get-command get-ciminstance -ea 0) {
                    $CPF = get-ciminstance -Class Win32_PageFileSetting
                } else {
                    $CPF = Get-WmiObject -Class Win32_PageFileSetting
                }
                $smsg = "Pagefile set to manual, initial/maximum size: $($CPF.InitialSize)MB / $($CPF.MaximumSize)MB"
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
            } Else {
                $smsg = "Manually configured page file, skipping configuration"
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
            }
        }
#endregion SET_PAGEFILETDO ; #*------^ END FUNCTION Set-PagefileTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrf9ZyIaFsc/2kpDAL43ku23o
# Pv2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT0Vg1d
# pfMCHHDy4g81Vggr4ykIpDANBgkqhkiG9w0BAQEFAASBgJ2paFng4z8WEmRZg1g+
# 86ChtWi8dfmFDuUWBjN82k6XXavWKFkIL3/vDGxR94SOCL2tf7g68lH4E8ckz6xC
# 2I3K6BoEtREAOwBlAMuw+NwSZT2f1RrCDJr5v6e02sm5VAlsfbccrOHQjc5NeaiB
# i3WkYOlbB8wM7Z3H7jzhLe/7
# SIG # End signature block
