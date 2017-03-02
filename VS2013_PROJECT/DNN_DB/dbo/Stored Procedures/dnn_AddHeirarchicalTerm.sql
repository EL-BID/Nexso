CREATE PROCEDURE [dbo].[dnn_AddHeirarchicalTerm] 
	@VocabularyID		int,
	@ParentTermID		int,
	@Name				nvarchar(250),
	@Description		nvarchar(2500),
	@Weight				int,
	@CreatedByUserID	int
AS

	DECLARE @Left int
	
	-- Get Left value of Sibling that we are inserting before
	SET @Left = (SELECT TOP 1 TermLeft FROM dbo.dnn_Taxonomy_Terms 
						WHERE VocabularyID = @VocabularyID 
							AND ParentTermID = @ParentTermID
							AND Name > @Name
						ORDER BY Name)
						
	-- Term is to be inserted at end of sibling list so get the Right value of the parent, which will become our new left value						
	IF @Left IS NULL
		SET @Left = (SELECT TermRight FROM dbo.dnn_Taxonomy_Terms 
							WHERE VocabularyID = @VocabularyID 
								AND TermID = @ParentTermID)
								
	-- Left is still null means this is the first term in this vocabulary - set the Left to 1
	IF @Left IS NULL
		SET @Left = 1
								
	BEGIN TRANSACTION
		-- Update Left values for all items that are after new term
		UPDATE dbo.dnn_Taxonomy_Terms 
			SET TermLeft = TermLeft + 2 
			WHERE TermLeft >= @Left
				AND VocabularyID = @VocabularyID

		IF @@ERROR = 0
			BEGIN
			-- Update Right values for all items that are after new term
				UPDATE dbo.dnn_Taxonomy_Terms 
					SET TermRight = TermRight + 2 
					WHERE TermRight >= @Left
						AND VocabularyID = @VocabularyID

				IF @@ERROR = 0
					BEGIN
							-- Insert new term
							INSERT INTO dbo.dnn_Taxonomy_Terms (
								VocabularyID,
								ParentTermID,
								[Name],
								Description,
								Weight,
								TermLeft,
								TermRight,
								CreatedByUserID,
								CreatedOnDate,
								LastModifiedByUserID,
								LastModifiedOnDate
							)

							VALUES (
								@VocabularyID,
								@ParentTermID,
								@Name,
								@Description,
								@Weight,
								@Left,
								@Left + 1,
								@CreatedByUserID,
								getdate(),
								@CreatedByUserID,
								getdate()
							)

							SELECT SCOPE_IDENTITY()

							IF @@ERROR = 0
								BEGIN
									COMMIT TRANSACTION
								END
							ELSE
								BEGIN
									-- Rollback the transaction
									ROLLBACK TRANSACTION		
								END
						END
				ELSE
					BEGIN
						-- Rollback the transaction
						ROLLBACK TRANSACTION
					END
			END
		ELSE
			BEGIN
				-- Rollback the transaction
				ROLLBACK TRANSACTION		
			END

