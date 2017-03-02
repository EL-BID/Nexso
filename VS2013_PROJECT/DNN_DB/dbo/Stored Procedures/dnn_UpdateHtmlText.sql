create procedure [dbo].[dnn_UpdateHtmlText]

@ItemID          int,
@Content         ntext,
@Summary		 ntext,
@StateID         int,
@IsPublished     bit,
@UserID          int

as

update dbo.dnn_HtmlText
set    Content              = @Content,
	   Summary				= @Summary,
       StateID              = @StateID,
       IsPublished          = @IsPublished,
       LastModifiedByUserID = @UserID,
       LastModifiedOnDate   = getdate()
where  ItemID = @ItemID

