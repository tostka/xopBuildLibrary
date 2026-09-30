#region FUNCTION TEST_PORT ; #*------v Function Test-Port v------
function Test-Port {
    <#
    .SYNOPSIS
    Test-Port() - test the specified ip/fqdn port combo
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-04-12
    FileName    : test-port.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    REVISIONS
    # 9:50 AM 3/24/2026 psv2 doesn't like dbl quoted regex in ValidatePattern (Parameter attributes need to be a constant or a script block.): 
        flipped to singles.
    # 9:11 AM 1/24/2025 added -ea 0 to the gcm's; expanded gcms; added try/catch to the Net.Sockets.TcpClient code (output friendly error fail); added CBH demo rdp users poll
        ; removed aliases 's' & 'p' (they're already usable as abbrev $server & $port, no other conflicting params ); flip 1st expl to commonly used 3389 (rdp) port; added cmdletbinding (full adv func/verbose support); added alias test-portTDO
    # 12:28 PM 4/12/2022 prior was .net dependant, not psCore compliant: make it defer to and use the NetTCPIP:Test-NetConnection -ComputerName -Port alt, or psv6+ test-connection -targetname -tcpport, only fallback to .net when on Win and no other option avail); moved port valid to param block, rem'd out eapref; added position to params; updated CBH
    # 10:42 AM 4/15/2015 fomt cleanup, added help
    # vers: 8:42 AM 7/24/2014 added proper fail=$false
    # vers: 10:25 AM 7/23/2014 disabled feedback, added a return
    .DESCRIPTION
    Test-Port() - test the specified ip/fqdn port combo
    Excplicitly does not have pipeline support, to make it broadest backward-compatibile, as this func name has been in use goine way back in my code.
    .PARAMETER  Server
    Server fqdn, name, ip to be connected to
    .PARAMETER  port
    Port number to be connected to
    .EXAMPLE
    PS> test-port -ComputerName hostname -Port 3389 -verbose
    Check hostname port 3389 (rdp server), with verbose output
    .EXAMPLE
    PS> 'SERVER1','SERVER2'|%{
    PS>     $ts = $_ ;
    PS>     write-host "`n`n==$($ts)" ;
    PS>     if(test-port -server $ts -port 3389){
    PS>         quser.exe /server:$ts
    PS>     } else {
    PS>         write-warning "$($ts):TSCPort 3389 unavailable! (check ping...)" ;
    PS>         $ctest = $null ; 
    PS>         TRY{$ctest = test-connection -ComputerName $ts -Count 1 -ErrorAction stop} CATCH {write-warning $Error[0].Exception.Message} 
    PS>         if($ctest){
    PS>             write-warning "$($ts):_Pingable_, but TSCPort 3389 unavailable!" ;
    PS>         }else {
    PS>             write-warning "$($ts):UNPINGABLE!" ;
    PS>         };
    PS>     };
    PS> } ; 
    Scriptblock that stacks test-port 3389 (rdp server) & test-connection against series of computers, to conditionally exec a query (run quser.exe rdp-user report)
    .LINK
    https://github.com/tostka/verb-network
    #>
    [CmdletBinding()]
    [alias("test-portTDO")]
    PARAM(
        [parameter(Position=0,Mandatory=$true)]
            [alias('ComputerName','TargetName')]
            [string]$Server,
        [parameter(Position=1,Mandatory=$true)]
            [alias('TcpPort')]
            [ValidatePattern('^(6553[0-5]|655[0-2]\d|65[0-4]\d\d|6[0-4]\d{3}|[1-5]\d{4}|[1-9]\d{0,3}|0)$')]
            [int32]$Port
    )
    if($host.version.major -ge 6 -AND (get-command test-connection -ea STOP)){
        write-verbose "(Psv6+:using PS native:test-connection -Targetname  $($server) -tcpport $($port)...)" ; 
        TRY {$PortTest = test-connection -targetname $Server -tcpport $port -Count 1 -ErrorAction SilentlyContinue -ErrorVariable Err } CATCH { $PortTest = $Null } ;
        if($PortTest -ne $null ){
            write-verbose "Success" ; 
            return $true ; 
        } else {
            write-verbose "Failure" ; 
            return $False;
        } ; 
    } elseif (get-command Test-NetConnection -ea STOP){
        write-verbose "(Psv5:using NetTCPIP:Test-NetConnection -computername $($server) -port $($port)...)" ; 
        if( (Test-NetConnection -computername $Server -port $port).TcpTestSucceeded ){
            write-verbose "Success" ; 
            return $true ; 
        } else {
            write-verbose "Failure" ; 
            return $False;
        } ; 
    } elseif([System.Environment]::OSVersion.Platform -eq 'Win32NT'){ 
        write-verbose "(Falling back to PsWin:Net.Sockets.TcpClient)" ; 
        $Socket = new-object Net.Sockets.TcpClient ; 
        TRY{ $Socket.Connect($Server, $Port) }CATCH{ write-warning "FAILED:($Socket).Connect(($Server), ($Port)" };
        if ($Socket.Connected){
            $Socket.Close() ; 
            write-verbose "Success" ; 
            return $True;
        } else {
            write-verbose "Failure" ; 
            return $False;
        } # if-block end
        $Socket = $null
    } else {
        throw "Unsupported OS/Missing depedancy! (missing PSCore6+, NetTCPIP, or even .net.sockets.tcpClient)! Aborting!" ;
    } ; 
} ;
#endregion FUNCTION TEST_PORT ; #*------^ END Function Test-Port ^------
# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdBPjCWQQaJYKUwZxobfNs7Z/
# C2ugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSnzPFs
# 03k+dt6KrYdmOdXriXY1nzANBgkqhkiG9w0BAQEFAASBgKwmJ14ZwrxfOoEcRfJr
# RY3k/N9dRksyFdAp9bTOXZemYr+bI3CaQue/6hHO3evrRny6J1/6y/qhhTBaTYIT
# ielL7wDJOIGZajcLYBrd/ZbkPJGBgw5M5FNNT9qmOkrWPJVrD4PvKQh6sTQ423YB
# UIvb+NUSuRq4sAzBn1PyNFpn
# SIG # End signature block
