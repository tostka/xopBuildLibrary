# test-xopExchangeInstallWatermarkTDO.ps1


#region TEST_XOPEXCHANGEINSTALLWATERMARKTDO ; #*------v test-xopExchangeInstallWatermarkTDO v------
function test-xopExchangeInstallWatermarkTDO {
        <#
        .SYNOPSIS
        test-xopExchangeInstallWatermarkTDO - Test local machine's HKLM:\SOFTWARE\Microsoft\ExchangeServer\v* registry sub-keys for Watermark values (a Watermark value indicates failed/incomplete install stage)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250713-0236PM
        FileName    : test-xopExchangeInstallWatermarkTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 2:36 PM 7/13/2025 init;
        .DESCRIPTION
        test-xopExchangeInstallWatermarkTDO - Test local machine's HKLM:\SOFTWARE\Microsoft\ExchangeServer\v* registry sub-keys for Watermark values (a Watermark value indicates failed/incomplete install stage)

        Tests HKLM:\SOFTWARE\Microsoft\ExchangeServer\v* subkeys -matching (AdminTools|ClientAccessRole|UnifiedMessagingRole|MailboxRole|FrontendTransportRole|CafeRole|EdgeTransportRole)
        for presense of a 'Watermark' value. Watermarks are set during install phases, and should be auto-removed as the stage completes.
        Their presense after an install/patch applicacation indicates an issue with the specified install phase.
        This is generally addressed by re-running the install/patch, specifying the specific role that failed/has a Watermark subkey.

        E.g. for the MailboxRole, rerun the prior commandline, with /roles: limited to the Watermark'd role names:

        CMD> setup.exe /mode:install /roles:Mailbox /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /DoNotStartTransport /InstallWindowsComponents /MdbName:MDB1 /DBFilePath:"F:\LYNMS6400\MDB1\DB\MDB1.edb" /LogFolderPath:"F:\LYNMS6400\MDB1\Log" /TargetDir:"D:\Program Files\Microsoft\Exchange Server\V15"

        This function essentially emulates the commandline registry check:
        CMD> Reg.exe query HKLM\SOFTWARE\Microsoft\ExchangeServer\v15 /s /v Watermark

        Which would return a Registry Watermark in the format:

            HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\v15\MailboxRole
            Watermark    REG_SZ    SystemAttendantDependent___1DEE95834DBA48F2BB211C2FB6765A5A

        .INPUTS
        None, no piped input.
        .OUTPUTS
        Returns matched watermark keys to pipeline
        .EXAMPLE
        PS> $WatermrkTest = test-xopExchangeInstallWatermarkTDO ;
        PS> if($WatermrkTest){;
        PS>     write-warning $WatermrkTest ; 
        PS> }

            Found value 'Watermark' in key 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\v15\MailboxRole':

        Typical Exchange 2016 MailboxRole install issue return information
        .LINK
        https://github.com/tostka/verb-ex2010
        #>
        [CmdletBinding()]
        ##[alias('ALIAS','ALIAS2')]
        PARAM() ;
        BEGIN {
            $RegistryPath = "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v*" ;
            $rgxRoleSuBkEYS = '(AdminTools|ClientAccessRole|UnifiedMessagingRole|MailboxRole|FrontendTransportRole|CafeRole|EdgeTransportRole)$' ;
            $ValueNameToCheck = "Watermark" ;
        }
        PROCESS {
            $hits = Get-ChildItem -Path $RegistryPath -Recurse -ErrorAction SilentlyContinue | ? { $_.PSIsContainer } | ? { $_.PSChildName -match $rgxRoleSuBkEYS } | ForEach-Object {
                TRY {
                    $RegValue = Get-ItemProperty -LiteralPath $_.PSPath -Name $ValueNameToCheck -ErrorAction Stop ;
                    if ($RegValue) {
                        #"Found value '$ValueNameToCheck' in key '$($_.PSPath)'." | write-output  ;
                        "Found value '$ValueNameToCheck' in key '$($_.PSPath)': $($RegValue.$ValueNameToCheck)" | write-output  ;
                    } ;
                } CATCH {} ;
            } ; # loop-E
        }
        END {
            if ($hits) {
                $smsg = "REGISTRY HITS: VALUE:$($ValueNameToCheck) -Recurse key:`n$($RegistryPath)`nfor: `$_.ItemProperty -match $($rgxRoleSuBkEYS):" ;
                $smsg += "`n`n$(($hits|out-string).trim())`n`n(returned to pipeline)" ;
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            } else {
                $smsg = "*NO* registry hits:VALUE:$($ValueNameToCheck) -Recurse key:`n$($RegistryPath)`nfor: `$_.ItemProperty -match $($rgxRoleSuBkEYS):" ;
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            } ;
        }
    }
#endregion TEST_XOPEXCHANGEINSTALLWATERMARKTDO ; #*------^ END test-xopExchangeInstallWatermarkTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtPO+9+FDSH4eVu3LpxZY545E
# ZQygggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRf4X3G
# RbXF8wbhhkgNPibkHvXtFDANBgkqhkiG9w0BAQEFAASBgEClYNnx5vSa9FoWovj1
# X2qYZHkQXe5sYnItrsAj4mFMADhssbDgqfvH6yH7No+G7ngwPF4ua2AYsVWjrawG
# EjRlqQS/89RuScGyw78xVm9rIS6ZlMNppnbnrIWosWd2ST6QiaPqktvNwaucE90t
# yk3AETlwJ5Yr2t48v9wHINEh
# SIG # End signature block
