CREATE TABLE [dbo].[dnn_JavaScriptLibraries] (
    [JavaScriptLibraryID]     INT            IDENTITY (1, 1) NOT NULL,
    [PackageID]               INT            NOT NULL,
    [LibraryName]             NVARCHAR (200) NOT NULL,
    [Version]                 NVARCHAR (50)  NOT NULL,
    [FileName]                NVARCHAR (100) NOT NULL,
    [ObjectName]              NVARCHAR (100) NOT NULL,
    [PreferredScriptLocation] INT            NOT NULL,
    [CDNPath]                 NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_dnn_JavaScriptLIbraries] PRIMARY KEY CLUSTERED ([JavaScriptLibraryID] ASC),
    CONSTRAINT [FK_dnn_JavaScriptLibrariesdnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE
);

