CREATE PROCEDURE [dbo].[dnn_Mobile_DeletePreviewProfile] @Id INT
AS 
		
    DELETE  FROM dbo.dnn_Mobile_PreviewProfiles
    WHERE   Id = @Id

