#region TEST_PENDINGREBOOTTDO ; #*------v FUNCTION Test-PendingRebootTDO v------
function Test-PendingRebootTDO{    
        <#
        .SYNOPSIS
        Test-PendingRebootTDO - Check specified Server(s) registry for telltale PendingReboot registry keys. Returns a hashtable with IsPendingREboot and ComputerName for each machine checked. Requires localadmin permissions.
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-
        FileName    : Test-PendingRebootTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,System,Reboot
        AddedCredit : Adam Bertram
        AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
        AddedTwitter:	@adambertram
        REVISIONS
        * 3:30 PM 2/17/2026 fixed error: Test-RebootPending : Property UpdateExeVolatile does not exist at path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Updates ; add missing base alias
        * 1:56 PM 9/18/2025 add verbose echo of regkey that tagged a reboot; ren Test-PendingReboot -> Test-PendingRebootTDO; alias orig name; add region tags
          cbh: updated cited output to pscustomobject.
        * 9:38 AM 12/26/2024 tab-indent & caps'd the param blocks, flipped $Computername to nonmando wo notnullorempty, defaulted to $env:computername; added coerced -local when $computername -eq $env:computername, now runs on mybox, failed trying to do unconfig'd remoteps prev
        * 12:19 PM 6/24/2024 new box, pre WinRM remote config, fails hard; so cut in quick & dirty workaroun: -Local param, steers through the tests wo the PSSesssion working
        * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
        * 9:52 AM 2/11/2021 pulled spurios trailing fire of the cmd below func, updated CBH
        * 5:03 PM 1/14/2021 init, minor CBH mods
        * 7/29/19 AB's posted version
        .DESCRIPTION
        Test-PendingRebootTDO - Check specified Server(s) registry for telltale PendingReboot registry keys. Returns a hashtable with IsPendingREboot and ComputerName for each machine checked. Requires localadmin permissions.
        .PARAMETER  ComputerName
        Array of computernames to be tested for pending reboot
        .PARAMETER  Credential
        windows Credential [-credential (get-credential)]
        .PARAMETER Local
        Switch to skip remote PSSession connection, run local machine tests only (which will fail on new build unconfigured WinRM)[-Local]
        .PARAMETER IgnoreFileRename
        Switch to skip  tests of *PendingFileRenameOperations* (which don't reflect system pending updates, just locked file removal/replacement)[-ignorefilerename]
        .OUTPUT
        System.Management.Automation.PSCustomObject
        .EXAMPLE
        if((Test-PendingRebootTDO -ComputerName $env:Computername).IsPendingReboot){write-warning "$env:computername is PENDING REBOOT!"} ;
        Test for pending reboot remotely
        .EXAMPLE
        PS> if((Test-PendingRebootTDO -ComputerName $env:Computername -Local -IgnoreFileRename).IsPendingReboot){
        PS>     $smsg = "$env:computername is PENDING REBOOT!" ; 
        PS>     $smsg += "`nreboot and relaunch..." ; 
        PS>     if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } 
        PS>     else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        PS>     break ; 
        PS> } ;
        Local only test with demo'd echo, and -IgnoreFileRename specified.
        .LINK
        https://adamtheautomator.com/pending-reboot-registry-windows/
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [CmdletBinding()]
        [Alias('Test-PendingReboot','Test-RebootPending')]
        PARAM(
            [Parameter(Mandatory=$false,HelpMessage="Array of computernames to be tested for pending reboot")]
                [ValidateNotNullOrEmpty()]
                [string[]]$ComputerName= $env:computername,
            [Parameter(HelpMessage="windows Credential [-credential (get-credential)]")]
                [ValidateNotNullOrEmpty()]
                [pscredential]$Credential,
            [Parameter(HelpMessage="Switch to skip remote PSSession connection (which will fail on new build unconfigured WinRM)[-Local]")]
                [switch]$Local,
            [Parameter(HelpMessage="Switch to skip  tests of *PendingFileRenameOperations*[-ignorefilerename]")]
                [switch]$IgnoreFileRename
        ) ;
        $ErrorActionPreference = 'Stop'

        <# try to pull in local modules into the scriptblock (rather than expliciting a copy in the block) - didn't work, module load threw
        Error Message: A Using variable cannot be retrieved. A Using variable can be used only with Invoke-Command, Start-Job, or InlineScript in the script workflow. When it is used with Invoke-Command, the Using variable is valid only if the script block is invoked on a remote computer
        #>
        $scriptBlock = {

            $VerbosePreference = $using:VerbosePreference

            function Test-RegistryKey {
                [OutputType('bool')]
                [CmdletBinding()]
                PARAM(
                    [Parameter(Mandatory=$true)]
                        [ValidateNotNullOrEmpty()]
                        [string]$Key
                )
                $ErrorActionPreference = 'Stop'
                if (Get-Item -Path $Key -ErrorAction Ignore) {
                    $true
                }
            }
            function Test-RegistryValue {
                [OutputType('bool')]
                [CmdletBinding()]
                PARAM(
                    [Parameter(Mandatory=$true)]
                        [ValidateNotNullOrEmpty()]
                        [string]$Key,
                    [Parameter(Mandatory=$true)]
                        [ValidateNotNullOrEmpty()]
                        [string]$Value
                )
                $ErrorActionPreference = 'Stop'
                if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
                    $true
                }
            }
            function Test-RegistryValueNotNull {
                [OutputType('bool')]
                [CmdletBinding()]
                PARAM(
                    [Parameter(Mandatory=$true)]
                        [ValidateNotNullOrEmpty()]
                        [string]$Key,
                    [Parameter(Mandatory=$true)]
                        [ValidateNotNullOrEmpty()]
                        [string]$Value
                )
                $ErrorActionPreference = 'Stop'
                if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
                    $true
                }
            }

            # Added "test-path" to each test that did not leverage a custom function from above since
            # an exception is thrown when Get-ItemProperty or Get-ChildItem are passed a nonexistant key path
            # $tests is an array of scriptblocks, to be executed in a stack
            $tests = @(
                { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
                { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
                { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
                { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
                { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting' }
                { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations' }
                { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2' }
                {
                    # Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
                    #'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { test-path $_ -PathType Container } | ForEach-Object {
                    #    (Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0
                    #}
                    # Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
                    'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { test-path $_ -PathType Container } | ForEach-Object {
                        #(Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0
                        # 3:24 PM 2/17/2026 still throws Test-RebootPending : Property UpdateExeVolatile does not exist at path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Updates
                        if(Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' -ea 0){
                            (Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0
                        } ; 
                    }
                }
                { Test-RegistryValue -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Value 'DVDRebootSignal' }
                { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps' }
                { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
                { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
                {
                    # Added test to check first if keys exists, if not each group will return $Null
                    # May need to evaluate what it means if one or both of these keys do not exist
                    ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { test-path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } ) -ne
                    ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } )
                }
                {
                    # Added test to check first if key exists
                    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending' | Where-Object {
                        (Test-Path $_) -and (Get-ChildItem -Path $_) } | ForEach-Object { $true }
                }
            ) ; # scriptblock-E
            # cycle the list and break on first match
            foreach ($test in $tests) {
                Write-Verbose "Running scriptblock: [$($test.ToString())]"
                if (& $test) {
                    $true
                    break
                }
            }
        } # scriptblock-E

        foreach ($computer in $ComputerName) {
            try {
                $connParams = @{'ComputerName' = $computer} ;
                if ($PSBoundParameters.ContainsKey('Credential')) {
                    $connParams.Credential = $Credential ;
                } ;
                $output = @{
                    ComputerName    = $computer ;
                    IsPendingReboot = $false ;
                } ;
                # test & force local - fails on mybox
                if(-not $Local -AND ($computer -eq $env:COMPUTERNAME)){
                    write-verbose "coercing local run -Local:$true" ; 
                    $local = $true ; 
                } ; 
                if($Local){
                    #if (-not ($output.IsPendingReboot = Invoke-Command -ScriptBlock $scriptBlock)) {
                    #    $output.IsPendingReboot = $false ;
                    #} ;
                    $tests = @(
                        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
                        { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
                        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
                        { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
                        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting' }
                        { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations' }
                        { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2' }
                        {
                            # Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
                            'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { test-path $_ -PathType Container } | ForEach-Object {
                                #(Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0
                                # 3:24 PM 2/17/2026 still throws Test-RebootPending : Property UpdateExeVolatile does not exist at path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Updates
                                if(Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' -ea 0){
                                    (Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0
                                } ; 
                            }
                        }
                        { Test-RegistryValue -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Value 'DVDRebootSignal' }
                        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps' }
                        { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
                        { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
                        {
                            # Added test to check first if keys exists, if not each group will return $Null
                            # May need to evaluate what it means if one or both of these keys do not exist
                            ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { test-path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } ) -ne
                            ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } )
                        }
                        {
                            # Added test to check first if key exists
                            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending' | Where-Object {
                                (Test-Path $_) -and (Get-ChildItem -Path $_) } | ForEach-Object { $true }
                        }
                    ) ; # scriptblock-E
                    # cycle the list and break on first match
                    foreach ($test in $tests) {
                        # $tests | ?{$_ -like '*PendingFileRenameOperations*'}
                        if($IgnoreFileRename -and ($test -like '*PendingFileRenameOperations*')){
                            write-verbose "-IgnoreFileRename: skipping PendingFileRenameOperations" ; 
                        } else { 
                            Write-Verbose "Running scriptblock: [$($test.ToString())]"
                            if (& $test) {
                                $output.IsPendingReboot = $true ;
                                Write-Verbose "REBOOT TAGGED: [$($test.ToString())]`n(break on first match)"
                                break
                            }
                        } ; 
                    }
                } else { 
                    $psRemotingSession = New-PSSession @connParams ;
                    if (-not ($output.IsPendingReboot = Invoke-Command -Session $psRemotingSession -ScriptBlock $scriptBlock)) {                
                        $output.IsPendingReboot = $false ;
                    } ;
                } ; 
                [pscustomobject]$output | write-output ;
            } catch {
                Write-Error -Message $_.Exception.Message
            } finally {
                if (Get-Variable -Name 'psRemotingSession' -ErrorAction Ignore) {
                    $psRemotingSession | Remove-PSSession
                }
            } # TRY-E
        } ;
    }
#endregion TEST_PENDINGREBOOTTDO ; #*------^ END FUNCTION Test-PendingRebootTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSDvpdFKEltvih8178i7a99dE
# DwagggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSv5RSX
# 5/oqy2Td3CGsUxhGpMiX2jANBgkqhkiG9w0BAQEFAASBgDuKM0eoWdsZoAKEbKa6
# gX6hkOaz0lqu+gmhM56Z0Z8BIc+UH4WO9UutfE49b2uukW48/9uyFcSmddCNvN0d
# 39ypTbHhvv9EJFXerryvm85OA5WBRz9TSuujRfdbyRCMjoOA5tLeQSPWNhW21Av4
# eib6t+FQDiyVp9GakNvOQ2/Z
# SIG # End signature block
