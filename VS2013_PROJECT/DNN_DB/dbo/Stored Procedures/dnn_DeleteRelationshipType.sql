CREATE PROCEDURE [dbo].[dnn_DeleteRelationshipType] @RelationshipTypeID INT	
AS 
	BEGIN
		DELETE FROM dbo.dnn_RelationshipTypes  
			WHERE RelationshipTypeID = @RelationshipTypeID
	END

