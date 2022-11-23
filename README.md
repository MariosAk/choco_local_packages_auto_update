# choco_server_local_packages_auto_update

These scripts are used with a [chocolatey local server](https://docs.chocolatey.org/en-us/guides/organizations/set-up-chocolatey-server) set up on a windows machine. The script first checks if an updated version of the app exists and then downloads the installer, deletes and edits some files and finally pushes the new version to the choco server.  
Below are the supported apps.  
* Firefox
