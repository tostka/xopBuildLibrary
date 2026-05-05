#region SET_WALLPAPERTDO ; #*------v FUNCTION Set-WallpaperTDO v------
Function Set-WallpaperTDO {
        <# 
        .SYNOPSIS
        Set-WallpaperTDO - Set specified file as desktop wallpaper
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2016-06-27
        FileName    : Set-WallpaperTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-desktop
        Tags        : Powershell,Wallpaper,Status
        AddedCredit : _Emin_
        AddedWebsite: https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
        AddedTwitter: URL
        REVISIONS   :
        * 11:13 AM 9/29/2025 rplc verb-noun -> Set-WallpaperTDO
        * 2:59 PM 9/4/2025 strongly type params, add parameter tags and helpmessage, update CBH
        * 4:08 PM 9/3/2025 update name to new tagged standard: ren Set-Wallpaper => Set-WallpaperTDO (alias orig name)
        * 9:12 AM 6/27/2016 TSK reformatted & added pshelp
        * September 5, 2014 - posted version
        .DESCRIPTION
        .PARAMETER  Path
        Path to image to be set as desktop backgroun[-Path c:\pathto\bg.bmp]
        .PARAMETER  Style
        Wallpaper image display style (Center|Stretch|Fill|Tile|Fit, default:Stretch)[-Style Fill]
        .INPUTS
        None. Does not accepted piped input.
        .OUTPUTS
        None. Returns no objects or output.
        .EXAMPLE
        PS> Set-WallpaperTDO -Path $WallPaper.FullName -Style Fill ;
        Set wallpaper file to fill screen
        .EXAMPLE
        PS> Set-Wallpaper -Path "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Style Fill ; 
        To Restore the default VM wallpaper (e.g. generally the Windows OS default)
        .LINK
        https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
        .LINK
        https://github.com/tostka/verb-desktop
        #>
        [CmdletBinding()]
        [Alias('Set-Wallpaper')]
        Param(
            [Parameter(Mandatory=$true,HelpMessage="Path to image to be set as desktop backgroun[-Path c:\pathto\bg.bmp]")]
                [ValidateScript({Test-Path $_ -pathtype Leaf})]
                [string]$Path,
            [Parameter(HelpMessage="Wallpaper image display style (Center|Stretch|Fill|Tile|Fit, default:Stretch)[-Style Fill]")]
                [ValidateSet('Center','Stretch','Fill','Tile','Fit')]
                [string]$Style = 'Stretch' 
        ) ; 
        $verbose = ($VerbosePreference -eq "Continue") ; 
        Try {
            if (-not ([System.Management.Automation.PSTypeName]'Wallpaper.Setter').Type) {
                Add-Type -TypeDefinition @"
           using System;
            using System.Runtime.InteropServices;
            using Microsoft.Win32;
            namespace Wallpaper {
                public enum Style : int {
                Center, Stretch, Fill, Fit, Tile
                }
                public class Setter {
                    public const int SetDesktopWallpaper = 20;
                    public const int UpdateIniFile = 0x01;
                    public const int SendWinIniChange = 0x02;
                    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                    private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
                    public static void SetWallpaper ( string path, Wallpaper.Style style ) {
                        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
                        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
                        switch( style ) {
                            case Style.Tile :
                                key.SetValue(@"WallpaperStyle", "0") ;
                                key.SetValue(@"TileWallpaper", "1") ;
                                break;
                            case Style.Center :
                                key.SetValue(@"WallpaperStyle", "0") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Stretch :
                                key.SetValue(@"WallpaperStyle", "2") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Fill :
                                key.SetValue(@"WallpaperStyle", "10") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Fit :
                                key.SetValue(@"WallpaperStyle", "6") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
}
                        key.Close();
                    }
                }
            }
"@ -ErrorAction Stop ; 
                } else {
                    Write-Verbose -Message "Type already loaded" -Verbose ; 
                } ; 
            # } Catch TYPE_ALREADY_EXISTS
            } Catch {
                Write-Warning -Message "Failed because $($_.Exception.Message)" ; 
            } ; 
     
        [Wallpaper.Setter]::SetWallpaper( $Path, $Style ) ; 
    }
#endregion SET_WALLPAPERTDO ; #*------^ END FUNCTION Set-WallpaperTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUW4JIyk0OWohQ6JedA6SswGzV
# 256gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQrWxF8
# sH2Bfl31XUxmcCff40xxYTANBgkqhkiG9w0BAQEFAASBgBMz5/uKSeNlzYid0KDZ
# ILuPmuvjPNpYCVRx4pAl0Ypkfb3uB+nVbRoVlsP3kPUF3w0FhCzuVjxsElC7aZ33
# 85mdG3dh4TYJsMfeZ7FO46AyyQhJLPtzBG8/XyWjcGFUI0TU3zBksHSJnlgYrmAP
# HEvT0OqrP65kjo7MkrivNQhS
# SIG # End signature block
