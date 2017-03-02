CREATE PROCEDURE [dbo].[dnn_Mobile_GetRedirectionRules] @RedirectionId INT
AS 
    SELECT  Id ,
            RedirectionId ,
            Capability ,
            Expression
    FROM    dnn_Mobile_RedirectionRules
    WHERE RedirectionId = @RedirectionId

