# xopBuildLibrary.psm1


<#
.SYNOPSIS
xopBuildLibrary - Exchange Server Build Utilties Module
.NOTES
Version     : 1.0.0
Author      : Todd Kadrie
Website     :	https://www.toddomation.com
Twitter     :	@tostka
CreatedDate : 5/5/2026
FileName    : xopBuildLibrary.psm1
License     : MIT
Copyright   : (c) 5/5/2026 Todd Kadrie
Github      : https://github.com/tostka
AddedCredit : REFERENCE
AddedWebsite:	REFERENCEURL
AddedTwitter:	@HANDLE / http://twitter.com/HANDLE
REVISIONS
* 5/5/2026 - 1.0.0.2 converted to dynamic include module with repo; MANUALLY SPLICED IN THE SIZABLE BLOCK OF PRE-ENVIRO DISCOVERY & CONSTANTS POPULATION CODE NEEDED BEFORE THE FCTS CAN BE LOADED
* Resolve-xopBuildSemVersToTextNameTDO() *5:18 PM 4/16/2026 updated build table to curr (through Feb26 patches)
* 5:36 PM 2/21/2026 worked patching cmw\Curly;  added:Test-PendingRebootSimple,  CMW, EXEMPTED CAB DISCOVERY (THEY HAVE NO INSTALL CAB MOUNTED LOCALLY THAT I CAN FIND!)
* 3:18 PM 2/17/2026 # 3:13 PM 2/17/2026  add functions nested into scriptblock, that are needed externally: Test-RegistryKey,Test-RegistryValue,Test-RegistryValueNotNull; 
fixed missing base aliases for function *TDO items (broke install-Exchang15-*.ps1 compat)
* 2:29 PM 12/19/2025 rejiggered preload: added cmdtype:module (ExternalScript, ending in .psm1), did some $State workarounds, updated the pre-stock calculated constants etc to provide data;  
replaced missing INVOKE_EXTRACTTDO (was errant 2nd copy of invoke-ProcessTDO)
* 4:08 PM 12/16/2025 updated to latest vio\start-sleepcountdown() ;
    Write-MyOutput Write-MyWarning  Write-MyOutput Write-MyWarning Write-MyVerbose:  made adv Func, wasn't detecting verbose -Verbose:($VerbosePreference -eq 'Continue')
* 9:57 AM 12/15/2025 add: vio\Remove-InvalidFileNameChars
* 11:57 AM 12/8/2025 ADD: vio\Start-SleepCountdown, Compare-ObjectsSideBySide, Compare-ObjectsSideBySide3, Compare-ObjectsSideBySide4
verb-ADMS\get-gcfast
set-ExchangeUrls\* 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
enable-XOPCertificateTDO\* 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
enable-XOPCertificateTDO\* 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
set-ExLicenseTDO\* 2:43 PM 12/2/2025 updated connect-xopLocalManagementShell wrapper logic; 
                ✅ got thru exec pass in lab; ✅ got through whatif pass in lab
        * 3:25 PM 12/1/2025 🚧 🐛 🔊 updated transcript build code, to include module-hosted func support, when local, non-AllUsers profile hosted; updated write-log/write-my* interaction to halt recursive loop (when no $state vari)
Resolve-xopMajorVersionTDO\* 3:06 PM 11/26/2025 init version, simplified major version version of Resolve-xopBuildSemVersToTextNameTDO, returns solely the build tag, not further details
Resolve-xopVersionTagToMinVersionNumTDO\* 3:06 PM 11/26/2025 init version, simplified major version version of Resolve-xopBuildSemVersToTextNameTDO, returns solely the build tag, not further details
test-LocalExchangeInfoTD\* 2:47 PM 12/2/2025 💡 updated the CBH demo to test for missing cmdlet, before doing reimport (conditional on actual fail; 
                imports are needed when this is called out of the .psm1 by another freestanding .ps1; 
                tends to work fine wo remedial ip from funcs inside the psm1). Tested in latest set-exLicense.
Get-ex16ExchangeServerTDO\* 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
Get-ex16MaintenanceModeTDO\* 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
Start-ex16MaintenanceMode\* 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
Stop-ex16MaintenanceMode\* 2:35 PM 12/2/2025 spliced in re-import connect-xopLocalManagementShell code
* 2:00 PM 12/2/2025 lab updates: got set-exLicense through whatif & exec passes in TOL, ready to use as model for copy-connector()
    - add: useEnterpriceLicense param, added licfile discovery code
* 10:36 AM 12/2/2025 add: ✨ Convert-xopAdminDisplayVersionTDO
* 3:02 PM 12/1/2025 🩹 write-log() fixed, getting recursive loop between write-log & write-myOutput|Warning|Error|Verbose (when no $State variable, it diverts back to write-log): added a loop counter, if it's more than 1x thru, it diverts to write-host local.
* 3:25 PM 12/1/2025 Set-ExLicense: 🚧 🐛 🔊 updated transcript build code, to include module-hosted func support, when local, non-AllUsers profile hosted; updated write-log/write-my* interaction to halt recursive loop (when no $state vari)
* 3:07 PM 11/26/2025 work from dbg etc on L6400T: add: Resolve-xopMajorVersionTDO(), updated Resolve-xopBuildSemVersToTextNameTD()
    Added code to resolve the local ExSetup & CabExSEtup versions into $CabExSetupMajorVersion & $InstalledExSetupMajorVersion
    added export to $global:InstalledExSetupVersion & $global:CabExSetup for back-defer, if not avail in depend calls.
* 3:21 PM 11/25/2025 add: CBH demo: # CONSTANTS_TTC_BUILD block, to backfill global variables in for local standardized use in other .ps1s
* 10:40 AM 11/24/2025 add: vx10\Resolve-xopBuildSemVersToTextNameTDO; set-ExLicenseTDO()
* 4:47 PM 11/4/2025 updated Import-CertificateTrustFileTDO & import-CertCERLegacy (testing in lab, with psv2 coverage)
* 1:23 PM 11/3/2025 Enable-RunOnceTDO:add: alias:Enable-RunOnce
* 2:54 PM 10/20/2025 SYNC'D latest c:\sc\ updates back into here. This should now be up to date.
* 2:36 PM 10/9/2025 reorganized functions order into region groupings, for easier duping/.commit into repos:
    region VLOG_MODULE_COMMON_FUNCTIONS
    region VIO_FUNCTIONS
    region VNET_MODULE_COMMON_FUNCTIONS
    region UWES__FUNC.PS1_FUNCTIONS
    region VX10_MODULE_COMMON_USE_FUNCTIONS
    region CONSTANTS_AND_ENVIRO
    region NETWORK_INFO
    region VAUTH_MODULE_COMMON_USE_FUNCTIONS
    repair-FileEncodingMixed 
    restored lost -replace \0 _actual fix_ from the set-content line.
    added     $ex15ScriptName const ; added pretest on drive hunts, to continue past missing drives ; added drive hunt timers & echo; 
    added $InstallPath CALCULATED_CONSTANTS, used for trailing repair func; 
    removed 821 suffixes (-> TDO) for: 
vnet:
test-CredentialsTDO; get-FullDomainAccountTDO; Test-LocalCredentialTDO; get-CredentialsTDO; Get-CurrentUserNameTDO; 
    Get-ForestRootNCTDO; Get-RootNCTDO ; Get-ForestConfigurationNCTDO; Get-ForestFunctionalLevelTDO;Test-DomainNativeModeTDO;Get-ForestRootNCTDO
vx10: 
Get-ExchangeOrganizationTDO; Test-ExchangeOrganizationTDO; Get-ExchangeForestLevelTDO; Get-ExchangeDomainLevel; connect-xopLocalManagementShell
get-xopLocalExSetupVersionTDO; 
vdesk:
    Enable-RunOnceTDO; Disable-UACTDO; Enable-UAC; Enable-AutoLogon; Disable-AutoLogonTDO; Disable-OpenFileSecurityWarningTDO; Enable-OpenFileSecurityWarning; Enable-OpenFileSecurityWarningTDO; Disable-IEESCTDO; Enable-IEESCTDO;
    Invoke-ExtractTDO; Install-MyPackageTDO; Invoke-ProcessTDO; 
    Stop-BackgroundJobsTDO; 
vio:
repair-FileEncodingMixed
X15:
Restore-Exchange15StateTDO; Save-Exchange15StateTDO; complete-CleanupExchange15; 
* 5:01 PM 10/8/2025 got through L6400 completion ; Add: Save-Exchange15StateTDO() ; 
    added added back differential write-my* support to: 'Enable-OpenFileSecurityWarning','Disable-UA','Disable-IEESC','Enable-AutoLogon','Enable-RunOnce','Enable-UAC','Enable-IEESC';
    ADD: 'Restore-Exchange15StateTDO','Disable-IEESCTDO','Enable-IEESCTDO','complete-CleanupExchange15' for remedial fixes to incomplete install-Exchange15-TTC.ps1 passes (that the script itself won't fix on fresh passes);
    sub'd out all \w+-\w+821 named functions and calls, updated aliases to drop 821 suffixes (matches source .ps1 calls); 
    CALCULATED_CONSTANTS: added resolve $InstallPath; and timer on InstallPath & Ca
* 4:18 PM 10/6/2025 Added COMMON_CONSTANTS to top; followed by ENCODED_CONSTANTS, LOCAL_CONSTANTS, and CALCULATED_CONSTANTS, that are based on the other constants, but not on functions that follow 
    RESOLVE_ENVIRONMENTTDO:removed write-my* calls: implemented support in vio\write-log() instead (avoids all this manual updating)
    push-TLSLatest: spliced orig expanded CBH over, brought up to date
    write-log:* 3:12 PM 9/16/2025 add: seamless support for Write-MyVerbose|Write-MyOutput|Write-MyWarning|Write-MyError: where they gcm, divert into those functions, otherwise normal material applies
                Unfortunately write-myOutput lacks -indent support, so we just drop the indents with a wv notice it's dropped, and do the usual write-MyOutput. 
                Also note, I'm expecting the stock 821 write-myOutput has been replaced with my updated write-myOutput(), 
                to suppresse default write-output of the message behavior in the original into the pipeline, blowing the buffer, corrupting function returns. 
                Instead my tweaked write-myOutput() does a normal write-host of the message within the write-myOutput. 
    test-CredentialsTDO/get-credentialstdo()/Get-CurrentUserNameTDO/test-SchemaAdmi821;Test-EnterpriseAdminTDO; Test-PendingReboot: get-forestrootnctdo; get-rootnctdo; get-forestconfigurationnctdo; ; 
    get-forestfunctionalleveltdo; test-domainnativemodetdo; get-exchangeorganizationtdo; test-exchangeorganizationtdo; get-exchangeforestleveltdo; get-exchangedomainleveltdo;  
    add to vnet; remove write-my*() calls (write-log has native defer support now)
    get-fileversiontdo:      
        * 9:31 AM 10/2/2025 add alias: 'Get-DetectedFileVersionTDO'
        * 9:13 AM 9/24/2025 moved vx10->vxio
        * 10:26 AM 9/22/2025 ren Get-DetectedFileVersionTDO -> Get-FileVersionTDO (better descriptive name for what it does, better mnemomic) ; port to vio from xopBuildLibrary; add CBH, and Adv Function specs
            added CBH; init; aliased orig name
    Get-SetupTextVersionTDO
        * 9:41 AM 10/2/2025 updated CBH w expanded comment about why running both this, and Resolve-xopBuildSemVersToTextNameTDO: they output different ProductName equivelents,
            which are already stored in build state .xml files on servers (would change the spec mid-build)
        * 10:48 AM 9/22/2025 port to uwes's as _func.ps1 (not a generic mod use; load when needed) from xopBuildLibrary; add CBH, and Adv Function specs
        * 1:58 PM 8/8/2025 added CBH; init; renamed AdminAccount -> Account, aliased  orig param and logon variant. ren: Get-SetupTextVersionTDO -> Get-SetupTextVersionTDO, aliased orig name
        * 9:05 AM 6/2/2025 expanded CBH, copied over current call from psparamt
    Test-isSchemaAdminTDO
        * 1:26 PM 9/17/2025 init, ported from xopBuildLibrary to vAuth
    Test-IsEnterpriseAdminTDO
        * 2:29 PM 9/18/2025 ren Test-IsEnterpriseAdmin -> Test-IsEnterpriseAdminTDO, alias orig, add alias Test-EnterpriseAdmin; add region tags
        * 12:05 PM 9/17/2024 flipped $User non-mand w [ValidateNotNullOrEmpty()]
    Test-PendingRebootTDO 
        * 1:56 PM 9/18/2025 add verbose echo of regkey that tagged a reboot; ren Test-PendingReboot -> Test-PendingRebootTDO; alias orig name; add region tags
            cbh: updated cited output to pscustomobject.
    Enable-RunOnceTDO
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            add splatting on the new-itemprop, to store the settings being set;  
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
    Disable-UACTDO
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
    Enable-UACTDO
        * 4:41 PM 10/6/2025 fixed comment brackets ; 
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
    Enable-AutoLogonTDO
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
                remove the write-my*() support (defer to native w-l support)
            * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
    Disable-AutoLogonTDO
    * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
                remove the write-my*() support (defer to native w-l support)
            * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
    Disable-OpenFileSecurityWarningTDO
            * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
                remove the write-my*() support (defer to native w-l support)
            * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
    Enable-OpenFileSecurityWarningTDO
            * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
                remove the write-my*() support (defer to native w-l support)
            * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat)       
    get-FullDomainAccountTDO
            * 1:14 PM 9/17/2025 port to vnet from xopBuildLibrary; add CBH, and Adv Function specs
            * 1:58 PM 8/8/2025 added CBH; init; renamed AdminAccount -> Account, aliased  orig param and logon variant. ren: get-FullDomainAccountTDO -> get-FullDomainAccountTDO, aliased orig name  
    Clear-AutodiscoverServiceConnectionPointTDO
            * 2:36 PM 9/25/2025 reflects 4.20 github vers update:  not a common admin task, skip vx10 add: park in uwes\Set-AutodiscoverServiceConnectionPointTDO_func.ps1 ; 
            add CBH, and Adv Function specs         
    Set-AutodiscoverServiceConnectionPointTDO
            * 9:38 AM 9/29/2025 CBH revised expls
            * 2:36 PM 9/25/2025 reflects 4.20 github vers update:  not a common admin task, skip vx10 add: park in uwes\Set-AutodiscoverServiceConnectionPointTDO_func.ps1 ; 
            add CBH, and Adv Function specs  
    Enable-WindowsDefenderExclusionsTDO
                * 4:52 PM 10/6/2025 TTC: add cmdletbinding, param & alias, append TDO to name; added non-$State support: elseif's through $TargetPath when $State['TargetPath'] missing
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
    Set-AutodiscoverServiceConnectionPointTDO
    * 4:48 PM 10/6/2025 add TDO to bracket tags
            * 9:38 AM 9/29/2025 CBH revised expls
            * 2:36 PM 9/25/2025 reflects 4.20 github vers update:  not a common admin task, skip vx10 add: park in uwes\Set-AutodiscoverServiceConnectionPointTDO_func.ps1 ; 
            add CBH, and Adv Function specs     
    Enable-HighPerformancePowerPlanTDO 
                * 9:10 AM 10/7/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
                * 4:55 PM 10/6/2025 add cmdletbinding, param & alias, append TDO to name; added non-$State support: elseif's through $TargetPath when
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func       
    Disable-NICPowerManagementTDO
                * 9:10 AM 10/7/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
                * 4:55 PM 10/6/2025 add cmdletbinding, param & alias, append TDO to name; a
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
    Set-PagefileTDO
                * 9:10 AM 10/7/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
                * 4:55 PM 10/6/2025 add cmdletbinding, param & alias, append TDO to name; patch in non-$State support
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
    Set-TCPSettingsTDO
                * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name; 
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
    Disable-SSL3TDO
                * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name;             
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
    Disable-RC4TDO
                * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name;  
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
    Set-TLSSettingsTDO
                * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name; 
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func             
    Enable-CBCTDO
                * 8:42 AM 10/7/2025 add cmdletbinding, param & alias, append TDO to name;
                Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func 
    Get-MyPackageTDO
                * 11:34 AM 8/15/2025 ren: Get-MyPackage -> Get-MyPackageTDO and alias the orig name;  add: CBH, fleshed out Parameter specs into formal well specified block. Added variety of working examples, for reuse adding future patches/packages to the mix.
                * 821's posted copy w/in install-Exchange15.ps1: Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func
    Test-MyPackageTDO
                * 11:47 AM 10/2/2025 port to C:\sc\powershell\PSScripts\build\Test-MyPackageTDO_func.ps1 - niche use, doesn't bear building into verb-io mod etc, but useful for patch verifications; also in xopBuildLibrary.psm1      
                    substantially updated the CBH demos, citing specific pkg test examples that can be easily reused.
                * 11:34 AM 8/15/2025 ren: Test-MyPackage -> Test-MyPackageTDO and alias the orig name; add: CBH, fleshed out Parameter specs into formal well specified block. Added variety of working examples, for reuse adding future patches/packages to the mix.
                * 821's posted copy w/in install-Exchange15.ps1: Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func                        
    Install-MyPackageTDO
                * 10:48 AM 10/6/2025 reworked demos; add var code for lack of $State[]; add alias Install-MyPackage
                * 12:06 PM 10/2/2025 ren Install-MyPackage -> Install-MyPackageTDO, alias original & 821 variant
    connect-XopLocalManagementShell
                * 2:42 PM 10/6/2025 updated CBH for demo of new remedial call import code; code to detect preexisting pssessions, and skip rexec redund, also to remove those as they accumulate; 
    get-IISLocalBoundCertifcateTDO
                * 2:40 PM 10/1/2025 updated CBH example; added to xopBuildLibrary.psm1
                * 4:01 PM 9/30/2025 init
    Stop-BackgroundJobsTDO
                * 10:17 AM 9/29/2025 reflects 4.20 github vers update:  port to vio from xopBuildLibrary; add CBH, and Adv Function specs; config defer of w-My to native wlt
    Round-NumberTDO
                * 9:01 AM 10/7/2025 added  if gcm
    get-LocalDiskFreeSpaceTDO
                * 11:03 AM 9/29/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
                added -raw, and dump  unformatted data fields into pipleine
                add to vio
    Set-WallpaperTDO
                * 11:13 AM 9/29/2025 rplc verb-noun -> Set-WallpaperTDO
    Reset-CurrentWallpaperTDO
                * 11:17 AM 9/29/2025 CBH: corrected output spec to None.
    get-OSFullVersionTDO
                * 12:12 PM 10/6/2025 add -MajorVersion & MinorVersion to return those sub-strings (support queries for the values in isolation); updated logic for the variant outputs.
                * 11:26 AM 9/29/2025 port from install-Exchnage15-TTC.ps1 into vdesk
    get-xopLocalBinVersionTDO
                * 3:27 PM 10/2/2025 init         
    get-xopLocalExSetupVersionTDO
                * 1:29 PM 10/2/2025 init  

* 11:38 AM 9/29/2025 rename xopBuildLibrary.ps1 -> xopBuildLibrary.psm1: already ran into an issue running ipmo -fo -verb that was fed by a gci, and tried to ipmo -fo -verb xopBuildLibrary.ps1 unintentially
There's a solid need to have unexecutable/iflv-able libraries - extensioned .psm1, and execuable scripts always .ps1. Don't mix the two. You never know when your .ps1 library will wind up in an executable target.
    RELOCATIONS: 
    - Constants are dependancies, same effects above: Move COMMON_CONSTANTS up first, as long as they aren't dependant on calculated constants.  
    - functions frequently don't work, if not declared before first call in same module: Move them up as FUNCTIONS_INTERNAL, after dependant constants
    - Calculated Constants/info variables, get moved down below the local function declarations as LOCAL_INFOVARIABLES
# 2:22 PM 9/18/2025 defer into my Test-IsEnterpriseAdminTDO, over Test-EnterpriseAdmin821; defer prior test-PendingReboot821() to a copy of my more fleshed out stock func
* 12:54 PM 9/17/2025 updated to latest vlog\write-log()
* 4:30 PM 9/15/2025 block-fileTDO(): updated CBH with set-content -stream info (only writes the stream around the file, not the entire file)
Test-FileBlockedStatusTDO(): flipped -Path to [string] -> [string[]] and test-path validation; process stack of specs, emit blocks, to pipeline; 
add CBH demos for 1-liner test and unblock & vsdev/xopBuildLibrary loads 
* 6:02 PM 9/11/2025 flipped pipeline output to fileinfo object, vs string fullname (unblock won't pipeline process the string, doers the object) ; 
ren'd Test-FileBlockedStatus -> Test-FileBlockedStatusTDO, aliased orig name
* 6:11 PM 9/11/2025 added: block-fileTDO & Test-FileBlockedStatus():revised: error workaround: $adsPath = "$($file.FullName):$ZoneIdentifierStream"; test-Path -LiteralPath $adsPath ;  init
* 3:31 PM 9/4/2025 add: get-LocalDiskFreeSpace New-WallpaperStatusTDO Set-WallpaperTDO
* 10:42 AM 9/3/2025 add: repair-FileEncodingMixed() for fixing damage to install-exchange15.ps1 logs, to get readability back, postreviwwing completion status
* 1:39 PM 8/20/2025 add: test-LocalDrivePathTDO()
* 10:09 AM 8/18/2025 add: Constants '$Ex16ServersTOL','$rgxEx16ServersTOL','$Ex16ServersTOLEdg','$rgxEx16ServersTOLEdg' ; 
    add: Test-Port ; Send-EmailNotif
* 3:54 PM 8/17/2025 added -InstallPhase param to invoke-Exchange15SetupFailPostflight(); 
    -  invoke-Exchange15SetupFailPostflight edge update: added rgxEdgeInstalledRole and detect of duplicate setup pass after completed Edge install (expected non-impactful error if no watermarks).; 
    - #4011 xop-connect... fix: vari expan doesn't work in single quotes => dbl quot
* 5:53 PM 8/16/2025 Stop-ex16MaintenanceMode: add Edge detection support; code to do the $isDAG test within the function (and not inherited)
* 5:47 PM 8/16/2025 Start-ex16MaintenanceMode: add Edge detection support
* 5:32 PM 8/16/2025 Get-ex16MaintenanceModeTDO(): add Edge detection support
* 5:12 PM 8/16/2025 connect-XopLocalManagementShell():Edge lacks RemoteExchange.ps1, added regkey edge test to exempt test for the file (was causing premature throw).
* 2:47 PM 8/15/2025 updated to latest: Invoke-ProcessTDO; Test-MyPackageTDO; Get-MyPackageTDO; Invoke-ExtractTDO (updated/expanded versions of the 821 orig functions)
* 9:17 AM 8/14/2025 ren: show-localNicsTDO -> get-localNicsTDO, alias orig name
* 3:40 PM 8/13/2025 show-localNicsTDO init, added to xopBuildLibary.ps1 & verb-io
* 3:45 PM 8/11/2025 added write-my* customized versions, to get defers working; flipped any -whatif's to non-default $true
* 4:50 PM 7/23/2025 major updates, a lot of write-My hybrid support added, along with fixes and reliance on some of these called from install-exchange15-ttc.ps1
  
.DESCRIPTION
xopBuildLibrary - Exchange Server Build Utilties Module

# library of functions for support of XOP build
# centralize the functions distributed in the FUNCTIONS_INTERNAL blocks, simpler to maintain, call them once

# github: [GitHub - michelderooij/Install-Exchange15: Script to fully unattended Exchange 2016/2019 deployments.](https://github.com/michelderooij/Install-Exchange15)

### PULL TOGETHER CONSTANTS THAT NEED TO BE LOCALLY DELCARED (FROM SOURCE install-Exchange15-TTC.ps1)

if you assume: 
1. A code sample uses convention that 'CONSTANT' variables - assuming they aren't manually tagged by read-only-them (which is a runtime status, not a static marker)
- are ALL CAPS, and contain solely [A-Z0-9_] char classes -> 
you can sls filter out all constants in a file;
2. You can then collect all PS Autovariables, 
3. And the Autovariables list will let you compare and postfilter your filtered 'CONSTANTS' list, into just the NON-AutoVariable capitalized variables from the script, 
=> to identify dependant Constants your library needs to include/declare-locally:

Code that performs the above against .xopBuildLibrary.ps1:
```powershell
write-verbose "Collect default varis in a -noprofile powershell session (excluding single-char name varis)..." 
$autovNames =  @(powershell.exe -NoProfile -Command { Get-Variable | Select-Object -ExpandProperty Name }) ; 
$autovNames = @($autovNames |?{$_.length -gt 1} | Sort-Object) ; 
write-verbose "Add the ENV environment system variable (so we filter it out as well)" ; 
$autovNames += @('ENV') ; 
write-verbose "pad the names out into proper `$[Name] variable specs for comparison" ; 
$AutoVariables = $autovNames | %{"`$$($_)"} ; 
write-verbose "then cmatch out all capitalized variables, postfiltering out autovariable names" ; 
gc D:\scripts\build\xopBuildLibrary.ps1 | ?{$_ -cmatch '(\$[A-Z0-9_]+\b)'} | %{$matches[0]} | select -unique |?{$_ -notmatch '\$_|\$ENV'} |?{$AutoVariables -notcontains $_} ; 
```

.EXAMPLE
usage: To load library: UNBLOCK & load, including the vsdev files (if vsdevISEFiles.txt is present)
PS> $whatif = $true ; 
PS> cd d:\cab; 
PS> $tfiles = @() ; 
PS> If($vdevISEFiles = gc .\vdevISEFiles.txt -ea 1){$tfiles += @(gci d:\cab\*_func.ps1 -Include $vdevISEFiles)} ; 
PS> $tfiles += @("D:\cab\xopBuildLibrary.ps1") ; 
PS> $tfiles | %{
PS>     $thisfile = $_ ; 
PS>     if(gi $thisfile  -Stream 'Zone.Identifier' -ea 0 |%{gc $_.FileName -Stream 'Zone.Identifier' |?{$_ -match "ZoneId=3"}}){
PS>         gci $thisfile| Unblock-File -verbose -whatif:$($whatif)  ; 
PS>     } else{write-verbose "$tfile isn't blocked" } ; 
PS>     $thisfile | ipmo -fo -verb
PS> } ; 
.EXAMPLE
#region CONSTANTS_TTC_BUILD ; #*------v CONSTANTS_TTC_BUILD v------
# back-defer populate $installpath -> $global:BuildInstallPath
if($installpath -AND (test-path -path $installpath -PathType Container -ea 0)){
    $smsg = "validated functional `$installpath: $($installpath)" ;
    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ;
} elseif($global:BuildInstallPath -AND (test-path -path $global:BuildInstallPath -PathType Container)){
    $smsg = "Invalid existing `$installpath ($($installpath)) -> defaulting to detected functional `$global:BuildInstallPath: ($($global:BuildInstallPath))" ;
    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
    } ;
}elseif(-not $installpath){
    $smsg = "NO POPULATED `$installpath: $($installpath)!" ;
    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    throw $smsg
    break ;
} ;
# $InstalledSetup -> $global:InstalledExSetup 
if($InstalledSetup -AND (test-path -path $InstalledSetup -PathType Container -ea 0)){
    $smsg = "validated functional `$InstalledSetup: $($InstalledSetup)" ;
    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ;
} elseif($global:InstalledExSetup -AND (test-path -path $global:InstalledExSetup -PathType Container)){
    $smsg = "Invalid existing `$InstalledSetup ($($InstalledSetup)) -> defaulting to detected functional `$global:InstalledExSetup: ($($global:InstalledExSetup))" ;
    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
    } ;
}elseif(-not $InstalledSetup){
    $smsg = "NO POPULATED `$InstalledSetup: $($InstalledSetup)!" ;
    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    throw $smsg
    break ;
} ;
# $InstalledSetupVersion -> $global:InstalledExSetupVersion
if($InstalledSetupVersion -AND (test-path -path $InstalledSetupVersion -PathType Container -ea 0)){
    $smsg = "validated functional `$InstalledSetupVersion: $($InstalledSetupVersion)" ;
    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ;
} elseif($global:InstalledExSetupVersion -AND (test-path -path $global:InstalledExSetupVersion -PathType Container)){
    $smsg = "Invalid existing `$InstalledSetupVersion ($($InstalledSetupVersion)) -> defaulting to detected functional `$global:InstalledExSetupVersion: ($($global:InstalledExSetupVersion))" ;
    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
    } ;
}elseif(-not $InstalledSetupVersion){
    $smsg = "NO POPULATED `$InstalledSetupVersion: $($InstalledSetupVersion)!" ;
    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    throw $smsg
    break ;
} ;
# $CabExSetup (good as is) -> $global:CabExSetup
if($CabExSetup -AND (test-path -path $CabExSetup -PathType Container -ea 0)){
    $smsg = "validated functional `$CabExSetup: $($CabExSetup)" ;
    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ;
} elseif($global:CabExSetup -AND (test-path -path $global:CabExSetup -PathType Container)){
    $smsg = "Invalid existing `$CabExSetup ($($CabExSetup)) -> defaulting to detected functional `$global:CabExSetup: ($($global:CabExSetup))" ;
    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
    } ;
}elseif(-not $CabExSetup){
    $smsg = "NO POPULATED `$CabExSetup: $($CabExSetup)!" ;
    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    throw $smsg
    break ;
} ;
#endregion CONSTANTS_TTC_BUILD ; #*------^ END CONSTANTS_TTC_BUILD ^------
CONSTANTS_TTC_BUILD block, to backfill global variables in for local standardized use
.LINK
https://github.com/tostka/xopBuildLibrary
#>

#region ENVIRO_DISCOVER ; #*------v ENVIRO_DISCOVER v------
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
if($rMyInvocation.mycommand.commandtype -eq 'ExternalScript' -AND [regex]::match($rMyInvocation.mycommand.source.tolower(),'\.\w+$').value -eq '.psm1'){
    #'module'
    $cmdType = 'Module'  ; $isScript = $false ; $isfunc = $false ; $isFuncAdv = $false  ; 
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
    }elseif($rMyInvocation.mycommand.source){
        if($CmdParentPathed = (resolve-path -path $rMyInvocation.mycommand.source).path){
            $CmdParentDir = split-path $CmdParentPathed ;                  
            write-verbose "Hosted function, mock it up as a proxy path for transcription name" ; 
            $CmdParentPathedExt = [regex]::match($CmdParentPathed,'(\.\w+$)').value
            $CmdPathed = (join-path -Path $CmdParentDir -ChildPath "$($CmdName)")           
        } else{
            throw "emtpy `$rMyInvocation.ScriptName!, unable to calculate isFunc: `$CmdParentDir!" ; 
        }        
    } ;
    $smsg = "`$isScript : $(($isfunc|out-string).trim())" ; 
    $smsg += "`n`$isfunc : $(($isfunc|out-string).trim())" ; 
    $smsg += "`n`$CmdName :$(($CmdName|out-string).trim())" ; 
    $smsg += "`n`$CmdParentPathed : $(($CmdParentPathed|out-string).trim())" ; 
    $smsg += "`n`$CmdParentDir : $(($CmdParentDir|out-string).trim())" ; 
    $smsg += "`n`$CmdPathed (log proxy) : $(($CmdPathed|out-string).trim())" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
}elseif($rMyInvocation.mycommand.commandtype -eq 'ExternalScript'){
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
#endregion ENVIRO_DISCOVER ; #*------^ END ENVIRO_DISCOVER ^------
#region COMMON_CONSTANTS ; #*------v COMMON_CONSTANTS v------    
if(-not $DoRetries){$DoRetries = 4 } ;    # # times to repeat retry attempts
if(-not $RetrySleep){$RetrySleep = 10 } ; # wait time between retries
if(-not $RetrySleep){$DawdleWait = 30 } ; # wait time (secs) between dawdle checks
if(-not $DirSyncInterval){$DirSyncInterval = 30 } ; # AADConnect dirsync interval
if(-not $ThrottleMs){$ThrottleMs = 50 ;}
if(-not $rgxDriveBanChars){$rgxDriveBanChars = '[;~/\\\.:]' ; } ; # ;~/\.:,
if(-not $rgxCertThumbprint){$rgxCertThumbprint = '[0-9a-fA-F]{40}' } ; # if it's a 40char hex string -> cert thumbprint
if(-not $rgxSmtpAddr){$rgxSmtpAddr = "^([0-9a-zA-Z]+[-._+&'])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,63}$" ; } ; # email addr/UPN
if(-not $rgxDomainLogon){$rgxDomainLogon = '^[a-zA-Z][a-zA-Z0-9\-\.]{0,61}[a-zA-Z]\\\w[\w\.\- ]+$' } ; # DOMAIN\samaccountname
if(-not $exoMbxGraceDays){$exoMbxGraceDays = 30} ;
if(-not $XOConnectionUri ){$XOConnectionUri = 'https://outlook.office365.com'} ;
if(-not $SCConnectionUri){$SCConnectionUri = 'https://ps.compliance.protection.outlook.com'} ;
if(-not $XODefaultPrefix){$XODefaultPrefix = 'xo' };
if(-not $SCDefaultPrefix){$SCDefaultPrefix = 'sc' };
if(-not $Ex16ServersTOL){$Ex16ServersTOL = 'LYNMS6400T.global.ad.torolab.com','LYNMS6401T.global.ad.torolab.com','LYNMS6400T','LYNMS6401T','10.92.9.12','10.92.9.13' ; } ; 
if(-not $rgxEx16ServersTOL){$rgxEx16ServersTOL = ('(' + (($Ex16ServersTOL |%{[regex]::escape($_)}) -join '|') + ')') ; } ; 
if(-not $Ex16ServersTOLEdg){$Ex16ServersTOLEdg = 'LYNMS6500T.torolab.com','LYNMS6501T.torolab.com','LYNMS6500T','LYNMS6501T','10.92.3.3','10.92.3.4' ;  } ; 
if(-not $rgxEx16ServersTOLEdg){$rgxEx16ServersTOLEdg = ('(' + (($Ex16ServersTOLEdg |%{[regex]::escape($_)}) -join '|') + ')') ; } ; 
if(-not $Ex16ServersTOR){$Ex16ServersTOR = 'LYNMS6400.global.ad.toro.com','LYNMS6401.global.ad.toro.com','LYNMS6402.global.ad.toro.com','LYNMS6403.global.ad.toro.com','LYNMS6400','LYNMS6401','LYNMS6402','LYNMS6403','170.92.9.6','170.92.9.7','170.92.9.8','170.92.9.9'  } ; 
if(-not $rgxEx16ServersTOR){$rgxEx16ServersTOR = ('(' + (($Ex16ServersTOR |%{[regex]::escape($_)}) -join '|') + ')') ; } ; 
if(-not $Ex16ServersTOREdg){$Ex16ServersTOREdg = 'LYNMS6500.toro.com','LYNMS6501.toro.com','LYNMS6500','LYNMS6501','170.92.3.115','170.92.3.116' ;  } ; 
if(-not $rgxEx16ServersTOREdg){$rgxEx16ServersTOREdg = ('(' + (($Ex16ServersTOREdg |%{[regex]::escape($_)}) -join '|') + ')') ; } ; 
#region RSLV_SMTPSERVER ; #*------v RSLV_SMTPSERVER v------
if(-not $global:SMTPServer){
    switch($env:userdomain){
        'TORO'{
            $global:SMTPServer = 'lynms650.global.ad.toro.com' ; 
            $smsg += "`nSET:`$global:SMTPServer: $($global:SMTPServer)" ;     
        }
        'TORO-LAB'{
            $global:SMTPServer = 'lynms650D.global.ad.torolab.com' 
            $smsg += "`nSET:`$global:SMTPServer: $($global:SMTPServer)" ;     
        }
        $env:COMPUTERNAME {
                $smsg = "NON-AD-connected `$env:userdomain:$($env:userdomain)!" ; 
                if($Ex16ServersTOLEdg -contains $env:computername){
                    $global:SMTPServer = $env:computername ; 
                }elseif($Ex16ServersTOREdg -contains $env:computername){
                    $global:SMTPServer = $env:computername ; 
                } ;
                $smsg += "`nSET:`$global:SMTPServer: $($env:computername)" ;                   
        }
        default{
            $smsg = "Unconfigured `$env:userdomain:$($env:userdomain)! (unable to SET:`$global:SMTPServer:)" ;                             
            if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error}
                else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
        }
    } ;
    if($global:SMTPServer){ 
        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        } ; ;
    } else { 
        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;

    }
} ; 
#endregion RSLV_SMTPSERVER #*------^ END #region RSLV_SMTPSERVER ; 
#$rgxADDistNameGAT = ",$(($TORMeta.UnreplicatedOU -split ',' | select -skip 1 ) -join ',')"
#$rgxADDistNameAT = ",$(($TORMeta.UnreplicatedOU -split ',' | select -skip 2 ) -join ',')"
#region WHPASSFAIL ; #*------v WHPASSFAIL v------
if(-not $whPASS){$whPASS = @{ Object = "$([Char]8730) PASS" ; ForegroundColor = 'Green' ; NoNewLine = $true  } }
if(-not $whFAIL){$whFAIL = @{'Object'= if ($env:WT_SESSION) { "$([Char]8730) FAIL"} else {' !X! FAIL'}; ForegroundColor = 'RED' ; NoNewLine = $true } } ;
# light diagonal cross: ╳ U+2573 DOESN'T RENDER IN PS, use it if WinTerm
if(-not $psPASS){$psPASS = "$([Char]8730) PASS" } # $smsg = $pspass + " :Tested Drives" ; write-host $smsg ;
if(-not $psFAIL){$psFAIL = if ($env:WT_SESSION) { "$([Char]8730) FAIL"} else {' !X! FAIL'} } ; # $smsg = $psfail + " :Tested Drives" ; write-warning $smsg ;
<#
# inline pass/fail color-coded w char
$smsg = "Testing: THING" ; 
$Passed = $true ; 
Write-Host "$($smsg)... " -NoNewline ; 
if($Passed){Write-Host @whPASS} else {write-host @whFAIL} ; 
Write-Host " (Done)" ;
# out: Test:Thing... √ PASS (Done) | Test:Thing...  X FAIL (Done)
#>
#endregion WHPASSFAIL ; #*------^ END WHPASSFAIL ^------

$smsg = "Coerce configured but blank Resultsize to Unlimited" ;
if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
} ;
if(get-variable -name resultsize -ea 0){
    if( ($null -eq $ResultSize) -OR ('' -eq $ResultSize) ){$ResultSize = 'unlimited' }
    elseif($Resultsize -is [int]){} else {
        $smsg = "Resultsize must be an integer or the string 'unlimited' (or blank)"
        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;  
        throw $smsg ;
    } ;
} ;
#$ComputerName = $env:COMPUTERNAME ;
#$NoProf = [bool]([Environment]::GetCommandLineArgs() -like '-noprofile'); # if($NoProf){# do this};
# XXXMeta derived constants:
# - AADU Licensing group checks
# calc the rgxLicGrpName fr the existing $xxxmeta.rgxLicGrpDN: (get-variable tormeta).value.rgxLicGrpDN.split(',')[0].replace('^','').replace('CN=','')
#$rgxLicGrpName = (get-variable -name "$($tenorg)meta").value.rgxLicGrpDN.split(',')[0].replace('^','').replace('CN=','')
# use the dn vers LicGrouppDN = $null ; # | ?{$_ -match $tormeta.rgxLicGrpDN}
#$rgxLicGrpDN = (get-variable -name "$($tenorg)meta").value.rgxLicGrpDN
# email trigger vari, it will be semi-delimd list of mail-triggering events
$script:PassStatus = $null ;
# TenOrg or other looped-specific PassStatus (auto supported by 7pswlt)
#New-Variable -Name PassStatus_$($tenorg) -scope Script -Value $null ;
[array]$SmtpAttachment = $null ;
#write-verbose "start-Timer:Master" ;
$swM = [Diagnostics.Stopwatch]::StartNew() ;
# $ByPassLocalExchangeServerTest = $true # rough in, code exists below for exempting service/regkey testing on this variable status. Not yet implemented beyond the exemption code, ported in from orig source.
#endregion COMMON_CONSTANTS ; #*------^ END COMMON_CONSTANTS ^------
#region ENCODED_CONSTANTS ; #*------v ENCODED_CONSTANTS v------
# ENCODED CONsTANTS & SUPPORT FUNCTIONS:
#region 2B4 ; #*------v 2B4 v------
if(-not (get-command 2b4 -ea 0)){function 2b4{[CmdletBinding()][Alias('convertTo-Base64String')] PARAM([Parameter(ValueFromPipeline=$true)][string[]]$str) ; PROCESS{$str|foreach-object {[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($_))}  };} ; } ;
#endregion 2B4 ; #*------^ END 2B4 ^------
#region 2B4C ; #*------v 2B4C v------
# comma-quoted return
if(-not (get-command 2b4c -ea 0)){function 2b4c{ [CmdletBinding()][Alias('convertto-Base64StringCommaQuoted')] PARAM([Parameter(ValueFromPipeline=$true)][string[]]$str) ;BEGIN{$outs = @()} PROCESS{[array]$outs += $str | foreach-object {[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($_))} ; } END {'"' + $(($outs) -join '","') + '"' | out-string | set-clipboard } ; } ; } ;
#endregion 2B4C ; #*------^ END 2B4C ^------
#region FB4 ; #*------v FB4 v------
# DEMO: $SitesNameList = 'THluZGFsZQ==','U3BlbGxicm9vaw==','QWRlbGFpZGU=' | fb4 ;
if(-not (get-command fb4 -ea 0)){function fb4{[CmdletBinding()][Alias('convertFrom-Base64String')] PARAM([Parameter(ValueFromPipeline=$true)][string[]]$str) ; PROCESS{$str | foreach-object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }; } ; } ; };
#endregion FB4 ; #*------^ END FB4 ^------
# FOLLOWING CONSTANTS ARE USED FOR DEPENDANCY-LESS CONNECTIONS
if(-not $CMW_logon_SID){$CMW_logon_SID = 'Q01XXGQtdG9kZC5rYWRyaWU=' | fb4 } ;
if(-not $o365_Toroco_SIDUpn){$o365_Toroco_SIDUpn = 'cy10b2RkLmthZHJpZUB0b3JvLmNvbQ==' | fb4 } ;
if(-not $TOR_logon_SID){$TOR_logon_SID = 'VE9ST1xrYWRyaXRzcw==' | fb4 } ;

#endregion ENCODED_CONSTANTS ; #*------^ END ENCODED_CONSTANTS ^------
#region LOCAL_CONSTANTS ; #*------v LOCAL_CONSTANTS v------
#ONLY USED used in test/install-mypackage(TDO)
if(-not $EX2016SETUPEXE_CU23){$EX2016SETUPEXE_CU23            = '15.01.2507.006'} ;         
if(-not $EX2019SETUPEXE_CU10){$EX2019SETUPEXE_CU10            = '15.02.0922.007'} ; 
if(-not $EX2019SETUPEXE_CU11){$EX2019SETUPEXE_CU11            = '15.02.0986.005'} ; 
if(-not $EX2019SETUPEXE_CU12){$EX2019SETUPEXE_CU12            = '15.02.1118.007'} ; 
if(-not $EX2019SETUPEXE_CU13){$EX2019SETUPEXE_CU13            = '15.02.1258.012'} ; 
if(-not $EX2019SETUPEXE_CU14){$EX2019SETUPEXE_CU14            = '15.02.1544.004'} ; 
if(-not $EX2019SETUPEXE_CU15){$EX2019SETUPEXE_CU15            = '15.02.1748.008'} ; 
if(-not $EXSESETUPEXE_RTM){$EXSESETUPEXE_RTM               = '15.02.2562.017'} ; 
if(-not $EX2016_MAJOR ){$EX2016_MAJOR                   = '15.1'}
if(-not $EX2019_MAJOR){$EX2019_MAJOR                   = '15.2'}
#if(-not $ex15ScriptName){$ex15ScriptName = "Install-Exchange15-TTC.ps1" }
if(-not $ex15ScriptName){$ex15ScriptName = (split-path $CmdPathed -leaf) }
#endregion LOCAL_CONSTANTS ; #*------^ END LOCAL_CONSTANTS ^------
#region CALCULATED_CONSTANTS ; #*------v CALCULATED_CONSTANTS v------
#xopBuildLibrary.psm1, configure stock constants for reference in testing etc:
# 12:41 PM 11/24/2025 we need to export some of these as standards. But we cant use as globals with undifferentiated names
# So we'll adapt them to globals as:

# check for installed bin version
#if((gcm ExSetup.exe -ea 0).source){
#if($InstalledSetup= (gcm ExSetup.exe).source){$InstalledSetupVersionText= Get-SetupTextVersionTDO $InstalledSetup } ; 
if(-not $global:InstalledExSetupVersion){
    $smsg = "Checking for installed Bin ExSetup.exe..." ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
    if($InstalledSetup= (gcm ExSetup.exe -ea 0).source){
        $smsg = "Resolved an installed Bin ExSetup: $($InstalledSetup)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        # 3:15 PM 11/21/2025 also resolve the product version as well
        [version]$InstalledSetupVersion = (get-item $InstalledSetup -ea STOP).VersionInfo.productversion ; 
        $smsg = "Exporting `$InstalledSetup as `$global:InstalledExSetup: $($InstalledSetup) " ;
        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        } ;
        $global:InstalledExSetup = $InstalledSetup ; 
        $smsg = "Exporting `$InstalledSetupVersion as `$global:InstalledExSetupVersion: $($InstalledSetupVersion) " ;
        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        } ;
        $global:InstalledExSetupVersion = $InstalledSetupVersion ; 
    }else{
        <#$smsg = "NO EXCHANGE %ProgramFiles%\Microsoft\Exchange Server\V15\bin\ExSetup.exe FOUND" ; 
        $smsg += "`nEXCHANGE HAS NOT BEEN INSTALLED ON $($env:COMPUTERNAME) YET!" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        BREAK ; 
        #>
        $smsg = "No Exchange %ProgramFiles%\Microsoft\Exchange Server\V15\bin\ExSetup.exe found" ; 
        $smsg += "`nExchange has not been installed on $($env:COMPUTERNAME) yet!" ;
        if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
    } ; 
}else{
    $smsg = "`$InstalledSetupVersion: recvycling existing `$global:InstalledExSetupVersion " ;
    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ;
    $InstalledSetupVersion = $global:InstalledExSetupVersion  ;     
} ; 
<#
[version]$thisVersion = ([version](gi $InstalledSetup).VersionInfo.ProductVersion) ; 
if($thisVersion -ge [version]'15.2.2562.29'){ $isEXSE = $true ; $ExVers = 'EXSE' }
elseif($thisVersion -ge [version]'15.2.196.0'){ $isEX2019 = $true ; $ExVers = 'EX2019' } 
elseif($thisVersion -ge [version]'15.1.225.16'){ $isEX2016 = $true ; $ExVers = 'EX2016' } 
elseif($thisVersion -ge [version]'15.0.516.32'){ $isEX2013 = $true ; $ExVers = 'EX2013' } 
elseif($thisVersion -ge [version]'14.0.639.21'){ $isEX2010 = $true ; $ExVers = 'EX2010' } 
elseif($thisVersion -ge [version]'8.0.685.25'){ $isEX2007 = $true ; $ExVers = 'EX2007' } 
elseif($thisVersion -ge [version]'6.5.6944'){ $isEX2003 = $true ; $ExVers = 'EX2003' } 
elseif($thisVersion -ge [version]'6.0.4417'){ $isEX2000 = $true ; $ExVers = 'EX2000' } 
elseif($thisVersion -ge [version]'5.5.1960'){ $isEX55 = $true ; $ExVers = 'EX55' } 
elseif($thisVersion -ge [version]'5.0.1457'){ $isEX50 = $true ; $ExVers = 'EX50' } 
elseif($thisVersion -ge [version]'4.0.837'){ $isEX40_SE = $true ; $ExVers = 'EX40_SE' } 
else{ throw "Unrecognized Exchange Server Version: $($thisVersion)" } ; 
write-host "Resolved Exchange Exchange Server Version: $($thisVersion) => `$ExVers: $($ExVers) "  ; 
#>
#[version]$InstalledSetupVersion
#$global:InstalledExSetupVersion
<#switch($env:userdomain){
    'CMW'{$localSourceServer = 'CURLYHOWARD'} 
    'LARRYFINE'{$localSourceServer = $null} 
    'TORO'{$localSourceServer = 'LYNMS6400'} 
    'TORO-LAB'{$localSourceServer = 'LYNMS6400t'}     
    default{
        throw "unrecogized `$env:userdomain:$($env:userdomain)!"
        BREAK
    }
} ; 
#>
if($env:userdomain -match  'CMW|LARRYFINE'){
    $smsg = "CMW server/edge server detected: SKIPPING CAB MOUNT DISCOVERY!" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
}else{
                                                                                                                                                                if(-not $global:CabExSetup){
    # can't use internal functions until they're loaded, moving the version lookups below the function block    
    if(-not (get-variable CabDrives -ea 0)){$CabDrives = 'r','d','c' };
    $smsg = "Resolving latest local cab version, hunting across drives:$($CabDrives -join '|') (sorted on ProductVersion)" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;    
    # wildcard model to span versions & cu/su combos.
    $SourcePath = 'D:\cab\ExchangeServer*-x64-*-ISO\unpacked\Setup\ServerRoles\Common\ExSetup.EXE'  ; 
    $SourceLeaf = ($SourcePath.split('\') | select -skip 1 ) -join '\' ;     
    $swStep = [Diagnostics.Stopwatch]::StartNew();
    foreach($cabdrv in $CabDrives){
        if(-not (test-path -path  "$($cabdrv):" -ea 0)){Continue} ;         
        $testpath = (join-path -path "$($cabdrv):" -child $SourceLeaf) ;
        $CabExSetup = resolve-path $testpath | select -expand path |foreach-object{
            $thisfile = gci $_ ;
            $finfo = @{
                FullName = $thisfile.fullname;
                Name = $thisfile.Name ; 
                ProductVersion = [version]$thisfile.versioninfo.productversion ; 
                Length = $thisfile.length ; 
                LastWriteTime = $thisfile.LastWriteTime ; 
            } ;
            [pscustomobject]$finfo | write-output ;            
        } | sort productversion | select -last 1 ;
        if($CabExSetup){
            #[version]$CabExSetupMajorVersion = Resolve-xopMajorVersionTDO -version $CabExSetup.ProductVersion -Verbose:($VerbosePreference -eq 'Continue') ; 
            #[version]$global:CabExSetupMajorVersion = $CabExSetupMajorVersion ; 
            $smsg = "Taking first resolved `$CabExSetup:`n`n$(($CabExSetup|out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            $smsg = "Exporting `$CabExSetup as `$global:CabExSetup: $($CabExSetup) " ;
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $global:CabExSetup = $CabExSetup ; 
            Break ; 
        } ; 
    } ;
}else{
        $smsg = "`$CabExSetup: recycling existing `$global:CabExSetup " ;
        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        } ;
        $CabExSetup = $global:CabExSetup ;     
    }
} ; 
if($swStep){$swStep.Stop() ; $ts = $swStep.elapsed | select days,hours,minutes,seconds,milliseconds ;} ; 
[array]$fst=@() ;
$ts.psobject.properties |?{$_.value} |foreach-object{switch ($_.name){ 'Days'{$fst += "{0:dd}d"} 'Hours'{$fst += "{0:hh}h"} 'Minutes'{$fst += "{0:mm}m"} 'Seconds'{$fst += "{0:ss}s"} 'Milliseconds'{$fst += "{0:fff}ms"} default{} } ; } ;
$smsg =  ("(Elapsed: $($fst -join " "))" -f $swStep.Elapsed) ;
if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
} ;
if(-not $global:BuildInstallPath){
    if(-not $InstallPath){
        if($env:userdomain -match  'CMW|LARRYFINE' -and $FilePath){
            $InstallPath = $filePath ; 
            $smsg = "CMW server/edge server detectedf recycling specified Filepath as InstallPath:$($filepath)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        }else{
            $smsg = "Missing -InstallPath: Resolving (hunting across `$CabDrives: $($CabDrives -join '|')" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $swStep = [Diagnostics.Stopwatch]::StartNew();
            foreach($cabdrv in $CabDrives){
                if(-not (test-path -path  "$($cabdrv):" -ea 0)){Continue} ; 
                # recurse for dir (on attribute), excluding ISO unpacked tree, limit 3 levels
                $ipath = gci "$($cabdrv):\installcache" -Attributes D -exclude "\unpacked\" -Recurse -Depth 3 ; 
                if($ipath){
                    $InstallPath = $ipath.fullname ; 
                    $smsg = "Taking first resolved `$InstallPath:`n$($InstallPath)" ; 
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                    $smsg = "Exporting `$InstallPath as `$global:BuildInstallPath: $($InstallPath)" ;
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                    $global:BuildInstallPath = $InstallPath ; 
                    Break ; 
                } ; 
            }  ; 
        } ; 
    }
}else{
    $smsg = "`$InstallPath: recvycling existing `$global:BuildInstallPath " ;
    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ;
    $InstallPath = $global:BuildInstallPath ;     
} ; 
if($swStep){$swStep.Stop() ; $ts = $swStep.elapsed | select days,hours,minutes,seconds,milliseconds ;}
[array]$fst=@() ;
$ts.psobject.properties |?{$_.value} |foreach-object{switch ($_.name){ 'Days'{$fst += "{0:dd}d"} 'Hours'{$fst += "{0:hh}h"} 'Minutes'{$fst += "{0:mm}m"} 'Seconds'{$fst += "{0:ss}s"} 'Milliseconds'{$fst += "{0:fff}ms"} default{} } ; } ;
$smsg =  ("(Elapsed: $($fst -join " "))" -f $swStep.Elapsed) ;
if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
} ;
if(-not (test-path $InstallPath -PathType Container)){
    $smsg = "MISSING/UNDEFINED `$InstallPath!"
    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    break ; 
}
#endregion CALCULATED_CONSTANTS ; #*------^ END CALCULATED_CONSTANTS ^------

#region FUNCTIONS_DYNLOAD ; #*======v FUNCTIONS_DYNLOAD v======
$script:ModuleRoot = $PSScriptRoot ;
if($script:ModuleRoot){
    $script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ;
} else { 
    throw "UNABLE TO RESOLVE .PSM1:`$script:moduleroot!" ; 
} ; 
$runningInVsCode = $env:TERM_PROGRAM -eq 'vscode' ;

# Array of functions that aren't supported under PsV2 loads (dynamically dropped from load under that rev)
$Psv2PublicExcl = @() ;
$Psv2PrivateExcl = @() ;
#* v NEXT LINE IS DYN EDIT LANDMARK * DO NOT REMOVE * v
#Get public and private function definition files.

<# orig template dyn include content
$functionFolders = @('Public', 'Internal', 'Classes') ;
ForEach ($folder in $functionFolders) {
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder ;
    If (Test-Path -Path $folderPath) {
        Write-Verbose -Message "Importing from $folder" ;
        $functions = Get-ChildItem -Path $folderPath -Filter '*.ps1'  ;
        ForEach ($function in $functions) {
            Write-Verbose -Message "  Importing $($function.BaseName)" ;
            . $($function.FullName) ;
        } ;
    } ;
} ;
$publicFunctions = (Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1').BaseName ;
#>

# updated dynincl
if( $runningInVsCode){
    if($script:ModuleRoot){
        $inferredRoot = split-path $script:ModuleRoot ;
    } else {
        $smsg = "Unable to resolve module root location!"
        write-warning $smsg ;
        throw $smsg ;
        break ;
    }
}else {
    $inferredRoot = split-path $PsScriptRoot ;
} ;
if(test-path $inferredRoot){
    $Public = @( Get-ChildItem -Path $inferredRoot -Include 'Public', 'External' -Recurse -Directory -ErrorAction SilentlyContinue | Get-ChildItem -Include *.ps1 -File -ErrorAction SilentlyContinue | where-object {$_.Extension -eq '.ps1'} ) ;
    $Private = @( Get-ChildItem -Path $inferredRoot -Include 'Private', 'Internal' -Recurse -Directory -ErrorAction SilentlyContinue | Get-ChildItem -Include *.ps1 -File -ErrorAction SilentlyContinue | where-object {$_.Extension -eq '.ps1'} ) ;
    $Classes = @( Get-ChildItem -Path $inferredRoot -Include 'Classes' -Recurse -Directory -ErrorAction SilentlyContinue | Get-ChildItem -Include *.ps1 -File -ErrorAction SilentlyContinue | where-object {$_.Extension -eq '.ps1'} ) ;

    # Following creates conditional excludes of down-rev Psv2-incompatible functions (drop them from the lists on load)
    if( ($psversiontable.psversion.major -lt 3) -AND ($Psv2PublicExcl -OR $Psv2PrivateExcl) ){
        write-host "Powershell v2 detected: removing deprecated non-Psv2-compatible functions from module" ;
        $deprecated = $public |?{$Psv2PublicExcl -contains $_.name} ;
        $Public = $public |?{$Psv2PublicExcl -notcontains $_.name} ;
        write-verbose "(PUBLIC:skipping load of incompatible modules:$($deprecated))" ;
        $deprecated = $Private |?{$Psv2PrivateExcl -contains $_.name} ;
        write-verbose "(PRIVATE:skipping load of incompatible modules:$($deprecated))" ;
        $Private = $Private |?{$Psv2PrivateExcl -notcontains $_.name} ;
    } ;
    Foreach($import in @($Public + $Private + $Classes)) {
        Try {
          Write-Verbose -Message "  Importing $($import.fullname)" ;
          . $($import.fullname) ;
        } catch {
          $smsg = "Failed to import function $($import.fullname): $_" ;
          $smsg += "`n$($_.exception.message)" ;
          Write-Error -Message $smsg
        } ;
    }  # loop-E; ;
} else {
  throw "Unable to locate `$inferredRoot folder calculated for module .psm1!" ; 
} ;  
#endregion FUNCTIONS_DYNLOAD ; #*======^ END FUNCTIONS_DYNLOAD ^======
Export-ModuleMember -Function $Public.Basename -Alias * ;
#* ^ ABOVE LINE IS DYN EDIT LANDMARK * DO NOT REMOVE * ^


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfz5y08TOjA5jlq1Ork1jj9pk
# YImgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS8msDv
# kItTpQ1QMmehPvUuCTg41TANBgkqhkiG9w0BAQEFAASBgGYih1zh+OYjHu6WQIGe
# fa9PYnhWH3/hpOW6SjpEW8ttSxK3ytm9dEi5u9BVm6FTsymkh3/ZZmtcetMLDLNU
# bxEWANhTnczsQUfSQyPHEvoooe0ff/wR8w/wp7dM1Yo2ML/UaejjmFIO4rD1OGp6
# 4c9UEUxiE/cIDM9xRPXzo3b7
# SIG # End signature block
