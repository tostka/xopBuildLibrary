#region CONVERTFROM_MARKDOWNTABLE ; #*------v FUNCTION convertFrom-MarkdownTable v------
Function convertFrom-MarkdownTable {
            <#
            .SYNOPSIS
            convertFrom-MarkdownTable.ps1 - Converts a Markdown table to a PowerShell object.
            .NOTES
            REVISION
            * 9:33 AM 4/11/2025 add alias: cfmdt (reflects standard verbalias)
            .PARAMETER markdowntext
            Markdown-formated table to be converted into an object [-markdowntext 'title text']
            .INPUTS
            Accepts piped input.
            .OUTPUTS
            System.Object[]
            .EXAMPLE
            PS> $svcs = Get-Service Bits,Winrm | select status,name,displayname |
                convertTo-MarkdownTable -border | ConvertFrom-MarkDownTable ;
            Convert Service listing to and back from MD table, demo's working around border md table syntax (outter pipe-wrapped lines)
            .EXAMPLE
            PS> $mdtable = @"
            |EmailAddress|DisplayName|Groups|Ticket|
            |---|---|---|---|
            |da.pope@vatican.org||CardinalDL@vatican.org|999999|
            |bozo@clown.com|Bozo Clown|SillyDL;SmartDL|000001|
            "@ ;
                $of = ".\out-csv-$(get-date -format 'yyyyMMdd-HHmmtt').csv" ;
                $mdtable | convertfrom-markdowntable | export-csv -path $of -notype ;
                cat $of ;

                "EmailAddress","DisplayName","Groups","Ticket"
                "da.pope@vatican.org","","CardinalDL@vatican.org","999999"
                "bozo@clown.com","Bozo Clown","SillyDL;SmartDL","000001"

            Example simpler method for building csv input files fr mdtable syntax, without PSCustomObjects, hashes, or invoked object creation.
            .EXAMPLE
            PS> $mdtable | convertFrom-MarkdownTable | convertTo-MarkdownTable -border ;
            Example to expand and dress up a simple md table, leveraging both convertfrom-mtd and convertto-mtd (which performs space padding to align pipe columns)
            .LINK
            https://github.com/tostka/verb-IO
            #>
            [CmdletBinding()]
            [alias('convertfrom-mdt', 'in-markdowntable', 'in-mdt', 'cfmdt')]
            Param (
                [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Markdown-formated table to be converted into an object [-markdowntext 'title text']")]
                $markdowntext
            ) ;
            PROCESS {
                $content = @() ;
                if (($markdowntext | measure).count -eq 1) { $markdowntext = $markdowntext -split '\n' } ;
                $markdowntext = $markdowntext -replace '\|\|', '| |' ;
                $content = $markdowntext  | ? { $_ -notmatch "--" } ;
            } ;
            END {
                $PsObj = $content.trim('|').trimend('|') | where-object { $_ } | ForEach-Object {
                    ($_.split('|') | where-object { $_ } | foreach-object { $_.trim() } | where-object { $_ } ) -join '|' ;
                } | ConvertFrom-Csv -Delimiter '|'; # convert to object
                $PsObj | write-output ;
            } ;
        }
#endregion CONVERTFROM_MARKDOWNTABLE ; #*------^ END FUNCTION convertFrom-MarkdownTable  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUe9f/9AL0Lh4lU/Evf5fKC/7h
# XVSgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQbiywq
# itb2+fsV75DglyPNAJT31jANBgkqhkiG9w0BAQEFAASBgIuN2npSLPH3/V7zvybg
# IdZj21THhRJ3qc2fsApJThV3I+EMnlxA2TU9/g9YGD5mgwzmI2CZNb08qbqto/JS
# tpqH56wydSWTSqEQv54sPplDJCj8e/g01pYi8dnceLXu2C8FlvfpjSCmuQ85yB8z
# RI0S8dZBchfJbMhEoYTwMVWf
# SIG # End signature block
