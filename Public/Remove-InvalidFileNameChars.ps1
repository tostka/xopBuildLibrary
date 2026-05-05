#region REMOVE_INVALIDFILENAMECHARS ; #*------v FUNCTION Remove-InvalidFileNameChars v------
Function Remove-InvalidFileNameChars {
          <#
            .SYNOPSIS
            Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
            .NOTES
            Author: Ansgar Wiechers
            Website:	https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
            Twitter     :	
            AddedCredit : 
            AddedWebsite:	
            Version     : 1.0.0
            CreatedDate : 2020-09-01
            FileName    : Remove-InvalidFileNameChars.ps1
            License     : 
            Copyright   : 
            Github      : https://github.com/tostka/verb-IO
            Tags        : Powershell,Filesystem
            REVISIONS   :
            * 9:55 AM 12/15/2025 added regions
            * 4:35 PM 12/16/2021 added -PurgeSpaces, to fully strip down the result. Added a 2nd CBH example
            * 7:21 AM 9/2/2020 added alias:'Remove-IllegalFileNameChars'
            * 3:32 PM 9/1/2020 added to verb-IO
            * 4/14/14 posted version
            .DESCRIPTION
            Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
            Note: You should pass the filename, and not a full-path specification as '-Name', 
            or the function will remove path-delimters and other routine path components. 
            .PARAMETER Name
            Potential file 'name' string (*not* path), to have illegal filename characters removed. 
            .PARAMETER PurgeSpaces
            Switch to purge spaces along with OS-specific illegal filename characters. 
            .INPUTS
            Accepts piped input.
            .OUTPUTS
            System.String
            .EXAMPLE
            $Name = Remove-InvalidFileNameChars -name $ofile ; 
            Remove OS-specific illegal characters from the sample filename in $ofile. 
            .EXAMPLE
            $Name = Remove-InvalidFileNameChars -name $ofile -purgespaces ; 
            Remove OS-specific illegal characters & spaces from the sample filename in $ofile. 
            .LINK
            https://github.com/tostka/verb-IO
            #>
            [CmdletBinding()]
            [Alias('Remove-IllegalFileNameChars')]
            Param(
                [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
                [String]$Name,
                [switch]$PurgeSpaces
            )
            $verbose = ($VerbosePreference -eq "Continue") ; 
            $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join '' ; 
            if($PurgeSpaces){
                write-verbose "(-PurgeSpaces: removing spaces as well)" ; 
                $invalidChars += ' ' ; 
            } ; 
            $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
            ($Name -replace $re) | write-output ; 
        }
#endregion REMOVE_INVALIDFILENAMECHARS ; #*------^ END FUNCTION Remove-InvalidFileNameChars  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEly8ILH+SdE+QJfktFatwYGu
# 0s2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRAvXHT
# EzY093RydMaDzAIRgDieejANBgkqhkiG9w0BAQEFAASBgE4vu5dg/bQCZKSKX2qr
# kVNDKn8ZVRvJo0hzyoJPPJ+dn7iIX0TN1FP+KstO8zrSHRTJxmSuhS53i+TZ01EU
# 8fnBokhcJgxB+eOWlwsyrPWDO+uE6L8Bogw2dhgnOrWsO2YwZFfGs3U3tmxtmvvH
# eeWD5Et4FpFENGB8fnh15A+9
# SIG # End signature block
