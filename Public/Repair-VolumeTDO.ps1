# Repair-VolumeTDO.ps1


#region REPAIR_VOLUMETDO ; #*------v Repair-VolumeTDO v------
function Repair-VolumeTDO{
        <#
        .SYNOPSIS
        Repair-VolumeTDO.ps1 - Wrapper for repair-volume/checkdsk
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-
        FileName    : Repair-VolumeTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-IO
        Tags        : Powershell
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 11:10 AM 7/30/2025 init, sub func for test-xop15LocalInstallDrivesTDO
        .DESCRIPTION
        Repair-VolumeTDO.ps1 - Wrapper for repair-volume/checkdsk
        .PARAMETER  DriveLetter
        Drive Letter to be checked[-DriveLetter D]]
        .INPUTS
        None. Does not accepted piped input.(.NET types, can add description)
        .OUTPUTS
        System.Integer OperationalStatus [0|1]
        .EXAMPLE
        PS> $tVols = get-volume ; 
        PS> $driveSummary = [ordered]@{
        PS>     Drives = @() ;
        PS>     DriveHealthIssues = $null ;
        PS>     ValidAll = $false ;
        PS> } ; 
        PS> $BadDrives = $tVols | ?{$_.DriveType  -eq 'Fixed' -AND ($_.HealthStatus -ne 'Healthy' -OR $_.OperationalStatus -ne 'OK')} ; 
        PS> $BadDrives | foreach-object{
        PS>     if($_.HealthStatus -ne 'Healthy'){
        PS>         $smsg = "drive HealthStatus: $($_.DriveLetter): $($_.HealthStatus)!" ;
        PS>         $driveSummary.DriveHealthIssues += @($smsg)
        PS>         write-warning $smsg ; 
        PS>     }else{Write-Host @whPASS} ;
        PS>     if($_.OperationalStatus -ne 'OK'){
        PS>         write-host @whFAIL ;
        PS>         $smsg = "SysVol drive OperationalStatus: $($_.DriveLetter): $($_.OperationalStatus)!" ;
        PS>         $driveSummary.DriveHealthIssues += @($smsg)
        PS>         write-warning $smsg ; 
        PS>     }else{Write-Host @whPASS} ;
        PS> } ;
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [CmdletBinding()]
        PARAM(
            [Parameter(Mandatory = $true, HelpMessage = "Drive Letter to be checked[-DriveLetter D]]")]
                [string]$DriveLetter
        )
        BEGIN{
            $rgxDriveLetter = '([A-Za-z])\:' ; 
            if($DriveLetter -match $rgxDriveLetter){                
                $DriveLetter = [regex]::match('c:',$rgxDriveLetter).groups[1] ; 
            }
        }
        PROCESS{
            foreach($bd in $DriveLetter){
                $bd = get-volume -driveletter $bd -ea Stop ; 
                $resRvol = repair-volume -DriveLetter $bd.driveletter -scan ; 
                if($resRvol -eq 'NoErrorsFound'){
                    $smsg = "Result:repair-volume -DriveLetter $($bd.driveletter) -scan:$($resRvol)" ; 
                    $smsg = "=> Moving on to Chkdsk" ; 
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                    #chkdsk D: /f
                    $resChkD = Invoke-DriveChkDskTDO -DriveLetter $bd.driveletter ; 
                    if($resChkD -eq 0){
                        $smsg = "=> Chkdsk: clean exit (status:0)" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                    } else {
                        $smsg = "Chkdsk non-0 results:$($resChkD)" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } ;                     
                }else {
                    $resChkD = Invoke-DriveChkDskTDO -DriveLetter $bd.driveletter ; 
                    if($resChkD -eq 0){
                        $smsg = "=> Chkdsk: clean exit (status:0)" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                    } else {
                        $smsg = "Chkdsk non-0 results:$($resChkD)" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } ;            
                } ; 
                switch ((get-volume -DriveLetter $bd.driveletter).OperationalStatus){
                    'OK'{
                        $smsg = "CLEAR results: get-volume -DriveLetter $($bd.driveletter).OperationalStatus: OK" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        0 | write-output                             
                    }
                    default {
                        $smsg = "NON-CLEAR results: get-volume -DriveLetter $($bd.driveletter).OperationalStatus: " ;                                 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;  
                        1 | WRITE-OUTPUT ; 
                    }
                } ;                
            } ; 
        } # PROC-E
    }
#endregion REPAIR_VOLUMETDO ; #*------^ END Repair-VolumeTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBp/GiGwgz3julFIdR79U6cbL
# coCgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQrbfqP
# u1VXBPizFYcvAUt4exi/DTANBgkqhkiG9w0BAQEFAASBgAyzrQL4wX9iwtMIAJag
# omYpD1lo99rmJQk/XWB/eTbMqq8jdpH59MjsI1aK/JuFgPJSmdvFpnrdv4eWZXnS
# aWMsIoAZX/RI1NCLI0TB3I3nv1gee4gXsFDsXl46qMbSCeVW6TTYfAyfSHF26Y/3
# N4z6f9LDQbk8wT+eK7SZa1PM
# SIG # End signature block
