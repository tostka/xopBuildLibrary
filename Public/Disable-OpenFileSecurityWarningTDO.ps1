#region DISABLE_OPENFILESECURITYWARNINGTDO ; #*------v FUNCTION Disable-OpenFileSecurityWarningTDO v------
function Disable-OpenFileSecurityWarningTDO{
        <#
        .SYNOPSIS
        Disable-OpenFileSecurityWarningTDO - Suppresses Open File - Security Warning popup prompts
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Disable-OpenFileSecurityWarningTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 4:20 PM 10/8/2025 added back differential write-my* support
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        .DESCRIPTION
        Disable-OpenFileSecurityWarningTDO - Suppresses Open File - Security Warning popup prompts        
        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Disable-OpenFileSecurityWarning
        .LINK
        https://github.org/tostka/verb-Desktop/
        #>
        [CmdletBinding()]
        [alias('Disable-OpenFileSecurityWarning')]
        PARAM() ;
        $smsg = 'Disabling File Security Warning dialog'
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ;
        # New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -ErrorAction SilentlyContinue |out-null
        $pltnItm=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;                       
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-Item w`n$(($pltnItm|out-string).trim())" ; 
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ;
        TRY{
            New-Item @pltnItm | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        } ;  
        #New-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -name 'LowRiskFileTypes' -value '.exe;.msp;.msu;.msi' -ErrorAction SilentlyContinue |out-null
        $pltnIP=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;
            Name = "LowRiskFileTypes" ;
            Value = '.exe;.msp;.msu;.msi' ;            
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-ItemProperty w`n$(($pltnIP|out-string).trim())" ; 
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ;
        TRY{
            New-ItemProperty @pltnIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        } ;  
        #New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -ErrorAction SilentlyContinue |out-null
        $pltnItm=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;                       
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-Item w`n$(($pltnItm|out-string).trim())" ; 
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ;
        TRY{
            New-Item @pltnItm | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        } ;  
        #New-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -name 'SaveZoneInformation' -value 1 -ErrorAction SilentlyContinue |out-null
        $pltnIP=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;
            Name = "SaveZoneInformation" ;
            Value = 1 ;            
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-ItemProperty w`n$(($pltnIP|out-string).trim())" ; 
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ;
        TRY{
            New-ItemProperty @pltnIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        } ;  
        # Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -Name 'LowRiskFileTypes' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;   
            Name = 'LowRiskFileTypes' ;
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        } ;
        # Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -Name 'SaveZoneInformation' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;   
            Name = 'SaveZoneInformation' ; 
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        } ;
    }
#endregion DISABLE_OPENFILESECURITYWARNINGTDO ; #*------^ END FUNCTION Disable-OpenFileSecurityWarningTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtVQBxS9mmck+88aaZlltQkZC
# whegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSewrZz
# yAprC3Vewhgn4GzetnRRRzANBgkqhkiG9w0BAQEFAASBgLYZR2AcZCn1MP30rSa6
# 5mPDuF7xLfImvX7mxLl+nSnyM8Di6PTtk01nKK7XAwODIwMVFpHsPERgBXjE0yFT
# ZcwmQbd8SkbMhg8bkEWm0xxbgoZ7MWDCZ7IJTz9HFYixPoUe1ZK44efrNpDMSCKq
# QqMnQ6nyngCASmTBiza63ANw
# SIG # End signature block
