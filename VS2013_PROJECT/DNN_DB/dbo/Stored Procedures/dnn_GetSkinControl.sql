CREATE PROCEDURE [dbo].[dnn_GetSkinControl]
	@SkinControlID	int
AS
    SELECT *
    FROM   dbo.dnn_SkinControls
	WHERE SkinControlID = @SkinControlID

