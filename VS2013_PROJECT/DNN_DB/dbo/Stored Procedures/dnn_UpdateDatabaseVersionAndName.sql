create procedure [dbo].[dnn_UpdateDatabaseVersionAndName]

	@Major  int,
	@Minor  int,
	@Build  int,
	@Name	nvarchar(50)

AS

	INSERT INTO dbo.dnn_Version (
		Major,
		Minor,
		Build,
		[Name],
		CreatedDate
	)
		VALUES (
			@Major,
			@Minor,
			@Build,
			@Name,
			getdate()
		)

