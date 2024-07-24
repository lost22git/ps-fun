function New-Uuidv7
{
  <#
    .SYNOPSIS
    new uuidv7

    .EXAMPLE
    New-Uuidv7 -Raw

    .EXAMPLE
    New-Uuidv7
  #>

  param(
    # Output raw bytes?
    [switch]$Raw
  )

  # random bytes
  $value = [byte[]]::new(16)
  [System.Random]::new().NextBytes($value)

  # current timestamp
  $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
  [System.BitConverter]::GetBytes($timestamp)[5..0].Copyto($value, 0)

  # version and variant
  $value[6] = ($value[6] -band 0x0F) -bor 0x70
  $value[8] = ($value[8] -band 0x0F) -bor 0x80

  if($Raw)
  {
    $value
  } else
  {
    $value | Format-HexString
  }
}

function Format-HexString
{

  <#
    .SYNOPSIS
    Format byte array as hex string (simple version of `Format-Hex`)
  #>
  
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [byte]$Data,

    [Parameter()]
    [String]$Sep=""
  )

  begin
  {
    $hex = [System.Collections.Generic.List[string]]::new()
  }
  process
  {
    $hex.Add([BitConverter]::ToString($Data))
  }
  end
  {
    $hex -join $Sep
  }
}

