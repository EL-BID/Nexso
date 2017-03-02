CREATE PROCEDURE [dbo].[dnn_DeleteSkin]

	@SkinID		int

AS

DELETE
	FROM	dbo.dnn_Skins
	WHERE   SkinID = @SkinID

