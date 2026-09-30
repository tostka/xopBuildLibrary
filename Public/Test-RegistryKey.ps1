
    #region TEST_REGISTRYKEY ; #*------v Test-RegistryKey v------    
    function Test-RegistryKey {
        <#
        .SYNOPSIS
        Test-RegistryKey.ps1 - Checks specified registry key for presence (gi)
        .NOTES
        Version     : 1.0.0
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        AddedCredit : Adam Bertram
        AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
        AddedTwitter:	@adambertram
        CreatedDate : 20201014-0826AM
        FileName    : Test-RegistryKey.ps1
        License     : MIT License
        Copyright   : (c) 2020 Todd Kadrie
        Github      : https://github.com/tostka/verb-XXX
        Tags        : Powershell,System,Reboot
        REVISIONS
        * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
        * 5:03 PM 1/14/2021 init, minor CBH mods
        * 7/29/19 AB's posted version
        .DESCRIPTION
        Test-RegistryKey.ps1 - Checks specified registry key for presence (gi)
        .PARAMETER  Key
        Full registkey to be tested [-Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
        .EXAMPLE
        Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' ;
        Tests one of the Pending Reboot keys
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [OutputType('bool')]
        [CmdletBinding()]
        #[Alias('get-ScheduledTaskReport')]
        PARAM(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]$Key
        ) ;
        $ErrorActionPreference = 'Stop' ;
        if (Get-Item -Path $Key -ErrorAction Ignore) {
            $true | write-output ;
        } ;
    }
    #endregion TEST_REGISTRYKEY ; #*------^ END Test-RegistryKey ^------
# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUw23qCXrkBzUyhBKTIbjc8GkX
# idGgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTYVvHp
# Y5bf8na+3+1zYP8/KmNJjzANBgkqhkiG9w0BAQEFAASBgEGRXQNF54fkylJR+wYu
# VvcVqBdkZK6MDk6mW0AsZHPNpTpwkFcYsP9Dg+ZGKv0KUlTcHjZmzglvJUvGPcFr
# I4utakVlr8iptb6q2u2cTLmWSTZ5EUiPrlcDob5Lw04Quo2ksLAJ0y5KPkA+FLH8
# BV5lngJh3YjeAcgMKH4jcU/R
# SIG # End signature block
