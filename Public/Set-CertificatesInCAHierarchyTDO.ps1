# Set-CertificatesInCAHierarchyTDO_func

#$cafiles = gci C:\OpenSSL-CAs\TKadrie256CA\*.crt -recur | select -expand fullname | sort ;

#region Set-CertificatesInCAHierarchyTDO ; #*------v Set-CertificatesInCAHierarchyTDO v------
function Set-CertificatesInCAHierarchyTDO {
    <#
    .SYNOPSIS
    Set-CertificatesInCAHierarchyTDO - Fed an array of Certificate Authority 'CA' cert names in cert (.cer|.cert|.crt) format, this will sort the Root CA certs first, followed by any Intermediate certificates (and any non-CA cert files will be appended last). Does not do more than two layers of sorting - CA & IA:  3rd level IAs will all be returned in initial order, along with 2nd-level IAs.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20250711-0423PM
    FileName    : Set-CertificatesInCAHierarchyTDO.ps1
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/Network
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 4:31 PM 7/11/2025 init; expanded into full function, adding to vnet
    .DESCRIPTION
    Set-CertificatesInCAHierarchyTDO - Fed an array of Certificate Authority 'CA' cert names in cert (.cer|.cert|.crt) format, this will sort the Root CA certs first, followed by any Intermediate certificates (and any non-CA cert files will be appended last). Does not do more than two layers of sorting - CA & IA:  3rd level IAs will all be returned in initial order, along with 2nd-level IAs.
    .PARAMETER  Path
    Array of cert-format CA file paths to be ordered[-Path @('c:\path-to\IA.cer','c:\path-to\Root.crt')]
    .INPUTS
    String[] Accepts piped input
    .OUTPUTS
    System.Array
    .EXAMPLE
    gci C:\OpenSSL-CAs\XXXCA\*.crt -recur | select -expand fullname | Set-CertificatesInCAHierarchyTDO;
    Pipeline example
    .EXAMPLE
    PS> Set-CertificatesInCAHierarchyTDO -path (gci C:\OpenSSL-CAs\XXXCA\*.crt -recur | select -expand fullname) -verbose
    Splatted example: Import specified pfx, using NotBefore and Change number, with -whatif & -verbose output
    .LINK
    https://github.org/tostka/powershellBB/
    #>
    [CmdletBinding()]
    [Alias('Set-CertificatesInCAHierarchy','sort-CertificatesInCAHierarchy')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Array of cert-format CA file paths to be ordered[-Path @('c:\path-to\IA.cer','c:\path-to\Root.crt')]")]
            [ValidateScript({Test-Path $_})]
            [string[]]$Path
    ) ;
    Begin{
    $RootCAs = @() ;
    $IAs = @() ;
    $NonCAs = @() ;
    }
    PROCESS{
        foreach ($file in $Path) {
            # load each cert
            $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($file) ;
            $basicConstraints = $certificate.Extensions | Where-Object {$_.Oid.FriendlyName -eq "Basic Constraints"}
            if ($basicConstraints) {
                $basicConstraintsData = [System.Security.Cryptography.X509Certificates.X509BasicConstraintsExtension]$basicConstraints ;
                if ($basicConstraintsData.CertificateAuthority) {
                    write-verbose "$($file) certificate is a Certificate Authority (CA) (basicConstraintsData.CertificateAuthority populated)."
                    # Root CA certs are self-signed: have matching Issuer & Subject
                    if ($certificate.Issuer -eq $certificate.Subject) {
                        write-verbose "$($file) have matching Issuer & Subject: Self-signed: likely a Root CA" ;
                        $RootCAs += @($file) ;
                    } else {
                        write-verbose "$($file) is likely an IA" ;
                        $IAs += @($file) ;
                    } ;
                }
            } else {
                write-verbose  "$($file) certificate in the array is NOT a Certificate Authority (CA) (CertificateAuthority UNPOPULATED)."
                $NonCAs += @($file) ;
            }
        } ;
    }
    END{
        # re-combine, Roots, then IAs
        write-verbose  "`RootCAs:`n$(($RootCAs|out-string).trim())" ;
        write-verbose  "`IAs:`n$(($IAs|out-string).trim())" ;
        write-verbose  "`NonCAs:`n$(($NonCAs|out-string).trim())" ;
        #[string[]]
        [array]$cafiles = $(@($RootCAs);@($IAs);@($NonCAs)) ;
        $cafiles | write-output ;
    }
}
#endregion Set-CertificatesInCAHierarchyTDO ; #*------^ END Set-CertificatesInCAHierarchyTDO ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8QNOszZ6dH8DonhGaG3I+GNo
# iPugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTENJgM
# hFFLNOFWbo4XGJjCnf5DhDANBgkqhkiG9w0BAQEFAASBgErS5P8Uk9ivR92lyMrG
# gDIB5Qz+XUpCZfQmp5JJ6kxbXkssFa3YytL1t5vDLit9UiNJsPcuhAQsoSFTe35C
# uymiXtjNe4MMSzyt56VDUnf9Uja7BKd7eqjcvA05TUpRoW7VsoFwPkluzvzcbR6L
# HNsa2wFMjbQ578LPuUc3pDLg
# SIG # End signature block
