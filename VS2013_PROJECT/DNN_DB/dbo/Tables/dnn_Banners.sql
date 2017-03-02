CREATE TABLE [dbo].[dnn_Banners] (
    [BannerId]      INT             IDENTITY (1, 1) NOT NULL,
    [VendorId]      INT             NOT NULL,
    [ImageFile]     NVARCHAR (100)  NULL,
    [BannerName]    NVARCHAR (100)  NOT NULL,
    [Impressions]   INT             NOT NULL,
    [CPM]           FLOAT (53)      NOT NULL,
    [Views]         INT             CONSTRAINT [DF_dnn_Banners_Views] DEFAULT ((0)) NOT NULL,
    [ClickThroughs] INT             CONSTRAINT [DF_dnn_Banners_ClickThroughs] DEFAULT ((0)) NOT NULL,
    [StartDate]     DATETIME        NULL,
    [EndDate]       DATETIME        NULL,
    [CreatedByUser] NVARCHAR (100)  NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [BannerTypeId]  INT             NULL,
    [Description]   NVARCHAR (2000) NULL,
    [GroupName]     NVARCHAR (100)  NULL,
    [Criteria]      BIT             CONSTRAINT [DF_dnn_Banners_Criteria] DEFAULT ((1)) NOT NULL,
    [URL]           NVARCHAR (255)  NULL,
    [Width]         INT             CONSTRAINT [DF_dnn_Banners_Width] DEFAULT ((0)) NOT NULL,
    [Height]        INT             CONSTRAINT [DF_dnn_Banners_Height] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_Banner] PRIMARY KEY CLUSTERED ([BannerId] ASC),
    CONSTRAINT [FK_dnn_Banner_dnn_Vendor] FOREIGN KEY ([VendorId]) REFERENCES [dbo].[dnn_Vendors] ([VendorId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Banners]
    ON [dbo].[dnn_Banners]([BannerTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Banners_1]
    ON [dbo].[dnn_Banners]([VendorId] ASC);

