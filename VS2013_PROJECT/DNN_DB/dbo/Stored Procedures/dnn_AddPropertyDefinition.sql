CREATE PROCEDURE [dbo].[dnn_AddPropertyDefinition]
	@PortalId int,
	@ModuleDefId int,
	@DataType int,
	@DefaultValue nvarchar(max),
	@PropertyCategory nvarchar(50),
	@PropertyName nvarchar(50),
	@ReadOnly bit,
	@Required bit,
	@ValidationExpression nvarchar(2000),
	@ViewOrder int,
	@Visible bit,
    @Length int,
    @DefaultVisibility int,
	@CreatedByUserID int

AS
	DECLARE @PropertyDefinitionId int

	SELECT @PropertyDefinitionId = PropertyDefinitionId
		FROM   dbo.dnn_ProfilePropertyDefinition
		WHERE  (PortalId = @PortalId OR (PortalId IS NULL AND @PortalId IS NULL))
			AND PropertyName = @PropertyName
			
	IF @vieworder=-1
		BEGIN
			SELECT	@vieworder = MAX(ViewOrder) + 1 
			FROM	dbo.dnn_ProfilePropertyDefinition
		END

	IF @PropertyDefinitionId IS NULL
		BEGIN
			INSERT dbo.dnn_ProfilePropertyDefinition	(
					PortalId,
					ModuleDefId,
					Deleted,
					DataType,
					DefaultValue,
					PropertyCategory,
					PropertyName,
					ReadOnly,
					Required,
					ValidationExpression,
					ViewOrder,
					Visible,
					Length,
                    DefaultVisibility,
					[CreatedByUserID],
					[CreatedOnDate],
					[LastModifiedByUserID],
					[LastModifiedOnDate]

				)
				VALUES	(
					@PortalId,
					@ModuleDefId,
					0,
					@DataType,
					@DefaultValue,
					@PropertyCategory,
					@PropertyName,
					@ReadOnly,
					@Required,
					@ValidationExpression,
					@ViewOrder,
					@Visible,
					@Length,
                    @DefaultVisibility,
					@CreatedByUserID,
  					getdate(),
  					@CreatedByUserID,
  					getdate()
				)

			SELECT @PropertyDefinitionId = SCOPE_IDENTITY()
		END
	ELSE
		BEGIN
			UPDATE dbo.dnn_ProfilePropertyDefinition 
				SET DataType = @DataType,
					ModuleDefId = @ModuleDefId,
					DefaultValue = @DefaultValue,
					PropertyCategory = @PropertyCategory,
					ReadOnly = @ReadOnly,
					Required = @Required,
					ValidationExpression = @ValidationExpression,
					ViewOrder = @ViewOrder,
					Deleted = 0,
					Visible = @Visible,
					Length = @Length,
                    DefaultVisibility = @DefaultVisibility,
					[LastModifiedByUserID] = @CreatedByUserID,	
					[LastModifiedOnDate] = getdate()
				WHERE PropertyDefinitionId = @PropertyDefinitionId
		END
		
	SELECT @PropertyDefinitionId

