# Get MFA Registration Status for Group members
----------

This PowerShell Cmdlet will allow Global Administrators to query the MFA Registration status for Groups matching a search string. The function also has a parameter to add for excluding groups from that result. So if you had groups that prefixed with something like "AAD_", but wanted to exclude groups that end in the something like "Execs", you could have the exclude pattern be `".*execs$"`. I recommend using [Regexr.com](https://regexr.com/) for creating and testing patterns.