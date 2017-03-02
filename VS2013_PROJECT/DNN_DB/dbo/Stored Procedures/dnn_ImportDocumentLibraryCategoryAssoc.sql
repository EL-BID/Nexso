CREATE PROCEDURE [dbo].[dnn_ImportDocumentLibraryCategoryAssoc]
AS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.[dnn_dlfp_Category]') AND type in (N'U'))
	BEGIN
	SELECT     dlc.CategoryName, dbo.dnn_Files.FileId
	FROM         dbo.dnn_dlfp_Category AS dlc INNER JOIN
                      dbo.dnn_dlfp_DocumentCategoryAssoc AS dlca ON dlc.CategoryID = dlca.CategoryID INNER JOIN
                      dbo.dnn_dlfp_Document AS dld ON dlca.DocumentID = dld.ID INNER JOIN
                      dbo.dnn_Files ON dld.ID = dbo.dnn_Files.FileId
	END

