CREATE TABLE [dbo].[dnn_EasyGallery] (
    [GalleryID]          INT             IDENTITY (1, 1) NOT NULL,
    [CategoryID]         INT             NOT NULL,
    [PortalID]           INT             NOT NULL,
    [GalleryName]        NVARCHAR (500)  NULL,
    [GalleryDescription] NVARCHAR (2000) NULL,
    [Position]           INT             NULL,
    [DateCreated]        DATETIME        NOT NULL,
    [DateLastModified]   DATETIME        NULL,
    [UserID]             INT             NULL,
    [PublishDate]        DATETIME        DEFAULT (getutcdate()) NOT NULL,
    [ExpireDate]         DATETIME        NULL,
    [Active]             BIT             CONSTRAINT [DF_dnn_EasyGallery_Active] DEFAULT ((1)) NOT NULL,
    [Approved]           BIT             CONSTRAINT [DF_dnn_EasyGallery_Approved] DEFAULT ((1)) NOT NULL,
    [NumberOfViews]      INT             DEFAULT ((0)) NOT NULL,
    [AllUsersView]       BIT             DEFAULT ((1)) NOT NULL,
    [AllUsersEdit]       BIT             DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGallery] PRIMARY KEY CLUSTERED ([GalleryID] ASC),
    CONSTRAINT [FK_dnn_EasyGallery_EasyGalleryCategory] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyGalleryCategory] ([CategoryID]) ON DELETE CASCADE
);



