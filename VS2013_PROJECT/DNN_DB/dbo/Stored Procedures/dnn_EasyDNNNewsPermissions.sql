CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsPermissions]
    @UserID INT,
    @PortalID INT,
    @ModuleID INT
AS 
SET NOCOUNT ON;
DECLARE @sqlcommand NVARCHAR(max);
DECLARE @paramList NVARCHAR(200);
SET @paramList = N'@UserID INT,@PortalID INT,@ModuleID INT'
SET @sqlcommand = N'SET NOCOUNT ON; '

IF @UserID = -1
BEGIN
	IF @ModuleID IS NULL
		SET @sqlcommand = @sqlcommand + N'
		SELECT [ApproveArticles],[DocumentUpload],[DocumentDownload],[AddEditCategories],[AllowToComment],[ApproveComments],[ViewPaidContent],[ShowSharedGallery],[ShowCustomGallery],[AddArticleToAll],[ShowAllCategories],[AddPerArticle],[PostToSocialNetwork],
			  [SubTitle],[SEO],[Summary],[Text],[Page],[File],[Link],[None],[Tags],[ArticleGallery],[GoogleMap],[ChangeTemplate],[Events],[AllowComments],[Featured],[PublishExpire],[CustomFields],[Links],[EventRegistration],[EnabledEventRegistration]
		FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
		WHERE rps.RoleID IS NULL AND rps.ModuleID IS NULL AND rps.PortalID = @PortalID;'
	ELSE
		SET @sqlcommand = @sqlcommand + N'
		SELECT [ApproveArticles],[DocumentUpload],[DocumentDownload],[AddEditCategories],[AllowToComment],[ApproveComments],[ViewPaidContent],[ShowSharedGallery],[ShowCustomGallery],[AddArticleToAll],[ShowAllCategories],[AddPerArticle],[PostToSocialNetwork],
			  [SubTitle],[SEO],[Summary],[Text],[Page],[File],[Link],[None],[Tags],[ArticleGallery],[GoogleMap],[ChangeTemplate],[Events],[AllowComments],[Featured],[PublishExpire],[CustomFields],[Links],[EventRegistration],[EnabledEventRegistration]
		FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps
		WHERE rps.RoleID IS NULL AND rps.ModuleID = @ModuleID AND rps.PortalID = @PortalID;'
END
ELSE
BEGIN
	SET @sqlcommand = @sqlcommand + N'
	DECLARE @TrueBit BIT; SET @TrueBit = 1;
	DECLARE @FalseBit BIT; SET @FalseBit = 0;
	
	DECLARE @permissionsTable TABLE 
	( 
       [ApproveArticles] BIT
      ,[DocumentUpload] BIT
      ,[DocumentDownload] BIT
      ,[AddEditCategories] BIT
      ,[AllowToComment] BIT
      ,[ApproveComments] BIT
      ,[ViewPaidContent] BIT
      ,[ShowSharedGallery] BIT
      ,[ShowCustomGallery] BIT
      ,[AddArticleToAll] BIT
      ,[ShowAllCategories] BIT
      ,[AddPerArticle] BIT
      ,[PostToSocialNetwork] BIT
      ,[SubTitle] BIT
      ,[SEO] BIT
      ,[Summary] BIT
      ,[Text] BIT
      ,[Page] BIT
      ,[File] BIT
      ,[Link] BIT
      ,[None] BIT
      ,[Tags] BIT
      ,[ArticleGallery] BIT
      ,[GoogleMap] BIT
      ,[ChangeTemplate] BIT
      ,[Events] BIT
      ,[AllowComments] BIT
      ,[Featured] BIT
      ,[PublishExpire] BIT
      ,[CustomFields] BIT
      ,[Links] BIT
      ,[EventRegistration] BIT
      ,[EnabledEventRegistration] BIT
	)
	
	INSERT INTO @permissionsTable
	SELECT [ApproveArticles],[DocumentUpload],[DocumentDownload],[AddEditCategories],[AllowToComment],[ApproveComments],[ViewPaidContent],[ShowSharedGallery],[ShowCustomGallery],[AddArticleToAll],[ShowAllCategories],[AddPerArticle],[PostToSocialNetwork],
        [SubTitle],[SEO],[Summary],[Text],[Page],[File],[Link],[None],[Tags],[ArticleGallery],[GoogleMap],[ChangeTemplate],[Events],[AllowComments],[Featured],[PublishExpire],[CustomFields],[Links],[EventRegistration],[EnabledEventRegistration]
		FROM dbo.[dnn_EasyDNNNewsRolePremissionSettings] AS rps WHERE rps.RoleID IN (SELECT RoleID FROM dbo.[dnn_UserRoles] WHERE UserID = @UserID AND (ExpiryDate IS NULL OR ExpiryDate > GETUTCDATE()) AND (EffectiveDate IS NULL OR EffectiveDate < GETUTCDATE())) '
	IF @ModuleID IS NULL
		SET @sqlcommand = @sqlcommand + N'
		AND rps.ModuleID IS NULL AND rps.PortalID = @PortalID 
		UNION ALL
		SELECT [ApproveArticles],[DocumentUpload],[DocumentDownload],[AddEditCategories],[AllowToComment],[ApproveComments],[ViewPaidContent],[ShowSharedGallery],[ShowCustomGallery],[AddArticleToAll],[ShowAllCategories],[AddPerArticle],[PostToSocialNetwork],
			[SubTitle],[SEO],[Summary],[Text],[Page],[File],[Link],[None],[Tags],[ArticleGallery],[GoogleMap],[ChangeTemplate],[Events],[AllowComments],[Featured],[PublishExpire],[CustomFields],[Links],[EventRegistration],[EnabledEventRegistration]
			FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
		WHERE ups.UserID = @UserID AND ups.ModuleID IS NULL AND ups.PortalID = @PortalID '
	ELSE
		SET @sqlcommand = @sqlcommand + N'
		AND rps.ModuleID = @ModuleID AND rps.PortalID = @PortalID
		UNION ALL
		SELECT [ApproveArticles],[DocumentUpload],[DocumentDownload],[AddEditCategories],[AllowToComment],[ApproveComments],[ViewPaidContent],[ShowSharedGallery],[ShowCustomGallery],[AddArticleToAll],[ShowAllCategories],[AddPerArticle],[PostToSocialNetwork],
			[SubTitle],[SEO],[Summary],[Text],[Page],[File],[Link],[None],[Tags],[ArticleGallery],[GoogleMap],[ChangeTemplate],[Events],[AllowComments],[Featured],[PublishExpire],[CustomFields],[Links],[EventRegistration],[EnabledEventRegistration]
			FROM dbo.[dnn_EasyDNNNewsUserPremissionSettings] AS ups
		WHERE ups.UserID = @UserID AND ups.ModuleID = @ModuleID AND ups.PortalID = @PortalID '
	SET @sqlcommand = @sqlcommand + N'
	
	SELECT
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE ApproveArticles = 1) THEN @TrueBit ELSE @FalseBit END AS ApproveArticles,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE DocumentUpload = 1) THEN @TrueBit ELSE @FalseBit END AS DocumentUpload,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE DocumentDownload = 1) THEN @TrueBit ELSE @FalseBit END AS DocumentDownload,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE AddEditCategories = 1) THEN @TrueBit ELSE @FalseBit END AS AddEditCategories,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE AllowToComment = 1) THEN @TrueBit ELSE @FalseBit END AS AllowToComment,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE ApproveComments = 1) THEN @TrueBit ELSE @FalseBit END AS ApproveComments,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE ViewPaidContent = 1) THEN @TrueBit ELSE @FalseBit END AS ViewPaidContent,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE ShowSharedGallery = 1) THEN @TrueBit ELSE @FalseBit END AS ShowSharedGallery,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE ShowCustomGallery = 1) THEN @TrueBit ELSE @FalseBit END AS ShowCustomGallery,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE AddArticleToAll = 1) THEN @TrueBit ELSE @FalseBit END AS AddArticleToAll,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE ShowAllCategories = 1) THEN @TrueBit ELSE @FalseBit END AS ShowAllCategories,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE AddPerArticle = 1) THEN @TrueBit ELSE @FalseBit END AS AddPerArticle,
		CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE PostToSocialNetwork = 1) THEN @TrueBit ELSE @FalseBit END AS PostToSocialNetwork,
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE SubTitle = 1) THEN @TrueBit ELSE @FalseBit END AS SubTitle,
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE SEO = 1) THEN @TrueBit ELSE @FalseBit END AS SEO, 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE Summary = 1) THEN @TrueBit ELSE @FalseBit END AS Summary, 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [Text] = 1) THEN @TrueBit ELSE @FalseBit END AS [Text], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [Page] = 1) THEN @TrueBit ELSE @FalseBit END AS [Page], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [File] = 1) THEN @TrueBit ELSE @FalseBit END AS [File], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [Link] = 1) THEN @TrueBit ELSE @FalseBit END AS [Link], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [None] = 1) THEN @TrueBit ELSE @FalseBit END AS [None], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [Tags] = 1) THEN @TrueBit ELSE @FalseBit END AS [Tags], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [ArticleGallery] = 1) THEN @TrueBit ELSE @FalseBit END AS [ArticleGallery], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [GoogleMap] = 1) THEN @TrueBit ELSE @FalseBit END AS [GoogleMap], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [ChangeTemplate] = 1) THEN @TrueBit ELSE @FalseBit END AS [ChangeTemplate], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [Events] = 1) THEN @TrueBit ELSE @FalseBit END AS [Events], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [Featured] = 1) THEN @TrueBit ELSE @FalseBit END AS [Featured], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [AllowComments] = 1) THEN @TrueBit ELSE @FalseBit END AS [AllowComments], 
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [PublishExpire] = 1) THEN @TrueBit ELSE @FalseBit END AS [PublishExpire],
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [CustomFields] = 1) THEN @TrueBit ELSE @FalseBit END AS [CustomFields],
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [Links] = 1) THEN @TrueBit ELSE @FalseBit END AS [Links],
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [EventRegistration] = 1) THEN @TrueBit ELSE @FalseBit END AS [EventRegistration],
	    CASE WHEN EXISTS (SELECT 1 FROM @permissionsTable WHERE [EnabledEventRegistration] = 1) THEN @TrueBit ELSE @FalseBit END AS [EnabledEventRegistration] '
END

EXEC sp_executesql @statement = @sqlcommand
	,@paramList = @paramList
	,@UserID = @UserID
	,@PortalID = @PortalID
	,@ModuleID = @ModuleID

