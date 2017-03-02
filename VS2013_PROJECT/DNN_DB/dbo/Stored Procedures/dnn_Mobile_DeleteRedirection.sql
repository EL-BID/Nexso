CREATE PROCEDURE [dbo].[dnn_Mobile_DeleteRedirection] @Id INT
AS 
    DELETE  FROM dbo.dnn_Mobile_RedirectionRules
    WHERE   RedirectionId = @id
		
    DELETE  FROM dbo.dnn_Mobile_Redirections
    WHERE   Id = @Id

