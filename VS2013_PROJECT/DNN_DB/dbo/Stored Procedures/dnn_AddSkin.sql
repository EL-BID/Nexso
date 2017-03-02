CREATE PROCEDURE [dbo].[dnn_AddSkin]
	@SkinPackageID		int,
    @SkinSrc			nvarchar(200)		
AS
	BEGIN
		IF NOT EXISTS (
			SELECT 1 FROM dbo.dnn_Skins S
				WHERE S.SkinPackageID = @SkinPackageID AND S.SkinSrc = @SkinSrc
			)
			BEGIN
				INSERT INTO dbo.dnn_Skins (SkinPackageID, SkinSrc)
				VALUES (@SkinPackageID, @SkinSrc)
			END
	END
	
	SELECT SkinID FROM dbo.dnn_Skins S
		WHERE S.SkinPackageID = @SkinPackageID AND S.SkinSrc = @SkinSrc

