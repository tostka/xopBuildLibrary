#region GET_CREDENTIALSTDO ; #*------v FUNCTION get-CredentialsTDO v------
function get-CredentialsTDO{
    <#
    .SYNOPSIS
    get-CredentialsTDO - Prompts for credentials and validates they function against Active Directory, returns a Credential object
    .NOTES
    Version     : 0.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20250711-0423PM
    FileName    : get-CredentialsTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,ActiveDirectory,Account,Credential
    AddedCredit : Michel de Rooij / michel@eightwone.com
    AddedWebsite: http://eightwone.com
    AddedTwitter: URL        
    REVISIONS
    * 9:02 AM 10/17/2025 pulled pw systemstring conv: test-CredentialsTDO natively accomodatese as ss; add mising wlt for return msg
    * 1:06 PM 9/17/2025 add to vnet; remove write-my*() calls (write-log has native defer support now)
    * 3:15 PM 8/8/2025 rejiggered to return a credential object, (orig updated a global vari in host script);  ren get-Credentials821 -> get-821, aliased orig name (I made sufficient changes, may as well keep a copy in verb-io)
    11:59 AM 7/18/2025 lifted copy of sub from install-Ex15, updated to support pw as plaintext or securestring, tweaked pw conv code, orig was failing
    .DESCRIPTION
    get-CredentialsTDO - Prompts for credentials and validates they function against Active Directory
                
    .INPUTS
    None, no piped input.
    .OUTPUTS
    System.Object summary of Exchange server descriptors, and service statuses.
    .EXAMPLE ; 
    PS> if($Credentials = get-CredentialsTDO){
    PS>     write-host -foregroundcolor green "Obtained Credential:$($Credentials.Username) (validated against AD)" ; 
    PS> } else {
    PS>     write-warning "INVALID CREDENTIALS SPECIFIED!" ; 
    PS> }; 
    .LINK
    https://github.org/tostka/verb-ex2010/
    #>
    [CmdletBinding()]
    [alias('get-Credentials')]
    PARAM(
        [Parameter(HelpMessage = "UserName (defaults to current desktop user)")]
            [Alias('AdminAccount','logon')]
            [string]$UserName,
        [Parameter(HelpMessage = "Account password (securestring)")]
            [Alias('AdminPassword')]
            [System.Security.SecureString]$Password
    ) ;
    If( -not( $UserName -and $Password)) {
        TRY {
		    $Script:Credentials= Get-Credential -UserName ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -Message 'Enter credentials to use'
            $UserName= $Credentials.UserName
            #$Password= ($Credentials.Password | ConvertFrom-SecureString)
            # test-CredentialsTDO() can natively handle securestring pw
            $Password= $Credentials.Password 
        }CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            $smsg += 'No or improper credentials provided'
            $smsg = "" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            throw $smsg ; 
        }
	}
    $smsg = 'Checking provided credentials'
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
    If( test-CredentialsTDO -UserName:$UserName -Password:$Password) {
        $smsg = 'Credential test-CredentialsTDO:PASS`n(returning Credential object to pipeline)'
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        [System.Management.Automation.PSCredential]$Credentials = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $UserName, $Password
        $Credentials | write-output ; 
    } Else {
        $smsg = 'Credential test-CredentialsTDO:FAIL/INVALID'
        $smsg = "" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        $false | write-output ; 
    }
}
#endregion GET_CREDENTIALSTDO ; #*------^ END FUNCTION get-CredentialsTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSmB8wuHgFuJO90pVtfh7SIzr
# LfagggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR9IKoN
# eOjs2XijhIo+3i1psl4sYzANBgkqhkiG9w0BAQEFAASBgF8XUcFBiBJacWeVM2lA
# KcJtFIJG7kHB0mybL+tWFi8iriksspMCbyiXEhZlagcyRnTfphUSM/c1RDbQDrsw
# HY4jE3tILTFLE6zpfgBkbal0DY30nFsJXsxnkinHy4k8RbH4rJzd2HkUHwpLCxRx
# CINZEwDvjGfTGEHl6RQ0FwF9
# SIG # End signature block
