# Vinuusev
# v. 0.1 - 07/21/2020
# by PresComm
# https://github.com/PresComm/TheCivyanquarkInspector/modules/Vinuusev.psm1
# https://www.presumptuouscommoner.com

#NOTE: This is a module that is intended to be used with The Civyanquark Inspector (https://github.com/PresComm/TheCivyanquarkInspector).

#Function for pulling a list of services from targets and placing it in output files, if specified
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

    #This is the part that reaches out to targets to retrieve a list of services on that system
    $global:servicelist = Get-Service -ComputerName $global:IP

    if ($global:output -eq "TXT") {
        $global:servicelist
        echo $global:servicelist | Out-File $global:filepath -Append -Encoding Unicode
    }
    if ($global:output -eq "CSV") {
        $global:servicelist
        echo $global:servicelist | Out-File $global:filepath -Append -Encoding Unicode
    }
    if ($global:output -eq "HTML") {
        $global:servicelist
        echo $global:servicelist | Out-File $global:filepath -Append -Encoding Unicode
    }
    else {
        $global:servicelist |% { 
            $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
            $matches[1].trim('"') + “\” + $matches[2].trim('"') 
		}
	}	

	echo ""
}