CREATE PROCEDURE [dbo].[dnn_InsertSearchStopWords]
	@StopWords 			nvarchar(MAX),
	@CreatedByUserID 		int,
	@PortalID				int,
	@CultureCode		nvarchar(50)
AS
BEGIN	
	INSERT INTO dbo.[dnn_SearchStopWords](
		[StopWords],  
		[CreatedByUserID],  
		[CreatedOnDate],  
		[LastModifiedByUserID],  
		[LastModifiedOnDate],
		[PortalID],
		[CultureCode]
	) VALUES (
		@StopWords,
		@CreatedByUserID,
	    GETUTCDATE(),
		@CreatedByUserID,
		GETUTCDATE(),
		@PortalID,
		@CultureCode
	)	

	SELECT SCOPE_IDENTITY()
END

