#region SET_EXLICENSETDO ; #*------v FUNCTION set-ExLicenseTDO v------
function set-ExLicenseTDO{
        <#
        .SYNOPSIS
        set-ExLicenseTDO.ps1 - PowerShell script to configure Exchange server license key on local Exchange Server, will automatically recycle Information Store (MSExchangeIS), to complete application.
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        AddedCredit      : Todd Kadrie
        AddedWebsite     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-10-20
        FileName    : set-ExLicenseTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/powershellbb/
        Tags        : Powershell,Exchange,ExchangeServer,License,Maintenance,Build
        REVISIONS
        * 2:43 PM 12/2/2025 updated connect-xopLocalManagementShell wrapper logic; 
             ✅ got thru exec pass in lab; ✅ got through whatif pass in lab
        * 3:25 PM 12/1/2025 🚧 🐛 🔊 updated transcript build code, to include module-hosted func support, when local, non-AllUsers profile hosted; updated write-log/write-my* interaction to halt recursive loop (when no $state vari)
        * 10:42 AM 11/24/2025 ren set-ExLicenseTDO -> set-ExLicenseTDOTDO (alias orig name) (standard naming)
        * 4:58 PM 10/20/2025 Initial version
        
        .DESCRIPTION
        set-ExLicenseTDO.ps1 - PowerShell script to configure Exchange server license key on local Exchange Server, will automatically recycle Information Store (MSExchangeIS), to complete application.

        .PARAMETER Server
        The name(s) of the server(s) you are configuring.
        .PARAMETER LicenseKey
        Microsoft Exchange Server License Key to be applied[-licKey 'nAAAn-AnAAA-Annnn-nAnAA-AnAAA']        
        .PARAMETER useEnterpriseLicense
        useEnterpriseLicense
        .PARAMETER whatIf
        Whatif Flag  [-whatIf]
        .INPUTS
        None. Does not accepted piped input.(.NET types, can add description)
        .OUTPUTS
        PsCustomObject returned summary per server configured.
        .EXAMPLE
        PS> $bRet = set-ExLicenseTdo -Server aaaaa9999A -useEnterpriseLicense -verbose -whatif:$true ; 
        PS> $bRet ; 

            Name                          : AAAAA9999A
            IsExchangeTrialEdition        : False
            IsExpiredExchangeTrialEdition : False
            RemainingTrialPeriod          : 00:00:00
            LicenseKey                    : 9AAA9-A9AAA-A9999-9A9AA-A9AAA
            isLicensed   

        Typical parameter pass
        .EXAMPLE
        PS> $whatif = $true ; 
        PS> $pltSExLic=[ordered]@{
        PS>     Server = SERVER; 
        PS>     LicenseKey = 'nAAAn-AnAAA-Annnn-nAnAA-AnAAA' ; 
        PS>     useEnterpriseLicense = $true ; 
        PS>     whatif = $($whatif) ; 
        PS> } ;
        PS> $smsg = "set-ExLicenseTDO w`n$(($pltSExLic|out-string).trim())" ; 
        PS> if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS> $bRet = set-ExLicenseTDO @pltSExLic ; 
        PS> $bRet ; 

            Name                          : AAAAA9999A
            IsExchangeTrialEdition        : False
            IsExpiredExchangeTrialEdition : False
            RemainingTrialPeriod          : 00:00:00
            LicenseKey                    : 9AAA9-A9AAA-A9999-9A9AA-A9AAA
            isLicensed                    : True

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
        [Alias('set-ExLicense')]
        PARAM(
	        [Parameter( Position=0,Mandatory=$true,HelpMessage="The name(s) of the server(s) you are configuring.")]
	            [string[]]$Server,
	        [Parameter( Mandatory=$false,HelpMessage="Microsoft Exchange Server License Key to be applied (defaults to local cached file discovery)[-licKey 'nAAAn-AnAAA-Annnn-nAnAA-AnAAA']")]
                [Alias('licKey')]
	            [string]$LicenseKey,
            #EnterpriseLicense
            [Parameter(HelpMessage="When no explicit -LicenseKey is specified, this switch specifies to use the discovered version EnterpriseLicense (vs default StandardLicense use)[-useEnterpriseLicense]")]
                [switch] $useEnterpriseLicense,
            [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
                [switch] $whatIf # =$true
        ) ; 
        BEGIN {
            #region TRANSCRIPT_NODEP ; #*------v TRANSCRIPT FROM ENV WO DEPS FOR SCRIPT, FUNC, ADVFUNC v------
            # VERS: 20251201-0257PM # revised module-hosted Func pathing
            $Verbose = [boolean]($VerbosePreference -eq 'Continue') ;
            $rPSCmdlet = $PSCmdlet ;
            ${CmdletName} = $rMyInvocation.InvocationName.MyCommand.Name ;
            $rPSScriptRoot = $PSScriptRoot ;
            $rPSCommandPath = $PSCommandPath ;
            $rMyInvocation = $MyInvocation ;
            $rPSBoundParameters = $PSBoundParameters ;
            $smsg = "`$rPSCmdlet : `n$(($rPSCmdlet|out-string).trim())`n`n" ; 
            $smsg += "`n`${CmdletName} : `n$((${CmdletName}|out-string).trim())`n`n" ; 
            $smsg += "`n`$rPSScriptRoot : `n$(($rPSScriptRoot |out-string).trim())`n`n" ; 
            $smsg += "`n`$rPSCommandPath : `n$(($rPSCommandPath|out-string).trim())`n`n" ; 
            $smsg += "`n`$rMyInvocation : `n$(($rMyInvocation|out-string).trim())`n`n" ; 
            $smsg += "`n`$rPSBoundParameters : `n$(($rPSBoundParameters|out-string).trim())`n`n" ; 
            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            if($rMyInvocation.mycommand.commandtype -eq 'ExternalScript'){
                $cmdType = 'Script' ; $isScript = $true ; $isfunc = $false ; $isFuncAdv = $false  ; 
                if($rMyInvocation.InvocationName){
                    if($rMyInvocation.InvocationName -AND $rMyInvocation.InvocationName -ne '.'){
                        $CmdPathed = (resolve-path $rMyInvocation.InvocationName -ea STOP).path ; 
                    }elseif($rMyInvocation.mycommand.definition -and (test-path -path $rMyInvocation.mycommand.definition -pathtype Leaf)){
                        $CmdPathed = (resolve-path $rMyInvocation.mycommand.definition -ea STOP).path ; 
                    }
                    $CmdName= split-path $CmdPathed -ea 0 -leaf ; 
                    $CmdParentDir = split-path $CmdPathed -ea 0 ; 
                    $CmdNameNoExt = [system.io.path]::GetFilenameWithoutExtension($CmdPathed) ;
                    $smsg = "`$isScript : $(($isScript|out-string).trim())" ; 
                    $smsg += "`n`$CmdPathed  : $(($CmdPathed|out-string).trim())" ; 
                    $smsg += "`n`$CmdParentDir  : $(($CmdParentDir|out-string).trim())" ; 
                    $smsg += "`n`$CmdNameNoExt  : $(($CmdNameNoExt|out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } else{
                    throw "Unpopulated dependant:`$rMyInvocation.InvocationName!" ; 
                } ;     
            }elseif($rMyInvocation.mycommand.commandtype -eq 'Function'){
                $cmdType = 'Function' ; $isScript = $false ; $isfunc = $true ; $isFuncAdv = $false  ; 
                if($rMyInvocation.mycommand.name){
                    $CmdName = $rMyInvocation.mycommand.name ; 
                    $CmdNameNoExt = [system.io.path]::GetFilenameWithoutExtension($CmdName) ;             
                } ; 
                if($rMyInvocation.ScriptName){
                    if($CmdParentPathed = (resolve-path -path $rMyInvocation.ScriptName).path){
                        $CmdParentDir = split-path $CmdParentPathed ;                  
                        write-verbose "Hosted function, mock it up as a proxy path for transcription name" ; 
                        $CmdParentPathedExt = [regex]::match($CmdParentPathed,'(\.\w+$)').value
                        $CmdPathed = (join-path -Path $CmdParentDir -ChildPath "$($CmdName)$($CmdParentPathedExt)")           
                    } else{
                        throw "emtpy `$rMyInvocation.ScriptName!, unable to calculate isFunc: `$CmdParentDir!" ; 
                    }
                }elseif($rPSCmdlet.MyInvocation.mycommand.commandtype -eq 'Function' -AND $rPSCmdlet.MyInvocation.mycommand.modulename -AND $rPSCmdlet.MyInvocation.mycommand.Module.path){
                    # cover function, pathed into the Module.path
                    if($CmdParentPathed = (resolve-path -path $rPSCmdlet.MyInvocation.mycommand.Module.path).path){
                        $CmdParentDir = split-path $CmdParentPathed ;                  
                        write-verbose "Hosted function, mock it up as a proxy path for transcription name" ; 
                        $CmdParentPathedExt = [regex]::match($CmdParentPathed,'(\.\w+$)').value
                        $CmdPathed = (join-path -Path $CmdParentDir -ChildPath "$($CmdName)$($CmdParentPathedExt)")   
                    } else{
                        throw "emtpy `$rMyInvocation.ScriptName!, unable to calculate isFunc: `$CmdParentDir!" ; 
                    }
                } ; 
                if($isFunc -AND ((gv rPSCmdlet -ea 0).value -eq $null)){
                    $isFuncAdv = $false
                } elseif($isFunc) {
                    $isFuncAdv = [boolean]($isFunc -AND $rMyInvocation.InvocationName -AND ($CmdName -eq $rMyInvocation.InvocationName))         
                }
                $smsg = "`$isfunc : $(($isfunc|out-string).trim())" ; 
                $smsg += "`n`$CmdName :$(($CmdName|out-string).trim())" ; 
                $smsg += "`n`$CmdParentPathed : $(($CmdParentPathed|out-string).trim())" ; 
                $smsg += "`n`$CmdParentDir : $(($CmdParentDir|out-string).trim())" ; 
                $smsg += "`n`$CmdPathed (log proxy) : $(($CmdPathed|out-string).trim())" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } else{
                throw "unrecognized environment combo: unable to resolve Script v Function v FuncAdv!" ; 
            } ;
            if(-not (get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
            foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
            # use local calc'd: workstations freq have ODFB etc, recalc always works
            $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
            $rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;
            if(($CmdPathed  -match $rgxPSAllUsersScope) -OR ($CmdPathed  -match $rgxPSCurrUserScope)){
                switch -regex ($CmdPathed){
                    $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                    $rgxPSCurrUserScope{$smsg = "CurrentUser"}
                } ;
                $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
                write-verbose $smsg  ;
                $transcript = "$($budrv):\scripts\logs"        
            } else {
                $transcript = "$($CmdParentDir)\logs"
            } ;    
            if(-not (test-path $transcript -PathType Container)){mkdir $transcript -verbose } ; 
            $transcript +=  "\$($CmdNameNoExt)" ;
            # add server name
            $transcript +=  "-$($Server -join ',')" ;
            if(get-variable whatif -ea 0){
                $transcript += "-WHATIF"
                if(-not $whatif){$transcript = $transcript.replace('-WHATIF','-EXECUTE')} 
            } ; 
            #$transcript = "d:\cab\$($env:computername)-set-ExLicenseTDO-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt" ; 
            #VARIANT: $transcript += "-LASTPASS-trans-log.txt" ;
            $transcript += "-$(get-date -format 'yyyyMMdd-HHmmtt')-trans.txt" ; 
            $logfile = $transcript.replace('-trans','-log') ; 
            $logging = [boolean](get-command write-log -ea 0) ; 
            $smsg = "`$transcript: $($transcript)" ; 
            $smsg += "`n`$logfile: $($logfile)" ; 
            $smsg += "`n`$logging: $($logging)" ; 
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
            $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
            if($stopResults){
                $smsg = "Stop-transcript:$($stopResults)" ;   
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
            } ;
            $startResults = start-Transcript -path $transcript -whatif:$false -confirm:$false;
            if($startResults){
                $smsg = "start-transcript:$($startResults)" ;
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
            } ;
            # DON'T FORGET TO ADD STOP TO END{}!
            #endregion TRANSCRIPT_NODEP ; #*------^ END TRANSCRIPT FROM ENV WO DEPS FOR SCRIPT, FUNC, ADVFUNC ^------
            
            #$whatif = $true ;             
            $pltsExLic = [ordered]@{
                Identity = $NULL ;
                ProductKey = $LicenseKey;
                whatif = $($whatif) ;
                errorAction = 'STOP' ; 
            } ; 
            $pltgSvc = [ordered]@{
                Name = 'MSExchangeIS' 
                ComputerName = $null ; 
                #verbose = $true ; 
                errorAction = 'STOP' ; 
                #whatif = $($whatif) ;
            } ;
            $pltRtSvc = [ordered]@{
                #Name = 'MSExchangeIS' 
                #ComputerName = $null ; 
                #Force = $true ; 
                InputObject = $null ; 
                verbose = $true ; 
                errorAction = 'STOP' ; 
                whatif = $($whatif) ;
            } ;
            $RestartService = 'MSExchangeIS' 
            #$transcript = "d:\cab\$($env:computername)-set-ExLicenseTDO-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt" ; 

            $prpTrial = 'name','IsExchangeTrialEdition','IsExpiredExchangeTrialEdition','RemainingTrialPeriod'  ; 
           
            #region CONNECT_XOPLOCAL ; #*------v connect-XopLocal v------
            $tcmdlet = 'get-ExchangeServer' ; 
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

            <# # do licenses by resolved version
            if(-not $LicenseKey){
                $cabinfo = get-xopLocalExSetupVersionTDO -verbose
                $localLicenseKeyFile = "Ex16EnterpriseLicense.txt " ; 
            } ; 
            #>
        } ; 
        PROCESS {

            foreach ($srv in $server){                
                    $smsg = "----------------------------------------"
                    $smsg += "`n Configuring $srv"
                    $smsg += "`n----------------------------------------`r`n"
                    $smsg += "`nValues:"
                    $smsg += "`n - LicenseKey : $LicenseKey"
                    $smsg += "`n`r`n"
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;

                    #$pltRtSvc.COMPUTERNAME = $srv ; 
                    #$pltgSvc.ComputerName = $srv ; 

                    TRY{
                        $thisserver = get-exchangeserver -Identity $srv -ea STOP ; 
                        $pltsExLic.Identity = $thisserver.FQDN
                        $pltgSvc.ComputerName = $thisserver.FQDN

                    } CATCH {$ErrTrapd=$Error[0] ;
                        $smsg = "Unable to get-exchangeserver -Identity $($srv)! " ; 
                        write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                        $smsg += "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                        CONTINUE ; 
                    } ;
                    <#
                    if([double]$ExVersNumMajor = [regex]::match($thisserver.AdminDisplayVersion,"Version\s(\d+\.\d+)\s\(Build\s(\d+\.\d+)\)").groups[1].value){
                        switch -regex ([string]$ExVersNumMajor) {
                            '15\.2' { $isEx2019 = $true ; $ExVers = 'Ex2019' }
                            '15\.1' { $isEx2016 = $true ; $ExVers = 'Ex2016'}
                            '15\.0' { $isEx2013 = $true ; $ExVers = 'Ex2013'}
                            '14\..*' { $isEx2010 = $true ; $ExVers = 'Ex2010'}
                            '8\..*' { $isEx2007 = $true ; $ExVers = 'Ex2007'}
                            '6\.5' { $isEx2003 = $true ; $ExVers = 'Ex2003'}
                            '6|6\.0' {$isEx2000 = $true ; $ExVers = 'Ex2000'} ;
                            default {
                                $smsg = "UNRECOGNIZED ExchangeServer.AdminDisplayVersion.Major.Minor string:$($thisserver.version)! ABORTING!" ;
                                write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                            }
                        } ; 
                    }else {
                        $smsg = "UNABLE TO RESOLVE `$ExVersNumMajor from `$thisserver.version:$($thisserver.version)!" ; 
                        write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ; 
                        throw $smsg ; 
                        break ; 
                    } ; 
                    #>
                    # to diff SE from Ex2019, you need to do semversion on build
                    if(-not $LicenseKey){
                        $smsg = "Convert-xopAdminDisplayVersionTDO -AdminDisplayVersion $($thisserver.AdminDisplayVersion)..." ;                         
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                        $VersionNum = Convert-xopAdminDisplayVersionTDO -AdminDisplayVersion $thisserver.AdminDisplayVersion ;
                        $smsg = "Resolve-xopMajorVersionTDO -Version $($VersionNum)..." ;                         
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                        $VersInfo = Resolve-xopMajorVersionTDO -Version $VersionNum ;
                        if($useEnterpriseLicense){
                            [string]$Keyfile = "$($VersInfo)EnterpriseLicense.txt" ; 
                            $smsg = "-NoLicenseKey specified & -useEnterpriseLicense: discovering $($VersInfo) Enterprise License file:`n$($Keyfile)" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        }else{
                            [string]$Keyfile = "$($VersInfo)StandardLicense.txt" ; 
                            $smsg = "-NoLicenseKey specified & -useEnterpriseLicense *not* in use: discovering $($VersInfo) Standard License file:`n$($Keyfile)" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        }; 
                        $KeyFile = [string](join-path -path (split-path (split-path $transcript)) -childpath $KeyFile)
                        if($LicenseKey = get-content $KeyFile -ea STOP){
                            $smsg = "`$LicenseKey: Using resolve KeyFile:$($KeyFile)`n$($LicenseKey)" ; 
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        }else{
                            $smsg = "Unable to resolve a local Keyfile!" ; 
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            throw $smsg ; 
                            break ; 
                        } ; 
                        if($LicenseKey = get-content $KeyFile -ea STOP){
                            $pltsExLic.ProductKey = $LicenseKey ; 
                        }else{
                            $smsg = "Missing `LicenseKey!!" ; 
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            throw $smsg ; 
                            break ; 
                        }
                    } else{
                       $smsg = "Specified -LicenseKey:`n$($LicenseKey)" ;
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ; 
                    }; 
                    if( $thisserver.IsExchangeTrialEdition){
                        $smsg = "UNLICENSED EXCHANGE SERVER:`n$($thisserver |fl name,*trial*|out-string).trim())" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        
                        $smsg = "Set-ExchangeServer w`n$(($pltsExLic|out-string).trim())" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        TRY{
                            # pre-aquire the dep restart service
                            #$service = get-service -ComputerName $srvr -Name $tservice ;
                            $smsg = "get-service w`n$(($pltgSvc|out-string).trim())" ; 
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            if($targetservice = get-service @pltgSvc){
                                $pltRtSvc.InputObject = $targetservice
                                Set-ExchangeServer @pltsExLic ;
                                #Get-Service -Name MSExchangeIS | Restart-Service @pltRtSvc ; 
                                #Restart-Service -Name "ServiceName" -ComputerName "RemoteComputerName" -Force
                                $smsg = "RESTART-service w`n$(($pltRtSvc|out-string).trim())" ; 
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                restart-Service @pltRtSvc ; 
                                $tSH = test-servicehealth -server $pltgSvc.ComputerName; 
                                $smsg = "test-servicehealth -server $($pltgSvc.ComputerName):`n`n$(($tSH|out-string).trim())" ; 
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                $tSH | Select-Object -Expand ServicesNotRunning | foreach-object{
                                    $thissvc = $_ ; 
                                    $smsg = "ServicesNotRunning: $($pltgSvc.ComputerName): set-service set-service -Name $($thissvc) -status Running:" ; 
                                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    } ;
                                    get-Service -ComputerName $pltgSvc.ComputerName -Name $thissvc | set-service -Status Running -verbose -ea STOP; 
                                } ; 
                            }else{
                                $smsg = "UNABLE TO: Get-Service -Name MSExchangeIS -COMPUTERNAME $($pltgSvc.ComputerName)!" ; 
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                                CONTINUE ; 
                            }

                            <# l6400T lacks the -computername param:
                            PS D:\cab> ((gcm restart-service ).parameters).keys -join ', '
                                Force, Name, InputObject, PassThru, DisplayName, Include, Exclude, Verbose, Debug, ErrorAction, 
                                WarningAction, InformationAction, ErrorVariable, WarningVariable, InformationVariable, 
                                OutVariable, OutBuffer, PipelineVariable, WhatIf, Confirmm

                            PS D:\cab> $host.version.Major
                            5
                            #>
                            
                            $lstat = get-exchangeserver -Identity $thisserver.fqdn | select $prpTrial  ; 
                            if($lStat.IsExchangeTrialEdition -eq $false){
                                $smsg = "Already Licensed Exchange Server:`n$(($lstat | fl name,*trial*|out-string).trim())" ; 
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            }elseif($whatif){
                                $smsg = "(-whatif:expected no change)" ;
                                $smsg += "Current Status:`n$(($lstat |fl name,*trial*|out-string).trim())" ; 
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                            }else{
                                $smsg = "STILL UNLICENSED EXCHANGE SERVER:`n$(($lstat |fl name,*trial*|out-string).trim())" ; 
                                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                            } ; 
                            
                        } CATCH {
                            $ErrTrapd=$Error[0] ;
                            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;

                        } ; 
                    }else{
                        $smsg = "Already Licensed Exchange Server:`n$(($thisserver | fl name,*trial*|out-string).trim())" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;

                    # 11:25 AM 7/24/2025 make it return a summary object for each run
                    
                    if($lstat){
                        $returnObj = [ordered]@{
                            Name = $lstat.Name  ; 
                            IsExchangeTrialEdition = $lstat.IsExchangeTrialEdition ; 
                            IsExpiredExchangeTrialEdition = $lstat.IsExpiredExchangeTrialEdition ; 
                            RemainingTrialPeriod = $lstat.RemainingTrialPeriod ; 
                            LicenseKey = $LicenseKey ; 
                            isLicensed = if($lstat.IsExchangeTrialEdition -eq $false){$true}else{$false} ;                         
                        } ; 
                    }elseif($thisserver){
                        $returnObj = [ordered]@{
                            Name = $thisserver.Name  ; 
                            IsExchangeTrialEdition = $thisserver.IsExchangeTrialEdition ; 
                            IsExpiredExchangeTrialEdition = $thisserver.IsExpiredExchangeTrialEdition ; 
                            RemainingTrialPeriod = $thisserver.RemainingTrialPeriod ; 
                            LicenseKey = $LicenseKey ; 
                            isLicensed = if($thisserver.IsExchangeTrialEdition -eq $false){$true}else{$false} ;                         
                        } ; 
                    } ; 
                    $smsg = "Returning summary object to pipeline" ;
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                    [pscustomobject]$returnObj | write-output 
                    #$smsg = "`r`n"
                
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
#endregion SET_EXLICENSETDO ; #*------^ END FUNCTION set-ExLicenseTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU82Kiz9V7Y71He+mfl/rG9mwv
# QDqgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTlF4Q3
# TGAdbcUhuhSuy8GX7J6P4TANBgkqhkiG9w0BAQEFAASBgKG/2tOc53+zD42c7a1x
# hzu+g5JxvQN6t2WQLwjxKln5j8HPhFxYaoNyHBHsZy8kbl60Hv+P0rYGS1tBNi/g
# CqZ0OUO6YYRH+ArVdG8lWl6IjGUI4JYAw4xsYc1Xs0WIUfh0KOvavziDV30wXag4
# I9BCdflbRvDX/y4aIedrksnL
# SIG # End signature block
