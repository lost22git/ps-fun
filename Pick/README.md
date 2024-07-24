## Requirements

* [Out-ConsoleGridView](https://github.com/PowerShell/GraphicalTools) (Optional)
* [fzf](https://github.com/junegunn/fzf) (Optional)
* [gum](https://github.com/charmbracelet/gum) (Optional)

### GUI

```powershell
Get-Process | Pick -m -gui
```

![GUI](https://i.imgur.com/5XR6Oho.gif)


### TUI

- Out-ConsoleGridView

```powershell
Get-Process | Pick -m
```
- Fzf

```powershell
Get-Process | Pick -m -fzf
```
- Gum

```powershell
Get-Process | Pick -m -gum
```

![TUI](https://i.imgur.com/jPr22v7.gif)

### Usage

`Get-Help Pick -Full`

```

NAME
    Pick
    
SYNOPSIS
    Pick something from pipeline
    
    
SYNTAX
    Pick [-Source <Object[]>] [-Title <String>] [-Multiple] [-Gui] [<CommonParameters>]
    
    Pick [-Source <Object[]>] [-Title <String>] [-Multiple] [-Gum] [<CommonParameters>]
    
    Pick [-Source <Object[]>] [-Title <String>] [-Multiple] [-Fzf] [-Preview] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Source <Object[]>
        source from pipeline
        
        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -Title <String>
        title
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Multiple [<SwitchParameter>]
        multiple picking
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Gui [<SwitchParameter>]
        use Out-GridView gui
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Gum [<SwitchParameter>]
        use gum tui
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Fzf [<SwitchParameter>]
        use fzf tui
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Preview [<SwitchParameter>]
        preview window (only for fzf)
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get-Process | Pick -Title "Pick one you like"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Get-Process | Pick -Multi -Gui -Title "Pick something you like"
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS > Get-Process | Pick -Multi -Title "Pick something you like"
    
    
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS > Get-Process | Pick -Multi -Fzf -Title "Pick something you like"
    
    
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS > Get-Process | Pick -Multi -Gum -Title "Pick something you like"
    
    
    
    
    
    
    
RELATED LINKS

```
