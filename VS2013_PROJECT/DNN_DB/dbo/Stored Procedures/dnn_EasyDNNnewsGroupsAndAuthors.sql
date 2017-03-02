CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsGroupsAndAuthors]
	@PortalID INT,
	@ModuleID INT,
	@NotInGroupPosition BIT, -- 0 gore, 1 dolje - uvjek false
	@DisplayAll BIT = 1,
	@RoleID INT = -1 -- -1 if role id is not main filter
AS 
DECLARE @i INT, @MaxI INT, @GroupID INT;
DECLARE @TableGroups Table ([PortalID] INT NOT NULL
	,[GroupID] INT NOT NULL
	,[GroupName] NVARCHAR(250) not null
	,[GroupInfo] NVARCHAR(4000) null
	,[GroupImage] NVARCHAR(1000) null
	,[FacebookURL] NVARCHAR(1000) null
	,[TwitterURL] NVARCHAR(1000) null
	,[GooglePlusURL] NVARCHAR(1000) null
	,[LinkedInURL] NVARCHAR(1000) null
	,[Parent] INT NULL
	,[Level] INT NOT NULL
	,[Position] INT NOT NULL
	,[GroupLinkType] tinyINT NOT NULL
	,[GroupURL] NVARCHAR(1000) null
	,[MyRowCount] Int IDENTITY(1,1));
DECLARE @resultTable Table (
	[OrderBy] INT IDENTITY(1,1), [UserID] INT NULL
	,[Username] NVARCHAR(100) null
	,[FirstName] NVARCHAR(50) null
	,[LastName] NVARCHAR(50) null
	,[Email] NVARCHAR(256) null
	,[DisplayName] NVARCHAR(128) null
	,[AuthorProfileID] INT NULL
	,[ShortInfo] NVARCHAR(350) null
	,[ProfileImage] NVARCHAR(1000) null
	,[FacebookURL] NVARCHAR(1000) null
	,[TwitterURL] NVARCHAR(1000) null
	,[GooglePlusURL] NVARCHAR(1000) null
	,[LinkedInURL] NVARCHAR(1000) null
	,[DateAdded] DATETIME NULL
	,[Active] BIT NULL
	,[ArticleCount] INT NULL
	,[AuthorLinkType] TINYINT NULL
	,[AuthorURL] NVARCHAR(1000) null
	,[GroupID] INT NULL
	,[GroupName] NVARCHAR(250) null
	,[GroupInfo] NVARCHAR(4000) null
	,[GroupImage] NVARCHAR(1000) null
	,[GFacebookURL] NVARCHAR(1000) null
	,[GTwitterURL] NVARCHAR(1000) null
	,[GGooglePlusURL] NVARCHAR(1000) null
	,[GLinkedInURL] NVARCHAR(1000) null
	,[Parent] INT NULL
	,[Level] INT NULL
	,[Position] INT NULL
	,[GroupLinkType] TINYINT NULL
	,[GroupURL] NVARCHAR(1000) null);
SET NOCOUNT ON;
 IF @RoleID <> -1
BEGIN
	INSERT INTO @resultTable
		SELECT u.[UserID]
			,u.[Username]
			,u.[FirstName]
			,u.[LastName]
			,u.[Email]
			,u.[DisplayName]
			,ap.[AuthorProfileID]
			,ap.[ShortInfo]
			,ap.[ProfileImage]
			,ap.[FacebookURL]
			,ap.[TwitterURL]
			,ap.[GooglePlusURL]
			,ap.[LinkedInURL]
			,ap.[DateAdded]
			,ap.[Active]
			,ap.[ArticleCount]
			,ap.[LinkType] AS AuthorLinkType
			,ap.[AuthorURL]
			,null,null,null,null,null,null,null,null,null,null,null,null,null
		FROM dbo.[dnn_Users] AS u
			INNER JOIN dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap ON u.UserID = ap.UserID
			INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.UserID = ap.UserID
		WHERE ap.PortalID = @PortalID AND ur.RoleID = @RoleID
		ORDER BY u.DisplayName
END
ELSE
BEGIN
	IF @NotInGroupPosition = 0 -- autori koji nisu u grupi su gore
	BEGIN
		IF @DisplayAll = 1 -- prikazi sve autore
		BEGIN
			INSERT INTO @resultTable
				SELECT u.[UserID]
					,u.[Username]
					,u.[FirstName]
					,u.[LastName]
					,u.[Email]
					,u.[DisplayName]
					,ap.[AuthorProfileID]
					,ap.[ShortInfo]
					,ap.[ProfileImage]
					,ap.[FacebookURL]
					,ap.[TwitterURL]
					,ap.[GooglePlusURL]
					,ap.[LinkedInURL]
					,ap.[DateAdded]
					,ap.[Active]
					,ap.[ArticleCount]
					,ap.[LinkType] AS AuthorLinkType
					,ap.[AuthorURL]
					,null,null,null,null,null,null,null,null,null,null,null,null,null
				FROM dbo.[dnn_Users] AS u
					INNER JOIN dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap ON u.UserID = ap.UserID
				WHERE ap.PortalID = @PortalID AND ap.AuthorProfileID NOT IN (SELECT AuthorProfileID FROM dbo.[dnn_EasyDNNNewsAutorGroupItems])
				ORDER BY u.DisplayName
		END
		ELSE
		BEGIN
			INSERT INTO @resultTable
				SELECT u.[UserID]
					,u.[Username]
					,u.[FirstName]
					,u.[LastName]
					,u.[Email]
					,u.[DisplayName]
					,ap.[AuthorProfileID]
					,ap.[ShortInfo]
					,ap.[ProfileImage]
					,ap.[FacebookURL]
					,ap.[TwitterURL]
					,ap.[GooglePlusURL]
					,ap.[LinkedInURL]
					,ap.[DateAdded]
					,ap.[Active]
					,ap.[ArticleCount]
					,ap.[LinkType] AS AuthorLinkType
					,ap.[AuthorURL]
					,null,null,null,null,null,null,null,null,null,null,null,null,null
				FROM dbo.[dnn_Users] AS u
					INNER JOIN dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap ON u.UserID = ap.UserID
					INNER JOIN dbo.[dnn_EasyDNNNewsModuleAuthorsItems] as mai ON mai.UserID = ap.UserID AND mai.ModuleID = @ModuleID
				WHERE ap.PortalID = @PortalID AND ap.AuthorProfileID NOT IN (SELECT AuthorProfileID FROM dbo.[dnn_EasyDNNNewsAutorGroupItems] as agi INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] as mgi ON agi.GroupId = mgi.GroupID WHERE mgi.ModuleID = @ModuleID)
				ORDER BY u.DisplayName
		END
	END
	
	IF @DisplayAll = 1
	BEGIN
		INSERT INTO @TableGroups SELECT nag.[PortalID]
			,nag.[GroupID]
			,nag.[GroupName]
			,nag.[GroupInfo]
			,nag.[GroupImage]
			,nag.[FacebookURL]
			,nag.[TwitterURL]
			,nag.[GooglePlusURL]
			,nag.[LinkedInURL]
			,nag.[Parent]
			,nag.[Level]
			,nag.[Position]
			,nag.[LinkType] as GroupLinkType
			,nag.[GroupURL]
		FROM dbo.[dnn_EasyDNNNewsAuthorGroups] AS nag
		WHERE nag.[GroupID] IN (SELECT DISTINCT nag.GroupID FROM dbo.[dnn_EasyDNNNewsAuthorGroups] as nag INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON agi.GroupID = nag.GroupID WHERE nag.PortalID = @PortalID)
		ORDER BY nag.Position;
	END
	ELSE
	BEGIN
		INSERT INTO @TableGroups SELECT DISTINCT nag.[PortalID]
			,nag.[GroupID]
			,nag.[GroupName]
			,nag.[GroupInfo]
			,nag.[GroupImage]
			,nag.[FacebookURL]
			,nag.[TwitterURL]
			,nag.[GooglePlusURL]
			,nag.[LinkedInURL]
			,nag.[Parent]
			,nag.[Level]
			,nag.[Position]
			,nag.[LinkType] as GroupLinkType
			,nag.[GroupURL]
		FROM dbo.[dnn_EasyDNNNewsAuthorGroups] AS nag WHERE nag.[GroupID] IN 
			(SELECT DISTINCT nag.GroupID FROM dbo.[dnn_EasyDNNNewsAuthorGroups] as nag
			 INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi
			ON agi.GroupID = nag.GroupID INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON nag.GroupID = mgi.GroupID
			WHERE mgi.ModuleID = @ModuleID AND nag.PortalID = @PortalID)
		ORDER BY nag.Position;
	END
	
	SELECT @MaxI = @@RowCount;
	SELECT @i = 0;
    WHILE @i < @MaxI
	BEGIN
		SET @i = @i + 1;
		SELECT @GroupID = GroupID FROM @TableGroups Where MyRowCount = @i
		INSERT INTO @resultTable
			SELECT
				null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
				,[GroupID]
				,[GroupName]
				,[GroupInfo]
				,[GroupImage]
				,[FacebookURL]
				,[TwitterURL]
				,[GooglePlusURL]
				,[LinkedInURL]
				,[Parent]
				,[Level]
				,[Position]
				,[GroupLinkType]
				,[GroupURL]
			FROM @TableGroups WHERE MyRowCount = @i
		INSERT INTO @resultTable
			SELECT u.[UserID]
				,u.[Username]
				,u.[FirstName]
				,u.[LastName]
				,u.[Email]
				,u.[DisplayName]
				,ap.[AuthorProfileID]
				,ap.[ShortInfo]
				,ap.[ProfileImage]
				,ap.[FacebookURL]
				,ap.[TwitterURL]
				,ap.[GooglePlusURL]
				,ap.[LinkedInURL]
				,ap.[DateAdded]
				,ap.[Active]
				,ap.[ArticleCount]
				,ap.[LinkType] AS AuthorLinkType
				,ap.[AuthorURL]
				,null,null,null,null,null,null,null,null,null,null,null,null,null
			FROM dbo.[dnn_Users] AS u INNER JOIN dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap ON u.UserID = ap.UserID INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON agi.AuthorProfileID = ap.AuthorProfileID
			WHERE agi.GroupID = @GroupID
			ORDER BY u.DisplayName
	END
	IF @NotInGroupPosition = 1
	BEGIN
		IF @DisplayAll = 1
		BEGIN
			INSERT INTO @resultTable
				SELECT u.[UserID]
					,u.[Username]
					,u.[FirstName]
					,u.[LastName]
					,u.[Email]
					,u.[DisplayName]
					,ap.[AuthorProfileID]
					,ap.[ShortInfo]
					,ap.[ProfileImage]
					,ap.[FacebookURL]
					,ap.[TwitterURL]
					,ap.[GooglePlusURL]
					,ap.[LinkedInURL]
					,ap.[DateAdded]
					,ap.[Active]
					,ap.[ArticleCount]
					,ap.[LinkType] AS AuthorLinkType
					,ap.[AuthorURL]
					,null,null,null,null,null,null,null,null,null,null,null,null,null
				FROM dbo.[dnn_Users] AS u
					INNER JOIN dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap ON u.UserID = ap.UserID WHERE ap.PortalID = @PortalID AND ap.AuthorProfileID NOT IN (SELECT AuthorProfileID FROM dbo.[dnn_EasyDNNNewsAutorGroupItems])
				ORDER BY u.DisplayName
		END
		ELSE
		BEGIN
			INSERT INTO @resultTable
				SELECT u.[UserID]
					,u.[Username]
					,u.[FirstName]
					,u.[LastName]
					,u.[Email]
					,u.[DisplayName]
					,ap.[AuthorProfileID]
					,ap.[ShortInfo]
					,ap.[ProfileImage]
					,ap.[FacebookURL]
					,ap.[TwitterURL]
					,ap.[GooglePlusURL]
					,ap.[LinkedInURL]
					,ap.[DateAdded]
					,ap.[Active]
					,ap.[ArticleCount]
					,ap.[LinkType] AS AuthorLinkType
					,ap.[AuthorURL]
					,null,null,null,null,null,null,null,null,null,null,null,null,null
				FROM dbo.[dnn_Users] AS u
					INNER JOIN dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap ON u.UserID = ap.UserID
					INNER JOIN dbo.[dnn_EasyDNNNewsModuleAuthorsItems] as mai ON mai.UserID = ap.UserID AND mai.ModuleID = @ModuleID WHERE ap.PortalID = @PortalID AND ap.AuthorProfileID NOT IN (SELECT AuthorProfileID FROM dbo.[dnn_EasyDNNNewsAutorGroupItems] as agi INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] as mgi ON agi.GroupId = mgi.GroupID WHERE mgi.ModuleID = @ModuleID)
				ORDER BY u.DisplayName
	  END
	END
 END 
 
 SELECT * FROM @resultTable ORDER BY OrderBy;

