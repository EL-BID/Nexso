CREATE PROCEDURE [dbo].[dnn_GetUserRelationshipPreference] 
	@UserID INT,
	@RelationshipID INT
AS 
    SELECT  PreferenceID,
			UserID,
			RelationshipID,            
			DefaultResponse,            
            CreatedByUserID ,
            CreatedOnDate ,
            LastModifiedByUserID ,
            LastModifiedOnDate
    FROM    dbo.dnn_UserRelationshipPreferences    
	WHERE UserID = @UserID
	  AND RelationshipID = @RelationshipID
	ORDER BY UserID ASC, RelationshipID ASC

