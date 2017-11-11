-- called using sqlcmd -S %ENV_DBSERVER% -U %ENV_DBUSERNAME% -P %ENV_DBPASSWORD% -d %ENV_DBNAME%

/* Start up script */ 

BEGIN TRANSACTION StartUpScript
BEGIN TRY

DECLARE @copyId INT = (SELECT TOP 1 computerId FROM ComputerList WITH (TABLOCKX) WHERE computerName = 'RecognitionTemplate')

/* Find the new computerId */
DECLARE @targetId INT = (SELECT MAX (computerId) FROM ComputerList) + 1

/* duplicate ComputerList Recognizer server entry based on another recognizer entry*/
INSERT INTO ComputerList (computerId, computerName, isUPlatform, isDBServer, isWebServer, isConfigurationServer, isInteractionReceiver, inputFolder, startTime, endTime, status, currentStatus, siteId, webPort, webVirtualFolder, webLanguage, installationFolder, recognizersPerServer, recognitionPortRangeStart, remoteSearchMachine, isReportServer, reportsVirtualFolder, reportsPort, reportsUseSSL, useSSL, maxActiveSearchRecognizers, configurationPort, interactionReceiverVirtualFolder, webPhysicalFolder, interactionReceiverPhysicalFolder, interactionReceiverUseSSL, interactionReceiverPort, maxConcurrentExplorationTasks, configServerSuffix)
	SELECT @targetId, HOST_NAME(), isUPlatform, isDBServer, isWebServer, isConfigurationServer, isInteractionReceiver, inputFolder, startTime, endTime, status, currentStatus, siteId, webPort, webVirtualFolder, webLanguage, installationFolder, recognizersPerServer, recognitionPortRangeStart, remoteSearchMachine, isReportServer, reportsVirtualFolder, reportsPort, reportsUseSSL, useSSL, maxActiveSearchRecognizers, configurationPort, interactionReceiverVirtualFolder, webPhysicalFolder, interactionReceiverPhysicalFolder, interactionReceiverUseSSL, interactionReceiverPort, maxConcurrentExplorationTasks, configServerSuffix
	FROM ComputerList WHERE computerId = @copyId

/* duplicate TaskList recognizer tasks */
SELECT * INTO TasksToCopy FROM TaskList WITH (TABLOCKX) WHERE m_hostComputerId = @copyId

DECLARE @tasksCounter INT = (SELECT COUNT (index1) FROM TasksToCopy)
DECLARE @targetIndex INT = (SELECT MAX (index1) FROM TaskList) + 1 
DECLARE @copyIndex INT

WHILE @tasksCounter > 0 
BEGIN
	SET @copyIndex = (SELECT MIN (index1) FROM TasksToCopy)
	INSERT INTO TaskList (appName, machineName, index1, m_taskLogName, m_hostComputerId, m_lowerKey, m_upperKey)
	SELECT appName, machineName, @targetIndex, m_taskLogName, @targetId, m_lowerKey, m_upperKey
	FROM TasksToCopy WHERE index1 = @copyIndex 
	SET @tasksCounter = @tasksCounter - 1
	SET @targetIndex = @targetIndex + 1
	DELETE FROM TasksToCopy WHERE index1 = @copyIndex
END
DROP TABLE TasksToCopy

COMMIT TRANSACTION StartUpScript
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION StartUpScript
END CATCH
 
GO
