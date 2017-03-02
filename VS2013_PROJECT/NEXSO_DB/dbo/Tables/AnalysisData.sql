CREATE TABLE [dbo].[AnalysisData] (
    [AnalysisDataId] UNIQUEIDENTIFIER CONSTRAINT [DF_AnalysisData_AnalysisDataId] DEFAULT (newid()) NOT NULL,
    [ObjectId]       UNIQUEIDENTIFIER NOT NULL,
    [ObjectType]     VARCHAR (40)     NOT NULL,
    [TypeKey]        VARCHAR (50)     NOT NULL,
    [Value]          VARCHAR (MAX)    NULL,
    [DateCreated]    DATETIME         NULL,
    [DateUpdated]    DATETIME         NULL,
    [Indexed]        BIT              CONSTRAINT [DF_AnalysisData_Indexed] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AnalysisData_1] PRIMARY KEY CLUSTERED ([AnalysisDataId] ASC)
);

