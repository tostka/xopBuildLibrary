#region GET_FORESTFUNCTIONALLEVELTDO ; #*------v FUNCTION Get-ForestFunctionalLevelTDO v------
function Get-ForestFunctionalLevelTDO{
        <#
        .SYNOPSIS
        Get-ForestFunctionalLevelTDO - Returns the Forest Functional Level integer (6)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Get-ForestFunctionalLevelTDO.ps1
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
        Get-ForestFunctionalLevelTDO - Returns the Forest Functional Level integer (6)
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String local ForestRoot 
        .EXAMPLE ; 
        PS> $EX2019_MAJOR = '15.2' ; 
        PS> $FOREST_LEVEL2012R2 = 6 ; 
        PS> $FOREST_LEVEL2012 = 5
        PS> Write-MyOutput 'Checking Forest Functional Level'
        PS> $FFL= Get-ForestFunctionalLevel
        PS> If( $MajorVersion -eq $EX2019_MAJOR) {
        PS>     If( $FFL -lt $FOREST_LEVEL2012R2) {
        PS>         Write-MyError ('Exchange Server 2019 or later requires Forest Functionality Level 2012R2 ({0}).' -f $FFL)
        PS>         Exit $ERR_ADFORESTLEVEL
        PS>     }
        PS>     Else {
        PS>         Write-MyOutput ('Forest Functional Level is {0} ({1})' -f $FFL, (Get-FFLText $FFL))
        PS>     }
        PS> }
        PS> Else {
        PS>     If( $FFL -lt $FOREST_LEVEL2012) {
        PS>         Write-MyError ('Exchange Server 2016 or later requires Forest Functionality Level 2012 ({0}).' -f $FFL)
        PS>         Exit $ERR_ADFORESTLEVEL
        PS>     }
        PS>     Else {
        PS>         Write-MyOutput ('Forest Functional Level is OK ({0})' -f $FFL)
        PS>     }
        PS> }
        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Get-ForestFunctionalLevel')]
        PARAM() ;
        $CNC= Get-ForestConfigurationNCTDO
        Try {
            $rval= ( ([ADSI]"LDAP://cn=partitions,$CNC").get('msDS-Behavior-Version') )
        }
        Catch {
            Write-MyError "Can't read Forest schema version, operator possibly not member of Schema Admin group"
        }
        return $rval
    }
#endregion GET_FORESTFUNCTIONALLEVELTDO ; #*------^ END FUNCTION Get-ForestFunctionalLevelTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVsA0IyQhUaGqAnxVJsoA4ozV
# FxOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTGvcc6
# NRzec6xE5681MXvXi0OY4TANBgkqhkiG9w0BAQEFAASBgJ3L8rjAHn8iX9kszThP
# 1amijuBDIs710pKjt9RLoU8RQ/oEAM5Q00lvHNv/9D0TijlmZv407pbn17y1HjlI
# QVSZs/j9z0GWwgV+2DQ1l//XWJHTvgfg7zHf21ySw5cLOM5L71oi67KErgSBsNRZ
# PhNuliE6ccb11oBBe/meTboO
# SIG # End signature block
