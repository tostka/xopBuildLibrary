#region DISABLE_SSL3TDO ; #*------v FUNCTION Disable-SSL3TDO v------
Function Disable-SSL3TDO {
            <# .NOTES
            REVISIONS
            * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name;             
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            #>
            [CmdletBinding()]
            [Alias('Disable-SSL3')]
            PARAM()
            # SSL3 disabling/Poodle, https://support.microsoft.com/en-us/kb/187498
            $smsg = "Disabling SSL3 protocol for services"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $RegKey = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
            $RegName = "Enabled"
            If ( -not( Get-ItemProperty -Path $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
                If ( -not (Test-Path $RegKey -ErrorAction SilentlyContinue)) {
                    New-Item -Path (Split-Path $RegKey -Parent) -Name (Split-Path $RegKey -Leaf) -Force -ErrorAction SilentlyContinue | out-null
                }
            }
            $smsg = "Setting registry $RegKey\$RegName to 0"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            New-ItemProperty -Path $RegKey -Name $RegName  -Value 0 -ErrorAction SilentlyContinue -Force | out-null
        }
#endregion DISABLE_SSL3TDO ; #*------^ END FUNCTION Disable-SSL3TDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOnpq0TTl3gt5OQO2ywiIUo7C
# iCWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBREZOJq
# qIV7vbMbmMXVu59VXIRH2jANBgkqhkiG9w0BAQEFAASBgKyQhQqYe4EQY5CGHr2t
# mqMLHt6cNEakiNJS8aSMulJZVLiuOhktBu+hal98P0IxokXcgjm7RJzVrDHNkJWm
# 4n75j+fkymb3IY1XEC1IwJ3K7JXFGiIGyRocS6zcvNuDirgN4vn2XQljewQGRHRE
# pGvg+wn0tv8jW+Wk4DmJgzZS
# SIG # End signature block
