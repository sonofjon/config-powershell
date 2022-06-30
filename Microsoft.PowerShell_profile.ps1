#### Modules

### Install-AJ8Apps
Import-Module ~\Documents\WindowsPowerShell\Install-AJ8Apps.psm1


### PSReadLine

# Based on https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1

Import-Module PSReadLine

## Options

# Disable bell
Set-PSReadLineOption -BellStyle Visual

# Use Emacs key bindings 
Set-PSReadLineOption -EditMode Emacs

# Place cursor at the end of the line while cycling through history
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

## Key bindings

# Improved history search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Windows style completion
Set-PSReadLineKeyHandler -Key Ctrl+q -Function TabCompleteNext
Set-PSReadLineKeyHandler -Key Ctrl+Q -Function TabCompletePrevious

# Clipboard interaction
Set-PSReadLineKeyHandler -Key Ctrl+C -Function Copy
Set-PSReadLineKeyHandler -Key Ctrl+V -Function Paste

# Use arrows for word movement
#   Doesn't work: https://github.com/PowerShell/PSReadLine/issues/105
Set-PSReadLineKeyHandler -Key Alt+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Alt+RightArrow -Function ForwardWord

# Use token based movements
#   (by default Emacs uses word based movement)
# Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
# Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
# Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
# Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
# Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
# Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord

# Save command to history 
Set-PSReadLineKeyHandler -Key Alt+w `
                         -BriefDescription SaveInHistory `
                         -LongDescription "Save current line in history but do not execute" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}


# `ForwardChar` accepts the entire suggestion text when the cursor is
# at the end of the line.  This custom binding makes `RightArrow`
# behave similarly - accepting the next word instead of the entire
# suggestion text.
#   TODO: Doesn't work (on PowerShell 5.1)
Set-PSReadLineKeyHandler -Key RightArrow `
                         -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
                         -LongDescription "Move cursor one character to the right in the current editing line and accept the next word in suggestion when it's at the end of current editing line" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -lt $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
    } else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
    }
}


### Winget

# Completion
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
