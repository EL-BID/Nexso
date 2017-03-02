CREATE PROCEDURE [dbo].[dnn_UpdateSkin]

	@SkinID   int,
	@SkinSrc  nvarchar(200)

AS
	UPDATE dbo.dnn_Skins
		SET
			SkinSrc = @SkinSrc
	WHERE SkinID = @SkinID

