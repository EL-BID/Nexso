CREATE PROCEDURE [dbo].[dnn_SearchDeletedItems_Add]
	@document nvarchar(max)
AS
BEGIN
	INSERT INTO dbo.dnn_SearchDeletedItems
		   (  document )
	VALUES ( @document )
END

