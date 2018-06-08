
Add-Type -TypeDefinition @"
  public enum VersionListMergeMode
  {
    SourceFirst,
    TargetFirst
  }
"@

function Get-VersionListModuleShortcut([string] $part)
{
    $index = $part.IndexOfAny("0123456789");
    if ($index -ge 1) {
      $result = @{'shortcut' = $part.Substring(0,$index);'version' = $part.Substring($index)};
    }
    return $result;
}

function Get-VersionListHash([string] $versionlist)
{
  $hash = @{}
  $versionlistarray=$versionlist.Split(",");
  foreach ($element in $versionlistarray) {
    $moduleinfo = Get-VersionListModuleShortcut($element);
    $hash.Add($moduleinfo.shortcut,$moduleinfo.version);
  }
  return $hash;
}

function Merge-NAVVersionListString([string] $source,[string] $target,[VersionListMergeMode] $mode=[VersionListMergeMode]::SourceFirst) 
{
  if ($mode -eq [VersionListMergeMode]::TargetFirst) {
    $temp = $source;
    $source = $target;
    $target = $temp;
  }
  $result = "";
  $sourcearray=$source.Split(",");
  $targetarray=$target.Split(",");
  $sourcehash=Get-VersionListHash($source);
  $targethash=Get-VersionListHash($target);
  foreach ($module in $sourcearray) {
    $actualversion = "";
    $moduleinfo = Get-VersionListModuleShortcut($module);
    if ($sourcehash[$moduleinfo.shortcut] -ge $targethash[$moduleinfo.shortcut]) {
      $actualversion = $sourcehash[$moduleinfo.shortcut];
    } else {
      $actualversion = $targethash[$moduleinfo.shortcut];
    }
    if ($result.Length -gt 0) {
      $result = $result + ",";
    }
    $result = $result + $moduleinfo.shortcut + $actualversion;
  }
  foreach ($module in $targetarray) {
    $moduleinfo = Get-VersionListModuleShortcut($module);
    if (!$sourcehash.ContainsKey($moduleinfo.shortcut)) {
        if ($result.Length -gt 0) {
          $result = $result + ",";
        }
        $result = $result + $module;
    }
  }
  return $result;
}

#Merge-NAVVersionListString -source "NAVW17.10,NVR7.20.0001,AAAA8.55.666,KSC8.300" -target "NAVW17.10,NVR7.20.0003,NEW7.33.0000,KSC8.200" -mode TargetFirst
