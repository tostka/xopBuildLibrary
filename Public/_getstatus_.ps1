#region _GETSTATUS_ ; #*------v FUNCTION _getstatus_ v------
function _getstatus_ ($status, $chain, $cert){
                    # add a returnable output object
                    if($host.version.major -ge 3){$oReport=[ordered]@{Dummy = $null ;} }
                    else {$oReport=@{Dummy = $null ;}} ;
                    If($oReport.Contains("Dummy")){$oReport.remove("Dummy")} ;
                    $oReport.add('Subject',$cert.Subject); 
                    $oReport.add('Issuer',$cert.Issuer); 
                    $oReport.add('NotBefore',$cert.NotBefore); 
                    $oReport.add('NotAfter',$cert.NotAfter);
                    $oReport.add('Thumbprint',$cert.Thumbprint); 
                    $oReport.add('Usage',$cert.EnhancedKeyUsageList.FriendlyName) ; 
                    $oReport.add('isSelfSigned',$false) ; 
                    $oReport.add('Status',$status); 
                    $oReport.add('Valid',$false); 
                    if($cert.Issuer -eq $cert.Subject){
                        $oReport.SelfSigned = $true ;
                        $smsg = "NOTE⚠️:Current certificate $($cert.SerialNumber) APPEARS TO BE *SELF-SIGNED* (SUBJECT==ISSUER)" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                    } ; 
                    # Return the list of certificates in the chain (the root will be the last one)
                    $oReport.add('TrustChain',($chain.ChainElements | ForEach-Object {$_.Certificate})) ; 
                    $smsg = "Certificate Trust Chain`n$(($chain.ChainElements | ForEach-Object {$_.Certificate}|out-string).trim())" ; 
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                    if ($status) {
                        $smsg = "Current certificate $($cert.SerialNumber) chain and revocation status is valid" ; 
                        if($CRLMode -eq 'NoCheck'){
                            $smsg += "`n(NOTE:-CRLMode:'NoCheck', no Certificate Revocation Check performed)" ; 
                        } ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        $smsg = "" ;
                        $oReport.valid = $true ; 
                    } else {
                        $smsg = "Current certificate $($cert.SerialNumber) chain is invalid due of the following errors:" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        $chain.ChainStatus | foreach-object{Write-Host $_.StatusInformation.trim() -ForegroundColor Red} ; 
                        $oReport.valid = $false ; 
                    } ; 
                    New-Object PSObject -Property $oReport | write-output ;
                }
#endregion _GETSTATUS_ ; #*------^ END FUNCTION _getstatus_  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCiiNvxb9LnY6qjJFoHnKDzjZ
# aBygggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSZGv9w
# jsqLHf2x9JsZpPSVg+BsQDANBgkqhkiG9w0BAQEFAASBgBkWjnb9qOKwwFAQaa/s
# 85lOUFChc7/VpKbNhBmfnr94fajzVx4/Qzk9/qYvh3mfIIZDZqRI4G2QdRPvDr5i
# Eqzkzk8siha8P2uYT8wXHb3OEMUpAjdC2kIKs+QmWpOJNGjpUjesvD4mtZjRiDD+
# 7KYaKJc67fL9lczBLs1yc6a5
# SIG # End signature block
