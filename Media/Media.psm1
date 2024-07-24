Import-Module -Name Pick

function yd
{
  <#
    .SYNOPSIS
    youtube 视频下载 & 字幕下载 & 字幕烧录
    依赖组件：
      1. yt-dlp [https://github.com/yt-dlp/yt-dlp] or `scoop install yt-dlp`
      2. handbrakecli [https://github.com/HandBrake/HandBrake] or `scoop install handbrake-cli`

    .EXAMPLE
    yd -Uri https://www.youtube.com/watch?v=dQw4w9WgXcQ

    .EXAMPLE
    yd -Proxy http://localhost:55555 -Uri https://www.youtube.com/watch?v=dQw4w9WgXcQ

    .EXAMPLE
    yd -Uri https://www.youtube.com/watch?v=dQw4w9WgXcQ -Interactive
  #>

  param(
    # Uri
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Uri,

    # Proxy 代理服务器
    [Parameter()]
    [string]$Proxy = "http://127.0.0.1:55556",

    [Parameter()]
    [switch]$Interactive
  )

  $ErrorActionPreference = "Stop"
  $down_sub = $true
  $down_video = $true

  if ($Interactive)
  {
    $features = @('下载字幕', '下载视频')
    $selected_features = $features | Pick -m -fzf -title "请选择 Features: "
    if (-not ($selected_features -contains '下载字幕'))
    {
      $down_sub = $false
    }
    if (-not ($selected_features -contains '下载视频'))
    {
      $down_video = $false
    }
  }

  if ($down_sub)
  {
    "============================================================"
    "`e[1m字幕下载...`e[m"
    "------------------------------------------------------------"
    $url = $Uri
    $downsubUri = "https://downsub.com?url=$url"
    "字幕下载页 uri = $downsubUri"
    $content = Invoke-WebRequest -Proxy $Proxy -Uri $downsubUri | Select-Object -ExpandProperty Content
    $contextValue = [regex]::new("context\s*=\s*'(\S+?)'").Matches($content).Groups[1].Value
    $contextValueDecoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($contextValue))
    $contextObj = ConvertFrom-Json -InputObject $contextValueDecoded
    "字幕下载页解析 contextObj = $contextObj"
    $url = $contextObj.id
    $getInfoUri = "https://get-info.downsub.com/$url"
    "字幕下载列表 uri = $getInfoUri"
    $content = Invoke-WebRequest -Proxy $Proxy -Uri $getInfoUri | Select-Object -ExpandProperty Content
    $contentObj = ConvertFrom-Json -InputObject $content
    $title = $contentObj.title
    "------------------------------------------------------------"
    "> 字幕下载列表: 【$title】"
    $contentObj.subtitles | Format-Table -AutoSize
    $url = ""
    $name = "English" 
    if ($Interactive)
    {
      $url = $contentObj.subtitles | Pick -fzf -title "请选择字幕：" | Select-Object -ExpandProperty url -First 1
    } else
    {
      "> 默认选择 $name"
      $url = $contentObj.subtitles | Where-Object { $_.name.StartsWith($name) -and $_.url -ne "" } | Select-Object -ExpandProperty url -First 1
    }
    $downUri = "https://subtitle.downsub.com?title=$title&url=$url"
    "字幕[$name]下载 uri = $downUri"
    $subtitleFile = ".\" + ("$title.srt".Split([IO.Path]::GetInvalidFileNameChars()) -join "_")
    Invoke-WebRequest -Proxy $Proxy -Uri $downUri -OutFile $subtitleFile
    "字幕下载完成 subtitleFile=$subtitleFile"
  }
    
  if ($down_video)
  {
    "============================================================"
    "`e[1m获取视频文件名...`e[m"
    "------------------------------------------------------------"
    $videoFilename = (yt-dlp --proxy $Proxy --merge-output-format mp4 --windows-filenames -o "%(title)s#%(id)s.%(ext)s" --get-filename $Uri)
    "获取视频文件名: $videoFilename"
    $videoFile = ".\$videoFilename"

    "============================================================"
    "`e[1m视频下载...`e[m"
    "------------------------------------------------------------"
    yt-dlp --proxy $Proxy -f 'bv+ba/b'--merge-output-format mp4 -i $Uri -v --windows-filenames -o "%(title)s#%(id)s.%(ext)s" --external-downloader aria2c --external-downloader-args "--file-allocation=prealloc -j 16 -x 16 -k 1M"
    "视频下载完成"
  }
  if ($down_sub -and $down_video)
  {
    "============================================================"
    "`e[1m烧录字幕...`e[m"
    "------------------------------------------------------------"
    $outFile = "$videoFile.withSubtitle.mp4"
    handbrakecli.exe -e nvenc_h265 -2 -T --srt-burn --srt-codeset "UTF-8" --srt-file "$subtitleFile" -i "$videoFile" -o "$outFile"
    "烧录字幕完成"

    Write-Host "> 删除原始视频和字幕文件 (Y/N): " -ForegroundColor Yellow -NoNewline
    $toDel = Read-Host 
    if ($toDel -ne "Y" -and $toDel -ne "y")
    {
      return
    }
  
    "============================================================"
    "`e[1m删除原始视频文件 $videoFile`n字幕文件 $subtitleFile ...`e[m"
    "------------------------------------------------------------"
    Remove-Item "$videoFile"
    Remove-Item "$subtitleFile"
    "删除完成"
  }
}


function Out-Image
{
  <#
    .SYNOPSIS
    使用 silicon 生成代码图片

    .EXAMPLE
    Get-Content 1.js | Out-Image -Title "Code Snippet" -Lang js -LineNumber -Font consolas -Theme OneHalfDark -OutFile 1.jpg
  #>

  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline,Mandatory)]
    [PSObject]$Content,

    [Parameter()]
    [string]$Lang="sh",
    
    [Parameter()]
    [string]$OutFile,

    [Parameter()]
    [switch]$LineNumber,

    [Parameter()]
    [ArgumentCompleter(
      {
        param ( $commandName,
          $parameterName,
          $wordToComplete,
          $commandAst,
          $fakeBoundParameters )
        $res = silicon.exe --list-fonts 
        | Where-Object { $_.ToLower().StartsWith("$wordToComplete".ToLower()) } 
        | ForEach-Object { $_.Contains(" ") ? "'$_'" : $_ }
        return $null -ne $res ? $res : @($wordToComplete)
      } 
    )]
    [string]$Font="IntoneMono Nerd Font",

    [Parameter()]
    [ArgumentCompleter(
      {
        param ( $commandName,
          $parameterName,
          $wordToComplete,
          $commandAst,
          $fakeBoundParameters )
        $res = silicon.exe --list-themes 
        | Where-Object { $_.ToLower().StartsWith("$wordToComplete".ToLower()) } 
        | ForEach-Object { $_.Contains(" ") ? "'$_'" : $_ }
        return $null -ne $res ? $res : @($wordToComplete)
      } 
    )]
    [string]$Theme="OneHalfDark",

    [Parameter()]
    [string]$Title = ""
  )


  begin
  {
    $contentList = [System.Collections.Generic.List[string]]::new()
  }
  process
  {
    $contentList.Add($Content)
  }
  end
  {
    $ErrorActionPreference = "Stop"

    $tmpFile = Join-Path -Path $env:TEMP -ChildPath (New-Guid)

    Write-Verbose "Temp file: $tmpFile"
    Write-Verbose "Out file: $OutFile"

    $contentList | Out-String | Set-Content -Path $tmpFile

    if($LineNumber)
    {
      silicon.exe -l $Lang -f $Font --theme $Theme --window-title $Title -o $OutFile $tmpFile 2>&1 | Out-Null
    } else
    {
      silicon.exe -l $Lang -f $Font --theme $Theme --window-title $Title --no-line-number -o $OutFile $tmpFile 2>&1 | Out-Null
    }

    Remove-Item $tmpFile
  }
}

function Play
{
  [CmdletBinding(DefaultParameterSetName = 'mpv')]
  param(
    # 播放地址
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Uri,

    # Http Header
    [Parameter(ParameterSetName="mpv")]
    [string[]]$Header,

    # 代理地址
    [string]$Proxy,

    # On Top
    [switch]$Ontop,

    # 音量
    [Parameter(ParameterSetName="mpv")]
    [ValidateRange(0, 100)]
    [int]$Volume = 0,

    # 宽高，位置  格式：[W[xH]][+-x+-y][/WS] (only for mpv)
    [Parameter(ParameterSetName="mpv")]
    [string]$Geometry,
 
    [Parameter(ParameterSetName="vlc")]
    [switch]$Vlc,

    # zoom (only for vlc)
    [Parameter(ParameterSetName="vlc")]
    [float]$Zoom=0.5
  )

  # mpv
  switch ($PSCmdlet.ParameterSetName)
  {
    'mpv'
    { 
      $headers_args = ""
      if ($null -ne $Header)
      {
        foreach ($h in $Header)
        {
          $headers_args = $headers_args + " --http-header-fields-add=`"$h`""
        }
      }

      $mpv_args = "--no-border --snap-window $headers_args `"$Uri`""

      if ($null -ne $Proxy)
      {
        $mpv_args = "--http-proxy=$Proxy $mpv_args"
      }

      if ($Ontop)
      {
        $mpv_args = "--ontop $mpv_args"
      }

      if ($null -ne $Geometry)
      {
        $mpv_args = "--geometry=$Geometry $mpv_args"
      }

      $mpv_args = "--volume=$Volume $mpv_args"

      Write-Host "Executing command: ``mpv.exe $mpv_args``" -ForegroundColor Yellow
      Start-Process "mpv.exe" -ArgumentList "$mpv_args" -WindowStyle Hidden
    }
    'vlc'
    {
      $vlc_args = " `"$Uri`"";
      if ($null -ne $Proxy)
      {
        $vlc_args = "--http-proxy=$Proxy $vlc_args"
      }
      if ($Ontop)
      {
        $vlc_args = "--video-on-top $vlc_args"
      }
      $vlc_args = "--zoom=$Zoom $vlc_args"
      Write-Host "Executing command: ``vlc.exe $vlc_args``" -ForegroundColor Yellow
      Start-Process "vlc.exe" -ArgumentList "$vlc_args" -WindowStyle Hidden
    }
    Default
    {
    }
  }
}

function Play-List
{
  <#
    .SYNOPSIS
    Play list of video in tiling windows
  #>

  param(
    # video uri
    [Parameter(ValueFromPipeline)]
    [string]$Uri,
    # Column count
    [Parameter()]
    [int]$Columns = 2,
    # Row count
    [Parameter()]
    [int]$Rows = 2
  )
  
  begin
  {
    $playlist = [System.Collections.Generic.List[string]]::new()
  }
  process
  {
    if(-not [string]::IsNullOrWhiteSpace($Uri))
    {
      $playlist.Add($Uri)
    }
  }
  end
  {
    $total_count = $playlist.Count

    # video windows column count and row count
    $col_count = $Columns # respect argument $Cols whatever $count <= ($Cols*$Rows)
    $row_count = [int][System.Math]::Ceiling($total_count / $col_count)

    # video window width and heigh
    $width = 100 / $col_count
    $heigh = 100 / $row_count
    $width = [int][System.Math]::Floor($width)
    $heigh = [int][System.Math]::Floor($heigh)

    # play args
    $play_args = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $total_count; $i++)
    {
      $row = [int][System.Math]::Floor($i / $col_count)
      $col = $i % $col_count
      $x = $col_count -gt 1 ? $col * 100 / ($col_count - 1) : 0
      $y = $row_count -gt 1 ? $row * 100 / ($row_count - 1) : 0
      $x = [int][System.Math]::Floor($x)
      $y = [int][System.Math]::Floor($y)

      $play_args.Add(@{
          uri =  $playlist[$i]
          width = $width
          heigh = $heigh
          x = $x
          y = $y
          geometry = "$width%x$heigh%+$x%+$y%/$total_count" 
        })
    }

    # play them
    $play_args | ForEach-Object {
      play -Uri $_.uri -Geometry $_.geometry -Volume 0
    }
  }
}
