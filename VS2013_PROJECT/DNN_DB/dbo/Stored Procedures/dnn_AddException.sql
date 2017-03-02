CREATE PROCEDURE [dbo].[dnn_AddException]
	@ExceptionHash varchar(100),
	@Message nvarchar(500),
	@StackTrace nvarchar(max),
	@InnerMessage nvarchar(500),
	@InnerStackTrace nvarchar(max),
	@Source nvarchar(500)
AS

IF NOT EXISTS (SELECT * FROM dbo.[dnn_Exceptions] WHERE ExceptionHash=@ExceptionHash)
INSERT INTO dbo.[dnn_Exceptions]
	(ExceptionHash,
	Message,
	StackTrace,
	InnerMessage,
	InnerStackTrace,
	Source)
VALUES
	(@ExceptionHash,
	@Message,
	@StackTrace,
	@InnerMessage,
	@InnerStackTrace,
	@Source)

