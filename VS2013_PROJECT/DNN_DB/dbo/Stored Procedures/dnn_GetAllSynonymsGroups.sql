CREATE PROCEDURE [dbo].[dnn_GetAllSynonymsGroups]
	@PortalID int,
	@CultureCode nvarchar(50)
AS
BEGIN
	SELECT   
	  [SynonymsGroupID],  
	  [SynonymsTags],  
	  [PortalID],
	  [CreatedByUserID],  
	  [CreatedOnDate],  
	  [LastModifiedByUserID],  
	  [LastModifiedOnDate]
	FROM dbo.dnn_SynonymsGroups 
	WHERE [PortalID] = @PortalID
	AND [CultureCode] = @CultureCode
	ORDER BY LastModifiedOnDate DESC
END

