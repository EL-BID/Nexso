CREATE PROCEDURE [dbo].[dnn_UpdateScheduleHistory]
@ScheduleHistoryID int,
@EndDate datetime,
@Succeeded bit,
@LogNotes ntext,
@NextStart datetime
AS
UPDATE dbo.dnn_ScheduleHistory
SET	EndDate = @EndDate,
	Succeeded = @Succeeded,
	LogNotes = @LogNotes,
	NextStart = @NextStart
WHERE ScheduleHistoryID = @ScheduleHistoryID

