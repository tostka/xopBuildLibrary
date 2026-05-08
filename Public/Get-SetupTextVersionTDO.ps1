# Get-SetupTextVersionTDO.ps1


#region GET_SETUPTEXTVERSIONTDO ; #*------v Get-SetupTextVersionTDO v------
Function Get-SetupTextVersionTDO {
        <#
        .SYNOPSIS
        Get-SetupTextVersionTDO - Resolves an Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (in 4-integer dot-separated format), to matching Exchange Version Text string. Works for either installed bins, or setup cab bins.
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Get-SetupTextVersionTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL
        REVISIONS
        * 9:41 AM 10/2/2025 updated CBH w expanded comment about why running both this, and Resolve-xopBuildSemVersToTextNameTDO: they output different ProductName equivelents,
            which are already stored in build state .xml files on servers (would change the spec mid-build)
        * 10:48 AM 9/22/2025 port to uwes's as _func.ps1 (not a generic mod use; load when needed) from xopBuildLibrary; add CBH, and Adv Function specs
        * 1:58 PM 8/8/2025 added CBH; init; renamed AdminAccount -> Account, aliased  orig param and logon variant. ren: Get-SetupTextVersionTDO -> Get-SetupTextVersionTDO, aliased orig name
        .DESCRIPTION
        Get-SetupTextVersionTDO - Resolves an Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (in 4-integer dot-separated format), to matching Exchange Version Text string. Works for either installed bins, or setup cab bins.
        
        This is of very limited utility: Duped from install-Exchange15-TTC.ps1, solely to support out of band calls to that function: 
        - Works with a static array of recent builds of installable RTM/SP/CU builds. 
        - by contrast verb-io\Get-FileVersionTDO() covers every version of Exchange Server back to 4.0, including every SU & HU. Issue between the two, 
            is Resolve-xopBuildSemVersToTextNameTDO's ProductName reflects MS's version doc page string; 
            while 821\Get-SetupTextVersion() returns a non-standard name for the same build/CU 
            ('Exchange Server 2016 CU23 (2022H1)' v 'Exchange Server 2016 Cumulative Update 23')
            Retaining both, to avoid changing rev version strings already stored in server build state .xml files

        I could recode get-fileversionTDO() to emulate this, but would have to externalize logic to 'fail' unsupportedbuilds, as this doesn't just reesolve .exe build SemVers, 
            it also aribtrates if your version isn't supported. So we go static.
        This is *not* in any module, but xopBuildLibrary.ps1. There' no ongoing benefit to building it into vx10 etc.
        I'll park a _func.ps1 copy out in uwes, for other use.

        This is designed to track the core/build-installable CU & RTM builds (vs hotfixes etc).
        
        This version, as of 10:42 AM 9/22/2025, documents the following specific revisions of Exchange Server
        
            $EX2016SETUPEXE_CU23= 'Exchange Server 2016 Cumulative Update 23';
            $EX2019SETUPEXE_CU10= 'Exchange Server 2019 CU10';
            $EX2019SETUPEXE_CU11= 'Exchange Server 2019 CU11';
            $EX2019SETUPEXE_CU12= 'Exchange Server 2019 CU12';
            $EX2019SETUPEXE_CU13= 'Exchange Server 2019 CU13';
            $EX2019SETUPEXE_CU14= 'Exchange Server 2019 CU14';
            $EX2019SETUPEXE_CU15= 'Exchange Server 2019 CU15';
            $EXSESETUPEXE_RTM= 'Exchange Server SE RTM';
        
        Requires manual updates to track new CUs over time.
                
        .PARAMETER FileVersion
        Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (from FileVersionInfo.ProductVersion in Powershell, or ProductVersion in Explorer), in 4-integer dot-separated format[-FileVersion '15.01.2507.006']
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> $SourcePath = 'D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked'  ; 
        PS> $SetupVersion= Get-DetectedFileVersion "$($SourcePath)\Setup\ServerRoles\Common\ExSetup.exe" ; 
        PS> $SetupVersionText= Get-SetupTextVersion $SetupVersion ; 
        Demo pulling setup CAB version
        .EXAMPLE
        PS> if($InstalledSetup= (gcm ExSetup.exe).source){$InstalledSetupVersionText= Get-SetupTextVersion $InstalledSetup } ; 
        Demo pulling installed bin version, by way of D:\Program Files\Microsoft\Exchange Server\V15\Bin\ExSetup.exe ProductVersion        
        .EXAMPLE
        .LINK
        https://github.org/tostka/verb-io/
        #>
        [CmdletBinding()]
        [alias('Get-SetupTextVersion821','Get-SetupTextVersion')]
        PARAM(
            [Parameter(Mandatory=$true,HelpMessage = "Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (from FileVersionInfo.ProductVersion in Powershell, or ProductVersion in Explorer), in 4-integer dot-separated format[-FileVersion '15.01.2507.006']")]
                [string]$FileVersion
        ) ;
        # ensure dep constants are defined
        if(-not $EX2016SETUPEXE_CU23){$EX2016SETUPEXE_CU23            = '15.01.2507.006'} ;         
        if(-not $EX2019SETUPEXE_CU10){$EX2019SETUPEXE_CU10            = '15.02.0922.007'} ; 
        if(-not $EX2019SETUPEXE_CU11){$EX2019SETUPEXE_CU11            = '15.02.0986.005'} ; 
        if(-not $EX2019SETUPEXE_CU12){$EX2019SETUPEXE_CU12            = '15.02.1118.007'} ; 
        if(-not $EX2019SETUPEXE_CU13){$EX2019SETUPEXE_CU13            = '15.02.1258.012'} ; 
        if(-not $EX2019SETUPEXE_CU14){$EX2019SETUPEXE_CU14            = '15.02.1544.004'} ; 
        if(-not $EX2019SETUPEXE_CU15){$EX2019SETUPEXE_CU15            = '15.02.1748.008'} ; 
        if(-not $EXSESETUPEXE_RTM){$EXSESETUPEXE_RTM               = '15.02.2562.017'} ; 
        # supported versions lookup table (maps semvers above to text string)
        $Versions= @{
            $EX2016SETUPEXE_CU23= 'Exchange Server 2016 Cumulative Update 23';
            $EX2019SETUPEXE_CU10= 'Exchange Server 2019 CU10';
            $EX2019SETUPEXE_CU11= 'Exchange Server 2019 CU11';
            $EX2019SETUPEXE_CU12= 'Exchange Server 2019 CU12';
            $EX2019SETUPEXE_CU13= 'Exchange Server 2019 CU13';
            $EX2019SETUPEXE_CU14= 'Exchange Server 2019 CU14';
            $EX2019SETUPEXE_CU15= 'Exchange Server 2019 CU15';
            $EXSESETUPEXE_RTM= 'Exchange Server SE RTM';
        }
        #
        <# build it instead, can't use varis in the index
        $versions = @{}
        $Versions[$EX2016SETUPEXE_CU23]= 'Exchange Server 2016 Cumulative Update 23' ; 
        $Versions[$EX2019SETUPEXE_CU10]= 'Exchange Server 2019 CU10';
        $Versions[$EX2019SETUPEXE_CU11]= 'Exchange Server 2019 CU11';
        $Versions[$EX2019SETUPEXE_CU12]= 'Exchange Server 2019 CU12';
        $Versions[$EX2019SETUPEXE_CU13]= 'Exchange Server 2019 CU13';
        $Versions[$EX2019SETUPEXE_CU14]= 'Exchange Server 2019 CU14';
        $Versions[$EX2019SETUPEXE_CU15]= 'Exchange Server 2019 CU15';
        $Versions[$EXSESETUPEXE_RTM]= 'Exchange Server SE RTM';
        #>
        $res= "Unsupported version (build $FileVersion)"
        $Versions.GetEnumerator() | Sort-Object -Property {[System.Version]$_.Name} | ForEach-Object {
            If( [System.Version]$FileVersion -ge [System.Version]$_.Name) {
                $res= '{0} (build {1})' -f $_.Value, $FileVersion
            }
        }
        return $res
    }
#endregion GET_SETUPTEXTVERSIONTDO ; #*------^ END Get-SetupTextVersionTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUuwd+W6NF9MaLSRL54t5dXVB
# pQOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSh7qHx
# FJ4hrYpG2LD2ZeEoUlHdSTANBgkqhkiG9w0BAQEFAASBgGNfw/+Soj5uvUBtNU4o
# qlpK1QaImKAD3K9x88sqt4pCys5l/uDk1lghpXFzs/FcjKnWi8ZCmNSsHYrgiWO3
# kiOuNMg9l6AzQdZYW1lSA0nj3GhankLf4yHhpQnTlt1zyqX96zMPMgjUH9tsXJkH
# g8KE1A6QTJMJ/fgl0/sMo0UK
# SIG # End signature block
