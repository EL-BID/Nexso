CREATE PROCEDURE [dbo].[dnn_AddSkinPackage]
	@PackageID  int,
	@PortalID   int,
	@SkinName   nvarchar(50),
	@SkinType   nvarchar(20),
	@CreatedByUserID	int
AS
	INSERT INTO dbo.dnn_SkinPackages (
	  PackageID,
	  PortalID,
	  SkinName,
	  SkinType,
	[CreatedByUserID],
	[CreatedOnDate],
	[LastModifiedByUserID],
	[LastModifiedOnDate]
	)
	VALUES (
	  @PackageID,
	  @PortalID,
	  @SkinName,
	  @SkinType,
	  @CreatedByUserID,
	  getdate(),
	  @CreatedByUserID,
	  getdate()
	)
	SELECT SCOPE_IDENTITY()

