CREATE PROCEDURE [dbo].[dnn_Mobile_DeleteRedirectionRule] @Id INT
AS 
    DELETE  FROM dbo.dnn_Mobile_RedirectionRules
    WHERE   Id = @id

