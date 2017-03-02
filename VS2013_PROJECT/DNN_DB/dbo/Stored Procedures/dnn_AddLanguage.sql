CREATE PROCEDURE [dbo].[dnn_AddLanguage]

	@CultureCode		    nvarchar(50),
	@CultureName            nvarchar(200),
	@FallbackCulture        nvarchar(50),
	@CreatedByUserID	int

AS
	INSERT INTO dbo.dnn_Languages (
		CultureCode,
		CultureName,
		FallbackCulture,
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	)
	VALUES (
		@CultureCode,
		@CultureName,
		@FallbackCulture,
		@CreatedByUserID,
	  	getdate(),
	  	@CreatedByUserID,
	  	getdate()
	)
	SELECT SCOPE_IDENTITY()

