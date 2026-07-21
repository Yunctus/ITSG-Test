function Get-Hello {
    [CmdletBinding()]
    param(
        [string]$Name = "Marcin"
    )

    "Hello $Name"
}