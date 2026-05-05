#region TEST_ISSCHEMAADMINTDO ; #*------v FUNCTION Test-isSchemaAdminTDO v------
function Test-isSchemaAdminTDO {
        <#
        .SYNOPSIS
        Test-isSchemaAdminTDO - Tests if session is running with "[root domain]\Schema Admins" permissions
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Test-isSchemaAdminTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Microsoft
        AddedWebsite: https://gallery.technet.microsoft.com/scriptcenter/Verify-the-Local-User-1e365545
        AddedTwitter: URL
        REVISIONS
        * 1:26 PM 9/17/2025 init, ported from xopBuildLibrary to vAuth
        .DESCRIPTION
        Test-isSchemaAdminTDO - Tests if session is running with "[root domain]\Schema Admins" permissions
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> if(Test-isSchemaAdminTDO){
        PS>     write-host -foregroundcolor green "Validated isSchemaAdmin " ; 
        PS> } ; 
        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Test-isSchemaAdmin821','Test-isSchemaAdmin','Test-SchemaAdmin')]
        Param()
        $FRNC= Get-ForestRootNCTDO
        $ADRootSID= ([ADSI]"LDAP://$FRNC").ObjectSID[0]
        $SID= (New-object System.Security.Principal.SecurityIdentifier ($ADRootSID, 0)).Value.toString()
        return [Security.Principal.WindowsIdentity]::GetCurrent().Groups | Where-Object {$_.Value -eq "$SID-518"}
    }
#endregion TEST_ISSCHEMAADMINTDO ; #*------^ END FUNCTION Test-isSchemaAdminTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIwwgCO0jrwmvZVJQ1A8VGSGN
# oACgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSW/Dkc
# 3WOUEnTZ2Rgkr92qRxVyBDANBgkqhkiG9w0BAQEFAASBgHPBzlEHZsiQru/gLLSk
# 8vUOIhIgUFAdR28K1PjYr6GJwi0Kn2A9kmy4QexoCBHJrHoyPteeMe7VIVt4XuEK
# 6rvDIXU9kwvU3cnlIltOl/eJF/a3VE8YvM2tOOhRWLpm9sGbdTteeIk6OUh22jZb
# 2iAmklO9sqSAKsbQtUrNERnc
# SIG # End signature block
