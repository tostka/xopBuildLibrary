#region GET_LOCALDISKFREESPACETDO ; #*------v FUNCTION get-LocalDiskFreeSpaceTDO v------
Function get-LocalDiskFreeSpaceTDO {
            <#
            .SYNOPSIS
            get-LocalDiskFreeSpaceTDO - Retrieves local disk space info, variant (for BGInfo()) drops server specs and reporting, and sorts on Name/driveletter
            .NOTES
            Version     : 0.0.1
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 20250929-1026AM
            FileName    : get-LocalDiskFreeSpaceTDO.ps1
            License     : MIT License
            Copyright   : (c) 2025 Todd Kadrie
            Github      : https://github.com/tostka/verb-io
            Tags        : Powershell,Storage,Drive,Drivespace
            AddedCredit : 
            AddedWebsite: 
            AddedTwitter: 
            REVISIONS
            * 11:03 AM 9/29/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
            added -raw, and dump  unformatted data fields into pipleine
            add to vio
            # 11:14 AM 6/27/2016 This local-only version (for BGInfo) drops server specs and reporting, and sorts on Name/driveletter
            .DESCRIPTION
            get-LocalDiskFreeSpaceTDO - Retrieves local disk space info, variant (for BGInfo()) drops server specs and reporting, and sorts on Name/driveletter
                
            .INPUTS
            None, no piped input.
            .OUTPUTS
            System.Object[] array of drive space summaries of type 3 drives: Size(gb) Free(gb) Free%
            .EXAMPLE
            PS> $drpt = get-LocalDiskFreeSpaceTDO; 
            PS> $drpt ; 
        
              Vol                   Size(gb) Free(gb) Free%
              ---                   -------- -------- -----
              \\?\Volume{b1d5e19... 0.5      0.1      31 % 
              D:\                   59.9     23.6     39 % 
              C:\                   199.5    30.1     15 % 
        
            Demo default output
            .EXAMPLE
            .EXAMPLE
            PS> $drpt = get-LocalDiskFreeSpaceTDO -raw  ; 
            PS> $drpt ; 
        
                Volume                                                    Size              Free    FreePercentage
                ------                                                    ----              ----    --------------
                \\?\Volume{b1d5e198-0000-0000-0000-100000000000}\    524283904 0.149879455566406 0.306955523090024
                D:\                                                64287080448  23.5635986328125 0.393566190899981
                C:\                                               214220926976  30.1288757324219 0.151015283337021
        
            Demo -raw un-formatted output.
            .LINK
            https://github.org/tostka/powershellBB/
            #>
            [CmdletBinding()]
            [alias('get-LocalDiskFreeSpace')]
            PARAM(
                [Parameter(HelpMessage="Switch to return raw unformatted stats (as opposed to elipses'd volumne namese etc)[-raw]")]
                    [switch] $raw
            ) ; 
            $prpDrives =  @{Name="Vol";Expression={if($_.Name.tostring().length -gt 18){"$($_.Name.tostring().substring(0,18))..."} else {"$($_.Name.tostring())" }} },@{Name="Size(gb)";Expression={"{0:N1}" -f($_.Capacity/1gb)}},@{Name="Free(gb)";Expression={"{0:N1}" -f($_.freespace/1gb)}},@{Name="Free`%";Expression={"{0:P0}" -f($_.freespace/$_.capacity)}} ; 
            $prpDrivesRaw =  @{Name="Volume";Expression={$($_.Name.tostring())}},@{Name="Size";Expression={$_.Capacity}},@{Name="Free";Expression={($_.freespace/1gb)}},@{Name="FreePercentage";Expression={($_.freespace/$_.capacity)}} ; 
            if (get-command get-ciminstance -ea 0) {
                $Drives = get-ciminstance Win32_Volume -filter "drivetype = 3" 
            } else {
                $Drives = Get-WMIObject -class Win32_OperatingSystem 
            } ;
            if($raw){
                $Drives | 
                  Select-Object $prpDrivesRaw | 
                      Sort-Object -property "Name" | write-output  ; 
            }else{
            $Drives | 
                  Select-Object $prpDrives | 
                      Sort-Object -property "Name" | write-output  ; 
            } ; 
        }
#endregion GET_LOCALDISKFREESPACETDO ; #*------^ END FUNCTION get-LocalDiskFreeSpaceTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9Vbo/qX3kvg3DFO5gUPb/+9d
# tvmgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRCltmW
# dKuP8kqOmGNHYlhc790iFzANBgkqhkiG9w0BAQEFAASBgKWMDPMrEQubzqLnZCPL
# E/cO+pd5xYXXk2R+WJfgs0lh0lvcwVbE3rE2PrQdxJr7gCbLc40Eu7zqkvMN/tut
# a7Fu5hNUxxSNbzQWMY1hVwo5Z9IdG3B3O7FvLZS9RTVVSTArD3qf4cVwFq2EMuZF
# 1qekc2VUPg/X60TlB8usG44l
# SIG # End signature block
