CREATE TABLE [dbo].[dnn_Packages] (
    [PackageID]            INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT             NULL,
    [Name]                 NVARCHAR (128)  NOT NULL,
    [FriendlyName]         NVARCHAR (250)  NOT NULL,
    [Description]          NVARCHAR (2000) NULL,
    [PackageType]          NVARCHAR (100)  NOT NULL,
    [Version]              NVARCHAR (50)   NOT NULL,
    [License]              NTEXT           NULL,
    [Manifest]             NTEXT           NULL,
    [Owner]                NVARCHAR (100)  NULL,
    [Organization]         NVARCHAR (100)  NULL,
    [Url]                  NVARCHAR (250)  NULL,
    [Email]                NVARCHAR (100)  NULL,
    [ReleaseNotes]         NTEXT           NULL,
    [IsSystemPackage]      BIT             CONSTRAINT [DF_dnn_Packages_IsSystemPackage] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    [FolderName]           NVARCHAR (128)  NULL,
    [IconFile]             NVARCHAR (100)  NULL,
    CONSTRAINT [PK_dnn_Packages] PRIMARY KEY CLUSTERED ([PackageID] ASC),
    CONSTRAINT [FK_dnn_Packages_dnn_PackageTypes] FOREIGN KEY ([PackageType]) REFERENCES [dbo].[dnn_PackageTypes] ([PackageType]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Packages]
    ON [dbo].[dnn_Packages]([Owner] ASC, [Name] ASC, [PackageType] ASC, [PortalID] ASC, [Version] ASC);

