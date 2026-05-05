#region TEST_DOMAINNATIVEMODETDO ; #*------v FUNCTION Test-DomainNativeModeTDO v------
function Test-DomainNativeModeTDO{
        <#
        .SYNOPSIS
        Test-DomainNativeModeTDO - Returns the Domain Native Mode (integer '0' of the Naming Context nTMixedDomain property)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Test-DomainNativeModeTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 1:14 PM 9/17/2025 port to vnet from xopBuildLibrary; add CBH, and Adv Function specs
        Only used for Ex version upgrades, schema & domain updates; not needed routinely, parking a copy in uwes as a _func.ps1 for loading when needed.
        .DESCRIPTION
        Test-DomainNativeModeTDO - Returns the Domain Native Mode (integer '0' of the Naming Context nTMixedDomain property)
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String local ForestRoot 
        .EXAMPLE ; 
        PS> $DOMAIN_MIXEDMODE = 0 ; 
        PS> If( Test-DomainNativeModeTDO -eq $DOMAIN_MIXEDMODE) {
        PS>     write-warning 'Domain is in mixed mode, native mode is required'
        PS> }Else {write-host -foregroundcolor green 'Domain is in native mode'}
        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Test-DomainNativeMode')]
        PARAM() ;
        $CNC= Get-ForestConfigurationNCTDO
        $NC= Get-RootNC
        return( ([ADSI]"LDAP://$NC").ntMixedDomain )
    }
#endregion TEST_DOMAINNATIVEMODETDO ; #*------^ END FUNCTION Test-DomainNativeModeTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUo3pzrodApb9m2gDKv3ZHtpHA
# voSgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQTKV16
# w9J34DzJLaFs/NQ32inz5jANBgkqhkiG9w0BAQEFAASBgGg4+vjQAjxxqgpYBW8D
# kNmwVZ5GUo3nqB75WNxrggqh0gsx5dA4IGk9nyVO9X5LbRMy/gcinqXdAkGoukyn
# F5s0Zp6XHiYZOuRmPLZckKFWKQm9BUX7PaagQsYo8WV97RwMy9QxcPKALfI/Rgd0
# uFiGuXcgzUCJ29Whd7XDF2DY
# SIG # End signature block
