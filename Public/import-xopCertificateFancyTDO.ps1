#region IMPORT_XOPCERTIFICATEFANCYTDO ; #*------v FUNCTION import-xopCertificateFancyTDO v------
function import-xopCertificateFancyTDO {
            <#
            .SYNOPSIS
            import-xopCertificateFancyTDO.ps1 - Import PFX file into Exchange onprem (fancier variant; based on old prod code)
            .NOTES
            Version     : 0.0.
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 20221005-0133PM
            FileName    : import-xopCertificateFancyTDO.ps1
            License     : MIT License
            Copyright   : (c) 2022 Todd Kadrie
            Github      : https://github.com/tostka/verb-ex2010
            Tags        : Powershell,Certificate,TrustChain,Import,Maintenance
            AddedCredit : REFERENCE
            AddedWebsite: URL
            AddedTwitter: URL
            REVISIONS
            * 2:21 PM 8/11/2025 flip default $whatif:$false!
            * 9:52 AM 7/24/2025 ren: import-xopCertificateTDO -> import-xopCertificateFancyTDO
            * 3:32 PM 7/13/2025 add: -Password, changed $pfxpw->$password;  ren: _import-ExCertPfxTDO -> import-xopCertificateTDO; it's been homogenized to support range of certs the underlying import-ExchangeCertificate supports ;
                add: -NoTranscription, supporess internal (if running pass for calling script already)
            # 10:04 AM 7/11/2025 syncing back latest functional from L650; updated xmpl to drop the obsolete NotAfter spec in the splat; ren import-ExCertPfxTBA.ps1 -> import-ExCertPfxTDO.ps1
            # 11:44 AM 10/26/2023: clearly prev updated: had origin used -notbefore to post-filter the after results,
            latest uses -passthru to capture updated cert thumbprint, which is used for actual post review targeting, -not after isn't needed anymore
            11:55 AM 11/7/2022 added desc
            .DESCRIPTION
            import-xopCertificatePfxTDO.ps1 - Import PFX file into Exchange onprem
            .PARAMETER  CertificatePath
            Path to Pfx file to be imported[-PfxPath c:\path-to\cert.pfx]
            .PARAMETER Password
            Securestring Password for PFX format certificates
            .PARAMETER ExVers
            Exchange version string (ExSE|Ex2019|Ex2016|Ex2013|Ex2010|Ex2007|Ex2003|Ex2000)[-ExVers Ex2016]
            .PARAMETER noTranscript
            Switch to suppress internal transcript (e.g. broad ongoing transcript running)[-noTranscript]
            .PARAMETER Change
            Change Number[-Change 123456]
            .PARAMETER Whatif
            Parameter to run a Test no-change pass [-Whatif switch]
            .INPUTS
            None. Does not accepted piped input.(.NET types, can add description)
            .OUTPUTS
            None. Returns no objects or output (.NET types)
            Transcribes to a log file.
            .EXAMPLE
            import-xopCertificateFancyTDO.ps1 -PfxPath 'c:\scripts\cert\SUB.DOMAIN.com (10-29-2023)-Sec-copy.pfx' -Change 'rfc77454' -verbose ;
            Non-splatted example
            .EXAMPLE
            PS> $pltIXP=@{
                    PfxPath='c:\scripts\cert\SUB.DOMAIN.com (10-29-2023)-Sec-copy.pfx' ;
                    Change='rfc77454' ;
                    verbose=$true;
                    whatif=$true;
                };
            PS> import-xopCertificateFancyTDO.ps1 @pltIXP ;
            Splatted example: Import specified pfx, using NotBefore and Change number, with -whatif & -verbose output
            .LINK
            https://github.org/tostka/powershellBB/
            #>
            [CmdletBinding()]
            [Alias('import-ExCertPfx', 'import-ExCertPfxTBA')]
            ##Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
            PARAM(
                [Parameter(Mandatory = $True, ValueFromPipeline = $true, HelpMessage = "Path to Pfx file to be imported[-PfxPath c:\path-to\cert.pfx]")]
                    [ValidateNotNullOrEmpty()]
                    [ValidateScript({ Test-Path $_ })]
                    $CertificatePath,
                [Parameter(Mandatory = $false, HelpMessage = "Securestring Password for PFX format certificates[-Password `$securestringpw")]
                    [System.Security.SecureString]$Password,
                [Parameter(Mandatory = $True, HelpMessage = "Exchange version string (ExSE|Ex2019|Ex2016|Ex2013|Ex2010|Ex2007|Ex2003|Ex2000)[-ExVers Ex2016]")]
                    [ValidateSet('ExSE', 'Ex2019', 'Ex2016', 'Ex2013', 'Ex2010', 'Ex2007', 'Ex2003', 'Ex2000')]
                    [string]$ExVers,
                [Parameter(ParameterSetName = 'EXCLUSIVENAME', HelpMessage = "Change Number[-Change 123456]")]
                    [string] $Change,
                [Parameter(HelpMessage = "Switch to suppress internal transcript (e.g. broad ongoing transcript running)[-noTranscript]")]
                    [switch] $noTranscript,
                [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
                    [switch] $whatif
            ) ;
            TRY {
                if (-not(gcm get-exchangecertificate -ea 0)) {
                    #$sName="Microsoft.Exchange.Management.PowerShell*" ;
                    #if (!(Get-PSSnapin | where {$_.Name -like $sName})) {Add-PSSnapin $sName -ea Stop} ;
                    # above doesn't work Ex16+; port in code from Connect-ExchangServerTDO()
                    write-host  "Loading LOCAL Exchange PowerShell Module..."
                    TRY {
                        # stock Ex enviro variables if missing
                        if ($ExInstall -eq $null -or $ExBin -eq $null) {
                            if (Test-Path 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v*\Setup') {
                                $Global:ExInstall = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ExchangeServer\v*\Setup).MsiInstallPath ;
                                $Global:ExBin = $Global:ExInstall + "\Bin"
                                $smsg = ("Set ExInstall: {0}" -f $Global:ExInstall)
                                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                } ;
                                $smsg = ("Set ExBin: {0}" -f $Global:ExBin)
                                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                } ;
                            } else {
                                $smsg = "Exchange Server Install Path not found in registry! (HKLM:\SOFTWARE\Microsoft\ExchangeServer\v*\Setup)" ;
                                write-warning $smsg ;
                                throw $smsg ;
                            } ;
                        } ;
                        if ((Test-Path 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v*\EdgeTransportRole')) {
                            # implement local snapins access on edge role: Only way to get access to EMS commands.
                            [xml]$PSSnapIns = Get-Content -Path "$env:ExchangeInstallPath\Bin\exshell.psc1" -ErrorAction Stop
                            ForEach ($PSSnapIn in $PSSnapIns.PSConsoleFile.PSSnapIns.PSSnapIn) {
                                write-verbose ("Trying to add PSSnapIn: {0}" -f $PSSnapIn.Name)
                                Add-PSSnapin -Name $PSSnapIn.Name -ErrorAction Stop
                            } ;
                            Import-Module $env:ExchangeInstallPath\bin\Exchange.ps1 -ErrorAction Stop ;
                            $passed = $true #We are just going to assume this passed.
                        } else {
                            Import-Module $env:ExchangeInstallPath\bin\RemoteExchange.ps1 -ErrorAction Stop
                            Connect-ExchangeServer -Auto -ClientApplication:ManagementShell
                            $passed = $true #We are just going to assume this passed.
                        }
                        if (-not(gcm get-exchangecertificate -ea 0)) {
                            $smsg = "UNABLE TO gcm get-exchangecertificate!" ;
                            WRITE-WARNING $smsg ;
                            throw $smsg ;
                        } else {

                        }
                    } CATCH {
                        $smsg = "Failed to Load Exchange PowerShell Module..." ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    }
                } ;
                if (-not $noTranscript) {
                    $transcript = "c:\scripts\logs\$($Change)-$($env:COMPUTERNAME)-ImportExCertPFX-$(get-date -format 'yyyyMMdd-HHmmtt')" ;
                    if (-not(test-path (split-path $transcript))) {
                        $smsg = "(creating missing $(split-path $transcript))" ;
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;

                        mkdir -path (split-path $transcript) -verbose ;
                    };
                    if ($whatif) {
                        $transcript += "-WHATIF" ;
                    } else {
                        $transcript += "-EXEC" ;
                    } ;
                    $transcript += "-log-trans.txt" ;
                    TRY { $stopresults = stop-transcript } CATCH {} ;
                    TRY {
                        $startresults = start-transcript $transcript ;
                        $smsg = $startresults ;
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;

                    } CATCH { write-warning "host doesn't support transcription" } ;
                } else {
                    $smsg = "(-NoTranscript: skipping internal transcription)" ;
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                }
                if ($CertificatePath = gci $CertificatePath) {
                    if ($CertificatePath.name.tolower() -match '\.pfx$' -and -not $Password) {
                        write-warning "Next dialog will prompt for PFX credential,`nfor:$($CertificatePath.name)`nenter anything ('dummy') for Username, it will not be used" ;
                        $Password = (get-credential -Credential dummy).password ;
                    } ;
                    $pltIpExCert = @{
                        #FileData=([Byte[]]$(Get-Content -Path $CertificatePath.fullname -Encoding byte -ReadCount 0 -erroraction 'STOP')) ;
                        #Password=$Password ;
                        erroraction = 'STOP' ;
                        whatif      = $($whatif) ;
                    } ;
                    if ($Password) {
                        $pltIpExCert.add('Password', $Password) ;
                    }
                    switch -regex ($ExVers) {
                        'Ex2010' {
                            $pltIpExCert.add('FileData', ([Byte[]]$(Get-Content -Path $CertificatePath.fullname -Encoding byte -ReadCount 0 -erroraction 'STOP'))) ;
                        }
                        'Ex2013' {
                            $pltIpExCert.add('FileName', $CertificatePath.fullname) ;
                        }
                        'ExSE|Ex2019|Ex2016' {
                            $pltIpExCert.add('FileData', ([System.IO.File]::ReadAllBytes($CertificatePath.fullname))) ;
                        }
                        default {
                            $smsg = "UNCONFIGURED `$ExVers:$($ExVers)!" ;
                            $smsg += "`nThis script has not been configured (yet) to support ImportExchangeCertificate syntax on the specified version" ;
                            write-warning $smsg ;
                            throw $smsg ;
                            break ;
                        }
                    }
                    $smsg = "Import-ExchangeCertificate  w`n$(($pltIpExCert|out-string).trim())" ;
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                    TRY{
                        $results = Import-ExchangeCertificate @pltIpExCert ;
                    } CATCH [InvalidOperationException]{
                        $ErrTrapd=$Error[0] ;
                        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                        $smsg += "`n$($ErrTrapd.Exception.Message)" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } CATCH {
                        $ErrTrapd=$Error[0] ;
                        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                        $smsg += "`n$($ErrTrapd.Exception.Message)" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } CATCH[$($ErrTrapd.Exception.GetType().FullName)]{" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } ; 
                    if(-not ($whatif) -and $results.Thumbprint){
                        if (-not $whatif -AND ($rout = Get-ExchangeCertificate -server $env:computername -thumb $results.Thumbprint)) {
                            $rout | select Subject, Services, not*, thumb*, friend* | write-output ;
                        } elseif (-not $whatif) {
                            $false | write-output ;
                        } else {
                            $smsg = "-whatif:$($whatif): skipped import/confirmation" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        } ;
                    }else{
                        $smsg = "Import-ExchangeCertificate RETURNED NO POPULATED THUMBPRINT!(BUG?)"
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        $false | write-output ;
                    }
                } else {
                    $smsg = "Unable to locate cert `$pfx!:$($CertificatePath)" ;
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    throw $smsg ;
                } ;
            } CATCH {
                $smsg = $_.Exception.Message ;
                write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;
                Continue ;
            } ;
            if (-not $noTranscript) {
                TRY {

                    $stopresults = stop-transcript
                    $smsg = $stopresults
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;


                } CATCH { write-warning "host doesn't support transcription" } ;
            } ;
        }
#endregion IMPORT_XOPCERTIFICATEFANCYTDO ; #*------^ END FUNCTION import-xopCertificateFancyTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJBGdqViYFDopb83UcYaWZGV3
# pr6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSs9xAK
# 1UmWv2A++qu/Ztw7nnq80jANBgkqhkiG9w0BAQEFAASBgBxXmdEfg1lVa2DVlpZS
# laqDwbp48cEzuYDEn0Hid2YcJVKkgFr2Xlx0kRudhtako8eHa2rytE7oe+eb/kwh
# aVy5RGisxAar+xusqCOnMwwdgPHWgcPhvqVJUvGWTEQAk87Z+1DaUWMp16LIrptM
# KKAt/XYOLym+paslZ6fi5zMW
# SIG # End signature block
