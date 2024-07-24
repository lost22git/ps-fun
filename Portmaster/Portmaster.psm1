function Pm-DnsClear
{
  <#
    .SYNOPSIS
    Clear dns cache
  #>

  param()

  $req = @{
    Method = 'POST'
    Uri = 'http://localhost:817/api/v1/dns/clear'
  }
  Invoke-RestMethod @req
}

function Pm-Restart
{
  <#
    .SYNOPSIS
    Restart
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
    Shutdown
  #>

  param()

  $req = @{
    Method = 'POST'
    Uri = 'http://localhost:817/api/v1/core/shutdown'
  }
  Invoke-RestMethod @req
}
