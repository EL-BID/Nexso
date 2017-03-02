CREATE PROCEDURE [dbo].[dnn_GetAllRelationshipTypes]
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
	ORDER BY RelationshipTypeID ASC

