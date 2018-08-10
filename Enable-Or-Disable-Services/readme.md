# Enable or disable Windows services

You need to speficy a list in csv format of services that you want to manage or use one of the default ones. Use _Service Display Names_ ++only++ in this list. In doubt look at the defaults. 

## Syntax:

$ disableEnableServices.ps1 -action {enable | disable | check} [-auto {$true | $false}] [-preset \<path>] 

### MAN

* -action

    * enable: sets services startup type to manual

    * disable: sets services startup type to disabled

    * check: shows status of services in the list

* -auto (has effect only with enable or disable) [default: $false] 

    * $false: decide action for each service

    * $true: like, automatic, you know

* -preset [default: services.csv]

    * path to the csv file
