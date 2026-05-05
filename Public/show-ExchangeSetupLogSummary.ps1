#region SHOW_EXCHANGESETUPLOGSUMMARY ; #*------v FUNCTION show-ExchangeSetupLogSummary v------
function show-ExchangeSetupLogSummary{
        <#
        .SYNOPSIS
        show-ExchangeSetupLogSummary.ps1 - Parse and summarize an ExchangeSetupLog for key steps, errors, and warnings, with an eye to focusing on points at which it fails (or completes).
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2024-
        FileName    : show-ExchangeSetupLogSummary.ps1
        License     : MIT License
        Copyright   : (c) 2024 Todd Kadrie
        Github      : https://github.com/tostka/powershell/
        Tags        : Powershell,Exchange,Install,Troubleshoo
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        * 4:32 PM 7/22/2025 added Toro-lab to the domain block to permit it to run there
        * 11:37 AM 7/16/2025 add: -passthru; added cmdline parsing & reporting, per session.
        * 4:04 PM 7/15/2025 convert to func, added to xopBuildLibrary.ps1; deferred all internal common functions out to xopBuildLib vers's
        * 5:33 PM 3/11/2025 was working fine in ISE, but in PS, wasn't echoing the sls outputs to console: added explicit write-host in front of each output in the %{} loop; 
         added -FilterNoiseStrings (eat worthless noisey write-exchangelog outputs); shifted rgxStarts, endFilter into overridable params; replace year versions from search strings (future proof); 
        rgx filter issue: there's a logged line that uses "At the end of setup,, which false counted as an $ends; pushed $start & $end count out of match; 
        Also was lacking write-host & write-warning on the two relevent echo's for that status; also was lacking the dump full log code being echoed about. Fixed: confirmed transits the issue. 
        * 3:42 PM 3/5/2025 added mult-log looping; -Number array of start/end blocks to target dump; -Summary to output a summary of the block count, and their times & start/end lines; 
        Expanded CBH
        * 3:41 PM 3/1/2025 init
        .DESCRIPTION
        show-ExchangeSetupLogSummary.ps1 - Parse and summarize an ExchangeSetupLog for key steps, errors, and warnings, with an eye to focusing on points at which it fails (or completes).
        .PARAMETER Path
        Path to an ExchangeSetup.log file (defaults to 'C:\ExchangeSetupLogs\ExchangeSetup.log')[-path c:\pathto\ExchangeSetup.log]
        .PARAMETER Summary
        Switch to output a start/end summary (used for picking values for the -Number parameter)[-Summary]
        .PARAMETER Errors
        Switch to output only the explicit error messages[-Errors]
        .PARAMETER Number
        Array of index specifications for which matched pair of 'Start'/'End' blocks found in the log, should be output to console(-1 is always the last pass)[-Number @(2,3)]
        .PARAMETER PassThru
        Returns an object to pipeline that represents the filered log lines. By default, this cmdlet does not generate any pipeline output.[-PassThru]
        .PARAMETER FilterStrings
        Array of regular expression strings to be parsed against in specified log (for overriding default list)[-FilterStrings = @('Starting Microsoft Exchange Server 2016 Setup','End of Setup')]
        .PARAMETER FilterNoiseStrings
        Array of regular expression strings to be _excluded_ from results in specified log (represent repeatitive irrelevent noise entries, that otherwise match important filter targets)(for overriding default list)[-FilterNoiseStrings = @('Beginning processing Write-ExchangeSetupLog','Ending processing Write-ExchangeSetupLog')]
        .PARAMETER rgxStarts
        Setup Start regex filter to be parsed against in specified log to identify installation starts (for overriding default list)[-rgxStarts = @('Starting\sMicrosoft\sExchange\sServer\s2016\sSetup')]
        .PARAMETER endFilter
        Setup End marker string to be parsed against in specified log to identify installation starts (for overriding default list)[-endFilter = @(' [0] End of Setup')]
        .EXAMPLE
        PS> show-ExchangeSetupLogSummary -summary 

            15:01:05: INFO: start-transcript:Transcript started, output file is D:\cab\logs\show-ExchangeSetupLogSummary-Summary-Transcript-BATCH-EXEC-20250305-1501PM-trans-log.txt
            Specified Log contains multiple (6) 'Starting Microsoft Exchange Server 2016 Setup' lines
            and a matching number (6) of 'End of Setup' lines
            There are 6 blocks covered by the log
            You can use the -Number parameter to specify a specific pass listed below to echo
            (or use -Number -1, to always output the last pass)

            ---
            block#0:start::Line2:[01/29/2024 03:32:36.0265] [0] Starting Microsoft Exchange Server 2016 Setup
            block#0:end:Line1897:[01/29/2024 03:34:07.0890] [0] End of Setup
            ---

            ---
            block#1:start::Line1900:[02/17/2024 00:40:55.0472] [0] Starting Microsoft Exchange Server 2016 Setup
            block#1:end:Line3799:[02/17/2024 00:42:08.0959] [0] End of Setup
            ---
            ..

            15:01:05: INFO: Stop-transcript:Transcript stopped, output file is D:\cab\logs\show-ExchangeSetupLogSummary-Summary-Transcript-BATCH-EXEC-20250305-1501PM-trans-log.txt

        Summarize matched Start...End pass blocks from the specified -Path ExchangeSetup.log (for use with the -Number parameter; -Path defaults to the default 'C:\ExchangeSetupLogs\ExchangeSetup.log')
        .EXAMPLE
        PS> show-ExchangeSetupLogSummary -Number @(1,2) 

            12:24:10:#*======v Microsoft.PowerShellISE_profile.ps1: v======
            Version-specific designation - 2016 - being regex'd filtered as '\d{4}'

            -FilterNoiseStrings: Suppressing output of matches on following:(Beginning\ processing\ Write-ExchangeSetupLog|Ending\ processing\ Write-ExchangeSetupLog)

            12:24:11: INFO:  start-transcript:Transcript started, output file is d:\scripts\logs\Microsoft.PowerShellISE_profile.ps1-Transcript-BATCH-EXEC-20250716-1224PM-trans-log.txt
            Hit Line breakpoint on 'D:\cab\xopBuildLibrary.ps1:2515'

            Specified Log contains multiple (10) '\s\[0]\sStarting\sMicrosoft\sExchange\sServer\s\d{4}\sSetup' lines
            and a matching number (10) of ' [0] End of Setup' lines
            There are 10 blocks covered by the log
            You can use the -Number parameter to specify a specific pass listed below to echo
            (or use -Number -1, to always output the last pass)
            Hit Line breakpoint on 'D:\cab\xopBuildLibrary.ps1:2546'

            ---
            block#0:start::Line2:[01/29/2024 03:32:36.0265] [0] Starting Microsoft Exchange Server 2016 Setup
            block#0:end:Line1897:[01/29/2024 03:34:07.0890] [0] End of Setup
            ===>Started Cmdline Params:
            [01/29/2024 03:32:36.0669] [0] RuntimeAssembly was started with the following command: '/mode:install /roles:Mailbox /IAcceptExchangeServerLicenseTerms /DoNotStartTransport /InstallWindowsComponents /MdbName:MDB1 
            /DBFilePath:F:\XXXXXXXXX\MDB1\DB\MDB1.edb /LogFolderPath:F:\XXXXXXXXX\MDB1\Log /TargetDir:D:\Program Files\Microsoft\Exchange Server\V15 /sourcedir:D:\cab\ExchangeServer2016-x64-cu17-ISO\unpacked'.
            ---

            ---
            block#1:start::Line1900:[02/17/2024 00:40:55.0472] [0] Starting Microsoft Exchange Server 2016 Setup
            block#1:end:Line3799:[02/17/2024 00:42:08.0959] [0] End of Setup
            ===>Started Cmdline Params:
            [02/17/2024 00:40:55.0695] [0] RuntimeAssembly was started with the following command: '/mode:install /roles:Mailbox /IAcceptExchangeServerLicenseTerms /DoNotStartTransport /InstallWindowsComponents /MdbName:MDB1 
            /DBFilePath:F:\XXXXXXXXX\MDB1\DB\MDB1.edb /LogFolderPath:F:\XXXXXXXXX\MDB1\Log /TargetDir:D:\Program Files\Microsoft\Exchange Server\V15 /sourcedir:D:\cab\ExchangeServer2016-x64-cu13-ISO\unpacked'.
            ---
            ...
 
            12:26:17: INFO:  Stop-transcript:Transcript stopped, output file is D:\scripts\logs\Microsoft.PowerShellISE_profile.ps1-Transcript-BATCH-EXEC-20250716-1224PM-trans-log.txt
            12:26:17:#*======^ Microsoft.PowerShellISE_profile.ps1: ^======            

        Demo output the first and 2nd start/end blocks fromn the default 'C:\ExchangeSetupLogs\ExchangeSetup.log' (output demo skipped 2nd specified block for brevity)
        .EXAMPLE
        PS> $LOUTErrs = show-ExchangeSetupLogSummary -Number -1 -Errors -Passthru ; 
        Pull tagged 'Error' elements (-Errors, filtered by the FilterExplicitErrors string list), out of the the most recent pass (-Number -1), with -Passthru (passing the matches to the pipeline), and assigning the result to a variable, for followup analysis of the content
        .EXAMPLE
        PS> write-verbose "Specify a list of targeted strings to post-filter from the results" ;         
        PS> $KeyCheckStrings = " Ending processing set-InstalledRoleInfo"," Ending processing Install-"," Finished executing component tasks."," Ending processing Start-PostSetup"," End of Setup" ; 
        PS> write-verbose "convert the strings into a regex" ; 
        PS> [regex]$rgxKeyCheckStrings = ('(' + (($KeyCheckStrings |%{[regex]::escape($_)}) -join '|') + ')') ;
        PS> write-verbose "Run a -passthru collection on the most recent pass (-Number -1), and assign to variable" ; 
        PS> $LOUT = show-ExchangeSetupLogSummary -Number -1 -Passthru ;
        
            12:30:02:#*======v Microsoft.PowerShellISE_profile.ps1: v======
            Version-specific designation - 2016 - being regex'd filtered as '\d{4}'

            -FilterNoiseStrings: Suppressing output of matches on following:(Beginning\ processing\ Write-ExchangeSetupLog|Ending\ processing\ Write-ExchangeSetupLog)

            12:30:03: INFO:  start-transcript:Transcript started, output file is d:\scripts\logs\Microsoft.PowerShellISE_profile.ps1-Transcript-BATCH-EXEC-20250716-1230PM-trans-log.txt
            Checking specified block -Number:(-1):
            block#:start::Line44793:[03/11/2025 18:29:55.0603] [0] Starting Microsoft Exchange Server 2016 Setup
            block#-1:end:Line64564:[03/11/2025 19:00:34.0860] [0] End of Setup
            ===>Started Cmdline Params:
            [03/11/2025 18:29:55.0645] [0] RuntimeAssembly was started with the following command: '/sourcedir:D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked /mode:Install'.

            -Number: -1: dumping key entries between that matched block in the specified log

            12:31:13:

            #*======v parse Log block -Number:-1:
            C:\ExchangeSetupLogs\ExchangeSetup.log v======

            12:31:23:

            #*======^ parse Log block -Number:-1:
            C:\ExchangeSetupLogs\ExchangeSetup.log ^======


            #*======^ parse Log block -Number:-1:
            C:\ExchangeSetupLogs\ExchangeSetup.log ^======

        PS> write-verbose "filter the pass entries, filtering for matches to the KeyCheckStrings regex" ;
        PS> $lout | sls -patt $rgxKeyCheckStrings ;

            [03/11/2025 18:31:27.0898] [1] Finished executing component tasks.
            [03/11/2025 18:32:52.0326] [1] Finished executing component tasks.
            [03/11/2025 18:35:48.0037] [1] Ending processing install-msipackage
            [03/11/2025 18:35:49.0147] [1] Ending processing Install-MsiPackage
            [03/11/2025 18:35:50.0101] [1] Ending processing Install-MsiPackage
            [03/11/2025 18:35:50.0105] [1] Ending processing install-LanguageFiles
            [03/11/2025 18:35:52.0690] [1] Finished executing component tasks.
            [03/11/2025 18:53:18.0201] [1] Ending processing install-Languages
            [03/11/2025 18:53:18.0637] [1] Finished executing component tasks.
            [03/11/2025 18:53:18.0643] [1] Ending processing Install-BridgeheadRole
            [03/11/2025 18:53:19.0128] [1] Finished executing component tasks.
            [03/11/2025 18:53:19.0133] [1] Ending processing Install-ClientAccessRole
            [03/11/2025 18:53:19.0498] [1] Finished executing component tasks.
            [03/11/2025 18:53:19.0504] [1] Ending processing Install-UnifiedMessagingRole
            [03/11/2025 18:54:19.0289] [2] Ending processing Install-FreeBusyFolder
            [03/11/2025 18:54:22.0180] [2] Ending processing set-InstalledRoleInfo
            [03/11/2025 18:54:22.0184] [1] Finished executing component tasks.
            [03/11/2025 18:54:22.0188] [1] Ending processing Install-MailboxRole
            [03/11/2025 18:54:54.0124] [2] Ending processing Install-FrontendTransportService
            [03/11/2025 18:55:27.0940] [2] Ending processing set-InstalledRoleInfo
            [03/11/2025 18:55:27.0945] [1] Finished executing component tasks.
            [03/11/2025 18:55:27.0949] [1] Ending processing Install-FrontendTransportRole
            [03/11/2025 18:55:56.0893] [2] Ending processing install-Imap4Service
            [03/11/2025 18:55:56.0965] [2] Ending processing install-Pop3Service
            [03/11/2025 18:55:57.0260] [2] Ending processing install-Imap4Container
            [03/11/2025 18:55:57.0308] [2] Ending processing install-Pop3Container
            [03/11/2025 18:56:02.0590] [2] Ending processing Install-ExchangeCertificate
            [03/11/2025 18:56:02.0608] [2] Ending processing Install-AuthCertificate
            [03/11/2025 18:56:04.0106] [2] Ending processing Install-ExchangeCertificate
            [03/11/2025 18:56:04.0403] [2] Ending processing install-CafeIisWebServiceExtensions
            [03/11/2025 18:57:17.0070] [2] Ending processing install-SIPContainer
            [03/11/2025 18:57:17.0216] [2] Ending processing install-UMCallRouter
            [03/11/2025 18:57:44.0061] [2] Ending processing set-InstalledRoleInfo
            [03/11/2025 18:57:44.0066] [1] Finished executing component tasks.
            [03/11/2025 18:57:44.0070] [1] Ending processing Install-CafeRole
            [03/11/2025 19:00:34.0781] [1] Finished executing component tasks.
            [03/11/2025 19:00:34.0794] [1] Ending processing Start-PostSetup
            [03/11/2025 19:00:34.0860] [0] End of Setup



        .LINK
        https://github.com/tostka/powershellBB/
        #>
        [CmdletBinding()]
        PARAM(
            [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = "Path to an ExchangeSetup.log file (defaults to 'C:\ExchangeSetupLogs\ExchangeSetup.log')[-path c:\pathto\ExchangeSetup.log]")]
                [Alias('PsPath')]
                [ValidateScript({Test-Path $_})]
                [system.io.fileinfo[]]$Path = 'C:\ExchangeSetupLogs\ExchangeSetup.log',
            [Parameter(HelpMessage = "Switch to output a start/end summary (used for picking values for the -Number parameter)[-Summary]")]
                [switch]$Summary,
            [Parameter(HelpMessage = "Switch to output only the explicit error messages[-Errors]")]
                [switch]$Errors,
            [Parameter(HelpMessage = "Array of index specifications for which matched pair of 'Start'/'End' blocks found in the log, should be output to console(-1 is always the last pass)[-Number @(2,3)]")]
                [int[]]$Number,
            [Parameter(HelpMessage = "Returns an object to pipeline that represents the filered log lines. By default, this cmdlet does not generate any pipeline output.[-PassThru]")]
                [switch]$PassThru,
            [Parameter(HelpMessage = "Array of regular expression strings to be parsed against in specified log (for overriding default list)[-FilterStrings = @('Starting Microsoft Exchange Server 2016 Setup','End of Setup')]")] 
                [ValidateNotNullOrEmpty()]
                [string[]]$FilterStrings = @(
                    " [0] Starting Microsoft Exchange Server 2016 Setup","RuntimeAssembly was started with the following command:","Command Line Parameter Name=",
                    "Because the command-line option","Logged on user:","Local time zone:","Operating system version:","Setup version:",
                    "The registry key, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V15\Setup, wasn't found.","RuntimeAssembly was started with the following command:",
                    "The registry key, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Exchange\v8.0, wasn't found.",
                    "The registry key, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\v14, wasn't found.",
                    "The registry key, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V15\Setup, wasn't found.","Copying Files...",
                    "File copy complete.","Performing Microsoft Exchange Server Prerequisite Check","Exchange Server installation failed during prereq check.",
                    "Setup will run from path","PrepareAD has been run,","Exchange configuration container for the organization is",
                    "Exchange organization container for the organization is","An Exchange organization with name","Active Directory Initialization status :",
                    "Schema Update Required Status :","Organization Configuration Update Required Status :","Domain Configuration Update Required Status :",
                    "Exchange configuration container for the organization is","Exchange organization container for the organization is",
                    "Setup is determining what organization-level operations to perform.","Setup is choosing the domain controller to use",
                    "Setup is choosing a local domain controller...","Setup has chosen the local domain controller","Setup is choosing a global catalog...",
                    "Setup has chosen the global catalog server","Setup will use the domain controller","Setup will use the global catalog",
                    "Setup will search for an Exchange Server object for the local machine with name","Beginning processing","Ending processing",
                    "Beginning processing Install-ExchangeOrganization","Ending processing Install-ExchangeOrganization",
                    "[ERROR]","[WARNING]","[RECOMENDED]","[REQUIRED]","Failed","Exception :","exception stack trace","Exception from",
                    "error(s) occurred during task execution:","ErrorRecord:","Help URL:","Setup is halting","The previous errors were generated by",
                    "Setup will continue processing component tasks","Process standard error:","Exchange Server installation failed",
                    "RestoreServer Script Path:","Trying to restore server state.","The operation couldn't be performed because",
                    "Finished executing component tasks.","The Exchange Server setup operation didn't complete.",
                    "The Microsoft Exchange Server setup operation completed successfully",
                    "The Exchange Server Setup operation did not complete"," [0] End of Setup"),
            [Parameter(HelpMessage = "Array of regular expression strings to be _excluded_ from results in specified log (represent repeatitive irrelevent noise entries, that otherwise match important filter targets)(for overriding default list)[-FilterNoiseStrings = @('Beginning processing Write-ExchangeSetupLog','Ending processing Write-ExchangeSetupLog')]")] 
                [ValidateNotNullOrEmpty()]
                [string[]]$FilterNoiseStrings = @('Beginning processing Write-ExchangeSetupLog','Ending processing Write-ExchangeSetupLog'),
            [Parameter(HelpMessage = "Array of regular expression strings to be parsed against in specified log (for overriding default list)[-FilterStrings = @('Starting Microsoft Exchange Server 2016 Setup','End of Setup')]")] 
                [ValidateNotNullOrEmpty()]
                [string[]]$FilterExplicitErrors = @(
                    " [0] Starting Microsoft Exchange Server 2016 Setup",
                    "Exchange Server installation failed during prereq check.",
                    "[ERROR]","[WARNING]","[RECOMENDED]","[REQUIRED]","Failed","Exception :","exception stack trace","Exception from",
                    "error(s) occurred during task execution:","ErrorRecord:","Help URL:","Setup is halting","The previous errors were generated by",
                    "Process standard error:","Exchange Server installation failed",
                    "RestoreServer Script Path:","Trying to restore server state.","The operation couldn't be performed because",
                    "The Exchange Server setup operation didn't complete.",
                    "The Exchange Server Setup operation did not complete"," [0] End of Setup"),
            [Parameter(HelpMessage = "Setup Start regex filter to be parsed against in specified log to identify installation starts (for overriding default list)[-rgxStarts = @('Starting\sMicrosoft\sExchange\sServer\s2016\sSetup')]")] 
                [regex]$rgxStarts = "\s\[0]\sStarting\sMicrosoft\sExchange\sServer\s\d{4}\sSetup",
            [Parameter(HelpMessage = "Setup End marker string to be parsed against in specified log to identify installation starts (for overriding default list)[-endFilter = @(' [0] End of Setup')]")] 
                [string]$endFilter = " [0] End of Setup"
        )
        BEGIN{
            #region CONSTANTS_AND_ENVIRO ; #*======v CONSTANTS_AND_ENVIRO v======
            #region ENVIRO_DISCOVER ; #*------v ENVIRO_DISCOVER v------
            push-TLSLatest
            $Verbose = [boolean]($VerbosePreference -eq 'Continue') ; 
            $rPSCmdlet = $PSCmdlet ; # an object that represents the cmdlet or advanced function that's being run. Available on functions w CmdletBinding (& $args will not be available). (Blank on non-CmdletBinding/Non-Adv funcs).
            $rPSScriptRoot = $PSScriptRoot ; # the full path of the executing script's parent directory., PS2: valid only in script modules (.psm1). PS3+:it's valid in all scripts. (Funcs: ParentDir of the file that hosts the func)
            $rPSCommandPath = $PSCommandPath ; # the full path and filename of the script that's being run, or file hosting the funct. Valid in all scripts.
            $rMyInvocation = $MyInvocation ; # populated only for scripts, function, and script blocks.
            # - $MyInvocation.MyCommand.Name returns name of a function, to identify the current command,  name of the current script (pop'd w func name, on Advfuncs)
            # - Ps3+:$MyInvocation.PSScriptRoot : full path to the script that invoked the current command. The value of this property is populated only when the caller is a script (blank on funcs & Advfuncs)
            # - Ps3+:$MyInvocation.PSCommandPath : full path and filename of the script that invoked the current command. The value of this property is populated only when the caller is a script (blank on funcs & Advfuncs)
            #     ** note: above pair contain information about the _invoker or calling script_, not the current script
            $rPSBoundParameters = $PSBoundParameters ; 
            #region PREF_VARI_DUMP ; #*------v PREF_VARI_DUMP v------
            <#$script:prefVaris = @{
                whatifIsPresent = $whatif.IsPresent
                whatifPSBoundParametersContains = $rPSBoundParameters.ContainsKey('WhatIf') ; 
                whatifPSBoundParameters = $rPSBoundParameters['WhatIf'] ;
                WhatIfPreferenceIsPresent = $WhatIfPreference.IsPresent ; # -eq $true
                WhatIfPreferenceValue = $WhatIfPreference;
                WhatIfPreferenceParentScopeValue = (Get-Variable WhatIfPreference -Scope 1).Value ;
                ConfirmPSBoundParametersContains = $rPSBoundParameters.ContainsKey('Confirm') ; 
                ConfirmPSBoundParameters = $rPSBoundParameters['Confirm'];
                ConfirmPreferenceIsPresent = $ConfirmPreference.IsPresent ; # -eq $true
                ConfirmPreferenceValue = $ConfirmPreference ;
                ConfirmPreferenceParentScopeValue = (Get-Variable ConfirmPreference -Scope 1).Value ; 
                VerbosePSBoundParametersContains = $rPSBoundParameters.ContainsKey('Confirm') ; 
                VerbosePSBoundParameters = $rPSBoundParameters['Verbose'] ;
                VerbosePreferenceIsPresent = $VerbosePreference.IsPresent ; # -eq $true
                VerbosePreferenceValue = $VerbosePreference ;
                VerbosePreferenceParentScopeValue = (Get-Variable VerbosePreference -Scope 1).Value;
                VerboseMyInvContains = '-Verbose' -in $rPSBoundParameters.UnboundArguments ; 
                VerbosePSBoundParametersUnboundArgumentContains = '-Verbose' -in $rPSBoundParameters.UnboundArguments 
            } ;
            write-verbose "`n$(($script:prefVaris.GetEnumerator() | Sort-Object Key | Format-Table Key,Value -AutoSize|out-string).trim())`n" ; 
            #>
            #endregion PREF_VARI_DUMP ; #*------^ END PREF_VARI_DUMP ^------
            #region RV_ENVIRO ; #*------v RV_ENVIRO v------
            $pltRvEnv=[ordered]@{
                PSCmdletproxy = $rPSCmdlet ; 
                PSScriptRootproxy = $rPSScriptRoot ; 
                PSCommandPathproxy = $rPSCommandPath ; 
                MyInvocationproxy = $rMyInvocation ;
                PSBoundParametersproxy = $rPSBoundParameters
                verbose = [boolean]($PSBoundParameters['Verbose'] -eq $true) ; 
            } ;
            $smsg = "(Purge no value keys from splat)" ; 
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $mts = $pltRVEnv.GetEnumerator() |?{$_.value -eq $null} ; $mts |%{$pltRVEnv.remove($_.Name)} ; rv mts -ea 0 -whatif:$false -confirm:$false; 
            $smsg = "resolve-EnvironmentTDO w`n$(($pltRVEnv|out-string).trim())" ; 
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
            if(get-command resolve-EnvironmentTDO -ea STOP){}ELSE{
                $smsg = "UNABLE TO gcm resolve-EnvironmentTDO!" ; 
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
                BREAK ; 
            } ; 
            $rvEnv = resolve-EnvironmentTDO @pltRVEnv ; 
            $smsg = "`$rvEnv returned:`n$(($rvEnv |out-string).trim())" ; 
            if(gcm Write-MyVerbose -ea 0){
                Write-MyVerbose $smsg ;
            } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            #endregion RV_ENVIRO ; #*------^ END RV_ENVIRO ^------
            #region NETWORK_INFO ; #*======v NETWORK_INFO v======
            if(get-command resolve-NetworkLocalTDO  -ea STOP){}ELSE{
                $smsg = "UNABLE TO gcm resolve-NetworkLocalTDO !" ; 
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
                BREAK ; 
            } ; 
            $netsettings = resolve-NetworkLocalTDO ; 
            if($env:Userdomain){ 
                switch($env:Userdomain){
                    'CMW'{
                        #$logon_SID = $CMW_logon_SID 
                    }
                    'TORO'{
                        #$o365_SIDUpn = $o365_Toroco_SIDUpn ; 
                        #$logon_SID = $TOR_logon_SID ; 
                    }
                    'TORO-LAB'{
                        #$o365_SIDUpn = $o365_Toroco_SIDUpn ; 
                        #$logon_SID = $TOR_logon_SID ; 
                    }
                    $env:COMPUTERNAME{
                        $smsg = "%USERDOMAIN% -EQ %COMPUTERNAME%: $($env:computername) => non-domain-connected, likely edge role Ex server!" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        if($netsettings.Workgroup){
                            $smsg = "WorkgroupName:$($netsettings.Workgroup)" ; 
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;                  
                        } ; 
                    } ; 
                    default{
                        $smsg = "$($env:userdomain):UNRECOGIZED/UNCONFIGURED USER DOMAIN STRING!" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        THROW $smsg 
                        BREAK ; 
                    }
                } ; 
            } ;  # $env:Userdomain-E
            #endregion NETWORK_INFO ; #*======^ END NETWORK_INFO ^======
            #region OS_INFO ; #*------v OS_INFO v------
            <# os detect, covers Server 2016, 2008 R2, Windows 10, 11
            if (get-command get-ciminstance -ea 0) {$OS = (Get-ciminstance -class Win32_OperatingSystem)} else {$Os = Get-WMIObject -class Win32_OperatingSystem } ;
            #$isWorkstationOS = $isServerOS = $isW2010 = $isW2011 = $isS2016 = $isS2008R2 = $false ;
            write-host "Detected:`$Os.Name:$($OS.name)`n`$Os.Version:$($Os.Version)" ;
            if ($OS.name -match 'Microsoft\sWindows\sServer') {
                $isServerOS = $true ;
                if ($os.name -match 'Microsoft\sWindows\sServer\s2016'){$isS2016 = $true ;} ;
                if ($os.name -match 'Microsoft\sWindows\sServer\s2008\sR2') { $isS2008R2 = $true ; } ;
            } else { 
                if ($os.name -match '^Microsoft\sWindows\s11') {
                    $isWorkstationOS = $true ;
                    if ($os.name -match 'Microsoft\sWindows\s11') { $isW2011 = $true ; } ;
                } elseif ($os.name -match '^Microsoft\sWindows\s10') {
                    $isWorkstationOS = $true ; $isW2010 = $true
                } else {
                    $isWorkstationOS = $true ;
                } ;         
            } ; 
            #>
            #endregion OS_INFO ; #*------^ END OS_INFO ^------
                        
            #region LOCAL_CONSTANTS ; #*------v LOCAL_CONSTANTS v------
            $logging = $false ; 
            $rgxStartCmdline = "\sRuntimeAssembly\swas\sstarted\swith\sthe\sfollowing\scommand:\s'.*'" ; 
            #endregion LOCAL_CONSTANTS ; #*------^ END LOCAL_CONSTANTS ^------        
            
            #endregion CONSTANTS_AND_ENVIRO ; #*------^ END CONSTANTS_AND_ENVIRO ^------
    
            #region FUNCTIONS ; #*======v FUNCTIONS v======

            #endregion FUNCTIONS ; #*======^ END FUNCTIONS ^======

            #region BANNER ; #*------v BANNER v------
            $sBnr="#*======v " ; 
            if($rvEnv.isScript){                
                if($rvEnv.PSCommandPathproxy){ $sBnr += $(split-path $rvEnv.PSCommandPathproxy -leaf) }
                elseif($script:PSCommandPath){$sBnr += $(split-path $script:PSCommandPath -leaf)}
                elseif($rPSCommandPath){$sBnr += $(split-path $rPSCommandPath -leaf)} ; 
            }elseif($rvEnv.isFunc){
                if($rvEnv.FuncDir -AND $rvEnv.FuncName){$sBnr += $rvEnv.FuncName } ; 
            } elseif($CmdletName){$sBnr += $rvEnv.CmdletName}; 
            $sBnr += ": v======" ;
            $smsg = $sBnr ;
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
            #endregion BANNER ; #*------^ END BANNER ^------

            # adapt the version-specific test strings to current rev, before building rgxs
            if($FilterStrings | ?{$_ -match "\s\[0]\sStarting\sMicrosoft\sExchange\sServer\s(\d+)\sSetup"} ){
                $VersionReplace = $matches[1]
                $smsg = "Version-specific designation - $($VersionReplace) - being regex'd filtered as '\d{4}'" ; 
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            } ; 

            [regex]$rgxExLogFilters = ('(' + (($FilterStrings |%{[regex]::escape($_)}) -join '|') + ')') ;
            #FilterNoiseStrings
            [regex]$rgxFilterNoiseStrings = ('(' + (($FilterNoiseStrings |%{[regex]::escape($_)}) -join '|') + ')') ;
            # $FilterExplicitErrors
            [regex]$rgxExLogFiltersErrors = ('(' + (($FilterExplicitErrors |%{[regex]::escape($_)}) -join '|') + ')') ;

            if($VersionReplace){
                [regex]$rgxExLogFilters = ([regex]($rgxExLogFilters.tostring() -replace "$VersionReplace","\d{4}")).tostring()
                [regex]$rgxExLogFiltersErrors = ([regex]($rgxExLogFiltersErrors.tostring() -replace "$VersionReplace","\d{4}")).tostring()

            } ; 

            $smsg = "`n`n-FilterNoiseStrings: Suppressing output of matches on following:$($rgxFilterNoiseStrings.tostring())`n`n" ; 
            $smsg += "`n`nActive rgxExLogFilters:`n$(($rgxExLogFilters|out-string).trim())`n`n" ; 
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
        }
        PROCESS{
            #region START_LOG_OPTIONS #*======v START_LOG_OPTIONS v======
            $useSLogHOl = $true ; # one or 
            $useSLogSimple = $false ; #... the other
            $useTransName = $false ; # TRANSCRIPTNAME
            $useTransPath = $false ; # TRANSCRIPTPATH
            $useTransRotate = $false ; # TRANSCRIPTPATHROTATE
            $useStartTrans = $false ; # STARTTRANS
            #region START_LOG_HOLISTIC #*------v START_LOG_HOLISTIC v------
            if($useSLogHOl){
                # Single log for script/function example that accomodates detect/redirect from AllUsers scope'd installed code, and hunts a series of drive letters to find an alternate logging dir (defers to profile variables)
                #${CmdletName} = $rPSCmdlet.MyInvocation.MyCommand.Name ;
                if(-not (get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
                foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
                if(-not (get-variable rgxPSAllUsersScope -ea 0)){$rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;} ;
                if(-not (get-variable rgxPSCurrUserScope -ea 0)){$rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;} ;
                $pltSL=[ordered]@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ;} ;
                if($whatif.ispresent){$pltSL.add('whatif',$($whatif))}
                elseif($WhatIfPreference.ispresent ){$pltSL.add('whatif',$WhatIfPreferenc)} ;         
                # if using [CmdletBinding(SupportsShouldProcess)] + -WhatIf:$($WhatIfPreference):
                #$pltSL=[ordered]@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($WhatIfPreference) ;} ;
                #$pltSL=[ordered]@{Path=$null ;NoTimeStamp=$false ;Tag="$($ticket)-$($TenOrg)-LASTPASS-" ;showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($WhatIfPreference) ;} ;
                #$pltSL.Tag = $((@($ticket,$usr) |?{$_}) -join '-')
                #if($ticket){$pltSL.Tag = $ticket} ;
                $pltSL.Tag = $env:COMPUTERNAME ; 
                $tagfields = 'ticket','UserPrincipalName','folderscope' ; # DomainName TenOrg ModuleName 
                $tagfields | foreach-object{$fld = $_ ; if(get-variable $fld -ea 0 |?{$_.value} ){$pltSL.Tag += @($((get-variable $fld).value))} } ; 
                if($pltSL.Tag -is [array]){$pltSL.Tag = $pltSL.Tag -join '-' } ; 
                #$transcript = ".\logs\$($Ticket)-$($DomainName)-$(split-path $rMyInvocation.InvocationName -leaf)-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt" ; 
                #$pltSL.Tag += "-$($DomainName)"
                #
                if($rPSBoundParameters.keys){ # alt: leverage $rPSBoundParameters hash
                    $sTag = @() ; 
                    #$pltSL.TAG = $((@($rPSBoundParameters.keys) |?{$_}) -join ','); # join all params
                    if($rPSBoundParameters['Summary']){ $sTag+= @('Summary') } ; # build elements conditionally, string
                    if($rPSBoundParameters['Number']){ $sTag+= @("Number$($rPSBoundParameters['Number'])") } ; # and keyname,value
                    $pltSL.Tag += "-$($sTag -join ',')" ; # 4:46 PM 7/16/2025 flipped to append, not assign
                } ; 
                #
                if($rvEnv.isScript){
                    write-host "`$script:PSCommandPath:$($script:PSCommandPath)" ;
                    write-host "`$PSCommandPath:$($PSCommandPath)" ;
                    if($rvEnv.PSCommandPathproxy){ $prxPath = $rvEnv.PSCommandPathproxy }
                    elseif($script:PSCommandPath){$prxPath = $script:PSCommandPath}
                    elseif($rPSCommandPath){$prxPath = $rPSCommandPath} ; 
                } ; 
                if($rvEnv.isFunc){
                    if($rvEnv.FuncDir -AND $rvEnv.FuncName){
                           $prxPath = join-path -path $rvEnv.FuncDir -ChildPath $rvEnv.FuncName ; 
                    } ; 
                } ; 
                if(-not $rvEnv.isFunc){
                    # under funcs, this is the scriptblock of the func, not a path
                    if($rvEnv.MyInvocationproxy.MyCommand.Definition){$prxPath2 = $rvEnv.MyInvocationproxy.MyCommand.Definition }
                    elseif($rvEnv.MyInvocationproxy.MyCommand.Definition){$prxPath2 = $rvEnv.MyInvocationproxy.MyCommand.Definition } ; 
                } ; 
                if($prxPath){
                    if(($prxPath -match $rgxPSAllUsersScope) -OR ($prxPath -match $rgxPSCurrUserScope)){
                        $bDivertLog = $true ; 
                        switch -regex ($prxPath){
                            $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                            $rgxPSCurrUserScope{$smsg = "CurrentUser"}
                        } ;
                        $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
                        write-verbose $smsg  ;
                        if($bDivertLog){
                            if((split-path $prxPath -leaf) -ne $rvEnv.CmdletName){
                                # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
                                $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($rvEnv.CmdletName).ps1") ;
                            } else {
                                # installed allusers|CU script, use the hosting script name
                                $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $prxPath -leaf)) ;
                            }
                        } ;
                    } else {
                        $pltSL.Path = $prxPath ;
                    } ;
                }elseif($prxPath2){
                    if(($prxPath2 -match $rgxPSAllUsersScope) -OR ($prxPath2 -match $rgxPSCurrUserScope) ){
                            $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $prxPath2 -leaf)) ;
                    } elseif(test-path $prxPath2) {
                        $pltSL.Path = $prxPath2 ;
                    } elseif($rvEnv.CmdletName){
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($rvEnv.CmdletName).ps1") ;
                    } else {
                        $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$rvEnv.CmdletName, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        BREAK ;
                    } ; 
                } else{
                    $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$rvEnv.CmdletName, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    BREAK ;
                }  ;
                $smsg = "start-Log w`n$(($pltSL|out-string).trim())" ; 
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
                $logspec = start-Log @pltSL ;
                $error.clear() ;
                TRY {
                    if($logspec){
                        $logging=$logspec.logging ;
                        $logfile=$logspec.logfile ;
                        $transcript=$logspec.transcript ;
                        $stopResults = TRY {Stop-transcript -ErrorAction stop} CATCH {} ;
                        if($stopResults){
                            $smsg = "Stop-transcript:$($stopResults)" ; 
                            if(gcm Write-MyVerbose -ea 0){
                                Write-MyVerbose $smsg ;
                            } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                        } ; 
                        $startResults = start-Transcript -path $transcript -whatif:$false -confirm:$false;
                        if($startResults){
                            $smsg = "start-transcript:$($startResults)" ; 
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        } ; 
                    } else {
                        $smsg = "Unable to configure logging!"  ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        throw $smsg ;
                    } ;
                } CATCH [System.Management.Automation.PSNotSupportedException]{
                    if($host.name -eq 'Windows PowerShell ISE Host'){
                        $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
                    } else { 
                        $smsg = "This host does *not* support native (start-)transcription" ; 
                    } ; 
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                } CATCH {
                    $ErrTrapd=$Error[0] ;
                    $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;

                    #region SendMailAlert ; #*------v SendMailAlert v------
                    $SmtpBody += "`n===FAIL Summary:" ;
                    $SmtpBody += "`n$('-'*50)" ;
                    $SmtpBody += "`n$('-'*50)" ;
                    $smsg += "`n$(($smsg |out-string).trim())" ; 
                    $sdEmail = @{
                        smtpFrom = $SMTPFrom ;
                        SMTPTo = $SMTPTo ;
                        SMTPSubj = $SMTPSubj ;
                        #SMTPServer = $SMTPServer ;
                        SmtpBody = $SmtpBody ;
                        SmtpAttachment = $SmtpAttachment ;
                        BodyAsHtml = $false ; # let the htmltag rgx in Send-EmailNotif flip on as needed
                        verbose = $($VerbosePreference -eq "Continue") ;
                    } ;
                    $smsg = "Send-EmailNotif w`n$(($sdEmail|out-string).trim())" ;
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                    Send-EmailNotif @sdEmail ;

                    #endregion SendMailAlert ; #*------^ END SendMailAlert ^------
                } ;
            } ; 
            #endregion START_LOG_HOLISTIC #*------^ END START_LOG_HOLISTIC ^------
            #endregion START-LOG #*======^ START-LOG OPTIONS ^======

            foreach($f in @($Path)){
                $file = get-childitem $f -ea STOP ;

                # profile start/stops
                $starts = $stops = $rawSourceLines = $thisstartCmd = $subblock = $null ; 
                # should pull/tag starts: "Starting Microsoft Exchange Server 2016 Setup"
                # strike that, more specific (non-false-detect) strings: " [0] Starting Microsoft Exchange Server 2016 Setup"
                #$starts = get-childitem $file.fullname | sls -pattern ([regex]::Escape("Starting Microsoft Exchange Server 2016 Setup"))
                # flip to \d{4} year spec, non-hardcoded
                #$rgxStarts = "\s\[0]\sStarting\sMicrosoft\sExchange\sServer\s\d{4}\sSetup" ;
                #$endFilter = " [0] End of Setup"
                $starts = get-childitem $file.fullname | sls -pattern  $rgxStarts ; 
                # and ends: "End of Setup"
                # more specific:  [0] End of Setup
                $ends = get-childitem $file.fullname | sls -pattern ([regex]::Escape($endFilter)) ; 
                $max = [math]::Max($starts.count,$ends.count) ; 
                $rawSourceLines = get-content -path $file.fullname  ;
                $SrcLineTtl = ($rawSourceLines | Measure-Object).count ;
                if($Summary){
                    if($starts.count -eq $ends.count){
                        $smsg = "Specified Log contains multiple ($($starts.count)) '$($rgxStarts)' lines"
                        $smsg += "`nand a matching number ($($ends.count)) of '$($endFilter)' lines" ; 
                        $smsg += "`nThere are $($starts.count) blocks covered by the log" ; 
                        $smsg += "`nYou can use the -Number parameter to specify a specific pass listed below to echo" ; 
                        $smsg += "`n(or use -Number -1, to always output the last pass)" ; 
                        write-host -foregroundcolor yellow $smsg ; 

                        # pregrab raw, for parsing out the cmdline syntax used
                        #$rawSourceLines = get-content -path $file.fullname  ;
                        
                        for($i = 0; $i -lt $max; $i++){
                            $smsg = "`n---`nblock#$($i):start::Line$($starts[$i].LineNumber):$($starts[$i].Line)" ; 
                            $smsg += "`nblock#$($i):end:Line$($ends[$i].LineNumber):$($ends[$i].Line)" ; 
                            $subblock = $rawSourceLines[($starts[$i].LineNumber - 1)..($ends[$i].LineNumber)] ; 
                            $thisstartCmd = $subblock |select-string -patt $rgxStartCmdline |select-string -patt $rgxFilterNoiseStrings -NotMatch ; 
                            $smsg += "`n===>Started Cmdline Params:`n$(($thisstartCmd|out-string).trim())" ; 
                            $smsg += "`n---`n"                            
                            if($PassThru){
                                $smsg | write-output ; 
                            } else {
                                write-host -foregroundcolor green $smsg ; 
                            }; 
                        } ; 
                    } else { 
                        $smsg = "Specified Log contains multiple ($($starts.count)) 'Starting Microsoft Exchange Server 2016 Setup' lines"
                        $smsg += "`nand a NON-matching number ($($ends.count)) of 'End of Setup' lines" ; 
                        $smsg += "`nOutputing the full log stream..." ; 
                        write-warning $smsg ;
                        #$rawSourceLines = get-content -path $file.fullname  ;
                        #$SrcLineTtl = ($rawSourceLines | Measure-Object).count ;
                        write-host -foregroundcolor green "Dumping key entries across entire specified log"; 
                        $sBnr="`n`n#*======v parse Log :`n$(($file.fullname|out-string).trim()) v======`n`n" ;
                        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnr)" ;
                        #get-childitem $file.fullname |select-string -patt $rgxExLogFilters | foreach-object {"$($_.linenumber):$($_.line)" };
                        # $rgxFilterNoiseStrings
                        #get-childitem $file.fullname |select-string -patt $rgxExLogFilters  |select-string -patt $rgxFilterNoiseStrings -NotMatch | foreach-object {"$($_.linenumber):$($_.line)" };
                        get-childitem $file.fullname |select-string -patt $rgxExLogFilters  |select-string -patt $rgxFilterNoiseStrings -NotMatch | foreach-object {write-host "$($_.linenumber):$($_.line)" };
                        #$subblock = $rawSourceLines[($starts[$num].LineNumber - 1)..($ends[$num].LineNumber - 1)] ; 
                        #$subblock |select-string -patt $rgxExLogFilters | foreach-object {"$($_.linenumber):$($_.line)" };
                        write-host -foregroundcolor green "`n`n$((get-date).ToString('HH:mm:ss')):$($sBnr.replace('=v','=^').replace('v=','^='))`n`n" ;
                    } ; 
                } elseif($Number){
                    foreach($num in $Number){
                        if($num -le $max){
                            if($starts[$num] -AND $ends[$num]){
                                <#
                                if($num -eq -1){
                                    $smsg = "block#$($i):start::Line$($starts[$i].LineNumber):$($starts[$i]Line)" ; 
                                    $smsg += "`nblock#$($i):end:Line$($ends[$i].LineNumber):$($ends[$i].Line)" ; 
                                    write-host -foregroundcolor green $smsg ; 
                                } else {
                    
                                };
                                #> 
                                $smsg = "Checking specified block -Number:($num):" ; 
                                $smsg += "`nblock#$($i):start::Line$($starts[$num].LineNumber - 1):$($starts[$num].Line)" ; 
                                $smsg += "`nblock#$($num):end:Line$($ends[$num].LineNumber - 1):$($ends[$num].Line)" ; 
                                $subblock = $rawSourceLines[($starts[$num].LineNumber - 1)..($ends[$num].LineNumber - 1)] ; 
                                $thisstartCmd = $subblock |select-string -patt $rgxStartCmdline |select-string -patt $rgxFilterNoiseStrings -NotMatch ; 
                                $smsg += "`n===>Started Cmdline Params:`n$(($thisstartCmd|out-string).trim())" ; 
                                #get-childitem $file.fullname |select-string -patt $rgxExLogFilters | foreach-object {"$($_.linenumber):$($_.line)" };                                
                                
                                #$subblock |select-string -patt $rgxExLogFilters | foreach-object {"$($_.linenumber):$($_.line)" };
                                # $rgxFilterNoiseStrings
                                #$subblock |select-string -patt $rgxExLogFilters |select-string -patt $rgxFilterNoiseStrings -NotMatch | foreach-object {"$($_.linenumber):$($_.line)" };
                                write-host -foregroundcolor green $smsg ;                                                                 
                                write-host -foregroundcolor green "-Number: $($num): dumping key entries between that matched block in the specified log"; 
                                $sBnr="`n`n#*======v parse Log block -Number:$($num):`n$(($file.fullname|out-string).trim()) v======`n`n" ;
                                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnr)" ;
                                if($Errors){                                    
                                    if($PassThru){
                                        $subblock |select-string -patt $rgxExLogFiltersErrors |select-string -patt $rgxFilterNoiseStrings -NotMatch | write-output ; 
                                    } else { 
                                        $subblock |select-string -patt $rgxExLogFiltersErrors |select-string -patt $rgxFilterNoiseStrings -NotMatch | foreach-object {write-host "$($_.linenumber):$($_.line)" };
                                    }; 
                                }else{                                    
                                    if($PassThru){
                                        $subblock |select-string -patt $rgxExLogFilters |select-string -patt $rgxFilterNoiseStrings -NotMatch | write-output ; 
                                    } else {
                                        $subblock |select-string -patt $rgxExLogFilters |select-string -patt $rgxFilterNoiseStrings -NotMatch | foreach-object {write-host "$($_.linenumber):$($_.line)" };
                                    }; 
                                } ;                                 
                                write-host -foregroundcolor green "`n`n$((get-date).ToString('HH:mm:ss')):$($sBnr.replace('=v','=^').replace('v=','^='))`n`n" ;
                            } else { 
                                $smsg = "current log does not have both the specified start:$($starts[$num]) and end $($ends[$num])!" ; 
                                $smsg += "`n(possibe mismatch set, premature abort with proper 'end'?)" ;
                                write-warning $smsg ;
                            } ; 
                        }else {
                            write-warning "Specified -Number ($($num)) is GREATER than the Max numnber of matching Start/End block markers found in the specified log" ; 
                            break ; 
                        } ; 
                    } ;  # loop-E
                } else {
                    # dump full log
                    $smsg = "NO REDUCED SET OPTIONS SPECIFIED!" ;
                    $smsg += "`nTHIS WILL DUMP THE *FULL* (FILTERED) SETUP LOG!" ;
                    $smsg += "`nCOULD REFLECT TENS OF THOUSANDS OF LINES OF CONSOLE OUTPUT (OR PIPELINE OUTPUT IF -PASSTHRU USED)" ;
                    write-warning $smsg ;
                    $bRet=Read-Host "Enter YYY to continue. Anything else will exit"  ;
                    if ($bRet.ToUpper() -eq "YYY") {
                        $smsg = "(Moving on)" ;
                
                        write-host -foregroundcolor green $smsg  ;
                    }               else {
                        $smsg = "(*skip* use of -NoFunc)" ;
                        write-host -foregroundcolor yellow $smsg  ;
                        break ; #exit 1
                    } ; 
                    write-host -foregroundcolor green "(Dumping default full log)"; 
                    $sBnr="`n`n#*======v parse Log:`n$(($file.fullname|out-string).trim()) v======`n`n" ;
                    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnr)" ;
                    #get-childitem $file.fullname |select-string -patt $rgxExLogFilters | foreach-object {"$($_.linenumber):$($_.line)" };
                    # $rgxFilterNoiseStrings
                    #get-childitem $file.fullname |select-string -patt $rgxExLogFilters  |select-string -patt $rgxFilterNoiseStrings -NotMatch | foreach-object {"$($_.linenumber):$($_.line)" };                    
                    if($PassThru){
                        get-childitem $file.fullname |select-string -patt $rgxExLogFilters  |select-string -patt $rgxFilterNoiseStrings -NotMatch | write-output ; 
                    } else {
                        get-childitem $file.fullname |select-string -patt $rgxExLogFilters  |select-string -patt $rgxFilterNoiseStrings -NotMatch | foreach-object {write-host "$($_.linenumber):$($_.line)" };
                    }; 
                    write-host -foregroundcolor green "`n`n$((get-date).ToString('HH:mm:ss')):$($sBnr.replace('=v','=^').replace('v=','^='))`n`n" ;
                }; 
            } ;
            if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
                $Logname=$transcript.replace('-trans-log.txt','-ISEtrans-log.txt') ; 
                $smsg = "`$Logname: $Logname";
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;

                Start-iseTranscript -logname $Logname  -Verbose:($VerbosePreference -eq 'Continue') ;
                #Archive-Log $Logname ;
                $transcript = $Logname ; 
                if($host.version.Major -ge 5){ stop-transcript  -Verbose:($VerbosePreference -eq 'Continue')} # ISE in psV5 actually supports transcription. If you don't stop it, it just keeps rolling
            } else {
                $stopResults = TRY {Stop-transcript -ErrorAction stop} CATCH {} ;
                if($stopResults){
                    $smsg = "Stop-transcript:$($stopResults)" ; 
                    <# Opt:verbose
                    if(gcm Write-MyVerbose -ea 0){
                        Write-MyVerbose $smsg ;
                    } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                    #>
                    # # Opt:pswlt
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                } ; 
                #Stop-TranscriptLog -Transcript $transcript -verbose:$($VerbosePreference -eq "Continue") ;
                if($logging -eq $true){$logging = $false} ; 
            } # if-E
        }
        END {
    
            $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;  # END-E
    }
#endregion SHOW_EXCHANGESETUPLOGSUMMARY ; #*------^ END FUNCTION show-ExchangeSetupLogSummary  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTDiOQiU3cm0ih08FG9UGTDO7
# s6CgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR7u7nl
# nvnBYsoIDPhPdMgJXzQ+lTANBgkqhkiG9w0BAQEFAASBgFyQmN3reEg5mpkO+CW8
# eiWetSkVx7oeSX7si7lTIYBUYAtneENq21v2AUYtrp+huAkXzmA+HMjf32Sw/Gnj
# a/NOiaDWNa5/8O/UNz1OlpzFgFw5DTwKThCoZv9ZhbBMzKQaSZRtFip137KWnVhe
# 7ogG2tH2UUskwMHeIf9en0A7
# SIG # End signature block
