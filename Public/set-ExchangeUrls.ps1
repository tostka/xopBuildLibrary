#region SET_EXCHANGEURLS ; #*------v FUNCTION set-ExchangeUrls v------
function set-ExchangeUrls{
        <#
        .SYNOPSIS
        Configure-ExchangeURLsPC.ps1 - PowerShell script to configure the Client Access server URLs for Microsoft Exchange Server 2013/2016. All Client Access server URLs will be set to the same namespace.
        .NOTES
        Version     : 0.0.
        Author      : Paul Cunningham
        Website     : https://paulcunningham.me
        Twitter     : @paulcunningham / https://twitter.com/paulcunningham
        AddedCredit      : Todd Kadrie
        AddedWebsite     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2014-11-13
        FileName    : Configure-ExchangeURLsPC.ps1
        License     : MIT License
        Copyright   : (c) 2015 Paul Cunningham
        Github      : https://github.com/tostka/powershellbb/
        Tags        : Powershell
        REVISIONS
        * 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
        * 3:48 PM 7/24/2025 validated 6400T; fixed minor echo typos;  added hybrid output of write-log & write-my* cmdlets (for use under install-Exchange15.ps1); added return summary object for each configured target server.
        * 1:38 PM 7/22/2025 converted to function for use with install-Exchange15.ps1 (output conventsions)
        * 2:16 PM 7/8/2025 updated CBH for AutodiscoverSCP; expanded examples and HelpMsg to indicate hostnames are expected for the Internal/ExternalURL params; added -whatif support, for testing
        * 1:34 PM 7/7/2025 added logic for $env:userdomain spec (untested) ; v1.06 ren'd ConfigureExchangeURLs.ps1 -> Configure-ExchangeURLsPC.ps1; updated CBH; put into OTB format; added HelpMsg to params
        V1.00, 13/11/2014 - Initial version
        V1.01, 26/06/2015 - Added MAPI/HTTP URL configuration
        V1.02, 27/08/2015 - Improved error handling, can now specify multiple servers to configure at once.
        V1.03, 09/09/2015 - ExternalURL can now be $null
        V1.04, 17/11/2016 - Removed Outlook Anywhere auth settings, script now sets URLs only
        V1.05, 18/11/2016 - Added AutodiscoverSCP option so it can be set to a different URL than other services
        .DESCRIPTION
        Configure-ExchangeURLsPC.ps1 - PowerShell script to configure the Client Access server URLs
        for Microsoft Exchange Server 2013/2016. All Client Access server
        URLs will be set to the same namespace.

        If you are using separate namespaces for each CAS service this script will
        not handle that.

        The script sets Outlook Anywhere to use NTLM with SSL required by default.
        If you have different auth requirements for Outlook Anywhere  use the optional
        parameters to set those.

        -AutodiscoverSCP AutodiscoverSCP to permit a different URL than other services: 

        Represents a a variant hostname, aside from the standard reuse of the -InternalURL hostname specified. 
        Is set in this script via: 
        Set-ClientAccessServer -AutoDiscoverServiceInternalUri https://$AutodiscoverSCP/Autodiscover/Autodiscover.xml

        In most cases, this will match the InternalURL hostname (hence it's reuse to set this value, unless AutodiscoverSCP override value is specified). 

        .PARAMETER Server
        The name(s) of the server(s) you are configuring.
        .PARAMETER InternalURL
        The internal namespace you are using (the hostname in the configured URLs).[-InternalURL 'host.domain.com']
        .PARAMETER ExternalURL
        The external namespace you are using (the hostname in the configured URLs).[-ExternalURL 'host.domain.com']
        AutodiscoverSCP
        Optional alt hostname for use to construct the CAS AutoDiscoverServiceInternalUri.[-AutodiscoverSCP 'g.qd.n']
        .PARAMETER InternalSSL
        Specifies the internal SSL requirement for Outlook Anywhere. Defaults to True (SSL required).[-InternalSSL:`$false]
        .PARAMETER ExternalSSL
        Specifies the external SSL requirement for Outlook Anywhere. Defaults to True (SSL required).[-ExternalSSL:`$false]
        .PARAMETER whatIf
        Whatif Flag  [-whatIf]
        .INPUTS
        None. Does not accepted piped input.(.NET types, can add description)
        .OUTPUTS
        PsCustomObject returned summary per server configured.
        .EXAMPLE
        PS> .\Configure-ExchangeURLsPC.ps1 -Server sydex1 -InternalURL mail.exchangeserverpro.net -ExternalURL mail.exchangeserverpro.net
        .EXAMPLE
        PS> .\Configure-ExchangeURLsPC.ps1 -Server sydex1,sydex2 -InternalURL mail.exchangeserverpro.net -ExternalURL mail.exchangeserverpro.net
        PS> $whatif = $true ; 
        PS> $pltCfgExUrls=[ordered]@{
        PS>     Server = SERVER; 
        PS>     InternalURL = 'HOST.DOMAIN.COM' ; 
        PS>     ExternalURL = 'HOST.DOMAIN.COM' ; 
        PS>     whatif = $($whatif) ; 
        PS> } ;
        PS> $smsg = ".\Configure-ExchangeURLsPC.ps1 w`n$(($pltCfgExUrls|out-string).trim())" ; 
        PS> if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS> .\Configure-ExchangeURLsPC.ps1 @pltCfgExUrls ; 
        Demo splatted call with whatif
        .LINK
        http://exchangeserverpro.com/powershell-script-configure-exchange-urls/
        .LINK
        https://github.com/cunninghamp
        .LINK
        https://github.com/tostka/powershellbb/
        #>
        ####requires -version 2 # conflicts with main script version spec
        [CmdletBinding()]
        PARAM(
	        [Parameter( Position=0,Mandatory=$true,HelpMessage="The name(s) of the server(s) you are configuring.")]
	            [string[]]$Server,
	        [Parameter( Mandatory=$false,HelpMessage="The internal namespace you are using (the hostname in the configured URLs).[-InternalURL 'host.domain.com']")]
	            [string]$InternalURL,
	        [Parameter( Mandatory=$false,HelpMessage="The external namespace you are using (the hostname in the configured URLs).[-ExternalURL 'host.domain.com']")]
                [AllowEmptyString()]
	            [string]$ExternalURL,
	        [Parameter( Mandatory=$false,HelpMessage="Optional alt hostname for use to construct the CAS AutoDiscoverServiceInternalUri.[-AutodiscoverSCP 'g.qd.n']")]
	            [string]$AutodiscoverSCP,
            [Parameter( Mandatory=$false,HelpMessage="Specifies the internal SSL requirement for Outlook Anywhere. Defaults to True (SSL required).[-InternalSSL:`$false]")]
                [Boolean]$InternalSSL=$true,
            [Parameter( Mandatory=$false,HelpMessage="Specifies the external SSL requirement for Outlook Anywhere. Defaults to True (SSL required).[-ExternalSSL:`$false]")]
                [Boolean]$ExternalSSL=$true,
            [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
                [switch] $whatIf # =$true
        ) ; 
        BEGIN {
            #region CONNECT_XOPLOCAL ; #*------v connect-XopLocal v------
            $tcmdlet = 'Set-ClientAccessServer' ; 
            $cmd = $null; $cmd = get-command $tcmdlet -erroraction 0 ;
            if(-not $cmd){
                if($xopconn = connect-XopLocalManagementShell){
                    if($ExPSS = get-pssession | ? { $_.ComputerName -match "^$($env:computername)" -AND $_.ConfigurationName -eq 'Microsoft.Exchange' } | sort id -Descending | select -first 1 ){
                        TRY{
                            $cmd = $null; $cmd = get-command $tcmdlet -erroraction 0 ;
                            if(-not $cmd){
                                $smsg = "Missing $($cmdlet): re-importing PSSession..." ;
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                                $ExIPSS = Import-PSSession $ExPSS -allowclobber -ea STOP ;
                            } ; 
                            $cmd = $null; $cmd = get-command 'Get-OrganizationConfig' -erroraction stop ;
                            $smsg = "Connected to: $($expss.computername)" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        } CATCH {
                            $ErrTrapd=$Error[0] ;
                            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            BREAK ;
                        } ;
                    } ;
                } else {
                    $smsg = "NOT CONNECTED!"
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    BREAK ; 
                } ;
            } ;
            #endregion CONNECT_XOPLOCAL ; #*------^ END connect-XopLocal ^------

            if(-not $ExternalUrl){
                switch($env:userdomain){
                    'TORO'{
                        $ExternalURL = 'mymail.toro.com' ; 
                    }
                    'TORO-LAB'{
                        $ExternalURL = 'mymail.torolab.com'
                    }
                    default{
                        if(-not $ExternalURL){
                            $smsg = "Unconfigured `$env:userdomain:$($env:userdomain)!" ; 
                            $smsg += "`nSpecify explicit -ExternalURL & -InternalURL keyed to the target domain" ;
                            if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error}
                                else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        } else { 
                            $smsg = "Unconfigured `$env:userdomain:$($env:userdomain)" ; 
                            $smsg = "-> using specified:" ; 
                            $smsg += "`n-ExternalURL: $($ExternalURL)" ;
                            $smsg += "`n-InternalURL: $($InternalURL)" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;

                        } ; 
                    }
                } ; 
            } ; 
            if(-not $InternalUrl){
                switch($env:userdomain){
                    'TORO'{
                        $InternalUrl = 'mymail.toro.com' ; 
                    }
                    'TORO-LAB'{
                        $InternalUrl = 'mymail.torolab.com'
                    }
                    default{
                        if(-not $InternalUrl){
                            $smsg = "Unconfigured `$env:userdomain:$($env:userdomain)!" ; 
                            $smsg += "`nSpecify explicit -ExternalURL & -InternalURL keyed to the target domain" ;
                            if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error}
                                else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        } else { 
                            $smsg = "Unconfigured `$env:userdomain:$($env:userdomain)" ; 
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        } ; 
                    }
                } ; 
            } ; 
            $smsg = "-> using hostnames:" ; 
            $smsg += "`n-ExternalURL: $($ExternalURL)" ;
            $smsg += "`n-InternalURL: $($InternalURL)" ;
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
        } ; 
        PROCESS {

            foreach ($i in $server){
                if ((Get-ExchangeServer $i -ErrorAction SilentlyContinue).IsClientAccessServer){
                    $smsg = "----------------------------------------"
                    $smsg += "`n Configuring $i"
                    $smsg += "`n----------------------------------------`r`n"
                    $smsg += "`nValues:"
                    $smsg += "`n - Internal URL: $InternalURL"
                    $smsg += "`n - External URL: $ExternalURL"
                    $smsg += "`n - Outlook Anywhere internal SSL required: $InternalSSL"
                    $smsg += "`n - Outlook Anywhere external SSL required: $ExternalSSL"
                    $smsg += "`n`r`n"
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;

                    $smsg = "Configuring Outlook Anywhere URLs"
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                    $OutlookAnywhere = Get-OutlookAnywhere -Server $i
                    $OutlookAnywhere | Set-OutlookAnywhere -ExternalHostname $externalurl -InternalHostname $internalurl `
                                        -ExternalClientsRequireSsl $ExternalSSL -InternalClientsRequireSsl $InternalSSL `
                                        -ExternalClientAuthenticationMethod $OutlookAnywhere.ExternalClientAuthenticationMethod -WhatIf:$($whatif) ;

                    if ($externalurl -eq ""){
                        $smsg = "Configuring Outlook Web App URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-OwaVirtualDirectory -Server $i | Set-OwaVirtualDirectory -ExternalUrl $null -InternalUrl https://$internalurl/owa -WhatIf:$($whatif) ;

                        $smsg = "Configuring Exchange Control Panel URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-EcpVirtualDirectory -Server $i | Set-EcpVirtualDirectory -ExternalUrl $null -InternalUrl https://$internalurl/ecp -WhatIf:$($whatif) ;

                        $smsg = "Configuring ActiveSync URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-ActiveSyncVirtualDirectory -Server $i | Set-ActiveSyncVirtualDirectory -ExternalUrl $null -InternalUrl https://$internalurl/Microsoft-Server-ActiveSync -WhatIf:$($whatif) ;

                        $smsg = "Configuring Exchange Web Services URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-WebServicesVirtualDirectory -Server $i | Set-WebServicesVirtualDirectory -ExternalUrl $null -InternalUrl https://$internalurl/EWS/Exchange.asmx -WhatIf:$($whatif) ;

                        $smsg = "Configuring Offline Address Book URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-OabVirtualDirectory -Server $i | Set-OabVirtualDirectory -ExternalUrl $null -InternalUrl https://$internalurl/OAB -WhatIf:$($whatif) ;

                        $smsg = "Configuring MAPI/HTTP URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-MapiVirtualDirectory -Server $i | Set-MapiVirtualDirectory -ExternalUrl $null -InternalUrl https://$internalurl/mapi -WhatIf:$($whatif) ;
                    }else{
                        $smsg = "Configuring Outlook Web App URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-OwaVirtualDirectory -Server $i | Set-OwaVirtualDirectory -ExternalUrl https://$externalurl/owa -InternalUrl https://$internalurl/owa -WhatIf:$($whatif) ;

                        $smsg = "Configuring Exchange Control Panel URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-EcpVirtualDirectory -Server $i | Set-EcpVirtualDirectory -ExternalUrl https://$externalurl/ecp -InternalUrl https://$internalurl/ecp -WhatIf:$($whatif) ;

                        $smsg = "Configuring ActiveSync URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-ActiveSyncVirtualDirectory -Server $i | Set-ActiveSyncVirtualDirectory -ExternalUrl https://$externalurl/Microsoft-Server-ActiveSync -InternalUrl https://$internalurl/Microsoft-Server-ActiveSync -WhatIf:$($whatif) ;

                        $smsg = "Configuring Exchange Web Services URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-WebServicesVirtualDirectory -Server $i | Set-WebServicesVirtualDirectory -ExternalUrl https://$externalurl/EWS/Exchange.asmx -InternalUrl https://$internalurl/EWS/Exchange.asmx -WhatIf:$($whatif) ;

                        $smsg = "Configuring Offline Address Book URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-OabVirtualDirectory -Server $i | Set-OabVirtualDirectory -ExternalUrl https://$externalurl/OAB -InternalUrl https://$internalurl/OAB -WhatIf:$($whatif) ;

                        $smsg = "Configuring MAPI/HTTP URLs"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Get-MapiVirtualDirectory -Server $i | Set-MapiVirtualDirectory -ExternalUrl https://$externalurl/mapi -InternalUrl https://$internalurl/mapi -WhatIf:$($whatif) ;
                    }

                    $smsg = "Configuring Autodiscover"
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                    if ($AutodiscoverSCP) {
                        Get-ClientAccessServer $i | Set-ClientAccessServer -AutoDiscoverServiceInternalUri https://$AutodiscoverSCP/Autodiscover/Autodiscover.xml -WhatIf:$($whatif) ;
                    }else{
                        Get-ClientAccessServer $i | Set-ClientAccessServer -AutoDiscoverServiceInternalUri https://$internalurl/Autodiscover/Autodiscover.xml -WhatIf:$($whatif) ;
                    }
                    # 11:25 AM 7/24/2025 make it return a summary object for each run
                    $errorAct = 'STOP' ; 
                    $prpOut = 'ExternalUrl','InternalUrl'
                    $owa = Get-OwaVirtualDirectory -Server $i -ea $errorAct | select $prpOut ;
                    $ECPV = Get-EcpVirtualDirectory -Server $i  -ea $errorAct| select $prpOut ;
                    $ASV = Get-ActiveSyncVirtualDirectory -Server $i  -ea $errorAct| select $prpOut ;
                    $WSV = Get-WebServicesVirtualDirectory -Server $i  -ea $errorAct| select $prpOut ;
                    $OAB = Get-OabVirtualDirectory -Server $i  -ea $errorAct| select $prpOut ;
                    $MVD = Get-MapiVirtualDirectory -Server $i  -ea $errorAct| select $prpOut ;
                    $AutoD = Get-ClientAccessServer $i | select AutoDiscoverServiceInternalUri ;
                    $returnObj = [ordered]@{
                        OwaVirtualDirectoryExternalUrl = if($owa){$owa.ExternalUrl} ;
                        OwaVirtualDirectoryInternalUrl = if($owa){$owa.InternalUrl} ;
                        EcpVirtualDirectoryExternalUrl = if($ECPV){$ECPV.ExternalUrl} ;                        
                        EcpVirtualDirectoryInternalUrl = if($ECPV){$ECPV.InternalUrl}  ; 
                        ActiveSyncVirtualDirectoryExternalUrl = if($ASV){$ASV.ExternalUrl}  ; 
                        ActiveSyncVirtualDirectoryInternalUrl = if($ASV){$ASV.InternalUrl}  ; 
                        WebServicesVirtualDirectoryExternalUrl = if($WSV){$WSV.ExternalUrl}  ; 
                        WebServicesVirtualDirectoryInternalUrl = if($WSV){$WSV.InternalUrl}  ; 
                        OabVirtualDirectoryExternalUrl = if($OAB){$OAB.ExternalUrl}  ; 
                        OabVirtualDirectoryInternalUrl = if($OAB){$OAB.InternalUrl}  ; 
                        MapiVirtualDirectoryExternalUrl = if($MVD){$MVD.ExternalUrl}  ; 
                        MapiVirtualDirectoryInternalUrl = if($MVD){$MVD.InternalUrl}  ; 
                        AutoDiscoverServiceInternalUri =  if($AutoD){$AutoD.AutoDiscoverServiceInternalUri}  ; 
                    } ; 
                    $smsg = "Returning summary object to pipeline" ;
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                    [pscustomobject]$returnObj | write-output 
                    #$smsg = "`r`n"
                }else{
                    $smsg = "$i is not a Client Access server."
                    if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error}
                        else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                }
            } # loop-E
        } ; 
        END {
            $smsg = "Finished processing all servers specified. Consider running Get-CASHealthCheck.ps1 to test your Client Access namespace and SSL configuration."
            $smsg += "`nRefer to http://exchangeserverpro.com/testing-exchange-server-2013-client-access-server-health-with-powershell/ for more details."
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
        } ; 
    }
#endregion SET_EXCHANGEURLS ; #*------^ END FUNCTION set-ExchangeUrls  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUK3rHNnHY8LyjRyn0er16L0fV
# iEegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBST/2pi
# 0McRZCilUBejOOoP3v3zbDANBgkqhkiG9w0BAQEFAASBgJCO2kvvvO7XB5GhjhEI
# xu1Fs8p2WZqUfyHe6QV2yPCKIRdAEYde2mZLYHQ0mS6HqwKNcgYrFq0+qCw+QasF
# uWSsICGmgCwKPaG2NgEFEL9Wp7PDNOST11SzS//sJyOoJ/DIO+mIzd1wcSWBeoZe
# AmL31S0fTasDTfTTI9Zn60mM
# SIG # End signature block
