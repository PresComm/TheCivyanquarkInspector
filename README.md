# The Civyanquark Inspector

#### Description:

The Civyanquark Inspector is a PowerShell utility that can target individual IPs, ranges, entire subnets, or a mixture any of those things. When run against a Windows target, this script will run one or more modules to gather information from the selected targets. This script was developed for blue teams to gather potentially useful information from unfamiliar systems/networks where they otherwise have little to know visibility. Requires administrator privileges on target systems.

#### Usage:

When run under the context of a user with administrator privileges on the target machines, The Civyanquark Inspector will iterate through a user-supplied target or target list and utilize one or more modules to gather information from Windows targets.

Accepted parameters:

-targets

Specifies the target(s) to be scanned.

Examples: 192.168.1.1, 192.168.1.25-50, 192.168.1.0/24

-intarget

Allows user to specify an input file of targets, one entry per line (see -targets example for acceptable input types.)

Example: .\input.txt

-output

Specifies the output format (if left blank, no file will be output; results will be written to the terminal.)

Currently supported output options: TXT, CSV, HTML

-filepath

Specifies the path for the output file (cannot be used without -output; if left blank, no file will be written [I will address this in an upcoming update]).

Example: C:\Users\Username\Desktop\Output.txt

-module

Selects the module(s) to be run against the target(s). Single modules can be specified. If left blank, all modules will be run.

Example: Coerchck

-help

Displays help information.

Accepted values: true

#### Modules:

Coerchck - Pulls a list of local administrator accounts from target

Inritver - Gathers BitLocker status information from target.

Stolanis - Pulls a list of installed applications from target.

Livviton - Lists details of shares on target.

Vinuusev - Polls target for a list of services.

#### Notes:

- Now supports single IPs, IP ranges, and subnets of any size!
- Now supports parameters only via the command-line; no more interactive prompts.
- Now has a -help parameter!
- Functions have been re-added.
- Now attempts to connect to potential targets on TCP port 445 before polling for administrator list. Speed is significantly increased as a result (I realize this may lead to false negatives and blank input for non-Windows SMB/Samba shares or other services running on this well-known port. I will continue to polish this feature in future updates.)
- Now supports input text files containing a list of targets. This means the user can supply a mixture of single IPs, IP ranges, and subnets of any size for a single scan!
- Previous standalone scripts Coerchck and Inritver have been deprecated and moved to modules to be used with this script.
- Fixed an issue wherein past standalone scripts were not recording their output in terminal windows. This will eventually be folded into an optional -verbose parameter or will only appear when an output file is not specified.

#### Plans:

- Allow for verbose output of scanning process.
- Allow for non-CIDR subnet masks (such as 255.255.255.0).
- Allow for custom module paths to be provided at the command-line. Right now, the script assumes .\modules.
- Allow for a user-supplied list of modules to be either included or excluded. Right now users can either run all modules or a single module only.
- Allow for per-target output. Right now, the tool creates an output file or prints in the terminal results for each module at a time (one file for Coerchck, one file for Inritver, etc.) Would like to have the option to make a report per-target instead of per-module.
- Add more error-catching logic (e.g., for bad or empty input).
- Make the output naming cleaner (this will depend heavily on the inclusion of per-target output.)
- Clean up the various output formats. CSV and HTML are mostly useless right now.
- Clean up individual module-specific errors. By that, I mean either fixing the source of the errors, providing user-friendly output, or suppressing the errors altogether.
- Many more modules are already in the works and will be added soon.
- Possible support for non-domain or out-of-permission targets.
- Possible support for user-supplied credentials at the command-line.
- Possible support for automatically pulling the local IP and subnet mask of the machine running the script to use as the input.
- Possible framework publication and code adjustment for allowing user-created modules to be dropped in the "modules" directory.
- Possible inclusion of a -command parameter to allow users to supply their own command to be run against targets instead of loading a module.

### Credit:

Credit for the portion of the Coerchck module that actually retrieves local admins (which actually inspired this entire script) goes to Paperclip on the Microsoft TechNet Gallery (https://gallery.technet.microsoft.com/scriptcenter/Get-remote-machine-members-bc5faa57). I contacted them and received approval before reusing their function.

Credit for the portion of the script that performs subnet calculation based upon the user's inpurt goes to Mark Gossa on the Microsoft TechNet Gallery (https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Subnet-db45ec74). I ensured the license is fine for me to include this function in my script.