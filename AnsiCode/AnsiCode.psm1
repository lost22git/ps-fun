# ------ Reference ---------------------
#
# https://en.wikipedia.org/wiki/ANSI_escape_code
#
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
#
# --------------------------------------



function Show-AnsiCode
{
  foreach ($i in @("",2,3,4,5,9,10))
  {
    foreach($j in (0..9))
    {
      if($i -in @(3,4,9,10) -and $j -in @(8,9))
      {
        continue
      }
      if($i -eq 2 -and $j -ne 1)
      {
        continue
      }
      if($i -eq 5 -and $j -ne 3)
      {
        continue
      }

      $style = "`e[${i}${j}m"
      $text = "$i$j".PadLeft(3," ")
      Write-Host "$style {$text} `e[m" -NoNewline
    }
    Write-Host ""
  }
}


<#
  .SYNOPSIS
  保存当前光标位置
#>
function Save-CursorPos
{
  "`e[s"
}


<#
  .SYNOPSIS
  还原当前光标位置
#>
function Restore-CursorPos
{
  "`e[u"
}


<#
  .SYNOPSIS
  设置当前光标位置

  .EXAMPLE
  Set-CursorPos -Line 10 -Column 10

  .EXAMPLE
  Set-CursorPos -y 10 -x 10
#>
function Set-CursorPos
{
  param(
    # 绝对行号
    [Parameter(Mandatory)]
    [Alias("y")]
    [uint]$Line,

    # 绝对列号
    [Parameter(Mandatory)]
    [Alias("x")]
    [uint]$Column
  )

  "`e[${Line};${Column}H"
}


<#
  .SYNOPSIS
  移动当前光标

  .EXAMPLE
  Move-Cursor -Line -1 -Column 10
#>
function Move-Cursor
{
  param(
    # 正值代表向下, 负值代表向上，超出边缘则无效
    [Parameter(Mandatory)]
    [Alias("y")]
    [int]$Line,

    # 空值代表行首, 正值代表向右, 负值代表向左，超出边缘则无效
    [Parameter()]
    [Alias("x")]
    [int]$Column
  )
  if($null -eq $Column)
  {
    return ($Line -ge 0) ? "`e[${Line}E" : "`e[$(-$Line)F"
  } else
  {
    $c1 = ($Line -ge 0) ? "`e[${Line}B" : "`e[$(-$Line)A"
    $c2 = ($Column -ge 0) ? "`e[${Column}C" : "`e[$(-$Column)D"
    "${c1}${c2}"
  }
}


<#
  .SYNOPSIS
  移动当前光标到第n列
#>
function Move-CursorToColumn
{
  param(
    # 绝对列号
    [Parameter(Mandatory)]
    [Alias("x")]
    [uint]$Column
  )

  "`e[${Column}G"
}


<#
  .SYNOPSIS
  从光标到屏幕开始清除
#>
function Clear-ScreenToTop
{
  "`e[1J"
}


<#
  .SYNOPSIS
  从光标到屏幕末尾清除
#>
function Clear-ScreenToBottom
{
  "`e[0J"
}


<#
  .SYNOPSIS
  清除整个屏幕（并将光标移动到DOS ANSI.exe的左上角）
#>
function Clear-Screen
{
  "`e[2J"
}


<#
  .SYNOPSIS
  清除整个屏幕并删除保存在scrollback buffer中的所有行
#>
function Clear-ScreenAndBuffer
{
  "`e[3J"
}


<#
  .SYNOPSIS
  清除当前光标到行首的文本
#>
function Clear-LineToHead
{
  "`e[1K"
}


<#
  .SYNOPSIS
  清除当前光标到行尾的文本
#>
function Clear-LineToEnd
{
  "`e[0K"
}


<#
  .SYNOPSIS
  清除当前行文本 (光标位置不变)
#>
function Clear-Line
{
  "`e[2K"
}



# SGR (Select Graphic Rendition)
enum AnsiStyle
{
  reset = 0                 # 重置
  bold = 1                  # 粗体
  dim = 2                   # 暗淡化
  italic = 3                # 斜体
  underline = 4             # 下划线
  blink = 5                 # 闪烁
  blinkFast = 6             # 快速闪烁
  invert = 7                # 反色
  hide = 8                  # 隐藏
  strike = 9                # 删除线
  underlineDouble = 21      # 双下划线
  notBold = 22              # 非粗体
  notItalic = 23            # 非斜体
  notUnderline = 24         # 非下划线
  notBlink = 25             # 非闪烁
  notBlinkFast = 26         # 非快速闪烁
  notInvert = 27            # 非反色
  notHide = 28              # 非隐藏
  notStrike = 29            # 非删除线
  overline = 53             # 上划线
  notOverline = 55          # 非上划线

  # 前景色 (标准16色)
  fgBlack = 30
  fgRed = 31
  fgGreen = 32
  fgYellow= 33
  fgBlue = 34
  fgMagenta = 35
  fgCyan = 36
  fgWhite = 37
  fgBlackBright = 90
  fgRedBright = 91
  fgGreenBright = 92
  fgYellowBright = 93
  fgBlueBright = 94
  fgMagentaBright = 95
  fgCyanBright = 96
  fgWhiteBright = 97

  # 背景色 (标准16色)
  bgBlack = 40
  bgRed = 41
  bgGreen = 42
  bgYellow= 43
  bgBlue = 44
  bgMagenta = 45
  bgCyan = 46
  bgWhite = 47
  bgBlackBright = 100
  bgRedBright = 101
  bgGreenBright = 102
  bgYellowBright = 103
  bgBlueBright = 104
  bgMagentaBright = 105
  bgCyanBright = 106
  bgWhiteBright = 107
}


class AnsiText
{
  [string]$Text

  [System.Collections.ArrayList]$Style

  AnsiText($Text)
  { 
    $this.Text = $Text
    $this.Style = [System.Collections.ArrayList]::new()
  }

  [AnsiText] AddStyle([AnsiStyle[]]$Style)
  {
    if($null -ne $Style -and $Style.Count -gt 0)
    {
      foreach($s in $Style)
      {
        if($null -ne $s)
        {
          $null = $this.Style.Add($s)
        }
      }
    }
    return $this
  }

  [string] ToString()
  {
    $_text =  $this.Text
    if($this.Style.Count -gt 0)
    {
      $_code = $this.Style | ForEach-Object { [int]$_ } 
    | Join-String -Separator ";" -OutputPrefix "`e[" -OutputSuffix "m"
      return "${_code}${_text}`e[0m"
    } else
    {
      return "$_text"
    }
  }

  [string] ToRawString()
  {
    $_text =  $this.Text
    if($this.Style.Count -gt 0)
    {
      $_code = $this.Style | ForEach-Object { [int]$_ } 
    | Join-String -Separator ";" -OutputPrefix "``e[" -OutputSuffix "m"
      return "${_code}${_text}``e[0m"
    } else
    {
      return "$_text"
    }
  }
}

class AnsiTextList
{
  hidden [System.Collections.ArrayList]$List

  AnsiTextList()
  {
    $this.List = [System.Collections.ArrayList]::new()
  }

  [AnsiTextList] AddText([string]$Text)
  {
    if($null -ne $Text)
    {
      $arr = $Text.Split("`e[") 
      $p = [regex]::new("^([0-9;]*?)m([\s\S]+)") # SGR 序列正则
      $c = 0
      $last = $null
      foreach ($i in $arr)
      {
        $c += 1
        # 第一个一定是普通文本或者空串
        if($c -eq 1)
        {
          if($i.Length -gt 0)
          {
            $last = [AnsiText]::new("$i")
            $this.List.Add($last)
          }
          continue
        }
        
        $m = $p.Match("$i")

        # SGR 序列
        if($m.Success)
        {
          $style = $m.Groups[1].Value.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
          | ForEach-Object { ([AnsiStyle]$_) }
          $style = @() + $style
          $text = $m.Groups[2].Value
          
          $last = [AnsiText]::new("$text").AddStyle($style)
          $null = $this.List.Add($last)
        }
        # 
        else
        {
          $last.Text += "`e[$i"
        }
      }
    }
    return $this
  }

  [AnsiTextList] AddText([AnsiText]$Text)
  {
    if($null -ne $Text)
    {
      $null = $this.List.Add($Text)
    }
    return $this
  }

  [AnsiTextList] AddText([AnsiTextList] $Text)
  {
    if($null -ne $Text)
    {
      $this.List.AddRange($Text.List)
    }
    return $this
  }

  [AnsiTextList] AddStyle([AnsiStyle[]]$Style)
  {
    foreach ($i in $this.List)
    {
      $null = $i.AddStyle($Style)
    }
    return $this
  }

  [string] ToString()
  {
    return $this.List 
    | ForEach-Object {"$_"}
    | Join-String -Separator ""
  }

  [string] ToRawString()
  {
    return $this.List
    | ForEach-Object { $_.ToRawString() }
    | Join-String -Separator ""
  }
}


<#
  .SYNOPSIS
  为文本添加 ansi style
  
  .EXAMPLE
  Add-AnsiStyle "hello" -Style bgBlue,fgRed,bold,italic,blink

  .EXAMPLE
  "hello" | Add-AnsiStyle -Style underline

  .EXAMPLE
  "hello" | Add-AnsiStyle -Style underline | Add-AnsiStyle -Style reset
#>
function Add-AnsiStyle
{
  [OutputType([AnsiTextList])]
  param(
    # 文本，可来自 pipeline
    [Parameter(Mandatory,ValueFromPipeline)]
    [psobject]$Text,
   
    # 文本 ansi style
    [Parameter(Mandatory)]
    [AnsiStyle[]]$Style
  )

  if($Text -is [string])
  {
    return [AnsiTextList]::new().AddText($Text).AddStyle($Style)
  } elseif($Text -is [AnsiText])
  {
    return [AnsiTextList]::new().AddText(
      ([AnsiText]$Text).AddStyle($Style)
    )
  } elseif($Text -is [AnsiTextList])
  {
    return ([AnsiTextList]$Text).AddStyle($Style)
  } else
  {
    throw "ArgumentTypeError: Text($Text) is not a type in (string or AnsiText or AnsiTextList)"
  }
}
