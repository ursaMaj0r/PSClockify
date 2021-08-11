Import-Module $PSScriptRoot\..\PSClockify
Describe 'Clockify Module: Integration Tests' {
    Context 'Establish Session'  -Tag 'Session' {
        BeforeAll {
            $cred = Import-Clixml -Path 'C:\temp\test-cred.xml' 
            Disconnect-Session
        }
        It 'Test Session' {
            $Output = Test-Session
            $Output | Should -Be "False" 
        }
        It 'Connect Session' {
            $Output = Connect-Session -workspaceID $cred.UserName -apiKey ($cred.Password | ConvertFrom-SecureString -AsPlainText)
            $Output | Should -Be "Success" 
        }
    }
    Context 'Clients' -Tag 'Clients' {
        BeforeAll {
            $testClient = Get-Random (Get-Client)
        }
        It 'Get all clients' -Tag 'Get' {
            $Output = Get-Client
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 3
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'Get one client by name' -Tag 'Get' {
            $Output = Get-Client -Identity $testClient.name
            $output | Should -MatchExactly $testClient
            $output | Should -HaveCount 1
        }
        It 'Get one client by id' -Tag 'Get' {
            $Output = Get-Client -Identity $testClient.id
            $output | Should -MatchExactly $testClient
            $output | Should -HaveCount 1
        }
        It 'Get detailed client information' -Tag 'Get' {
            $Output = Get-Client -OutputType Detailed
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 4
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'workspaceID'
        }
        It 'Throw error if no client is found' -Tag 'Get' {
            Get-Client -Identity "%" -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -Not -Be 0
            $err.Exception.Message | Should -Be "Client not found, please try again"
        }
        It 'Create new client' -Tag 'New' {
            $Output = New-Client -Name "pesterClient"
            $output.name | Should -MatchExactly "pesterClient"
            $output | Should -HaveCount 1
            $Output.id | Should -Match "^[0-9A-F]+$" 
            $Output.id.Length | Should -BeExactly 24 
        }
        It 'Rename client' -Tag 'Set' {
            $client = Get-Client -Identity "pesterClient"
            $Output = Set-Client -Identity "pesterClient" -Name "pesterClient_Rename"
            $output.name | Should -MatchExactly "pesterClient_Rename"
            $output | Should -HaveCount 1
            $Output.id | Should -BeExactly $client.id
        }
        It 'Archive client' -Tag 'Set' {
            $Output = Set-Client -Identity "pesterClient_Rename" -archive
            $output | Should -HaveCount 1
            $Output.archived | Should -Be True
        }
        It 'Remove client' -Tag 'Set' {
            $Output = Remove-Client -Identity "pesterClient_Rename" -Confirm:$false
            $output.name | Should -Be "pesterClient_Rename"
            $output | Should -HaveCount 1
        }
    }
    Context 'Current User' -Tag 'Users' {
        It 'Get current user' -Tag 'Get' {
            $Output = Get-CurrentUser
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 5
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'Get detailed user information' -Tag 'Get' {
            $Output = Get-CurrentUser -OutputType Detailed
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 9
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'defaultWorkspace'
        }
    }
    Context 'Projects' -Tag 'Projects' {
        BeforeAll {
            $testClient = Get-Random (Get-Client)
            $testProject = Get-Random (Get-Project)
        }
        It 'Get all projects' -Tag 'Get' {
            $Output = Get-Project
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 5
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'Get one project by name' -Tag 'Get' {
            $Output = Get-Project -Identity $testProject.name
            $output | Should -MatchExactly $testProject
            $output | Should -HaveCount 1
        }
        It 'Get one Project by id' -Tag 'Get' {
            $Output = Get-Project -Identity $testProject.id
            $output | Should -MatchExactly $testProject
            $output | Should -HaveCount 1
        }
        It 'Get detailed Project information' -Tag 'Get' {
            $Output = Get-Project -OutputType Detailed
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 15
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'public'
        }
        It 'Throw error if no project is found' -Tag 'Get' {
            Get-Project -Identity "%" -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -Not -Be 0
            $err.Exception.Message | Should -Be "Project not found, please try again"
        }
        It 'Create new project' -Tag 'New' {
            $Output = New-Project -Name "pesterProject" -client $testClient.name -color ff0000 -note "TEST-Note" 
            $output.name | Should -MatchExactly "pesterProject"
            $output | Should -HaveCount 1
            $Output.id | Should -Match "^[0-9A-F]+$" 
            $Output.id.Length | Should -BeExactly 24 
            $output.clientName | Should -Be "$($testClient.name)"
            $output.color | Should -Be "#ff0000"
            $output.note | Should -Be "TEST-Note"
        }
        It 'Rename project' -Tag 'Set' {
            Start-Sleep -Seconds 3
            $project = Get-Project -Identity "pesterProject"
            $Output = Set-Project -Identity "pesterProject" -Name "pesterProject_Rename"
            $output.name | Should -MatchExactly "pesterProject_Rename"
            $output | Should -HaveCount 1
            $Output.id | Should -BeExactly $project.id
        }
        It 'Archive project' -Tag 'Set' {
            Start-Sleep -Seconds 3
            $Output = Set-Project -Identity "pesterProject_Rename" -archive
            $output | Should -HaveCount 1
            $Output.archived | Should -Be True
        }
        It 'Remove project' -Tag 'Set' {
            $Output = Remove-Project -Identity "pesterProject_Rename" -Confirm:$false
            $output.name | Should -Be "pesterProject_Rename"
            $output | Should -HaveCount 1
        }
    }
    Context 'Tags' -Tag 'Tags' {
        BeforeAll {
            $testTag = Get-Random (Get-Tag)
        }
        It 'Get all Tags' -Tag 'Get' {
            $Output = Get-Tag
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 3
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'Get one Tag by name'  -Tag 'Get' {
            $Output = Get-Tag -Identity $testTag.name
            $output | Should -BeLike $testTag
            $output | Should -HaveCount 1
        }
        It 'Get one Tag by id' -Tag 'Get' {
            $Output = Get-Tag -Identity $testTag.id
            $output | Should -BeLike $testTag
            $output | Should -HaveCount 1
        }
        It 'Get detailed Tag information' -Tag 'Get' {
            $Output = Get-Tag -OutputType Detailed
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 4
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'workspaceId'
        }
        It 'Throw error if no tag is found' -Tag 'Error' {
            Get-Tag -Identity "%" -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -Not -Be 0
            $err.Exception.Message | Should -Be "Tag not found, please try again"
        }
        It 'Create new tag' -Tag 'New' {
            $Output = New-Tag -Name "pesterTag"
            $output.name | Should -MatchExactly "pesterTag"
            $output | Should -HaveCount 1
            $Output.id | Should -Match "^[0-9A-F]+$" 
            $Output.id.Length | Should -BeExactly 24 
        }
        It 'Rename tag' -Tag 'Set' {
            $tag = Get-Tag -Identity "pesterTag"
            $Output = Set-Tag -Identity "pesterTag" -Name "pesterTag_Rename"
            $output.name | Should -MatchExactly "pesterTag_Rename"
            $output | Should -HaveCount 1
            $Output.id | Should -BeExactly $tag.id
        }
        It 'Archive tag' -Tag 'Set' {
            $Output = Set-Tag -Identity "pesterTag_Rename" -archive
            $output | Should -HaveCount 1
            $Output.archived | Should -Be True
        }
        It 'Remove tag' -Tag 'Remove' {
            $Output = Remove-Tag -Identity "pesterTag_Rename" -Confirm:$false
            $output.name | Should -Be "pesterTag_Rename"
            $output | Should -HaveCount 1
        }
    }
    Context 'Tasks' -Tag 'Tasks' {
        BeforeAll {
            $testProject = Get-Random (Get-Project)
            $newProject = New-Project -Name "taskProject"
            $testTask = Get-Random (Get-Task -Project $testProject.name)
        }
        It 'Get all Tasks for a Project by name' -Tag 'Get' {
            $Output = Get-Task -Project $testProject.name
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 4
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'Get one Task by name' -Tag 'Get' {
            $Output = Get-Task -Identity $testTask.name -Project $testProject.name
            $output | Should -MatchExactly $testTask
            $output | Should -HaveCount 1
        }
        It 'Get one Task by id' -Tag 'Get' {
            $testTask = Get-Random (Get-Task -Project $testProject.name)
            $Output = Get-Task -Identity $testTask.id -Project $testProject.name
            $output | Should -MatchExactly $testTask
            $output | Should -HaveCount 1
        }
        It 'Get detailed Task information' -Tag 'Get' {
            $Output = Get-Task -OutputType Detailed -Project $testProject.name
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 8
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'projectId'
        }
        It 'Throw error if no task is found' -Tag 'Get' {
            Get-Task -Identity "%" -Project $testProject.name -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -Not -Be 0
            $err.Exception.Message | Should -Be "Task not found, please try again"
        }
        It 'Create new task' -Tag 'New' {
            $Output = New-Task -Name "pesterTask" -Project "taskProject"
            $output.name | Should -MatchExactly "pesterTask"
            $output | Should -HaveCount 1
            $Output.id | Should -Match "^[0-9A-F]+$" 
            $Output.id.Length | Should -BeExactly 24 
        }
        It 'Rename task' -Tag 'Set' {
            $task = Get-Task -Identity "pesterTask" -Project "taskProject"
            $Output = Set-Task -Identity "pesterTask" -Name "pesterTask_Rename" -Project "taskProject"
            $output.name | Should -MatchExactly "pesterTask_Rename"
            $output | Should -HaveCount 1
            $Output.id | Should -BeExactly $task.id
        }
        It 'mark task done' -Tag 'Set' {
            $Output = Set-Task -Identity "pesterTask_Rename" -Status DONE -Project "taskProject"
            $output | Should -HaveCount 1
            $Output.status | Should -Be "DONE"
        }
        It 'Remove task' -Tag 'Set' {
            $Output = Remove-Task -Identity "pesterTask_Rename" -Project "taskProject" -Confirm:$false
            $output.name | Should -Be "pesterTask_Rename"
            $output | Should -HaveCount 1
        }
        AfterAll {
            Remove-Project -Identity  "taskProject" -Confirm:$false
        }
    }
    Context 'Workspaces' -Tag 'Workspaces' {
        BeforeAll {
            $testWorkspace = Get-Random (Get-Workspace)
        }
        It 'Get all Workspaces' -Tag 'Get' {
            $Output = Get-Workspace
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 3
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'Get one Workspace by id' -Tag 'Get' {
            $Output = Get-Workspace -Identity $testWorkspace.id
            $output | Should -MatchExactly $testWorkspace
            $output | Should -HaveCount 1
        }
        It 'Get detailed Workspace information' -Tag 'Get' {
            $Output = Get-Workspace -OutputType Detailed
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 7
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'workspaceSettings'
        }
    }
    Context 'Workspace Users' -Tag 'Users' {
        BeforeAll {
            $testWorkspaceUser = Get-WorkspaceUser | Select-Object -First 1
        }
        It 'Get all Workspace Users' -Tag 'Get' {
            $Output = Get-WorkspaceUser
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 5
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'Get one Workspace User by id' -Tag 'Get' {
            $Output = Get-WorkspaceUser -Identity $testWorkspaceUser.id
            $output | Should -MatchExactly $testWorkspaceUser
            $output | Should -HaveCount 1
        }
        It 'Get detailed Workspace information' -Tag 'Get' {
            $Output = Get-WorkspaceUser -OutputType Detailed
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 9
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'defaultWorkspace'
        }
    }
    Context 'Time Entries' -Tag 'TimeEntries' {
        BeforeAll {
            $testTimeEntry = Get-Random (Get-TimeEntry)
            $testUser = Get-CurrentUser
        }
        It 'Get all time entries' -Tag 'Get' {
            $Output = Get-TimeEntry
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 5
            $Output[0].id | Should -Match "^[0-9A-F]+$" 
            $Output[0].id.Length | Should -BeExactly 24 
        }
        It 'specify result size of 25' -Tag 'Get' {
            $Output = Get-TimeEntry -ResultSize 25
            $output | Should -HaveCount 25
        }
        It 'Get time entry by description' -Tag 'Get' {
            $Output = Get-TimeEntry -description $testTimeEntry.description
            $output[0].description | Should -Contain $testTimeEntry.description
        }
        It 'Get one time entry by id' -Tag 'Get' {
            $Output = Get-TimeEntry -Identity $testTimeEntry.id
            $output.id | Should -Be $testTimeEntry.id
            $output | Should -HaveCount 1
        }
        It 'Get one time entry by user' -Tag 'Get' {
            $Output = Get-TimeEntry -OutputType Detailed -ResultSize 5 -User $testUser.id
            $output.userId | Select-Object -Unique | Should -Be $testUser.id
        }
        It 'Get detailed time entry information' -Tag 'Get' {
            $Output = Get-TimeEntry -OutputType Detailed
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 11
            ($output | Get-Member -MemberType NoteProperty).Name | Should -Contain 'customFieldValues'
        }
        It 'get current timer' -Tag 'Get' {
            $timer = Start-Timer
            $Output = Get-TimeEntry -inProgress
            $Output.id | Should -Be $timer.id
            Remove-Timer
        }
    }
    Context 'Starting Timer'-Tag 'Timer', 'Start' {
        BeforeAll {
            $testTag = Get-Random (Get-Tag)
            $testProject = Get-Random (Get-Project)
            $testTask = Get-Random (Get-Task -Project $testProject.name)
            $Output = Start-Timer `
                -description "TEST-Description" `
                -Tags $testTag.name `
                -project $testProject.name `
                -task $testTask.name `
                -billable
        }
        It 'create time entry' {
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 11
            $Output.id | Should -Match "^[0-9A-F]+$" 
            $Output.id.Length | Should -BeExactly 24 
        }
        It 'start time is within 10 seconds of current time' {
            $delta = New-TimeSpan -Start (Get-Date).ToUniversalTime() -End $output.timeInterval.Start
            $delta.TotalSeconds | Should -BeLessThan 10
        }
        It 'set custom description' {
            $Output.description | Should -Be "TEST-Description" 
        }
        It 'set custom project' {
            $Output.projectId | Should -Be $testProject.id
        }
        It 'set custom task' {
            $Output.taskId | Should -Be $testTask.id
        }
        It 'set custom tag' {
            $Output.tagIds | Should -BeLike $testTag.id 
        }
        It 'set billable' {
            $Output.billable | Should -Be $true
        }
        AfterAll {
            Remove-Timer
        }
    }
    Context 'Updating Timer' -Tag 'Timer' {
        BeforeAll {
            $testTag = Get-Random (Get-Tag) -Count 2
            $testProject = Get-Random (Get-Project)
            $testTask = Get-Random (Get-Task -Project $testProject.name)
            $timer = Start-Timer 
        }
        It 'set custom description' {
            $Output = Set-Timer -Identity $timer.id -description "TEST-Description"
            $Output.description | Should -Be "TEST-Description" 
        }
        It 'append custom description' {
            $Output = Set-Timer -Identity $timer.id -description "TEST-Description" -append
            $Output.description | Should -Be "TEST-Description + TEST-Description" 
        }
        It 'set custom project' {
            $Output = Set-Timer -Identity $timer.id -project $testProject.id
            $Output.projectId | Should -Be $testProject.id
        }
        It 'set custom task' {
            $Output = Set-Timer -Identity $timer.id -project $testProject.id -task $testTask.id
            $Output.taskId | Should -Be $testTask.id
        }
        It 'set custom tag' {
            $Output = Set-Timer -Identity $timer.id -Tags $testTag.id
            $Output.tagIds | Should -Be $testTag.id 
        }
        It 'set billable' {
            $Output = Set-Timer -Identity $timer.id -billable
            $Output.billable | Should -Be $true
        }
        It 'restart timer' {
            $Output = Set-Timer -Identity $timer.id -restartTimer
            $Output.timeInterval.end | Should -BeNullOrEmpty
        }
        AfterAll {
            Remove-Timer
        }
    }   
    Context 'Stopping Timer'-Tag 'Timer', 'Stop' {
        BeforeAll {
            $timer = Start-Timer
            $Output = Stop-Timer
        }
        It 'stop time entry' {
            $output | Get-Member -MemberType NoteProperty | Should -HaveCount 11
            $Output.id | Should -Match "^[0-9A-F]+$" 
            $Output.id.Length | Should -BeExactly 24 
        }
        It 'end time is within 10 seconds of current time' {
            $delta = New-TimeSpan -Start (Get-Date).ToUniversalTime() -End $output.timeInterval.End
            $delta.TotalSeconds | Should -BeLessThan 10
        }
        AfterAll {
            Remove-Timer -Identity $timer.id
        }
    }
}