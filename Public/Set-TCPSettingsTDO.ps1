#region SET_TCPSETTINGSTDO ; #*------v FUNCTION Set-TCPSettingsTDO v------
Function Set-TCPSettingsTDO {
            <# .NOTES
            REVISIONS
            * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name; 
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            #>
            [CmdletBinding()]
            [Alias('Set-TCPSettings')]
            PARAM()        
            $smsg = "Configuring RPC Timeout setting"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $RegKey = "HKLM:\Software\Policies\Microsoft\Windows NT\RPC"
            $RegName = "MinimumConnectionTimeout"
            If ( -not( Get-ItemProperty -Path $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
                If ( -not (Test-Path $RegKey -ErrorAction SilentlyContinue)) {
                    New-Item -Path (Split-Path $RegKey -Parent) -Name (Split-Path $RegKey -Leaf) -ErrorAction SilentlyContinue | out-null
                }
            }
            $smsg = "Setting RPC Timeout to 120 seconds"
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
            New-ItemProperty -Path $RegKey -Name $RegName  -Value 120 -ErrorAction SilentlyContinue | out-null

            $smsg = "Configuring Keep-Alive Timeout setting"
            $RegKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
            $RegName = "KeepAliveTime"
            If ( -not( Get-ItemProperty -Path $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
                If ( -not (Test-Path $RegKey -ErrorAction SilentlyContinue)) {
                    New-Item -Path (Split-Path $RegKey -Parent) -Name (Split-Path $RegKey -Leaf) -ErrorAction SilentlyContinue | out-null
                }
            }
            $smsg = "Setting Keep-Alive Timeout to 15 minutes"
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
            New-ItemProperty -Path $RegKey -Name $RegName  -Value 900000 -ErrorAction SilentlyContinue | out-null
        }
#endregion SET_TCPSETTINGSTDO ; #*------^ END FUNCTION Set-TCPSettingsTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMtM8c7k6hG+hXYXPjEYJXzIo
# PkWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSgXf/D
# LCNUP7EQdRbw043RYXF27TANBgkqhkiG9w0BAQEFAASBgGnovmsv5vdUsSrsCrer
# ZSSNHxMO+XyafUY0VDNWCNJFuU7rSKglMNfshDZ2A3AU8Br2/pDKqhymczydsaWA
# im0f33LYNbNvWDTNi4q0OcVV2S6rHkmYKRiIe4TwDL42Y0Clu74gKk6RMI88EW7i
# rrxLcQKvELW9E0pfAAStc5pZ
# SIG # End signature block
