#region GET_XOPLOCALEXSETUPVERSIONTDO ; #*------v FUNCTION get-xopLocalExSetupVersionTDO v------
Function get-xopLocalExSetupVersionTDO {
        <#
        .SYNOPSIS
        get-xopLocalExSetupVersionTDO - Discover local Exchange Server Installed BIN ExSetup.exe (or use specified -ExSetupPath), from common paths and return summary (FullName,Name,ProductVersion,Length,Lastwritetime)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250929-1026AM
        FileName    : get-xopLocalExSetupVersionTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : ExchangeServer,Version,Install,Maintenance
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 1:18 PM 11/3/2025 updated description to indicate BIN ExSetup, (not CAB)
        * 1:29 PM 10/2/2025 init 
        .DESCRIPTION
        get-xopLocalExSetupVersionTDO - Discover local Exchange Server CAB ExSetup.exe (or use specified -ExSetupPath), from common paths and return summary (FullName,Name,ProductVersion,Length,Lastwritetime)
        .PARAMETER ExSetupPath
        Optional full path to ExSetup.exe file to be examined [-ExSetupPath c:\pathto\ExSetup.exe]
        .INPUTS
        None, no piped input.
        .OUTPUTS
        PSCustomObject summary of ExSetup.exe (FullName,Name,ProductVersion,Length,Lastwritetime)
        .EXAMPLE
        PS> $cabinfo = get-xopLocalExSetupVersionTDO -verbose 
        PS> $cabinfo 

        15:22:22:No -ExSetupPath: Attempting to discover latest local cab version, hunting across drives:r|d|c
        15:22:23:Taking first resolved $CabExSetup:

            FullName       : D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked\Setup\ServerRoles\Common\ExSetup.EXE
            Name           : ExSetup.EXE
            ProductVersion : 15.1.2507.6
            Length         : 36256
            LastWriteTime  : 3/26/2022 3:02:53 PM

        Demo autodiscovery hunting through configured drives on standard paths
        .EXAMPLE
        PS> $cabinfo = get-xopLocalExSetupVersionTDO -ExSetupPath "D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked\Setup\ServerRoles\Common\ExSetup.EXE" -verbose ; 
        PS> $cabinfo 

            FullName       : D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked\Setup\ServerRoles\Common\ExSetup.EXE
            Name           : ExSetup.EXE
            ProductVersion : 15.1.2507.6
            Length         : 36256
            LastWriteTime  : 3/26/2022 3:02:53 PM

        Demo resolving against a specified full path to the ExSetup.exe to be examined.
        .LINK
        https://github.org/tostka/verb-ex2010/
        #>
        [CmdletBinding()]
        [alias('get-xopLocalExSetupVersion')]
        PARAM(
            [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = 'Optional full path to ExSetup.exe file to be examined [-ExSetupPath c:\pathto\ExSetup.exe]')]
                [Alias('PsPath')]
                #[AllowNull()]
                #[ValidateScript({Test-Path $_ -PathType 'Container'})]
                #[System.IO.DirectoryInfo[]]$Path,
                [ValidateScript({Test-Path $_})]
                [system.io.fileinfo[]]$ExSetupPath
                #[string[]]$ExSetupPath,
        ) ;  
        BEGIN{}
        PROCESS{       
            if(-not $ExSetupPath){
                if(-not (get-variable CabDrives -ea 0)){$CabDrives = 'r','d','c' };        
                $smsg = "No -ExSetupPath: Attempting to discover latest local cab version, hunting across drives:$($CabDrives -join '|')" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                # Resolve LATEST LOCAL CAB VERSION, HUNTING ACROSS DRIVES
                #$SourcePath = 'D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked\Setup\ServerRoles\Common\ExSetup.EXE'  ; 
                # wildcard to span versions & cu/su combos.
                $SourcePath = 'D:\cab\ExchangeServer*-x64-*-ISO\unpacked\Setup\ServerRoles\Common\ExSetup.EXE'  ; 
                $SourceLeaf = ($SourcePath.split('\') | select -skip 1 ) -join '\' ;     
                foreach($cabdrv in $CabDrives){
                    if(-not (test-path -path  "$($cabdrv):" -ea 0)){Continue} ;
                    $testpath = (join-path -path "$($cabdrv):" -child $SourceLeaf) ;
                    $CabExSetup = resolve-path $testpath | select -expand path |foreach-object{
                        $thisfile = gci $_ ;
                        $finfo = [ordered]@{
                            FullName = $thisfile.fullname;
                            Name = $thisfile.Name ; 
                            ProductVersion = [version]$thisfile.versioninfo.productversion ; 
                            Length = $thisfile.length ; 
                            LastWriteTime = $thisfile.LastWriteTime ; 
                        } ;
                        [pscustomobject]$finfo | write-output ;            
                    } | sort productversion | select -last 1 ;
                    if($CabExSetup){
                        $smsg = "Taking first resolved `$CabExSetup:`n`n$(($CabExSetup|out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        $CabExSetup | write-output ; 
                        Break ; 
                    } ; 
                } ;
            } else{
                FOREACH($exfile IN $ExSetupPath){
                    $thisfile = gci $EXFILE -ea STOP ;
                    $finfo = [ordered]@{
                        FullName = $thisfile.fullname;
                        Name = $thisfile.Name ; 
                        ProductVersion = [version]$thisfile.versioninfo.productversion ; 
                        Length = $thisfile.length ; 
                        LastWriteTime = $thisfile.LastWriteTime ; 
                    } ;
                    [pscustomobject]$finfo | write-output 
                } ; 
            }; 
        } ;  # PROC-E
    }
#endregion GET_XOPLOCALEXSETUPVERSIONTDO ; #*------^ END FUNCTION get-xopLocalExSetupVersionTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqyWdWDNvrGTSSTlyEMllIg3R
# REOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRbMzDn
# 5h0u+r6gMqpOEkRIwa/G2jANBgkqhkiG9w0BAQEFAASBgISAj3eaV6dbuB4WKSy3
# KvpMNXafRQPky3LsFcQQFuIbfNgGNTAEQxvGfbjR6dKMLmGx8LH2MYPvHQP4DyEu
# L2XBaVrZnuggBwFphf5DovgeEB+ykH5uMj8+fp+SkQHD67TZZK6bhnFPXIJfw0UJ
# uYghZe+fKN2nW1uezNUmV2vd
# SIG # End signature block
