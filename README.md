# MSSQL Source Control
This repository contains a script that creates a table to hold information about changes made on the aimed database.  

## Requirements
To use the component in your own environment, you need Microsoft SQL Server 2008 and above.

## How to Use
 - Copy the script into `SQL Server Management Studio`.
 - Change the `@database`-variable so it matches the database you want to aim.
 - Execute the script and you will recieve a script as output. Execute this script to initiate the Source Control. (containts a trigger and a table) 
 - You can now script your history from `[SourceControl].[ChangeTracking]`.

## How to Query
```sql
SELECT * FROM [SourceControl].[ChangeTracking] ORDER BY EventDate DESC;
```

## How to Test
```sql
CREATE VIEW [Test] AS SELECT 1 AS 'ONE';
GO

SELECT * FROM [SourceControl].[ChangeTracking] ORDER BY EventDate DESC;

DROP VIEW [TEST];
GO
```

## Whats Next?
This small script component was created for fun. The idea came from a request i had years back on a older version of SQL Server, and i thought that this new updated version might be useful for someone.

If you have any change requests or ideas for further development on this script, fell free to contribute to the solution or contact me at mjo@pro-solution.dk.