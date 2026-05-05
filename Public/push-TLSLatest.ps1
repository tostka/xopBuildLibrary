#region PUSH_TLSLATEST ; #*------v FUNCTION push-TLSLatest v------
function push-TLSLatest {
            <#
            .SYNOPSIS
            push-TLSLatest - Elevates TLS on Powershell connections to highest available local version
            .NOTES
            Version     : 0.0.
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 2025-
            FileName    : push-TLSLatest.ps1
            License     : MIT License
            Copyright   : (c) 2025 Todd Kadrie
            Github      : https://github.com/tostka/verb-Network
            Tags        : Powershell,Security,TLS,protocol,Encryption
            AddedCredit : REFERENCE
            AddedWebsite: URL
            AddedTwitter: URL
            REVISIONS        
            * 12:46 PM 9/17/2025 spliced orig expanded CBH over, brought up to date
            * 9:05 AM 6/2/2025 expanded CBH, copied over current call from psparamt
            * 4:41 PM 5/29/2025 init (replace scriptblock in psparamt)
            .DESCRIPTION
            push-TLSLatest - Elevates TLS on Powershell connections to highest available local version        
            .INPUTS
            None. Does not accepted piped input.
            .OUTPUTS
            None. 
            .EXAMPLE
            PS> push-TLSLatest ;     
            .LINK
            https://github.com/tostka/verb-Network      
            #>
            [CmdletBinding()]
            PARAM() ;
            $CurrentVersionTlsLabel = [Net.ServicePointManager]::SecurityProtocol ; # Tls, Tls11, Tls12 ('Tls' == TLS1.0)  ;
            $smsg = "PRE: `$CurrentVersionTlsLabel : $($CurrentVersionTlsLabel )" ;
            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            # psv6+ already covers, test via the SslProtocol parameter presense
            if ('SslProtocol' -notin (Get-Command Invoke-RestMethod).Parameters.Keys) {
                $currentMaxTlsValue = [Math]::Max([Net.ServicePointManager]::SecurityProtocol.value__, [Net.SecurityProtocolType]::Tls.value__) ;
                $smsg = "`$currentMaxTlsValue : $($currentMaxTlsValue )" ;
                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                $newerTlsTypeEnums = [enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -gt $currentMaxTlsValue }
                if ($newerTlsTypeEnums) {
                    $smsg = "Appending upgraded/missing TLS `$enums:`n$(($newerTlsTypeEnums -join ','|out-string).trim())" ;
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                } else {
                    $smsg = "Current TLS `$enums are up to date with max rev available on this machine" ;
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                };
                $newerTlsTypeEnums | ForEach-Object {
                    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
                } ;
            } ;
        }
#endregion PUSH_TLSLATEST ; #*------^ END FUNCTION push-TLSLatest  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCbVaHbn+GY4koFjDWI0KadKc
# Je2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTdz4gU
# oA3Mz+Npedq7V3+nxn1MczANBgkqhkiG9w0BAQEFAASBgE/YrfVbYF/F5tzJnNZZ
# JjG8W5B1VqPvQAHGWDppwD3L9pbQ7hg9+1zXvgH4HDSYEC9iMv/hcL6cSS5SUijD
# w8j/35EA8sw8AMr2sZ/3p5jBPloDv+BkUHHIkvaYq7hMW21QZEiZRbHOWJUwjxqv
# L+7HuVMwqrQ1e8zBTuNA+fTc
# SIG # End signature block
