CREATE PROCEDURE [dbo].[dnn_AddEventLogType]
	@LogTypeKey nvarchar(35),
	@LogTypeFriendlyName nvarchar(50),
	@LogTypeDescription nvarchar(128),
	@LogTypeOwner nvarchar(100),
	@LogTypeCSSClass nvarchar(40)
AS
	INSERT INTO dbo.dnn_EventLogTypes
	(LogTypeKey,
	LogTypeFriendlyName,
	LogTypeDescription,
	LogTypeOwner,
	LogTypeCSSClass)
VALUES
	(@LogTypeKey,
	@LogTypeFriendlyName,
	@LogTypeDescription,
	@LogTypeOwner,
	@LogTypeCSSClass)

