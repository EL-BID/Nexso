CREATE PROCEDURE [dbo].[dnn_GetModulePackagesInUse]
	@PortalID INT,
	@ForHost BIT
AS

IF (@ForHost = 1)
	-- Get in use for all host pages and portal pages
	SELECT AllPackages.* FROM dbo.dnn_Packages AS AllPackages
		INNER JOIN (
			SELECT DISTINCT P.PackageID
			FROM dbo.dnn_Packages P
				INNER JOIN dbo.dnn_DesktopModules DM 
					ON P.PackageID=DM.PackageID
				INNER JOIN dbo.dnn_vw_Modules M
					ON M.DesktopModuleID=DM.DesktopModuleID
				INNER JOIN dbo.dnn_tabs T 
					ON T.TabID=M.TabID
			WHERE T.IsDeleted=0
				AND M.IsDeleted=0) AS InUsePackages
		ON AllPackages.PackageID = InUsePackages.PackageID
	ORDER BY AllPackages.FriendlyName
ELSE
	-- Get in use for portal or host only
	SELECT AllPackages.* FROM dbo.dnn_Packages AS AllPackages
		INNER JOIN (
			SELECT DISTINCT P.PackageID
			FROM dbo.dnn_Packages P
				INNER JOIN dbo.dnn_DesktopModules DM 
					ON P.PackageID=DM.PackageID
				INNER JOIN dbo.dnn_vw_Modules M
					ON M.DesktopModuleID=DM.DesktopModuleID
				INNER JOIN dbo.dnn_tabs T 
					ON T.TabID=M.TabID
			WHERE ((@PortalID IS NULL AND T.PortalID IS NULL) OR T.PortalID = @PortalID)
				AND T.IsDeleted=0
				AND M.IsDeleted=0) AS InUsePackages
		ON AllPackages.PackageID = InUsePackages.PackageID
	ORDER BY AllPackages.FriendlyName

