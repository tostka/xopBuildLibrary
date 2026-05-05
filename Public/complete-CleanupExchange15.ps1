#region COMPLETE_CLEANUPEXCHANGE15 ; #*------v FUNCTION complete-CleanupExchange15 v------
Function complete-CleanupExchange15 {
        <# .NOTES
        REVISIONS
        * 10:57 AM 10/8/2025 TTC: port to xopBL ren'd Cleanup() -> complete-CleanupExchange15() to backfill borked wrapup cleanup; 
        add cmdletbinding, param & alias, append TDO to name; added non-$State support: elseif's through $TargetPath when $State['TargetPath'] missing
        Version 4.20, September 15th, 2025
        Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
        #>
        [CmdletBinding()]
        [alias('Cleanup')]
        PARAM()
        # in this case, we *always* want logging into the build log, so that test-Exchange15-install-ttc.ps1 will find and clear the dangling bad tests.
        # $StateFile= "$InstallPath\$($env:computerName)_$($ScriptName)_state.xml"
        #$ex15ScriptName = "Install-Exchange15-TTC.ps1" ;         
        # initiate the $State
        if(-not $ex15ScriptName ){$ex15ScriptName = "Install-Exchange15-TTC.ps1"} ;        
        if(-not $InstallPath){
            $smsg = "MISSING/UNDEFINED `$InstallPath!"
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            BREAK ; 
        } ;
        if(-not $StateFile){$StateFile= "$InstallPath\$($env:computerName)_$($ex15ScriptName)_state.xml"}
        $State=@{}
        $State= Restore-Exchange15State -StateFile $StateFile ;
        # leverage TranscriptFile for writes (enforces outputs into the main install log)
        Write-MyOutput "Cleaning up .."
        If( Get-WindowsFeature Bits) {
            Write-MyOutput "Removing BITS feature"
            Remove-WindowsFeature Bits
        }
        #region TTC_FIXRERUNPHASE6 ; #*------v TTC_FIXRERUNPHASE6 v------
        # splice over the phase 6 6{} elements, to ensure fully cleanedup 
        If( Get-Service MSExchangeTransport -ErrorAction SilentlyContinue) {
            Write-MyOutput "Configuring MSExchangeTransport startup to Automatic"
            Set-Service MSExchangeTransport -StartupType Automatic
        }
        If( Get-Service MSExchangeFrontEndTransport -ErrorAction SilentlyContinue) {
            Write-MyOutput "Configuring MSExchangeFrontEndTransport startup to Automatic"
            Set-Service MSExchangeFrontEndTransport -StartupType Automatic
        }
        Write-MyVerbose 'Restoring Server Manager startup configuration'
        if($State){
            If( $State['DoNotOpenServerManagerAtLogon']) {
                New-ItemProperty -Path 'HKCU:\Software\Microsoft\ServerManager' -Name DoNotOpenServerManagerAtLogon -Value $State['DoNotOpenServerManagerAtLogon'] -Force -ErrorAction SilentlyContinue | Out-Null
            }
            if( -not($State['InstallEdge'])){
                Write-MyVerbose 'Performing Health Monitor checks..'
                # Warmup IIS
                $web = New-Object Net.WebClient
                # To ignore self-signed cert warnings
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
                'OWA', 'ECP', 'EWS', 'Autodiscover', 'Microsoft-Server-ActiveSync', 'OAB', 'mapi', 'rpc' | ForEach-Object {
                    $url = 'https://localhost/{0}/healthcheck.htm' -f $_
                    Try {
                        $output = $web.DownloadString($url)
                        Write-MyOutput ('Healthcheck {0}: {1}' -f $url, ($output -split '<')[0])
                    }
                    Catch {
                        Write-MyWarning ('Healthcheck {0}: {1}' -f $url, 'ERR')
                    }
                }
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
            }
            Else {
                Write-MyVerbose 'InstallEdge Mode, skipping IIS health monitor checks'
            }
            Enable-UAC
            Enable-IEESC
            Write-MyOutput "Setup finished - We're good to go."
            #endregion TTC_FIXRERUNPHASE6 ; #*------^ END TTC_FIXRERUNPHASE6 ^------
            #region TTC_FIXRERUNPOSTPHASE6 ; #*------v TTC_FIXRERUNPOSTPHASE6 v------
            if(gv State -ea 0){$State["LastSuccessfulPhase"]= $State["InstallPhase"]} ; 
            Enable-OpenFileSecurityWarning
            if(gv State -ea 0){
                Save-State -State $State -Statefile $StateFile ; 
                If( $State['SourceImage']) {
                    Dismount-DiskImage -ImagePath $State['SourceImage']
                }
                If( $State["AutoPilot"]) {
                    If( $State["InstallPhase"] -lt $MAX_PHASE) {
        	            Write-MyVerbose "Preparing system for next phase"
	                    Disable-UACTDO
                        Disable-IEESCTDO
                        Enable-AutoLogonTDO
                        Enable-RunOnceTDO
                    }
                    Else {
                        Cleanup
                    }
                    Write-MyOutput "Rebooting in $COUNTDOWN_TIMER seconds .."
                    Start-Sleep -Seconds $COUNTDOWN_TIMER
                    Restart-Computer -Force
                }
            } else{

            } ; 
        } else { 
            $smsg = "MISSING DEPENDANT `$STATE[xxx] VARIABLE!"
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            THROW $SMSG ; 
            BREAK ; 
        }
        # Exit $ERR_OK
        # the above closes ISE etc, 
        if($psise){
            $smsg = "ISE: avoiding explicit EXIT: status: $($ERR_OK)" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        }else{
           # Exit $ERR_OK
        }
        #endregion TTC_FIXRERUNPOSTPHASE6 ; #*------^ END TTC_FIXRERUNPOSTPHASE6 ^------
        #region TTC_FIXSTATEBU ; #*------v TTC_FIXSTATEBU v------
        Write-MyOutput "Backing up state file $($Statefile) to  state file $($Statefile)_FINAL"
        # $StateFile= "$InstallPath\$($env:computerName)_$($ScriptName)_state.xml"
        copy-item -path $StateFile -Destination ($StateFile.replace('_state.xml','_state.xml_FINAL'))
        #endregion TTC_FIXSTATEBU ; #*------^ END TTC_FIXSTATEBU ^------
        Write-MyVerbose "Removing state file $Statefile"
        Remove-Item $Statefile
        Write-MyOutput "Rebooting in $COUNTDOWN_TIMER seconds .."
        Start-Sleep -Seconds $COUNTDOWN_TIMER
        Restart-Computer -Force
    }
#endregion COMPLETE_CLEANUPEXCHANGE15 ; #*------^ END FUNCTION complete-CleanupExchange15  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEHotlVS1agCZyuNsbiFs6teF
# W2+gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSVngMq
# sHPn2GH24PtwpMw+EIPzpzANBgkqhkiG9w0BAQEFAASBgCzhzksAwFXYcwCX8cHN
# aR9I2qXXzc6yQljAyYDNiUyPMRv0haQgH95nBODNeIY3xLRUJ51S8xp8TSi/d+6q
# qRFi/XtMKpMKk+8E9fQgBI+kfW3w52OB7wp1iHIgWEa4DmNmL0k22DlsDtPCw/nw
# k9T0UXjQ8dmMJKMk1NvP4USl
# SIG # End signature block
