#region DISABLE_AUTOLOGONTDO ; #*------v FUNCTION Disable-AutoLogonTDO v------
function Disable-AutoLogonTDO{
        <#
        .SYNOPSIS
        Disable-AutoLogonTDO - Deconfigures autologon of the specified credential, after reboots (reverses Enable-AutoLogon821))
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Disable-AutoLogonTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-desktop
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 2:35 PM 2/17/2026 add missing base alias
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        .DESCRIPTION
        Disable-AutoLogonTDO - Deconfigures autologon of the specified credential, after reboots (reverses Enable-AutoLogon821))
        .PARAMETER Credential
        Use specific Credentials[-Credentials [credential object]
        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Disable-AutoLogon
        .LINK
        https://github.org/tostka/verb-Desktop/
        #>
        [CmdletBinding()]
        [alias('Disable-AutoLogon821','Disable-AutoLogon')]
        PARAM() ;
        $smsg = 'Disabling Automatic Logon'
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -ErrorAction SilentlyContinue| out-null
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' ;
            Name = "AutoAdminLogon" ;          
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ; 
        #Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -ErrorAction SilentlyContinue| out-null
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' ;
            Name = "DefaultUserName" ;
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;  
        # Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -ErrorAction SilentlyContinue| out-null
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' ;
            Name = "DefaultPassword" ;       
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;
    }
#endregion DISABLE_AUTOLOGONTDO ; #*------^ END FUNCTION Disable-AutoLogonTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhwQqJ1YDBY/DTxPFhINyFPw6
# i4ugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQrtINC
# lyOk96+RUMgGpWJTLlWLCzANBgkqhkiG9w0BAQEFAASBgGHJ2dd9pu6BQP/5JVCx
# dgZ/mXEM62G7z5m5cMc2KC2hcjd8sqSw/EHqAAweATnD0ejKJj0X3JYQ9Jh4DTay
# BGQtNekvDjceRXcKwM5B51WLd/KlB/yKouOkDMgf7Fka1Vnz8gChqZ7FeNEwELQg
# 1LsSZ6zwK2k9YuXGp49wsUak
# SIG # End signature block
