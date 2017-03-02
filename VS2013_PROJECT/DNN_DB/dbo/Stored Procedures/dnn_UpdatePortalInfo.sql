CREATE PROCEDURE [dbo].[dnn_UpdatePortalInfo]
	@PortalID				INT,
	@PortalGroupID			INT,
	@PortalName				NVARCHAR(128),
	@LogoFile				NVARCHAR(50),
	@FooterText				NVARCHAR(100),
	@ExpiryDate				DATETIME,
	@UserRegistration		INT,
	@BannerAdvertising		INT,
	@Currency				CHAR(3),
	@AdministratorId		INT,
	@HostFee				MONEY,
	@HostSpace				INT,
	@PageQuota				INT,
	@UserQuota				INT,
	@PaymentProcessor		NVARCHAR(50),
	@ProcessorUserId		NVARCHAR(50),
	@ProcessorPassword		NVARCHAR(50),
	@Description			NVARCHAR(500),
	@KeyWords				NVARCHAR(500),
	@BackgroundFile			NVARCHAR(50),
	@SiteLogHistory			INT,
	@SplashTabId			INT,
	@HomeTabId				INT,
	@LoginTabId				INT,
	@RegisterTabId			INT,
	@UserTabId				INT,
	@SearchTabId			INT,
    @Custom404TabId			INT,
    @Custom500TabId			INT,
	@DefaultLanguage		NVARCHAR(10),
	@HomeDirectory			VARCHAR(100),
	@LastModifiedByUserID	INT,
	@CultureCode			NVARCHAR(50)

AS

	UPDATE dbo.dnn_Portals
		SET    
		   PortalGroupID		= @PortalGroupID,
		   ExpiryDate			= @ExpiryDate,
		   UserRegistration		= @UserRegistration,
		   BannerAdvertising	= @BannerAdvertising,
		   Currency				= @Currency,
		   AdministratorId		= @AdministratorId,
		   HostFee				= @HostFee,
		   HostSpace			= @HostSpace,
		   PageQuota			= @PageQuota,
		   UserQuota			= @UserQuota,
		   PaymentProcessor		= @PaymentProcessor,
		   ProcessorUserId		= @ProcessorUserId,
		   ProcessorPassword	= @ProcessorPassword,
		   SiteLogHistory		= @SiteLogHistory,
		   DefaultLanguage		= @DefaultLanguage,
		   HomeDirectory		= @HomeDirectory,
		   LastModifiedByUserID = @LastModifiedByUserID,
		   LastModifiedOnDate	= GETDATE()
	WHERE  PortalId = @PortalID

    IF EXISTS (SELECT * FROM dbo.dnn_PortalLocalization WHERE PortalId = @PortalID AND CultureCode = @CultureCode)
	BEGIN 
		UPDATE dbo.dnn_PortalLocalization
			SET
				PortalName				= @PortalName,
				LogoFile				= @LogoFile,
				FooterText				= @FooterText,
				Description				= @Description,
				KeyWords				= @KeyWords,
				BackgroundFile			= @BackgroundFile,
				HomeTabId				= @HomeTabId,
				LoginTabId				= @LoginTabId,
				RegisterTabId			= @RegisterTabId,
				UserTabId				= @UserTabId,
				SplashTabId				= @SplashTabId,
				SearchTabId				= @SearchTabId,
                Custom404TabId			= @Custom404TabId,
                Custom500TabId			= @Custom500TabId,
				LastModifiedByUserID	= @LastModifiedByUserID,
				LastModifiedOnDate		= GETDATE()
		WHERE	PortalId = @PortalID 
			AND CultureCode = @CultureCode
	END 
ELSE
	BEGIN 
		DECLARE @AdminTabId int
		SET @AdminTabId = (SELECT AdminTabId 
								FROM dbo.dnn_PortalLocalization 
								WHERE PortalID = @PortalID AND CultureCode='en-US')

		INSERT INTO dbo.dnn_PortalLocalization (
			[PortalID],
			[CultureCode],
			[PortalName],
			[LogoFile],
			[FooterText],
			[Description],
			[KeyWords],
			[BackgroundFile],
			[HomeTabId],
			[LoginTabId],
			[UserTabId],
			[AdminTabId],
			[SplashTabId],
			[SearchTabId],
            [Custom404TabId],
            [Custom500TabId],
			[CreatedByUserID],
			[CreatedOnDate],
			[LastModifiedByUserID],
			[LastModifiedOnDate]
		)
		VALUES (
			@PortalID,
			@CultureCode,
			@PortalName,
			@LogoFile, 
			@FooterText,
			@Description,
			@KeyWords,
			@BackgroundFile,
			@HomeTabId ,
			@LoginTabId ,
			@UserTabId,
			@AdminTabid,
			@SplashTabId,
			@SearchTabId,
            @Custom404TabId,
            @Custom500TabId,
			-1,
			GETDATE(),
			-1,
			GETDATE()
		)
	END

