CREATE PROCEDURE [dbo].[dnn_DeleteSkinPackage]

	@SkinPackageID		int

AS
    DELETE
	    FROM	dbo.dnn_SkinPackages
	WHERE   SkinPackageID = @SkinPackageID

