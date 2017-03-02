CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsArticleArchive]
(
	@ArticleID int,
	@numOfHistory int   
)
AS
	DECLARE @latestValue int;
	SET @latestValue = 0;
	DECLARE @numOfHistoryDB int;
	SET @numOfHistoryDB = 0;

        SET NOCOUNT ON;      
        BEGIN
		IF @numOfHistory = 0
			BEGIN
				DELETE FROM dbo.[dnn_EasyDNNNewsArchive] WHERE ArticleID = @ArticleID;
			END
        ELSE
			BEGIN
				SELECT @numOfHistoryDB = CASE WHEN Count(HistoryVersion) IS NULL THEN 0 ELSE Count(HistoryVersion) END FROM dbo.[dnn_EasyDNNNewsArchive] WHERE ArticleID=@ArticleID;
				IF @numOfHistoryDB <> 0 AND @numOfHistoryDB >= @numOfHistory -- if contains history items and if need to delete overflow items
				BEGIN
					DELETE FROM dbo.[dnn_EasyDNNNewsArchive] WHERE ArticleID = @ArticleID AND HistoryEntryID IN
						 (SELECT TOP(@numOfHistoryDB - @numOfHistory + 1) HistoryEntryID FROM dbo.[dnn_EasyDNNNewsArchive]
						  WHERE ArticleID = @ArticleID ORDER BY HistoryVersion ASC);
					With cte As
						(
						SELECT ArticleID, HistoryVersion, ROW_NUMBER() OVER (ORDER BY HistoryVersion ASC) AS RN FROM dbo.[dnn_EasyDNNNewsArchive] WHERE ArticleID=@ArticleID
						)
						UPDATE cte SET HistoryVersion=RN  WHERE ArticleID=@ArticleID;
				END
			END
				
		IF @numOfHistory <> 0
		BEGIN
			SELECT @latestValue = CASE WHEN max(HistoryVersion) IS NULL THEN 1 ELSE max(HistoryVersion) + 1 END FROM dbo.[dnn_EasyDNNNewsArchive] WHERE ArticleID = @ArticleID;	

			INSERT INTO dbo.[dnn_EasyDNNNewsArchive] 
				([PortalID]
				  ,[UserID]
				  ,[Title]
				  ,[SubTitle]
				  ,[Summary]
				  ,[Article]
				  ,[ArticleImage]
				  ,[LastModified]
				  ,[PublishDate]
				  ,[ExpireDate]
				  ,[Featured]
				  ,[AllowComments]
				  ,[TitleLink]
				  ,[DetailType]
				  ,[DetailTypeData]
				  ,[DetailsTemplate]
				  ,[DetailsTheme]
				  ,[GalleryPosition]
				  ,[GalleryDisplayType]
				  ,[ShowMainImage]
				  ,[ShowMainImageFront]
				  ,[CommentsTheme]
				  ,[ArticleImageFolder]
				  ,[HistoryVersion]
				  ,n.[ArticleID])
			SELECT
				   n.[PortalID]
				  ,n.[UserID]
				  ,n.[Title]
				  ,n.[SubTitle]
				  ,n.[Summary]
				  ,n.[Article]
				  ,n.[ArticleImage]
				  ,n.[LastModified]
				  ,n.[PublishDate]
				  ,n.[ExpireDate]
				  ,n.[Featured]
				  ,n.[AllowComments]
				  ,n.[TitleLink]
				  ,n.[DetailType]
				  ,n.[DetailTypeData]
				  ,n.[DetailsTemplate]
				  ,n.[DetailsTheme]
				  ,n.[GalleryPosition]
				  ,n.[GalleryDisplayType]
				  ,n.[ShowMainImage]
				  ,n.[ShowMainImageFront]
				  ,n.[CommentsTheme]
				  ,n.[ArticleImageFolder]
				  ,[HistoryVersion] = @latestValue
				  ,n.[ArticleID]
			FROM dbo.[dnn_EasyDNNNews] AS n WHERE ArticleID = @ArticleID;
		 END
        END


