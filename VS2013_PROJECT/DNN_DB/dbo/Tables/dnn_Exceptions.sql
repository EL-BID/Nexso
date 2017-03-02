CREATE TABLE [dbo].[dnn_Exceptions] (
    [ExceptionHash]   VARCHAR (100)  NOT NULL,
    [Message]         NVARCHAR (500) NOT NULL,
    [StackTrace]      NVARCHAR (MAX) NULL,
    [InnerMessage]    NVARCHAR (500) NULL,
    [InnerStackTrace] NVARCHAR (MAX) NULL,
    [Source]          NVARCHAR (500) NULL,
    CONSTRAINT [PK_dnn_Exceptions] PRIMARY KEY CLUSTERED ([ExceptionHash] ASC)
);

