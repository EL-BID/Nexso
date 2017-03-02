CREATE PROCEDURE [dbo].[dnn_GetUserRelationships]
	@UserID INT
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
	WHERE UserID = @UserID OR RelatedUserID = @UserID

