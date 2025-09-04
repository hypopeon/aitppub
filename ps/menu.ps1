<#
.SYNOPSIS
    Provides a menu-driven interface to download and execute PowerShell scripts from URLs.

.DESCRIPTION
    This script displays a menu of script categories. Upon selection, it shows a sub-menu
    of available scripts. Choosing a script will download its content using
    Invoke-RestMethod (irm) and execute it using Invoke-Expression (iex).

.WARNING
    EXTREME CAUTION IS ADVISED. This script uses 'Invoke-Expression' (iex) to run code
    downloaded directly from the internet without prior inspection. This is a significant
    security risk. Only use this script with URLs you own and trust completely.
    Running scripts from untrusted sources can lead to severe system compromise,
    data loss, or malware infection.
#>

# --- SCRIPT CONFIGURATION ---
# Define the menu structure. Add categories as keys and an array of script objects as values.
# Each script object should have a 'Name' for the menu and a 'Url' for the script source.
$menuConfiguration = @{
    "Scripts" = @(
        @{ Name = "1. PowerShell: Modern Standby-problem"; Url = "https://hypopeon.github.io/aitppub/ps/modernstandby.ps1" },
        # Add more script objects here
    )
    "Misc" = @(
        @{ Name = "TBA"; Url = "" }
        # Add more script objects here
    )
}

# --- SCRIPT FUNCTIONS ---

function Show-SubMenu {
    param(
        [string]$CategoryName,
        [array]$Scripts
    )

    while ($true) {
        Clear-Host
        Write-Host "--- $CategoryName ---" -ForegroundColor Cyan
        
        # Display the scripts in the selected category
        for ($i = 0; $i -lt $Scripts.Count; $i++) {
            Write-Host "$($i + 1). $($Scripts[$i].Name)"
        }
        Write-Host "B. Back to Main Menu"
        Write-Host ""

        $choice = Read-Host "Enter your choice"

        if ($choice -eq 'B' -or $choice -eq 'b') {
            return
        }

        if ($choice -match "^\d+$" -and [int]$choice -ge 1 -and [int]$choice -le $Scripts.Count) {
            $selectedScript = $Scripts[[int]$choice - 1]
            Execute-RemoteScript -Url $selectedScript.Url
            Read-Host "Press Enter to continue..."
        }
        else {
            Write-Host "Invalid choice, please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}

function Execute-RemoteScript {
    param(
        [string]$Url
    )
    
    try {
        Write-Host "Attempting to execute script from: $Url" -ForegroundColor Yellow

        # The core command:
        # 1. irm (Invoke-RestMethod) downloads the content from the URL.
        # 2. The pipe symbol '|' sends that content to the next command.
        # 3. iex (Invoke-Expression) executes the content as a PowerShell script.
        irm $Url | iex

        Write-Host "Successfully executed script from: $Url" -ForegroundColor Green
    }
    catch {
        Write-Host "An error occurred while trying to execute the script from: $Url" -ForegroundColor Red
        Write-Host "Error details: $_" -ForegroundColor Red
    }
    finally {
        Write-Host ("-" * 50)
    }
}


# --- SCRIPT EXECUTION ---
while ($true) {
    Clear-Host
    # --- ASCII Art Header ---
    $asciiArt = @'
 $$$$$$\  $$$$$$\ $$$$$$$$\ $$$$$$$\  
$$  __$$\ \_$$  _|\__$$  __|$$  __$$\ 
$$ /  $$ |  $$ |     $$ |   $$ |  $$ |
$$$$$$$$ |  $$ |     $$ |   $$$$$$$  |
$$  __$$ |  $$ |     $$ |   $$  ____/ 
$$ |  $$ |  $$ |     $$ |   $$ |      
$$ |  $$ |$$$$$$\    $$ |   $$ |      
\__|  \__|\______|   \__|   \__|      
'@
    Write-Host $asciiArt -ForegroundColor Green
    Write-Host ""
    Write-Host "  Aros IT-Partner Toolbox by Andreas Elfström" -ForegroundColor Cyan
    Write-Host "==============================================="
    Write-Host ""
    Write-Host "What do you want to do?" -ForegroundColor Yellow
    Write-Host ""

    $menuItems = $menuConfiguration.Keys | Sort-Object
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        Write-Host "$($i + 1). $($menuItems[$i])"
    }
    Write-Host "Q. Quit"
    Write-Host ""

    $mainChoice = Read-Host "Enter your choice"

    if ($mainChoice -eq 'Q' -or $mainChoice -eq 'q') {
        break
    }

    if ($mainChoice -match "^\d+$" -and [int]$mainChoice -ge 1 -and [int]$mainChoice -le $menuItems.Count) {
        $selectedCategory = $menuItems[[int]$mainChoice - 1]
        Show-SubMenu -CategoryName $selectedCategory -Scripts $menuConfiguration[$selectedCategory]
    }
    else {
        Write-Host "Invalid choice, please try again." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

Write-Host "Exiting script." -ForegroundColor Green


