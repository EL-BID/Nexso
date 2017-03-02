-- new function to determine, whether a user may view content of another users property,
-- if extended permissions (per social group or relationship) are specified
CREATE FUNCTION [dbo].[dnn_FitsExtendedPropertyPermission](
    @viewingUserId 		 Int,
    @viewedUserID 		 Int,
    @extendedPermissions nVarChar(2000)
) 
	RETURNS 			 Bit
AS
	BEGIN
		DECLARE @rolesStr    nVarChar(2000) = ''
		DECLARE @reltnStr    nVarChar(2000) = ''
		DECLARE @gStartPos   Int
		DECLARE @rStartPos   Int
		DECLARE @recCount    Int = 0
		DECLARE @SQL         Int
		If (@viewedUserID > 0 and Len(IsNull(@extendedPermissions,'')) > 2) BEGIN
			SET @gStartPos = CHARINDEX('G:',@extendedPermissions) + 2
			SET @rStartPos = CHARINDEX('R:',@extendedPermissions) + 2
			if @gStartPos > @rStartPos BEGIN
				SET @rolesStr = SUBSTRING(@extendedPermissions, @gStartPos, Len(@extendedPermissions) - @gStartPos)
				if @rStartPos > 0 SET @reltnStr = SUBSTRING(@extendedPermissions, @rStartPos, @gStartPos - @rStartPos - 1)
			END
			If @gStartPos < @rStartPos BEGIN
				SET @reltnStr = SUBSTRING(@extendedPermissions, @rStartPos, Len(@extendedPermissions) - @rStartPos)
				if @gStartPos > 0 SET @rolesStr = SUBSTRING(@extendedPermissions, @gStartPos, @rStartPos - @gStartPos - 1)
			END
			If @rolesStr <> '' BEGIN
				SET @rolesStr = ',' + SUBSTRING(@rolesStr,1, Len(@rolesStr) - CASE WHEN RIGHT(@RolesStr,1) = ';' THEN 1 ELSE 0 END)
				SELECT @recCount = COUNT(1) FROM dbo.[dnn_UserRoles] WHERE UserID = @viewingUserId AND @rolesStr LIKE '%,' + Convert(nVarChar(10),RoleId) + ',%'
			END
			If @recCount = 0 AND @reltnStr <> '' BEGIN
				SET @reltnStr = ',' + SUBSTRING(@reltnStr,1, Len(@reltnStr) - CASE WHEN RIGHT(@reltnStr,1) = ';' THEN 1 ELSE 0 END)
				SELECT @recCount = COUNT(1) FROM dbo.[dnn_vw_RelatedUsers] WHERE UserID = @viewingUserId AND relatedUserID = @viewedUserId AND @reltnStr LIKE '%,' + Convert(nVarChar(10),RelationShipID) + ',%' AND Status = 2
			END
		END
		RETURN CASE WHEN IsNull(@RecCount, 0) > 0 THEN 1 ELSE 0 END
	END

