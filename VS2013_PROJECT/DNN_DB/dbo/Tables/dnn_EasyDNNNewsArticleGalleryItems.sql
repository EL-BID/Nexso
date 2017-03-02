CREATE TABLE [dbo].[dnn_EasyDNNNewsArticleGalleryItems] (
    [ArticleID] INT NOT NULL,
    [GalleryID] INT NOT NULL,
    [Position]  INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsArticleGalleryItems] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [GalleryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleGalleryItems_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleGalleryItems_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE
);

