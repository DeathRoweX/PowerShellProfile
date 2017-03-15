# Default Location
Set-Location "C:\Scripts"

# Shell object
$Shell = $Host.UI.RawUI

# Adjust Window Size
$size = $Shell.WindowSize
$size.width=100
$size.height=35
$Shell.WindowSize = $size
$size = $Shell.BufferSize
$size.width=100
$size.height=5000
$Shell.BufferSize = $size

# Console Colors
$shell.BackgroundColor = "Black"
$shell.ForegroundColor = "Gray"

# Auto Load function scripts
$source = "c:\Scripts\functions"
$failedToLoad = New-Object System.Collections.ArrayList
$functionErrors = New-Object System.Collections.ArrayList
gci "${source}\*.ps1" | %{
  try{
     $name = $_.name
    .$_
  }catch{
    $failedToLoad.add($name) | out-null
    $functionErrors.add($_) | out-null
  }
}
Clear-Host
if($failedToLoad){write-output "Functions Failed to load:"$failedToLoad}
