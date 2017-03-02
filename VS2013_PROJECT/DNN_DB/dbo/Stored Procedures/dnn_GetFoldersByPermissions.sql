CREATE PROCEDURE [dbo].[dnn_GetFoldersByPermissions] 
	@PortalID int,
	@Permissions nvarchar(300),
	@UserID int,
	@FolderID int,
	@FolderPath nvarchar(300)

AS
	DECLARE @IsSuperUser BIT
	DECLARE @Admin BIT
	DECLARE @Read INT
	DECLARE @Write INT
	DECLARE @Browse INT
	DECLARE @Add INT

	--Determine Admin or SuperUser
	IF @UserId IN (
		SELECT UserId 
		FROM dbo.[dnn_UserRoles] 
		WHERE RoleId IN (
			SELECT RoleId 
			FROM dbo.[dnn_Roles] 
			WHERE PortalId = @PortalId 
			AND RoleName = 'Administrators')) 
	BEGIN 
		SET @Admin = 1 
	END;
	
	SELECT @IsSuperUser = IsSuperUser 
	FROM dbo.[dnn_Users] 
	WHERE UserId = @UserId;

	--Retrieve Permission Ids
	IF @Permissions LIKE '%READ%' BEGIN SELECT TOP 1 @Read = PermissionID FROM dbo.[dnn_Permission] WHERE PermissionCode = 'SYSTEM_FOLDER' AND PermissionKey = 'READ' END;
	IF @Permissions LIKE '%WRITE%' BEGIN SELECT TOP 1 @Write = PermissionID FROM dbo.[dnn_Permission] WHERE PermissionCode = 'SYSTEM_FOLDER' AND PermissionKey = 'WRITE' END;
	IF @Permissions LIKE '%BROWSE%' BEGIN SELECT TOP 1 @Browse = PermissionID FROM dbo.[dnn_Permission] WHERE PermissionCode = 'SYSTEM_FOLDER' AND PermissionKey = 'BROWSE' END;
	IF @Permissions LIKE '%ADD%' BEGIN SELECT TOP 1 @Add = PermissionID FROM dbo.[dnn_Permission] WHERE PermissionCode = 'SYSTEM_FOLDER' AND PermissionKey = 'ADD' END;

	IF @PortalID IS NULL
		BEGIN
			SELECT DISTINCT F.*
			FROM dbo.[dnn_Folders] F
			WHERE F.PortalID IS NULL
				AND (F.FolderID = @FolderID OR @FolderID = -1)
				AND (F.FolderPath = @FolderPath OR @FolderPath = '')
		  
			 ORDER BY F.FolderPath
		END
	ELSE
		BEGIN
			CREATE TABLE #Skip_Folders(folderid INT PRIMARY KEY(folderid))
			INSERT INTO #Skip_Folders
				 SELECT DISTINCT folderid FROM dbo.[dnn_FolderPermission] FP
									JOIN dbo.[dnn_Permission] P ON FP.PermissionID = P.PermissionID
									WHERE
										((P.PermissionKey = 'WRITE' OR @IsSuperUser=1 OR @Admin=1) OR
										FP.PermissionID = CASE WHEN @Read > 0 THEN @Read END OR
										FP.PermissionID = CASE WHEN @Write > 0 THEN @Write END OR
										FP.PermissionID = CASE WHEN @Browse > 0 THEN @Browse END OR
										FP.PermissionID = CASE WHEN @Add > 0 THEN @Add END)
										AND FP.FolderID NOT IN (SELECT DISTINCT folderid FROM dbo.[dnn_FolderPermission] WHERE allowaccess=0 AND (userid=@UserId OR roleid=-1 OR roleid IN (SELECT roleid FROM dbo.[dnn_UserRoles] WHERE UserID=@UserId)))		

			SELECT DISTINCT F.*
			FROM dbo.[dnn_Folders] F
				JOIN dbo.[dnn_FolderPermission] FP ON F.FolderId = FP.FolderID
				JOIN dbo.[dnn_Permission] P ON FP.PermissionID = P.PermissionID
				JOIN #Skip_Folders sf ON sf.folderid=f.folderid 
			WHERE ((F.PortalID = @PortalID) OR (F.PortalID IS NULL AND @PortalID IS NULL))
				AND (F.FolderID = @FolderID OR @FolderID = -1)
				AND (F.FolderPath = @FolderPath OR @FolderPath = '')
				AND 
					((P.PermissionKey = 'WRITE' OR @IsSuperUser=1 OR @Admin=1) OR
						FP.PermissionID = CASE WHEN @Read > 0 THEN @Read END OR
						FP.PermissionID = CASE WHEN @Write > 0 THEN @Write END OR
						FP.PermissionID = CASE WHEN @Browse > 0 THEN @Browse END OR
						FP.PermissionID = CASE WHEN @Add > 0 THEN @Add END)
				AND FP.AllowAccess = 1
			 ORDER BY F.FolderPath

			 DROP TABLE #Skip_Folders
		END

