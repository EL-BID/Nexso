CREATE PROCEDURE [dbo].[dnn_GetUserRelationship] @UserRelationshipID INT
AS 
    SELECT  UserRelationshipID,
			UserID,
			RelatedUserID,
			RelationshipID,            
			Status,            
            CreatedByUserID ,
            CreatedOnDate ,
            LastModifiedByUserID ,
            LastModifiedOnDate
    FROM    dbo.dnn_UserRelationships    
	WHERE UserRelationshipID = @UserRelationshipID
	ORDER BY UserRelationshipID ASC

