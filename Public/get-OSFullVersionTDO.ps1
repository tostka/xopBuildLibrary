# get-OSFullVersionTDO.ps1


#region GET_OSFULLVERSIONTDO ; #*------v get-OSFullVersionTDO v------
Function get-OSFullVersionTDO {
        <#
        .SYNOPSIS
        get-OSFullVersionTDO - local OS Semantic Version number n.n.n.n, via get-cimInstance/get-WMIObject
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250929-1026AM
        FileName    : get-OSFullVersionTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-desktop
        Tags        : Powershell,Storage,Drive,Drivespace
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 12:12 PM 10/6/2025 add -MajorVersion & MinorVersion to return those sub-strings (support queries for the values in isolation); updated logic for the variant outputs.
        * 11:26 AM 9/29/2025 port from install-Exchnage15-TTC.ps1 into vdesk
        .DESCRIPTION
        get-OSFullVersionTDO - local OS Semantic Version number n.n.n.n, via get-cimInstance/get-WMIObject
       .PARAMETER MajorVersion
       Switch to return solely the MajorVersion value
       .PARAMETER MinorVersion        
        Switch to return solely the MinorVersion value
        .INPUTS
        None, no piped input.
        .OUTPUTS
        String Semantic Version
        .EXAMPLE
        PS> $OSSemVers = get-OSFullVersionTDO; 
        PS> $OSSemVers ; 
        
            10.0.19045          
        
        Demo call
        .EXAMPLE
        PS> if(get-variable -name State){
        PS>     $State['MajorSetupVersion'] = get-OSFullVersionTDO -MajorVersion ;
        PS>     $State['MinorSetupVersion'] = get-OSFullVersionTDO -MinorVersion ;
        PS> } else{
        PS>     #$SetupVersion = Get-FileVersionTDO $CabExSetup.fullname ;
        PS>     $MajorSetupVersion = get-OSFullVersionTDO -MajorVersion ;
        PS>     $MinorSetupVersion = get-OSFullVersionTDO -MinorVersion ;
        PS> } ; 
        Demo use of the -MajorVersion & -MinorVersion params
        .LINK
        https://github.org/tostka/verb-desktop/
        #>
        [CmdletBinding()]
        [alias('get-OSFullVersion')]
        PARAM(
            [Parameter(HelpMessage = "Switch to return solely the MajorVersion value[-MajorVersion]")]
                [switch]$MajorVersion,
            [Parameter(HelpMessage = "Switch to return solely the MinorVersion value[-MinorVersion]")]
                [switch]$MinorVersion
        ) ; 
        if($MajorVersion -AND $MinorVersion){
            $smsg = "*BOTH* -MajorVersion & -MinorVersion SPECIFIED: SPECIFY ONE OR THE OTHER!" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            BREAK ; 
        } ; 
        if (get-command get-ciminstance -ea 0) {
            $OS = Get-ciminstance -class  Win32_OperatingSystem ; 
        } else {
            $OS = Get-WmiObject Win32_OperatingSystem ; 
        } ;
        $MajorOSVersion= [string]($OS| Select-Object @{n="Major";e={($_.Version.Split(".")[0]+"."+$_.Version.Split(".")[1])}}).Major ; 
        $MinorOSVersion= [string]($OS| Select-Object @{n="Minor";e={($_.Version.Split(".")[2])}}).Minor ; 
        $FullOSVersion= ('{0}.{1}' -f $MajorOSVersion, $MinorOSVersion) ;
        if($MajorVersion){
            $smsg = "-MajorVersion: returning to pipeline $($MajorVersion)" ;
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $MajorVersion | write-output 
        } elseif($MinorVersion){
            $MinorOSVersion | write-output ; 
            $smsg = "-MinorOSVersion: returning to pipeline $($MinorOSVersion)" ;
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
        }else{ 
            $smsg = "Returning FullOSVersionto pipeline $($FullOSVersion)" ;
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $FullOSVersion | write-output  ;
        }
    }
#endregion GET_OSFULLVERSIONTDO ; #*------^ END get-OSFullVersionTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvEdJFUHSa++2D0qFdoKe4YFN
# qf2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTdVkv/
# cgamRFW54RyuUveW5sQ9qzANBgkqhkiG9w0BAQEFAASBgLMstTO5igC4kRL1AScm
# 351IZNbrnXyw9J0F8uVcIa8qQ+01vGsV5ndnUqhRGLe87HnP0eJdRS0itpyZhvMx
# 6N7TwT8SvUJoqPAZTREjFYGT8T/eOp66RehkfpoJxTI8E8ukeVRASF0znA8vvyUs
# S5Earz3rdYOFY7zhRTLdZQR2
# SIG # End signature block
