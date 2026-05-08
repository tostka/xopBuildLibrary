#region TEST_REGISTRYVALUE ; #*------v Test-RegistryValue v------
function Test-RegistryValue {
    <#
    .SYNOPSIS
    Test-RegistryValue.ps1 - Tests registry for specified Value at Key (present/set, doesn't return value)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : Adam Bertram
    AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
    AddedTwitter:	@adambertram
    CreatedDate : 20201014-0826AM
    FileName    : Test-RegistryValue.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,System,Reboot
    REVISIONS
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
    * 5:03 PM 1/14/2021 init, minor CBH mods
    * 7/29/19 AB's posted version
    .DESCRIPTION
    Test-RegistryValue.ps1 - Tests registry for specified Value at Key (present/set, doesn't return value)
    .PARAMETER  Key
    Full registkey to be tested [-Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
    .PARAMETER  Value
    Value to be compared to
    .EXAMPLE
    Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain'
    Tests value of the specified key -eq 'JoinDomain'
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [CmdletBinding()]
    #[Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string]$Value
    ) ;
    $ErrorActionPreference = 'Stop' ;
    if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
        $true | write-output ;
    } ;
}
#endregion TEST_REGISTRYVALUE ; #*------^ END Test-RegistryValue ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnN9v3ESBi2ZSKjsJ+FpD+MZD
# pmegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS2qwOX
# EHO+XeCYah5seGm6UafD5DANBgkqhkiG9w0BAQEFAASBgIHS4IjNfNSdwMrcHWYG
# PPhPxlKbtNvb184c3jXHiROwFZqYghTJlRL+HngoT8VH6j8aDDg/SQ4wYAU/5ycC
# onYkxrB1Aq/ONM0TJdHp6w94hdkyTAxdcyauK3N0gHpudej+HNWcRgIPMUup5qF/
# NUFi2Tp3E+mLaYtCvLkZPL1O
# SIG # End signature block
