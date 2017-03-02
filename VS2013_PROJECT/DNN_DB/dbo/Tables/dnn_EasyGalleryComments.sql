CREATE TABLE [dbo].[dnn_EasyGalleryComments] (
    [CommentID]           INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]            INT             NOT NULL,
    [PictureID]           INT             NOT NULL,
    [UserID]              INT             NULL,
    [IsAuthorRegistrated] BIT             NOT NULL,
    [AuthorIP]            NVARCHAR (50)   NOT NULL,
    [AuthorName]          NVARCHAR (100)  NOT NULL,
    [AuthorEmail]         NVARCHAR (250)  NOT NULL,
    [RawComment]          NVARCHAR (2000) NOT NULL,
    [FormatedComment]     NVARCHAR (2000) NOT NULL,
    [DateAdded]           DATETIME        NOT NULL,
    [GoodVotes]           INT             NOT NULL,
    [BadVotes]            INT             NOT NULL,
    [Approved]            BIT             NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryComments] PRIMARY KEY CLUSTERED ([CommentID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryComments_dnn_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryComments_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryComments_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE SET NULL
);

