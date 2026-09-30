# Get-ex16ExchangeServerTDO.ps1


#region GET_EX16EXCHANGESERVERTDO ; #*------v Get-ex16ExchangeServerTDO v------
function Get-ex16ExchangeServerTDO{        
        <#
        .SYNOPSIS
        Checks an Exchange 2016 servers identity
        .NOTES
        Version     : 0.0.1
        Author      : PietroCiaccio
        Website     : https://github.com/PietroCiaccio/
        Twitter     : 
        CreatedDate : 2025-03-19
        FileName    : Get-ex16ExchangeServerTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-XXX
        Tags        : Powershell
        AddedCredit : Todd Kadrie
        AddedWebsite: http://www.toddomation.com
        AddedTwitter: @tostka / http://twitter.com/tostka
        REVISIONS
        * 2:35 PM 2/17/2026 add missing base alias
        * 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) ; ADD: being{} & connext-xop...() call (dep)
        * 9:10 AM 7/24/2025 ren: Get-EPExchangeServer -> Get-ex16ExchangeServerTDO (alias orig name) ; 
        updated return obj, now includes raw component status and a xxxFmt formated output (visible in dumps wo manual expansion); added ServerWideOffline that can be used as central check (assuming it can't be set if other components are active)
        * 4:30 PM 7/23/2025 rejiggered to output a customobject with more useful sub-properites, and easier to review info.
        * 12:52 PM 3/27/2025 TK: added aggregated Tests summary, returned to pipeline (to evaluate status, for follow-on processing).
        * 8/12/2020 Pietro Ciaccio's PSG-posted ExchangePowerShell module, v0.11.0
        .DESCRIPTION
        Checks an Exchange 2016 servers identity
        .PARAMETER Identity
        Specify the identity of the computer. This can be piped from Get-ExchangeServer or specified explicitly using a string.
        .PARAMETER KeyComponents
        Key Components that are critical for 'Down' status of a server - to prevent CAS access or mail-handling (defaults to 'ServerWideOffline|HubTransport|FrontendTransport|AutoDiscoverProxy|ActiveSyncProxy|EcpProxy|EwsProxy|ImapProxy|OabProxy|OwaProxy|PopProxy|RpsProxy|RpcProxy|MapiProxy|EdgeTransport|MailboxDeliveryProxy')
        .OUTPUTS
        Returns a PSCustomObject to pipeline, summarizing status of tested components.
        .EXAMPLE
        $testResults = Get-EPMaintenanceMode -identity SERVER1 ; 
        #>
        [cmdletbinding()]
        [Alias('Get-EPExchangeServer','Get-ex16ExchangeServer')]
        PARAM (
            [Parameter(mandatory=$true,valuefrompipelinebypropertyname=$true)][PSCustomObject]$Identity
        )
        BEGIN{            
            #region CONNECT_XOPLOCAL ; #*------v connect-XopLocal v------
            $tcmdlet = 'get-ExchangeServer' ;
            $cmd = $null; $cmd = get-command $tcmdlet -erroraction 0 ;
            if(-not $cmd){
                if($xopconn = connect-XopLocalManagementShell){
                    if($ExPSS = get-pssession | ? { $_.ComputerName -match "^$($env:computername)" -AND $_.ConfigurationName -eq 'Microsoft.Exchange' } | sort id -Descending | select -first 1 ){
                        TRY{
                            $cmd = $null; $cmd = get-command $tcmdlet -erroraction 0 ;
                            if(-not $cmd){
                                $smsg = "Missing $($cmdlet): re-importing PSSession..." ;
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                                $ExIPSS = Import-PSSession $ExPSS -allowclobber -ea STOP ;
                            } ;
                            $cmd = $null; $cmd = get-command 'Get-OrganizationConfig' -erroraction stop ;
                            $smsg = "Connected to: $($expss.computername)" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        } CATCH {
                            $ErrTrapd=$Error[0] ;
                            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            BREAK ;
                        } ;
                    } ;
                } else {
                    $smsg = "NOT CONNECTED!"
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    BREAK ;
                } ;
            } ;
            #endregion CONNECT_XOPLOCAL ; #*------^ END connect-XopLocal ^------
        } # BEG-E
        PROCESS {
            # Validate Exchange Server
            if ($input) {
                if ($input.objectcategory.name -ne "ms-Exch-Exchange-Server"){
                    $smsg = "Unable to validate Exchange server identity."
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    throw $smsg
                } else {
                    $ExchangeServer = $null; $ExchangeServer = $input
                }
            }
            if (!($input)) {
                if ($identity.gettype().fullname -ne "System.String") {
                    $smsg = "Unable to use parameter 'Identity' of type '$($identity.gettype().fullname)'."
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    throw $smsg ; 
                } else {
                    TRY {
                        $ExchangeServer = $null; $ExchangeServer = Get-ExchangeServer -Identity $identity -erroraction stop
                    } CATCH {
                        $ErrTrapd=$Error[0] ;
                        $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        throw $smsg ;
                    }
                }
            }
            if ($ExchangeServer.Admindisplayversion.tostring() -notmatch "^version 15\." ) {
                $smsg = "Exchange version is not 15 for '$($ExchangeServer.identity)'. There may be issues."
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            }
            return $ExchangeServer
        }
    }
#endregion GET_EX16EXCHANGESERVERTDO ; #*------^ END Get-ex16ExchangeServerTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlT8ZmOcu/4NFfjMj9rjcWG6H
# a9KgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR+4mXv
# 0Wj6BznDPfh736TjW9C9QzANBgkqhkiG9w0BAQEFAASBgEKNdwXIcHaSAg6a7DTp
# 6rdRmCqAovzc8PDUgAcvYxZrnvmzIX7hP3nOsPVyERUFXtqmVxgHzsbHCiio2Uq7
# gqewGm5UEE+RYu+PSl473XLpBfZHs1h6soPh8nHpmlQnBPvIwGGzjt/DnvThHMp3
# kOojaJcS/tHykXeFA+hzg9mg
# SIG # End signature block
