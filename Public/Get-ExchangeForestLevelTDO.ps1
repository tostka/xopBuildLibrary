#region GET_EXCHANGEFORESTLEVELTDO ; #*------v FUNCTION Get-ExchangeForestLevelTDO v------
function Get-ExchangeForestLevelTDO{
        <#
        .SYNOPSIS
        Get-ExchangeForestLevelTDO - Returns the Exchange Forest Level (rangeUper property 5-digit integer)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Get-ExchangeForestLevelTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 1:14 PM 9/17/2025 port to vx10 from xopBuildLibrary; add CBH, and Adv Function specs
        Only used for Ex version upgrades, schema & domain updates; not needed routinely, parking a copy in uwes as a _func.ps1 for loading when needed.
        .DESCRIPTION
        Get-ExchangeForestLevelTDO - Returns the Exchange Forest Level (rangeUper property 5-digit integer)
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String local ForestRoot 
        .EXAMPLE ; 
        PS> $forestlvl= Get-ExchangeForestLevel
        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Get-ExchangeForestLevel')]
        PARAM() ;
        $CNC= Get-ForestConfigurationNCTDO
        return ( ([ADSI]"LDAP://CN=ms-Exch-Schema-Version-Pt,CN=Schema,$CNC").rangeUpper )
    }
#endregion GET_EXCHANGEFORESTLEVELTDO ; #*------^ END FUNCTION Get-ExchangeForestLevelTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/Yd1WZxU2rlGxUYOs8R9gEpP
# l6+gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQrVxT3
# Vdc1RSU0SRKfmVKN+rEFpTANBgkqhkiG9w0BAQEFAASBgLfFkme3mP7WyDPuEViq
# c/gA1za9OTUBsUzjSJik3vmMT8C6v6fMEyvLWnYO2WfI8Pj9pqjz92Uz6zv/o/nx
# xmicDJK3ldSDv1Z/t+IqdZFZCsq3RQc7tzTXNeVsr6/W0JVNlPMSvEe9ZWq37gAq
# PFug1IGFkruD+VoZpc0N1C/8
# SIG # End signature block
