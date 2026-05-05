#region RESTORE_EXCHANGE15STATETDO ; #*------v FUNCTION Restore-Exchange15StateTDO v------
Function Restore-Exchange15StateTDO {
        <#
        .SYNOPSIS
        Restore-Exchange15StateTDO - Reads StateFile .xml into hashtable for assignment into `$State variable, for use with/emulating install-Exchange15-TTC.ps1
        .NOTES
        Version     : 0.0.1
        Author      : Michel de Rooij, michel@eightwone.com
        Website     : http://eightwone.com
        Twitter     : 
        CreatedDate : 20250929-1026AM
        FileName    : Restore-Exchange15StateTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.org/tostka/powershellBB/
        Tags        : ExchangeServer,Version,Install,Maintenance
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 2:39 PM 10/8/2025 TTC: port to xopBL ren'd Restore-State() -> Restore-Exchange15StateTDO() to backfill borked wrapup cleanup; init 
        .DESCRIPTION
        Restore-Exchange15StateTDO - Reads StateFile .xml into hashtable for assignment into `$State variable, for use with/emulating install-Exchange15-TTC.ps1
        .PARAMETER Statefile
        Path to Statefile[-path c:\pathto\SERVERNAME_Install-Exchange15-TTC.ps1_state.xml]                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Collections.Hashtable contining data from Statefile .xml 
        .EXAMPLE
        PS> $State=@{}
        PS> $ex15ScriptName = "Install-Exchange15-TTC.ps1" ;
        PS> if(-not $StateFile){$StateFile= "$InstallPath\$($env:computerName)_$($ex15ScriptName)_state.xml"}
        PS> $StateFile= "$InstallPath\$($env:computerName)_$($ScriptName)_state.xml"
        PS> $State= Restore-Exchange15State -StateFile $StateFile ; 
        Demo call
        .LINK
        https://github.org/tostka/powershellBB/
        #>
        [CmdletBinding()]
        [alias('Restore-Exchange15State')]
        PARAM(
            [Parameter(Mandatory = $True,Position = 0,HelpMessage = 'Path to Statefile[-path c:\pathto\SERVERNAME_Install-Exchange15-TTC.ps1_state.xml]')]
                [ValidateScript({Test-Path $_})]
                #[system.io.fileinfo[]]$Path,
                [string]$Statefile
        ) ; 
        $smsg = "Reading -Statefile: $($Statefile) into hashtable" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        TRY{
            $State= @{}
            If(Test-Path $StateFile) {
                $State= Import-Clixml -Path $StateFile -ErrorAction STOP
                Write-Verbose "State information loaded from $StateFile"
            }
            Else {
                Write-Verbose "No state file found at $StateFile"
            }
            Return $State     
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ; 
    }
#endregion RESTORE_EXCHANGE15STATETDO ; #*------^ END FUNCTION Restore-Exchange15StateTDO  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHfZRg9Zap/iofQrPo6e4szai
# ofSgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSM8au+
# PqHKc9Vi5EXxyQ42xN6BwTANBgkqhkiG9w0BAQEFAASBgB6nDfCjEagIRWg8dTpe
# ith04VWNTcSwfNtBz+FxPqsOJLMDRh2q6tuhZ0BFiEI2eZoLaU7G9bPUvDJUICLV
# nZcKlud5ZBWRL1+A5AaJHj13el/73knX9LvdtVmUgBcN6MwHT5Ua2BvuEatlcHPs
# APZVVOxMS+8c7EkHfu6mUoc2
# SIG # End signature block
