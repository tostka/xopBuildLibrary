#region TEST_ISENTERPRISEADMINTDO ; #*------v FUNCTION Test-IsEnterpriseAdminTDO v------
function Test-IsEnterpriseAdminTDO {
        <#
        .SYNOPSIS
        Test-IsEnterpriseAdminTDO - Tests if session is running with "$env:userdomain\Enterprise Admins" permissions
        .NOTES
        Version     : 1.0.0.0
        Author: Todd Kadrie
        Website:	http://toddomation.com
        Twitter:	http://twitter.com/tostka
        AddedCredit : John Savill, based on DOS command sample
    AddedWebsite:	https://www.itprotoday.com/cloud-computing/how-can-i-determine-which-groups-im-member-my-current-logon-session
        CreatedDate : 2013-03-25
        FileName    :
        License     :
        Copyright   :
        Github      : https://github.com/tostka/verb-Auth
        Tags        : Powershell,Permissions,Session
        REVISIONS
        * 2:29 PM 9/18/2025 ren Test-IsEnterpriseAdmin -> Test-IsEnterpriseAdminTDO, alias orig, add alias Test-EnterpriseAdmin; add region tags
        * 12:05 PM 9/17/2024 flipped $User non-mand w [ValidateNotNullOrEmpty()]
        * 2:03 PM 3/27/2020 simplified, added CBH, cited author & source
        * 7/27/2005 posted version
        .DESCRIPTION
        Test-IsEnterpriseAdminTDO - Tests if session is running with "[root domain]\Enterprise Admins" permissions
        Leverages the old whoami utility (core, previously ResKit)
        .PARAMETER  File
        File [-file c:\path-to\file.ext]
        .EXAMPLE
        if(Test-IsEnterpriseAdminTDO){"Y"} else {"No" } ;
        Echo "Y" if DomainAdmin member, and "N" if not
        .LINK
        https://www.itprotoday.com/cloud-computing/how-can-i-determine-which-groups-im-member-my-current-logon-session
        #>
        [CmdletBinding()]
        [Alias('Test-IsEnterpriseAdmin','Test-EnterpriseAdmin')]
        PARAM(
            [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="User security principal [-User `$SecPrinobj]")]
                [ValidateNotNullOrEmpty()]
                [System.Security.Principal.WindowsIdentity]$User = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        ) ;
        # using slower whoami
        #[bool](whoami /groups|where{$_ -match ".*\\Enterprise\sAdmins"})| write-output ;
        # faster using WinIdentity class
        $WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($User) ;
        [bool]($WindowsPrincipal.IsInRole('\Enterprise Admins')) | write-output ;
    }
#endregion TEST_ISENTERPRISEADMINTDO ; #*------^ END FUNCTION Test-IsEnterpriseAdminTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtLHiD9maAyUBXJs7IH9/RFXb
# TvOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQePHsU
# F/woXoLF0FyB+omcjxTy9zANBgkqhkiG9w0BAQEFAASBgC8tPhYjEOp6zcsy/YvQ
# wiMQGLlSXdj8J1OJZbVypqui28ygBEiW1fhH3sfSAQPJYq0SA38pKVPCpjS+AoMM
# ot9rNYAI1qF0wBNcH3dXwag28s3/5taOaMma5kEJeifM7TXxxuPhygYamTzUXkpi
# 384k3youwsC3nWinzjSJP08T
# SIG # End signature block
