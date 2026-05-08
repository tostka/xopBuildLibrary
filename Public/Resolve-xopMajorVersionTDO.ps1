# Resolve-xopMajorVersionTDO.ps1

#region RESOLVE_XOPMAJORVERSIONTDO ; #*------v Resolve-xopMajorVersionTDO v------
Function Resolve-xopMajorVersionTDO {
    <#
    .SYNOPSIS
    Resolve-xopMajorVersionTDO - Resolves Exchange Server SemanticVersion BuildNumber to Major Server Revision tag (EXSE|EX2019|EX2016|EX2013|EX2010|EX2007|EX2003|EX2000|EX55|EX50|EX40_SE)
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20250711-0423PM
    FileName    : Resolve-xopMajorVersionTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-ex2010
    Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: URL
    REVISIONS
    * 3:06 PM 11/26/2025 init version, simplified major version version of Resolve-xopBuildSemVersToTextNameTDO, returns solely the build tag, not further details

    .DESCRIPTION
    Resolve-xopMajorVersionTDO - Resolves Exchange Server SemanticVersion BuildNumber to Major Server Revision tag (EXSE|EX2019|EX2016|EX2013|EX2010|EX2007|EX2003|EX2000|EX55|EX50|EX40_SE)
    
    Supports Exchange Server 4.0 SE through Exchange Server Subscription Edition. 

    Simple check of semver against RTM/Preview etc initial release versions ('Breakpoints'): 

        Breakpoints for major versions (1st/lowest BuildNumberShort for the revision level):
        NickName           BuildNumberShort
        --------           ----------------
        EXSE_RTM           15.2.2562.17
        EX2019_Preview     15.2.196.0
        EX2016_RTM         15.1.225.42
        EX2016_Preview     15.1.225.16
        EX2013_RTM         15.0.516.32
        EX2010_RTM         14.0.639.21
        EX2007_RTM         8.0.685.25
        EX2003             6.5.6944
        EX2000             6.0.4417
        EX55               5.5.1960
        EX50               5.0.1457
        EX40_SE            4.0.837

    .PARAMETER Version
    .INPUTS
    None, no piped input.
    .OUTPUTS
    System.String Exchange Server Major Version Tag
    .EXAMPLE
    PS> $VersInfo = Resolve-xopMajorVersionTDO -Version ([version](gi (gcm ExSetup.exe -ea STOP).source -ea STOP).VersionInfo.ProductVersion) ; 
    PS> $VersInfo ; 
    
        EX2016

    Demo resolving a Semantic Version string to specific release/build details
    .LINK
    https://github.com/tostka/verb-ex2010        
    .LINK
    https://learn.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates
    #>
    [CmdletBinding()]
    #[alias('Get-DetectedFileVersion')]
    PARAM(
        [Parameter(Mandatory=$TRUE,HelpMessage = "Exchange Version in Semantic Version Number format (n.n.n.n), or semantic/version object[-Version '8.0.708.3']")]                
            [alias('FileVersion')]
            [version]$Version          
    ) ;         
    PROCESS {
        # when updating $BuildToProductName table (below), also record date of last update here (echos to console, for awareness on results)
        [datetime]$lastBuildTableUpedate = '2025-11-26' ; 
        $BuildTableUpedateUrl = 'https://learn.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates'
        #'https://docs.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-date' ; 
        #Creating the hash table with build numbers and cumulative updates
        # updated as of 9:56 AM 3/26/2025 to curr https://learn.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates?view=exchserver-2019
        # also using unmodified MS Build names, from the chart (changing just burns time)
        $smsg = "NOTE:`$BuildToProductName table was last updated on $($lastBuildTableUpedate.ToShortDateString())" ; 
        $smsg += "`n(update from:$($BuildTableUpedateUrl))" ;
        write-host -foregroundcolor yellow $smsg ; 
      
        if($Version){ 
            if($Version -ge [version]'15.2.2562.29'){ $isEXSE = $true ; $ExVers = 'EXSE' }
            elseif($Version -ge [version]'15.2.196.0'){ $isEX2019 = $true ; $ExVers = 'EX2019' } 
            elseif($Version -ge [version]'15.1.225.16'){ $isEX2016 = $true ; $ExVers = 'EX2016' } 
            elseif($Version -ge [version]'15.0.516.32'){ $isEX2013 = $true ; $ExVers = 'EX2013' } 
            elseif($Version -ge [version]'14.0.639.21'){ $isEX2010 = $true ; $ExVers = 'EX2010' } 
            elseif($Version -ge [version]'8.0.685.25'){ $isEX2007 = $true ; $ExVers = 'EX2007' } 
            elseif($Version -ge [version]'6.5.6944'){ $isEX2003 = $true ; $ExVers = 'EX2003' } 
            elseif($Version -ge [version]'6.0.4417'){ $isEX2000 = $true ; $ExVers = 'EX2000' } 
            elseif($Version -ge [version]'5.5.1960'){ $isEX55 = $true ; $ExVers = 'EX55' } 
            elseif($Version -ge [version]'5.0.1457'){ $isEX50 = $true ; $ExVers = 'EX50' } 
            elseif($Version -ge [version]'4.0.837'){ $isEX40_SE = $true ; $ExVers = 'EX40_SE' } 
            else{ throw "Unrecognized Exchange Server Version: $($Version)" } ; 
            if($ExVers){
                $smsg = "Resolved Exchange Exchange Server Version: $($Version) => `$ExVers: $($ExVers) "  ;                 
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
                $ExVers | write-output 
            } ; 
        } ; 
    };  # PROC-E        
} ; 
#endregion RESOLVE_XOPMAJORVERSIONTDO ; #*------^ END Resolve-xopMajorVersionTDO ^------
# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzB1xRBlpEXa0NDZ7hSAZgj5T
# jmmgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT9BLW3
# dmkB4F9tanJdN7bYF8JgmjANBgkqhkiG9w0BAQEFAASBgJgScNZ9lxiTA+AjortE
# iIkYhKTEY6P7a5rNPzAe9k4IIS/HAEhwEr3VAcsxwpjOwKZYmmmUUo1BQ0Uoe1ju
# 6DWTxthAf20x+r5nD2k0ZQ3cnx3d/F8zWZHsegl/2GNBYWvLOdPdNQY0ST0YAdGA
# ugE9pAAgpJiF09g4YU23av7E
# SIG # End signature block
