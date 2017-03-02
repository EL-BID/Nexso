CREATE PROCEDURE [dbo].[dnn_GetUserRelationshipPreferenceByID] 
	@PreferenceID INT	
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
	WHERE @PreferenceID = @PreferenceID	  
	ORDER BY PreferenceID ASC

