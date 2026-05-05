#region WRITE_MYWARNING ; #*------v FUNCTION Write-MyWarning v------
Function Write-MyWarning {
            <#
            .NOTES
            REVISION
            # 4:35 PM 8/11/2025 also fixed gv State test ;  
            # 2:17 PM 12/16/2025 Write-MyOutput Write-MyWarning  Write-MyOutput Write-MyWarning Write-MyVerbose:  made adv Func, wasn't detecting verbose -Verbose:($VerbosePreference -eq 'Continue')
                added CBH
            #>
            [CmdletBinding()]
            Param($Text)
            # version that splices together Write-MyWarning with wlw fall back
            if( (gv State -ea 0) -AND ($State['TranscriptFile'])){
                Write-Warning $Text
                $Location= Split-Path $State['TranscriptFile'] -Parent
                If( Test-Path $Location) {
                    Write-Output "$(Get-Date -Format u): [WARNING] $Text" | Out-File $State['TranscriptFile'] -Append -ErrorAction SilentlyContinue
                }
            } else {
                $smsg = $Text ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        }
#endregion WRITE_MYWARNING ; #*------^ END FUNCTION Write-MyWarning  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2pxpmmFZaBBMPw71+Fa4v9r8
# KB+gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSO8WUr
# T0ua074Cp+aA8/HulufV1TANBgkqhkiG9w0BAQEFAASBgJfm+dbm/E/oSiz/g68X
# fXbz7oIQLGB/haY3s20watZveCkrw7I2McUhjCuaXxB1Dcj+bW1GAocdOy/NwVTg
# k5IhcAqKK/9IUabb3j5D7oNghYSi6vCf2wnN7RYTO15WRAhVbqVt/hoNgrJxsjMz
# WPvqv41kuIVRS8yNhT7Z5KEw
# SIG # End signature block
