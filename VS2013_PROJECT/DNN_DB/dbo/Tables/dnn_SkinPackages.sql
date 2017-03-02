CREATE TABLE [dbo].[dnn_SkinPackages] (
    [SkinPackageID]        INT           IDENTITY (1, 1) NOT NULL,
    [PackageID]            INT           NOT NULL,
    [PortalID]             INT           NULL,
    [SkinName]             NVARCHAR (50) NOT NULL,
    [SkinType]             NVARCHAR (20) NOT NULL,
    [CreatedByUserID]      INT           NULL,
    [CreatedOnDate]        DATETIME      NULL,
    [LastModifiedByUserID] INT           NULL,
    [LastModifiedOnDate]   DATETIME      NULL,
    CONSTRAINT [PK_dnn_SkinPackages] PRIMARY KEY CLUSTERED ([SkinPackageID] ASC),
    CONSTRAINT [FK_dnn_SkinPackages_dnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE ON UPDATE CASCADE
);

