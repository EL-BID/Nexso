CREATE TABLE [dbo].[dnn_EasyGalleryUpload] (
    [ModuleID]     INT            NOT NULL,
    [UserRole]     NVARCHAR (250) NOT NULL,
    [TypeToUpload] NVARCHAR (20)  NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryUpload] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [UserRole] ASC, [TypeToUpload] ASC)
);

