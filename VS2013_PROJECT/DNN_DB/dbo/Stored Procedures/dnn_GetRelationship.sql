CREATE PROCEDURE [dbo].[dnn_GetRelationship] @RelationshipID INT
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
	WHERE RelationshipID = @RelationshipID
	ORDER BY RelationshipID ASC

