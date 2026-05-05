#region WRITE_MYERROR ; #*------v FUNCTION Write-MyError v------
Function Write-MyError {
            <#
            .NOTES
            REVISION
            # 4:35 PM 8/11/2025 also fixed gv State test ;  
            # 2:17 PM 12/16/2025 Write-MyOutput Write-MyWarning  Write-MyOutput Write-MyWarning Write-MyVerbose:  made adv Func, wasn't detecting verbose -Verbose:($VerbosePreference -eq 'Continue')
                added CBH
            #>
            [CmdletBinding()]
            Param($Text)
            # version that splices together Write-MyError with wlt fall back
            if( (gv State -ea 0) -AND ($State['TranscriptFile'])){
                Write-Error $Text
                $Location= Split-Path $State['TranscriptFile'] -Parent
                If( Test-Path $Location) {
                    Write-Output "$(Get-Date -Format u): [ERROR] $Text" | Out-File $State['TranscriptFile'] -Append -ErrorAction SilentlyContinue
                }
            } else {
                $smsg = $Text ; 
                 if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        }
#endregion WRITE_MYERROR ; #*------^ END FUNCTION Write-MyError  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2cA0Nj85kwGYr2ZktW4e37sv
# rVWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ/p5Lu
# 1jIcDIHpW/jNfS2LZFeARjANBgkqhkiG9w0BAQEFAASBgD6WxoPc++6/F48TDnjC
# e8LpcYpZgc4FCKpLj1xBzjD0uPKinYgLyTC0XkGsDJxOUw86h9LLxF1tq4Wni1w2
# QqXOvuxmG6ifwf8UDMNZFB9cP9tabakfWv9FLCZKmZvxAOmi+39ZMRXu81IcS2d6
# ZiWfTv7I9oy43dNxnKjb3v7r
# SIG # End signature block
