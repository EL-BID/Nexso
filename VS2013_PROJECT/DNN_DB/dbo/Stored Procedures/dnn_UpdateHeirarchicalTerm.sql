CREATE PROCEDURE [dbo].[dnn_UpdateHeirarchicalTerm] 
	@TermID					int, 
	@VocabularyID			int,
	@ParentTermID			int,
	@Name					nvarchar(250),
	@Description			nvarchar(2500),
	@Weight					int,
	@LastModifiedByUserID	int
AS

	DECLARE @Left				int
	DECLARE @Right				int
	DECLARE @Width				int
	
	SET @Left = (SELECT TermLeft FROM dbo.dnn_Taxonomy_Terms WHERE TermID = @TermID)
	SET @Right = (SELECT TermRight FROM dbo.dnn_Taxonomy_Terms WHERE TermID = @TermID)
	SET @Width = @Right - @Left + 1
	
	BEGIN TRANSACTION
		BEGIN
			-- Temporarily remove term from heirarchy - but retain information about term and children 
			-- (these should now be -n, ...,-2,-1 etc)
			UPDATE dbo.dnn_Taxonomy_Terms 
				SET TermLeft = TermLeft - @Right - 1,
					TermRight = TermRight - @Right - 1
				WHERE TermLeft >= @Left
					AND TermRight <= @Right
					AND VocabularyID = @VocabularyID
			
			IF @@ERROR = 0
				BEGIN
					-- Update Left values for all items that are after the original term
					UPDATE dbo.dnn_Taxonomy_Terms 
						SET TermLeft = TermLeft - @Width 
						WHERE TermLeft >= @Left + @Width
							AND VocabularyID = @VocabularyID

					IF @@ERROR = 0
						BEGIN
						-- Update Right values for all items that are after the original term
							UPDATE dbo.dnn_Taxonomy_Terms 
								SET TermRight = TermRight - @Width 
								WHERE TermRight >= @Right
									AND VocabularyID = @VocabularyID

							IF @@ERROR = 0
								BEGIN
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
							
									SET @Right = @Left + @Width - 1
																	
									-- Update Left values for all items that are after the updated term
									UPDATE dbo.dnn_Taxonomy_Terms 
										SET TermLeft = TermLeft + @Width 
										WHERE TermLeft >= @Left
											AND VocabularyID = @VocabularyID

									IF @@ERROR = 0
										BEGIN
										-- Update Right values for all items that are after the term
											UPDATE dbo.dnn_Taxonomy_Terms 
												SET TermRight = TermRight + @Width 
												WHERE TermRight >= @Left
													AND VocabularyID = @VocabularyID

											IF @@ERROR = 0
												BEGIN
													-- Update Left/Right values for all items temporarily removed from heirarchy
													UPDATE dbo.dnn_Taxonomy_Terms 
														SET TermLeft = TermLeft + @Left + @Width,
															TermRight = TermRight + @Left + @Width
														WHERE TermLeft < 0
															AND TermRight < 0
															AND VocabularyID = @VocabularyID

													IF @@ERROR = 0
														BEGIN
															-- Update Term
															UPDATE dbo.dnn_Taxonomy_Terms
																SET 
																	VocabularyID = @VocabularyID,
																	ParentTermID = @ParentTermID,
																	[Name] = @Name,
																	Description = @Description,
																	Weight = @Weight,
																	LastModifiedByUserID = @LastModifiedByUserID,
																	LastModifiedOnDate = getdate()
															WHERE TermID = @TermID

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
				END
			ELSE
				BEGIN
					-- Rollback the transaction
					ROLLBACK TRANSACTION		
				END
		END

