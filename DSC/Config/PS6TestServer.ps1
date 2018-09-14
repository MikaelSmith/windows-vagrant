Configuration PS6TestServer {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Node,
        [ValidateNotNullOrEmpty()]
        [string]$MOFfolder
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    Node $Node {

        File DSCLogFolder {
            Type            = 'Directory'
            DestinationPath = 'C:\Tmp\DSClogs'
            Ensure          = "Present"
        }
        Package PSCore {
            Ensure    = "Present"
            Name      = "PowerShell 6-x64"
            Path      = "$Env:SystemDrive\tmp\SourceFiles\PowerShell-6.1.0-win-x64.msi"
            ProductId = "5B7A41F8-E132-45BE-92D5-48543F89372F"
            LogPath   = "C:\Tmp\DSClogs\PS6.log"
        }
        Log AfterPSCoreInstall {
            Message   = "Finished Installing PowerShell Core 6 resource with ID PSCore"
            DependsOn = "[Package]PSCore"
        }

        Script InstallOpenSSH {
            GetScript  = {
                $folderSize = Get-ChildItem -Path 'C:\Program Files\OpenSSH\OpenSSH-Win64' |
                    Measure-Object -property Length -sum |
                    Select-Object Sum

                # return true or false
                return @{ Result = ($folderSize.Sum -eq '6940061') }
            }
            SetScript  = {
                param(
                    [string] $From = "C:\Tmp\SourceFiles\OpenSSH-Win64.zip",
                    [string] $To = "C:\Program Files\OpenSSH\",
                    [string] $Installer = "C:\Program Files\OpenSSH\OpenSSH-Win64\install-sshd.ps1"
                )
                if (Test-Path $From) {
                    # Load assembly name to perform unzip
                    Add-Type -AssemblyName System.IO.Compression.FileSystem
                    # Unzip file to directory
                    [System.IO.Compression.ZipFile]::ExtractToDirectory($From, $To)
                    # Run install
                    & $Installer
                }
            }
            TestScript = {
                # The Test function needs to return True if the system is already in the desired state
                $testpath = Test-Path "$Env:SystemDrive\Program Files\OpenSSH\OpenSSH-Win64"

                if ($testpath) {
                    $count = (Get-ChildItem -Path "$Env:SystemDrive\Program Files\OpenSSH\OpenSSH-Win64").count
                    if ($count -eq 19) {
                        return $true
                    }
                }
                return $false
            }
        }
        Log AfterInstallOpenSSH {
            Message   = "Finished Installing Open SSH resource with ID InstallOpenSSH"
            DependsOn = "[Script]InstallOpenSSH"
        }

        Script ConfigureDefaultShell {
            GetScript  = {
                return Test-Path "HKLM:\SOFTWARE\OpenSSH\DefaultShell"
            }
            SetScript  = {
                $powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
                New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $powershellPath -PropertyType String -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShellCommandOption -Value "/c" -PropertyType String -Force
            }
            TestScript = {
                $powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
                return ((Test-Path "HKLM:\SOFTWARE\OpenSSH\DefaultShell") -and ((Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell) -eq $powershellPath))
            }
            DependsOn = "[Script]InstallOpenSSH"
        }

        Firewall OpenPortForSSHServer {
            Name        = 'SSHD'
            DisplayName = 'OpenSSH SSH Server'
            Action      = 'Allow'
            Direction   = 'Inbound'
            LocalPort   = ('22')
            Protocol    = 'TCP'
            Profile     = 'Any'
            Enabled     = 'True'
        }

        Service StartSSHServer {
            Name        = 'sshd'
            StartupType = 'Automatic'
            State       = 'Running'
            DependsOn   = "[Script]InstallOpenSSH"
        }
    }
}

# Get the DSC networking module
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name NetworkingDsc -Repository PSGallery
# For Vagrant output
Write-Host "MySite DSC Config :: Node=$($args[0]), MOFfolder=$($args[1])"
# Call the configuration to generate MOF file
PS6TestServer -Node $args[0] -OutputPath $args[1]
