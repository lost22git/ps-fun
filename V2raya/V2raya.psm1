function Va-ServiceStart
{
  <#
    .SYNOPSIS
    [V2raya] 启动服务
  #>

  Write-Host 'V2raya service starting...'
  start-v2raya
}

function Va-ServiceStop
{
  <#
    .SYNOPSIS
    [V2raya] 关闭服务
  #>

  Write-Host 'V2raya service stopping...'
  stop-v2raya
}

function Va-ServiceRestart
{
  <#
    .SYNOPSIS
    [V2raya] 重启服务
  #>

  Va-ServiceStop

  Va-ServiceStart
}

function Va-ResetPassword
{
  <#
    .SYNOPSIS
    [V2raya] 重置密码
  #>

  v2raya --reset-password
}

function Va-Login
{
  <#
    .SYNOPSIS
    [V2raya] 登录
  #>

  param(
    [Parameter()]
    [string]$Username='lostfun',

    [Parameter()]
    [securestring]$Password=(ConvertTo-SecureString 'lostfun' -AsPlainText)
  )

  $req = @{
    Method = 'Post'
    Uri = 'http://localhost:2017/api/login'
    ContentType = 'application/json'
    Body = (
      @{
        username = $Username
        password = (ConvertFrom-SecureString -SecureString $Password -AsPlainText)
      } | ConvertTo-Json -Compress
    )
  }
  $resp = Invoke-RestMethod @req

  $token = $resp.data.token
  $env:va_api_token = $token
  $token
}

function Va-List
{
  <#
    .SYNOPSIS
    [V2raya] 查询节点列表
  #>

  param(
    [Parameter()]
    [string]$ApiToken=$env:va_api_token,

    # 查询已连接的节点
    [Parameter()]
    [switch]$Connected
  )

  $req = @{
    Method = 'Get'
    Uri = 'http://localhost:2017/api/touch' 
    Headers = @{
      Authorization = $ApiToken
    }
  }
  $resp = Invoke-RestMethod @req

  if($Connected)
  {
    $resp.data.touch.connectedServer
  } else
  {
    $resp.data.touch.servers
  }

}

function Va-Start 
{
  <#
    .SYNOPSIS
    [V2raya] 启动
  #>

  param(
    [Parameter()]
    [string]$ApiToken=$env:va_api_token
  )

  $req = @{
    Method = 'Post'
    Uri = 'http://localhost:2017/api/v2ray'
    Headers = @{
      Authorization = $ApiToken
    }
  }
  $resp = Invoke-RestMethod @req

  $resp.data
}

function Va-Stop
{
  <#
    .SYNOPSIS
    [V2raya] 关闭
  #>

  param(
    [Parameter()]
    [string]$ApiToken=$env:va_api_token
  )

  $req = @{
    Method = 'Delete'
    Uri = 'http://localhost:2017/api/v2ray'
    Headers = @{
      Authorization = $ApiToken
    }
  }
  $resp = Invoke-RestMethod @req

  $resp.data
}

function Va-Ping 
{
  <#
    .SYNOPSIS
    [V2raya] 批量 ping 节点
  #>

  param(
    # 节点列表，如果为空则选择全部节点
    [Parameter(ValueFromPipeline)]
    [pscustomobject]$Server,

    [Parameter()]
    [string]$ApiToken=$env:va_api_token
  )

  begin
  {
    $server_list = [System.Collections.Generic.List[object]]::new()
  }

  process
  {
    if($null -ne $Server)
    {
      $server_list.Add($Server)    
    }
  }
  
  end
  {
    if ($server_list.Count -le 0)
    {
      $server_list = (Va-List -ApiToken $ApiToken)
    }
    $server_list_json = ($server_list | ConvertTo-Json -Compress)

    $req = @{
      Method = 'Get' 
      Uri = "http://localhost:2017/api/pingLatency?whiches=$server_list_json"
      Headers = @{
        Authorization = $ApiToken
      } 
    }
    $resp = Invoke-RestMethod @req
  
    $resp.data.whiches | 
      ForEach-Object {
        $sortBy = [Int32]::MaxValue 
        if (-not [Int32]::TryParse($_.pingLatency.Substring(0, $_.pingLatency.Length-2), [ref]$sortBy))
        {
          $sortBy = [Int32]::MaxValue 
        }
        $_ | Add-Member -MemberType NoteProperty -Name 'sortBy' -Value $sortBy
        $_
      } | 
      Sort-Object sortBy
  }
}

function Va-Connect 
{
  <#
    .SYNOPSIS
    [V2raya] 批量连接节点
  #>

  param(
    # 节点列表，如果为空则选择延迟最小的3个节点
    [Parameter(ValueFromPipeline)]
    [pscustomobject]$Server,

    [Parameter()]
    [string]$ApiToken=$env:va_api_token
  )

  begin
  {
    $server_list = [System.Collections.Generic.List[object]]::new()
  }

  process
  {
    if($null -ne $Server)
    {
      $server_list.Add($Server)
    }
  }

  end
  {
    $to_connect_list = if($server_list.Count -le 0)
    {
      (Va-Ping -ApiToken $ApiToken | Where-Object sortBy -lt 2000 | Select-Object -First 3)
    } else
    {
      $server_list      
    }
    $to_disconnect_list = (Va-List -Connected -ApiToken $ApiToken) 

    Write-Debug "To connect list($($to_connect_list.Count)): $($to_connect_list | ConvertTo-Json -Compress)"
    Write-Debug "To disconnect list($($to_disconnect_list.Count)): $($to_disconnect_list | ConvertTo-Json -Compress)"

    $to_disconnect_list | ForEach-Object {
      $req = @{
        Method = 'Delete'
        Uri = 'http://localhost:2017/api/connection'
        Headers = @{
          Authorization = $ApiToken
        }
        ContentType = 'application/json'
        Body = ($_ | ConvertTo-Json -Compress)
      }
      $null = Invoke-RestMethod @req
    }

    $to_connect_list | ForEach-Object {
      $req = @{
        Method = 'Post'
        Uri = 'http://localhost:2017/api/connection'
        Headers = @{
          Authorization = $ApiToken
        }
        ContentType = 'application/json'
        Body = ($_ | ConvertTo-Json -Compress)
      }
      $null = Invoke-RestMethod @req
    }

    Va-Start -ApiToken $ApiToken
  }
}

function Va-Clear
{
  <#
    .SYNOPSIS
    [V2raya] 清空所有节点
  #>

  param(
    [Parameter()]
    [string]$ApiToken=$env:va_api_token
  )

  $server_list = (Va-List -ApiToken $ApiToken)

  $req = @{
    Method = 'Delete'
    Uri = 'http://localhost:2017/api/touch'
    Headers = @{
      Authorization = $ApiToken
    }
    ContentType = 'application/json'
    Body =  (@{touches = $server_list} | ConvertTo-Json -Compress)
  }
  $resp = Invoke-RestMethod @req
  $resp
}

function Va-Import
{
  <#
    .SYNOPSIS
    [V2raya] 批量导入节点
  #>

  param(
    # 一行一个节点链接, 如果为空，则从系统剪贴板获取
    [Parameter()]
    [string]$url = '',

    [Parameter()]
    [string]$ApiToken=$env:va_api_token
  )

  if([string]::IsNullOrWhiteSpace($url))
  {
    $url = (Get-Clipboard)
  }

  $req = @{
    Method = 'Post'
    Uri = 'http://localhost:2017/api/import'
    Headers = @{
      Authorization = $ApiToken
    }
    ContentType = 'application/json'
    Body = (@{url = $url} | ConvertTo-Json -Compress)
  }
  $resp = Invoke-RestMethod @req
  $resp
}
