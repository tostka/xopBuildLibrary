#region ENABLE_HIGHPERFORMANCEPOWERPLANTDO ; #*------v FUNCTION Enable-HighPerformancePowerPlanTDO v------
Function Enable-HighPerformancePowerPlanTDO {
            <# .NOTES
            REVISIONS
            * 9:10 AM 10/7/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
            * 4:55 PM 10/6/2025 add cmdletbinding, param & alias, append TDO to name; added non-$State support: elseif's through $TargetPath when
            Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
            #>
            [CmdletBinding()]
            [Alias('Enable-HighPerformancePowerPlan')]
            PARAM()    
            $smsg = "Configuring Power Plan"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $null = Start-Process -FilePath 'powercfg.exe' -ArgumentList ('/setactive', '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') -NoNewWindow -PassThru -Wait            
            if (get-command get-ciminstance -ea 0) {
                $CurrentPlan = get-ciminstance -Namespace root\cimv2\power -Class win32_PowerPlan | Where-Object { $_.IsActive }
            } else {
                $CurrentPlan = Get-WmiObject -Namespace root\cimv2\power -Class win32_PowerPlan | Where-Object { $_.IsActive }
            } ;
            $smsg = "Power Plan active: $($CurrentPlan.ElementName)"
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
        }
#endregion ENABLE_HIGHPERFORMANCEPOWERPLANTDO ; #*------^ END FUNCTION Enable-HighPerformancePowerPlanTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0mb0P7zFOL6+SeFIvdQ1isoR
# aUigggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSlj/Ix
# pRP6DMM3VpBsoHkabUr+lTANBgkqhkiG9w0BAQEFAASBgGxnGdBLVXfm6fMlMquX
# eEfUd2ogztWwWDoeg+zcTDgh9d+vh+VO6Wbz8WZL8fWfr2VgmJsPVBHPZVSjtJJf
# 3v4OBGNTgSXSEFqRuJyBNSTi5hQE8rIwavtZR8kqvaDDn3LcDMSFP/HUunPA/d4Z
# me17B3MhVGjGR4joy6k1AaM/
# SIG # End signature block
