CREATE PROCEDURE [dbo].[dnn_Mobile_GetPreviewProfiles] @PortalId INT
AS 
    SELECT  Id, PortalId, Name, Width, Height, UserAgent, SortOrder, CreatedByUserID, CreatedOnDate, LastModifiedByUserID, LastModifiedOnDate
    FROM    dbo.dnn_Mobile_PreviewProfiles
    WHERE   PortalId = @PortalId
	ORDER BY SortOrder ASC

