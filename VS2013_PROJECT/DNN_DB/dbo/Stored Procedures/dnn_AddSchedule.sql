CREATE PROCEDURE [dbo].[dnn_AddSchedule]
	@TypeFullName varchar(200)
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
	,@CreatedByUserID	int
	,@FriendlyName varchar(200)
	,@ScheduleStartDate datetime
AS
	INSERT INTO  dbo.dnn_Schedule(
		 TypeFullName
		,TimeLapse
		,TimeLapseMeasurement
		,RetryTimeLapse
		,RetryTimeLapseMeasurement
		,RetainHistoryNum
		,AttachToEvent
		,CatchUpEnabled
		,Enabled
		,ObjectDependencies
		,Servers
		,FriendlyName
		,[CreatedByUserID]
		,[CreatedOnDate]
		,[LastModifiedByUserID]
		,[LastModifiedOnDate]
		,ScheduleStartDate
		)
	VALUES
		(@TypeFullName
		,@TimeLapse
		,@TimeLapseMeasurement
		,@RetryTimeLapse
		,@RetryTimeLapseMeasurement
		,@RetainHistoryNum
		,@AttachToEvent
		,@CatchUpEnabled
		,@Enabled
		,@ObjectDependencies
		,@Servers
		,@FriendlyName
		,@CreatedByUserID
		,getdate()
		,@CreatedByUserID
		,getdate()
		,@ScheduleStartDate
		)
		select SCOPE_IDENTITY()

