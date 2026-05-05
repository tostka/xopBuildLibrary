#region COMPARE_OBJECTSSIDEBYSIDE3 ; #*------v FUNCTION Compare-ObjectsSideBySide3 v------
function Compare-ObjectsSideBySide3 {
            <#
            .SYNOPSIS
            Compare-ObjectsSideBySide3() - Displays four objects side-by-side comparatively in console
            .NOTES
            Author: Richard Slater
            Website:	https://stackoverflow.com/users/74302/richard-slater
            Updated By: Todd Kadrie
            Website:	http://www.toddomation.com
            Twitter:	@tostka, http://twitter.com/tostka
            Additional Credits: REFERENCE
            FileName    : Compare-ObjectsSideBySide3.ps1
            License     : MIT License
            Copyright   : (c) 2020 Todd Kadrie
            Github      : https://github.com/tostka/verb-IO
            Tags        : Powershell,Compare
            REVISIONS   :
            *3:17 PM 12/9/2025 add -ExcludeProperties, -ExplicitProperties
            * 11:18 AM 12/8/2025 add region
            * 10:33 AM 4/25/2022 edit back to compliance, prior overwrite with cosbs4; , fixed pos param specs (uniqued); included output in exmplt
            * 10:35 AM 2/21/2022 CBH example ps> adds 
            * 10:17 AM 9/15/2021 moved to full param block,expanded CBH
            * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
            * 10:18 AM 11/2/2018 Extension of base model, to 4 columns
            * May 7 '16 at 20:55 posted version
            .DESCRIPTION
            Compare-ObjectsSideBySide3() - Displays four objects side-by-side comparatively in console
            .PARAMETER col1
            Object to compare in 1st column[-col1 `$PsObject1]
            PARAMETER col2
            Object to compare in 2nd column[-col2 `$PsObject1]
            PARAMETER col3
            Object to compare in 3rd column[-col3 `$PsObject1]
            .PARAMETER ExcludeProperties
            Properties to be excluded (generally due to char width in table)[-ExcludeProperties 'DistinguishedName']
            .PARAMETER ExplicitProperties
            Properties to be compared (static list, non-discovered from populuation)[-ExplicitProperties @('DistinguishedName','Name')]  
            .INPUTS
            Acceptes piped input.
            .OUTPUTS
            Outputs specified object side-by-side on console
            .EXAMPLE
            PS> $object1 = New-Object PSObject -Property @{
                  'Forename' = 'Richard';
                  'Surname' = 'Slater';
                  'Company' = 'Amido';
                  'SelfEmployed' = $true;
                } ;
            PS> $object2 = New-Object PSObject -Property @{
                  'Forename' = 'Jane';
                  'Surname' = 'Smith';
                  'Company' = 'Google';
                  'MaidenName' = 'Jones' ;
                } ;
            PS> $object3 = New-Object PSObject -Property @{
                  'Forename' = 'Zhe';
                  'Surname' = 'Person';
                  'Company' = 'Apfel';
                  'MaidenName' = 'NunaUBusiness' ;
                } ;
            PS> Compare-ObjectsSideBySide3 $object1 $object2 $object3| Format-Table Property, col1, col2, col3;
            Property     Col1    Col2   Col3
            --------     ----    ----   ----
            Company      Amido   Google Apfel
            Forename     Richard Jane   Zhe
            MaidenName           Jones  NunaUBusiness
            SelfEmployed True
            Surname      Slater  Smith  Person
            Display $object1,2, & 3 in comparative side-by-side columns
            .LINK
            https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
            #>
            PARAM(
                [Parameter(Position=0,Mandatory=$True,HelpMessage="Object to compare in 1st column[-col1 `$PsObject1]")]
                    #[Alias('lhs')]
                    $col1,
                [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 2nd column[-col1 `$PsObject1]")]
                    #[Alias('rhs')]        
                    $col2,
                [Parameter(Position=2,Mandatory=$True,HelpMessage="Object to compare in 3rd column[-col1 `$PsObject1]")]
                    #[Alias('rhs')]        
                    $col3,
                [Parameter(HelpMessage="Properties to be excluded (generally due to char width in table)[-ExcludeProperties 'DistinguishedName']")]
                    [string[]]$ExcludeProperties,
                [Parameter(HelpMessage="Properties to be compared (static list, non-discovered from populuation)[-ExcludeProperties 'DistinguishedName']")]
                    [string[]]$ExplicitProperties
            ) ;
            if(-not $ExplicitProperties){
                $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
                $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
                $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
                $combinedMembers = ($col1Members + $col2Members + $col3Members) | Sort-Object -Unique ;
            }else{
                $smsg = "-ExplicitProperties specified for compare" ; 
                $smsg += "`n$(($ExplicitProperties -join ', '|out-string).trim())" ; 
                write-verbose $smsg ; 
                $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name | ?{$ExplicitProperties -contains $_} ; 
                $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name | ?{$ExplicitProperties -contains $_} ; 
                $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name | ?{$ExplicitProperties -contains $_} ; 
                $combinedMembers = ($col1Members + $col2Members + $col3Members) | Sort-Object -Unique ;
            } ; 
            if($ExcludeProperties){
                $combinedMembers |?{$ExcludeProperties -notcontains $_ } ; 
                write-verbose "-ExcludeProperties: $($ExcludeProperties)" ; 
            }
            $combinedMembers | ForEach-Object {
                $properties = @{'Property' = $_} ;
                if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
                if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
                if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
                New-Object PSObject -Property $properties ;
            } ;
        }
#endregion COMPARE_OBJECTSSIDEBYSIDE3 ; #*------^ END FUNCTION Compare-ObjectsSideBySide3  ^------

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZ/YgTYblKwEfpLrkMN6SAtAZ
# 2mOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTSjIYp
# +dAtQs4j7Hq4mOcgDstJWjANBgkqhkiG9w0BAQEFAASBgKZZwqXwX3chMKPpSaMy
# L3lBxM6oznzAajpldYiKEgELnDwJI2rB7E44u/9WFLKYUtcmaMEj/BhjyyrSClg5
# ps3ZsmIQQgQI5zSIM1h3xFeKPCfaH+ht0qMHQM2FIoWHpkmTY/SSIpt+GqmT78EG
# 7bO5pn4Knp6lyQSofxye7SHe
# SIG # End signature block
