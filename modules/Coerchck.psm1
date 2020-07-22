# Coerchck
# v. 0.1 - 07/21/2020
# by PresComm
# https://github.com/PresComm/TheCivyanquarkInspector/modules/Coerchck.psm1
# https://www.presumptuouscommoner.com

#NOTE: This is a module that is intended to be used with The Civyanquark Inspector (https://github.com/PresComm/TheCivyanquarkInspector).

#Function for pulling the admin list from targets and placing it in output files, if specified
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

    #This is the function that actually polls each target for the list of local administrators.
    #Credit for this portion of the script (which actually inspired this entire script) goes to
    #Paperclip on the Microsoft TechNet Gallery (https://gallery.technet.microsoft.com/scriptcenter/Get-remote-machine-members-bc5faa57).
    #I contacted them and received approval before reusing their function.
    $global:admins = Gwmi win32_groupuser –computer $global:IP  
    $global:admins = $global:admins |? {$_.groupcomponent –like '*"Administrators"'}

    if ($global:output -eq "TXT") {
        $global:admins |% { 
            $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
            $matches[1].trim('"') + “\” + $matches[2].trim('"') 
        } | Select-Object @{Name='Account Name';Expression={$_}} | Out-File $global:filepath -Append -Encoding Unicode
    }
    if ($global:output -eq "CSV") {
        $global:admins |% { 
            $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
            $matches[1].trim('"') + “\” + $matches[2].trim('"') 
        } | Select-Object @{Name='Account Name';Expression={$_}} | Out-File $global:filepath -Append -Encoding Unicode
    }
    if ($global:output -eq "HTML") {
        $global:admins |% { 
            $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
            $matches[1].trim('"') + “\” + $matches[2].trim('"') 
        } | Select-Object @{Expression={$_}} | ConvertTo-Html | Out-File $global:filepath -Append -Encoding Unicode
    }
    else {
        $global:admins |% { 
            $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
            $matches[1].trim('"') + “\” + $matches[2].trim('"') 
		}
	}	

	echo ""
}