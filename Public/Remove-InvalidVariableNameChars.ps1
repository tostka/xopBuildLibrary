#*------v Function Remove-InvalidVariableNameChars v------
Function Remove-InvalidVariableNameChars {

  <#
    .SYNOPSIS
    Remove-InvalidVariableNameChars - Remove Powershell illegal Variable Name characters from the passed string. By default complies with about_Variables Best practice guidence: 'The best practice is that variable names include only alphanumeric characters and the underscore (_) character. Variable names that include spaces and other special characters, are difficult to use and should be avoided.'
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-07-26
    FileName    : Remove-InvalidVariableNameChars.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Tags        : Powershell,Variable,NameStandard,BestPractice
    REVISIONS   :
    * 3:35 PM 7/26/2022 Cleans potential variable names, simple update to the regex.
    .DESCRIPTION
    Remove-InvalidVariableNameChars - Remove Powershell illegal Variable Name characters from the passed string. By default complies with about_Variables Best practice guidence: 'The best practice is that variable names include only alphanumeric characters and the underscore (_) character. Variable names that include spaces and other special characters, are difficult to use and should be avoided.'
    I use this with dynamically-generated ticket-based variables for accumulating ticket data (traces, log parses etc), basing the dyn variable on ticket attribute, email address etc. 
    MS docs on variable name restrictions: 
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    [about Variables - PowerShell | Microsoft Docs - docs.microsoft.com/](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables?view=powershell-7.2#variable-names-that-include-special-characters)

    ## Variable names that include special characters

    Variable names begin with a dollar ($) sign and can include alphanumeric characters and special characters. The variable name length is limited only by available memory.

    The best practice is that variable names include only alphanumeric characters and the underscore (_) character. Variable names that include spaces and other special characters, are difficult to use and should be avoided.

    Alphanumeric variable names can contain these characters:

     - Unicode characters from these categories: Lu, Ll, Lt, Lm, Lo, or Nd.
     - Underscore (_) character.
     - Question mark (?) character.
     
    The following list contains the Unicode category descriptions. For more information, see UnicodeCategory.

     - Lu - UppercaseLetter
     - Ll - LowercaseLetter
     - Lt - TitlecaseLetter
     - Lm - ModifierLetter
     - Lo - OtherLetter
     - Nd - DecimalDigitNumber
     - 
    To create or display a variable name that includes spaces or special characters, enclose the variable name with the curly braces ({}) characters. The curly braces direct PowerShell to interpret the variable name's characters as literals.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    
    .PARAMETER Name
    Potential variable 'name' string to have illegal variable name characters removed. 
    .PARAMETER PermitSpecial
    Switch to permit inclusion of Special characters in variable name (use requires wrapping name in curly-braces) [-PermitSpecial]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    $Name = Remove-InvalidVariableNameChars -name $vname ; 
    Remove OS-specific illegal characters from the sample filename in $ofile. 
    .EXAMPLE
    $Name = Remove-InvalidVariableNameChars -name $vname -PermitSpecial ; 
    Demo use of -permitSpecial: Remove all but closing curly-brace } and backtick ` characters from name in $vname. 
    .EXAMPLE
    set-variable -name ($VName | Remove-InvalidVariableNameChars) -value 1 ; 
    Demo pipeline use with set-variable.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$Name,
        [Parameter(HelpMessage = 'Switch to permit inclusion of Special characters in variable name (use requires wrapping name in curly-braces) [-PermitSpecial]')]
        [switch]$PermitSpecial
    )
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        $rgxVariableNameBP = '[A-Za-z0-9_]' ; 
        $rgxInvalidChars = "[\}`]" ; # all but closing curly brace (}) character (U+007D) and backtick (`) character (U+0060).
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 

    } ;  # BEGIN-E
    PROCESS {
        foreach($item in $Name) {
            If($PermitSpecial){
                $uName = ($item -replace $rgxInvalidChars) 
                write-verbose "(-PermitSpecial specified: returning cleaned name:'$($uname)' to pipeline)" ;
            } else { 
                $uName = ($item.tochararray() -match $rgxVariableNameBP) -join '' ;
                write-verbose "(returning cleaned name:'$($uname)' to pipeline)" ; 
            } ; 
            $uName | write-output ; 
        } ; 
    } ;  # PROC-E
} ; 
#*------^ END Function Remove-InvalidVariableNameChars ^------ ;

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVSA+ISLgLnsqI5Ksc0iVQHIS
# om6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRG7hyq
# y1zilJNygKAN3MpUsT1y/jANBgkqhkiG9w0BAQEFAASBgJ7QitMfLOqfoYSR5PoX
# 1JPFIJeonovTfwfQDNNO55wMg1diXt80UOtvHT2zXqlcRLAk/zNWHo4aPL5XcMmV
# xx1Crc37q12a0gTxpzgsfW/bqStgdgRN/0p71GC/HDm8gMCbNqkvQWd/pOFBQXut
# +ZRKUjO5W0RXGz8DKn8XgKA7
# SIG # End signature block
