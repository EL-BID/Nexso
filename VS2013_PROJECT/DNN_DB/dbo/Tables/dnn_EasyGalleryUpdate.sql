CREATE TABLE [dbo].[dnn_EasyGalleryUpdate] (
    [UpdateID]      INT           IDENTITY (1, 1) NOT NULL,
    [UpdateVersion] NVARCHAR (20) NOT NULL,
    [Finished]      BIT           NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryUpdate] PRIMARY KEY CLUSTERED ([UpdateID] ASC)
);

