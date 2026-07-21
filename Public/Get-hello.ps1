function Get-Hello {
    [CmdletBinding()]
    param(
        [string]$Name = "Wojtas"
    )

    "Hello $Name"
}
