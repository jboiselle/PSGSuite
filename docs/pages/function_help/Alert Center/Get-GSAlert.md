# Get-GSAlert

## SYNOPSIS
Gets a specific alert or the list of alerts from the Google Alert Center

## SYNTAX

### List (Default)
```
Get-GSAlert [-Filter <String>] [-OrderBy <String>] [-PageSize <Int32>] [-Limit <Int32>] [-All]
 [<CommonParameters>]
```

### Get
```
Get-GSAlert [-AlertId] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Gets a specific alert or the list of alerts from the Google Alert Center.

When listing, only the first page of alerts (up to -PageSize) is returned by default, since the Alert Center can hold a very large number of alerts.
A warning is displayed if more alerts are available; use -All to retrieve every alert, -Limit to set a maximum, or -Filter to narrow the results.

The Alert Center API is currently a v1beta1 API.
Using it requires both of the following on the service account:
1. The Google Workspace Alert Center API enabled in the service account's Google Cloud project
2. The 'https://www.googleapis.com/auth/apps.alerts' scope granted in the Admin console's domain-wide delegation settings

## EXAMPLES

### EXAMPLE 1
```
Get-GSAlert
```

Gets the first page of alerts (up to -PageSize) from the Alert Center, warning if more alerts are available

### EXAMPLE 2
```
Get-GSAlert -All
```

Gets the full list of alerts from the Alert Center

### EXAMPLE 3
```
Get-GSAlert -Filter 'type = "Suspicious login"' -OrderBy 'createTime desc' -Limit 10
```

Gets the 10 most recent suspicious login alerts

### EXAMPLE 4
```
Get-GSAlert -AlertId '7c66e05e-b3b0-4b09-9384-0b53b1d51b23'
```

Gets the alert matching the provided Id

## PARAMETERS

### -AlertId
The unique Id of the alert(s) you would like to retrieve info for.

If excluded, returns the list of alerts.

```yaml
Type: String[]
Parameter Sets: Get
Aliases: Id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -All
If passed, returns all alerts instead of only the first page

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
A query string for filtering alert results, e.g.
'createTime >= "2026-07-01T00:00:00Z" AND type = "Suspicious login"'.

Supported filter fields include createTime, startTime, endTime, type and source.
See https://developers.google.com/workspace/admin/alertcenter/guides/query-filters for the supported syntax.

```yaml
Type: String
Parameter Sets: List
Aliases: Q, Query

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
The maximum amount of results you want returned.
Exclude or set to 0 to return the first page of results (see -All to return everything)

```yaml
Type: Int32
Parameter Sets: List
Aliases: First

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrderBy
The sort order of the list results, e.g.
"createTime desc".
If not specified, results may be returned in an arbitrary order.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize
Page size of the result set

```yaml
Type: Int32
Parameter Sets: List
Aliases: MaxResults

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Google.Apis.AlertCenter.v1beta1.Data.Alert
## NOTES

## RELATED LINKS
