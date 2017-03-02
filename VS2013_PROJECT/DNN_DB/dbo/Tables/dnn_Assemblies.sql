CREATE TABLE [dbo].[dnn_Assemblies] (
    [AssemblyID]   INT            IDENTITY (1, 1) NOT NULL,
    [PackageID]    INT            NULL,
    [AssemblyName] NVARCHAR (250) NOT NULL,
    [Version]      NVARCHAR (20)  NOT NULL,
    CONSTRAINT [PK_dnn_PackageAssemblies] PRIMARY KEY CLUSTERED ([AssemblyID] ASC),
    CONSTRAINT [FK_dnn_PackageAssemblies_PackageAssemblies] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE
);

