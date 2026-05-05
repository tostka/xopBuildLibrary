#region ENABLE_CBCTDO ; #*------v FUNCTION Enable-CBCTDO v------
Function Enable-CBCTDO {
            <# .NOTES
            REVISIONS
            * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name;
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            # https://support.microsoft.com/en-us/topic/enable-support-for-aes256-cbc-encrypted-content-in-exchange-server-august-2023-su-add63652-ee17-4428-8928-ddc45339f99e
            #>
            [CmdletBinding()]
            [Alias('Enable-CBC')]
            PARAM()             
            $smsg = "Enabling AES256-CBC mode of encryption support"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;

            $Override= Get-SettingOverride | Where-Object { ($_.SectionName -eq "EnableEncryptionAlgorithmCBC") -and ($_.Parameters -eq "Enabled=True")}
            If( $Override) {
                $smsg = ('Configuration for CBC already configured')
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
            }
            Else {
                New-SettingOverride -Name "EnableEncryptionAlgorithmCBC" -Parameters @("Enabled=True") -Component Encryption -Reason "Enable CBC encryption" -Section EnableEncryptionAlgorithmCBC
                Get-ExchangeDiagnosticInfo -Process Microsoft.Exchange.Directory.TopologyService -Component VariantConfiguration -Argument Refresh
                Restart-Service -Name W3SVC, WAS -Force
            }
        }
#endregion ENABLE_CBCTDO ; #*------^ END FUNCTION Enable-CBCTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8/RgjuRzPtB6qkSy/BVACOEb
# IhOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTQAVQS
# HxdpHdQRrEN5r3WsywWLiTANBgkqhkiG9w0BAQEFAASBgHnYWsZqzN6DnM5wZ1OO
# 1jFpxrbXQSvR5Y/9GSjCf/IYPw7MfZjf1dhLOmbTArcwy/SqzR8XEGxe5nIbB6dI
# E8ufYcfmjhVZaJunG/u1f1l2ldpsYDE+TJNDjmyE/HsJBGeqOcEymPyLD2XlXksf
# Fcsh+sCwtRqaPz84TWQTiRjB
# SIG # End signature block
