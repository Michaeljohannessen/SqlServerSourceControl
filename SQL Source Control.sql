-- Script Setup Section.
DECLARE @Database NVARCHAR(255) = 'YourDatabaseName';

-- Script Variables.
DECLARE @Query NVARCHAR(MAX);

-- Defining Query with Input from Setup Section.
SET @Query = 
'
USE [' + @Database + '];
GO

CREATE SCHEMA [SourceControl];
GO

CREATE TABLE [SourceControl].[ChangeTracking]
(
	ChangeTrackingID	INT NOT NULL IDENTITY(1,1),
    EventDate			DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    EventType			NVARCHAR(255),
    EventDDL			NVARCHAR(MAX),
    DatabaseName		NVARCHAR(255),
    SchemaName			NVARCHAR(255),
    ObjectName			NVARCHAR(255),
    HostName			NVARCHAR(255),
    IPAddress			NVARCHAR(255),
    ProgramName			NVARCHAR(255),
    LoginName			NVARCHAR(255)
)
GO

INSERT [SourceControl].[ChangeTracking]
(
    EventType,
    EventDDL,
    DatabaseName,
    SchemaName,
    ObjectName
)
SELECT
    N''Initial'',
    OBJECT_DEFINITION([object_id]),
    DB_NAME(),
    OBJECT_SCHEMA_NAME([object_id]),
    OBJECT_NAME([object_id])
FROM
    sys.procedures
GO

CREATE TRIGGER [CaptureChanges]
    ON DATABASE
    FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, CREATE_TABLE, ALTER_TABLE, DROP_TABLE, CREATE_VIEW, ALTER_VIEW, DROP_VIEW
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventData XML = EVENTDATA(), @ip VARCHAR(32);

    SELECT @ip = client_net_address
    FROM sys.dm_exec_connections
    WHERE session_id = @@SPID;

    INSERT [' + @Database + '].[SourceControl].[ChangeTracking]
    (
        EventType,
        EventDDL,
        SchemaName,
        ObjectName,
        DatabaseName,
        HostName,
        IPAddress,
        ProgramName,
        LoginName
    )
    SELECT
        @EventData.value(''(/EVENT_INSTANCE/EventType)[1]'',   ''NVARCHAR(100)''), 
        @EventData.value(''(/EVENT_INSTANCE/TSQLCommand)[1]'', ''NVARCHAR(MAX)''),
        @EventData.value(''(/EVENT_INSTANCE/SchemaName)[1]'',  ''NVARCHAR(255)''), 
        @EventData.value(''(/EVENT_INSTANCE/ObjectName)[1]'',  ''NVARCHAR(255)''),
        DB_NAME(), HOST_NAME(), @ip, PROGRAM_NAME(), SUSER_SNAME();
END
GO

SELECT * FROM [' + @Database + '].[SourceControl].[ChangeTracking];
';

PRINT @Query;