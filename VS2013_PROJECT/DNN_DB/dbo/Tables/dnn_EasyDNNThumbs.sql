CREATE TABLE [dbo].[dnn_EasyDNNThumbs] (
    [ModuleID]         INT           NOT NULL,
    [GalleryID]        INT           NOT NULL,
    [ViewType]         NVARCHAR (50) NULL,
    [Width]            INT           NOT NULL,
    [Height]           INT           NOT NULL,
    [PictureW]         INT           NULL,
    [PictureH]         INT           NULL,
    [ViewerMode]       NVARCHAR (50) NULL,
    [CropVertical]     BIT           NULL,
    [SmartCrop]        BIT           NULL,
    [GallerificRandom] NVARCHAR (50) NULL,
    [CategoryID]       INT           NULL,
    [AllNested]        BIT           CONSTRAINT [DF_dnn_EasyDNNThumbs_AllNested] DEFAULT ((0)) NOT NULL,
    [GrayScale]        BIT           CONSTRAINT [DF_dnn_EasyDNNThumbs_GrayScale] DEFAULT ((0)) NOT NULL,
    [JpegQuality]      INT           CONSTRAINT [DF_dnn_EasyDNNThumbs_JpegQuality] DEFAULT ((97)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNThumbs] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [GalleryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNThumbs_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNThumbs_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);



