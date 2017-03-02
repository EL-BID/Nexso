CREATE TABLE [dbo].[dnn_MetaData] (
    [MetaDataID]          INT             IDENTITY (1, 1) NOT NULL,
    [MetaDataName]        NVARCHAR (100)  NOT NULL,
    [MetaDataDescription] NVARCHAR (2500) NULL,
    CONSTRAINT [PK_dnn_MetaData] PRIMARY KEY CLUSTERED ([MetaDataID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_MetaData_MetaDataName]
    ON [dbo].[dnn_MetaData]([MetaDataName] ASC);

