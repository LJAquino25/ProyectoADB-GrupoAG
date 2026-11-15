SELECT @@VERSION
EXEC msdb.dbo.sp_help_job;

USE msdb;

EXEC sp_add_operator --Operador 
    @name = N'DBA_Admin',
    @enabled = 1,
    @email_address = N'dbaEmails@biblioteca.com'

EXEC sp_update_job --Operador asignado a un job = Backup completo
    @job_name = N'Backup completo',
    @notify_level_email = 3,
    @notify_email_operator_name = N'DBA_Admin';

EXEC sp_update_job --Operador asignado a un job = Backup Diferencial
    @job_name = N'Backup Diferencial',
    @notify_level_email = 3,
    @notify_email_operator_name = N'DBA_Admin';

EXEC sp_update_job --Operador asignado a un job = Backup Incremental
    @job_name = N'Backup Incremental',
    @notify_level_email = 3,
    @notify_email_operator_name = N'DBA_Admin';

EXEC sp_add_alert -- Alerta
    @name = N'Alerta jobs',
    @message_id = 0,
    @severity = 20,
    @enabled = 1,
    @delay_between_responses = 60,
    @include_event_description_in = 1;

EXEC sp_add_notification --Operador asignado a una alerta
    @alert_name = N'Alerta jobs',
    @operator_name = N'DBA_Admin',
    @notification_method = 1;

