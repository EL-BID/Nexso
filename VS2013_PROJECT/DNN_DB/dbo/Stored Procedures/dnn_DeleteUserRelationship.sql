CREATE PROCEDURE [dbo].[dnn_DeleteUserRelationship] @UserRelationshipID INT	
AS 
	BEGIN
		DELETE FROM dbo.dnn_UserRelationships  
			WHERE UserRelationshipID = @UserRelationshipID
	END

