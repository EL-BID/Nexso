﻿CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsSearchAllContent]
	@PortalID INT, -- current Portal
	@ModuleID INT, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID INT,
	@OrderBy NVARCHAR(20) = 'PublishDate DESC',
	@ItemsFrom INT = 1,
	@ItemsTo INT = 5,
	@ShowAllAuthors BIT = 1, -- gleda se filtriranje autora po modulu ili portalu
	@FilterByAuthor INT = 0, -- ako se selektiran jedan autor
	@FilterByGroupID INT = 0, -- ako je selektirana grupa
	@FilterByDNNUserID INT = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID INT = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@EditOnlyAsOwner BIT = 0, -- news settings
	@UserCanApprove BIT = 0, -- news settings
	@LocaleCode NVARCHAR(20) = NULL,
	@IsSocialInstance BIT = 0,
	@Perm_ViewAllCategores BIT = 0, -- permission settings View all categories
	@Perm_EditAllCategores BIT = 0, -- permission settings Edit all categories
	@AdminOrSuperUser BIT = 0,
	@CategoryFilterType TINYINT = 1, -- 0 All categories, 1 - SELECTion, 2 - AutoAdd
	@PermissionSettingsSource BIT = 1, -- 1 portal, 0 module
	@FillterSettingsSource BIT = 1, -- 1 portal, 0 module
	
	-- ODNOSI SE NA SEARCH UNUTAR SEARCH MODULA
	@OuterPermissionSource TINYINT= 0, -- 0 none, 1 portal, 2 module
	@OuterPermissionID INT = 0,
	@OuterModuleID INT = 0,
	
	@SearchType TINYINT = 3,
	@SearchCondition NVARCHAR(300),
	@SearchModulePermissions BIT = 0,
	@HideUnlocalizedItems BIT = 0,
	-- ovo je samo za evente
	@DateRangeType TINYINT = 0, -- moze biti 2 (startdate) i 0 (show all) - 1 ne moze biti jer nema pretrazivanja po from to date
	@StartDate DATETIME = NULL
AS
SET NOCOUNT ON;
SET DATEFIRST 1;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();
DECLARE @SearchTable TABLE (Words NVARCHAR(100) NOT NULL);
BEGIN
	DECLARE @word NVARCHAR(100), @PosWord INT
	SET @SearchCondition = LTRIM(RTRIM(@SearchCondition))+ ':'
	SET @PosWord = CHARINDEX(':', @SearchCondition, 1)
	IF REPLACE(@SearchCondition, ':', '') <> ''
	BEGIN
		WHILE @PosWord > 0
		BEGIN
			SET @word = LTRIM(RTRIM(LEFT(@SearchCondition, @PosWord - 1)))
			IF @word <> ''
			BEGIN
				SET @word = replace( 
							replace( 
							replace( 
							replace( @word
							,    '\', '\\' )
							,    '%', '\%' )
							,    '_', '\_' )
							,    '[', '\[' )
				INSERT INTO @SearchTable (Words) VALUES ('% '+@word+'%')
				INSERT INTO @SearchTable (Words) VALUES (@word+'%')
			END
			SET @SearchCondition = RIGHT(@SearchCondition, LEN(@SearchCondition) - @PosWord)
			SET @PosWord = CHARINDEX(':', @SearchCondition, 1)
		END
	END
END

DECLARE @EditPermission TINYINT;
SET @EditPermission = 0;
DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
INSERT INTO @UserInRoles SELECT DISTINCT ur.[RoleID] FROM dbo.[dnn_UserRoles] AS ur INNER JOIN dbo.[dnn_Roles] AS r ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);
DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions
DECLARE @UserEditCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can edit based on permissions
DECLARE @UserViewCategoriesWithFilter TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories which user can see based on permissions and Module filter
DECLARE @FiltredByCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY); -- all categories that are filtred by module or portal

IF @AdminOrSuperUser = 1 OR @Perm_ViewAllCategores = 1
BEGIN
	INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
END
ELSE IF @SearchModulePermissions = 1 -- ovaj dio se odnosi na dozvole ako se pristupa iz satelitskog modula
BEGIN
	IF @OuterPermissionSource = 0
	BEGIN
		INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	END
	ELSE IF @UserID = -1
	BEGIN
		IF @OuterPermissionSource = 1 -- portal
		BEGIN
		INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
		ELSE IF @OuterPermissionSource = 2 -- module
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @OuterPermissionID AND rps.RoleID IS NULL;
		END
	END
	ELSE -- registrirani korisnik
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpsc.[CategoryID]
			UNION
			SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upsc.[CategoryID];
		END
		ELSE -- by module
		BEGIN
			INSERT INTO @UserViewCategories
			SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @OuterModuleID GROUP BY rpsc.[CategoryID]
			UNION
			SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @OuterPermissionID GROUP BY upsc.[CategoryID];
		END
	END 
END
ELSE IF @UserID = -1
BEGIN	
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM  dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc 
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		WHERE rps.PortalID = @PortalID  AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
	END
	ELSE -- by module
	BEGIN
	INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID AND rps.RoleID IS NULL;
	END
END
ELSE -- registrirani korisnik
BEGIN
	IF @PermissionSettingsSource = 1 -- by portal
	BEGIN
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpsc.[CategoryID]
		UNION
		SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
		INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
		WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upsc.[CategoryID];
	END
	ELSE -- by module
	BEGIN
		INSERT INTO @UserViewCategories
		SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
		INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
		INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
		WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID GROUP BY rpsc.[CategoryID]
		UNION
		SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
		INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
		WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @ModuleID GROUP BY upsc.[CategoryID];
	END
END

IF @OuterModuleID <> 0 -- ovaj dio se odnosi na filter kategorija iz satelitskog modula
BEGIN
	IF @CategoryFilterType = 0 -- 0 All categories
	BEGIN
		INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories;
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	END
	ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
	BEGIN
		INSERT INTO @UserViewCategoriesWithFilter 
		SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
		INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @OuterModuleID
			
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID;
	END
	ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
	BEGIN
		WITH hierarchy AS(
			SELECT [CategoryID], [ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
			WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID)) AND PortalID = @PortalID
			UNION ALL
			SELECT c.[CategoryID], c.[ParentCategory]
			FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
		INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
		INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;
	END
END
ELSE
BEGIN
	IF @CategoryFilterType = 0 -- 0 All categories
	BEGIN
		INSERT INTO @UserViewCategoriesWithFilter SELECT [CategoryID] FROM @UserViewCategories;
		INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	END
	ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
	BEGIN
		IF @FillterSettingsSource = 1 -- portal
		BEGIN
			INSERT INTO @UserViewCategoriesWithFilter 
			SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
			INNER JOIN dbo.[dnn_EasyDNNNewsPortalCategoryItems] AS pci ON pci.CategoryID = cl.CategoryID AND pci.PortalID = @PortalID
			
			INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID;
		END
		ELSE -- module
		BEGIN
			INSERT INTO @UserViewCategoriesWithFilter 
			SELECT cl.[CategoryID] FROM @UserViewCategories AS cl
			INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @ModuleID
			
			INSERT INTO @FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID;
		END
	END
	ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
	BEGIN
		IF @FillterSettingsSource = 1 -- portal
		BEGIN
			WITH hierarchy AS(
				SELECT [CategoryID], [ParentCategory]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID)) AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID], c.[ParentCategory]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
				)
			INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
			INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;			
		END
		ELSE -- module
		BEGIN
			WITH hierarchy AS(
				SELECT [CategoryID], [ParentCategory]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID)) AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID], c.[ParentCategory]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
				)
			INSERT INTO @FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
			INSERT INTO @UserViewCategoriesWithFilter SELECT uvc.CategoryID FROM @FiltredByCategories AS nfc INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = nfc.CategoryID;
		END
	END
END

DECLARE @FilterBySocialGroup BIT;
SET @FilterBySocialGroup = 0;
DECLARE @FilterAuthorOrAuthors BIT;
SET @FilterAuthorOrAuthors = 0;

DECLARE @TempAuthorsIDList TABLE (UserID INT NOT NULL PRIMARY KEY);
IF @IsSocialInstance = 1
	BEGIN
		IF @FilterByDNNGroupID <> 0
		BEGIN	
			SET @FilterBySocialGroup = 1;
			IF @FilterByAuthor <> 0
			BEGIN
				SET @FilterAuthorOrAuthors = 1;
				SELECT @FilterByAuthor = UserID FROM dbo.[dnn_EasyDNNNewsAuthorProfile] WHERE [AuthorProfileID] = @FilterByAuthor;
			END
		END
	END
ELSE
BEGIN
-- ovaj dio odnosi se na filtriranje autora
	IF @OuterModuleID <> 0 AND @ShowAllAuthors = 0 -- filter iu other modula
	BEGIN
		SET @FilterAuthorOrAuthors = 1;
		INSERT INTO @TempAuthorsIDList
			SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @OuterModuleID
			UNION 
			SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
				INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
				INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
			WHERE mgi.ModuleID = @OuterModuleID
	END
	ELSE
	BEGIN
		IF @FilterByAuthor = 0 AND @FilterByGroupID = 0 AND @ShowAllAuthors = 0 -- filter glavnog newsa
		BEGIN
			SET @FilterAuthorOrAuthors = 1;
			IF @FillterSettingsSource = 1 -- by portal
			BEGIN
				INSERT INTO @TempAuthorsIDList
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsPortalAuthorsItems] AS pai WHERE pai.PortalID = @PortalID
				UNION 
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
					INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
					INNER JOIN dbo.[dnn_EasyDNNNewsPortalGroupItems] AS pgi ON pgi.GroupID = agi.GroupID
					WHERE pgi.PortalID = @PortalID
			END
			ELSE -- by modul
			BEGIN
				INSERT INTO @TempAuthorsIDList
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @ModuleID
				UNION 
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
					INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
					INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
					WHERE mgi.ModuleID = @ModuleID
			END
		END
		ELSE IF @FilterByAuthor <> 0
		BEGIN
			SET @FilterAuthorOrAuthors = 1;
			INSERT INTO @TempAuthorsIDList SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] WHERE [AuthorProfileID] = @FilterByAuthor;
		END
		ELSE IF @FilterByGroupID <> 0
		BEGIN
			SET @FilterAuthorOrAuthors = 1;
			INSERT INTO @TempAuthorsIDList
			SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
				INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID	
				WHERE agi.GroupID = @FilterByGroupID
		END
	END
END
-- kategorije sa edit pravima
IF @AdminOrSuperUser = 1 OR @Perm_EditAllCategores = 1
BEGIN	
	INSERT INTO @UserEditCategories SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
	SET @EditPermission = 1;
END
ELSE IF @SearchModulePermissions = 1 -- ovaj dio se odnosi na dozvole ako se pristupa iz satelitskog modula
BEGIN
	IF @OuterPermissionSource = 0
	BEGIN
		INSERT INTO @UserEditCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
		SET @EditPermission = 1;
	END
	ELSE IF @UserID = -1
	BEGIN
		IF @OuterPermissionSource = 1 -- portal settings
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
		ELSE IF @OuterPermissionSource = 2 -- module settings
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.RoleID IS NULL AND rps.PortalID = @PortalID AND rps.ModuleID = @OuterPermissionID;
		END
	END
	ELSE -- registrirani korisnik
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upatc.[CategoryID];
		END
		ELSE -- by module
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @OuterPermissionID GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @OuterPermissionID GROUP BY upatc.[CategoryID];
		END	
	END
END
ELSE
BEGIN
	IF @UserID = -1
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
		END
		ELSE -- by module
		BEGIN
		INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			WHERE rps.RoleID IS NULL AND rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID;
		END
	END
	ELSE -- registrirani korisnik
	BEGIN
		IF @PermissionSettingsSource = 1 -- by portal
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL GROUP BY upatc.[CategoryID];
		END
		ELSE -- by module
		BEGIN
			INSERT INTO @UserEditCategories
			SELECT rpatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsAddToCategories] AS rpatc
			INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpatc.PremissionSettingsID
			INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
			WHERE rps.PortalID = @PortalID AND rps.ModuleID = @ModuleID GROUP BY rpatc.[CategoryID]
			UNION
			SELECT upatc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsAddToCategories] AS upatc
			INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upatc.PremissionSettingsID
			WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @ModuleID GROUP BY upatc.[CategoryID];
		END	
	END
	IF EXISTS(SELECT * FROM @UserEditCategories) BEGIN SET @EditPermission = 2; END
END

DECLARE @LocalizedCategories TABLE (ID INT NOT NULL PRIMARY KEY, Name NVARCHAR(200), Position INT, CategoryURL NVARCHAR(1500));
IF @LocaleCode IS NOT NULL
BEGIN
	WITH LocCategories(ID, Name, Position, CategoryURL) AS (
		SELECT Cat.CategoryID AS ID, cl.Title AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = Cat.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLocalization] AS cl ON uvc.CategoryID = cl.CategoryID WHERE Cat.PortalID = @PortalID AND cl.LocaleCode = @LocaleCode
	),
	NotLocCategories(ID, Name, Position, CategoryURL) AS (
		SELECT Cat.CategoryID AS ID, Cat.CategoryName AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = Cat.CategoryID WHERE Cat.PortalID = @PortalID AND Cat.CategoryID NOT IN (SELECT ID FROM LocCategories)
	)
	INSERT INTO @LocalizedCategories SELECT ID, Name, Position, CategoryURL FROM (SELECT ID, Name, Position, CategoryURL FROM LocCategories UNION ALL SELECT ID, Name, Position, CategoryURL FROM NotLocCategories) AS ArticleCategories
END
ELSE
BEGIN
	INSERT INTO @LocalizedCategories SELECT Cat.CategoryID AS ID, Cat.CategoryName AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN @UserViewCategories AS uvc ON uvc.CategoryID = cat.CategoryID WHERE Cat.PortalID = @PortalID
END

IF @IsSocialInstance = 0
BEGIN
IF @LocaleCode IS NOT NULL
	BEGIN
		;WITH MainFilters AS(
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID 
			WHERE na.PortalID=@PortalID
				AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
				AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
				AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
		),
		AllContent AS(
			SELECT n.ArticleID,
				CASE WHEN n.EventArticle = 0 THEN n.PublishDate ELSE CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END END AS 'StartDate',
				CASE WHEN n.EventArticle = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID'
				FROM dbo.[dnn_EasyDNNNews] AS n
		LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
		LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
			CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
					 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
						THEN 1
						ELSE 0
					END
				WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END
			 WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM ( -- AS OnlyArticles
					SELECT ArticleID FROM (
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 0 AND HasPermissions 0 AND SearchTearm
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.HasPermissions = 0
							AND na.EventArticle = 0
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 0 AND HasPermissions 0 AND TagCloud
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
						WHERE na.HasPermissions = 0
							AND na.EventArticle = 0
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					) AS HasPermissionsFalse
					UNION ALL
					SELECT ArticleID FROM (
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 0 AND HasPermissions 1 AND User permissions AND SearchTearm
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.HasPermissions = 1
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 0 AND HasPermissions 1 AND User permissions AND TagCloud
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
						WHERE na.HasPermissions = 1
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 0 AND HasPermissions 1 AND Role permissions AND SearchTearm
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.HasPermissions = 1
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 0 AND HasPermissions 1 AND Role permissions AND TagCloud
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
						WHERE na.HasPermissions = 1
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
					) AS HasPermissionsTrue
				) AS OnlyArticles
				UNION ALL
				SELECT [ArticleID] FROM ( -- AS OnlyEvents
					SELECT [ArticleID] FROM (
						SELECT [ArticleID] FROM (
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurrin 0 AND SearchTearm
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
							WHERE na.HasPermissions = 0
								AND na.EventArticle = 1
								AND ne.Recurring = 0
								AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))) 
								AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurring 0 AND TagCloud
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							WHERE na.HasPermissions = 0
								AND na.EventArticle = 1
								AND ne.Recurring = 0
								AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
								AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						) AS HasPermissionsFalse
						UNION ALL
						SELECT [ArticleID] FROM (
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND SearchTearm
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE @DateRangeType
								WHEN 2 THEN -- @StartDate min value
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
										THEN 1
										ELSE 0
									END
								WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
										THEN 1
										ELSE 0
									END
								ELSE 0
								END
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
							WHERE na.HasPermissions = 0
								AND na.EventArticle = 1
								AND ne.Recurring = 1
								AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND TagCloud
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE @DateRangeType
								WHEN 2 THEN -- @StartDate min value
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
										THEN 1
										ELSE 0
									END
								WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
										THEN 1
										ELSE 0
									END
								ELSE 0
								END
							WHERE na.HasPermissions = 0
								AND na.EventArticle = 1
								AND ne.Recurring = 1
								AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						)  AS HasPermissionsFalseRecurring
					) AS HasPermissionsFalseAndOrRecurring
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT [ArticleID] FROM (
							SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND SearchTearm
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 0
								AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
								AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
								))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND SearchTearm
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 0
								AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
								AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
									AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
								))
							UNION
							SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND Tag Cloud
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 0
								AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
								AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
								))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND Tag Cloud
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 0
								AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
								AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
									AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
								))
						) AS HasPermissions
						UNION ALL
						SELECT [ArticleID] FROM (
							SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND SearchTearm
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE @DateRangeType
								WHEN 2 THEN -- @StartDate min value
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
										THEN 1
										ELSE 0
									END
								WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
										THEN 1
										ELSE 0
									END
								ELSE 0
								END
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 1
								AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
								))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND SearchTearm
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE @DateRangeType
								WHEN 2 THEN -- @StartDate min value
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
										THEN 1
										ELSE 0
									END
								WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
										THEN 1
										ELSE 0
									END
								ELSE 0
								END
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 1
								AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
									AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
								))
							UNION
							SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND Tag Cloud
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE @DateRangeType
								WHEN 2 THEN -- @StartDate min value
									CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
										THEN 1
										ELSE 0
									END
								WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
										THEN 1
										ELSE 0
									END
								ELSE 0
								END
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 1
								AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
								))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND Tag Cloud
								INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
								INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
								CASE @DateRangeType
								WHEN 2 THEN -- @StartDate min value
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
											THEN 1
											ELSE 0
										END
								WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
									CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
										THEN 1
										ELSE 0
									END
								ELSE 0
								END
							WHERE na.HasPermissions = 1
								AND na.EventArticle = 1
								AND ne.Recurring = 1
								AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
									AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
								))
						) AS HasPermissionsRecurring
					) AS HasPermissionsAndOrRecurring
				) AS OnlyEvents
			)
			),
		AllCount AS (
			SELECT COUNT(*) AS ContentCount FROM AllContent --GROUP BY ArticleID, RecurringID
		),
		FinalArticleIDsSet (ArticleID,StartDate,RecurringID) AS(
			SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID, StartDate,RecurringID FROM (
			SELECT *,ROW_NUMBER() OVER (ORDER BY
		CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
		CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
		CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
		CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
		CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
		CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
		CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
		CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
		CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
		CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
		CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
		CASE WHEN @OrderBy ='Title ASC' THEN Title END,
		CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC) AS Kulike
		FROM 
			(SELECT n.ArticleID,n.Featured,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,n.NumberOfComments,n.Title,ac.StartDate, ac.RecurringID FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID) AS innerAllResult) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY		
			CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC
		),
		FinalLocalizedArticleIDsSet (ArticleID,RecurringID,StartDate,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
			SELECT ncl.ArticleID,fais.RecurringID,fais.StartDate,ncl.Title,ncl.SubTitle,ncl.Summary,ncl.Article,ncl.DetailTypeData,ncl.clTitleLink AS TitleLink ,ncl.MetaDecription,ncl.MetaKeywords,ncl.MainImageTitle,ncl.MainImageDescription
			FROM dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl INNER JOIN FinalArticleIDsSet AS fais ON ncl.ArticleID = fais.ArticleID AND LocaleCode = @LocaleCode
		)
		SELECT *,
			CASE @AdminOrSuperUser 
				WHEN 0 THEN 0
				WHEN 1 THEN 1
				WHEN 2 THEN
				CASE @EditOnlyAsOwner
					WHEN 0 THEN			
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END
						END  			
					WHEN 1 THEN
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END 
						END
				END
				WHEN 3 THEN
					CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
						THEN 1
						ELSE
						CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
							THEN 1
							ELSE 0
							END
						END 
			END AS 'CanEdit',
			(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
			 CASE Result.Active
				WHEN 1 THEN 0
				WHEN 0 THEN 1
			 END AS 'Published',
			 CASE @UserCanApprove
				WHEN 0 THEN 0
				WHEN 1 THEN
					CASE Result.Approved
					 WHEN 1 THEN 0
					 WHEN 0 THEN
						 CASE Result.Active
							WHEN 1 THEN 1
							WHEN 0 THEN 0
						END
					END
			 END AS 'Approve',
			(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
			 FROM (
				SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
					 fais.StartDate,
					 fais.RecurringID,
					 n.[CFGroupeID]
					FROM dbo.[dnn_EasyDNNNews] AS n
					INNER JOIN FinalArticleIDsSet AS fais ON n.ArticleID = fais.ArticleID AND fais.ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet)
				UNION ALL
				SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription],
					 fla.StartDate,
					 fla.RecurringID,
					 n.[CFGroupeID]
				FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID 
				) As Result	
			ORDER BY
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
	ELSE
	BEGIN
		;WITH MainFilters AS(
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
				INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
			WHERE na.PortalID=@PortalID
				AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate]
				AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
		),
		AllContent AS(
			SELECT n.ArticleID,
					CASE WHEN n.EventArticle = 0 THEN n.PublishDate ELSE CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END END AS 'StartDate',
					CASE WHEN n.EventArticle = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID'
				FROM dbo.[dnn_EasyDNNNews] AS n
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
							THEN 1
							ELSE 0
						END
					WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
				WHERE n.ArticleID IN(
				SELECT [ArticleID] FROM ( -- AS OnlyArticles
					SELECT ArticleID FROM (
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 0
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
						WHERE na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 0
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					) AS HasPermissionsFalse
					UNION ALL
					SELECT ArticleID FROM (
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
						WHERE na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
							INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
						WHERE na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 0
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
						) AS HasPermissionsTrue
				) AS OnlyArticles
				UNION ALL
				SELECT [ArticleID] FROM ( -- AS OnlyEvents
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 0
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 1
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 0 AND TagCloud
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					UNION ALL
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 1 AND TagCloud
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.HasPermissions = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					UNION ALL
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 0 AND User permissions
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
					UNION
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 0 AND User permissions AND Tag Cloud
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
					UNION
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 1 AND User permissions
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
					UNION
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 1 AND User permissions AND Tag Cloud
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 0 AND Role permissions
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 0 AND Role permissions AND Tag Cloud
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 1 AND Role permissions
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND Recurrin 1 AND Role permissions AND Tag Cloud
						INNER JOIN MainFilters AS mf ON na.ArticleID = mf.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.HasPermissions = 1
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
				) AS OnlyEvents
			)
		),
		AllCount AS (
			SELECT COUNT(*) AS ContentCount FROM AllContent --GROUP BY ArticleID, RecurringID
		)
		SELECT *,
		CASE @AdminOrSuperUser 
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN
			CASE @EditOnlyAsOwner
				WHEN 0 THEN			
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END
					END  			
				WHEN 1 THEN
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END 
					END
			END
			WHEN 3 THEN
				CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
					THEN 1
					ELSE
					CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
						THEN 1
						ELSE 0
						END
					END 
		END AS 'CanEdit',
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
		 CASE Result.Active
			WHEN 1 THEN 0
			WHEN 0 THEN 1
		 END AS 'Published',
		 CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Result.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Result.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS  'Approve',
			(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
		FROM (
		 SELECT *, ROW_NUMBER() OVER (ORDER BY
			 CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			 CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			 CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			 CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			 CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			 CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			 CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			 CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			 CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			 CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			 CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			 CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			 CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			 CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			 CASE WHEN @OrderBy ='StartDate ASC' THEN [StartDate] END,
			 CASE WHEN @OrderBy ='StartDate DESC' THEN [StartDate] END DESC) AS Kulike
	FROM (

	SELECT
		 n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
		 ac.StartDate,
		 ac.RecurringID
		 ,n.[CFGroupeID]
		 FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID) AS innerAllResult ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
			CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
END
ELSE IF @FilterBySocialGroup = 1
BEGIN
	IF @LocaleCode IS NOT NULL
	BEGIN
		;WITH AllContent AS(
			SELECT n.ArticleID,
				CASE WHEN n.EventArticle = 0 THEN n.PublishDate ELSE CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END END AS 'StartDate',
				CASE WHEN n.EventArticle = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID'
			FROM dbo.[dnn_EasyDNNNews] AS n
			LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
			LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
				CASE @DateRangeType
					WHEN 2 THEN -- @StartDate min value
						CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
							THEN 1
							ELSE 0
						END
					WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
						CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
							THEN 1
							ELSE 0
						END
					ELSE 0
					END
				 WHERE n.ArticleID IN(
					SELECT [ArticleID] FROM ( -- AS OnlyArticles
						SELECT ArticleID FROM (
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
							WHERE na.PortalID=@PortalID
								AND na.HasPermissions = 0
								AND na.EventArticle = 0
								AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
								AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
								AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
							WHERE na.PortalID=@PortalID
								AND na.HasPermissions = 0
								AND na.EventArticle = 0
								AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
								AND ((@AdminOrSuperUser = 1) OR ((@UserCanApprove = 1 OR na.Approved=1)AND (na.Active=1 OR na.UserID=@UserID)))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
								AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
						) AS HasPermissionsFalse
						UNION ALL
						SELECT ArticleID FROM (
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
							WHERE na.PortalID=@PortalID
								AND na.HasPermissions = 1
								AND na.EventArticle = 0
								AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
								AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
								))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
								AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
							WHERE na.PortalID=@PortalID
								AND na.HasPermissions = 1
								AND na.EventArticle = 0
								AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
								AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
									AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
								))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
								AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN @SearchTable AS st ON(
									(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
									OR
									(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
								)
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
							WHERE na.PortalID=@PortalID
								AND na.HasPermissions = 1
								AND na.EventArticle = 0
								AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
								AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
									AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
								))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
								AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							UNION
							SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
								INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
								INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
								INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
								INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
								INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
								INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
								LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
							WHERE na.PortalID=@PortalID
								AND na.HasPermissions = 1
								AND na.EventArticle = 0
								AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
								AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
									AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
								))
								AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
								AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
						) AS HasPermissionsTrue
					) AS OnlyArticles
					UNION ALL
					SELECT [ArticleID] FROM ( -- AS OnlyEvents
						SELECT [ArticleID] FROM (
							SELECT [ArticleID] FROM (
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurrin 0 AND SearchTearm
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 0
									AND na.EventArticle = 1
									AND ne.Recurring = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))) 
									AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurring 0 AND TagCloud
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 0
									AND na.EventArticle = 1
									AND ne.Recurring = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
									AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							) AS HasPermissionsFalse
							UNION ALL
							SELECT [ArticleID] FROM (
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND SearchTearm
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
									CASE @DateRangeType
									WHEN 2 THEN -- @StartDate min value
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
											THEN 1
											ELSE 0
										END
									WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END
									ELSE 0
									END
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 0
									AND na.EventArticle = 1
									AND ne.Recurring = 1
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND TagCloud
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
									CASE @DateRangeType
									WHEN 2 THEN -- @StartDate min value
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
											THEN 1
											ELSE 0
										END
									WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END
									ELSE 0
									END
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 0
									AND na.EventArticle = 1
									AND ne.Recurring = 1
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							)  AS HasPermissionsFalseRecurring
						) AS HasPermissionsFalseAndOrRecurring
						UNION ALL
						SELECT [ArticleID] FROM (
							SELECT [ArticleID] FROM (
								SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND SearchTearm
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
									AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND SearchTearm
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
									AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
										AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND Tag Cloud
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
									AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND Tag Cloud
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
									AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
										AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							) AS HasPermissions
							UNION ALL
							SELECT [ArticleID] FROM (
								SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND SearchTearm
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
									CASE @DateRangeType
									WHEN 2 THEN -- @StartDate min value
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
											THEN 1
											ELSE 0
										END
									WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END
									ELSE 0
									END
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 1
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND SearchTearm
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
									CASE @DateRangeType
									WHEN 2 THEN -- @StartDate min value
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
											THEN 1
											ELSE 0
										END
									WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END
									ELSE 0
									END
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 1
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
										AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND Tag Cloud
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
									CASE @DateRangeType
									WHEN 2 THEN -- @StartDate min value
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
											THEN 1
											ELSE 0
										END
									WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END
									ELSE 0
									END
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 1
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND Tag Cloud
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
									INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
									CASE @DateRangeType
									WHEN 2 THEN -- @StartDate min value
										CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
										 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
											THEN 1
											ELSE 0
										END
									WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
										CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
											THEN 1
											ELSE 0
										END
									ELSE 0
									END
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.EventArticle = 1
									AND ne.Recurring = 1
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
										AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
									))
									AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							) AS HasPermissionsRecurring
						) AS HasPermissionsAndOrRecurring
					) AS OnlyEvents
				)
		),
		AllCount AS (
			SELECT COUNT(*) AS ContentCount FROM AllContent --GROUP BY ArticleID, RecurringID
		),
		FinalArticleIDsSet (ArticleID,StartDate,RecurringID) AS(
			SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID, StartDate,RecurringID FROM (
			SELECT *,ROW_NUMBER() OVER (ORDER BY
		CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
		CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
		CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
		CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
		CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
		CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
		CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
		CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
		CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
		CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
		CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
		CASE WHEN @OrderBy ='Title ASC' THEN Title END,
		CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC) AS Kulike
		FROM 
			(SELECT n.ArticleID,n.Featured,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,n.NumberOfComments,n.Title,ac.StartDate, ac.RecurringID FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID) AS innerAllResult) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY		
			CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC
		),
		FinalLocalizedArticleIDsSet (ArticleID,RecurringID,StartDate,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
			SELECT ncl.ArticleID,fais.RecurringID,fais.StartDate,ncl.Title,ncl.SubTitle,ncl.Summary,ncl.Article,ncl.DetailTypeData,ncl.clTitleLink AS TitleLink ,ncl.MetaDecription,ncl.MetaKeywords,ncl.MainImageTitle,ncl.MainImageDescription
			FROM dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl INNER JOIN FinalArticleIDsSet AS fais ON ncl.ArticleID = fais.ArticleID AND LocaleCode = @LocaleCode
		)
		SELECT *,
			CASE @AdminOrSuperUser 
				WHEN 0 THEN 0
				WHEN 1 THEN 1
				WHEN 2 THEN
				CASE @EditOnlyAsOwner
					WHEN 0 THEN			
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END
						END  			
					WHEN 1 THEN
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END 
						END
				END
				WHEN 3 THEN
					CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
						THEN 1
						ELSE
						CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
							THEN 1
							ELSE 0
							END
						END 
			END AS 'CanEdit',
			(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
			 CASE Result.Active
				WHEN 1 THEN 0
				WHEN 0 THEN 1
			 END AS 'Published',
			 CASE @UserCanApprove
				WHEN 0 THEN 0
				WHEN 1 THEN
					CASE Result.Approved
					 WHEN 1 THEN 0
					 WHEN 0 THEN
						 CASE Result.Active
							WHEN 1 THEN 1
							WHEN 0 THEN 0
						END
					END
			 END AS 'Approve',
			(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
			 FROM (
				SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
					 fais.StartDate,
					 fais.RecurringID,
					 n.[CFGroupeID]
					FROM dbo.[dnn_EasyDNNNews] AS n
					INNER JOIN FinalArticleIDsSet AS fais ON n.ArticleID = fais.ArticleID AND fais.ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet)
				UNION ALL
				SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription],
					 fla.StartDate,
					 fla.RecurringID,
					 n.[CFGroupeID]
				FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID 
				) As Result	
			ORDER BY
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
	ELSE
	BEGIN
		;WITH AllContent AS(
			SELECT n.ArticleID,
				CASE WHEN n.EventArticle = 0 THEN n.PublishDate ELSE CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END END AS 'StartDate',
				CASE WHEN n.EventArticle = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID'
			FROM dbo.[dnn_EasyDNNNews] AS n
			LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
			LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
			CASE @DateRangeType
				WHEN 2 THEN -- @StartDate min value
					CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
						THEN 1
						ELSE 0
					END
				WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
					CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
						THEN 1
						ELSE 0
					END
				ELSE 0
				END
			WHERE n.ArticleID IN(
			SELECT [ArticleID] FROM ( -- AS OnlyArticles
				SELECT ArticleID FROM (
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @SearchTable AS st ON(
						(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
					)
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
					INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
			) AS HasPermissionsFalse
			UNION ALL
			SELECT ArticleID FROM (
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @SearchTable AS st ON(
						(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
					)
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
					INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @SearchTable AS st ON(
						(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
					)
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
					INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
					AND ((@FilterAuthorOrAuthors = 0) OR (@FilterAuthorOrAuthors = 1 AND na.UserID = @FilterByAuthor))
				) AS HasPermissionsTrue
			) AS OnlyArticles
			UNION ALL
			SELECT [ArticleID] FROM ( -- AS OnlyEvents
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurrin 0 AND SearchTearm
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))) 
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurring 0 AND TagCloud
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					) AS HasPermissionsFalse
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND SearchTearm
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND TagCloud
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 0
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					)  AS HasPermissionsFalseRecurring
				) AS HasPermissionsFalseAndOrRecurring
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND SearchTearm
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND SearchTearm
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND Tag Cloud
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND Tag Cloud
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 0
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					) AS HasPermissions
					UNION ALL
					SELECT [ArticleID] FROM (
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND SearchTearm
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND SearchTearm
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
							INNER JOIN @SearchTable AS st ON(
								(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
								OR
								(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
							)
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND Tag Cloud
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
								AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
						UNION
						SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND Tag Cloud
							INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
							INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
							INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
							INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
							INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = n.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
							INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
							INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
							CASE @DateRangeType
							WHEN 2 THEN -- @StartDate min value
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
								CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
									THEN 1
									ELSE 0
								END
							ELSE 0
							END
						WHERE na.PortalID=@PortalID
							AND na.HasPermissions = 1
							AND na.HideDefaultLocale = 0
							AND na.EventArticle = 1
							AND ne.Recurring = 1
							AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
							AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
								AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							))
							AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					) AS HasPermissionsRecurring
				) AS HasPermissionsAndOrRecurring
			) AS OnlyEvents
		)
		),
		AllCount AS (
			SELECT COUNT(*) AS ContentCount FROM AllContent --GROUP BY ArticleID, RecurringID
		)
		SELECT *,
		CASE @AdminOrSuperUser 
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN
			CASE @EditOnlyAsOwner
				WHEN 0 THEN			
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END
					END  			
				WHEN 1 THEN
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END 
					END
			END
			WHEN 3 THEN
				CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
					THEN 1
					ELSE
					CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
						THEN 1
						ELSE 0
						END
					END 
		END AS 'CanEdit',
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
		 CASE Result.Active
			WHEN 1 THEN 0
			WHEN 0 THEN 1
		 END AS 'Published',
		 CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Result.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Result.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS  'Approve',
			(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
		FROM (
		 SELECT *, ROW_NUMBER() OVER (ORDER BY
			 CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			 CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			 CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			 CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			 CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			 CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			 CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			 CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			 CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			 CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			 CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			 CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			 CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			 CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			 CASE WHEN @OrderBy ='StartDate ASC' THEN [StartDate] END,
			 CASE WHEN @OrderBy ='StartDate DESC' THEN [StartDate] END DESC) AS Kulike
		FROM (

	SELECT
		 n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
		 ac.StartDate,
		 ac.RecurringID
		 ,n.[CFGroupeID]
		 FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID) AS innerAllResult ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
			CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
END
ELSE IF @FilterByDNNUserID <> 0
BEGIN
	IF @LocaleCode IS NOT NULL
	BEGIN
		;WITH AllContent AS(
			SELECT n.ArticleID,
				CASE WHEN n.EventArticle = 0 THEN n.PublishDate ELSE CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END END AS 'StartDate',
				CASE WHEN n.EventArticle = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID'
						FROM dbo.[dnn_EasyDNNNews] AS n
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
					CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
							 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					 WHERE n.ArticleID IN(
						SELECT [ArticleID] FROM ( -- AS OnlyArticles
							SELECT ArticleID FROM (
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 0
									AND na.UserID = @FilterByDNNUserID
									AND na.EventArticle = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 0
									AND na.UserID = @FilterByDNNUserID
									AND na.EventArticle = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							) AS HasPermissionsFalse
							UNION ALL
							SELECT ArticleID FROM (
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.UserID = @FilterByDNNUserID
									AND na.EventArticle = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
									))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.UserID = @FilterByDNNUserID
									AND na.EventArticle = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
										AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
									))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN @SearchTable AS st ON(
										(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
										OR
										(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
									)
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.UserID = @FilterByDNNUserID
									AND na.EventArticle = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
										AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
									))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								UNION
								SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
									INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
									INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
									INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
									INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
									INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
									INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
									INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
									LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
								WHERE na.PortalID=@PortalID
									AND na.HasPermissions = 1
									AND na.UserID = @FilterByDNNUserID
									AND na.EventArticle = 0
									AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
									AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
										AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
									))
									AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
							) AS HasPermissionsTrue
						) AS OnlyArticles
						UNION ALL
						SELECT [ArticleID] FROM ( -- AS OnlyEvents
							SELECT [ArticleID] FROM (
								SELECT [ArticleID] FROM (
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurrin 0 AND SearchTearm
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
										INNER JOIN @SearchTable AS st ON(
											(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
										)
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 0
										AND na.EventArticle = 1
										AND ne.Recurring = 0
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))) 
										AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurring 0 AND TagCloud
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
										INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 0
										AND na.EventArticle = 1
										AND ne.Recurring = 0
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
										AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								) AS HasPermissionsFalse
								UNION ALL
								SELECT [ArticleID] FROM (
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND SearchTearm
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE @DateRangeType
										WHEN 2 THEN -- @StartDate min value
											CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END
										WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
												THEN 1
												ELSE 0
											END
										ELSE 0
										END
										INNER JOIN @SearchTable AS st ON(
											(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
										)
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 0
										AND na.EventArticle = 1
										AND ne.Recurring = 1
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND TagCloud
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
										INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE @DateRangeType
										WHEN 2 THEN -- @StartDate min value
											CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END
										WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
												THEN 1
												ELSE 0
											END
										ELSE 0
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 0
										AND na.EventArticle = 1
										AND ne.Recurring = 1
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								)  AS HasPermissionsFalseRecurring
							) AS HasPermissionsFalseAndOrRecurring
							UNION ALL
							SELECT [ArticleID] FROM (
								SELECT [ArticleID] FROM (
									SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND SearchTearm
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
										INNER JOIN @SearchTable AS st ON(
											(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
										)
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 0
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
										AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
											AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND SearchTearm
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
										INNER JOIN @SearchTable AS st ON(
											(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
										)
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 0
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
										AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
											AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND Tag Cloud
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
										INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 0
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
										AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
											AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND Tag Cloud
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
										INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 0
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
										AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
											AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								) AS HasPermissions
								UNION ALL
								SELECT [ArticleID] FROM (
									SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND SearchTearm
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE @DateRangeType
										WHEN 2 THEN -- @StartDate min value
											CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END
										WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
												THEN 1
												ELSE 0
											END
										ELSE 0
										END
										INNER JOIN @SearchTable AS st ON(
											(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
										)
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 1
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
											AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND SearchTearm
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE @DateRangeType
										WHEN 2 THEN -- @StartDate min value
											CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END
										WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
												THEN 1
												ELSE 0
											END
										ELSE 0
										END
										INNER JOIN @SearchTable AS st ON(
											(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
											OR
											(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
										)
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 1
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
											AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND Tag Cloud
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
										INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE @DateRangeType
										WHEN 2 THEN -- @StartDate min value
											CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END
										WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
												THEN 1
												ELSE 0
											END
										ELSE 0
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 1
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
											AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
									UNION
									SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND Tag Cloud
										INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
										INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
										INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
										INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
										INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
										INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
										INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
										INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
										CASE @DateRangeType
										WHEN 2 THEN -- @StartDate min value
											CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
											 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
												THEN 1
												ELSE 0
											END
										WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
											CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
												THEN 1
												ELSE 0
											END
										ELSE 0
										END
										LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID
									WHERE na.PortalID=@PortalID
										AND na.HasPermissions = 1
										AND na.EventArticle = 1
										AND ne.Recurring = 1
										AND na.UserID = @FilterByDNNUserID
										AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
										AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
											AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
										))
										AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
										AND (@HideUnlocalizedItems = 0 OR (ncl.ArticleID IS NOT NULL AND ncl.LocaleCode = @LocaleCode))
								) AS HasPermissionsRecurring
							) AS HasPermissionsAndOrRecurring
						) AS OnlyEvents
					)
		),
		AllCount AS (
			SELECT COUNT(*) AS ContentCount FROM AllContent --GROUP BY ArticleID, RecurringID
		),
		FinalArticleIDsSet (ArticleID,StartDate,RecurringID) AS(
			SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID, StartDate,RecurringID FROM (
			SELECT *,ROW_NUMBER() OVER (ORDER BY
		CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
		CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
		CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
		CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
		CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
		CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
		CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
		CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
		CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
		CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
		CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
		CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
		CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
		CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
		CASE WHEN @OrderBy ='Title ASC' THEN Title END,
		CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC) AS Kulike
		FROM 
			(SELECT n.ArticleID,n.Featured,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,n.NumberOfComments,n.Title,ac.StartDate, ac.RecurringID FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID) AS innerAllResult) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY			
			CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC
		),
		FinalLocalizedArticleIDsSet (ArticleID,RecurringID,StartDate,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
			SELECT ncl.ArticleID,fais.RecurringID,fais.StartDate,ncl.Title,ncl.SubTitle,ncl.Summary,ncl.Article,ncl.DetailTypeData,ncl.clTitleLink AS TitleLink ,ncl.MetaDecription,ncl.MetaKeywords,ncl.MainImageTitle,ncl.MainImageDescription
			FROM dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl INNER JOIN FinalArticleIDsSet AS fais ON ncl.ArticleID = fais.ArticleID AND LocaleCode = @LocaleCode
		)
		SELECT *,
			CASE @AdminOrSuperUser 
				WHEN 0 THEN 0
				WHEN 1 THEN 1
				WHEN 2 THEN
				CASE @EditOnlyAsOwner
					WHEN 0 THEN			
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END
						END  			
					WHEN 1 THEN
						CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
							THEN 1
							ELSE
								CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
								THEN 1
								ELSE
									CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
										THEN 1
										ELSE 0
									END
								END 
						END
				END
				WHEN 3 THEN
					CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
						THEN 1
						ELSE
						CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
							THEN 1
							ELSE 0
							END
						END 
			END AS 'CanEdit',
			(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
			 CASE Result.Active
				WHEN 1 THEN 0
				WHEN 0 THEN 1
			 END AS 'Published',
			 CASE @UserCanApprove
				WHEN 0 THEN 0
				WHEN 1 THEN
					CASE Result.Approved
					 WHEN 1 THEN 0
					 WHEN 0 THEN
						 CASE Result.Active
							WHEN 1 THEN 1
							WHEN 0 THEN 0
						END
					END
			 END AS 'Approve',
			(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
				FROM (
				SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
					 fais.StartDate,
					 fais.RecurringID,
					 n.[CFGroupeID]
					FROM dbo.[dnn_EasyDNNNews] AS n
					INNER JOIN FinalArticleIDsSet AS fais ON n.ArticleID = fais.ArticleID AND fais.ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet)
				UNION ALL
				SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
					,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
					,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
					,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
					,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
					,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription],
					 fla.StartDate,
					 fla.RecurringID,
					 n.[CFGroupeID]
				FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID 
				) As Result	
			ORDER BY
				CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
				CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
				CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
				CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
				CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
				CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
				CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
				CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
				CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
				CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
				CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
				CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
				CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
				CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
				CASE WHEN @OrderBy ='Title ASC' THEN Title END,
				CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
				CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
				CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
	ELSE
	BEGIN
		;WITH AllContent AS(
			SELECT n.ArticleID,
				CASE WHEN n.EventArticle = 0 THEN n.PublishDate ELSE CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END END AS 'StartDate',
				CASE WHEN n.EventArticle = 1 AND ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS 'RecurringID'
					FROM dbo.[dnn_EasyDNNNews] AS n
		LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
		LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.ArticleID IS NOT NULL AND ned.Recurring = 1 AND 1 =
		CASE @DateRangeType
			WHEN 2 THEN -- @StartDate min value
				CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
					OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
					THEN 1
					ELSE 0
				END
			WHEN 0 THEN -- Show all treba uzeti u obzir ogranicenje UpcomingOccurrences
				CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
					THEN 1
					ELSE 0
				END
			ELSE 0
			END
		WHERE n.ArticleID IN(
		SELECT [ArticleID] FROM ( -- AS OnlyArticles
			SELECT ArticleID FROM (
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @SearchTable AS st ON(
						(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
					)
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.UserID = @FilterByDNNUserID
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
					INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 0
					AND na.HideDefaultLocale = 0
					AND na.UserID = @FilterByDNNUserID
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
			) AS HasPermissionsFalse
			UNION ALL
			SELECT ArticleID FROM (
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @SearchTable AS st ON(
						(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
					)
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.UserID = @FilterByDNNUserID
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
					INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.UserID = @FilterByDNNUserID
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
						AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
					))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN @SearchTable AS st ON(
						(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
						OR
						(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
					)
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.UserID = @FilterByDNNUserID
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
					INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
					INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
					INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
					INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
					INNER JOIN @SearchTable AS st2 ON newt.Name Like st2.Words
				WHERE na.PortalID=@PortalID
					AND na.HasPermissions = 1
					AND na.HideDefaultLocale = 0
					AND na.UserID = @FilterByDNNUserID
					AND na.EventArticle = 0
					AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
					AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
						AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					))
			) AS HasPermissionsTrue
		) AS OnlyArticles
		UNION ALL
		SELECT [ArticleID] FROM ( -- AS OnlyEvents
			SELECT [ArticleID] FROM (
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurrin 0 AND SearchTearm
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)))) 
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurring 0 AND TagCloud
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
				) AS HasPermissionsFalse
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND SearchTearm
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 0 AND Recurring 1 AND TagCloud
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @UserViewCategoriesWithFilter AS uvcwf ON uvcwf.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ne.UpcomingOccurrences > 1
							THEN
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(ne.UpcomingOccurrences) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							ELSE
								CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
									OR (nerd.RecurringID IN (SELECT TOP(1) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
									THEN 1
									ELSE 0
								END
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 0
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (((na.Active = 1 OR na.UserID = @UserID) AND (na.Approved = 1 OR @UserCanApprove = 1)) OR @AdminOrSuperUser = 1)
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
				)  AS HasPermissionsFalseRecurring
			) AS HasPermissionsFalseAndOrRecurring
			UNION ALL
			SELECT [ArticleID] FROM (
				SELECT [ArticleID] FROM (
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na  -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND SearchTearm
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND SearchTearm
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND User permissions AND Tag Cloud
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 0 AND Role permissions AND Tag Cloud
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 0
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND (@DateRangeType = 0 OR (@DateRangeType = 2 AND ((ne.StartDate >= @StartDate) OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate))))
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
				) AS HasPermissions
				UNION ALL
				SELECT [ArticleID] FROM (
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND SearchTearm
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND SearchTearm
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
						INNER JOIN @SearchTable AS st ON(
							(@SearchType = 3 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\' OR na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 2 AND (na.CleanArticleData LIKE st.Words ESCAPE '\'))
							OR
							(@SearchType = 1 AND (na.Title LIKE st.Words ESCAPE '\' OR na.SubTitle LIKE st.Words ESCAPE '\'))
						)
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND User permissions AND Tag Cloud
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserID = -1 AND aup.UserID IS NULL) OR (aup.UserID = @UserID))
							AND aup.Show = 1 AND ((@UserCanApprove = 1) OR (na.Approved=1)) AND (na.Active=1 OR na.UserID=@UserID)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
					UNION
					SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND Recurring 1 AND Role permissions AND Tag Cloud
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID
						INNER JOIN @FiltredByCategories AS fbc ON fbc.CategoryID = cat.CategoryID
						INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS nt ON na.ArticleID = nt.ArticleID
						INNER JOIN dbo.[dnn_EasyDNNNewsNewTags] AS newt ON nt.TagID = newt.TagID
						INNER JOIN @SearchTable AS st2 ON newt.Name LIKE st2.Words
						INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = n.ArticleID
						INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
						INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND 1 =
						CASE @DateRangeType
						WHEN 2 THEN -- @StartDate min value
							CASE WHEN ((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
								OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime)))
								THEN 1
								ELSE 0
							END
						WHEN 0 THEN -- Show all ali treba uzeti u obzir ogranicenje UpcomingOccurrences
							CASE WHEN nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)
								THEN 1
								ELSE 0
							END
						ELSE 0
						END
					WHERE na.PortalID=@PortalID
						AND na.HasPermissions = 1
						AND na.HideDefaultLocale = 0
						AND na.EventArticle = 1
						AND ne.Recurring = 1
						AND na.UserID = @FilterByDNNUserID
						AND na.PublishDate <= @CurrentDate AND na.[ExpireDate] >= @CurrentDate
						AND ((@AdminOrSuperUser = 1) OR (((@UserCanApprove = 1) OR (na.Approved=1))
							AND (na.Active=1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
						))
						AND (@FilterAuthorOrAuthors = 0 OR na.UserID IN (SELECT UserID FROM @TempAuthorsIDList))
				) AS HasPermissionsRecurring
			) AS HasPermissionsAndOrRecurring
		) AS OnlyEvents
		)
		),
		AllCount AS (
			SELECT COUNT(*) AS ContentCount FROM AllContent --GROUP BY ArticleID, RecurringID
		)
		SELECT *,
		CASE @AdminOrSuperUser 
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN
			CASE @EditOnlyAsOwner
				WHEN 0 THEN			
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END
					END  			
				WHEN 1 THEN
					CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserEditCategories))
						THEN 1
						ELSE
							CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
							THEN 1
							ELSE
								CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
									THEN 1
									ELSE 0
								END
							END 
					END
			END
			WHEN 3 THEN
				CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM @UserInRoles))
					THEN 1
					ELSE
					CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
						THEN 1
						ELSE 0
						END
					END 
		END AS 'CanEdit',
		(SELECT cat.ID, cat.Name, cat.CategoryURL FROM @LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT('root')) AS 'CatToShow',
		 CASE Result.Active
			WHEN 1 THEN 0
			WHEN 0 THEN 1
		 END AS 'Published',
		 CASE @UserCanApprove
			WHEN 0 THEN 0
			WHEN 1 THEN
				CASE Result.Approved
				 WHEN 1 THEN 0
				 WHEN 0 THEN
					 CASE Result.Active
						WHEN 1 THEN 1
						WHEN 0 THEN 0
					END
				END
		 END AS  'Approve',
			(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
		FROM (
		 SELECT *, ROW_NUMBER() OVER (ORDER BY
			 CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			 CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			 CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			 CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			 CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			 CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			 CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			 CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			 CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			 CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			 CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			 CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			 CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			 CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			 CASE WHEN @OrderBy ='StartDate ASC' THEN [StartDate] END,
			 CASE WHEN @OrderBy ='StartDate DESC' THEN [StartDate] END DESC) AS Kulike
	FROM (

	SELECT
		 n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
		 ac.StartDate,
		 ac.RecurringID
		 ,n.[CFGroupeID]
		 FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID) AS innerAllResult ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY
			CASE WHEN @OrderBy ='PublishDate ASC' THEN PublishDate END,
			CASE WHEN @OrderBy ='PublishDate DESC' THEN PublishDate END DESC,
			CASE WHEN @OrderBy ='NumberOfViews ASC' THEN NumberOfViews END,
			CASE WHEN @OrderBy ='NumberOfViews DESC' THEN NumberOfViews END DESC,
			CASE WHEN @OrderBy ='RatingValue ASC' THEN RatingValue END,
			CASE WHEN @OrderBy ='RatingValue DESC' THEN RatingValue END DESC,
			CASE WHEN @OrderBy ='DateAdded ASC' THEN DateAdded END,
			CASE WHEN @OrderBy ='DateAdded DESC' THEN DateAdded END DESC,
			CASE WHEN @OrderBy ='ExpireDate ASC' THEN ExpireDate END,
			CASE WHEN @OrderBy ='ExpireDate DESC' THEN ExpireDate END DESC,
			CASE WHEN @OrderBy ='LastModified ASC' THEN LastModified END,
			CASE WHEN @OrderBy ='LastModified DESC' THEN LastModified END DESC,
			CASE WHEN @OrderBy ='NumberOfComments ASC' THEN NumberOfComments END,
			CASE WHEN @OrderBy ='NumberOfComments DESC' THEN NumberOfComments END DESC,
			CASE WHEN @OrderBy ='Title ASC' THEN Title END,
			CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC,
			CASE WHEN @OrderBy ='StartDate ASC' THEN StartDate END,
			CASE WHEN @OrderBy ='StartDate DESC' THEN StartDate END DESC;
	END
END

