function Get-Hello {
    [CmdletBinding()]
    param(
        [string]$Name = "Kama"
    )

    "Hello $Name"
}
