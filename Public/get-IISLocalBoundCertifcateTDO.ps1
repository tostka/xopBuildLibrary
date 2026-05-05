#region GET_IISLOCALBOUNDCERTIFCATETDO ; #*------v FUNCTION get-IISLocalBoundCertifcateTDO v------
Function get-IISLocalBoundCertifcateTDO {
        <#
        .SYNOPSIS
        get-IISLocalBoundCertifcateTDO - Retrieves the certificate bound to the IIS Default Website (also handy for independantly verifyinig Exchange Service bindings, when get-exchangecertificate is mangled by Exchange Auth cert expiration). 
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250929-1026AM
        FileName    : get-IISLocalBoundCertifcateTDO
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,IIS,Web,Website,Exchange,Certificate
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 2:40 PM 10/1/2025 updated CBH example; added to xopBuildLibrary.psm1
        * 4:01 PM 9/30/2025 init
        .DESCRIPTION
        get-IISLocalBoundCertifcateTDO - Retrieves the certificate bound to the IIS Default Website (also handy for independantly verifyinig Exchange Service bindings, when get-exchangecertificate is mangled by Exchange Auth cert expiration). 
        
        Driven by get-exchangecertificate fundemental on-install break, when Nov2023 SU patching packet signing mandates break any time the Exchange Auth certificate is non-functional
        Unfortunately, fixing the issue requires rerunning Hybrid Configuration Wizard as part of the process (Change approval requiremment PITA).
        So this is one way to commandline confirm Exchange Cert Service binding, without a functional get-exchangecertificate return (or using EAC web site).
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Security.Cryptography.X509Certificates.X509Certificate2 bound certificate object
        .EXAMPLE
        PS> if($iisCert = get-IISLocalBoundCertifcateTDO){
        PS>     write-host "IIS has a bound certificate: implies the IIS ExchangeCertifidate Binding is intact"
        PS> } ; 
        Demo default output        
        .LINK
        https://github.org/tostka/verb-network/
        #>
        [CmdletBinding()]
        #[alias('get-LocalDiskFreeSpace')]
        PARAM() ; 
        if(-not (get-module Webadministration)){import-module -name Webadministration -fo -verb } ; 
        if($site = Get-ChildItem -Path "IIS:\Sites" | where {( $_.Name -eq "Default Web Site" )}){
            if($binding = $site.bindings.collection | ?{$_.protocol -eq 'https' -and $_.bindingInformation -eq ':443:'}){                
                $smsg = "`n$(($binding | fl * |out-string).trim())" ; 
                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                if($iisCert = gci -Path "cert:\localmachine\$($binding.certificateStoreName)\$($binding.certificateHash)"){
                    $smsg = "IIS bound cert:`nSubjectName: $($iiscert.subjectname.name)`n$(($iisCert | fl thumbprint,notbefore,notafter,hasprivatekey|out-string).trim())" ; 
                    $smsg += "`nSANS:`n`n$(($iisCert.DnsNameList.unicode|out-string).trim())" ; 
                    write-host -foregroundcolor green $smsg ;   
                    [pscustomobject]$iisCert | write-output ;           
                }else{
                    $smsg = "No bound certificate found for local IIS Default Web Site" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ; 
            } ; 
        }else{
            $smsg = "No local IIS Sites found" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;  
    }
#endregion GET_IISLOCALBOUNDCERTIFCATETDO ; #*------^ END FUNCTION get-IISLocalBoundCertifcateTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyVSubnL4DVn935ChoBRHWb3I
# 6MqgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSC10U4
# D/Q7glKQhj8BXdkdebMFvjANBgkqhkiG9w0BAQEFAASBgD9DelGvuRTZVkspuhkO
# T3tOp50nllNzLG5BCF5W+JHBdS9uE82hPuOnLguzs7ugDodlBGUQxZk98yEyWddm
# pN5TcGduATAoFi4b1WHnRXIa20NCx+jkpQvzzpJi2R6cnYTVLRLNqvMoJYNzrBNp
# oJLPsqlHi7002F1eyQq+9Qo0
# SIG # End signature block
