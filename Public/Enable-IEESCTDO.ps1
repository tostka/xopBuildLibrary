#region ENABLE_IEESCTDO ; #*------v FUNCTION Enable-IEESCTDO v------
Function Enable-IEESCTDO {
        <#
        .SYNOPSIS
        Enable-IEESCTDO - Enabling IE Enhanced Security Configuration, for use with/emulating install-Exchange15-TTC.ps1
        .NOTES
        Version     : 0.0.1
        Author      : Michel de Rooij, michel@eightwone.com
        Website     : http://eightwone.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250929-1026AM
        FileName    : Enable-IEESCTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.org/tostka/powershellBB/
        Tags        : ExchangeServer,Version,Install,Maintenance
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 2:39 PM 10/8/2025 TTC: port to xopBL ren'd Enable-IEESC() -> Enable-IEESCTDO() to backfill borked wrapup cleanup; init 
        .DESCRIPTION
        Enable-IEESCTDO - Enabling IE Enhanced Security Configuration, for use with/emulating install-Exchange15-TTC.ps1
        .PARAMETER Statefile
        Path to Statefile[-path c:\pathto\SERVERNAME_Install-Exchange15-TTC.ps1_state.xml]                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Collections.Hashtable contining data from Statefile .xml 
        .EXAMPLE
        PS> $State=@{}
        PS> $ex15ScriptName = "Install-Exchange15-TTC.ps1" ;
        PS> if(-not $StateFile){$StateFile= "$InstallPath\$($env:computerName)_$($ex15ScriptName)_state.xml"}
        PS> $StateFile= "$InstallPath\$($env:computerName)_$($ScriptName)_state.xml"
        PS> $State= Enable-IEESC -StateFile $StateFile ; 
        Demo call
        .LINK
        https://github.org/tostka/powershellBB/
        #>
        [CmdletBinding()]
        [alias('Enable-IEESC')]
        PARAM() ; 
        Write-MyVerbose 'Enabling IE Enhanced Security Configuration'
        $AdminKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
        $UserKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
        New-Item -Path (Split-Path $AdminKey -Parent) -Name (Split-Path $AdminKey -Leaf) -ErrorAction SilentlyContinue | out-null
        Set-ItemProperty -Path $AdminKey -Name 'IsInstalled' -Value 1 -Force | Out-Null
        New-Item -Path (Split-Path $UserKey -Parent) -Name (Split-Path $UserKey -Leaf) -ErrorAction SilentlyContinue | out-null
        Set-ItemProperty -Path $UserKey -Name 'IsInstalled' -Value 1 -Force | Out-Null
        If( Get-Process -Name explorer.exe -ErrorAction SilentlyContinue) {
            Stop-Process -Name Explorer
        }
    }
#endregion ENABLE_IEESCTDO ; #*------^ END FUNCTION Enable-IEESCTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUR7jaLvDm3QYjBJEC8uSVT4/E
# M4ugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQMtQ1v
# lqSB2habEQd40LpJepDRpzANBgkqhkiG9w0BAQEFAASBgKaalYUK7EOO9+YfCR2L
# SNmAdv5njXYvZyQzTokBEdRCYmNlcdP72pdSdaZ7Ysrg9X+N5oRBKrAo4/rHr5/3
# 74nnByqtuDfQDWzqfbaxDNM4ks34j9R8YHWlu3xmXtGSiEDcPAYIOIOCFM6TTpvK
# gPqWKkZlLr2GH5zdVaCa2HTu
# SIG # End signature block
