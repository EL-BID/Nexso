CREATE TABLE [dbo].[dnn_EasyDNNNews] (
    [ArticleID]                      INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]                       INT             NOT NULL,
    [UserID]                         INT             NULL,
    [Title]                          NVARCHAR (800)  NOT NULL,
    [SubTitle]                       NVARCHAR (4000) NULL,
    [Summary]                        NVARCHAR (4000) NULL,
    [Article]                        NVARCHAR (MAX)  NULL,
    [ArticleImage]                   NVARCHAR (550)  NULL,
    [DateAdded]                      DATETIME        CONSTRAINT [DF_dnn_EasyDNNNews_DateAdded] DEFAULT (getutcdate()) NOT NULL,
    [LastModified]                   DATETIME        CONSTRAINT [DF_dnn_EasyDNNNews_LastModified] DEFAULT (getutcdate()) NOT NULL,
    [PublishDate]                    DATETIME        CONSTRAINT [DF_dnn_EasyDNNNews_PublishDate] DEFAULT (getutcdate()) NOT NULL,
    [ExpireDate]                     DATETIME        NULL,
    [NumberOfViews]                  INT             NOT NULL,
    [RatingValue]                    DECIMAL (18, 4) NULL,
    [RatingCount]                    INT             NOT NULL,
    [TitleLink]                      NVARCHAR (800)  NOT NULL,
    [DetailType]                     VARCHAR (10)    NULL,
    [DetailTypeData]                 NVARCHAR (400)  NULL,
    [DetailsTemplate]                NVARCHAR (50)   NULL,
    [DetailsTheme]                   NVARCHAR (50)   NULL,
    [GalleryPosition]                NVARCHAR (50)   NULL,
    [GalleryDisplayType]             NVARCHAR (50)   NULL,
    [CommentsTheme]                  NVARCHAR (50)   NULL,
    [ArticleImageFolder]             NVARCHAR (250)  NULL,
    [NumberOfComments]               INT             NULL,
    [MetaDecription]                 NVARCHAR (1000) NULL,
    [MetaKeywords]                   NVARCHAR (500)  NULL,
    [DisplayStyle]                   NVARCHAR (50)   NULL,
    [DetailTarget]                   NVARCHAR (20)   CONSTRAINT [DF_dnn__EasyDNNNews_DetailTarget] DEFAULT ('_self') NULL,
    [CleanArticleData]               NVARCHAR (MAX)  CONSTRAINT [DF_dnn_EasyDNNNews_CleanArticleData] DEFAULT ('') NOT NULL,
    [ArticleFromRSS]                 BIT             CONSTRAINT [DF_dnn_EasyDNNNews_ArticleFromRSS] DEFAULT ((0)) NOT NULL,
    [HasPermissions]                 BIT             CONSTRAINT [DF_dnn__EasyDNNNews_HasPermissions] DEFAULT ((0)) NOT NULL,
    [EventArticle]                   BIT             CONSTRAINT [DF_dnn__EasyDNNNews_EventArticle] DEFAULT ((0)) NOT NULL,
    [DetailMediaType]                NVARCHAR (30)   DEFAULT ('Image') NOT NULL,
    [DetailMediaData]                NVARCHAR (1000) NULL,
    [AuthorAliasName]                NVARCHAR (100)  NULL,
    [ShowGallery]                    BIT             DEFAULT ((0)) NOT NULL,
    [ArticleGalleryID]               INT             NULL,
    [MainImageTitle]                 NVARCHAR (500)  NULL,
    [MainImageDescription]           NVARCHAR (2000) NULL,
    [HideDefaultLocale]              BIT             DEFAULT ((0)) NOT NULL,
    [Featured]                       BIT             NOT NULL,
    [Approved]                       BIT             NOT NULL,
    [AllowComments]                  BIT             NOT NULL,
    [Active]                         BIT             NOT NULL,
    [ShowMainImage]                  BIT             NOT NULL,
    [ShowMainImageFront]             BIT             NOT NULL,
    [ArticleImageSet]                BIT             NOT NULL,
    [CFGroupeID]                     INT             NULL,
    [DetailsDocumentsTemplate]       NVARCHAR (250)  NULL,
    [DetailsLinksTemplate]           NVARCHAR (250)  NULL,
    [DetailsRelatedArticlesTemplate] NVARCHAR (250)  NULL,
    CONSTRAINT [PK_dnn_EasyDNNNews] PRIMARY KEY CLUSTERED ([ArticleID] ASC),
    CONSTRAINT [chk_dnn_EasyDNNNews_NumberOfViews] CHECK ([NumberOfViews]>=(0)),
    CONSTRAINT [chk_dnn_EasyDNNNews_RatingCount] CHECK ([RatingCount]>=(0)),
    CONSTRAINT [chk_dnn_EasyDNNNews_Title_Lenght] CHECK (len([Title])>(0)),
    CONSTRAINT [chk_dnn_EasyDNNNews_TitleLink_Lenght] CHECK (len([TitleLink])>(0)),
    CONSTRAINT [FK_dnn_EasyDNNNews_EasyDNNfieldsTemplate] FOREIGN KEY ([CFGroupeID]) REFERENCES [dbo].[dnn_EasyDNNfieldsTemplate] ([FieldsTemplateID]) ON DELETE SET NULL,
    CONSTRAINT [FK_dnn_EasyDNNNews_EasyGallery] FOREIGN KEY ([ArticleGalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE SET NULL,
    CONSTRAINT [FK_dnn_EasyDNNNews_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE SET NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_Active]
    ON [dbo].[dnn_EasyDNNNews]([Active] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_Approved]
    ON [dbo].[dnn_EasyDNNNews]([Approved] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_EventArticle]
    ON [dbo].[dnn_EasyDNNNews]([EventArticle] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_ExpireDate]
    ON [dbo].[dnn_EasyDNNNews]([ExpireDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_Featured]
    ON [dbo].[dnn_EasyDNNNews]([Featured] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_HasPermissions]
    ON [dbo].[dnn_EasyDNNNews]([HasPermissions] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_PortalID]
    ON [dbo].[dnn_EasyDNNNews]([PortalID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_PortalID_HasPermissions_HideDefaultLocale]
    ON [dbo].[dnn_EasyDNNNews]([PortalID] ASC, [HasPermissions] ASC, [HideDefaultLocale] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_PublishDate]
    ON [dbo].[dnn_EasyDNNNews]([PublishDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_UserID]
    ON [dbo].[dnn_EasyDNNNews]([UserID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_Wizard_Suggestion]
    ON [dbo].[dnn_EasyDNNNews]([PortalID] ASC, [HasPermissions] ASC, [HideDefaultLocale] ASC, [Approved] ASC, [Active] ASC, [PublishDate] ASC, [ExpireDate] ASC)
    INCLUDE([ArticleID], [UserID], [ArticleImage], [Featured]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_Wizard_Suggestion2]
    ON [dbo].[dnn_EasyDNNNews]([PortalID] ASC, [HasPermissions] ASC, [EventArticle] ASC, [HideDefaultLocale] ASC, [PublishDate] ASC, [ExpireDate] ASC)
    INCLUDE([ArticleID], [UserID], [Approved], [Active]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_Wizard_Suggestion3]
    ON [dbo].[dnn_EasyDNNNews]([PortalID] ASC, [HideDefaultLocale] ASC, [PublishDate] ASC, [ExpireDate] ASC)
    INCLUDE([ArticleID], [UserID]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNews_Wizard_Suggestion4]
    ON [dbo].[dnn_EasyDNNNews]([PortalID] ASC, [UserID] ASC, [Approved] ASC, [Active] ASC, [PublishDate] ASC, [ExpireDate] ASC);

