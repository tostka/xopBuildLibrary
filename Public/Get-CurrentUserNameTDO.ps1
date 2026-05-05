#region GET_CURRENTUSERNAMETDO ; #*------v FUNCTION Get-CurrentUserNameTDO v------
function Get-CurrentUserNameTDO{
    <#
        .SYNOPSIS
        Get-CurrentUserNameTDO - Returns local machine's windows security principal 'DOMAIN\logon' string
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Get-CurrentUserNameTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Account,Credential
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 9:19 AM 10/17/2025 hadn't actually copied in the raw code, now fully populated, and covers fallback to env varis, and supports non-domain-connected boxese
        * 1:14 PM 9/17/2025 port to vnet from xopBuildLibrary; add CBH, and Adv Function specs
        .DESCRIPTION
        Get-CurrentUserNameTDO - Returns local machine's windows security principal 'DOMAIN\logon' string
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.String windows security principal in 'DOMAIN\logon' format
        .EXAMPLE ; 
        PS> if($Username = Get-CurrentUserNameTDO){
        PS>     write-host -foregroundcolor green "UserName:$($UserName)" ; 
        PS> } else {
        PS>     write-warning "Unable to get local windows security principal name" ; 
        PS> }; 
        .LINK
        https://github.org/tostka/verb-Network/
        #>
    [CmdletBinding()]
    [alias('Get-CurrentUserName')]
    PARAM(
        [Parameter(HelpMessage = "UserName (defaults to current desktop user)")]
            [Alias('AdminAccount','logon')]
            [string]$UserName,
        [Parameter(HelpMessage = "Account password (securestring)")]
            [Alias('AdminPassword')]
            [System.Security.SecureString]$Password
    ) ;
    if([System.Security.Principal.WindowsIdentity]::GetCurrent().Name){
        return [System.Security.Principal.WindowsIdentity]::GetCurrent().Name 
    }else{
        $smsg = "Unpopulated[System.Security.Principal.WindowsIdentity]:`nfallback to `$env:USERDOMAIN & USERNAME checks" ; 
        if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        if($env:USERDOMAIN -eq $env:COMPUTERNAME){
            if($env:USERNAME){
                $smsg = "Non-Domain-connected system, returning non-Domain local `$env:USERNAME string" ; 
                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                return $env:USERNAME ; 
            }else{
                $smsg = "Unpopulated `$env:USERNAME!" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                throw $smsg ; 
            } 
        }else{
            $smsg = "Returning ``$env:USERDOMAIN\$env:USERNAME string: $($env:USERDOMAIN)\$($env:USERNAME)" ; 
            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            return "$($env:USERDOMAIN)\$($env:USERNAME)" ; 
        }

    } ; 
}
#endregion GET_CURRENTUSERNAMETDO ; #*------^ END FUNCTION Get-CurrentUserNameTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcNa5uYLBno+of7px7VhmLgXR
# BwWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRSy8MN
# /H2Cjql+scv7nSyq1B9f2TANBgkqhkiG9w0BAQEFAASBgJJFuGTiGnhDNy7+zPWn
# Zq35+7SANrQAsCEWC3I9NCXXF40euDnkRWH7b8xY++FL7KcRECGemnOlQt/yZ99P
# 7dTNKibll4MozEAusfyfGD+WKRaXxwadbsy3hhtoW25AiRjxtQC799yyXynve9Pp
# Oc4pJ27w+XqaTJ8w8ne0Ls6C
# SIG # End signature block
