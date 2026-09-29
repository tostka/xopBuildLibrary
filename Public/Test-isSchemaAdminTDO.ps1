# Test-isSchemaAdminTDO.ps1


#region TEST_ISSCHEMAADMINTDO ; #*------v Test-isSchemaAdminTDO v------
function Test-isSchemaAdminTDO {
        <#
        .SYNOPSIS
        Test-isSchemaAdminTDO - Tests if session is running with "[root domain]\Schema Admins" permissions
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Test-isSchemaAdminTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Microsoft
        AddedWebsite: https://gallery.technet.microsoft.com/scriptcenter/Verify-the-Local-User-1e365545
        AddedTwitter: URL
        REVISIONS
        * 1:26 PM 9/17/2025 init, ported from xopBuildLibrary to vAuth
        .DESCRIPTION
        Test-isSchemaAdminTDO - Tests if session is running with "[root domain]\Schema Admins" permissions
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> if(Test-isSchemaAdminTDO){
        PS>     write-host -foregroundcolor green "Validated isSchemaAdmin " ; 
        PS> } ; 
        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Test-isSchemaAdmin821','Test-isSchemaAdmin','Test-SchemaAdmin')]
        Param()
        $FRNC= Get-ForestRootNCTDO
        $ADRootSID= ([ADSI]"LDAP://$FRNC").ObjectSID[0]
        $SID= (New-object System.Security.Principal.SecurityIdentifier ($ADRootSID, 0)).Value.toString()
        return [Security.Principal.WindowsIdentity]::GetCurrent().Groups | Where-Object {$_.Value -eq "$SID-518"}
    }
#endregion TEST_ISSCHEMAADMINTDO ; #*------^ END Test-isSchemaAdminTDO ^------

