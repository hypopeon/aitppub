# --- SCRIPT CONFIGURATION ---
$cfg = @{
    "Scripts" = @(
        @{ N = "1. PowerShell: Modern Standby-problem"; U = "https://hypopeon.github.io/aitppub/ps/modernstandby.ps1" }
    )
    "Misc" = @(
        @{ N = "TBA"; U = "" }
    )
}

# --- SCRIPT FUNCTIONS ---
function Execute-Script {
    param($Url)
    if (-not $Url) { return }
    try {
        Write-Host "Executing: $Url" -f Yellow; irm $Url | iex
        Write-Host "Success: $Url" -f Green
    }
    catch {
        Write-Host "Error on: $Url" -f Red; Write-Host "Details: $_" -f Red
    }
    finally { Write-Host ('-' * 50) }
}

function Show-Menu {
    param($Category, $Scripts)
    while ($true) {
        Clear-Host; Write-Host "--- $Category ---" -f Cyan
        for ($i = 0; $i -lt $Scripts.Count; $i++) { Write-Host "$($i + 1). $($Scripts[$i].N)" }
        Write-Host "B. Back"; Write-Host ""
        $choice = Read-Host "Choice"
        if ($choice -eq 'b') { return }
        if ($choice -match "^\d+$" -and $choice -ge 1 -and $choice -le $Scripts.Count) {
            $selected = $Scripts[$choice - 1]; Execute-Script -Url $selected.U
            Read-Host "Press Enter..."
        }
        else { Write-Host "Invalid" -f Red; Start-Sleep 2 }
    }
}

# --- SCRIPT EXECUTION ---
while ($true) {
    Clear-Host
    $art = @'
 $$$$$$\  $$$$$$\ $$$$$$$$\ $$$$$$$\  
$$  __$$\ \_$$  _|\__$$  __|$$  __$$\ 
$$ /  $$ |  $$ |     $$ |   $$ |  $$ |
$$$$$$$$ |  $$ |     $$ |   $$$$$$$  |
$$  __$$ |  $$ |     $$ |   $$  ____/ 
$$ |  $$ |  $$ |     $$ |   $$ |      
$$ |  $$ |$$$$$$\    $$ |   $$ |      
\__|  \__|\______|   \__|   \__|      
'@
    Write-Host $art -f Green; Write-Host ""
    "  Aros IT-Partner Toolbox by Andreas Elfström" | ForEach-Object { Write-Host $_ -f Cyan }
    "===============================================", "", "What do you want to do?" | ForEach-Object { Write-Host $_ -f Yellow }
    Write-Host ""
    $keys = $cfg.Keys | Sort-Object
    for ($i = 0; $i -lt $keys.Count; $i++) { Write-Host "$($i + 1). $($keys[$i])" }
    Write-Host "Q. Quit"; Write-Host ""
    $mainChoice = Read-Host "Choice"
    if ($mainChoice -eq 'q') { break }
    if ($mainChoice -match "^\d+$" -and $mainChoice -ge 1 -and $mainChoice -le $keys.Count) {
        $cat = $keys[$mainChoice - 1]; Show-Menu $cat $cfg[$cat]
    }
    else { Write-Host "Invalid" -f Red; Start-Sleep 2 }
}

