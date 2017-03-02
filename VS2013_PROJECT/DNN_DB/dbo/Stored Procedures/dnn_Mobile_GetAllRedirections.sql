CREATE PROCEDURE [dbo].[dnn_Mobile_GetAllRedirections]
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
	ORDER BY PortalId ASC, SortOrder ASC

