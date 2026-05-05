#region DISABLE_NICPOWERMANAGEMENTTDO ; #*------v FUNCTION Disable-NICPowerManagementTDO v------
Function Disable-NICPowerManagementTDO {
            <# .NOTES
            REVISIONS
            * 9:10 AM 10/7/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
            * 4:55 PM 10/6/2025 add cmdletbinding, param & alias, append TDO to name; a
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            #>
            [CmdletBinding()]
            [Alias('Disable-NICPowerManagement')]
            PARAM()        
            # http://support.microsoft.com/kb/2740020
            $smsg = "Disabling Power Management on Network Adapters"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            # Find physical adapters that are OK and are not disabled
            if (get-command get-ciminstance -ea 0) {
                $NICs = get-ciminstance -ClassName Win32_NetworkAdapter | Where-Object { $_.AdapterTypeId -eq 0 -and $_.PhysicalAdapter -and $_.ConfigManagerErrorCode -eq 0 -and $_.ConfigManagerErrorCode -ne 22 }
            } else {
                $NICs = Get-WmiObject -ClassName Win32_NetworkAdapter | Where-Object { $_.AdapterTypeId -eq 0 -and $_.PhysicalAdapter -and $_.ConfigManagerErrorCode -eq 0 -and $_.ConfigManagerErrorCode -ne 22 }
            } ;
            
            ForEach ( $NIC in $NICs) {
                $PNPDeviceID = ($NIC.PNPDeviceID).ToUpper()
                if (get-command get-ciminstance -ea 0) {
                    $NICPowerMgt = get-ciminstance MSPower_DeviceEnable -Namespace root\wmi | Where-Object { $_.instancename -match [regex]::escape( $PNPDeviceID) }
                } else {
                    $NICPowerMgt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | Where-Object { $_.instancename -match [regex]::escape( $PNPDeviceID) }
                } ; 
                If ($NICPowerMgt.Enable) {
                    $NICPowerMgt.Enable = $false
                    $NICPowerMgt.psbase.Put() | Out-Null
                    If ($NICPowerMgt.Enable) {
                        $smsg = "Problem disabling power management on $($NIC.Name) ($PNPDeviceID)"
                        if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } else {
                        $smsg = "Disabled power management on $($NIC.Name) ($PNPDeviceID)"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                    }
                } Else {
                    $smsg = "Power management already disabled on $($NIC.Name) ($PNPDeviceID)"
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                }
            }
        }
#endregion DISABLE_NICPOWERMANAGEMENTTDO ; #*------^ END FUNCTION Disable-NICPowerManagementTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWEpjmPrT/CltYbdIOErq2EVj
# 0HOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTeqsx9
# 01bXv3ImYGKTfJwHlME/jDANBgkqhkiG9w0BAQEFAASBgJDgv4RhdcWrtVrcaw9G
# sPe1pCuYb7fZW6oY25+ejrA/rHCQONodN8ltr2bKIe5Iss9I3i6kBqClf58JfhRH
# zzIC8hDPkuncQtWfbqsTUg6xN4ShyRprgb75KVzYzRPaZFNkqjOl+stSBAw/tabZ
# QT3l0m8A47x1nGv6ZtkKN/wR
# SIG # End signature block
