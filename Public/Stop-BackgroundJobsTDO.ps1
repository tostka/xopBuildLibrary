#region STOP_BACKGROUNDJOBSTDO ; #*------v FUNCTION Stop-BackgroundJobsTDO v------
Function Stop-BackgroundJobsTDO {
            <#
            .SYNOPSIS
            Stop-BackgroundJobsTDO - Receive-Job & Stop-Job pre-configured `$Global:BackgroundJobs (which are accumulated Start-Job's from other proceses), normally a manual fire, and as a Register-EngineEvent -SourceIdentifier PowerShell.Exiting binding.
            .NOTES
            Version     : 0.0.
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 20250711-0423PM
            FileName    : Stop-BackgroundJobsTDO.ps1
            License     : (none asserted)
            Copyright   : (none asserted)
            Github      : https://github.com/tostka/verb-ex2010
            Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
            AddedCredit : Michel de Rooij / michel@eightwone.com
            AddedWebsite: http://eightwone.com
            AddedTwitter: URL
            REVISIONS
            * 10:17 AM 9/29/2025 reflects 4.20 github vers update:  port to vio from xopBuildLibrary; add CBH, and Adv Function specs; config defer of w-My to native wlt
            .DESCRIPTION
            Stop-BackgroundJobsTDO - Receive-Job & Stop-Job pre-configured `$Global:BackgroundJobs (which are accumulated Start-Job's from other proceses), normally a manual fire, and as a Register-EngineEvent -SourceIdentifier PowerShell.Exiting binding.
                
            .INPUTS
            None, no piped input.
            .OUTPUTS
            None.
            .EXAMPLE
            PS> Stop-BackgroundJobs -Name $ENV:COMPUTERNAME -Wait
            Demo pulling setup CAB version
            .EXAMPLE
            PS> write-verbose "pre-configure backgroundjobs and auto-cleanup via separate xopBuildLibrary\Stop-BackgroundJobs() on exit trap" ; 
            PS> $BackgroundJobs= @() ; 
            PS> Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
            PS>     Stop-BackgroundJobs 
            PS> } | Out-Null ; 
            PS> TRAP {
            PS>     Write-MyWarning 'Script termination detected, cleaning up background jobs...'
            PS>     Stop-BackgroundJobs
            PS>     break
            PS> } ; 
            PS> if (-not $Global:BackgroundJobs) {
            PS>     $Global:BackgroundJobs = @()
            PS> }
            PS> $Job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Name, $ConfigNC -Name ('Clear-AutodiscoverSCP-{0}' -f $Name)
            PS> $Global:BackgroundJobs += $Job
            PS> Write-MyVerbose ('Started background job to clear AutodiscoverServiceConnectionPoint for {0} (Job ID: {1})' -f $Name, $Job.Id)        
            PS> write-verbose "Then Cleanup any background jobs" ; 
            PS> Stop-BackgroundJobs ; 
            Demo preconfiguring backgroundjobs cleanup, run SCP config pass, run install pass, and then post-cleanup backgroundjobs
            .LINK
            https://github.org/tostka/powershellBB/
            #>
            [CmdletBinding()]
            [alias('Stop-BackgroundJobs')]
            PARAM()
            if ($Global:BackgroundJobs -and $Global:BackgroundJobs.Count -gt 0) {
                $smsg = "Cleaning up $($Global:BackgroundJobs.Count) background job(s)..."
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {                
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ;
                foreach ($Job in $Global:BackgroundJobs) {
                    if ($Job.State -eq 'Running') {
                        Stop-Job -Job $Job -ErrorAction SilentlyContinue
                    }
                    $JobOutput= Receive-Job -Job $Job
                    $smsg =  ('Cleanup background job: {0} (ID {1}), Output {2}' -f $Job.Name, $Job.Id, $JobOutput) ; 
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {                
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ;
                    Remove-Job -Job $Job -Force -ErrorAction SilentlyContinue
                }
                $Global:BackgroundJobs = @()
                $smsg = "Background job cleanup completed."
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {                
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ;
            } ; 
        }
#endregion STOP_BACKGROUNDJOBSTDO ; #*------^ END FUNCTION Stop-BackgroundJobsTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUM7kxkXRKiGmuLXyBPSRCG3AR
# Ag2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTnTK4V
# Vv5Bcqo1BjDwrfXyS4kbkjANBgkqhkiG9w0BAQEFAASBgJszqnqkaJoHJZ1ydIOI
# KBLRJsa9EqK2ub6dRVzIOv+fY6Ze9llPNXokAt9xNYYg0gcBigNMr8FTiAO6eKho
# ZG4abeekqp53kXK3RB/1uHN0TGtnqFQ/b19zuqXzKsl9gZgln9Q+Z1pabVZ895OE
# sQO/DhsIhtfD8mX0HCDrkk/O
# SIG # End signature block
