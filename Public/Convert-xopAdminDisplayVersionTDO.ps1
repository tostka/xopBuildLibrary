#region CONVERT_XOPADMINDISPLAYVERSIONTDO ; #*------v FUNCTION Convert-xopAdminDisplayVersionTDO v------
function Convert-xopAdminDisplayVersionTDO {
            <#
            .SYNOPSIS
            Convert-xopAdminDisplayVersionTDO - Convert Exchange Server AdminDisplayVersion (as returned by EMS get-ExchangeServer) to Semantic Version (n.n.n.n)
            .NOTES
            Version     : 0.0.1
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 2025-12-02
            FileName    : Convert-xopAdminDisplayVersionTDO.ps1
            License     : MIT License
            Copyright   : (c) 2025 Todd Kadrie
            Github      : https://github.com/tostka/verb-ex2010
            Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
            AddedCredit : 
            AddedWebsite: https://www.google.com/search?client=firefox-b-1-d&q=powershell+convert+exchange+admindisplayversion+to+semantic+version
            AddedTwitter: URL
            REVISIONS
            * 12:10 PM 12/2/2025 revised to named caps;  init version

            .DESCRIPTION
            Convert-xopAdminDisplayVersionTDO - Convert Exchange Server AdminDisplayVersion 'Version [major].[minor] (Build [buildmajor].[buildminor])' (as returned by EMS get-ExchangeServer) to equiv Semantic Version (major.minor.buildmajor.build.minor)

            Simple job: 
            - the AdminDisplayVersion string: 'Version 15.1 (Build 2507.6)'
            ...represents following SemVersion components: 
                'Version [major].[minor] (Build [buildMajor].[buildMinor])'
            ... which just need to be regex parsed and lined up into equiv semversion:
                [major].[minor].[buildMajor].[buildMinor]
                == 15.1.2507.6

            .PARAMETER AdminDisplayVersion
            .INPUTS
            Accepts piped input.
            .OUTPUTS
            System.Version Semantic Version object
            .EXAMPLE
            PS> $VersionNum = Convert-xopAdminDisplayVersionTDO -AdminDisplayVersion ((get-exchangeserver Server1).AdminDisplayVersion) ; 
            PS> $VersionNum ; 

                15.1.2507.6

            PS> $VersInfo = Resolve-xopBuildSemVersToTextNameTDO -Version $VersionNum ; 
            PS> $VersInfo ; 

                ProductName      : Exchange Server 2016 CU23 (2022H1)
                ReleaseDate      : 4/20/2022
                BuildNumberShort : 15.1.2507.6
                BuildNumberLong  : 15.01.2507.006
                PatchBasis       : Exchange Server 2016 CU23
                NickName         : EX2016_CU23_2022H1
                IsInstallable    : TRUE

            Demo resolving get-exchangeserver AdminDisplayVersion to Semantic Version, and then resolving that version to Exchange Version info through vx10\Resolve-xopBuildSemVersToTextNameTDO.
            .EXAMPLE
            PS> $VersionNum = Convert-xopAdminDisplayVersionTDO -AdminDisplayVersion 'Version 15.1 (Build 2507.6)' -verbose ; 
            PS> $VersionNum ; 
            Demo resolving an AdminDisplayVersion static string value to Semantic Version string
            .LINK
            https://github.com/tostka/verb-ex2010
            #>
        [CmdletBinding()]
        [Alias('Convert-AdminDisplayVersion')]
        PARAM(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [string]$AdminDisplayVersion
        )
        PROCESS {
            # Example AdminDisplayVersion: "Version 15.1 (Build 1913.5)"
             <# # prior position caps vers
             if ($AdminDisplayVersion -match 'Version (\d+)\.(\d+)\s+\(Build (\d+)\.(\d+)\)') {
                $major = $matches[1]
                $minor = $matches[2]
                $buildMajor = $matches[3]
                $buildMinor = $matches[4]                
                $semanticVersion = "$major.$minor.$buildMajor.$buildMinor"
            #>
            # flip to named caps rgx
            [regex]$rx = "Version\s(?<major>\d+)\.(?<minor>\d+)\s\(Build\s(?<buildmajor>\d+)\.(?<buildminor>\d+)\)" ;
            if ($AdminDisplayVersion -match $rx){               
                [version]$semanticVersion = "$($matches.major).$($matches.minor).$($matches.buildmajor).$($matches.buildminor)"
                Write-Output $semanticVersion
            } else {
                $smsg = "Could not parse AdminDisplayVersion: '$AdminDisplayVersion'"
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            }
        } ;  # PROC-E
    }
#endregion CONVERT_XOPADMINDISPLAYVERSIONTDO ; #*------^ END FUNCTION Convert-xopAdminDisplayVersionTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPWkIRUB4Tv/uyg4knKEvT1T2
# GV+gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTbu4sk
# qC92SIHiGsca9od9UZZwtTANBgkqhkiG9w0BAQEFAASBgDhARHkRShkv7w+taPHY
# yRevto/EM6HZUHMxxAhbQwF2dSM3ax8IMLQv6YdBcZx6GW9iky9crhaCogk2TKN1
# y9nXI3Z29JYBRc86qsb/4Vcpkco1s23R8Q1y4ucsddEkgW2AXzRH44JmeHvHkeQf
# VpKnvYQ5HM+V1IRGJDFzu3fq
# SIG # End signature block
