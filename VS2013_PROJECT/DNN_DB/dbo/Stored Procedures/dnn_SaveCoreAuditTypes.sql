CREATE PROCEDURE [dbo].[dnn_SaveCoreAuditTypes]
	@LogTypeKey nvarchar(35),  
	@LogTypeFriendlyName nvarchar(50),  
	@LogTypeOwner nvarchar(100),  
	@LogTypeCSSClass nvarchar(40) ,
	@LoggingIsActive bit,  
	@KeepMostRecent int,  
	@EmailNotificationIsActive bit  

AS  
 IF NOT EXISTS (SELECT * FROM dbo.dnn_EventLogTypes WHERE LogTypeKey = @LogTypeKey)  
	BEGIN  
		-- Add new Event Type  
		EXEC dbo.dnn_AddEventLogType @LogTypeKey, @LogTypeFriendlyName, N'', @LogTypeOwner, @LogTypeCSSClass  

		-- Add new Event Type Config  
		EXEC dbo.dnn_AddEventLogConfig @LogTypeKey, NULL, @LoggingIsActive, @KeepMostRecent, @EmailNotificationIsActive, 1, 1, 1, N'', N''  
		  
		-- exit  
		Return
	END
  ELSE

		UPDATE dbo.dnn_EventLogTypes SET LogTypeFriendlyName = @LogTypeFriendlyName WHERE LogTypeKey = @LogTypeKey  

		UPDATE dbo.dnn_EventLogConfig
		SET LoggingIsActive=@LoggingIsActive,
		KeepMostRecent=@KeepMostRecent,
		EmailNotificationIsActive=@EmailNotificationIsActive
		WHERE LogTypeKey = @LogTypeKey

