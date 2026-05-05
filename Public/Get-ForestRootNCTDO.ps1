#region GET_FORESTROOTNCTDO ; #*------v FUNCTION Get-ForestRootNCTDO v------
function Get-ForestRootNCTDO{
        <#
        .SYNOPSIS
        Get-ForestRootNCTDO - Returns local machine's ForestRoot DN (DC=sub,DC=dom,DC=tld)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Get-ForestRootNCTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 10:42 AM 10/17/2025 updated CBH to indicate format of the DN returned.
        * 1:14 PM 9/17/2025 port to vnet from xopBuildLibrary; add CBH, and Adv Function specs
        .DESCRIPTION
        Get-ForestRootNCTDO - Returns local machine's ForestRoot DN (DC=sub,DC=dom,DC=tld)
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String local ForestRoot 
        .EXAMPLE ; 
        PS> $FRNC= Get-ForestRootNCTDO
        PS> $FRNC ; 

            DC=sub,DC=dom,DC=tld

        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Get-ForestRootNC')]
        PARAM() ;
        return ([ADSI]'LDAP://RootDSE').rootDomainNamingContext.toString()
    }
#endregion GET_FORESTROOTNCTDO ; #*------^ END FUNCTION Get-ForestRootNCTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCxGXJ+v3tzdi/rrC9WuAoD6A
# +7mgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTFfSY6
# h4cuIFogs4a0hlGTN/J4hTANBgkqhkiG9w0BAQEFAASBgAXgEe/oJ2/FAIhRChif
# gRbDY0ZnVmfpycVzsNao0i+5Ne7ZdNDd5DjdChpFE11c33wc4AV/zByA7In7yPyO
# ZP4mrv8z7mYGjaCKVONZSaTe4WEt5Q0iCgvkH9ycd9X53+NVgaj/oqCIQM6EgDUh
# kSowqtpk7C40mittLn1GHe0V
# SIG # End signature block
