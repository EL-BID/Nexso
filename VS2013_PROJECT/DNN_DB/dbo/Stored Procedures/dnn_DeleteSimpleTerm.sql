CREATE PROCEDURE [dbo].[dnn_DeleteSimpleTerm] 
	@TermId			int
AS
	DELETE FROM dbo.dnn_Taxonomy_Terms
	WHERE TermID = @TermID

