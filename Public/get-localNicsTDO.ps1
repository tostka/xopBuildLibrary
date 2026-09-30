# get-localNicsTDO.ps1


#region GET_LOCALNICSTDO ; #*------v get-localNicsTDO v------
function get-localNicsTDO {
        <#
        .SYNOPSIS
        get-localNicsTDO - Quick summary of local Drives, encapsulates highlights of Get-NetAdapter, get-netipaddress & Get-NetIPInterface. 
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-07-17
        FileName    : get-localNicsTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-network
        Tags        : Powershell
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 10:06 AM 8/14/2025 add: -NoAutoIP & -NoDhcp params, to exclude wo need to postfilter ;  ren: show-localNicsTDO -> get-localNicsTDO, alias orig name
        * 3:40 PM 8/13/2025 init, added to xopBuildLibary.ps1 & verb-network
        .DESCRIPTION
        get-localNicsTDO - Quick summary of local Drives, encapsulates highlights of Get-NetAdapter, get-netipaddress & Get-NetIPInterface. 

        Returns PSCustomObject array with following properties:

            A typical Static IPv4 Nic:

            Name                 : Ethernet
            Status               : Up
            LinkSpeed            : 10 Gbps
            MediaType            : 802.3
            MediaConnectionState : Connected
            ifIndex              : 2
            ifDesc               : vmxnet3 Ethernet Adapter
            ipAddress            : 123.456.9.6
            ipInterfaceIndex     : 2
            ipInterfaceAlias     : Ethernet
            ipAddressFamily      : IPv4
            ipType               : Unicast
            ipPrefixLength       : 24
            ipiInterfaceMetric   : 15
            isDHCP               : False
            isAutoIPRange        : False

            A typcial unconfigured DHCP nic defaulting to APIPA auto-ip.

            Name                 : Ethernet1
            Status               : Up
            LinkSpeed            : 10 Gbps
            MediaType            : 802.3
            MediaConnectionState : Connected
            ifIndex              : 4
            ifDesc               : vmxnet3 Ethernet Adapter #2
            ipAddress            : 169.254.167.181
            ipInterfaceIndex     : 4
            ipInterfaceAlias     : Ethernet1
            ipAddressFamily      : IPv4
            ipType               : Unicast
            ipPrefixLength       : 16
            ipiInterfaceMetric   : 15
            isDHCP               : True
            isAutoIPRange        : True

            - isAutoIPRange reflects a simple regex test of ipAddress against '^169\.254\.' 
                (the Automatic Private IP Addressing (APIPA) range 169.254.0.1 to 169.254.255.254).
            - ipiInterfaceMetric (from Get-NetIPInterface) can be used to resolve binding order: Lower metric is prioritized (e.g. lower is higher in the binding order).

        .PARAMETER NoAutoIP
        Switch to exclude APIPA auto-assigned IP nics (unconfigured)
        .PARAMETER NoDHCP
        Switch to exclude DHCP-enabled nics (static-IP only returned)
        .INPUTS
        None. Does not accepted piped input.
        .OUTPUTS
        System.Object[] summary properties
        .EXAMPLE
        PS> $localNics = get-localNicsTDO | ?{-not $_.isAutoIPRange} ; 
        PS> $localNics  ; 
        
            Name                 : Ethernet
            Status               : Up
            LinkSpeed            : 10 Gbps
            MediaType            : 802.3
            MediaConnectionState : Connected
            ifIndex              : 2
            ifDesc               : vmxnet3 Ethernet Adapter
            ipAddress            : 123.456.9.6
            ipInterfaceIndex     : 2
            ipInterfaceAlias     : Ethernet
            ipAddressFamily      : IPv4
            ipType               : Unicast
            ipPrefixLength       : 24
            ipiInterfaceMetric   : 15
            isDHCP               : False
            isAutoIPRange        : False
         
        Demo typical pass, with postfilter to exclude isAutoIPRange nics (APIPA, e.g. unconfigured, non-Static/non-DHCP)
        .EXAMPLE
        PS> $localNics = get-localNicsTDO -NoAutoIP -NoDHCP} ; 
        PS> $localNics  ; 
        
            Name                 : Ethernet
            Status               : Up
            LinkSpeed            : 10 Gbps
            MediaType            : 802.3
            MediaConnectionState : Connected
            ifIndex              : 2
            ifDesc               : vmxnet3 Ethernet Adapter
            ipAddress            : 123.456.9.6
            ipInterfaceIndex     : 2
            ipInterfaceAlias     : Ethernet
            ipAddressFamily      : IPv4
            ipType               : Unicast
            ipPrefixLength       : 24
            ipiInterfaceMetric   : 15
            isDHCP               : False
            isAutoIPRange        : False
         
        Demo typical pass, using -NoAutoIP & -NoDhcp (vs post filtering in frst demo)
        .LINK
        https://github.com/tostka/verb-network
        #>
        [CmdletBinding()]
        [Alias('show-localNicsTDO','get-localNics')]
        PARAM(
            [Parameter(Mandatory = $false, HelpMessage = "Switch to exclude APIPA auto-assigned IP nics (unconfigured)")]
                [switch]$NoAutoIP,
            [Parameter(Mandatory = $false, HelpMessage = "Switch to exclude DHCP-enabled nics (static-IP only returned)")]
                [switch]$NoDHCP
        );
        TRY{
            $nicsActive = Get-NetAdapter | ?{$_.Status -eq 'Up' -AND $_.MediaConnectionState -eq 'Connected'}; 
            $nics = @() ; 
            $nicsActive | foreach-object{        
                $thisnic = $_ ; 
                $nicInfo = [ordered]@{                    
                    Name = $thisnic.Name ;  # Ethernet
                    Status = $thisnic.Status ; # Up
                    LinkSpeed = $thisnic.LinkSpeed ; # 10 Gbps
                    MediaType = $thisnic.MediaType ; # 802.3
                    MediaConnectionState = $thisnic.MediaConnectionState ; # Connected
                    ifIndex = $thisnic.ifIndex ; # 2
                    ifDesc = $thisnic.ifDesc ; # vmxnet3 Ethernet Adapter    
                    ipAddress = $null ; # 123.456.9.6
                    ipInterfaceIndex = $null ; # 2
                    ipInterfaceAlias = $null ; # Ethernet
                    ipAddressFamily = $null ; # IPv4
                    ipType = $null ; # Unicast
                    ipPrefixLength = $null ; # 24
                    ipiInterfaceMetric = $null ; 
                    isDHCP = $null ; 
                    isAutoIPRange = $false ; 
                } ; 
                if($ipInfo = $thisnic | get-netipaddress){
                    $nicInfo.ipAddress = $ipInfo.ipAddress ; # 123.456.9.6
                    if($nicInfo.ipAddress -match '^169\.254\.'){
                        $nicInfo.isAutoIPRange = $true ;
                        $smsg = "NIC:$($nicInfo.name) is unused APIPA/AutoIP'd!: $($nicInfo.ipAddress)" ;
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                
                        } ;
                    } ; 
                    $nicInfo.ipInterfaceIndex =$ipInfo.InterfaceIndex ; # 2
                    $nicInfo.ipInterfaceAlias =$ipInfo.InterfaceAlias ; # Ethernet
                    $nicInfo.ipAddressFamily =$ipInfo.AddressFamily ; # IPv4
                    $nicInfo.ipType =$ipInfo.Type ; # Unicast
                    $nicInfo.ipPrefixLength =$ipInfo.PrefixLength ; # 24
                    if($ipBindInfo = $thisnic | Get-NetIPInterface |?{$_.ConnectionState -eq 'Connected'}){
                        $nicInfo.ipiInterfaceMetric = $ipBindInfo.InterfaceMetric ; 
                        $nicInfo.isDHCP = [boolean]($ipBindInfo.dhcp -eq 'Enabled')
                    } else { write-warning "No Get-NetIPInterface data returned" } 
                } else { write-warning "No get-netipaddress data returned" } ; 
                $nics += @([pscustomobject]$nicInfo)
            } ; 
            if($NoAutoIP){
                $nics = $nics |?{-not $_.isAutoIPRange} ; 
            }
            if($NoDhcp){
                $nics = $nics |?{-not $_.isDHCP} ; 
            } ; 
            $nics | write-output ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        } ; 
    }
#endregion GET_LOCALNICSTDO ; #*------^ END get-localNicsTDO ^------


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZQ0fVYpqJCkpVTDvVoGVb5fM
# 5TugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTLpFYj
# Ah/QL3kwJADnZDRDL5F30zANBgkqhkiG9w0BAQEFAASBgDHiBnTauQtmN5ssN28P
# hct3leJ6V4VXg38goMkSuAqUmwe43LtoYzbvDvC4Zea0rZgPNBe2kew4AnrIItmD
# CDCXa8SqHAgxiaon4O54KcARjVN6HrbNpxgZ/rww7JaQ6f44Lc0UI1L1rE2VIotz
# sP2fU7Ma4G9MXXZxYjD3YPXu
# SIG # End signature block
