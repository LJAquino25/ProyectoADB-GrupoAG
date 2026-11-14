--sudo docker exec sqlserver-2025 ls -lh  /backup
--sudo docker exec -it sqlserver-2025 mkdir -p /backup/gestion_biblioteca
--sudo docker exec -it sqlserver-2025 mkdir -p /backup/gestion_biblioteca/Diferencial
--sudo docker exec -it sqlserver-2025 mkdir -p /backup/gestion_biblioteca/Incremental


SELECT @@VERSION
EXEC msdb.dbo.sp_help_job;

USE msdb;

--Job backup [Completo] - Domingo a las 18:00 pm

EXEC sp_add_job
    @job_name = N'Backup completo',
    @enabled = 1,
    @description = N'Backup semanal completo',
    @category_name = N'Database Maintenance';
GO
EXEC sp_add_jobstep
    @job_name = N'Backup completo',
    @step_name = N'Ejecutar Backup',
    @subsystem = N'TSQL',
    @command = N'
    DECLARE @FileName VARCHAR(255);
    SET @FileName = ''/backup/gestion_biblioteca/'' + CONVERT(VARCHAR(8), GETDATE(), 112) + ''_gestion_biblioteca_full.bak'';
    BACKUP DATABASE [gestion_biblioteca] 
    TO DISK = @FileName 
    WITH INIT, FORMAT,NAME = ''Backup Total'';',
    @on_success_action = 1,
    @on_fail_action = 2;
GO
EXEC sp_add_jobschedule
    @job_name = N'Backup completo',
    @name = N'Programacion Backup Completo',
    @freq_type = 8,
    @freq_interval = 1,
    @freq_recurrence_factor= 1,
    @active_start_time = 180000;
GO
EXEC sp_add_jobserver
    @job_name = N'Backup completo',
    @server_name = N'(LOCAL)';
GO
EXEC sp_start_job @job_name = N'Backup completo';

--Job backup [Diferencial] - Martes a Sabado a las 8:00 am

EXEC sp_add_job
    @job_name = N'Backup Diferencial',
    @enabled = 1,
    @description = N'Backup inicio de jornada',
    @category_name = N'Database Maintenance';
GO
EXEC sp_add_jobstep
    @job_name = N'Backup Diferencial',
    @step_name = N'Ejecutar Backup',
    @subsystem = N'TSQL',
    @command = N'
    DECLARE @FileName VARCHAR(255);
    SET @FileName = ''/backup/gestion_biblioteca/Diferencial/'' + CONVERT(VARCHAR(8), GETDATE(), 112) + ''_gestion_biblioteca_diff.bak'';
    BACKUP DATABASE [gestion_biblioteca] 
    TO DISK = @FileName 
    WITH INIT, DIFFERENTIAL,NAME = ''Backup Differential'';',
    @on_success_action = 1,
    @on_fail_action = 2;
GO
EXEC sp_add_jobschedule
    @job_name = N'Backup Diferencial',
    @name = N'Programacion Backup Diferencial',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 080000;
GO
EXEC sp_add_jobserver
    @job_name = N'Backup Diferencial',
    @server_name = N'(LOCAL)';
GO
EXEC sp_start_job @job_name = N'Backup Diferencial';

--Job backup [Incremental] - Todos los dias cadas 2 horas de 8:00 am a 18:00 pm

EXEC sp_add_job
    @job_name = N'Backup Incremental',
    @enabled = 1,
    @description = N'Backup semanal completo',
    @category_name = N'Database Maintenance';
GO
EXEC sp_add_jobstep
    @job_name = N'Backup Incremental',
    @step_name = N'Ejecutar Backup',
    @subsystem = N'TSQL',
    @command = N'
    DECLARE @FileName VARCHAR(255);
    DECLARE @Numero INT;
    SELECT @Numero = COUNT(*) + 1
    FROM msdb.dbo.backupset
    WHERE database_name = ''gestion_biblioteca''
      AND type = ''L''
      AND CAST(backup_start_date AS DATE) = CAST(GETDATE() AS DATE);
    SET @FileName = ''/backup/gestion_biblioteca/Incremental/'' + CONVERT(VARCHAR(8), GETDATE(), 112) + ''_'' + CAST(@Numero AS VARCHAR(5)) + ''_gestion_biblioteca_log.trn'';
    BACKUP LOG [gestion_biblioteca] 
    TO DISK = @FileName 
    WITH INIT, NAME = ''Backup Incremental'';',
    @on_success_action = 1,
    @on_fail_action = 2;
GO
EXEC sp_add_jobschedule
    @job_name = N'Backup Incremental',
    @name = N'Programacion Backup Incremental Lunes a Sabado',
    @freq_type = 4,
    @freq_interval = 126,
    @freq_subday_type = 8,          
    @freq_subday_interval = 2,      
    @active_start_time = 100000,    
    @active_end_time = 180000;
GO
EXEC sp_add_jobschedule
    @job_name = N'Backup Incremental',
    @name = N'Programacion Backup Incremental Domingo',
    @freq_type = 4,   
    @freq_interval = 1,             
    @freq_subday_type = 8,          
    @freq_subday_interval = 2,      
    @active_start_time = 100000,    
    @active_end_time = 160000;      
GO
EXEC sp_add_jobserver
    @job_name = N'Backup Incremental',
    @server_name = N'(LOCAL)';
GO
EXEC sp_start_job @job_name = N'Backup Incremental';
