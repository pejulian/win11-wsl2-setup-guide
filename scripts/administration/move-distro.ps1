$NewDrive = Read-host -Promp "Input the drive letter to move WSL to (eg: D) "

if ( $NewDrive ) {
    echo "Moving WSL to the drive..."
    cd $NewDrive":"

    mkdir WSL
    cd WSL

    echo "Getting current distribution id and name..."
    
    $DefaultDistId = Get-ItemPropertyValue 'HKCU:HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name DefaultDistribution
    echo "Distribution Id: $DefaultDistId"

    $DistName = Get-ItemPropertyValue "HKCU:HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss\$DefaultDistId" -Name DistributionName
    echo "Distribution Name: $DistName"
    
    $ExportFile = "$DistName.tar"

    echo ""
    echo "Compressing distribution..."
    wsl --export $DistName $ExportFile

    echo ""
    echo "Verifying the export file..."
    if (Test-Path $ExportFile) {
        echo "Export file exists. Proceeding to unregister the distribution..."
        wsl --unregister $DistName
    } else {
        echo "Export file not found. Aborting the unregistration process."
        exit
    }
    
    echo ""
    echo "Creating a new distribution folder..."
    mkdir $DistName
    
    echo ""
    echo "Importing distribution into the new folder..."
    wsl --import $DistName $DistName $ExportFile
    
    echo ""
    echo "Registering WSL..."
    # wsl --set-version $DistName 2 # Set the default WSL to version 2 for the distribution
    wsl -d $DistName # Start the distribution


    echo "######"
    echo "Done!"
    echo "######"
}
Read-host -Promp "Press enter to exit"
