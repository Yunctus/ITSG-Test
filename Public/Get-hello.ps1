function Get-Hello {
    [CmdletBinding()]
    param(
        [string]$Name = "Janek"
    )

    "Hello $Name"
}
