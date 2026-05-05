#region TEST_ISELEVATED ; #*------v FUNCTION test-iselevated v------
function test-iselevated {
            PARAM() ;
            # using slower whoami
            #[bool](whoami /groups|where{$_ -match 'BUILTIN\\Administrators'})| write-output ;
            # faster using WinIdentity class...
            <#$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($User) ;
            [bool]($WindowsPrincipal.IsInRole('BUILTIN\Administrators')) | write-output ;
            #>
            # ...but Integrity Level isn't returned by WindowsIdentity, have to use whoami to actually eval; whoami /groups may be quicker (meas-cmd says 20.978secs v 20.518secs incremental diff )
            if (-not(get-variable -Name whoamiAll -ea 0)) { $whoamiAll = (whoami /all) } ;
            [bool](($whoamiAll | ? { $_ -match 'BUILTIN\\Administrators' }) -AND ($whoamiAll | ? { $_ -match 'S-1-16-12288' })) | write-output ;
        }
#endregion TEST_ISELEVATED ; #*------^ END FUNCTION test-iselevated  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3lXEKyQVoKNN2bfhImPGvDAU
# RcGgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTNPapp
# 7vsk/L+LrY9CZwqWjI5vtTANBgkqhkiG9w0BAQEFAASBgGEvNObnM0+zteUUwiRL
# YM4jeCCnZb5YzSEvPU/cQDdPBJ61XPKUvSQrwt218cqIZ6k8jbldngSeR275skyu
# zfTqh1dHeITq0akNQmq9ydapksW0zTJ9VYQ5Cd0cTxvjz1LPAb2pkGDelz8MsftR
# +puQzZHwbN+gTw5a1gJrR8+U
# SIG # End signature block
