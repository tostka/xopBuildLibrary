# Get-FileVersionTDO.ps1


#region GET_FILEVERSIONTDO ; #*------v Get-FileVersionTDO v------
Function Get-FileVersionTDO {
        <#
        .SYNOPSIS
        Get-FileVersionTDO - Returns the (get-command `$File).FileVersionInfo.ProductVersion property for versioned leaf file objects
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Get-FileVersionTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)

        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL
        REVISIONS
        * 2:35 PM 2/17/2026 add missing base alias
        * 9:31 AM 10/2/2025 add alias: 'Get-DetectedFileVersionTDO'
        * 9:13 AM 9/24/2025 moved vx10->vxio
        * 10:26 AM 9/22/2025 ren Get-DetectedFileVersionTDO -> Get-FileVersionTDO (better descriptive name for what it does, better mnemomic) ; port to vio from xopBuildLibrary; add CBH, and Adv Function specs
            added CBH; init; aliased orig name
        .DESCRIPTION
        Get-FileVersionTDO - Returns the (get-command `$File).FileVersionInfo.ProductVersion property for versioned leaf file objects
        
        Advantage of using gcm: if it's in path, raw .exe's work
        but fully path'd works as well, anywhere. 
        .PARAMETER File
        Path to leaf versioned file object to be checked[-File 'c:\pathto\ExSetup.exe']
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> $SourcePath = 'D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked'  ; 
        PS> $SetupVersion= Get-FileVersionTDO "$($SourcePath)\Setup\ServerRoles\Common\ExSetup.exe" ; 
        PS> $SetupVersionText= Get-SetupTextVersion $SetupVersion ; 
        Demo resolving cab ExSetup.exe to semantic version number
        .EXAMPLE
        PS> $ExBinSetupVersion = Get-DetectedFileVersion ExSetup.exe ; 
        PS> if($ExBinSetupVersionText = Resolve-xopBuildSemVersToTextNameTDO -FileVersion $ExBinSetupVersion | select -expand ProductName){
        PS>     write-host -object ('{0} (build {1})' -f $ExBinSetupVersionText, $ExBinSetupVersion)
        PS> }else{
        PS>     write-warning "unable to resolve -FileVersion:$($ExBinSetupVersion) to a functional version ProductName" ; 
        PS> }
        Demo Resolving discovered installed Exchange bin ExSetup.exe revision semantic version number.
        .LINK
        https://github.org/tostka/verb-io/
        #>
        [CmdletBinding()]
        [alias('Get-DetectedFileVersion','Get-DetectedFileVersionTDO','Get-FileVersion')]
        PARAM(
            [Parameter(Mandatory=$true,HelpMessage = "Path to leaf versioned file object to be checked[-File 'c:\pathto\ExSetup.exe']")]
                [string]$File
        ) ;
        $res= 0 ; 
        If( Test-Path $File) {
            $res= (Get-Command $File).FileVersionInfo.ProductVersion ; 
        } Else {
            write-verbose "failed inital test-path:$($file)`nretrying raw gcm (will auto-resolve in-path targets)"
            if($gcm= (Get-Command $File -ea 0)){
                write-verbose "resolved gcm:$($file) to:$($gcm.source)"
                $res = $gcm.FileVersionInfo.ProductVersion
            }else{
                write-verbose "failed:(Get-Command $($File))" ; 
                $res= 0
            } ; 
        } ; 
        return $res 
    } #endregion GET_FILEVERSIONTDO ; #*------^ END Get-FileVersionTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4ON3A0+x28Gi6akg0LT+uAjc
# E5ygggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSOE/QS
# y3gMlm0pB+orP6hOVoFxOjANBgkqhkiG9w0BAQEFAASBgBmLdWAvSzA1yvvF7XtI
# 2ypgqG/ykp0vN2ks2ve4100H+aMpXLCyB6IKxwXxcpInUXaJoBqUW4UipN7b+L6R
# ew4MQaf4xw0povSjhNr/OvtYphAZPOn38DY8WmIcRWMJTfRcCx3uyPfuNJhomDwA
# ZHshcEGUKnJRz8c+Zml2tFPO
# SIG # End signature block
