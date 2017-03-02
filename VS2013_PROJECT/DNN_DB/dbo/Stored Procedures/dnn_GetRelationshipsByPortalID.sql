CREATE PROCEDURE [dbo].[dnn_GetRelationshipsByPortalID] @PortalID INT
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
	WHERE PortalID = @PortalID AND UserID IS NULL
	ORDER BY RelationshipID ASC

