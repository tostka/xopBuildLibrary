#region WRITE_MYOUTPUT ; #*------v FUNCTION Write-MyOutput v------
Function Write-MyOutput {
            <#
            .NOTES
            REVISION
            # 4:35 PM 8/11/2025 also fixed gv State test ;  
            # 2:17 PM 12/16/2025 Write-MyOutput Write-MyWarning  Write-MyOutput Write-MyWarning Write-MyVerbose:  made adv Func, wasn't detecting verbose -Verbose:($VerbosePreference -eq 'Continue')
                added CBH
            #>
            [CmdletBinding()]
            Param($Text)
            # version that splices together write-MyOutput with wlt fall back
            if( (gv State -ea 0) -AND ($State['TranscriptFile'])){
                #Write-Output $Text
                # NO! THIS BLOWS THE BUFFER ON FUNCTION RETURNS! WRITE-HOST THE GD THING! wmw doesn't dump to pipe; neither does wmE; ; or wmV, wmOutput is the only one that blows all text into the pipeline
                write-host $Text ; 
                $Location= Split-Path $State['TranscriptFile'] -Parent
                If( Test-Path $Location) {
                    Write-Output "$(Get-Date -Format u): $Text" | Out-File $State['TranscriptFile'] -Append -ErrorAction SilentlyContinue
                }
            } else {
                $smsg = $Text ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
        }
#endregion WRITE_MYOUTPUT ; #*------^ END FUNCTION Write-MyOutput  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVTVRE66pwLhZzZF41jEI2F0m
# F8CgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRjal+H
# CYahHepnLyi5GlPaIfsNazANBgkqhkiG9w0BAQEFAASBgDwWPH1vZHXI0GhxpRjm
# BPh6fOiE1avTISPB+FGx6lidop5oflH1cXxUo//L0iWJDaEk+8BHG976d8yw12wd
# X8QCMcRLs5s2+4hi4Ylnuvv6pbGV/zINmCes+OGMwJCHeQ+EjyZWRDiOpILGLPUV
# ZqFAuIS11q6L9FZ8hwAfyP5A
# SIG # End signature block
