#region: Test object collections
$global:Alerts = New-Object System.Collections.ArrayList
1..5 | ForEach-Object {
    [Void]$global:Alerts.Add((New-Object 'Google.Apis.AlertCenter.v1beta1.Data.Alert' -Property @{
        AlertId    = "alert-$_"
        CustomerId = 'Cxxxxxxxxx'
        Type       = if ($_ % 2) { 'Suspicious login' } else { 'Device compromised' }
        Source     = 'Google identity'
    }))
}
#endregion

#region: Requests - These should inherit from the GoogleRequest core class
class AlertCenterAlertsListRequest : GoogleRequest {
    [String] $CustomerId
    [String] $Filter
    [String] $OrderBy
    [Int] $PageSize
    [String] $PageToken

    AlertCenterAlertsListRequest() {

    }
    [Object] Execute() {
        $results = $global:Alerts
        if ( -not [String]::IsNullOrEmpty($this.Filter)) {
            # Naive single-clause filter support for tests, e.g.: type = "Suspicious login"
            Write-Verbose "Filter: $($this.Filter.Trim())"
            $left,$right = $this.Filter.Split('=',2)
            $prop = $left.Trim()
            $value = $right.Trim().Trim('"')
            $results = $results | Where-Object {$_.$prop -eq $value}
        }
        $results = @($results)
        $startIndex = 0
        if ( -not [String]::IsNullOrEmpty($this.PageToken)) {
            $startIndex = [int]$this.PageToken
        }
        $size = if ($this.PageSize -gt 0) {
            $this.PageSize
        }
        else {
            100
        }
        $page = @($results | Select-Object -Skip $startIndex -First $size)
        $nextIndex = $startIndex + $page.Count
        $token = if ($nextIndex -lt $results.Count) {
            "$nextIndex"
        }
        else {
            $null
        }
        return ([PSCustomObject]@{
            Alerts        = $page
            NextPageToken = $token
        })
    }
}

class AlertCenterAlertsGetRequest : GoogleRequest {
    [String] $AlertId
    [String] $CustomerId

    AlertCenterAlertsGetRequest([String] $AlertId) {
        $this.AlertId = $AlertId
    }
    [Object] Execute() {
        if ($alert = $global:Alerts | Where-Object {$_.AlertId -eq $this.AlertId}) {
            return $alert
        }
        else {
            throw "Alert $($this.AlertId) not found!"
        }
    }
}
#endregion

#region: Resources
class AlertCenterAlertsResource {
    AlertCenterAlertsResource() {

    }

    [AlertCenterAlertsListRequest] List() {
        return [AlertCenterAlertsListRequest]::new()
    }

    [AlertCenterAlertsGetRequest] Get([String] $AlertId) {
        return [AlertCenterAlertsGetRequest]::new($AlertId)
    }
}
#endregion

#region: Service - This should inherit from the GoogleService core class
class AlertCenterService : GoogleService {
    [AlertCenterAlertsResource] $Alerts
    [String] $ApplicationName = $null

    AlertCenterService() {
        $this.Alerts = [AlertCenterAlertsResource]::new()
        $this.ApplicationName = $null
    }
}
#endregion

#region: New-GoogleService mock
Mock 'New-GoogleService' -ModuleName PSGSuite -ParameterFilter {$ServiceType -eq 'Google.Apis.AlertCenter.v1beta1.AlertCenterService'} -MockWith {
    Write-Verbose "Mocking New-GoogleService for ServiceType '$ServiceType' using the AlertCenterService class"
    return [AlertCenterService]::new()
}
#endregion
