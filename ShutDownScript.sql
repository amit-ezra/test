-- sqlcmd -S %ENV_DBSERVER% -U %ENV_DBUSERNAME% -P %ENV_DBPASSWORD% -d %ENV_DBNAME%

/* Shut down script */

BEGIN TRANSACTION ShutDownScript
BEGIN TRY

/* Check if the last entry in the list is a recogntition server */
DECLARE @maxId INT = (SELECT MAX (computerId) FROM ComputerList WITH (TABLOCKX))
DECLARE @maxRecognitionId INT = (SELECT MAX (m_hostComputerId) FROM TaskList WITH (TABLOCKX) WHERE m_taskLogName = '3')
DECLARE @currentId INT = (SELECT computerId FROM ComputerList WHERE computerName = HOST_NAME())
CREATE TABLE RestartNeeded (computerId INT)

IF @maxId > @maxRecognitionId
BEGIN
	/* Rotate so the last entry will be a recognition server */
	UPDATE ComputerList SET computerId = (@maxId + 1) WHERE computerId = @maxId
	UPDATE ComputerList SET computerId = @maxId WHERE computerId = @maxRecognitionId
	UPDATE ComputerList SET computerId = @maxRecognitionId WHERE computerId = (@maxId + 1)
	
	UPDATE TaskList SET m_hostComputerId = (@maxId + 1) WHERE m_hostComputerId = @maxId
	UPDATE TaskList SET m_hostComputerId = @maxId WHERE m_hostComputerId = @maxRecognitionId	
	UPDATE TaskList SET m_hostComputerId = @maxRecognitionId WHERE m_hostComputerId = (@maxId + 1)
	
	UPDATE ComputerFetchers SET computerId = @maxRecognitionId WHERE computerId = @maxId
	INSERT INTO RestartNeeded VALUES (@maxRecognitionId)
END

IF @maxId = @currentId
BEGIN
	/* Recognition last in list. just remove */
	DELETE FROM ComputerList WHERE computerId = @currentId 
	DELETE FROM TaskList WHERE m_hostComputerId = @currentId
END
ELSE
	BEGIN
	/* Replace last recognition server with current one, and delete */
	UPDATE ComputerList SET computerName = (SELECT computerName FROM ComputerList WHERE computerId = @maxId) WHERE computerId = @currentId
	DELETE FROM ComputerList WHERE computerId = @maxId
	DELETE FROM TaskList WHERE m_hostComputerId = @maxId
	INSERT INTO RestartNeeded VALUES (@currentId)
END
/* Restart needed services */
UPDATE ComputerList SET status = 2 WHERE computerId IN (SELECT computerId FROM RestartNeeded) 
DROP TABLE RestartNeeded

COMMIT TRANSACTION ShutDownScript
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION ShutDownScript
END CATCH
GO