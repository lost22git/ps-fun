
$MSVC_HOME = (vswhere -products "Microsoft.VisualStudio.Product.BuildTools" -latest -property "installationPath")
Import-Module "$MSVC_HOME\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"

# @see $MSVC_HOME\Common7\Tools\vsdevcmd\core\parse_cmd.bat

enum HostArch
{
  x86
  amd64
}
enum TargetArch
{
  x86
  amd64
  arm
  arm64
}
enum AppPlatform
{
  Desktop
  UWP
}

<#
  .SYNOPSIS
  进入 MSVC dev shell 环境
  
  .EXAMPLE
  Enter-Msvc

  .EXAMPLE
  Enter-Msvc -TargetArch arm64 -HostArch amd64 -AppPlatform UWP
#>
function Enter-Msvc
{
  param(
    # 目标架构 默认 amd64
    [Parameter()]
    [TargetArch]$TargetArch = [TargetArch]::amd64,

    # 本地架构 默认 amd64
    [Parameter()]
    [HostArch]$HostArch = [HostArch]::amd64,

    # App Platform, 默认 Desktop
    [Parameter()]
    [AppPlatform]$AppPlatform = [AppPlatform]::Desktop
  )
 
  $devCmdArgs = "-arch=$TargetArch -host_arch=$HostArch -app_platform=$AppPlatform"
 
  Enter-VsDevShell -InstallPath $MSVC_HOME -SkipAutomaticLocation -DevCmdArguments $devCmdArgs
}
