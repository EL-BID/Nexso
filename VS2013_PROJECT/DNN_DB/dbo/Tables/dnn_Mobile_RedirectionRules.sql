CREATE TABLE [dbo].[dnn_Mobile_RedirectionRules] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [RedirectionId] INT           NOT NULL,
    [Capability]    NVARCHAR (50) NOT NULL,
    [Expression]    NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_Mobile_RedirectionRules] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dnn_Mobile_RedirectionRules_dnn_Mobile_Redirections] FOREIGN KEY ([RedirectionId]) REFERENCES [dbo].[dnn_Mobile_Redirections] ([Id]) ON DELETE CASCADE
);

