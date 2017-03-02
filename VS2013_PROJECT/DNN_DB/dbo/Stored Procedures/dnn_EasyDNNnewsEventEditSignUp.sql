CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsEventEditSignUp]
	@News_ModuleID INT,
	@PortalID INT,
	@UserID INT,
	@ArticleID INT,
	@RecurringID INT,
	@IsAdminOrSuperUser BIT,
	@UserStatus TINYINT
AS 
SET NOCOUNT ON;

-- @UserStatus
-- 0 no
-- 1 yes
-- 2 maybe

DECLARE @ReturnCode SMALLINT;
SET @ReturnCode = 0;
-- 0 insert new record
-- -1 value exists do update
-- -6 value exists - do nothing
-- -2 error occurred
-- -3 article doesnt exist
-- -4 dont have artivle view permissions
-- -5 dont have registration permissions

-- trebam dodati i check dates tj od clanka settingse za registraciju

DECLARE @HasRegistrationRights BIT;
SET @HasRegistrationRights = 0;

DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE();

DECLARE @EventRegistrationRole INT;

DECLARE @CanViewArticle BIT;
SET @CanViewArticle = 0;

DECLARE @EventUserItemID INT;
SET @EventUserItemID = 0;

IF @RecurringID IS NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsData] WHERE ArticleID = @ArticleID AND EventType = 1)
		SET @ReturnCode = -3;
	ELSE IF EXISTS(SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsData] WHERE ArticleID = @ArticleID AND EventType = 1 AND Recurring = 1) -- ako je to clanak recurring onda nije dobro
		SET @ReturnCode = -3;
END
ELSE
BEGIN
	IF NOT EXISTS(
		SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsData] AS ed
		INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd ON ed.ArticleID = erd.ArticleID AND erd.RecurringID = @RecurringID
		WHERE ed.ArticleID = @ArticleID AND ed.EventType = 1
	)
		SET @ReturnCode = -3;
END

IF @ReturnCode = 0
BEGIN
	IF @IsAdminOrSuperUser = 1
	BEGIN
		SET @CanViewArticle = 1;
	END
	ELSE
	BEGIN
		DECLARE @HasArticlePermissions BIT;
		SET @HasArticlePermissions = (SELECT HasPermissions FROM dbo.[dnn_EasyDNNNews] WHERE ArticleID = @ArticleID);
		
		DECLARE @UserInRoles TABLE (RoleID INT NOT NULL PRIMARY KEY);
		INSERT INTO @UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND (ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);
		
		IF @HasArticlePermissions = 1
		BEGIN
			IF EXISTS(
				SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = @ArticleID AND aup.UserID = @UserID AND aup.EventRegistration = 1
			) OR EXISTS(
				SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp
				WHERE arp.ArticleID = @ArticleID AND arp.EventRegistration = 1 AND arp.RoleID IN(SELECT [RoleID] FROM @UserInRoles)
			)
			BEGIN
				SET @HasRegistrationRights = 1;

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
						SET @CanViewArticle = 1;
				ELSE
				SET @ReturnCode = -4;			
			END
			ELSE
				SET @ReturnCode = -5;
		END
		ELSE
		BEGIN
		
			DECLARE @PermissionsByPortal BIT;
			SELECT @PermissionsByPortal = [PermissionsPMSource] FROM dbo.[dnn_EasyDNNNewsModuleSettings] WHERE ModuleID = @News_ModuleID;
			
			DECLARE @UserViewCategories TABLE (CategoryID INT NOT NULL PRIMARY KEY);
			
			IF @PermissionsByPortal = 1 -- po portalu
			BEGIN
				IF EXISTS(
					SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.[EventRegistration] = 1 AND rps.ModuleID IS NULL AND rps.PortalID = @PortalID AND rps.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				) OR EXISTS(
					SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
					WHERE ups.[EventRegistration] = 1 AND ups.UserID = @UserID AND ups.ModuleID IS NULL AND ups.PortalID = @PortalID
				)	
				BEGIN
					SET @HasRegistrationRights = 1;
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
				END
				ELSE
					SET @ReturnCode = -5;	
			END
			ELSE
			BEGIN
				IF EXISTS(
					SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
					WHERE rps.[EventRegistration] = 1 AND rps.ModuleID = @News_ModuleID AND rps.PortalID = @PortalID AND rps.RoleID IN (SELECT [RoleID] FROM @UserInRoles)
				) OR EXISTS(
					SELECT [EventRegistration] FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
					WHERE ups.[EventRegistration] = 1 AND ups.UserID = @UserID AND ups.ModuleID = @News_ModuleID AND ups.PortalID = @PortalID
				)	
				BEGIN
					SET @HasRegistrationRights = 1;
					
					IF EXISTS(
						SELECT [ShowAllCategories] FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
						WHERE rps.[ShowAllCategories] = 1 AND rps.ModuleID = @News_ModuleID AND rps.PortalID = @PortalID AND rps.RoleID IN (SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND ( ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate))
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
				END
				ELSE
					SET @ReturnCode = -5;
			END
			
			IF @HasRegistrationRights = 1
			BEGIN
				IF EXISTS (SELECT n.ArticleID FROM dbo.[dnn_EasyDNNNews] AS n
					INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON n.ArticleID = c.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM @UserViewCategories)
					WHERE n.ArticleID=@ArticleID
						AND n.HasPermissions = 0
						AND n.Approved = 1
						AND (n.UserID = @UserID OR (n.Active = 1 AND @CurrentDate BETWEEN n.[PublishDate] AND n.[ExpireDate]))
					)
					SET @CanViewArticle = 1;
				ELSE
					SET @ReturnCode = -4;
			END
		END
	END
	
	IF @CanViewArticle = 1
	BEGIN
		DECLARE @EventUserId INT;

		SELECT @EventUserId=Id FROM dbo.[dnn_EasyDNNNewsEventUsers] WHERE DNNUserID = @UserId
		IF @EventUserId IS NULL
		BEGIN
			INSERT INTO dbo.[dnn_EasyDNNNewsEventUsers] ([DNNUserID],[EmailAuthenticatedUserID]) VALUES (@UserId,NULL)
			SELECT @EventUserId=CAST(SCOPE_IDENTITY() AS INT);
		END
				
		IF @RecurringID IS NULL
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE ArticleID = @ArticleID AND EventUserID=@EventUserId)
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE ArticleID = @ArticleID AND EventUserID=@EventUserId AND [UserStatus] = @UserStatus)
					SET @ReturnCode = -6;
				ELSE
					SET @ReturnCode = -1;
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE RecurringArticleID = @ArticleID AND RecurringID = @RecurringID AND EventUserID=@EventUserId)
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE RecurringArticleID = @ArticleID AND RecurringID = @RecurringID AND EventUserID=@EventUserId AND [UserStatus] = @UserStatus)
					SET @ReturnCode = -6;
				ELSE
					SET @ReturnCode = -1;
			END
		END

		IF @ReturnCode <> -6
		BEGIN
			
			DECLARE @IsRegistrationEnabled BIT;
			SET @IsRegistrationEnabled = 0;
			
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
					  ,@EventRegistrationRole = [EventRegistrationRole]
					  ,@DisableFurtherRegistration = [DisableFurtherRegistration]
				 FROM dbo.[dnn_EasyDNNNewsEventsData] WHERE ArticleID = @ArticleID
			 ELSE
				SELECT @StartDate = erd.[StartDateTime]
					  ,@EndDate = erd.[EndDateTime]
					  ,@EnableDaysBeforeStartDate = ed.[EnableDaysBeforeStartDate]
					  ,@DisableDaysBeforeStartDate = ed.[DisableDaysBeforeStartDate]
					  ,@EventRegistrationRole = ed.[EventRegistrationRole]
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
			 
			IF @IsRegistrationEnabled = 1
			BEGIN
				
				IF @ReturnCode = -1 -- record exists - update !!!
				BEGIN
									
					BEGIN TRY
						IF @RecurringID IS NULL
						BEGIN
							UPDATE dbo.[dnn_EasyDNNNewsEventsUserItems]
								SET [LastModifiedDate] = @CurrentDate
									,[UserStatus] = @UserStatus
							WHERE ArticleID = @ArticleID AND EventUserID=@EventUserId;
							
							SELECT @EventUserItemID = Id FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE ArticleID = @ArticleID AND EventUserID=@EventUserId;
							
						END
						ELSE
						BEGIN
							UPDATE dbo.[dnn_EasyDNNNewsEventsUserItems]
								SET [LastModifiedDate] = @CurrentDate
									,[UserStatus] = @UserStatus
							WHERE RecurringArticleID = @ArticleID AND RecurringID = @RecurringID AND EventUserID=@EventUserId;
							
							SELECT @EventUserItemID = Id FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE RecurringArticleID = @ArticleID AND RecurringID = @RecurringID AND EventUserID=@EventUserId;
							
						END

					END TRY
					BEGIN CATCH
						SET @ReturnCode = -2;
					END CATCH
				
				END
				ELSE
				BEGIN
				
					BEGIN TRY

						IF @RecurringID IS NULL
						BEGIN
							INSERT INTO dbo.[dnn_EasyDNNNewsEventsUserItems]
							   ([ArticleID]
							   ,[EventUserID]
							   ,[ApproveStatus]
							   ,[CreatedOnDate]
							   ,[LastModifiedDate],[NumberOfTickets],[Message],[UserStatus])
						 VALUES
							   (@ArticleID,
							   @EventUserId,
							   1,
							   @CurrentDate,
							   @CurrentDate,1,NULL,@UserStatus)
							   
							   SELECT @EventUserItemID = Id FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE ArticleID = @ArticleID AND EventUserID=@EventUserId;
						END
						ELSE
						BEGIN
							INSERT INTO dbo.[dnn_EasyDNNNewsEventsUserItems]
							   ([RecurringArticleID]
							   ,[RecurringID]
							   ,[EventUserID]
							   ,[ApproveStatus]
							   ,[CreatedOnDate]
							   ,[LastModifiedDate],[NumberOfTickets],[Message],[UserStatus])
						 VALUES
							   (@ArticleID,
							   @RecurringID,
							   @EventUserId,
							   1,
							   @CurrentDate,
							   @CurrentDate,1,NULL,@UserStatus)
							   
						SELECT @EventUserItemID = Id FROM dbo.[dnn_EasyDNNNewsEventsUserItems] WHERE RecurringArticleID = @ArticleID AND RecurringID = @RecurringID AND EventUserID=@EventUserId;
	   
						END

					END TRY
					BEGIN CATCH
						SET @ReturnCode = -2;
					END CATCH
					
				END
				
			END
			ELSE
				SET @EventRegistrationRole = NULL;
		END
	END
END

SELECT @ReturnCode AS ReturnCode, @EventUserItemID AS EventUserItemID, @EventRegistrationRole AS EventRegistrationRole;

