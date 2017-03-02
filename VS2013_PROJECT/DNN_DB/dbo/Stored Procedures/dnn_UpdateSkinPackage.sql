CREATE PROCEDURE [dbo].[dnn_UpdateSkinPackage]
	@SkinPackageID  int,
	@PackageID      int,
	@PortalID       int,
	@SkinName       nvarchar(50),
	@SkinType       nvarchar(20),
	@LastModifiedByUserID	int
AS
	UPDATE dbo.dnn_SkinPackages
		SET
			PackageID = @PackageID,
			PortalID = @PortalID,
			SkinName = @SkinName,
			SkinType = @SkinType,
 			[LastModifiedByUserID] = @LastModifiedByUserID,	
			[LastModifiedOnDate] = getdate()
	WHERE SkinPackageID = @SkinPackageID

