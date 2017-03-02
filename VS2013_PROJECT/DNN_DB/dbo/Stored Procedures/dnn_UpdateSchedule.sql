CREATE PROCEDURE [dbo].[dnn_UpdateSchedule]
	@ScheduleID int
	,@TypeFullName varchar(200)
	,@TimeLapse int
	,@TimeLapseMeasurement varchar(2)
	,@RetryTimeLapse int
	,@RetryTimeLapseMeasurement varchar(2)
	,@RetainHistoryNum int
	,@AttachToEvent varchar(50)
	,@CatchUpEnabled bit
	,@Enabled bit
	,@ObjectDependencies varchar(300)
	,@Servers varchar(150)
	,@LastModifiedByUserID	int
	,@FriendlyName varchar(200)
	,@ScheduleStartDate datetime
AS
UPDATE dbo.dnn_Schedule
	SET 
	TypeFullName = @TypeFullName
	,FriendlyName = @FriendlyName
	,TimeLapse = @TimeLapse
	,TimeLapseMeasurement = @TimeLapseMeasurement
	,RetryTimeLapse = @RetryTimeLapse
	,RetryTimeLapseMeasurement = @RetryTimeLapseMeasurement
	,RetainHistoryNum = @RetainHistoryNum
	,AttachToEvent = @AttachToEvent
	,CatchUpEnabled = @CatchUpEnabled
	,Enabled = @Enabled
	,ObjectDependencies = @ObjectDependencies
	,Servers = @Servers,
	[LastModifiedByUserID] = @LastModifiedByUserID,	
	[LastModifiedOnDate] = getdate(),
	ScheduleStartDate = @ScheduleStartDate
	WHERE ScheduleID = @ScheduleID

