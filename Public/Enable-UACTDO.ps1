# Enable-UACTDO.ps1


#region ENABLE_UACTDO ; #*------v Enable-UACTDO v------
function Enable-UACTDO{
        <#
        .SYNOPSIS
        Enable-UACTDO - Enables User Account Control
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Enable-UACTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-desktop
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 1:26 PM 11/3/2025 Enable-UACTDO: add: alias: Enable-UAC
        * 4:41 PM 10/6/2025 fixed comment brackets ; 
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        .DESCRIPTION
        Enable-UACTDO - Enables User Account Control
        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Enable-UAC
        .LINK
        https://github.org/tostka/verb-Desktop/
        #>
        [CmdletBinding()]
        [alias('Enable-UAC821','Enable-UAC')]
        PARAM( ) ;
        $smsg = 'Enabling User Account Control'
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -Value 1 -ErrorAction SilentlyContinue| out-null
        $pltnIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' ;
            Name = "EnableLUA" ;
            Value = 1 ;            
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-ItemProperty w`n$(($pltnIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            New-ItemProperty @pltnIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;     
    }
#endregion ENABLE_UACTDO ; #*------^ END Enable-UACTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUE1jeaw7yprO1N0NHxBrAvWe2
# GGSgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT1atpx
# rXJz7jTiH3dbWQ20cyskFzANBgkqhkiG9w0BAQEFAASBgDJsbWWjweUZzMJr9asm
# dfjOby0zDO4L9uS/BeKFpuWUuCoNyBkEslX6KIBCpKV8HeVSNJDz0qaKEzAMSA2K
# O7YZhDYLf+YK6ySp++at5VCG8PFaRTCCjZpi2vcPYzo4X3qvcSl7Eqsk7GqFHnPO
# nkluR8VNfsXRPRuIPbTHLB+x
# SIG # End signature block
