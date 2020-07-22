# The Civyanquark Inspector
# v. 0.1 - 07/21/2020
# by PresComm
# https://github.com/PresComm/TheCivyanquarkInspector
# https://www.presumptuouscommoner.com

#MIT License

<#Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.#>

#Allow user to provide their desired target subnet as a command-line parameter, as well as their desired output format
Param(
    [string]$targets,
    [string]$output,
    [string]$filepath,
    [string]$intarget,
    [string]$module,
    [string]$help    
)
    $global:targets = $targets
    $global:output = $output
    $global:filepath = $filepath
    $global:intarget = $intarget
    $global:module = $module
    $global:help = $help

#Main function
function execute-main() {
    show-banner

    if ($global:help -eq "True") {
        show-help
    }

    $global:originalExt = $filepath 
    prep-modules

    if ($global:module -eq "") {
        $arrayLoop = @($moduleArray).length

        for($arrayLoop -gt 0; $arrayLoop--) {
        Import-Module -Name $moduleArray[$arrayLoop].fullname

        $global:moduleExt = $originalExt
        $global:filepath = $originalExt
        $moduleExt = $moduleArray[$arrayLoop].name
        $moduleExt = $moduleExt.Substring(0,$moduleExt.Length-5)
        $global:filepath = "$filepath"+"_"+"$moduleExt"

        $global:currentModule = $moduleExt

        init-output
        target-logic
        
        Get-Module | Remove-Module
         
        }

        exit
    }

    init-output
    target-logic

    Get-Module | Remove-Module   
}

#Banner function
function show-banner() {
    #Show banner, version info, authorship, etc.
    cls
    echo "The Civyanquark Inspector"
    echo "v. 0.1 - 07/22/2020"
    echo "by PresComm"
    echo "https://github.com/PresComm/TheCivyanquarkInspector"
	echo "https://www.presumptuouscommoner.com"
    echo ""

    #Trying to poll non-Windows machines results in nasty errors, so let's ignore them and move on when they pop up.
    $global:ErrorActionPreference = 'SilentlyContinue'
}

#Help function
function show-help() {
    echo "[===HELP INFORMATION===]"
    echo ""
    echo "When run under the context of a user with admin privileges on the target machines, The Civyanquark Inspector will iterate through a user-supplied target or target list and run one or more info-gathering modules on each Windows machine contacted."
    echo ""
    echo "Accepted parameters:"
    echo ""
    echo "-targets"
    echo ""
    echo "Specifies the target(s) to be scanned."
    echo ""
    echo "Examples: 192.168.1.1, 192.168.1.25-50, 192.168.1.0/24"
    echo ""
    echo "-intarget"
    echo ""
    echo "Allows user to specify an input file of targets, one entry per line (see -targets example for acceptable input types.)"
    echo ""
    echo "Example: .\input.txt"
    echo ""
    echo "-output"
    echo ""
    echo "Specifies the output format (if left blank, no file will be output; results will be written to the terminal.)"
    echo ""
    echo "Currently supported output options: TXT, CSV, HTML"
    echo ""
    echo "-filepath"
    echo ""
    echo "Specifies the path for the output file (cannot be used without -output; if left blank, no file will be written [I will address this in an upcoming update])."
    echo ""
    echo "Example: C:\Users\Username\Desktop\Output.txt"
    echo ""
    echo "-module"
    echo ""
    echo "Selects the module(s) to be run against the target(s). Single modules can be specified. If left blank, all modules will be run."
    echo ""
    echo "Example: Coerchck"
    echo ""
    echo "-help"
    echo ""
    echo "Displays help information."
    echo ""
    echo "Accepted values: true"
    echo ""
    echo ""
    echo ""
    echo "[===AVAILABLE MODULES===]"
    echo ""
    echo "Coerchck - Pulls a list of local administrator accounts from target."
    echo ""
    echo "Inritver - Gathers BitLocker status information from target."
    echo ""
    echo "Stolanis - Pulls a list of installed applications from target."
    echo ""
    echo "Livviton - Lists details of shares on target."
    echo ""
    echo "Vinuusev - Polls target for a list of services."
    echo ""

    exit
}

#Function for determining which module(s) are being run and setting variables up accordingly
function prep-modules() {
    if ($global:module -eq "") {
        $modulePath = ".\modules\"
        $global:moduleArray = @(Get-ChildItem $modulePath -File)
        [array]::Reverse($moduleArray)
    }
    else {
        $modulePath = ".\modules\"+"$module"+".psm1"
        Import-Module -Name $modulePath

        $moduleExt = $module
        $global:filepath = "$filepath"+"_"+"$moduleExt"
        $global:currentModule = $module
    }
}

#Output init function
function init-output(){
    #If an output format of some kind was supplied as a parameter, react accordingly and create the initial file so we can loop through and append to it.
    if ($global:output -eq "TXT"){
        echo "$global:currentModule scan results" | Select-Object @{Name='The Civyanquark Inspector - Blue Team Security Data Gatherer';Expression={$_}} | Out-File $global:filepath
    }
    if ($global:output -eq "CSV"){
        echo "$global:currentModule scan results" | Select-Object @{Name='The Civyanquark Inspector - Blue Team Security Data Gatherer';Expression={$_}} | Export-Csv -Path $global:filepath -NoTypeInformation
    }
    if ($global:output -eq "HTML"){
        echo "The Civyanquark Inspector - Blue Team Security Data Gatherer"''"$global:currentModule scan results" | Select-Object @{Expression={$_}} | ConvertTo-Html | Out-File $global:filepath
    }
}

#Target logic function
function target-logic() {
    #Check to see if . If so, determine what type of target.
    if ($global:targets -ne "") {
        $targetspecified = "Targets"
    }
    #Check to see if an input file for targets was supplied. If so, determine what type of targets.
    if ($global:intarget -ne "") {
        $targetspecified = "Intarget"
    }

    #Check to see if no targets were supplied. If no targets were supplied, throw an error message and exit the script
    if ($targetspecified -ne "Targets" -and $targetspecified -ne "Intarget"){
        echo "Target(s) must be specified either at the command-line or via an input file. For more info run script with -help True."
        echo ""
        exit
    } else {
        #Logic if targets were supplied directly at the command-line.
        if ($targetspecified -eq "Targets") {
            if ($global:targets -like '*-*') {
                scan-range
            }
            if ($global:targets -like '*/*') {
                scan-subnet
            }
            else {
                if ($global:targets -notlike '*-*' -and $global:targets -notlike '*/*') {
                    scan-ip
                }
            }
        }
        #Logic if an input file for targets was supplied.
        if ($targetspecified -eq "Intarget") {
            foreach ($line in Get-Content $intarget) {
                if ($line -like '*-*') {
                    $global:targets = $line
                    scan-range
                }
                if ($line -like '*/*') {
                    $global:targets = $line
                    scan-subnet
                }
                else {
                    if ($line -notlike '*-*' -and $line -notlike '*/*') {
                        $global:targets = $line
                        scan-ip
                    }
                }
            }
        }
    }
}

#Function for testing connection to current target
function test-connection() {
    $requestCallback = $state = $null
    $client = New-Object System.Net.Sockets.TcpClient
    $beginConnect = $client.BeginConnect($global:IP,445,$requestCallback,$state)
    Start-Sleep -milli 3000
    if ($client.Connected) { $global:open = $true } else { $global:open = $false }
    $client.Close()
}

#Function for scanning single IPs
function scan-ip(){
    echo "Beginning $global:currentModule scan of $global:targets..."
    echo ""

    $global:IP = $global:targets

    test-connection

    if ($global:open -eq "True") {

        use-module

    }
}

#Function for scanning address ranges
function scan-range(){
    echo "Beginning $global:currentModule scan of $global:targets..."
    echo ""
    
    $firstset = $global:targets
    $secondset = $global:targets

    $root = $firstset.split('-')[0]
    $lastipoct = $secondset.split('-')[-1]
    $firstipoct = $root.split('.')[-1]

    $root = $root -split '\.' | ForEach-Object {
        [System.Convert]::ToString($_,2).PadLeft(8,'0')
    }

    $root = $root -join ''

    $firstoctet = $root.SubString(0,8)
    $thirdoctet = $root.SubString(16,8)
    $secondoctet = $root.SubString(8,8)

    $firstoctet = $firstoctet | ForEach-Object {
        [System.Convert]::ToByte($_,2)
    }
    $secondoctet = $secondoctet | ForEach-Object {
        [System.Convert]::ToByte($_,2)
    }
    $thirdoctet = $thirdoctet | ForEach-Object {
        [System.Convert]::ToByte($_,2)
    }

    $root = "$firstoctet"+'.'+"$secondoctet"+'.'+"$thirdoctet"

    $totaltargets = $lastipoct - $firstipoct

    $currentoct = $firstipoct

    do {
        $global:IP = "$root"+'.'+"$currentoct"
        
        test-connection

        if ($global:open -eq "True") {

            use-module
           
        }
            $totaltargets = $totaltargets - 1
            [int]$currentoct = [int]$currentoct + 1
        
    } while ($totaltargets -gt -1)
}

#Function for scanning subnets
function scan-subnet(){
    echo "Beginning $global:currentModule scan of $global:targets..."
    echo ""
    #This is the function that iterates through the user-supplied subnet.
    #Credit for this portion of the script goes to Mark Gossa
    #on the Microsoft TechNet Gallery (https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Subnet-db45ec74).
    #I ensured the license is fine for me to include this function in my script.
    foreach ($subnet in $global:targets) {
        
        #Split IP and subnet
        $global:IP = ($Subnet -split "\/")[0]
        $SubnetBits = ($Subnet -split "\/")[1]
        
        #Convert IP into binary
        #Split IP into different octects and for each one, figure out the binary with leading zeros and add to the total
        $Octets = $global:IP -split "\."
        $IPInBinary = @()

        foreach($Octet in $Octets) {
            #convert to binary
            $OctetInBinary = [convert]::ToString($Octet,2)
                
            #get length of binary string add leading zeros to make octet
            $OctetInBinary = ("0" * (8 - ($OctetInBinary).Length) + $OctetInBinary)

            $IPInBinary = $IPInBinary + $OctetInBinary
        }

        $IPInBinary = $IPInBinary -join ""

        #Get network ID by subtracting subnet mask
        $HostBits = 32-$SubnetBits
        $NetworkIDInBinary = $IPInBinary.Substring(0,$SubnetBits)
        
        #Get host ID and get the first host ID by converting all 1s into 0s
        $HostIDInBinary = $IPInBinary.Substring($SubnetBits,$HostBits)        
        $HostIDInBinary = $HostIDInBinary -replace "1","0"

        #Work out all the host IDs in that subnet by cycling through $i from 1 up to max $HostIDInBinary (i.e. 1s stringed up to $HostBits)
        #Work out max $HostIDInBinary
        $imax = [convert]::ToInt32(("1" * $HostBits),2) -1

        $IPs = @()

        #Next ID is first network ID converted to decimal plus $i then converted to binary
        For ($i = 1 ; $i -le $imax ; $i++) {
            #Convert to decimal and add $i
            $NextHostIDInDecimal = ([convert]::ToInt32($HostIDInBinary,2) + $i)
            #Convert back to binary
            $NextHostIDInBinary = [convert]::ToString($NextHostIDInDecimal,2)
            #Add leading zeros
            #Number of zeros to add 
            $NoOfZerosToAdd = $HostIDInBinary.Length - $NextHostIDInBinary.Length
            $NextHostIDInBinary = ("0" * $NoOfZerosToAdd) + $NextHostIDInBinary

            #Work out next IP
            #Add networkID to hostID
            $NextIPInBinary = $NetworkIDInBinary + $NextHostIDInBinary
            #Split into octets and separate by . then join
            $global:IP = @()

            For ($x = 1 ; $x -le 4 ; $x++) {
                #Work out start character position
                $StartCharNumber = ($x-1)*8
                #Get octet in binary
                $IPOctetInBinary = $NextIPInBinary.Substring($StartCharNumber,8)
                #Convert octet into decimal
                $IPOctetInDecimal = [convert]::ToInt32($IPOctetInBinary,2)
                #Add octet to IP 
                $global:IP += $IPOctetInDecimal
            }

            #Separate by .
            $global:IP = $global:IP -join "."
            $FQDN = $null

            test-connection

            if ($global:open -eq "True") {

                use-module
                
			}
        }
    }
}

execute-main