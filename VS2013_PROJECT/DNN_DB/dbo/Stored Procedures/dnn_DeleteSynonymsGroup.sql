CREATE PROCEDURE [dbo].[dnn_DeleteSynonymsGroup]
	@SynonymsGroupID int
AS
BEGIN	
	DELETE FROM dbo.dnn_SynonymsGroups WHERE SynonymsGroupID = @SynonymsGroupID
END

