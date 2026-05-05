#region ENABLE_WINDOWSDEFENDEREXCLUSIONSTDO ; #*------v FUNCTION Enable-WindowsDefenderExclusionsTDO v------
Function Enable-WindowsDefenderExclusionsTDO {
            <# .NOTES
            REVISIONS
            * 4:52 PM 10/6/2025 TTC: add cmdletbinding, param & alias, append TDO to name; added non-$State support: elseif's through $TargetPath when $State['TargetPath'] missing
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            #>
            [CmdletBinding()]
            [Alias('Enable-WindowsDefenderExclusions')]
            PARAM()
            If ( Get-Command -Name Add-MpPreference -ErrorAction SilentlyContinue) {
                $SystemRoot = "$Env:SystemRoot"
                $SystemDrive = "$Env:SystemDrive"

                $smsg = "Configuring Windows Defender folder exclusions"
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
                if($State -and $State['InstallPath']){
                    $InstallFolder = $State['TargetPath']
                }elseif($TargetPath){
                    $InstallFolder = $TargetPath ; 
                } Else {
                    # TargetPath not specified, using default location
                    $InstallFolder = 'C:\Program Files\Microsoft\Exchange Server\V15'
                }

                $Locations = @(
                    "$SystemRoot|Cluster",
                    "$InstallFolder|ClientAccess\OAB,FIP-FS,GroupMetrics,Logging,Mailbox",
                    "$InstallFolder\TransportRoles\Data|IpFilter,Queue,SenderReputation,Temp",
                    "$InstallFolder\TransportRoles|Logs,Pickup,Replay",
                    "$InstallFolder\UnifiedMessaging|Grammars,Prompts,Temp,VoiceMail",
                    "$InstallFolder|Working\OleConverter",
                    "$SystemDrive\InetPub\Temp|IIS Temporary Compressed Files",
                    "$SystemDrive|Temp\OICE_*"
                )

                ForEach ( $Location in $Locations) {
                    $Location
                    $Parts = $Location -split '\|'
                    $Items = $Parts[1] -split ','
                    ForEach ( $Item in $Items) {
                        $ExcludeLocation = Join-Path -Path $Parts[0] -ChildPath $Item
                        $smsg = "WindowsDefender: Excluding location $ExcludeLocation"
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                        TRY {
                            Add-MpPreference -ExclusionPath $ExcludeLocation -ErrorAction SilentlyContinue
                        } CATCH {
                            $smsg = "$_.Exception.Message"
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;

                        }
                    }
                }

                $smsg = "Configuring Windows Defender exclusions: NodeRunner process"
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
                $Processes = @(
                    "$InstallFolder\Bin|ComplianceAuditService.exe,Microsoft.Exchange.Directory.TopologyService.exe,Microsoft.Exchange.EdgeSyncSvc.exe,Microsoft.Exchange.Notifications.Broker.exe,Microsoft.Exchange.ProtectedServiceHost.exe,Microsoft.Exchange.RPCClientAccess.Service.exe,Microsoft.Exchange.Search.Service.exe,Microsoft.Exchange.Store.Service.exe,Microsoft.Exchange.Store.Worker.exe,MSExchangeCompliance.exe,MSExchangeDagMgmt.exe,MSExchangeDelivery.exe,MSExchangeFrontendTransport.exe,MSExchangeMailboxAssistants.exe,MSExchangeMailboxReplication.exe,MSExchangeRepl.exe,MSExchangeSubmission.exe,MSExchangeThrottling.exe,OleConverter.exe,UmService.exe,UmWorkerProcess.exe,wsbexchange.exe,EdgeTransport.exe,Microsoft.Exchange.AntispamUpdateSvc.exe,Microsoft.Exchange.Diagnostics.Service.exe,Microsoft.Exchange.Servicehost.exe,MSExchangeHMHost.exe,MSExchangeHMWorker.exe,MSExchangeTransport.exe,MSExchangeTransportLogSearch.exe",
                    "$InstallFolder\FIP-FS\Bin|fms.exe,ScanEngineTest.exe,ScanningProcess.exe,UpdateService.exe",
                    "$InstallFolder|Bin\Search\Ceres|HostController\HostControllerService.exe,Runtime\1.0\Noderunner.exe,ParserServer\ParserServer.exe",
                    "$InstallFolder|FrontEnd\PopImap|Microsoft.Exchange.Imap4.exe,Microsoft.Exchange.Pop3.exe",
                    "$InstallFolder|ClientAccess\PopImap\Microsoft.Exchange.Imap4service.exe,Microsoft.Exchange.Pop3service.exe",
                    "$InstallFolder|FrontEnd\CallRouter|Microsoft.Exchange.UM.CallRouter.exe",
                    "$InstallFolder|TransportRoles\agents\Hygiene\Microsoft.Exchange.ContentFilter.Wrapper.exe"
                )

                ForEach ( $Process in $Processes) {
                    $Parts = $Process -split '\|'
                    $Items = $Parts[1] -split ','
                    ForEach ( $Item in $Items) {
                        $ExcludeProcess = Join-Path -Path $Parts[0] -ChildPath $Item
                        $smsg = "WindowsDefender: Excluding process $ExcludeProcess"
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                        TRY {
                            Add-MpPreference -ExclusionProcess $ExcludeProcess -ErrorAction SilentlyContinue
                        } CATCH {
                            $smsg = "$_.Exception.Message"
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        }
                    }
                }

                $Extensions = 'dsc', 'txt', 'cfg', 'grxml', 'lzx', 'config', 'chk', 'edb', 'jfm', 'jrs', 'log', 'que'
                ForEach ( $Extension in $Extensions) {
                    $ExcludeExtension = '.{0}' -f $Extension
                    $smsg = "WindowsDefender: Excluding extension $ExcludeExtension"
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                    TRY {
                        Add-MpPreference -ExclusionExtension $ExcludeExtension -ErrorAction SilentlyContinue
                    } CATCH {
                        $smsg = "$_.Exception.Message"
                    }
                }
            } Else {
                $smsg = "Windows Defender not installed"
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
            }
        }
#endregion ENABLE_WINDOWSDEFENDEREXCLUSIONSTDO ; #*------^ END FUNCTION Enable-WindowsDefenderExclusionsTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUageffOHktVA/8NCwmov1+dv/
# Z4mgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRl5XjS
# yh3uqkzxRmoCuvIuzEVUvDANBgkqhkiG9w0BAQEFAASBgEwkcTrSsnouydi61xQS
# zUVhSYcnCKMEVyC+sC8RYzGfRxi8F5+eMcV9tIJmK3WidyvDgPSl5/9uK7Db63DK
# i4YgFZvizZqIva2NXStZVbaDQqorBtcwVGr3NM1IZeEz6rUA3rFiN5m2YEaq4GNS
# Vh0z6e9B7ZsdU0ArTg43DtSc
# SIG # End signature block
