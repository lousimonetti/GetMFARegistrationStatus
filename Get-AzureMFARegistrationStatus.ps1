function Get-AzureMFARegistrationByGroup {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="MFAGroup",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Group name to search for members' MFA status.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,
        # Parameter help description
        [Parameter(Mandatory=$false,
                   Position=1,
                   ParameterSetName="MFAGroup",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Regular Expression to skip Groups that Match that pattern.")]
        [string]
        $NameNotMatch
    )
    if(![string]::IsNullOrEmpty($NameNotMatch)){
        $groups = Get-MsolGroup -SearchString $GroupName -All | Where-Object{$_.displayname -notmatch $NameNotMatch}
    } else{
        $groups = Get-MsolGroup -SearchString $GroupName -All
    }
    $members =@(); 
    $groups | ForEach-Object{
        $g=$_;
        $m = Get-MsolGroupMember -GroupObjectId $g.objectid -All; 
        $members += [pscustomobject]@{"GroupName"=$g.displayName; 
                                      "Group ID"=$g.objectid;
                                      "Members"=$m}
    } 
    $results=@(); 
    $members | ForEach-Object{
        $curr= $_; $curr.Members | ForEach-Object{
            $m = get-msoluser -ObjectId $_.objectid; 
            $results += [pscustomobject]@{"GroupName"=$curr.GroupName;
                 "Group ID"=$curr.'Group ID'; 
                 "UserName"=$m.userprincipalname; 
                 "User ID" = $m.objectid; 
                 "StrongAuth_Requirements"= $m.strongauthenticationRequirements.state; 
                 "StrongAuth_PhoneNumber"=  $m.strongauthenticationuserdetails.phonenumber
                }
            } 
    }
    
    return $results;
}


Connect-MsolService

"NOTE: You must be a Global Admin to return results for all accounts except your own" | Out-Host 
$groupName = Read-Host "Enter a Search String for the Group you would like to query"
$pattern = Read-Host "Is there a pattern you'd like to exclude from the results where there might be multiple groups returned from the group name search string?  If no exclude required, please leave blank (hit enter)"
$result= Get-AzureMFARegistrationByGroup -GroupName $groupName -NameNotMatch $pattern
