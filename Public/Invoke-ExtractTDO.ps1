#region INVOKE_EXTRACTTDO ; #*------v FUNCTION Invoke-ExtractTDO v------
Function Invoke-ExtractTDO {
            <#
            .SYNOPSIS
            Invoke-ExtractTDO - Given 1) an installable's downloaded source Url, 2) the matching downloaded installable FileName, and 3) the Path that the download should be findable within: This tests for a pre-downloaded Filename at the InstallPath specified, and if not found, downloads the specified URL (via Start-BitsTransfer), to the InstallPath\Filename. 
            .NOTES
            Version     : 0.0.1
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 2025-08-15
            FileName    : Invoke-ExtractTDO.ps1
            License     : (none asserted)
            Copyright   : (none asserted)
            Github      : https://github.com/tostka/verb-IO
            Tags        : Powershell,FileSystem,Backup,Development,Build,Staging
            AddedCredit :  Michel de Rooij / michel@eightwone.com
            AddedWebsite: https://eightwone.com / https://github.com/michelderooij/Install-Exchange15
            AddedTwitter: URL
            REVISIONS
            * 11:34 AM 8/15/2025 ren: Invoke-Extract -> Invoke-ExtractTDO and alias the orig name;  add: CBH, fleshed out Parameter specs into formal well specified block. Added variety of working examples, for reuse adding future patches/packages to the mix.
            * 821's posted copy w/in install-Exchange15.ps1: Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func
            .DESCRIPTION
            Invoke-ExtractTDO - Given 1) an installable's downloaded source Url, 2) the matching downloaded installable FileName, and 3) the Path that the download should be findable within: This tests for a pre-downloaded Filename at the InstallPath specified, and if not found, downloads the specified URL (via Start-BitsTransfer), to the InstallPath\Filename. 

            .INPUTS
            None. Does not accepted piped input.(.NET types, can add description)
            .OUTPUTS            
            System.Boolean
            .PARAMETER FilePath
            Parent directory path containing target file to be extracted [-FilePath c:\pathto\]
            .PARAMETER FileName
            Filename for the file to be extracted[-FileName 'Exchange2016-KB5057653-x64-en.exe']        
            .EXAMPLE
            PS> Invoke-ExtractTDO -FilePath $RunFrom -FileName $PackageFile
            Demo Test use 
            .LINK
            https://github.com/michelderooij/Install-Exchange15
            .LINK
            https://github.com/tostka/verb-io
            .LINK
            https://github.com/tostka/powershellbb/
            #>
            [CmdletBinding()]
            [Alias('Invoke-Extract')]
            PARAM(
                [Parameter(Position=0, HelpMessage="Parent directory path containing target file to be extracted [-FilePath c:\pathto\]")]
                    $FilePath,
                [Parameter(Position=1, HelpMessage="Filename for the file to be extracted[-FileName 'Exchange2016-KB5057653-x64-en.exe']")]
                    [String]$FileName
            ) 
            $smsg = "Extracting $FilePath\$FileName to $FilePath"
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            If( Test-Path $(Join-Path $FilePath $Filename)) {
                $TempNam= "$(Join-Path $FilePath $Filename).zip"
                Copy-Item $(Join-Path $FilePath $Filename) "$TempNam" -Force
                $shellApplication = new-object -com shell.application
                $zipPackage = $shellApplication.NameSpace( $TempNam)
                $destFolder = $shellApplication.NameSpace( $FilePath)
                $destFolder.CopyHere( $zipPackage.Items(), 0x10)
                Remove-Item $TempNam
            }
            Else {
                $smsg = "$FilePath\$FileName not found"
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            }
        }
#endregion INVOKE_EXTRACTTDO ; #*------^ END FUNCTION Invoke-ExtractTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU31qCcPPAsatwejlY28tt6Kmb
# FsegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQPJFYR
# v0V7DbEEg6U0InfOFJxRwzANBgkqhkiG9w0BAQEFAASBgGZ5bSJT6wRAkLys8762
# jJEHNdl+W74qfL9tJDnr3SVlG+eU1Nkza+Sp3wtj08lYkGMJElcfr3/HqN3eSqTA
# aMezip6V6xdMzdj6MisRKOhzfGGz5ZHAj80C1IANaz3r51LQk3myhutAVrYchmfE
# WQzai/YgD3zV/Mxk8XY28nnk
# SIG # End signature block
