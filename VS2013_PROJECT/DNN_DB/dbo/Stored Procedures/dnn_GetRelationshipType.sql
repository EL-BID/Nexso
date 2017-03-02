CREATE PROCEDURE [dbo].[dnn_GetRelationshipType] @RelationshipTypeID INT
AS 
    SELECT  RelationshipTypeID,
            Direction,
            Name ,            
            Description,
            CreatedByUserID ,
            CreatedOnDate ,
            LastModifiedByUserID ,
            LastModifiedOnDate
    FROM    dbo.dnn_RelationshipTypes    
	WHERE RelationshipTypeID = @RelationshipTypeID
	ORDER BY RelationshipTypeID ASC

