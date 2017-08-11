<# Console and ISE Settings #>
# Update profile variable
Set-Variable -Name profile -Value $env:USERPROFILE\documents\WindowsPowerShell\Profile.ps1

# Default Location
Set-Location "C:\Scripts"

# Change Window title
$Host.UI.RawUI.WindowTitle = "$env:USERDOMAIN/$(($env:USERNAME).ToUpper())"

# Shell object
$shell = $Host.UI.RawUI

# Console Colors
$shell.BackgroundColor = "Black"
$shell.ForegroundColor = "Gray"


# Auto Load functions
$source = "c:\Scripts\functions"
$failedToLoad = New-Object System.Collections.ArrayList
$functionErrors = New-Object System.Collections.ArrayList
Get-ChildItem "${source}\*.ps1" | foreach-object{
  try{
     $name = $_.name
    .$_
  }catch{
    $failedToLoad.add($name) | out-null
    $functionErrors.add($_) | out-null
  }
}

<# Console Settings #>
if ($host.Name -eq 'ConsoleHost')
{
    # Adjust window buffer
    $size = $shell.BufferSize
    $size.width=130
    $size.height=5000
    $shell.BufferSize = $size

    # Adjust Window Size
    $size = $shell.WindowSize
    $size.width=100
    $size.height=40
    $shell.WindowSize = $size

    # Import PSReadline and Configure Key Bindings
    Import-Module PSReadline -ErrorAction SilentlyContinue

    # Select Entire command
    Set-PSReadlineKeyHandler -key "ctrl+a" `
    -BriefDescription SelectEntireCommandLine `
    -Description "Selects the entire command line" `
    -ScriptBlock {
        param($key, $arg)
        [PSConsoleUtilities.PSConsoleReadLine]::BeginningOfLine($key, $arg)
        $line = $null
        $cursor = $null
        [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
 
        while ($cursor -lt $line.Length) {
            [PSConsoleUtilities.PSConsoleReadLine]::SelectForwardChar($key, $arg)
            [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        }
    }

    # Expands Aliases
    Set-PSReadlineKeyHandler -Key "ctrl+%"  `
    -BriefDescription ExpandAliases  `
    -LongDescription "Replace  all aliases with the full command" `
    -ScriptBlock {
        param($key, $arg)
        $ast = $null
        $tokens  = $null
        $errors  = $null
        $cursor  = $null
        [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState(
            [ref]$ast, 
            [ref]$tokens, 
            [ref]$errors, 
            [ref]$cursor
        )
        $startAdjustment  = 0
        foreach  ($token in  $tokens){
            if  ($token.TokenFlags  -band [System.Management.Automation.Language.TokenFlags]::CommandName){
                $alias  = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
                if  ($alias -ne  $null){
                    $resolvedCommand  = $alias.ResolvedCommandName
                    if  ($resolvedCommand -ne  $null){
                        $extent  = $token.Extent
                        $length  = $extent.EndOffset - $extent.StartOffset
                        [PSConsoleUtilities.PSConsoleReadLine]::Replace(
                            $extent.StartOffset + $startAdjustment,
                            $length,
                            $resolvedCommand
                        )
                        #  Our copy of the tokens won't have been updated, so we need to
                        #  adjust by the difference in length
                        $startAdjustment  += ($resolvedCommand.Length - $length)
                    }
                }
            }
        }
    } 

    # Set VIM Alias
    if(test-path "C:\Program Files (x86)\vim\vim.exe"){
        set-alias -Name vim -Value "C:\Program Files (x86)\vim\vim.exe"
        set-alias -Name vi -Value "C:\Program File (x86)\vim\vim.exe"
    }
    
    # More too come
}

<# ISE Settings #>
if($psISE){

    # Fonts             
    $psISE.Options.FontName = 'Verdana'             
    $psISE.Options.FontSize = 9          

    # Command pane             
    $psISE.Options.ConsolePaneBackgroundColor = '#000000'
    $psISE.Options.ConsolePaneForegroundColor = '#F8F8F2'  
               
    # Script pane             
    $psISE.Options.ScriptPaneBackgroundColor = '#171812'    
    $psISE.Options.ScriptPaneForegroundColor = '#F8F8F2'

    # Console/Script pane color tokens            
    $tokenColors = @{
        Attribute = "#FFFFFF"
        Command = "#66D9EF"
        CommandArgument = "#AE81FF"
        CommandParameter = "#FFA07A"
        Comment = "#708090"
        GroupEnd = "#FFFFFF"
        GroupStart = "#FFFFFF"
        Keyword = "#F92659"
        LineContinuation = "#FFFFFF"
        LoopLabel = "#AE81FF"
        Member = "#FD971F"
        Number = "#AE81FF"
        Operator = "#FFFFFF"
        StatementSeparator = "#FD971F"
        String = "#9ACD32"
        Type = "#FD971F"
        Variable = "#6495ED"
    }

    # XML color tokens     
    $xmlTokenColors = @{
        Attribute = "#FD971F"
        Comment = "#708090"
        CommentDelimiter = "#708090"
        ElementName = "#6495ED"
       MarkupExtension = "#AE81FF"
        Quote = "#9ACD32"
        QuotedString = "#9ACD32"
        Tag = "#FFFFFF"
        Text = "#FFFFFF"
        CharacterData = "#FFFFFF"
    }

    foreach($tokenColor in $tokenColors.GetEnumerator()){
        $psISE.Options.TokenColors.item($tokenColor.name) = $tokenColor.value 
        $psISE.Options.ConsoleTokenColors.item($tokenColor.name) = $tokenColor.value 
    }

    foreach($tokenColor in $xmlTokenColors.GetEnumerator()){
        $psISE.Options.XmlTokenColors.item($tokenColor.name) = $tokenColor.value
    }
}

Clear-Host
if($failedToLoad){write-output "Functions Failed to load:"$failedToLoad}
