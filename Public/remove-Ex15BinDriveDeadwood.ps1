#region REMOVE_EX15BINDRIVEDEADWOOD ; #*------v FUNCTION remove-Ex15BinDriveDeadwood v------
function remove-Ex15BinDriveDeadwood {
        <#
        .SYNOPSIS
        remove-Ex15BinDriveDeadwood - Hunts down old CU installs and isos, and purges the content
        .NOTES
        Version     : 1.0.0
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2025-07-30
        FileName    : remove-Ex15BinDriveDeadwood.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,Storage,Maintenance,Exchange,Deadwood,Cleanup
        AddedCredit : REFERENCE
        AddedWebsite:	URL
        AddedTwitter:	URL
        REVISIONS
        * 2:07 PM 8/4/2025 conv to func, add to xopBuildLibrary.ps1
        * 4:10 PM 7/30/2025 init
        .DESCRIPTION
        remove-Ex15BinDriveDeadwood - Hunts down old CU installs and isos, and purges the content

        .PARAMETER Include
        Patch folder identifiers in the form of a get-childitem 'include' specification: Specifies an array of one or more string patterns to be matched as the cmdlet gets child items. Any matching item is included in the output. Enter a path element or pattern, such as `"*.txt"`. Wildcard characters are permitted. The Include parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the wildcard character specifies the contents of the `C:\Windows` directory.
        .PARAMETER Purge
        Switch to Purge, rather than Move obsolete content
        .EXAMPLE
        PS> RndTo2($tv.SizeRemaining/1GB)
        Demo use of the RndTo2 alias, which defaults places to 2 (v RndTo3, RndTo4)
        .EXAMPLE
        PS> remove-Ex15BinDriveDeadwood 5.1234,3

        Demo use of full function name, with position params for number and places
        .EXAMPLE
        PS> remove-Ex15BinDriveDeadwood -Purge
        Demo use of full function name, with -Purge switch
        .LINK
        https://github.com/tostka/PowershellBB
        #>
        [CmdletBinding()]
        #[Alias('')]
        PARAM(
            [Parameter(Mandatory = $false, HelpMessage = "Patch folder identifiers in the form of a get-childitem 'include' specification: Specifies an array of one or more string patterns to be matched as the cmdlet gets child items. Any matching item is included in the output. Enter a path element or pattern, such as `"*.txt`. Wildcard characters are permitted. The Include parameter is effective only when the command includes the contents of an item, such as `C:\Windows*`, where the wildcard character specifies the contents of the `C:\Windows` directory.")]
                [ValidateNotNullOrEmpty()]
                [string[]]$Include = @('E2016CU17-KB4556414','Ubuntu_Mono'),
            [Parameter(Mandatory = $false, HelpMessage = "Switch to Purge, rather than Move obsolete content")]
                [switch]$Purge
        );
        BEGIN{
            #$Include = 'E2016CU17-KB4556414' ;
            $AggRemovals = @() ;
        }
        PROCESS{
            if($binDriveLtr = (get-volume -FileSystemLabel 'binaries').driveletter ){
                if($deadFldrs = gci -path "$($binDriveLtr):\cab*" -include $Include -Recurse -Depth 3 -directory){
                    $deadFldrs | foreach-object {
                        TRY{
                            $df = $_ ;
                            $smsg = "Removing dead cab folder: $($_.FullName)" ;
                            if(-not $Purge){
                                $smsg =$smsg -replace 'Removing\s', 'Moving '
                            }
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            if(-not $Purge){
                                if(test-path r:\cab -PathType Container){
                                }else{
                                    new-item -Path 'r:\cab' -ItemType Directory -ErrorAction STOP | out-null ;
                                }
                                if(test-path r:\cab -PathType Container){
                                    $smsg = "Moving dead cab folder to r:\cab" ;
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    $df | move-item -Destination "r:\cab" -Force -Verbose -ErrorAction STOP;
                                    $AggRemovals += $df ; 
                                } else {
                                    $smsg = "r:\cab does not exist, creating it and moving dead cab folder there" ;
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                            } else {
                                $smsg = "Purging dead cab folder: $($_.FullName)" ;
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                $df | remove-item -Force -Recurse -Verbose -ErrorAction STOP ;
                                $AggRemovals += $df ; 
                            } ;
                        } CATCH {
                            $ErrTrapd=$Error[0] ;
                            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                        } ; 
                    } # loop-E
                } else {
                    $smsg = "No dead cab folders found in $($_):\cab" ;
                    if(get-command Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                }
            }else {
                $smsg = "Unable to resolve a Binaries Drive!" ;
                if(get-command Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
                throw $smsg ;
            } ;# if-E  BINDRIVE
        } ; # PROC-E
        END{
            if($AggRemovals){
                $smsg = "returning purged to pipeline:" ; 
                $smsg += "`n$(($AggRemovals | ft -a |out-string).trim())" ; 
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
                $AggRemovals | write-output ; 
            }else{
                $smsg = "No removable content found..." ;                 
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ; 
            } ; 
        }
    }
#endregion REMOVE_EX15BINDRIVEDEADWOOD ; #*------^ END FUNCTION remove-Ex15BinDriveDeadwood  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGRqNc6QPeyfylkpnd6SLEqM1
# P3agggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQbr3hA
# WymwM+n8sgH4NI/2vmwrhjANBgkqhkiG9w0BAQEFAASBgH2zCU0sbVYI5lPefv/p
# adlVeY7Qrare6M72VtjGF1cXnw7zYl9eUsUIvC5+Th0vICUiXwaJo36wTX5NUX70
# /oISkyhZH2qEpvY7Be2rFSWT7M2cOWAGcFFY9vZ7izp3+piJAHJxxvF+547BcuZi
# 5dUVeUplynfhznR50utNUu5F
# SIG # End signature block
