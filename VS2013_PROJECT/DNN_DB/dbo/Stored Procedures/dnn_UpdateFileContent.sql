CREATE procedure [dbo].[dnn_UpdateFileContent]

@FileId      int,
@Content     image

as

update dbo.dnn_Files
set    Content = @Content
where  FileId = @FileId

