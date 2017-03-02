CREATE PROCEDURE [dbo].[dnn_PurgeScheduleHistory]
AS
delete from dbo.dnn_schedulehistory where schedulehistoryid in (
	select top 50000 ScheduleHistoryID from dbo.dnn_ScheduleHistory sh 
		inner join dbo.dnn_schedule s on s.ScheduleID = sh.ScheduleID and s.Enabled = 1
	where 
		(select count(*) from dbo.dnn_ScheduleHistory sh where sh.ScheduleID = s.ScheduleID) > s.RetainHistoryNum
		AND s.RetainHistoryNum <> -1
		AND s.ScheduleID = sh.ScheduleID
	order by ScheduleHistoryID
)

