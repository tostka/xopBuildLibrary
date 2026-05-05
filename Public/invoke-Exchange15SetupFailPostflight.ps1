#region INVOKE_EXCHANGE15SETUPFAILPOSTFLIGHT ; #*------v FUNCTION invoke-Exchange15SetupFailPostflight v------
function invoke-Exchange15SetupFailPostflight{
        <#
        .SYNOPSIS
        invoke-Exchange15SetupFailPostflight - This function gets run after a setup fail - non-zero (0) setup exit - downs the server (Start-ex16MaintenanceMode, service disable if necessary), outputs trailing 25lines of setup log (via show-ExchangeSetupLogSummary), then checks watermarks (via test-xopExchangeInstallWatermarkTDO)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-03-19
        FileName    : invoke-Exchange15SetupFailPostflight.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/PowershellBB
        Tags        : Powershell
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 3:54 PM 8/17/2025 add -InstallPhase support-invoke-Exchange15SetupFailPostflight edge update: added rgxEdgeInstalledRole and detect of duplicate setup pass after completed Edge install (expected non-impactful error if no watermarks).
        * 2:58 PM 8/6/2025 typo fixes, dbgd; ; added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        * 1:10 PM 8/5/2025 init, move out of install-Exchange15-TTC.ps1 (needs to be run in both Install-Exchange15_() & in phase 4{}, so functionalize).
        .DESCRIPTION
        invoke-Exchange15SetupFailPostflight - This function gets run after a setup fail - non-zero (0) setup exit - downs the server (Start-ex16MaintenanceMode, service disable if necessary), outputs trailing 25lines of setup log (via show-ExchangeSetupLogSummary), then checks watermarks (via test-xopExchangeInstallWatermarkTDO)
        
        .PARAMETER LogCount
        Number of lines of most recent ExchangeSetupLog session to return/review
        .PARAMETER InstallPhase
        InstallPhase (the `$State.InstallPhase from install-Exchange15-TTC.ps1, at time of call)[-InstallPhase `$State['InstallPhase']
        
        .INPUTS
        None. Does not accepted piped input.(.NET types, can add description)
        .OUTPUTS
        System.Object summary of local ExServer status, services, ComponentStatus, and ExSEtupLog comb-out status.
        .EXAMPLE
        PS> $PostFlight = invoke-Exchange15SetupFailPostflight -InstallPhase $State["InstallPhase"] ; 
        demo call
        .LINK
        https://github.com/tostka/powershell/
        #>
        # #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
        [CmdletBinding()]
        Param (
            [Parameter(mandatory=$false,
                HelpMessage="Number of lines of most recent ExchangeSetupLog session to return/review")]
                [int]$LogCount=30,
            [Parameter(mandatory=$false,
                HelpMessage="InstallPhase (the `$State.InstallPhase from install-Exchange15-TTC.ps1, at time of call)[-InstallPhase `$State['InstallPhase']")]
                [int]$InstallPhase
        ) ;
        BEGIN{
            #region LOCAL_CONSTANTS  ; #*------v LOCAL_CONSTANTS v------
            $rgxExSvcNamesFull = '^(MSEx|W3SVC|ClusSvc)' ; 
            $rgxSetupStart = "Starting\sMicrosoft\sExchange\sServer\s.*\sSetup"
            $rgxSetupEnd = "\sEnd\sof\sSetup" ;
            $rgxSetupIncomplete = "The\sExchange\sServer\ssetup\soperation\sdidn't\scomplete\." ; 
            $rgxSetupError = "\[ERROR]\s" ; 
            $rgxDriveSpace = "\[ERROR]\sExchange\sServer\srequires\sat\sleast\s[\d\.]+\sGB\sof\sdisk\sspace\." ; 
            $rgxBadSourcePath = "This\sinstallation\spackage\scould\snot\sbe\sopened\.\sVerify\sthat\sthe\spackage" ; 
            $rgxNoInstallRole = "\[ERROR]\sPlease\sselect\sat\sleast\sone\sserver\srole\sto\sinstall\.\sMake\ssure\sthat\sthe\sspecified\sroles\saren't\salready\sinstalled"; 
            # 2:14 PM 8/17/2025: add Edge already installed error
            $rgxEdgeInstalledRole = "The\sEdge\sTransport\srole\shas\sbeen\sunpacked\sor\sinstalled\.\sThe\sother\sroles\scannot\sbe\sinstalled\swith\sthe\sEdge\sTransport\srole\."
            $rgxADPrep = "\[ERROR]\sSetup\sencountered\sa\sproblem\swhile\svalidating\sthe\sstate\sof\sActive\sDirectory:" ; 
            #endregion LOCAL_CONSTANTS ; #*------^ END LOCAL_CONSTANTS ^------
            # results summary hash
            $ResultSummary = [ordered]@{
                ServerComponentState= $null ; 
                didMaintenanceMode = $false ;
                didExDisable = $false ; 
                hasExServices = $false ; 
                ExServicesStatus = $null ; 
                ExSetupLogSummary = $null ; 
                WatermarkTest = $null ; 
                isServerValid = $false ; 
                isFailedInstall = $false ; 
            }
            
        } ;  # BEG-E
        PROCESS{            
            # 4:54 PM 7/23/2025 TTC run disable here: Start-ex16MaintenanceMode -Identity, crashes are LEAVING RUNNING SERVICES!
            #if(get-service msex* | ?{$_.status -eq 'Running'}){            
            if($ResultSummary.ExServicesStatus = get-service -ComputerName $env:computername | ? { $_.ServiceName -match $rgxExSvcNamesFull } | select-object servicename, displayname, status, starttype){
                $ResultSummary.hasExServices = $true ;
                $smsg = "Running MSEX* Services!`n$(($ResultSummary.ExServicesStatus | ?{$_.status -eq 'Running'}|out-string).trim())" ;
                $smsg += "`nChecking Get-ex16MaintenanceModeTDO..." ;
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 }else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
                $ResultSummary.ServerComponentState = Get-ex16MaintenanceModeTDO -Identity $env:COMPUTERNAME ;
                if($ResultSummary.ServerComponentState.ServerWideOffline.state -eq 'Inactive'){
                    $smsg = "ServerComponentState.ServerWideOffline.state is: $($ResultSummary.ServerComponentState.ServerWideOffline.state)" ;
                    $smsg += "`nServer disabled for CAS/Mail handling, safe to move ahead" ;
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                }else{
                    $smsg = "ServerComponentState.ServerWideOffline.state is: $($ResultSummary.ServerComponentState.ServerWideOffline.state)" ;
                    $smsg += "`nServer NOT DISABLED for CAS/Mail handling, safe to move ahead" ;
                    $smsg += "`nRunning: Start-ex16MaintenanceMode -Identity $($env:computerName)!" ;
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    # it returns a stock get-ex16MaintenanceMode result, same effect
                    $ResultSummary.ServerComponentState = Start-ex16MaintenanceMode -Identity $env:computerName ;
                    $ResultSummary.didMaintenanceMode = $true ;
                    $smsg = "Start-ex16MaintenanceMode: RESULTS`n$(($ResultSummary.ServerComponentState|out-string).trim())" ;
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    if($ResultSummary.ServerComponentState.ServerWideOffline.state -ne 'Inactive'){
                        $smsg = "ServerComponentState.ServerWideOffline.state is: $($MMResults.ServerWideOffline.state)" ;
                        $smsg += "`nServer NOT DISABLED for CAS/Mail handling, NOT SAFE to move ahead!" ;
                        $smsg += "`nRunning: disable-xopExServer -Identity $($env:computerName)!" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        # disable-xopExServer returns filtered get-servives output (subset of props)
                        $ResultSummary.ExServicesStatus = disable-xopExServer -Identity $env:computerName  ;
                        $ResultSummary.didExDisable = $TRUE ; 
                        $smsg = "`disable-xopExServer result:`n$(($ResultSummary.ExServicesStatus | ft -a |out-string).trim())" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } ;
                }                
            }else{
                $smsg = "NO Running MSEX* Services!(ASSUMED FAILED INSTALL)`n$((get-service msex* | ?{$_.status -eq 'Running'}|out-string).trim())" ;
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
                $ResultSummary.isFailedInstall = $true ; 
                $ResultSummary.isServerValid = $false ; 
            } ; 

            # 3:41 PM 8/17/2025 add -InstallPhase support
            if($InstallPhase -ge 4){
                <# ExchangeSEtupLog: is updated by install, CU, SU & Hotfixes, run after all
                    Phase 4 : install
                    Phase 5 : fixes installs
                    Phase 6 :  first phase after completion of trailing fixes
                #>
                $smsg = "InstallPhase:$($InstallPhase): Including ExchangeSetupLog & Watermark checks" ;
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
                # parse and dump the ExchangeSetupLog for trailing errors in last pass
                if(gcm show-ExchangeSetupLogSummary){
                    $smsg = "Running show-ExchangeSetupLogSummary for exit cause..." ;
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    if($loutLast = show-ExchangeSetupLogSummary -Number -1 -PassThru){                
                        $ResultSummary.ExSetupLogSummary = $loutLast| select -last $LogCount ; 
                        $smsg = "Last $($LogCount) lines of log last session:`n$(($ResultSummary.ExSetupLogSummary | out-string).trim())" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        <#
                        $rgxSetupStart = "Starting\sMicrosoft\sExchange\sServer\s.*\sSetup"
                        $rgxSetupEnd = "\sEnd\sof\sSetup" ;
                        $rgxSetupIncomplete = "The\sExchange\sServer\ssetup\soperation\sdidn't\scomplete\." ; 
                        $rgxSetupError = "\[ERROR]\s" ; 
                        $rgxDriveSpace = "\[ERROR]\sExchange\sServer\srequires\sat\sleast\s[\d\.]+\sGB\sof\sdisk\sspace\." ; 
                        $rgxBadSourcePath = "This\sinstallation\spackage\scould\snot\sbe\sopened\.\sVerify\sthat\sthe\spackage" ; 
                        $rgxNoInstallRole = "\[ERROR]\sPlease\sselect\sat\sleast\sone\sserver\srole\sto\sinstall\.\sMake\ssure\sthat\sthe\sspecified\sroles\saren't\salready\sinstalled" ; 
                        # add Edge already installed error
                        $rgxEdgeInstalledRole = "The\sEdge\sTransport\srole\shas\sbeen\sunpacked\sor\sinstalled\.\sThe\sother\sroles\scannot\sbe\sinstalled\swith\sthe\sEdge\sTransport\srole\."
                        $rgxADPrep = "\[ERROR]\sSetup\sencountered\sa\sproblem\swhile\svalidating\sthe\sstate\sof\sActive\sDirectory:" ; 
                        #>
                        if($loutLast | ?{$_ -match $rgxSetupEnd }){
                            # setup completed/didn't crash
                            if($loutLast | ?{$_ -match $rgxSetupIncomplete}){
                                $ResultSummary.isFailedInstall -eq $true ; 
                                $smsg = "EXPLICIT INCOMPLETE LINE MATCHING:$($rgxSetupIncomplete)!" ;
                                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                                # dump errors
                                $smsg = "`[ERROR] lines from trailing ExSetupLog pass:`n$(($loutlast | ?{$_ -match $rgxSetupError}| ft -a |out-string).trim())" ;
                                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                                if($loutLast | ?{$_ -match $rgxDriveSpace}){
                                    $smsg = "INSUFFICIENT BINARIES DRIVE SPACE!:$($rgxDriveSpace)!" ;
                                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    } ;
                                };
                             
                                if($loutLast | ?{$_ -match $rgxBadSourcePath}){
                                    $smsg = "Invalid SourcePath to unpacked ISO!:$($rgxBadSourcePath)!" ;
                                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    } ;
                                };
                                if($loutLast | ?{$_ -match $rgxNoInstallRole }){
                                    $smsg = "No specific Server Role specified (use /mode:Upgrade for patching)!:$($rgxNoInstallRole)!" ;
                                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    } ;
                                };
                                if($loutLast | ?{$_ -match $rgxEdgeInstalledRole }){                                
                                    $smsg = "Edge Role already installed: Secondary install attempt (won't permit added roles after Edge - expected error, don't re-run Stage 4 anymore):$($rgxNoInstallRole)!" ;
                                    $smsg += "`n(Advance State .xml file InstallPhase & LastSuccessfulPhase to skip this step on next pass)" ; 
                                    $smsg += "`nThe Edge Transport role has been unpacked or installed. The other roles cannot be installed with the Edge Transport role." ;
                                    $smsg += "`n(no impact as long as no Watermarks found)" ; 
                                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    } ;
                                };                       
                                if($loutLast | ?{$_ -match $rgxADPrep }){
                                    $smsg = "Issues with Domain/Schema!:$($rgxADPrep)!" ;
                                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    } ;
                                }; 
                            } else {
                                $smsg = "Setup exited with proper:End of Setup" ;
                                $smsg += "and *no* 'setup\soperation\sdidn't\scomplete' failure indicators" ;
                                $smsg += "=> appears to be an INTACT setup pass (pending following watermark testing)." ;
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 }
                                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                            } ; ; 
                        }else{
                            $smsg = "MISSING:'End of Setup' line! Possible Setup crash/incomplete!" ;
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            $ResultSummary.isServerValid = $false ; 
                            $ResultSummary.isFailedInstall = $true ; 
                        } ; 
                    };
                } ;
                # test registry for setup role watermarks
                if(gcm test-xopExchangeInstallWatermarkTDO){
                    $smsg = "Running test-xopExchangeInstallWatermarkTDO for incomplete setup roles..." ;
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    if($ResultSummary.WatermarkTest = test-xopExchangeInstallWatermarkTDO){
                        $smsg = "test-xopExchangeInstallWatermarkTDO: FOUND INSTALL WATERMARKS! w`n$(($ResultSummary.WatermarkTest|out-string).trim())" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } else {
                        $smsg = "test-xopExchangeInstallWatermarkTDO No Watermark values found in `$RegistryPath" ;                    
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        $ResultSummary.isServerValid = $true ; 
                    } ;
                } ;  
            } # if-E $InstallPhase
        }  # PROC-E
        END {
            $smsg = "Returning invoke-Exchange15SetupFailPostflight() summary to pipeline" ;
            $smsg += "`n$(($ResultSummary|out-string).trim())" ; 
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            [pscustomobject]$ResultSummary | write-output 
        } ;  # END-E
    }
#endregion INVOKE_EXCHANGE15SETUPFAILPOSTFLIGHT ; #*------^ END FUNCTION invoke-Exchange15SetupFailPostflight  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNnskYxIY6SY5EazaUtI1iMhi
# 8UagggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQtqD2F
# LB4a5eX3eLmkMnwjIIu0zDANBgkqhkiG9w0BAQEFAASBgFJ32wDg5gfLc3uezokE
# y+/EyqeZDP1MJSS625anWEGRgfhTDhLCvX/5XaQpYiWgyaa/ZBgaz9TIYsf+R4Xf
# LHugx+WkYHBqx3Pz/Ip90trVKPbtA0VZCwRWO+hsLjYTIpBWXdCI4VzG8c2lvBRB
# My8hPyjUjcHevHuo1MzNYRh/
# SIG # End signature block
