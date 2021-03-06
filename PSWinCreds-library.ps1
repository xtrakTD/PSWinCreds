<# 
 .Synopsis
   Manages using saved Windows Credentials in Powershell.

 .Description
   Stores your credentials in an .xml file to future use

 .Parameter credName
   The name of the file you will be storing (adds .xml extension automatically).

 .Parameter path
   Path where to store or look for credentials

 .Example
   # Save credentials to a local file.
   New-WinCreds -credName "exampleUser"

 .Example
   # Retrieve credentials to be used.
   $creds = Get-WinCreds -credName "exampleUser"

 .Version
   1.2 21-03-2018

 .Author
   Dan Jellesma, current fork by Dmitry Minin
#>

Function Get-WinCreds
{
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)][SecureString]$credName=(ConvertTo-SecureString 'creds' -AsPlainText -Force),
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)][string]$path=($env:USERPROFILE+'\'+[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credName))+'.xml')
    )          
        Write-Debug "looking for creds in $path"
        $import = Import-CLixml $path
       
           $Username = $import.Username 
           $SecurePassword = $import.Password | ConvertTo-SecureString
       
           $Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePassword
           Write-Debug "username: $Username"
           return $Credential
}

Function New-WinCreds 
{
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)][SecureString]$credName =(ConvertTo-SecureString 'creds' -AsPlainText -Force),
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)][string]$path = $env:USERPROFILE
    )     
        [string]$credNameUnsafe = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credName))
        
        Write-Debug "'credNameUnsafe='$credNameUnsafe"

        $Credential = Get-Credential;
           $export = "" | Select-Object Username, Password
       
           $export.Username = $Credential.Username
           $export.Password = $Credential.Password | ConvertFrom-SecureString

        if(Test-Path $path)
        {
            Write-Debug "'path='$path 'exists'"
            if((Get-Item $path) -is [System.IO.DirectoryInfo])
            {
                Write-Debug "$path 'is a directory'"
                $path = $path.TrimEnd('\') + '\' + $credNameUnsafe + '.xml'
                Write-Debug "'new path: '$path"
            }            
        }
        else
        {
            Write-Host "Specified path doesn't exist. Trying to create..."
            $pathArr = $path.Split('\')
            if($pathArr[$pathArr.Length - 1] -like '*.xml')
            {
                [string]$pathLocation = ''
                for([int]$i = 0; $i -lt $pathArr.Length - 1; $i++)
                {
                    $pathLocation = $pathLocation + $pathArr[$i] + '\'
                }
                try
                {
                    mkdir $pathLocation
                }
                catch
                {
                    Write-Error 'Something went wrong' -ErrorAction:Continue
                }
            }
            else
            {
                try
                {
                    mkdir $path
                    $path = $path.Trim('\') + '\' + $credName + '.xml'
                }
                catch
                {
                    Write-Error 'Something went wrong'
                }
            }
        }          
               
           $export | Export-Clixml $path
           Write-Host "Credential Save Complete"
}        
