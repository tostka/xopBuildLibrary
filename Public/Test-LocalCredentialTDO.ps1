# Test-LocalCredentialTDO.ps1


#region TEST_LOCALCREDENTIALTDO ; #*------v Test-LocalCredentialTDO v------
 function Test-LocalCredentialTDO {
        <#
        .SYNOPSIS
        Test-LocalCredentialTDO - tests provided UserName & ComputerName combo against local machine accounts
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Test-LocalCredential.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Microsoft
        AddedWebsite: https://gallery.technet.microsoft.com/scriptcenter/Verify-the-Local-User-1e365545
        AddedTwitter: URL
        REVISIONS
        * 2:35 PM 2/17/2026 add missing base alias
        * 1:04 PM 9/17/2025 remove write-my*() calls (write-log has native defer support now)
        * 2:27 PM 8/8/2025 ren Test-LocalCredential821 -> Test-LocalCredentialTDO (alias orig name)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat)
        * 9:03 AM 7/18/2025 lifted copy of sub from install-Ex15; works
        .DESCRIPTION
        Test-LocalCredentialTDO - tests provided UserName & ComputerName combo against local machine accounts

        #From https://gallery.technet.microsoft.com/scriptcenter/Verify-the-Local-User-1e365545
        .PARAMETER UserName
        Account to be tested
        .PARAMETER ComputerName
        Computer name to test against (defaults to COMPUTERNAME environment variable)
        .PARAMETER Password
        Account Password (plaintext)
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> $tcred = get-credential ; 
        PS> if(Test-LocalCredentialTDO -UserName $tcred.UserName -Password $tcred.GetNetworkCredential().Password){
        PS>     write-host -foregroundcolor green "Validated functional credentials" ; 
        PS> } ; 
        .LINK
        https://github.org/tostka/verb-ex2010/
        #>
        [CmdletBinding()]
        [alias('Test-LocalCredential821','Test-LocalCredentials','Test-LocalCredential')]
        Param( 
            [Parameter(HelpMessage = "Account to be tested")]
                [Alias('Account','logon')]
                [string]$UserName,
            [Parameter(HelpMessage = "Computer name to test against (defaults to COMPUTERNAME environment variable)")]
                [string]$ComputerName = $env:COMPUTERNAME,
            [Parameter(HelpMessage = "Account password to be used for install (plaintext)")]
                [string]$Password
        )
        if (!($UserName) -or !($Password)) {
            $smsg = "Test-LocalCredential: Please specify both user name and password"
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } else {
            TRY {   # Wrap in a try-catch in case we try to add this type twice.
                Add-Type -AssemblyName System.DirectoryServices.AccountManagement
            } CATCH {} ; 
            $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$ComputerName)
            $DS.ValidateCredentials($UserName, $Password)
        }
    }
#endregion TEST_LOCALCREDENTIALTDO ; #*------^ END Test-LocalCredentialTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAHjSLI7s2hB+6KKSLGsIvYcB
# bPegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSL7kaW
# 7b8pWdNMAXfnQQgHkYogsjANBgkqhkiG9w0BAQEFAASBgLRWRN8PksbgJAG8SzMm
# 675LPlesjnPOSBqRN+YgXUhKCwFmmGHbTltg9NVIfNcd9j5e4ZatdZb/UpYsYfYd
# kVl/DbxTbrn19KQx+AhWwp9TFSD/AKH1GCKwv3uAUW252j3gPb/oGeQadY/AfpF1
# 8idw18wj6iNX2bNjYhP+vnOx
# SIG # End signature block
