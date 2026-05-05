#region GET_FULLDOMAINACCOUNTTDO ; #*------v FUNCTION get-FullDomainAccountTDO v------
Function get-FullDomainAccountTDO {
    <#
    .SYNOPSIS
    get-FullDomainAccountTDO - Validates an account logon specification string is either a UserPrincipalName (acct@DOMAIN.TLD) or legacy format (DOMAIN\Account) specification. If no domain is specified (just an accountname), it substitutes the local UserDomain environment variable as the Domain specification. The resolved UPN or Legacy spec is passed through (UPN -> UPN; legacy -> legacy)
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20250711-0423PM
    FileName    : get-FullDomainAccountTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-ex2010
    Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
    AddedCredit : Michel de Rooij / michel@eightwone.com
    AddedWebsite: http://eightwone.com
    AddedTwitter: URL
    REVISIONS
    * 4:33 PM 10/16/2025 reworked logic to make self-contained, no-dep, updated cbh demo; replaced all of MdR's original logic
    * 1:14 PM 9/17/2025 port to vnet from xopBuildLibrary; add CBH, and Adv Function specs
    * 1:58 PM 8/8/2025 added CBH; init; renamed AdminAccount -> Account, aliased  orig param and logon variant. ren: get-FullDomainAccountTDO -> get-FullDomainAccountTDO, aliased orig name
    .DESCRIPTION
    get-FullDomainAccountTDO - Validates an account logon specification string is either a UserPrincipalName (acct@DOMAIN.TLD) or legacy format (DOMAIN\Account) specification. If no domain is specified (just an accountname), it substitutes the local UserDomain environment variable as the Domain specification. The resolved UPN or Legacy spec is passed through (UPN -> UPN; legacy -> legacy)
        
    .INPUTS
    None, no piped input.
    .OUTPUTS
    System.Object summary of Exchange server descriptors, and service statuses.
    .EXAMPLE
    PS> $tcred = get-credential ; 
    PS> $rvLogon = get-FullDomainAccountTDO -Account $tcred.username
    .LINK
    https://github.org/tostka/verb-io/
    #>
    [CmdletBinding()]
    [alias('get-FullDomainAccount')]
    PARAM(
        [Parameter(Mandatory=$true,HelpMessage = "Account specification")]
            [Alias('AdminAccount','logon','credential')]
            [string]$Account
    ) ;
        $PlainTextAccount= $Account;        
    switch -regex ($PlainTextAccount){
        '(.*)\\(.*)' {
            $Parts = $PlainTextAccount.split('\') ; 
            $FullPlainTextAccount = "$($Parts[0].ToUpper())\$($Parts[1])" ; write-host  "Account is in Legacy format" ; 
            return $FullPlainTextAccount ;
            break ; 
        } ; 
        '(.*)@(.*)' {
            write-host  "Account is in UPN format"  ; 
            $FullPlainTextAccount = $PlainTextAccount ;              
            return $FullPlainTextAccount ;
            #break ;
        }
        default{
            if($env:USERDOMAIN){
                $FullPlainTextAccount = "$($env:USERDOMAIN)\$($PlainTextAccount)" ; 
                write-host  "simple string: Assuming Logon, asserting `$env:USERDOMAIN for domain in legacy format" ; 
                return $FullPlainTextAccount ; 
                break ;
            } else{
                throw "Unrecognized -Account format:$($PlainTextAccount)" ; 
            };
            break ;  
        } ; 
    } ; 
}
#endregion GET_FULLDOMAINACCOUNTTDO ; #*------^ END FUNCTION get-FullDomainAccountTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAw5oDuskWKzvbMs+tBnWmXZ5
# 9T6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTpcVDp
# 0fJ7DROM+14Q6duNXNtqUDANBgkqhkiG9w0BAQEFAASBgBMC/usp2vfaqyUaDJn0
# 5y/qQfdCaK+gV4Psrlc5h3N+LvNl5fBet9Jia1q5ECW2mTCmeEiJdmKUP878douo
# pzBY9EWZHePvIGPkdUWSMEhJbaC6ATLJmNgxaDixUlOnHKDP11ucpyPqSl8JHrun
# C3NeA5Hl0pJi3sYrXeZOiIYr
# SIG # End signature block
