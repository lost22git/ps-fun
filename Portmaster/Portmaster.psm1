
function Pm-Restart
{
  <#
    .SYNOPSIS
    [Portmaster] Restart
  #>
  param()

  $req = @{
    Method = 'POST'
    Uri = 'http://localhost:817/api/v1/core/restart'
  }
  Invoke-RestMethod @req
}

function Pm-Shutdown
{
  <#
    .SYNOPSIS
    [Portmaster] Shutdown
  #>

  param()

  $req = @{
    Method = 'POST'
    Uri = 'http://localhost:817/api/v1/core/shutdown'
  }
  Invoke-RestMethod @req
}


function Pm-DnsClear
{
  <#
    .SYNOPSIS
   [Portmaster] Clear dns cache
  #>

  param()

  $req = @{
    Method = 'POST'
    Uri = 'http://localhost:817/api/v1/dns/clear'
  }
  Invoke-RestMethod @req
}

function Pm-DnsServers
{
  <#
    .SYNOPSIS
    [Portmaster] List DNS servers
  #>

  param()

  $req = @{
    Method = 'GET'
    Uri = 'http://localhost:817/api/v1/dns/resolvers'
  }
  Invoke-RestMethod @req
}

function Pm-DnsCache
{
  <#
    .SYNOPSIS
    [Portmaster] DNS query from cache
  #>

  param(
    # 待查询域名
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Domain
  )

  $req = @{
    Method = 'GET'
    Uri = "http://localhost:817/api/v1/dns/cache/${Domain}.A"
  }
  Invoke-RestMethod @req
}
