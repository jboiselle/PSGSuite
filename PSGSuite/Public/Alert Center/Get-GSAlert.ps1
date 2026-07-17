function Get-GSAlert {
    <#
    .SYNOPSIS
    Gets a specific alert or the list of alerts from the Google Alert Center

    .DESCRIPTION
    Gets a specific alert or the list of alerts from the Google Alert Center.

    When listing, only the first page of alerts (up to -PageSize) is returned by default, since the Alert Center can hold a very large number of alerts. A warning is displayed if more alerts are available; use -All to retrieve every alert, -Limit to set a maximum, or -Filter to narrow the results.

    The Alert Center API is currently a v1beta1 API. Using it requires both of the following on the service account:
    1. The Google Workspace Alert Center API enabled in the service account's Google Cloud project
    2. The 'https://www.googleapis.com/auth/apps.alerts' scope granted in the Admin console's domain-wide delegation settings

    .PARAMETER AlertId
    The unique Id of the alert(s) you would like to retrieve info for.

    If excluded, returns the list of alerts.

    .PARAMETER Filter
    A query string for filtering alert results, e.g. 'createTime >= "2026-07-01T00:00:00Z" AND type = "Suspicious login"'.

    Supported filter fields include createTime, startTime, endTime, type and source. See https://developers.google.com/workspace/admin/alertcenter/guides/query-filters for the supported syntax.

    .PARAMETER OrderBy
    The sort order of the list results, e.g. "createTime desc". If not specified, results may be returned in an arbitrary order.

    .PARAMETER PageSize
    Page size of the result set

    .PARAMETER Limit
    The maximum amount of results you want returned. Exclude or set to 0 to return the first page of results (see -All to return everything)

    .PARAMETER All
    If passed, returns all alerts instead of only the first page

    .EXAMPLE
    Get-GSAlert

    Gets the first page of alerts (up to -PageSize) from the Alert Center, warning if more alerts are available

    .EXAMPLE
    Get-GSAlert -All

    Gets the full list of alerts from the Alert Center

    .EXAMPLE
    Get-GSAlert -Filter 'type = "Suspicious login"' -OrderBy 'createTime desc' -Limit 10

    Gets the 10 most recent suspicious login alerts

    .EXAMPLE
    Get-GSAlert -AlertId '7c66e05e-b3b0-4b09-9384-0b53b1d51b23'

    Gets the alert matching the provided Id
    #>
    [OutputType('Google.Apis.AlertCenter.v1beta1.Data.Alert')]
    [cmdletbinding(DefaultParameterSetName = "List")]
    Param
    (
        [parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true,ParameterSetName = "Get")]
        [Alias('Id')]
        [String[]]
        $AlertId,
        [parameter(Mandatory = $false,ParameterSetName = "List")]
        [Alias('Q','Query')]
        [String]
        $Filter,
        [parameter(Mandatory = $false,ParameterSetName = "List")]
        [String]
        $OrderBy,
        [parameter(Mandatory = $false,ParameterSetName = "List")]
        [ValidateRange(1,1000)]
        [Alias("MaxResults")]
        [Int]
        $PageSize = 100,
        [parameter(Mandatory = $false,ParameterSetName = "List")]
        [Alias('First')]
        [Int]
        $Limit = 0,
        [parameter(Mandatory = $false,ParameterSetName = "List")]
        [Switch]
        $All
    )
    Begin {
        $serviceParams = @{
            Scope       = 'https://www.googleapis.com/auth/apps.alerts'
            ServiceType = 'Google.Apis.AlertCenter.v1beta1.AlertCenterService'
        }
        $service = New-GoogleService @serviceParams
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            Get {
                foreach ($alert in $AlertId) {
                    try {
                        Write-Verbose "Getting Alert '$alert'"
                        $request = $service.Alerts.Get($alert)
                        $request.Execute()
                    }
                    catch {
                        if ($ErrorActionPreference -eq 'Stop') {
                            $PSCmdlet.ThrowTerminatingError($_)
                        }
                        else {
                            Write-Error $_
                        }
                    }
                }
            }
            List {
                try {
                    Write-Verbose "Getting Alert List"
                    $request = $service.Alerts.List()
                    if ($PSBoundParameters.ContainsKey('Filter')) {
                        $request.Filter = $Filter
                    }
                    if ($PSBoundParameters.ContainsKey('OrderBy')) {
                        $request.OrderBy = $OrderBy
                    }
                    $firstPageOnly = $false
                    if (-not $All -and $Limit -eq 0) {
                        Write-Verbose "Returning the first page of results only. Use -All to retrieve all alerts."
                        $Limit = $PageSize
                        $firstPageOnly = $true
                    }
                    if ($Limit -gt 0 -and $PageSize -gt $Limit) {
                        Write-Verbose ("Reducing PageSize from {0} to {1} to meet limit with first page" -f $PageSize,$Limit)
                        $PageSize = $Limit
                    }
                    $request.PageSize = $PageSize
                    [int]$i = 1
                    $overLimit = $false
                    do {
                        $result = $request.Execute()
                        if ($result.Alerts) {
                            $result.Alerts
                        }
                        $request.PageToken = $result.NextPageToken
                        [int]$retrieved = ($i + $result.Alerts.Count) - 1
                        Write-Verbose "Retrieved $retrieved alerts..."
                        if ($Limit -gt 0 -and $retrieved -eq $Limit) {
                            Write-Verbose "Limit reached: $Limit"
                            $overLimit = $true
                        }
                        elseif ($Limit -gt 0 -and ($retrieved + $PageSize) -gt $Limit) {
                            $newPS = $Limit - $retrieved
                            Write-Verbose ("Reducing PageSize from {0} to {1} to meet limit with next page" -f $PageSize,$newPS)
                            $request.PageSize = $newPS
                        }
                        [int]$i = $i + $result.Alerts.Count
                    }
                    until ($overLimit -or !$result.NextPageToken)
                    if ($firstPageOnly -and $result.NextPageToken) {
                        Write-Warning "More alerts are available than were returned. Use -All to retrieve all alerts, -Limit to specify a maximum amount, or -Filter to narrow down the results."
                    }
                }
                catch {
                    if ($ErrorActionPreference -eq 'Stop') {
                        $PSCmdlet.ThrowTerminatingError($_)
                    }
                    else {
                        Write-Error $_
                    }
                }
            }
        }
    }
}
