#Requires -RunAsAdministrator

################
#    PARAMS    #
################
Param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("enable", "disable", "check")]
    $action,

    [ValidateNotNull()]
    $auto=$false
)

###################
#    FUNCTIONS    #
###################
function confirm {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $serviceDisplayName,

        [Parameter(Mandatory=$true)]
        [string]
        $serviceName
    )
    $actionDisplay;

    if ($action -match 'enable') {
        $actionDisplay = "Enable"
    } else {
        $actionDisplay = "Disable";
    }

    $msg = "$actionDisplay service $($serviceDisplayName)? y/n (or d for description)";

    Write-Host $msg;
    $answer;
    
    while ($true) {
        $answer = Read-Host;
        if ($answer -eq 'd') {Write-Host (getServiceDesc $serviceName)
            (Get-WmiObject win32_service | Where-Object {$_.Name -eq $serviceName}).Description;
            Write-Host "y/n/d?";
        } else {
            break;
        }
    }

    return $answer -match 'y' -or !$answer;
}

function getServiceName {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $serviceDisplayName
    )

    return (getService $serviceDisplayName).Name;
}

function disableService {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $serviceName
    )

    Write-Host "Disabling $serviceName";
    Set-Service $serviceName -StartupType Disabled;
}

function enableService {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $serviceName
    )

    Write-Host "Enabling $serviceName (Manual)";
    Set-Service $serviceName -StartupType Manual;
}

function disableOrEnableService {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $serviceName
    )

    if ($action -match 'disable') {
        disableService $serviceName;
    } else {
        enableService $serviceName;
    }
}

function getServiceDesc {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $serviceName
    )

    return (Get-WmiObject win32_service | Where-Object {$_.Name -eq $serviceName}).Description;
}

function getService {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $serviceDisplayName
    )
    
    return (Get-Service | Where-Object{ $_.DisplayName -eq $serviceDisplayName});
}

function disableOrEnable {
    param (
        [Parameter(Mandatory=$true)]
        [array]
        $services
    )
    
    ForEach ($service in $services) {
        $displayName = ($service.displayName);
        $name = getServiceName $displayName;

        if (!$name) {
            Write-Host "Service $displayName was not found! Skipping...";
            continue;
        }

        if ($auto) {
            disableOrEnableService $name;
        } else {
            $ok = (confirm -serviceDisplayName $displayName -serviceName $name);

            if ($ok -eq $true) {
                disableOrEnableService $name;
            } else {
                Write-Host "Skipping...";
            }
        }
    }
}

function checkServices {
    param (
        [Parameter(Mandatory=$true)]
        [array]
        $services
    )

    $output = @();

    ForEach ($service in $services) {
        $displayName = ($service.displayName);
        $output += (getService -serviceDisplayName $displayName);
    }

    $output | Format-Table -Property StartType,Status,Name,DisplayName -AutoSize;
}

##############
#    MAIN    #
##############
$services = import-csv "services.csv" -header displayName -delimiter ','

if ($action -eq 'check') {
    checkServices -services $services;
} else {
    disableOrEnable -services $services;
}
