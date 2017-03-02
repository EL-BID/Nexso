CREATE PROCEDURE [dbo].[dnn_Mobile_GetRedirections] @PortalId INT
AS 
    SELECT  Id ,
            PortalId ,
            Name ,
            [Type] ,
            SortOrder ,
            SourceTabId ,
			IncludeChildTabs ,
            TargetType ,
            TargetValue ,
			Enabled ,
            CreatedByUserID ,
            CreatedOnDate ,
            LastModifiedByUserID ,
            LastModifiedOnDate
    FROM    dbo.dnn_Mobile_Redirections
    WHERE   PortalId = @PortalId
	ORDER BY SortOrder ASC

