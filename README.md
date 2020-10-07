# Clear TFVC Bindings

This powershell script removes the Scc information from project and solution files.

___Project Files___

Removes 4 xml nodes under PropertyGroup section.

___Solution Files___

Removes GloabalSection created for TeamFoundationVersionControl settings

## Steps

1. Clone this repo to your local directory.
    (You can clone it seperately from your project directory) 
2. Open Powershell and navigate to the project directory.
3. Run the script file. (Full path if you stored it in different folder)
