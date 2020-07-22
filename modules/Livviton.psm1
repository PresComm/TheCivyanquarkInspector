# Livviton
# v. 0.1 - 07/21/2020
# by PresComm
# https://github.com/PresComm/TheCivyanquarkInspector/modules/Livviton.psm1
# https://www.presumptuouscommoner.com

#NOTE: This is a module that is intended to be used with The Civyanquark Inspector (https://github.com/PresComm/TheCivyanquarkInspector).

#Function for pulling shared details from targets and placing it in output files, if specified
function use-module(){
    $FQDN = (Gwmi win32_computersystem –computer $global:IP).DNSHostName+"."+(Gwmi win32_computersystem –computer $global:IP).Domain
				
    echo "Loading results for $global:IP..."
    if ($FQDN -ne $null) {echo "FQDN :: $FQDN"}
    if ($global:output -eq "TXT") {
        echo $global:IP | Select-Object @{Name='Displaying results for...';Expression={$_}} | Out-File $global:filepath -Append -Encoding Unicode
        if ($FQDN -ne $null) {echo "FQDN :: $FQDN">>$global:filepath} 
    }
    if ($global:output -eq "CSV") {
        echo $global:IP | Select-Object @{Name='Displaying results for...';Expression={$_}} | Out-File $global:filepath -Append -Encoding Unicode
        if ($FQDN -ne $null) {echo "FQDN :: $FQDN" | Out-File $global:filepath -Append -Encoding Unicode}
    }
    if ($global:output -eq "HTML") {
        echo "Displaying results for"''$global:IP | Select-Object @{Expression={$_}} | ConvertTo-Html | Out-File $global:filepath -Append -Encoding Unicode
        if ($FQDN -ne $null) {echo "FQDN :: $FQDN" | Out-File $global:filepath -Append -Encoding Unicode}
    }

    #This is the part that actually polls each target for share details. This portion simply uses 'net view' to get basic information.
    $global:sharestatus1 = net view $global:IP
    $global:wmicShareCmd = "Get-WmiObject -class Win32_Share -computer $global:IP -EA Stop | Select Name, Path, Description"
    $global:sharestatus2 = powershell $global:wmicShareCmd

    if ($global:output -eq "TXT") {
        $global:sharestatus1
        powershell $global:wmicShareCmd
        echo $global:sharestatus1 | Out-File $global:filepath -Append -Encoding Unicode
        echo $global:sharestatus2 | Out-File $global:filepath -Append -Encoding Unicode
    }
    if ($global:output -eq "CSV") {
        $global:sharestatus1
        powershell $global:wmicShareCmd
        echo $global:sharestatus1 | Out-File $global:filepath -Append -Encoding Unicode
        echo $global:sharestatus2 | Out-File $global:filepath -Append -Encoding Unicode
    }
    if ($global:output -eq "HTML") {
        $global:sharestatus1
        powershell $global:wmicShareCmd
        echo $global:sharestatus1 | Out-File $global:filepath -Append -Encoding Unicode
        echo $global:sharestatus2 | Out-File $global:filepath -Append -Encoding Unicode
    }
    else {
        $global:sharestatus1 |% { 
            $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
            $matches[1].trim('"') + “\” + $matches[2].trim('"') 
		}
        $global:sharestatus2 |% { 
            $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
            $matches[1].trim('"') + “\” + $matches[2].trim('"') 
		}
	}

	echo ""
}