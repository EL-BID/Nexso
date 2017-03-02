CREATE PROCEDURE [dbo].[dnn_GetSkinControlByPackageID]
	@PackageID	int
AS
    SELECT *
    FROM   dbo.dnn_SkinControls
	WHERE PackageID = @PackageID

