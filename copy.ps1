param(
    [Parameter(Mandatory, HelpMessage = "The source directory")]
    [string]$Source,
    [Parameter(Mandatory, HelpMessage = "The destination directory")]
    [string]$Destination,
    [Parameter(Mandatory, HelpMessage = "A file that contains a list of the names of every file that has been copied. Names in the list will be skipped. New files copied will be appended to the list.")]
    [string]$Copied,
    [Parameter(HelpMessage = "Filters filenames by this regular expression.")]
    [string]$PathFilter = "."
)

If (![IO.File]::Exists($Copied)) {
    [IO.File]::Create($Copied).Close();
}
$copiedList = New-Object System.Collections.Generic.HashSet[string] -ArgumentList ([StringComparer]::InvariantCultureIgnoreCase);
$copiedList.UnionWith([IO.File]::ReadAllLines($Copied));

$toCopy = Get-ChildItem -Path $Source -Recurse -File | Where-Object { !$copiedList.Contains($_.Name) -and $_.FullName -match $PathFilter };

If ($toCopy.Length -gt 0) {
    ForEach-Object -InputObject $toCopy {
        Copy-Item -Path $_.FullName -Destination $Destination;
        $copiedList.Add($_.Name);
        Add-Content $Copied -Value $_.Name;
    }
}