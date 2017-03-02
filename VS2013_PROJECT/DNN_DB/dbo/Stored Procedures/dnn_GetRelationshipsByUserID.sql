CREATE PROCEDURE [dbo].[dnn_GetRelationshipsByUserID] @UserID INT
AS 
    SELECT  RelationshipID,
			RelationshipTypeID,            
            Name,            
            Description,
			UserID,
			PortalID,
			DefaultResponse,
            CreatedByUserID ,
            CreatedOnDate ,
            LastModifiedByUserID ,
            LastModifiedOnDate
    FROM    dbo.dnn_Relationships    
	WHERE UserID = @UserID
	ORDER BY RelationshipID ASC

