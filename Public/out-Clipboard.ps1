#region OUT_CLIPBOARD ; #*------v FUNCTION out-Clipboard v------
Function out-Clipboard {
            [CmdletBinding()]
            Param (
                [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Content to be copied to clipboard [-Content `$object]")]
                [ValidateNotNullOrEmpty()]$Content,
                [Parameter(HelpMessage="Switch to suppress the default 'append `n' clip.exe-emulating behavior[-NoLegacy]")]
                [switch]$NoLegacy
            ) ;
            PROCESS {
                if($host.version.major -lt 3){
                    # provide clipfunction downrev
                    if(-not (get-command out-clipboard)){
                        # build the alias if not pre-existing
                        $tClip = "$((Resolve-Path $env:SystemRoot\System32\clip.exe).path)" ;
                        #$input | "($tClip)" ;
                        #$content | ($tClip) ;
                        Set-Alias -Name 'Out-Clipboard' -Value $tClip -scope script ;
                    } ;
                    $content | out-clipboard ;
                } else {
                    # emulate clip.exe's `n-append behavior on ps3+
                    if(-not $NoLegacy){
                        $content = $content | foreach-object {"$($_)$([Environment]::NewLine)"} ;
                    } ;
                    $content | set-clipboard ;
                } ;
            } ;
        }
#endregion OUT_CLIPBOARD ; #*------^ END FUNCTION out-Clipboard  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVB/1x6G1SPEj+jHNLLvbW+RP
# YXOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQXpR9H
# cqcEbRPJaPONCz+hk6mpBTANBgkqhkiG9w0BAQEFAASBgDKgvRV4oPNKIInLu08T
# Kc0cDTbCJ/sbumt0LgyJAxa7Nzou5dRCyF6NNypMoc9FBlyPi8VGqFouW/qgDGRI
# WK4jxNkcBP9MKxEDmd3NYN3qO1V9/8muyEjrmOlz0he9LzJfZ1mEv445SGp8uXuM
# 0DB5Vj8dcr3gr2ARGL8PXQsn
# SIG # End signature block
