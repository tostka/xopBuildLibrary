#region GET_EXCHANGEORGANIZATIONTDO ; #*------v FUNCTION Get-ExchangeOrganizationTDO v------
function Get-ExchangeOrganizationTDO{
        <#
        .SYNOPSIS
        Get-ExchangeOrganizationTDO - Returns the Exchange Organization Name
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Get-ExchangeOrganizationTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 1:14 PM 9/17/2025 port to vx10 from xopBuildLibrary; add CBH, and Adv Function specs
        .DESCRIPTION
        Get-ExchangeOrganizationTDO - Returns the Exchange Organization Name
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String local ForestRoot 
        .EXAMPLE ; 
        PS> $ExOrg= Get-ExchangeOrganization
        .LINK
        https://github.com/tostka/verb-ex2010
        #>
        [CmdletBinding()]
        [alias('Get-ExchangeOrganization')]
        PARAM() ;
        $CNC= Get-ForestConfigurationNCTDO
        Try {
            $ExOrgContainer= [ADSI]"LDAP://CN=Microsoft Exchange,CN=Services,$CNC"
            $rval= ($ExOrgContainer.PSBase.Children | Where-Object { $_.objectClass -eq 'msExchOrganizationContainer' }).Name
        }
        Catch {
            Write-MyVerbose "Can't find Exchange Organization object"
            $rval= $null
        }
        return $rval
    }
#endregion GET_EXCHANGEORGANIZATIONTDO ; #*------^ END FUNCTION Get-ExchangeOrganizationTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcWLyn86cPsiyb6KHAQO65Xvm
# zRWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQsPv4i
# 19vENa8aQgwoOHHFHSLlPTANBgkqhkiG9w0BAQEFAASBgGcFfQyuzN0dtYaoGdtK
# lYbe9kbNioPvH0IFKfBxam/NRCpJcwf0G6wj2EXiyltoGafJtbMd+2PGPohH7bdH
# Ybj2J4lYw+qzBkF/uzPIKOq+9BsfG4E0hcNoY+9w7IdgaotayLyoAG2tmTYwUaCm
# UCTMhY4NpmhGI6tmfMHKvjQ4
# SIG # End signature block
