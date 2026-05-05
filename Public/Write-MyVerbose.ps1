#region WRITE_MYVERBOSE ; #*------v FUNCTION Write-MyVerbose v------
Function Write-MyVerbose {
            <#
            .NOTES
            REVISION
            # 4:35 PM 8/11/2025 also fixed gv State test ;  
            # 2:17 PM 12/16/2025 Write-MyOutput Write-MyWarning  Write-MyOutput Write-MyWarning Write-MyVerbose:  made adv Func, wasn't detecting verbose -Verbose:($VerbosePreference -eq 'Continue')
                added CBH
            #>
            [CmdletBinding()]
            Param($Text)
            # version that splices together Write-MyVerbose with wlt fall back
            if( (gv State -ea 0) -AND ($State['TranscriptFile'])){
                Write-Verbose $Text
                $Location= Split-Path $State['TranscriptFile'] -Parent
                If( Test-Path $Location) {
                    Write-Output "$(Get-Date -Format u): [VERBOSE] $Text" | Out-File $State['TranscriptFile'] -Append -ErrorAction SilentlyContinue
                }
            } else {
                $smsg = $Text ; 
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
        }
#endregion WRITE_MYVERBOSE ; #*------^ END FUNCTION Write-MyVerbose  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEHDHaa7M6YJ6zcpGWxgFVRWJ
# 1qagggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTvzUIY
# 25Rzx3ODkq0OWizml5HmizANBgkqhkiG9w0BAQEFAASBgHyQYwKj598o3xCej20q
# Lh3iBOxi3kn6qoCMbs29bwyBA/5/apN9j/ps6g0ToiCGVarJ2dzR9OYDUMRaHqJr
# Vl88ZbcTmlZhg1YQtlAeLb/LfoZ3yqy5vEnEcZ+EmZDXcZ1EPFxHsaU7a8B7abib
# 3sGWseIUtq0uIXYUTUEnzqi5
# SIG # End signature block
