CREATE PROCEDURE [dbo].[dnn_DeleteRelationship] @RelationshipID INT	
AS 
	BEGIN
		DELETE FROM dbo.dnn_Relationships  
			WHERE RelationshipID = @RelationshipID
	END

