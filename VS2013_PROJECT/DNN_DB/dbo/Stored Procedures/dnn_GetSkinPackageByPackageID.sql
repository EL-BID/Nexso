CREATE PROCEDURE [dbo].[dnn_GetSkinPackageByPackageID]
	@PackageID int	
AS
BEGIN
 SELECT SP.*
  FROM  dbo.dnn_SkinPackages SP
  WHERE SP.PackageID = @PackageID

 SELECT I.*
  FROM  dbo.dnn_Skins I
 INNER JOIN dbo.dnn_SkinPackages S ON S.SkinPackageID = I.SkinPackageID
 WHERE S.PackageID = @PackageID
END

