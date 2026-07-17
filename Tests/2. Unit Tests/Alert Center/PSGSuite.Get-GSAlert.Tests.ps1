<#
    * Unit test files should be wrapped with InModuleScope
    * Each unit test file should have the following above the Describe block(s):
        1. A call to dot-source the core mocks and classes
        2. A call to dot-source the appropriate Service mock and classes for the function being tested
#>

InModuleScope PSGSuite {

    #region: Load service and config mocks and validate mock via $null ApplicationName
    Write-Verbose "Loading Core mocks"
    . ([System.IO.Path]::Combine("$env:BHProjectPath","Tests","0. Mocks","Core.Mocks.ps1"))
    Write-Verbose "Loading AlertCenterService mock"
    . ([System.IO.Path]::Combine("$env:BHProjectPath","Tests","0. Mocks","AlertCenterService.Mocks.ps1"))
    Describe 'AlertCenterService' -Tag 'Core' {
        Context 'When a mocked AlertCenter service is created' {
            It 'ApplicationName should be $null' {
                $service = New-GoogleService -ServiceType 'Google.Apis.AlertCenter.v1beta1.AlertCenterService' -Scope 'Mock' -User 'MockUser@test.com'
                $service.ApplicationName | Should -BeNullOrEmpty
            }
        }
    }
    #endregion

    Describe 'Get-GSAlert mock tests' -Tag 'AlertCenter' {
        Context 'When Get-GSAlert lists alerts' {
            $result = Get-GSAlert
            It 'Should return the full list of alerts' {
                $result.Count | Should -Be 5
            }
            $testCase = @('alert-1','alert-2','alert-3','alert-4','alert-5') | Foreach-Object {@{item = $_}}
            It "[Full list] AlertId should contain <item>" -TestCases $testCase {
                param($item)
                $result.AlertId | Should -Contain $item
            }
            It '[Full list] AlertId should not contain "alert-99"' {
                $result.AlertId | Should -Not -Contain 'alert-99'
            }
            It 'Should page through the full list when PageSize is smaller than the result set' {
                (Get-GSAlert -PageSize 2 -All).Count | Should -Be 5
            }
        }
        Context 'When Get-GSAlert returns the first page by default' {
            It 'Should only return the first page when more results exist' {
                (Get-GSAlert -PageSize 2 -WarningAction SilentlyContinue).Count | Should -Be 2
            }
            It 'Should warn when more results exist beyond the first page' {
                $null = Get-GSAlert -PageSize 2 -WarningVariable warns -WarningAction SilentlyContinue
                $warns | Should -Not -BeNullOrEmpty
            }
            It 'Should not warn when all results fit on the first page' {
                $null = Get-GSAlert -WarningVariable warns -WarningAction SilentlyContinue
                $warns | Should -BeNullOrEmpty
            }
        }
        Context 'When Get-GSAlert lists alerts with a filter' {
            $result = Get-GSAlert -Filter 'Type = "Suspicious login"'
            It 'Should return only matching alerts' {
                $result.Count | Should -Be 3
            }
            It 'Should only contain alerts of the filtered type' {
                $result.Type | Select-Object -Unique | Should -BeExactly 'Suspicious login'
            }
        }
        Context 'When Get-GSAlert limits list results' {
            It 'Should stop at the limit when the limit spans multiple pages' {
                (Get-GSAlert -PageSize 2 -Limit 3).Count | Should -Be 3
            }
            It 'Should shrink the first page when the limit is below the page size' {
                (Get-GSAlert -Limit 2).Count | Should -Be 2
            }
        }
        Context 'When Get-GSAlert gets specific alerts' {
            $testCase = @('alert-1','alert-3','alert-5') | Foreach-Object {@{item = $_}}
            It "Should not throw when getting <item>" -TestCases $testCase {
                param($item)
                {Get-GSAlert -AlertId $item} | Should -Not -Throw
            }
            It "Should return correct AlertId when getting <item>" -TestCases $testCase {
                param($item)
                $result = Get-GSAlert -AlertId $item
                $result.AlertId | Should -BeExactly $item
            }
            It 'Should get multiple alerts by Id' {
                $result = Get-GSAlert -AlertId 'alert-1','alert-3'
                $result.Count | Should -Be 2
                $result.AlertId | Should -Contain 'alert-1'
                $result.AlertId | Should -Contain 'alert-3'
            }
            It 'Should accept AlertId from the pipeline by property name' {
                $result = [PSCustomObject]@{AlertId = 'alert-2'} | Get-GSAlert
                $result.AlertId | Should -BeExactly 'alert-2'
            }
            It 'Should throw when getting alert-99' {
                {Get-GSAlert -AlertId 'alert-99' -ErrorAction Stop} | Should -Throw -ExpectedMessage "Alert alert-99 not found!"
            }
        }
    }
}
