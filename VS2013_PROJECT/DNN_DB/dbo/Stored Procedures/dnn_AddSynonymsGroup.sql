CREATE PROCEDURE [dbo].[dnn_AddSynonymsGroup]
	@SynonymsTags 			nvarchar(MAX),
	@CreatedByUserID 		int,
	@PortalID				int,
	@CultureCode            nvarchar(50)
AS
BEGIN	
	INSERT INTO dbo.[dnn_SynonymsGroups](
		[SynonymsTags],  
		[CreatedByUserID],  
		[CreatedOnDate],  
		[LastModifiedByUserID],  
		[LastModifiedOnDate],
		[PortalID],
		[CultureCode]
	) VALUES (
		@SynonymsTags,
		@CreatedByUserID,
	    GETUTCDATE(),
		@CreatedByUserID,
		GETUTCDATE(),
		@PortalID,
		@CultureCode
	)	

	SELECT SCOPE_IDENTITY()
END

