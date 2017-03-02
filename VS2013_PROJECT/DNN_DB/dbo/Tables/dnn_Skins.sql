CREATE TABLE [dbo].[dnn_Skins] (
    [SkinID]        INT            IDENTITY (1, 1) NOT NULL,
    [SkinPackageID] INT            NOT NULL,
    [SkinSrc]       NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_dnn_Skins] PRIMARY KEY CLUSTERED ([SkinID] ASC),
    CONSTRAINT [FK_dnn_Skins_dnn_SkinPackages] FOREIGN KEY ([SkinPackageID]) REFERENCES [dbo].[dnn_SkinPackages] ([SkinPackageID]) ON DELETE CASCADE
);

