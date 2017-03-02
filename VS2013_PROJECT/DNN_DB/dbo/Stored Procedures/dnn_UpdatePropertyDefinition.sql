CREATE PROCEDURE [dbo].[dnn_UpdatePropertyDefinition]
	@PropertyDefinitionId int,
	@DataType int,
	@DefaultValue nvarchar(50),
	@PropertyCategory nvarchar(50),
	@PropertyName nvarchar(50),
	@ReadOnly bit,
	@Required bit,
	@ValidationExpression nvarchar(2000),
	@ViewOrder int,
	@Visible bit,
    @Length int,
    @DefaultVisibility int,
	@LastModifiedByUserID	int

AS
	UPDATE dbo.dnn_ProfilePropertyDefinition 
		SET DataType = @DataType,
			DefaultValue = @DefaultValue,
			PropertyCategory = @PropertyCategory,
			PropertyName = @PropertyName,
			ReadOnly = @ReadOnly,
			Required = @Required,
			ValidationExpression = @ValidationExpression,
			ViewOrder = @ViewOrder,
			Visible = @Visible,
			Length = @Length,
            DefaultVisibility = @DefaultVisibility,
			[LastModifiedByUserID] = @LastModifiedByUserID,	
			[LastModifiedOnDate] = getdate()
		WHERE PropertyDefinitionId = @PropertyDefinitionId

