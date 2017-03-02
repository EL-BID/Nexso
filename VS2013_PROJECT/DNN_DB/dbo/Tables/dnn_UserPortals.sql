CREATE TABLE [dbo].[dnn_UserPortals] (
    [UserId]       INT            NOT NULL,
    [PortalId]     INT            NOT NULL,
    [UserPortalId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedDate]  DATETIME       CONSTRAINT [DF_dnn_UserPortals_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [Authorised]   BIT            CONSTRAINT [DF_dnn_UserPortals_Authorised] DEFAULT ((1)) NOT NULL,
    [IsDeleted]    BIT            CONSTRAINT [DF_dnn_UserPortals_IsDeleted] DEFAULT ((0)) NOT NULL,
    [RefreshRoles] BIT            CONSTRAINT [DF_dnn_UserPortals_RefreshRoles] DEFAULT ((0)) NOT NULL,
    [VanityUrl]    NVARCHAR (100) NULL,
    CONSTRAINT [PK_dnn_UserPortals] PRIMARY KEY CLUSTERED ([UserId] ASC, [PortalId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserPortals]
    ON [dbo].[dnn_UserPortals]([PortalId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserPortals_PortalId_IsDeleted]
    ON [dbo].[dnn_UserPortals]([PortalId] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserPortals_VanityUrl]
    ON [dbo].[dnn_UserPortals]([VanityUrl] ASC)
    INCLUDE([UserId], [PortalId]);

