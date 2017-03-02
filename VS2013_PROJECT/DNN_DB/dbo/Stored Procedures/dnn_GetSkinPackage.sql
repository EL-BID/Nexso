CREATE PROCEDURE [dbo].[dnn_GetSkinPackage]
	@PortalID   int,
	@SkinName   nvarchar(50),
	@SkinType   nvarchar(50)

AS
	SELECT *
		FROM  dbo.dnn_SkinPackages
		WHERE (PortalID = @PortalID OR @PortalID IS NULL Or PortalID IS Null)
			AND SkinName = @SkinName
			AND SkinType = @SkinType

