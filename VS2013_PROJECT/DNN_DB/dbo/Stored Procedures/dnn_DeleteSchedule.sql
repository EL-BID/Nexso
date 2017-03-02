CREATE PROCEDURE [dbo].[dnn_DeleteSchedule]
@ScheduleID int
AS
DELETE FROM dbo.dnn_Schedule
WHERE ScheduleID = @ScheduleID

