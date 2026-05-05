#region START_LOG ; #*------v FUNCTION Start-Log v------
function Start-Log {
        <#
            .SYNOPSIS
            Start-Log.ps1 - Configure base settings for use of write-Log() logging
            .NOTES

            REVISIONS
            * 3:19 PM 5/30/2025 switch -whatif:$true -> no default also revise calls to use: whatif:$($whatifpreference); pulled forced -verbose from trailing w-v
            ep
            .PARAMETER  Path
            Path to target script (defaults to $PSCommandPath)
            .PARAMETER Tag
            Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]
            .PARAMETER NoTimeStamp
            Flag that suppresses the trailing timestamp value from the generated filenames[-NoTimestamp]
            .PARAMETER TagFirst
            Flag that leads the returned filename with the Tag parameter value[-TagFirst]
            .PARAMETER ShowDebug
            Switch to display Debugging messages [-ShowDebug]
            .PARAMETER whatIf
            Whatif Flag (pass in the `$whatifpreference) [-whatIf]

            #>
        ###Requires -Modules verb-IO, verb-Text
        [CmdletBinding()]
        PARAM(
            [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to target script (defaults to `$PSCommandPath) [-Path .\path-to\script.ps1]")]
            $Path,
            [Parameter(HelpMessage = "Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]")]
            [string]$Tag,
            [Parameter(HelpMessage = "Flag that suppresses the trailing timestamp value from the generated filenames[-NoTimestamp]")]
            [switch] $NoTimeStamp,
            [Parameter(HelpMessage = "Flag that leads the returned filename with the Tag parameter value[-TagFirst]")]
            [switch] $TagFirst,
            [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
            [switch] $showDebug,
            [Parameter(HelpMessage = "Whatif Flag (pass in the `$whatifpreference) [-whatIf]")]
            [switch] $whatIf
        ) ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $transcript = join-path -path (Split-Path -parent $Path) -ChildPath "logs" ;
        if (!(test-path -path $transcript)) { "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
        if ($Tag) {
            if ((gci function:Remove-StringDiacritic -ea 0)) { $Tag = Remove-StringDiacritic -String $Tag } else { write-host "(missing:verb-text\Remove-StringDiacritic, skipping)"; }  # verb-text ;
            if ((gci function:Remove-StringLatinCharacters -ea 0)) { $Tag = Remove-StringLatinCharacters -String $Tag } else { write-host "(missing:verb-textRemove-StringLatinCharacters, skipping)"; } # verb-text
            if ((gci function:Remove-InvalidFileNameChars -ea 0)) { $Tag = Remove-InvalidFileNameChars -Name $Tag } else { write-host "(missing:verb-textRemove-InvalidFileNameChars, skipping)"; }; # verb-io, (inbound Path is assumed to be filesystem safe)
            if ($TagFirst) {
                $smsg = "(-TagFirst:Building filenames with leading -Tag value)" ;
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
                $transcript = join-path -path $transcript -childpath "$($Tag)-$([system.io.path]::GetFilenameWithoutExtension($Path))" ;
                #$transcript = "$($Tag)-$($transcript)" ;
            } else {
                $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ;
                $transcript += "-$($Tag)" ;
            } ;
        } else {
            $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ;
        };
        $transcript += "-Transcript-BATCH"
        if (!$NoTimeStamp) { $transcript += "-$(get-date -format 'yyyyMMdd-HHmmtt')" } ;
        $transcript += "-trans-log.txt"  ;
        # add log file variant as target of Write-Log:
        $logfile = $transcript.replace("-Transcript", "-LOG").replace("-trans-log", "-log")
        # revise for -whatif-less shouldprocess: leverage $whatifpreference (ispresent == $true)
        if (((get-variable whatif -ea 0) -AND ($whatif.IsPresent)) -OR ($whatifpreference.IsPresent)) {
            $logfile = $logfile.replace("-BATCH", "-BATCH-WHATIF") ;
            $transcript = $transcript.replace("-BATCH", "-BATCH-WHATIF") ;
        } else {
            $logfile = $logfile.replace("-BATCH", "-BATCH-EXEC") ;
            $transcript = $transcript.replace("-BATCH", "-BATCH-EXEC") ;
        } ;
        $logging = $True ;

        if ($host.version.major -ge 3) {
            $hshRet = [ordered]@{Dummy = $null ; } ;
        } else {
            # psv2 Ordered obj (can't use with new-object -properites)
            $hshRet = New-Object Collections.Specialized.OrderedDictionary ;
            # or use an UN-ORDERED psv2 hash: $Hash=@{ Dummy = $null ; } ;
        } ;
        If ($hshRet.Contains("Dummy")) { $hshRet.remove("Dummy") } ;
        $hshRet.add('logging', $logging) ;
        $hshRet.add('logfile', $logfile);
        $hshRet.add('transcript', $transcript) ;
        if ($showdebug -OR $verbose) {
            # retaining historical $showDebug support, even tho' not generally used now.
            $smsg = "$(($hshRet|out-string).trim())" ; ;
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
        } ;
        Write-Output $hshRet ;
    }
#endregion START_LOG ; #*------^ END FUNCTION Start-Log  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbwRmsE9ORPPnoHcta84ah8g7
# VumgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTM2YYd
# zqgslWDZkfQdEE+p7kf79jANBgkqhkiG9w0BAQEFAASBgI0S0qAfzF+XP3yNFGBz
# XfaJj/cKgAkc2hPvbftwJRf/Z8apZymMgU1rrDadt5TjA/RtW+KM2+sL6RqKtTPS
# AFtjstm2Sa/KoNMjbuR+TWHRGtPBxZVcL3YAm1hZLO/g1qsTCi3QK5/ylc7FCSF1
# VFkM2qazYn3+fOgL5E/FwavA
# SIG # End signature block
