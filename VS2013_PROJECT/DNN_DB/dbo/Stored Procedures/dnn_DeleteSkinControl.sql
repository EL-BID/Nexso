CREATE PROCEDURE [dbo].[dnn_DeleteSkinControl]
	@SkinControlId int
AS
    DELETE
    FROM   dbo.dnn_SkinControls
    WHERE  SkinControlId = @SkinControlId

