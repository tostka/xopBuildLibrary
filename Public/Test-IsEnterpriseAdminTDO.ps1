#region TEST_ISENTERPRISEADMINTDO ; #*------v Test-IsEnterpriseAdminTDO v------
function Test-IsEnterpriseAdminTDO {
    <#
    .SYNOPSIS
    Test-IsEnterpriseAdminTDO - Tests if session is running with "$env:userdomain\Enterprise Admins" permissions
    .NOTES
    Version     : 1.0.0.0
    Author: Todd Kadrie
    Website:	http://toddomation.com
    Twitter:	http://twitter.com/tostka
    AddedCredit : John Savill, based on DOS command sample
AddedWebsite:	https://www.itprotoday.com/cloud-computing/how-can-i-determine-which-groups-im-member-my-current-logon-session
    CreatedDate : 2013-03-25
    FileName    :
    License     :
    Copyright   :
    Github      :
    Tags        : Powershell,Permissions,Session
    REVISIONS
    * 2:29 PM 9/18/2025 ren Test-IsEnterpriseAdmin -> Test-IsEnterpriseAdminTDO, alias orig, add alias Test-EnterpriseAdmin; add region tags
    * 12:05 PM 9/17/2024 flipped $User non-mand w [ValidateNotNullOrEmpty()]
    * 2:03 PM 3/27/2020 simplified, added CBH, cited author & source
    * 7/27/2005 posted version
    .DESCRIPTION
    Test-IsEnterpriseAdminTDO - Tests if session is running with "[root domain]\Enterprise Admins" permissions
    Leverages the old whoami utility (core, previously ResKit)
    .PARAMETER  File
    File [-file c:\path-to\file.ext]
    .EXAMPLE
    if(Test-IsEnterpriseAdminTDO){"Y"} else {"No" } ;
    Echo "Y" if DomainAdmin member, and "N" if not
    .LINK
    https://www.itprotoday.com/cloud-computing/how-can-i-determine-which-groups-im-member-my-current-logon-session
    #>
    [CmdletBinding()]
    [Alias('Test-IsEnterpriseAdmin','Test-EnterpriseAdmin')]
    PARAM(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="User security principal [-User `$SecPrinobj]")]
            [ValidateNotNullOrEmpty()]
            [System.Security.Principal.WindowsIdentity]$User = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    ) ;
    # using slower whoami
    #[bool](whoami /groups|where{$_ -match ".*\\Enterprise\sAdmins"})| write-output ;
    # faster using WinIdentity class
    $WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($User) ;
    [bool]($WindowsPrincipal.IsInRole('\Enterprise Admins')) | write-output ;
} ; 
#endregion TEST_ISENTERPRISEADMINTDO ; #*------^ END Test-IsEnterpriseAdminTDO ^------