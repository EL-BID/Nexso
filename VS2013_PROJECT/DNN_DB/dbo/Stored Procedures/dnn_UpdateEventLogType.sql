CREATE PROCEDURE [dbo].[dnn_UpdateEventLogType]
	@LogTypeKey nvarchar(35),
	@LogTypeFriendlyName nvarchar(50),
	@LogTypeDescription nvarchar(128),
	@LogTypeOwner nvarchar(100),
	@LogTypeCSSClass nvarchar(40)
AS
UPDATE dbo.dnn_EventLogTypes
	SET LogTypeFriendlyName = @LogTypeFriendlyName,
	LogTypeDescription = @LogTypeDescription,
	LogTypeOwner = @LogTypeOwner,
	LogTypeCSSClass = @LogTypeCSSClass
WHERE	LogTypeKey = @LogTypeKey

