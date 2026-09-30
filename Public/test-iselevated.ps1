#*------v test-IsElevated.ps1 v------
function test-IsElevated {
    <#
    .SYNOPSIS
    test-IsElevated - Tests if session is running with local\Administrators membership -AND- High Integrity Level (should match, but they do reflect different components)
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : test-IsElevated.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Permissions,Session
    REVISIONS
    * 5:48 PM 5/15/2021 make whoami.exe call conditional
    * 8:06 AM 7/23/2020 updated CBH
    * 2:03 PM 3/27/2020 simplified, added CBH, cited author & source
    .DESCRIPTION
    test-IsElevated - Tests if session is running with local\Administrators membership -AND- High Integrity Level (should match, but they do reflect different components. Uses slower whoami.exe (only way to get Integrity Level)
    .EXAMPLE
    if(test-IsElevated){"Y"} else {"No" } ;
    Echo "Y" if current session is a member of local\administrators member & High Integrity, and "N" if not
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    PARAM() ;
    # using slower whoami
    #[bool](whoami /groups|where{$_ -match 'BUILTIN\\Administrators'})| write-output ;
    # faster using WinIdentity class...
    <#$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($User) ;
    [bool]($WindowsPrincipal.IsInRole('BUILTIN\Administrators')) | write-output ;
    #>
    # ...but Integrity Level isn't returned by WindowsIdentity, have to use whoami to actually eval; whoami /groups may be quicker (subset of output meas-cmd says 20.978secs v 20.518secs incremental diff )
    if(-not(get-variable -Name whoamiAll -ea 0)){$whoamiAll = (whoami /all)} ;
    [bool](($whoamiAll |?{$_ -match 'BUILTIN\\Administrators'}) -AND ($whoamiAll |?{$_ -match 'S-1-16-12288'})) | write-output ;
}

#*------^ test-IsElevated.ps1 ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQHqtR7x/xB3BuAE3/4NGA+E1
# Ze2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSNveXT
# kEWrbitQbRJ9zHxKx96oYTANBgkqhkiG9w0BAQEFAASBgJJaPtWVI+xoRs5LsES/
# JWbH7M/eXU5HJLw9YDvct1NTAKyNdKifRD6p1UL0EhICpYoYkHucJ2MtBzqOvKu0
# Ces6kR42Ws5fYjD6gt0yznX9barXT3aQBJwCXO0ZMrsO7vmBlf/ksAKqRG75Cdgk
# 1QcgdNWLb9IYAwbRkeWqZOck
# SIG # End signature block
