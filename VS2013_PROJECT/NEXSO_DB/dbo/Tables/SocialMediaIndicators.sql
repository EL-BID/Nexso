CREATE TABLE [dbo].[SocialMediaIndicators] (
    [SocialMediaIndicatorId] UNIQUEIDENTIFIER NOT NULL,
    [ObjectId]               UNIQUEIDENTIFIER NOT NULL,
    [ObjectType]             VARCHAR (50)     NOT NULL,
    [UserId]                 INT              NULL,
    [IndicatorType]          VARCHAR (50)     NOT NULL,
    [Value]                  DECIMAL (12, 2)  NOT NULL,
    [Created]                DATETIME         NULL,
    [Unit]                   VARBINARY (50)   NULL,
    [Aggregator]             VARCHAR (10)     NOT NULL,
    CONSTRAINT [PK_SocialMediaIndicators] PRIMARY KEY CLUSTERED ([SocialMediaIndicatorId] ASC),
    CONSTRAINT [FK_SocialMediaIndicators_UserProperties] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[SocialMediaIndicators] NOCHECK CONSTRAINT [FK_SocialMediaIndicators_UserProperties];



