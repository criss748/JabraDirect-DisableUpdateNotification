# JabraDirect-DisableUpdateNotification for all Users
 
* Software Title:	Jabra Direct
* Vendor:	        GN Audio A/S

* Downloadlink:   https://www.jabra.com/software-and-services/jabra-direct 

# install / uninstall Software

* Silent Install:	  JabraDirectSetup.exe /install /quiet /norestart

* Silent Uninstall:	JabraDirectSetup.exe /uninstall /quiet /norestart

# Post install

* Run JabraDirect-DisableUpdateNotification.ps1 to manipulate the config.json for all Users.
* The current Script edit the "DirectShowNotification" and "EnableFeedback" setting, but more is possible.

Have fun.
