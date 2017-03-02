CREATE TABLE [dbo].[dnn_EasyGalleryCategory] (
    [CategoryID]          INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]            INT             NOT NULL,
    [CategoryName]        NVARCHAR (500)  NULL,
    [CategoryDescription] NVARCHAR (2000) NULL,
    [Position]            INT             NULL,
    [UserID]              INT             NULL,
    [AllUsersView]        BIT             DEFAULT ((1)) NOT NULL,
    [AllUsersEdit]        BIT             DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryCategory] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);



