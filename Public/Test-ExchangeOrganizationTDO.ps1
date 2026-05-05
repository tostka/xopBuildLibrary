#region TEST_EXCHANGEORGANIZATIONTDO ; #*------v FUNCTION Test-ExchangeOrganizationTDO v------
function Test-ExchangeOrganizationTDO{
        <#
        .SYNOPSIS
        Test-ExchangeOrganizationTDO - Tests specified Exchange Organization within the local Forest 
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Test-ExchangeOrganizationTDO.ps1
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
        Test-ExchangeOrganizationTDO - Tests specified Exchange Organization within the local Forest
        .PARAMETER Organization
        Exchange Organization name                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String local ForestRoot 
        .EXAMPLE 
        PS> Write-MyOutput 'Checking Exchange organization existence'
        PS> $EX2016_MINFORESTLEVEL          = 15317
        PS> $EX2016_MINDOMAINLEVEL          = 13236
        PS> $EX2019_MINFORESTLEVEL          = 17000
        PS> $EX2019_MINDOMAINLEVEL          = 13236
        PS> If( $null -ne ( Test-ExchangeOrganizationTDO $Organization)) {
        PS>     Write-MyOutput "No existing Org in Forest" ; 
        PS> } Else {
        PS>     Write-MyOutput 'Organization exist; checking Exchange Forest Schema and Domain versions'
        PS>     $forestlvl= Get-ExchangeForestLevelTDO
        PS>     $domainlvl= Get-ExchangeDomainLevelTDO
        PS>     Write-MyOutput "Exchange Forest Schema version: $forestlvl, Domain: $domainlvl)"
        PS>     $MinFFL= $EX2016_MINFORESTLEVEL
        PS>     $MinDFL= $EX2016_MINDOMAINLEVEL
        PS>     If(( $forestlvl -lt $MinFFL) -or ( $domainlvl -lt $MinDFL)) {
        PS>         Write-MyOutput "Exchange Forest Schema or Domain needs updating (Required: $MinFFL/$MinDFL)"
        PS>     } Else {
        PS>         Write-MyOutput 'Active Directory looks already updated'
        PS>     }
        PS> }
        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Test-ExchangeOrganization')]
        PARAM(
            [Parameter(HelpMessage = "Exchange Organization Name to be tested")]
                [string]$Organization
        ) ;
        $CNC= Get-ForestConfigurationNCTDO
        return( [ADSI]"LDAP://CN=$Organization,CN=Microsoft Exchange,CN=Services,$CNC")
    }
#endregion TEST_EXCHANGEORGANIZATIONTDO ; #*------^ END FUNCTION Test-ExchangeOrganizationTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUARC8W7b+LiclzNroU988s+dp
# OJqgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQhCwWw
# ukCIY5iYLV4E146VmKOwozANBgkqhkiG9w0BAQEFAASBgGnOe767Aw/+sJAcgaRD
# /ueXWI+XhedxRL4vVJy4Ys+j4VWdnRNBaVtlTGjztEHhYV2P1tcxeHEK2coXGzU0
# eKb6h5tkhiB8MO4jPbMPDh9DXaYrkK2IhsK8+uuLZvHd6XE61tSlZu6plHKbMdpc
# DzPPGOKxLFVYFJ7sh3K/E2+r
# SIG # End signature block
