#region DISABLE_RC4TDO ; #*------v FUNCTION Disable-RC4TDO v------
Function Disable-RC4TDO {
            <# .NOTES
            REVISIONS
            * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name;  
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            #>
            # https://support.microsoft.com/en-us/kb/2868725
            # Note: Can't use regular New-Item as registry path contains '/' (always interpreted as path splitter)
            [CmdletBinding()]
            [Alias('Disable-RC4')]
            PARAM() 
            $smsg = "Disabling RC4 protocol for services"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $RC4Keys = @('RC4 128/128', 'RC4 40/128', 'RC4 56/128')
            $RegKey = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
            $RegName = "Enabled"
            ForEach ( $RC4Key in $RC4Keys) {
                If ( -not( Get-ItemProperty -Path $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
                    If ( -not (Test-Path $RegKey -ErrorAction SilentlyContinue)) {
                        $RegHandle = (get-item 'HKLM:\').OpenSubKey( $RegKey, $true)
                        $RegHandle.CreateSubKey( $RC4Key) | out-null
                        $RegHandle.Close()
                    }
                }
                $smsg = "Setting registry $RegKey\$RegName\RC4Key to 0"
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
                New-ItemProperty -Path (Join-Path (Join-Path 'HKLM:\' $RegKey) $RC4Key) -Name $RegName  -Value 0 -Force -ErrorAction SilentlyContinue | out-null
            }
        }
#endregion DISABLE_RC4TDO ; #*------^ END FUNCTION Disable-RC4TDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnbFS1y2oh3nUqi3F/b+hxzka
# SIOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRQr5UR
# gS5byeaPYmFhu1XoQea7XTANBgkqhkiG9w0BAQEFAASBgDC6u5JTGWQQYBCTf5sK
# 7Rn2yqzlisZ+vTxX+OFjnO7vc6q3zzeJafh5SFci4ufShru8WXLdpgbywxEhF98V
# 4ogIKfBE+SHpbKcXe9vK80uTwg40cJJCcmx4HcGbnvuFEzjzj249osFxcCzBF0jt
# 1KTCYjPCMPkxSdG0HUdTnd3s
# SIG # End signature block
