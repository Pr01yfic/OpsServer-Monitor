$path = "c:\scripts\pingmonitor\pinglist.csv"
$downpath = "c:\scripts\pingmonitor\downlist.csv"
$newpath = "C:\scripts\pingmonitor\newlist.csv"
[System.Collections.ArrayList]$pinglist = import-csv $path
$log = 'c:\scripts\pingmonitor\pingmonlog.log'
$Errorcount = 0
$failed = $null



foreach ($row in $pinglist) 
  {
    $target = $row.entry
    if(!(Test-Connection -Cn $target -Count 1 -ea 0))
      {
        $today = get-date
        $body+= "[ERROR]`t Failure pinging $target at $today, will retry in 5 seconds<br/>"
                "[ERROR]`t Failure pinging $target at $today, will retry in 5 seconds" | out-file $log -append
                write-host "Retrying $target"    
        # Start-Sleep -seconds 5                                                                
        if(!(Test-Connection -Computername $target -Count 1 -ea 0))
          {
          $body+= "[ERROR]`t Retry failed, Server Monitor still unable to ping $target<br/>"
                  "[ERROR]`t Retry failed, Server Monitor still unable to ping $target" | out-file $log -append
          $errorcount+= 1
          write-host "$target is down!"
          $failed += "$target is down! </br>"
          FINDSTR /V /C:"$target"  > $newpath
          $target | out-file $downpath -Append -force
          rename-item $path "$path.old" 
          rename-item $newpath $path 
         # $target | Out-File $downpath -append
          # Import-Csv $path | where {$_.Entry -ne $target} | Export-csv $path.Replace("$target") -NoTypeInformation -Force
          
          # Import-Csv test.csv | where {$_.Publisher -ne "Microsoft P"} | Export-Csv New.csv -notypeinfo

          }
      }
        else 
       {
        write-host "$target ping test: OK"
#          $body+= "[INFO]`t Success pinging $target<br/>"
#                  "[INFO]`t Success pinging $target" | out-file $log -append   
        }
  }
  
  if ($errorcount -gt 0)
    {
      Send-MailMessage -subject "$errorcount errors" -body $failed -to itopsphones@tsvg.com -SmtpServer svff-mail-03 -from PingMonster@tsvg.com -BodyAsHtml
    }