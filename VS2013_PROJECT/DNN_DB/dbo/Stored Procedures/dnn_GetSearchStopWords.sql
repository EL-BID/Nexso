CREATE PROCEDURE [dbo].[dnn_GetSearchStopWords]
	@PortalID int,
	@CultureCode nvarchar(50)
AS
BEGIN
	SELECT   
	  [StopWordsID],  
	  [StopWords],  
	  [CreatedByUserID],  
	  [CreatedOnDate],  
	  [LastModifiedByUserID],  
	  [LastModifiedOnDate],
	  [PortalID],
	  [CultureCode]
	FROM dbo.dnn_SearchStopWords 
	WHERE [PortalID] = @PortalID AND [CultureCode] = @CultureCode
END

