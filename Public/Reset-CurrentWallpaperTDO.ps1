#region RESET_CURRENTWALLPAPERTDO ; #*------v FUNCTION Reset-CurrentWallpaperTDO v------
Function Reset-CurrentWallpaperTDO {
        <#
        .SYNOPSIS
        Reset-CurrentWallpaperTDO - Tests for, and clears any configured HKCU:\Control Panel\Desktop WallPaper Value to $NULL, and refreshes the desktop
        .NOTES
        Version     : 1.0.0
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2025-07-30
        FileName    : Reset-CurrentWallpaperTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,Math,Round,Ceiling,Floor,Truncate,Number,Decimal
        AddedCredit : REFERENCE
        AddedWebsite:	URL
        AddedTwitter:	URL
        REVISIONS
        * 11:17 AM 9/29/2025 CBH: corrected output spec to None.
        * 4:06 PM 9/3/2025 init
        .DESCRIPTION
        Reset-CurrentWallpaperTDO - Tests for, and clears any configured HKCU:\Control Panel\Desktop WallPaper Value to $NULL, and refreshes the desktop
        .OUTPUT
        None
        .EXAMPLE
        PS> Reset-CurrentWallpaperTDO 
        Demo call
        .LINK
        https://github.com/tostka/verb-desktop
        #>
        PARAM()
        PROCESS{
            $CurrentWallPaperValue = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper").WallPaper ; 
            if($CurrentWallPaperValue){
                $smsg = "HKCU:\Control Panel\Desktop\ WallPaper Value is currently set to: $($CurrentWallPaperValue)" ;
                if(test-path -path $CurrentWallPaperValue -PathType Leaf){
                    $smsg += "`n(which exists)" ;                    
                } else{
                    $smsg += "`n(which does not exist)" ;
                }; 
                $smsg += "`nClearing the value..." ;
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper" -Value $NULL -verbose ; 
                $CurrentWallPaperValue = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper").WallPaper ; 
                $smsg = "HKCU:\Control Panel\Desktop\ WallPaper value is now set: $($CurrentWallPaperValue)" ;
                $smsg += "`nIssuing desktop reset:rundll32.exe user32.dll, UpdatePerUserSystemParameters..." ;
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;              
                } ;
                rundll32.exe user32.dll, UpdatePerUserSystemParameters ; 
            } else{
                $smsg = "HKCU:\Control Panel\Desktop\ WallPaper Value is currently UNSET (NULL) (no change)" ; 
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
            } ; 
        }
    }
#endregion RESET_CURRENTWALLPAPERTDO ; #*------^ END FUNCTION Reset-CurrentWallpaperTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURzjuszqBGUnXIPTZR7CMtnkG
# +pOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQxHhdr
# R0HQSFdx5FwHGQdJ+P4a6DANBgkqhkiG9w0BAQEFAASBgACaSbzsRI838IYNeCmu
# W5Xx6m+1qo42/MCeq0hNv5qJri6A+/hPCljthRexEJqub0eBnruZJG11kKmN2DbV
# 0wwcE+ZVIP0MkX0P0ZTxmOxX50uhFLteR2XsXE7WrJIkOOUcNhpiJ63pnKcrsdLe
# EL4cJxfQcWHWM38XHGBzL6Wd
# SIG # End signature block
