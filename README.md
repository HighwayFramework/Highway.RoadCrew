Highway.RoadCrew
================

Incubating - Platform for environment setup

# Install

First, run the following two lines, which will download the current script, and run it.

```
(new-object Net.WebClient).DownloadString("http://bit.ly/hwyfwk-rc") > RunMe.ps1
.\RunMe.ps1
```

# Configure

Now setup your configuration by editing the `RunMe.config.ps1` file.  This will always be the file you edit, you shouldn't ever need to modify `RunMe.ps1`.  The following commands are supported:

* `chocolatey <package-name>` will install the named package (see http://chocolatey.org/ for a list)
  * `-source` is an optional switch that lets you specify another chocolatey feed or source
* `gem <gem-name>` will install a Ruby gem (see http://rubygems.org/ for a list)
* `windows <feature-name>` will install the named feature (execute `clist -source windowsfeatures` to see a possible list, only available after you've executed `RunMe.ps1` a second time currently)
* `profile <powershell-command>` adds the listed PowerShell command to the current user's current profile.
* `alias <alias-name> <command>` adds an alias to the current user's current PowerShell profile.
* `psget <module-name>` will install a PsGet.net PowerShell module (see http://psget.net/ for a list)


