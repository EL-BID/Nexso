CREATE TABLE [dbo].[dnn_EasyDNNNewsUserPremissionSettings] (
    [PremissionSettingsID]     INT IDENTITY (1, 1) NOT NULL,
    [PortalID]                 INT NOT NULL,
    [ModuleID]                 INT NULL,
    [UserID]                   INT NOT NULL,
    [ApproveArticles]          BIT NOT NULL,
    [DocumentUpload]           BIT NOT NULL,
    [DocumentDownload]         BIT NOT NULL,
    [AddEditCategories]        BIT NOT NULL,
    [AllowToComment]           BIT NOT NULL,
    [ApproveComments]          BIT NOT NULL,
    [ViewPaidContent]          BIT NOT NULL,
    [ShowSharedGallery]        BIT NOT NULL,
    [ShowCustomGallery]        BIT NOT NULL,
    [AddArticleToAll]          BIT NOT NULL,
    [ShowAllCategories]        BIT NOT NULL,
    [AddPerArticle]            BIT CONSTRAINT [DF_dnn__EasyDNNNewsUserPremissionSettings_AddPerArticle] DEFAULT ((0)) NOT NULL,
    [PostToSocialNetwork]      BIT DEFAULT ((0)) NOT NULL,
    [ApproveArticle]           BIT DEFAULT ((0)) NOT NULL,
    [ApproveUpdateArticle]     BIT DEFAULT ((0)) NOT NULL,
    [EditOwnArticle]           BIT DEFAULT ((0)) NOT NULL,
    [SubTitle]                 BIT DEFAULT ((1)) NOT NULL,
    [SEO]                      BIT DEFAULT ((1)) NOT NULL,
    [Summary]                  BIT DEFAULT ((1)) NOT NULL,
    [Text]                     BIT DEFAULT ((1)) NOT NULL,
    [Page]                     BIT DEFAULT ((1)) NOT NULL,
    [File]                     BIT DEFAULT ((1)) NOT NULL,
    [Link]                     BIT DEFAULT ((1)) NOT NULL,
    [None]                     BIT DEFAULT ((1)) NOT NULL,
    [Tags]                     BIT DEFAULT ((1)) NOT NULL,
    [ArticleGallery]           BIT DEFAULT ((1)) NOT NULL,
    [GoogleMap]                BIT DEFAULT ((1)) NOT NULL,
    [ChangeTemplate]           BIT DEFAULT ((1)) NOT NULL,
    [Events]                   BIT DEFAULT ((1)) NOT NULL,
    [AllowComments]            BIT DEFAULT ((1)) NOT NULL,
    [Featured]                 BIT DEFAULT ((1)) NOT NULL,
    [PublishExpire]            BIT DEFAULT ((1)) NOT NULL,
    [CustomFields]             BIT CONSTRAINT [DF_dnn_EasyDNNNewsUserPremissionSettings_CustomFields] DEFAULT ((0)) NOT NULL,
    [CFGroupeID]               BIT CONSTRAINT [DF_dnn_EasyDNNNewsUserPremissionSettings_CFGroupeID] DEFAULT ((0)) NOT NULL,
    [Links]                    BIT CONSTRAINT [DF_dnn_EasyDNNNewsUserPremissionSettings_Links] DEFAULT ((0)) NOT NULL,
    [EnabledEventRegistration] BIT CONSTRAINT [DF_dnn_EasyDNNNewsUserPremissionSettings_EnabledEventRegistration] DEFAULT ((1)) NOT NULL,
    [EventRegistration]        BIT CONSTRAINT [DF_dnn_EasyDNNNewsUserPremissionSettings_EventRegistration] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsUserPremissionSettings] PRIMARY KEY CLUSTERED ([PremissionSettingsID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsUserPremissionSettings_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsUserPremissionSettings_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsUserPremissionSettings_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsUserPremissionSettings] UNIQUE NONCLUSTERED ([PortalID] ASC, [ModuleID] ASC, [UserID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EDNUserPremissionSettings_FK_ModuleID]
    ON [dbo].[dnn_EasyDNNNewsUserPremissionSettings]([ModuleID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EDNUserPremissionSettings_FK_PortalID]
    ON [dbo].[dnn_EasyDNNNewsUserPremissionSettings]([PortalID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EDNUserPremissionSettings_FK_UserID]
    ON [dbo].[dnn_EasyDNNNewsUserPremissionSettings]([UserID] ASC);

