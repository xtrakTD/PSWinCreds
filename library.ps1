Function Get-WinCreds
{
param([string]$credName)
	
	$path = "D:\scripts\$credName.xml"
	$import = Import-CLixml $path
	 
	$Username = $import.Username 
	$SecurePassword = $import.Password | ConvertTo-SecureString
	 
	$Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePassword
	return $Credential
}

Function Set-WinCreds 
{
param ([string]$credName = "creds")

	$Credential = Get-Credential;
	$export = "" | Select-Object Username, Password
	 
	$export.Username = $Credential.Username
	$export.Password = $Credential.Password | ConvertFrom-SecureString

	$path = "D:\scripts\$credName.xml"
	 
	$export | Export-Clixml $path
	Write-Host "Credential Save Complete"
}