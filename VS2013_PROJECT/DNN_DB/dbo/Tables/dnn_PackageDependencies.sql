CREATE TABLE [dbo].[dnn_PackageDependencies] (
    [PackageDependencyID] INT            IDENTITY (1, 1) NOT NULL,
    [PackageID]           INT            NOT NULL,
    [PackageName]         NVARCHAR (128) NOT NULL,
    [Version]             NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_dnn_PackageDependencies] PRIMARY KEY CLUSTERED ([PackageDependencyID] ASC),
    CONSTRAINT [FK_dnn_PackageDependencies_dnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE
);

