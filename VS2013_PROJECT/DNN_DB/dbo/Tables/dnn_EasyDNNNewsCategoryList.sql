CREATE TABLE [dbo].[dnn_EasyDNNNewsCategoryList] (
    [CategoryID]     INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]       INT             NULL,
    [CategoryName]   NVARCHAR (200)  NULL,
    [Position]       INT             NULL,
    [ParentCategory] INT             NULL,
    [Level]          INT             NULL,
    [CategoryURL]    NVARCHAR (1500) NULL,
    [CategoryImage]  NVARCHAR (1500) NULL,
    [CategoryText]   NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsCategoryList] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNewsCategoryList_ParentCategory]
    ON [dbo].[dnn_EasyDNNNewsCategoryList]([ParentCategory] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNewsCategoryList_PortalID]
    ON [dbo].[dnn_EasyDNNNewsCategoryList]([PortalID] ASC);

