#region TEST_XOP15LOCALINSTALLDRIVESTDO ; #*------v FUNCTION test-xop15LocalInstallDrivesTDO v------
function test-xop15LocalInstallDrivesTDO {
        <#
        .SYNOPSIS
        test-xop15LocalInstallDrivesTDO - Test drive config for Exchange15(Ex2016,19,SE) suitability - drivespace; issues;role requirements - and resolve and return Exchange15-specific install drives
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-07-17
        FileName    : test-xop15LocalInstallDrivesTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-XXX
        Tags        : Powershell
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 5:02 PM 7/31/2025 rewrote simplfied, returns an array now. 
        * 11:10 AM 7/30/2025 blank $rgxFileSystemLabels (process all, get A & CDR) ; revise, ren: test-LocalInstallDrivesTDO -> test-xop15LocalInstallDrivesTDO; added Alias 'test-xop15LocalInstallDrivesTDO' and orig name
        .DESCRIPTION
        test-xop15LocalInstallDrivesTDO - Test drive config for Exchange15(Ex2016,19,SE) suitability - drivespace; issues;role requirements - and resolve and return Exchange15-specific install drives

        Returns a system.object that contains the following:

        Drives  : An array of Drive evaluation summaries, in following format:

            DriveRole           : {System} # array of values, 'System', 'Queue' & 'Pagefile' may return multiple role matches: 
                    Variant values: System|DB|CDMount|FloppyMount|Queue|Binary|Recovery
            FileSystemLabel     : System
            DriveLetter         : C
            FileSystem          : NTFS
            DriveType           : Fixed
            FileSystemStatus    : True  # evaluates FileSystem against desired format for DriveRole
            HealthStatus        : Healthy
            OperationalStatus   : OK
            SizeRemaining       : 54331154432
            SizeRemainingStatus : True  # evaluates SizeRemaining against desired freespace or freespace percentage for DriveRole
            Size                : 85372956672
            DriveIssues         :     # aggregates any issues found: space issues, HealthSTatus, OperationalStatus. These in turn are agegated into the overall 'DriveHealthIssues' property returned.
            PSDrive             : C   # this represents the entire PSDrive object (populated when a drive letter is assigned in the OS, to permit PSDrive lookup resolution)
            DriveOK             : True # Evaluates $True if no DriveIssues.

        DriveHealthIssues: aggregates any DriveIssues from individual Drive results
        ValidAll: An overall status flag ($true, if no DriveHealthIssues).

        .PARAMETER
        rgxFileSystemLabels
        Regex filter of Filesystem Drive Labels to be targeted for space analysis[-Credentials [-rgxFileSystemLabels '^(QUEUE|RECOVERY|System|MAILBOX1|BINARIES|PageQueue|TRANSPORT)$']
        .PARAMETER
        rgxDriveTypes
        Regex filter of Filesystem DriveTypes to be targeted for targeted analysis[-rgxDriveTypes '^(Fixed|CD-ROM)$']
        .INPUTS
        None. Does not accepted piped input.
        .OUTPUTS
        System.Object[]
        .EXAMPLE
        PS> $drivesResult = test-xop15LocalInstallDrivesTDO ; 
        PS> if(if($drivesResult.ValidAll){write-host -foregroundcolor green "Local Drives Pass tests"
        PS> }else{
        PS>     throw "drivesResult.ValidAll:FALSE!`n`$drivesResult.DriveHealthIssues!`n$(($drivesResult.DriveHealthIssues|out-string).trim())" ; 
        PS> }
        PS> $drivesResult | fl DriveHealthIssues, ValidAll

            DriveHealthIssues : 
            ValidAll          : True
        
        PS> write-verbose "Output the drives summary table"
        PS> $drivesResult.drives | ft -a 

            DriveRole     FileSystemLabel DriveLetter FileSystem DriveType FileSystemStatus HealthStatus OperationalStatus SizeRemaining SizeRemainingStatus
            ---------     --------------- ----------- ---------- --------- ---------------- ------------ ----------------- ------------- -------------------
            {System}      System                    C NTFS       Fixed                 True Healthy      OK                  54331154432                True
            {DB}          MAILBOX1                  M ReFS       Fixed                 True Healthy      OK                 533421555712                True
            {CDMount}                               E            CD-ROM                     Healthy      Unknown                       0                    
            {FloppyMount}                           A            Removable                  Healthy      Unknown                       0                    
            {Queue}       QUEUE                     Q NTFS       Fixed                 True Healthy      OK                   1022849024                True
            {Binary}      BINARIES                  D NTFS       Fixed                 True Healthy      OK                  12112310272                True
            {Recovery}    RECOVERY                  R NTFS       Fixed                 True Healthy      OK                  92773736448                True

        PS> write-verbose "Return the CD and Floppy Drive DriveLetters from the returned Drives property (post-filtered by DriveRole)
        PS> $drivesResult.drives | ?{$_.driverole -match 'CDMount|FloppyMount'} | ft -a DriveLetter,DriveRole ; 

            DriveLetter DriveRole    
            ----------- ---------    
                      E {CDMount}    
                      A {FloppyMount}

        PS> write-verbose "Assign variables for System, DB & Binary driveletters from the returned Drives property (post-filtered by DriveRole)
        PS> $SysDrv = $drivesResult.drives | ?{$_.driverole -match 'System'} | select -expand DriveLetter ;
        PS> $BinDrv = $drivesResult.drives | ?{$_.driverole -match 'Binary'} | select -expand DriveLetter ;
        PS> $DBDrv = $drivesResult.drives | ?{$_.driverole -match 'DB'} | select -expand DriveLetter ; ;

        Demo test for Exchange15 installation of all local drives on the system, and return various relevent information on the drives.
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [CmdletBinding()]
        [Alias('resolve-LocalInstallDrivesTDO','test-LocalInstallDrivesTDO')]
        PARAM(
            [Parameter(Mandatory = $false, HelpMessage = "Regex filter of Filesystem Drive Labels to be targeted for space analysis[-Credentials [-rgxFileSystemLabels '^(QUEUE|RECOVERY|System|MAILBOX1|BINARIES|PageQueue|TRANSPORT)$']")]
                [regex]$rgxFileSystemLabels,
            [Parameter(Mandatory = $false, HelpMessage = "Regex filter of Filesystem DriveTypes to be targeted for targeted analysis[-rgxDriveTypes '^(Fixed|CD-ROM)$']")]
                [regex]$rgxDriveTypes = '^(Fixed|CD-ROM|Removable)$'
        )
        BEGIN{
            #region COMMON_CONSTANTS ; #*------v COMMON_CONSTANTS v------
            #region WHPASSFAIL ; #*------v WHPASSFAIL v------
            $whTPad = 72  ; $whTChar = '.' ; # scale $whTPad to longest Testing:xxx line you use in the test array
            #if(-not $whPASS){
            $whPASS = @{ Object = "$([Char]8730) PASS`n" ; ForegroundColor = 'Green' ; NoNewLine = $true  } 
            #}
            #if(-not $whFAIL){
            $whFAIL = @{'Object'= if ($env:WT_SESSION) { "$([Char]8730) FAIL`n"} else {" !X! FAIL`n"}; ForegroundColor = 'RED' ; NoNewLine = $true } 
            #} ;
            # light diagonal cross: ╳ U+2573 DOESN'T RENDER IN PS, use it if WinTerm
            if(-not $psPASS){$psPASS = "$([Char]8730) PASS`n" } # $smsg = $pspass + " :Tested Drives" ; write-host $smsg ;
            if(-not $psFAIL){$psFAIL = if ($env:WT_SESSION) { "$([Char]8730) FAIL`n"} else {" !X! FAIL`n"} } ; # $smsg = $psfail + " :Tested Drives" ; write-warning $smsg ;
            #endregion WHPASSFAIL ; #*------^ END WHPASSFAIL ^------
            #endregion COMMON_CONSTANTS ; #*------^ END COMMON_CONSTANTS ^------
            #region LOCAL_CONSTANTS ; #*------v LOCAL_CONSTANTS v------
            if(-not $SysDriveFreeFloor){$SysDriveFreeFloor = 10 * 1GB };
            if(-not $binDriveFreeFloor){$binDriveFreeFloor = 8 * 1GB *1.2 }; # 8GB + 20% free space floor for bin drive
            if(-not $dbDriveFreeFloorPercent){$dbDriveFreeFloorPercent = .9} ; # 90% free space floor for DB drive
            if(-not $QUEUEDriveFreeFloor){$QUEUEDriveFreeFloor = 8 * 1MB }; # 800MB free space floor for queue drive
            if(-not $RecoverDriveFreeFloor){$RecoverDriveFreeFloor = 25 * 1GB *1.2 }; # 20GB + 20% free space floor for bin Recover
            if(-not $PageFileFormat){$PageFileFormat ='NTFS'} ; # pagefile hosting needs to be NTFS
            #endregion LOCAL_CONSTANTS ; #*------^ END LOCAL_CONSTANTS ^------
            # export report
            $driveSummary = [ordered]@{
                Drives = @() ;
                DriveHealthIssues = $null ;
                ValidAll = $false ;
            } ;            
        };  # BEG-E
        PROCESS{            
            $smsg = "test-xop15LocalInstallDrivesTDO:Resolve local destination install paths, validate FileSysFormat & Freespace & populate testable objects" ;
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;

            #if ($tVols = get-volume | ? { $_.drivetype -eq 'Fixed' } | ? { $_.FileSystemLabel -match $rgxFileSystemLabels }) {
            #if ($tVols = get-volume | ? { $_.drivetype -eq 'Fixed' }){
            # include non-fixed, to capture cdrom & floppy into report
            if ($tVols = get-volume ){
                if($rgxFileSystemLabels){
                    $tvols = $tVols | ? { $_.FileSystemLabel -match $rgxFileSystemLabels }
                } ;
                if($rgxDriveTypes){
                    $tvols = $tVols | ? { $_.DriveType -match $rgxDriveTypes }
                } ;
                if($BadDrives = $tVols | ?{$_.DriveType  -eq 'Fixed' -AND ($_.HealthStatus -ne 'Healthy' -OR $_.OperationalStatus -ne 'OK')}){
                    $BadDrives | foreach-object{                        
                        $smsg = "Testing: Volume.HealthStatus: $($_.DriveLetter):$($_.FileSystemLabel):" ; 
                        $smsg += " $($whTChar * ($whTPad - $smsg.length))" ; Write-Host "$($smsg) " -NoNewline ;
                        if($_.HealthStatus -ne 'Healthy'){
                            write-host @whFAIL ;
                            $smsg = "drive HealthStatus: $($_.DriveLetter): $($_.HealthStatus)!" ;
                            $driveSummary.DriveHealthIssues += @($smsg)
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        }else{Write-Host @whPASS} ;
                        $smsg = "Testing: Volume.OperationalStatus: $($_.DriveLetter):$($_.FileSystemLabel):" ; 
                        $smsg += " $($whTChar * ($whTPad - $smsg.length))" ; Write-Host "$($smsg) " -NoNewline ;
                        if($_.OperationalStatus -ne 'OK'){
                            write-host @whFAIL ;
                            $smsg = "SysVol drive OperationalStatus: $($_.DriveLetter): $($_.OperationalStatus)!" ;
                            $driveSummary.DriveHealthIssues += @($smsg)
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        }else{Write-Host @whPASS} ;
                    } ;
                }
                # 11:03 AM 7/23/2025 post drive resize the Binary drive came up OperationalStatus:'Full Repair Needed'
                if($BadDrives = $tvols | ?{$_.OperationalStatus -eq 'Full Repair Needed'}){
                    foreach($bd in $BadDrives){
                        $result = Repair-VolumeTDO -DriveLetter $bd.driveletter
                        if($result -eq 0){
                            $smsg = "CLEAR RESULT:Repair-VolumeTDO -DriveLetter $($bd.driveletter)" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 }
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        }else {
                            $smsg = "*NON* CLEAR RESULT:Repair-VolumeTDO -DriveLetter $($bd.driveletter)" ;
                            $smsg += "`N(BEARS FURTHER RESEARCH AND REMEDIATION!)" ;
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        } ;
                    } ;
                } ;
                foreach ($tv in $tVols) {
                    $smsg = "Checking Drive:$($tv.driveletter): ($($tv.filesystemlabel))" ;
                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                    } ;
                    $rptDrive = [ordered]@{
                        DriveRole = $null ; # sys,
                        FileSystemLabel = $tv.FileSystemLabel ;
                        DriveLetter = $tv.DriveLetter ;
                        FileSystem = $tv.FileSystem ; # NTFS
                        DriveType = $tv.DriveType
                        FileSystemStatus = $null ;
                        HealthStatus= $tv.HealthStatus ;
                        OperationalStatus= $tv.OperationalStatus
                        SizeRemaining = $tv.SizeRemaining ;
                        SizeRemainingStatus = $null ;
                        Size = $tv.Size ;
                        DriveIssues = $null ;
                        PSDrive = if($tv.DriveLetter){get-psdrive -Name $tv.driveletter -PSProvider 'FileSystem' -ea STOP | write-output } ;
                        DriveOK = $false ;
                    } ;
                    if($tv.Filesystemlabel -eq 'MAILBOX1'){
                        #write-verbose 'GOTCHA!' ;
                    } ;
                    $tFormat = $null ;
                    $tSpaceThresh = $null ;
                    switch -regex ($tv.FileSystemLabel) {
                        '^System$' {
                            $rptDrive.DriveRole += @('System') ;
                            $tFormat ='NTFS' ;
                            $tSpaceThresh = $sysDriveFreeFloor ;

                        } ; 
                        '^BINARIES$' {
                            $rptDrive.DriveRole += @('Binary') ;
                            $tFormat ='NTFS' ;
                            $tSpaceThresh = $binDriveFreeFloor ;
                                                    } ;  # BIN-E
                        '^MAILBOX((\d)*)$'{
                            $rptDrive.DriveRole += @('DB') ;
                            $tFormat = 'ReFS' ;
                            $tSpaceThresh = $dbDriveFreeFloorPercent ;

                        } ; 
                        '^(QUEUE|PageQueue)$' {
                            $tFormat = 'NTFS' ;
                            $tSpaceThresh = $QUEUEDriveFreeFloor ;
                            switch -regex ($tv.FileSystemLabel){
                                '^QUEUE$'{
                                    if($driveSummary.Drives.DriveRole -notcontains 'Queue'){
                                        $rptDrive.DriveRole += @('Queue') ;
                                        $smsg = "Detected $($tv.DriveLetter) is QUEUE drive" ;
                                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                        } ;

                                    } else {
                                        $smsg = "CONFLICTING PRE-EXISTING LABEL:$($tv.FileSystemLabel) driverole!" ;
                                        $rptDrive.DriveIssues += @($smsg)
                                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                        } ;
                                    } ;

                                }  # Queue-E
                                '^PageQueue$'{
                                    $smsg = "Detected $($tv.DriveLetter) is QUEUE drive" ;
                                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                    } ;
                                    if (gci -path "$($tv.DriveLetter):\" -hidden | ? { $_.fullname -match 'pagefile\.sys' }) {
                                        $rptDrive.DriveRole += @('PageFile') ;
                                        $smsg = "Detected $($tv.DriveLetter) is PageFile.sys drive" ;
                                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                        } ;
                                    } ;
                                    
                                    if($driveSummary.Drives.DriveRole -notcontains 'Queue'){
                                        $smsg = "Detected $($tv.DriveLetter) is QUEUE drive" ;
                                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                        } ;
                                    } else {
                                        $smsg = "CONFLICTING PRE-EXISTING LABEL:$($tv.FileSystemLabel) driverole!" ;
                                        $rptDrive.DriveIssues += @($smsg)
                                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                        } ;
                                    } ;
                                }  # PageQueue-E
                            }   # swtch-E
                        } # queue|pagequeue-E
                        '^TRANSPORT$' {
                            $rptDrive.DriveRole += @('Queue') ;
                            $tFormat = 'NTFS' ;
                            $tSpaceThresh = $QUEUEDriveFreeFloor ;
                        }
                        '^RECOVERY$' {
                            $rptDrive.DriveRole += @('Recovery') ;
                            $tFormat = 'NTFS' ;
                            $tSpaceThresh = $RecoverDriveFreeFloor ;

                        }
                        '^System Reserved$' {
                            $smsg = "Skip: $($tv.driveletter) label:$($tv.FileSystemLabel)" ;
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                        }
                        default {
                            switch($tv.DriveType){
                                'Removable'{
                                    if($tv.DriveLetter -eq 'A'){
                                        $rptDrive.DriveRole += @('FloppyMount') ;
                                        $smsg = "FloppyMount: $($tv.driveletter) label:$($tv.FileSystemLabel)" ;
                                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                        } ;
                                    } ;
                                }
                                'CD-ROM'{
                                    $rptDrive.DriveRole += @('CDMount') ;
                                    $smsg = "CDMount: $($tv.driveletter) label:$($tv.FileSystemLabel)" ;
                                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                    } ;
                                }
                                default {
                                    $smsg = "Skip unconfigured DriveType: $($tv.DriveType) label:$($tv.FileSystemLabel)" ;
                                    if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                        if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                                    } ;
                                } ;
                            };  # swtch-E
                        } ;  # def-E
                    } # swtch-E

                    #$tFormat = 'NTFS' ;
                    #$tSpaceThresh = $$RecoverDriveFreeFloor ;
                   
                    if($tFormat){
                        $smsg = "Testing: Volume.FileSystem against: $($tFormat)" ;          
                        $smsg += " $($whTChar * ($whTPad - $smsg.length))" ; Write-Host "$($smsg) " -NoNewline ;               
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                        if ($tv.FileSystem -eq $tFormat) {
                            $rptDrive.FileSystemStatus = $true ;
                            Write-Host @whPASS ;
                            $smsg = "$($tFormat) file system detected on $($rptDrive.DriveRole -join ',') drive: $($tv.DriveLetter): $($tv.FileSystemLabel)" ;
                            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                            } ;
                        } else {
                            $rptDrive.FileSystemStatus = $true ;
                            write-host @whFAIL ;
                            $smsg = "$($tFormat) file system NOT detected on $($rptDrive.DriveRole -join ',') drive: $($tv.DriveLetter): $($tv.FileSystemLabel) - MUST BE CONVERTED TO $($tFormat)!" ;
                            $rptDrive.DriveIssues += @($smsg)
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        };
                    } ; 
                    if($tSpaceThresh){
                        if($tSpaceThresh -gt 1000){
                            $smsg = "Testing: Volume.SizeRemainingStatus against: $(RndTo3($tSpaceThresh/1GB))GB" ; 
                        }elseif($tSpaceThresh -lt 1){
                            $smsg = "Testing: Volume.SizeRemainingStatus against: $(RndTo3($tSpaceThresh * 100))%" ; 
                        }else {
                            $smsg = "Testing: Volume.SizeRemainingStatus against: $($tSpaceThresh)" ; 
                        } ; 
                        $smsg += " $($whTChar * ($whTPad - $smsg.length))" ; Write-Host "$($smsg) " -NoNewline ;
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                        if($tSpaceThresh -lt 1){
                            $smsg = "Detected $($tSpaceThresh) is a percentage free test" ;
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                            if ($tv.SizeRemaining / $tv.Size -lt $tSpaceThresh) {
                                $rptDrive.SizeRemainingStatus = $false ; 
                                write-host @whFAIL ;
                                $smsg = "Insufficient free space on $($rptDrive.DriveRole -join ',') drive: $($tv.DriveLetter): $(RndTo2($tv.SizeRemaining/1GB)) GB, needs at least $($tv.Size/1GB * $tSpaceThresh) GB" ;
                                $rptDrive.DriveIssues += @($smsg)
                                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                            } else {
                                $rptDrive.SizeRemainingStatus = $true ; 
                                Write-Host @whPASS ;   ;
                                $smsg = "DB drive: $($tv.DriveLetter): $(RndTo2($tv.SizeRemaining/1GB)) GB free, sufficient for install" ;
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                            } ;
                        }else{
                            $smsg = "Detected $($tSpaceThresh) is a free space floor test" ;
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                            if ($tv.SizeRemaining -lt $tSpaceThresh){
                                $rptDrive.SizeRemainingStatus = $false ;
                                write-host @whFAIL ;
                                $smsg = "Insufficient free space on $($rptDrive.DriveRole -join ',') drive: $(RndTo2($tv.SizeRemaining/1GB)) GB, needs at least $(RndTo2($tSpaceThresh/1GB)) GB" ;
                                $rptDrive.DriveIssues += @($smsg)
                                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                            } else {
                                $rptDrive.SizeRemainingStatus = $true ;
                                Write-Host @whPASS ;   ;
                                $smsg = "$($rptDrive.DriveRole -join ','): $(RndTo2($tv.SizeRemaining/1GB)) GB free, sufficient for install" ;
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                            } ;
                        } ; 
                    } ; 
                    # test for pagefile:
                    if($tv.DriveLetter){
                        if (gci -path "$($tv.DriveLetter):\" -hidden -ErrorAction SilentlyContinue | ? { $_.fullname -match 'pagefile\.sys' }) {
                            $rptDrive.DriveRole += @('PageFile') ;
                            $smsg = "Detected $($tv.DriveLetter) is a PageFile.sys drive" ;
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                            #$PageFileFormat
                            $smsg = "Testing: Volume.FileSystem against: $($PageFileFormat)" ; 
                            $smsg += " $($whTChar * ($whTPad - $smsg.length))" ; Write-Host "$($smsg) " -NoNewline ;
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                            if ($tv.FileSystem -eq $PageFileFormat) {
                                $rptDrive.FileSystemStatus = $true ;
                                Write-Host @whPASS ;
                                $smsg = "$($PageFileFormat) file system detected on $($rptDrive.DriveRole -join ',') Role pagefile-hosting drive: $($tv.DriveLetter): $($tv.FileSystemLabel)" ;
                                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                                } ;
                            } else {
                                $rptDrive.FileSystemStatus = $true ;
                                write-host @whFAIL ;
                                $smsg = "$($PageFileFormat) file system NOT detected on $($rptDrive.DriveRole -join ',')  pagefile-hosting drive: $($tv.DriveLetter): $($tv.FileSystemLabel) - MUST BE CONVERTED TO $($PageFileFormat)!" ;
                                $rptDrive.DriveIssues += @($smsg)
                                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                            };
                        } ;
                    } ; 
                    if($rptDrive.DriveIssues){
                        $rptDrive.DriveOK = $false ;
                    } else{
                        $rptDrive.DriveOK = $true ;
                    } ;
                    if($rptDrive.DriveRole){
                        $driveSummary.Drives += @([pscustomobject]$rptDrive) ;
                    } else {
                        $smsg = "Skip Add DriveAggr (no DriveRoles):$($tv.DriveType) label:$($tv.FileSystemLabel)" ;
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                    } ;
                    if($rptDrive.DriveIssues){
                        $driveSummary.DriveHealthIssues += @($rptDrive.DriveIssues) ;
                    } ;
                } ;  # loop-E
            } else{
                $smsg = "UNABLE TO GET-VOLUME: ANY VOLUMES!" ;
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            } ;
        } ;  # PROC-E
        END {
            if($driveSummary.DriveHealthIssues){
                $driveSummary.ValidAll = $false ;
                $smsg = "ValidAll: All Drives Pass testing" ;
                $smsg += "`nFollowing DriveHealthIssues returned:`n$(($driveSummary.DriveHealthIssues|out-string).trim())" ; 
                if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            }else{
                $driveSummary.ValidAll = $true ;
                $smsg = "ValidAll: All Drives Pass testing" ;
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ; 
            }
            if($VerbosePreference -eq 'Continue'){
                $smsg = "Returning:`nDriveSummary.Drives:`n$(($driveSummary.Drives|sort DriveLetter | ft -a | out-string).trim())" ; 
                $smsg += "`n`nDriveSummary.DriveHealthIssues:`n$(($DriveSummary.DriveHealthIssues | out-string).trim())" ; 
                $smsg += "`nDriveSummary.ValidAll:$($DriveSummary.ValidAll)`n" ;
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE }
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ; 
            }            
            [pscustomobject]$driveSummary | write-output ;
        }
    }
#endregion TEST_XOP15LOCALINSTALLDRIVESTDO ; #*------^ END FUNCTION test-xop15LocalInstallDrivesTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUe+/zBm1C6FGe7knvsUx1GNli
# P2mgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTsfoE4
# kzgzI2Tj8dbesCpdrhjHFTANBgkqhkiG9w0BAQEFAASBgIdiUL+m4+5j/IxQ2AEv
# hXCUilsvu8ZpAX2GNPWgRBwO4Dz7bIYh8w/2A3G8EDdOE2JaJzREvGvn73iyr0SH
# DnXR76ZUb+6t9UA7l0x4Y9B+A8PXWTSQ+fP41lyXm8uEvshHVffe+k9Y+avccBWr
# lVx3IEYncZAdqpNt3D8MREhY
# SIG # End signature block
