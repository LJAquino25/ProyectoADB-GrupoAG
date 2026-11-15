
CREATE DATABASE prueba_backup;

--Backup Completo Domingo 18:00
RESTORE DATABASE [gestion_biblioteca] FROM DISK = '/backup/gestion_biblioteca/202611 _gestion_biblioteca_full.bak' WITH NORECOVERY

--Diferencial antes del fallo - Jueves 8:00
RESTORE DATABASE [gestion_biblioteca] FROM DISK = '/backup/gestion_biblioteca/Diferencial/202611 _gestion_biblioteca_diff.bak' WITH NORECOVERY

--Incrementales antes del fallo - Jueves 10:00, 12:00 y 14:00
RESTORE LOG [gestion_biblioteca] FROM DISK = '/backup/gestion_biblioteca/Incremental/202611 _1_gestion_biblioteca_log.trn' WITH RECOVERY
RESTORE LOG [gestion_biblioteca] FROM DISK = '/backup/gestion_biblioteca/Incremental/202611 _2_gestion_biblioteca_log.trn' WITH RECOVERY
RESTORE LOG [gestion_biblioteca] FROM DISK = '/backup/gestion_biblioteca/Incremental/202611 _3_gestion_biblioteca_log.trn' WITH RECOVERY