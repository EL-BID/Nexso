CREATE PROCEDURE [dbo].[dnn_UpdateSynonymsGroup]
	@SynonymsGroupID		int,
	@SynonymsTags 			nvarchar(MAX),
	@LastModifiedByUserID 	int
AS
BEGIN	
	UPDATE dbo.dnn_SynonymsGroups
			SET				
				SynonymsTags = @SynonymsTags,
				LastModifiedByUserID = @LastModifiedByUserID,
				LastModifiedOnDate = GETUTCDATE()
			WHERE SynonymsGroupID = @SynonymsGroupID
END

