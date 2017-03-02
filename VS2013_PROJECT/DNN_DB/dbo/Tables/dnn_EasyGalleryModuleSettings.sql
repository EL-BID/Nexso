CREATE TABLE [dbo].[dnn_EasyGalleryModuleSettings] (
    [ModuleID]                 INT NOT NULL,
    [PortalID]                 INT NOT NULL,
    [EnableCommunityMode]      BIT NOT NULL,
    [EnableAutoResize]         BIT NOT NULL,
    [ResizeWidth]              INT NOT NULL,
    [ResizeHeight]             INT NOT NULL,
    [EnablePostingToJournal]   BIT NOT NULL,
    [AutoJournalPost]          BIT NOT NULL,
    [ModuleToOpenDetails]      INT NOT NULL,
    [TabToOpenDetails]         INT NOT NULL,
    [ModuleToOpenGroupDetails] INT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryModuleSettings] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [PortalID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryModuleSettings_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

