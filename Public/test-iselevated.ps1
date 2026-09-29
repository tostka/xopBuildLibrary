#*------v test-IsElevated.ps1 v------
function test-IsElevated {
    <#
    .SYNOPSIS
    test-IsElevated - Tests if session is running with local\Administrators membership -AND- High Integrity Level (should match, but they do reflect different components)
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : test-IsElevated.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Permissions,Session
    REVISIONS
    * 5:48 PM 5/15/2021 make whoami.exe call conditional
    * 8:06 AM 7/23/2020 updated CBH
    * 2:03 PM 3/27/2020 simplified, added CBH, cited author & source
    .DESCRIPTION
    test-IsElevated - Tests if session is running with local\Administrators membership -AND- High Integrity Level (should match, but they do reflect different components. Uses slower whoami.exe (only way to get Integrity Level)
    .EXAMPLE
    if(test-IsElevated){"Y"} else {"No" } ;
    Echo "Y" if current session is a member of local\administrators member & High Integrity, and "N" if not
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    PARAM() ;
    # using slower whoami
    #[bool](whoami /groups|where{$_ -match 'BUILTIN\\Administrators'})| write-output ;
    # faster using WinIdentity class...
    <#$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($User) ;
    [bool]($WindowsPrincipal.IsInRole('BUILTIN\Administrators')) | write-output ;
    #>
    # ...but Integrity Level isn't returned by WindowsIdentity, have to use whoami to actually eval; whoami /groups may be quicker (subset of output meas-cmd says 20.978secs v 20.518secs incremental diff )
    if(-not(get-variable -Name whoamiAll -ea 0)){$whoamiAll = (whoami /all)} ;
    [bool](($whoamiAll |?{$_ -match 'BUILTIN\\Administrators'}) -AND ($whoamiAll |?{$_ -match 'S-1-16-12288'})) | write-output ;
}

#*------^ test-IsElevated.ps1 ^------
