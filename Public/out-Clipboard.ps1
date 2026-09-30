# out-Clipboard.ps1

#region OUT-CLIPBOARD ; #*------v out-Clipboard v------
Function out-Clipboard {
    <#
    .SYNOPSIS
    out-Clipboard.ps1 - cross-version emulation of the older pre-psv3 out-clipboard 'clip.exe' use (for pre psv3); or emulates the `n-appending bahavior of clip.exe, when using it for psv3+. This differentiates from the native set-clipboard, which appends no trailing `n.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : out-Clipboard.ps1
    License     : (none-asserted)
    Copyright   : (none-asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Hashtable,PSCustomObject,Conversion
    AddedCredit : https://community.idera.com/members/tobias-weltner
    AddedWebsite:	https://community.idera.com/members/tobias-weltner
    AddedTwitter:	URL
    REVISIONS
    * 1:19 PM 6/2/2025 added -ea 0 to the gcm out-clipboard test (was throwing missing error into console)
    * 10:59 AM 11/29/2021 fixed - shift to adv func broke the $input a-vari (only present w simple funcs): Added declared $content pipeline vari; added -NoLegacy switch to suppress the default 'append-`n to each line' clip.exe behavior emulation. 
    * 3:17 PM 11/8/2021 init vers, flip profile alias & clip.exe to holistic function for either
    .DESCRIPTION
    out-Clipboard.ps1 - cross-version emulation of the older pre-psv3 out-clipboard 'clip.exe' use (for pre psv3); or emulates the `n-appending bahavior of clip.exe, when using it for psv3+. This differentiates from the native set-clipboard, which appends no trailing `n.
    Set-clipboard supports pipeline support, like the older | clip.exe approach. 
    But, there are differences between set-clipboard & clip.exe: 
    - clip.exe appends `n to every item added. 
    - set-clipboard does not.
    if you have code in place using the prior clip.exe support, and want an emulation of the prior behavior, this fakes it by appending `n to the input, before set-clipboarding the value. 
    .OUTPUT
    None. places specified input onto the clipboard.
    .EXAMPLE
    "some text" | out-clipboard ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Content to be copied to clipboard [-Content `$object]")]
        [ValidateNotNullOrEmpty()]$Content,
        [Parameter(HelpMessage="Switch to suppress the default 'append `n' clip.exe-emulating behavior[-NoLegacy]")]
        [switch]$NoLegacy
    ) ;
    PROCESS {
        if($host.version.major -lt 3 -OR -not (get-command Microsoft.PowerShell.Management\set-clipboard)){
            # provide clipfunction downrev
            if(-not (get-command Microsoft.PowerShell.Management\set-clipboard -ea 0)){
                write-verbose "creating downrev alias: out-clipboard -> $tClip" ; 
                # build the alias if not pre-existing
                if($tClip = "$((Resolve-Path $env:SystemRoot\System32\clip.exe -ea STOP).path)"){
                    # have to alias: can't put an expression on right of pipeline, but can use an alias
                    # revised:use an alias that doesn't overlap the function name
                    Set-Alias -Name 'Out-ClipboardTmp' -Value $tClip -scope script ;
                } ; 
            } ;
            # input only works in simple functions, in adv funcs declare a suitable vari
            #$input | out-clipboard 
            $content | out-ClipboardTmp ;
        } else {
            # emulate clip.exe's `n-append behavior on ps3+
            if(-not $NoLegacy){
                $content = $content | foreach-object {"$($_)$([Environment]::NewLine)"} ; 
            } ; 
            # hardcode to native, not pscx module version
            $content | Microsoft.PowerShell.Management\set-clipboard ;
        } ; 
    } ; 
} ; 
#endregion OUT-CLIPBOARD ; #*------^ END out-Clipboard ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUC1EM7KIlsfwp4SEq6CSI/x8
# k1CgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRbS2T+
# SfrmNeejyP5HKb+98SY7CzANBgkqhkiG9w0BAQEFAASBgJn0mWAkmnQuijBKP9Rc
# dFTvFoO6Covm4yMw4iBh33/Z07ha5rRNeQxXSsxJuqURV8biqeBa/QxwrTxbcWbo
# Sq8K/26CHhA79lLJltZMVa0a6qXk2msS3ICjnPuz9xPAgELY5HaTu6kntWBnQdW0
# YKOtW0Wlnxg9fY7JN/0qeYiS
# SIG # End signature block
