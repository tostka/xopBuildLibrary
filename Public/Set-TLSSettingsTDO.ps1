#region SET_TLSSETTINGSTDO ; #*------v FUNCTION Set-TLSSettingsTDO v------
Function Set-TLSSettingsTDO {
            <# 
            .NOTES
            REVISIONS
            * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name; 
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            .EXAMPLE
            PS> Set-TLSSettingsTDO -TLS12 $State["EnableTLS12"] -TLS13 $State["EnableTLS13"]

            #>
            [CmdletBinding()]
            [Alias('Set-TLSSettings')]
            param(
                [switch]$TLS12,
                [switch]$TLS13
            )

            If ( $TLS12) {

                # configure the .NET Framework 4.x Schannel inheritance
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value 1 -Type DWord

                # Enable TLS 1.2 for client and server connections
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.2" -ErrorAction SilentlyContinue
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Client" -ErrorAction SilentlyContinue
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Server" -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "DisabledByDefault" -Value 0 -Type DWord
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "DisabledByDefault" -Value 0 -Type DWord
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value 1 -Type DWord
            } Else {

                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.2" -ErrorAction SilentlyContinue
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Client" -ErrorAction SilentlyContinue
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Server" -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "DisabledByDefault" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -Value 0 -Type DWord
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "DisabledByDefault" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value 0 -Type DWord
            }

            If ( [System.Version]$FullOSVersion -ge [System.Version]$WS2022_PREFULL -and [System.Version]$SetupVersion -ge [System.Version]$EX2019SETUPEXE_CU15) {
                If ( $TLS13) {

                    # configure the .NET Framework 4.x Schannel inheritance
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value 1 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value 1 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value 1 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value 1 -Type DWord

                    # Enable TLS 1.3 for client and server connections
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.3" -ErrorAction SilentlyContinue
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3" -Name "Client" -ErrorAction SilentlyContinue
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3" -Name "Server" -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "DisabledByDefault" -Value 0 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "Enabled" -Value 1 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -Name "DisabledByDefault" -Value 0 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -Name "Enabled" -Value 1 -Type DWord

                    # Configure the TLS 1.3 cipher suites
                    Enable-TlsCipherSuite -Name TLS_AES_256_GCM_SHA384 -Position 0
                    Enable-TlsCipherSuite -Name TLS_AES_128_GCM_SHA256 -Position 1
                } Else {

                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.3" -ErrorAction SilentlyContinue
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3" -Name "Client" -ErrorAction SilentlyContinue
                    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3" -Name "Server" -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "DisabledByDefault" -Value 1 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "Enabled" -Value 0 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -Name "DisabledByDefault" -Value 1 -Type DWord
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -Name "Enabled" -Value 0 -Type DWord

                    Disable-TlsCipherSuite -Name TLS_AES_256_GCM_SHA384 -ErrorAction SilentlyContinue
                    Disable-TlsCipherSuite -Name TLS_AES_128_GCM_SHA256 -ErrorAction SilentlyContinue
                }
            } Else {
                $smsg = "TLS13 configuration not supported for this OS or Exchange version"
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            }

        }
#endregion SET_TLSSETTINGSTDO ; #*------^ END FUNCTION Set-TLSSettingsTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH89X8CtbHUZmsJAz7mEeTrh4
# tE+gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSwlVl5
# /b5+vaz1f24XTcWfedMcOjANBgkqhkiG9w0BAQEFAASBgKbl+a9VVG3yJDfwD1V4
# Adz+pAVLYc23+eEtMwcerTygB1mwUqgwUpCw1QD6eAeykj3i+J8c1aId+Gf8lVDL
# eB3AyW+4p4hNsB1ouE508HGVxM9c72VVFqMlfSGAyDh1MQmjtiQ/GZmWa7gEakZI
# TsF7F4ZJEIazFhQgjxnRVq9s
# SIG # End signature block
