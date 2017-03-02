CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsEventViewSignUp]
	@News_ModuleID INT,
	@PortalID INT,
	@UserID INT,
	@ArticleID INT,
	@RecurringID INT = NULL,
	@IsAdminOrSuperUser BIT = 0
AS 
SET NOCOUNT ON;

DECLARE @IsRegistrationEnabled BIT; -- if article still alows registration
SET @IsRegistrationEnabled = 0;

DECLARE @ShowRegistredUsersRoleID INT;
DECLARE @ShowRegistredUsersTo TINYINT;

DECLARE @HasRegistrationRights BIT;
SET @HasRegistrationRights = 0;

DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @CanViewArticle BIT;
SET @CanViewArticle = 0;

DECLARE @EventExists BIT;
SET @EventExists = 1;

IF @RecurringID IS NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsData] WHERE ArticleID = @ArticleID AND EventType = 1)
		SET @EventExists = 0;
	ELSE IF EXISTS(SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsData] WHERE ArticleID = @ArticleID AND EventType = 1 AND Recurring = 1)
		SET @EventExists = 0;
END
ELSE
BEGIN
	IF NOT EXISTS(
		SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsData] AS ed
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd ON ed.ArticleID = erd.ArticleID AND erd.RecurringID = @RecurringID
		WHERE ed.ArticleID = @ArticleID AND ed.EventType = 1
	)
		SET @EventExists = 0;
END

IF @EventExists = 1
BEGIN

	DECLARE @PermissionsByPortal BIT;
	DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);
	
	DECLARE @HasArticlePermissions BIT;
	SET @HasArticlePermissions = (SELECT HasPermissions FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID);

	IF @IsAdminOrSuperUser = 1
	BEGIN
		SET @CanViewArticle = 1;
		SET @HasRegistrationRights = 1;
	END
	ELSE IF @UserID = -1
	BEGIN
		IF @HasArticlePermissions = 1
		BEGIN
			
			IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n 
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
						WHERE aup.ArticleID = @ArticleID
							AND n.HasPermissions = 1
							AND aup.UserID IS NULL
							AND aup.Show = 1
							AND (n.Approved = 1)
							AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
						)
			SET @CanViewArticle = 1;	
					
		END
		ELSE
		BEGIN

			SELECT @PermissionsByPortal = [PermissionsPMSource] FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @News_ModuleID;
			
			IF @PermissionsByPortal = 1 -- po portalu
			BEGIN

				IF EXISTS(
					SELECT [ShowAllCategories] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.[ShowAllCategories] = 1 AND rps.ModuleID IS NULL AND rps.PortalID = @PortalID AND rps.RoleID IS NULL
				)
					INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
				ELSE
				BEGIN
					INSERT INTO @UserViewCategories
					SELECT DISTINCT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
					INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL AND rps.RoleID IS NULL;
				END
				
				IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserViewCategories)
				WHERE n.ArticleID=@ArticleID
					AND n.HasPermissions = 0
					AND n.Approved = 1
					AND n.Active = 1
					AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]
				)
					SET @CanViewArticle = 1;	
			END
			ELSE
			BEGIN
				
				IF EXISTS(
					SELECT [ShowAllCategories] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.[ShowAllCategories] = 1 AND rps.ModuleID = @News_ModuleID AND rps.PortalID = @PortalID AND rps.RoleID IS NULL
				)
					INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
				ELSE
				BEGIN
					INSERT INTO @UserViewCategories
					SELECT DISTINCT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
					INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID = @News_ModuleID AND rps.RoleID IS NULL;
				END
				
				IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserViewCategories)
				WHERE n.ArticleID=@ArticleID
					AND n.HasPermissions = 0
					AND n.Approved = 1
					AND n.Active = 1
					AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]
				)
					SET @CanViewArticle = 1;
			END
			
		END
	END
	ELSE
	BEGIN

		DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
		INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);
		
		IF @HasArticlePermissions = 1
		BEGIN
			
			IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n 
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON n.ArticleID = aup.ArticleID
						WHERE aup.ArticleID = @ArticleID
							AND n.HasPermissions = 1
							AND aup.UserID = @UserID
							AND aup.Show = 1
							AND n.Approved = 1
							AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
						)
				OR EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n 
						INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON n.ArticleID = arp.ArticleID
						WHERE arp.ArticleID = @ArticleID
							AND n.HasPermissions = 1
							AND arp.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
							AND arp.Show = 1
							AND n.Approved = 1
							AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
						)
			BEGIN
				SET @CanViewArticle = 1;	
				
				IF EXISTS(
					SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = @ArticleID AND aup.UserID = @UserID AND aup.EventRegistration = 1
				) OR EXISTS(
					SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp
					WHERE arp.ArticleID = @ArticleID AND arp.EventRegistration = 1 AND arp.RoleID IN(SELECT [RoleID] FROM @UserInRoles)
				)
				SET @HasRegistrationRights = 1;
			END
			
		END
		ELSE
		BEGIN

			
			SELECT @PermissionsByPortal = [PermissionsPMSource] FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @News_ModuleID;
						
			IF @PermissionsByPortal = 1 -- po portalu
			BEGIN

				IF EXISTS(
					SELECT [ShowAllCategories] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.[ShowAllCategories] = 1 AND rps.ModuleID IS NULL AND rps.PortalID = @PortalID AND rps.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				) OR EXISTS(
					SELECT [ShowAllCategories] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
					WHERE ups.[ShowAllCategories] = 1 AND ups.UserID = @UserID AND ups.ModuleID IS NULL AND ups.PortalID = @PortalID
				)
					INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
				ELSE
				BEGIN
					INSERT INTO @UserViewCategories
					SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
					INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID IS NULL
					UNION
					SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
					INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
					WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID IS NULL;
				END
				
				IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserViewCategories)
				WHERE n.ArticleID=@ArticleID
					AND n.HasPermissions = 0
					AND n.Approved = 1
					AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
				)
				BEGIN
					SET @CanViewArticle = 1;
				
					IF EXISTS(
						SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
						WHERE rps.[EventRegistration] = 1 AND rps.ModuleID IS NULL AND rps.PortalID = @PortalID AND rps.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					) OR EXISTS(
						SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
						WHERE ups.[EventRegistration] = 1 AND ups.UserID = @UserID AND ups.ModuleID IS NULL AND ups.PortalID = @PortalID
					)	
					SET @HasRegistrationRights = 1;	
				END			
			END
			ELSE
			BEGIN
				
				IF EXISTS(
					SELECT [ShowAllCategories] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.[ShowAllCategories] = 1 AND rps.ModuleID = @News_ModuleID AND rps.PortalID = @PortalID AND rps.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				) OR EXISTS(
					SELECT [ShowAllCategories] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
					WHERE ups.[ShowAllCategories] = 1 AND ups.UserID = @UserID AND ups.ModuleID = @News_ModuleID AND ups.PortalID = @PortalID 
				)
					INSERT INTO @UserViewCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID;
				ELSE
				BEGIN
					INSERT INTO @UserViewCategories
					SELECT rpsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsRolePremissionsShowCategories] AS rpsc
					INNER JOIN dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps ON rps.PremissionSettingsID = rpsc.PremissionSettingsID
					INNER JOIN @UserInRoles AS uir ON rps.RoleID = uir.RoleID
					WHERE rps.PortalID = @PortalID AND rps.ModuleID = @News_ModuleID
					UNION
					SELECT upsc.[CategoryID] FROM dbo.[dnn_EasyDNNNewsUserPremissionsShowCategories] AS upsc
					INNER JOIN dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups ON ups.PremissionSettingsID = upsc.PremissionSettingsID
					WHERE ups.UserID = @UserID AND ups.PortalID = @PortalID AND ups.ModuleID = @News_ModuleID;
				END
				
				IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserViewCategories)
				WHERE n.ArticleID=@ArticleID
					AND n.HasPermissions = 0
					AND n.Approved = 1
					AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
				)
				BEGIN
					SET @CanViewArticle = 1;
				
					IF EXISTS(
						SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
						WHERE rps.[EventRegistration] = 1 AND rps.ModuleID = @News_ModuleID AND rps.PortalID = @PortalID AND rps.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
					) OR EXISTS(
						SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
						WHERE ups.[EventRegistration] = 1 AND ups.UserID = @UserID AND ups.ModuleID = @News_ModuleID AND ups.PortalID = @PortalID
					)
					SET @HasRegistrationRights = 1;		
				END
			END
			
		END
	END
		
	IF @CanViewArticle = 1
	BEGIN
		
		DECLARE @DisableFurtherRegistration BIT;
		DECLARE @EnableDaysBeforeStartDate INT;
		DECLARE @DisableDaysBeforeStartDate INT;
		DECLARE @StartDate DATETIME;
		DECLARE @EndDate DATETIME;
			
		IF @RecurringID IS NULL
			SELECT @StartDate = [StartDate]
					,@EndDate = [EndDate]
					,@EnableDaysBeforeStartDate = [EnableDaysBeforeStartDate]
					,@DisableDaysBeforeStartDate = [DisableDaysBeforeStartDate]
					,@ShowRegistredUsersRoleID = [ShowRegistredUsersRole]
					,@ShowRegistredUsersTo = [ShowRegistredUsersTo]
					,@DisableFurtherRegistration = [DisableFurtherRegistration]
				FROM dbo.[dnn_EasyDNNNewsEventsData] WHERE ArticleID = @ArticleID
			ELSE
			SELECT @StartDate = erd.[StartDateTime]
					,@EndDate = erd.[EndDateTime]
					,@EnableDaysBeforeStartDate = ed.[EnableDaysBeforeStartDate]
					,@DisableDaysBeforeStartDate = ed.[DisableDaysBeforeStartDate]
					,@ShowRegistredUsersRoleID = [ShowRegistredUsersRole]
					,@ShowRegistredUsersTo = [ShowRegistredUsersTo]
					,@DisableFurtherRegistration = ed.[DisableFurtherRegistration]
				FROM dbo.[dnn_EasyDNNNewsEventsData] AS ed
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd ON ed.ArticleID = erd.ArticleID AND erd.RecurringID = @RecurringID
				WHERE ed.ArticleID = @ArticleID
			  
		DECLARE @registrationEndDate BIT;
		SET @registrationEndDate = 0;
			  
		IF @DisableFurtherRegistration = 0
		BEGIN
			IF @DisableDaysBeforeStartDate IS NULL AND @CurrentDate < @StartDate
				SET @registrationEndDate = 1;
			ELSE IF @CurrentDate < DATEADD(minute,-@DisableDaysBeforeStartDate, @StartDate)
				SET @registrationEndDate = 1;
				
			IF @registrationEndDate = 1
			BEGIN
				IF @EnableDaysBeforeStartDate IS NULL
				BEGIN 
					IF @CurrentDate > (SELECT [PublishDate] FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID)
						SET @IsRegistrationEnabled = 1;
				END
				ELSE IF @CurrentDate > DATEADD(minute,-@EnableDaysBeforeStartDate, @StartDate)
					SET @IsRegistrationEnabled = 1;

			END
			END

	END

END

SELECT @CanViewArticle AS CanViewArticle,
	@HasRegistrationRights AS HasRegistrationRights,
	@IsRegistrationEnabled AS IsRegistrationEnabled,
	@ShowRegistredUsersTo AS ShowRegistredUsersTo,
	@ShowRegistredUsersRoleID AS ShowRegistredUsersRoleID

