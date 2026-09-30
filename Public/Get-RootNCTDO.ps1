# Get-RootNCTDO.ps1


#region GET_ROOTNCTDO ; #*------v Get-RootNCTDO v------
function Get-RootNCTDO{
        <#
        .SYNOPSIS
        Get-RootNCTDO - Returns local machine's Root Naming Context DN (DC=sub,DC=sub,DC=domain,DC=tld)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Get-RootNCTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 8:31 PM 3/26/2026 move from vnet to vad
        * 11:50 AM 10/17/2025 updated CBH, incl output DN example
        * 1:14 PM 9/17/2025 port to vnet from xopBuildLibrary; add CBH, and Adv Function specs
        .DESCRIPTION
        Get-RootNCTDO - Returns local machine's Root Naming Context DN (DC=sub,DC=sub,DC=domain,DC=tld)
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String local ForestRoot 
        .EXAMPLE ; 
        PS> $NC= Get-RootNC
        PS> $NC; 

            DC=sub,DC=sub,DC=domain,DC=tld

        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Get-RootNC')]
        PARAM() ;
        return ([ADSI]'').distinguishedName.toString()
    }
#endregion GET_ROOTNCTDO ; #*------^ END Get-RootNCTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6GtQG3qWw23s3BZ26jjSkKB/
# 0C6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ70RfV
# JJ9xpxjrW72WW7beRhIWrjANBgkqhkiG9w0BAQEFAASBgI5V7oetlZ+XxJFwjuI3
# ScTKP4gKk/tCmtkgrLDZVenfSCtXFexvTnxk7qZ+kDIMPJNL7tS9+jyFMvo2CDSl
# N/LLsGbcKM3Ti5kM81ylKbXwJhuM5zEGU3O+eqPPxIBq0qpd5YeUPNoKgnMP8MSs
# LTDUTf2bXLzCxtXqbpBJRh50
# SIG # End signature block
