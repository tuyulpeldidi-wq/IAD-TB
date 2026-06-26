-- ============================================================================
-- PT ANDALAS MANUFAKTUR — pt_andalas_db
-- Phase 1: Complex Data Acquisition & Data Cleaning
-- Star Schema simulated database (raw/messy data, as required by the brief)
-- ============================================================================
-- Sections in this file:
--   1. Schema definition (5 tables: 3 dimensions + 2 facts)
--   2. Raw data load (deliberately contains missing values, duplicates,
--      physical temperature anomalies, and inconsistent text/number/date
--      formatting — to be cleaned downstream in Python/Pandas)
--   3. Phase 1 data acquisition queries (SQL JOIN across >= 3 tables)
-- Target engine: SQLite. Adjust UPPER()/date handling if porting to
-- MySQL/PostgreSQL/SQL Server.
-- ============================================================================

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

-- ----------------------------------------------------------------------------
-- SECTION 1: SCHEMA DEFINITION
-- ----------------------------------------------------------------------------

-- 1.1 DIMENSION TABLE: ms_mesin (Machine ID, Name, Type, Location)
CREATE TABLE ms_mesin (
    id_mesin TEXT,
    nama_mesin TEXT,
    tipe TEXT,
    lokasi TEXT
);;

-- 1.2 DIMENSION TABLE: ms_operator (Operator ID, Full Name, Shift Group, Skill Level)
CREATE TABLE ms_operator (
    id_operator TEXT,
    nama_lengkap TEXT,
    grup_shift TEXT,
    skill_level TEXT
);;

-- 1.3 DIMENSION TABLE: ms_material (Material ID, Raw Material Type, Supplier Vendor)
CREATE TABLE ms_material (
    id_material TEXT,
    jenis_bahan_baku TEXT,
    vendor_pemasok TEXT
);;

-- 1.4 FACT TABLE: tr_produksi (Date, Time, Machine, Operator, Material, Speed, Temp, Output, Reject)
CREATE TABLE tr_produksi (
    id_produksi TEXT,
    tanggal TEXT,
    jam TEXT,
    id_mesin TEXT,
    id_operator TEXT,
    id_material TEXT,
    setting_speed_rpm TEXT,
    suhu_mesin TEXT,
    output_qty_ok TEXT,
    reject_qty_ng TEXT
);;

-- 1.5 FACT TABLE: tr_maintenance (Date, Machine, Damage Type, Repair Cost, Downtime Duration)
CREATE TABLE tr_maintenance (
    id_maintenance TEXT,
    tanggal TEXT,
    id_mesin TEXT,
    tipe_kerusakan TEXT,
    biaya_perbaikan TEXT,
    durasi_downtime TEXT
);;

-- ----------------------------------------------------------------------------
-- SECTION 2: RAW DATA LOAD (intentionally messy — see Phase 1 brief)
-- ----------------------------------------------------------------------------

-- 1.1 DIMENSION TABLE: ms_mesin (Machine ID, Name, Type, Location)
-- Note: 'lokasi' and casing are inconsistent on purpose (e.g. 'Line 1' vs 'LINE 2' vs 'Line  2').
-- 8 rows
INSERT INTO "ms_mesin" VALUES('MSN-01','Stamping Press 01','Mechanical Press','Line 1');;
INSERT INTO "ms_mesin" VALUES('MSN-02','stamping press 02','Mechanical Press','line 1');;
INSERT INTO "ms_mesin" VALUES('MSN-03','Stamping Press 03','Hydraulic Press','Line  2');;
INSERT INTO "ms_mesin" VALUES('MSN-04','STAMPING PRESS 04','Hydraulic Press','LINE 2');;
INSERT INTO "ms_mesin" VALUES('MSN-05','Stamping Press 05','Servo Press','Line 3');;
INSERT INTO "ms_mesin" VALUES('MSN-06','Stamping Press 06','Servo Press','Line 3 ');;
INSERT INTO "ms_mesin" VALUES('MSN-07','Stamping Press 07','Mechanical Press','Line 1');;
INSERT INTO "ms_mesin" VALUES('MSN-08','Stamping Press 08','Hydraulic Press','Line 2');;

-- 1.2 DIMENSION TABLE: ms_operator (Operator ID, Full Name, Shift Group, Skill Level)
-- Note: 'grup_shift' mixes formats ('A', 'Shift A', 'a'); skill_level has missing values (NULL).
-- 15 rows
INSERT INTO "ms_operator" VALUES('OP-001','Budi Santoso','shift b','1');;
INSERT INTO "ms_operator" VALUES('OP-002','Andi Wijaya','C','3');;
INSERT INTO "ms_operator" VALUES('OP-003','Siti Pratama','A','2');;
INSERT INTO "ms_operator" VALUES('OP-004','Dewi Setiawan','B','1');;
INSERT INTO "ms_operator" VALUES('OP-005','Rudi Kurniawan','c',NULL);;
INSERT INTO "ms_operator" VALUES('OP-006','Agus Saputra','A','5');;
INSERT INTO "ms_operator" VALUES('OP-007','Hendra Hidayat',' B ','1');;
INSERT INTO "ms_operator" VALUES('OP-008','Rina Gunawan','C','1');;
INSERT INTO "ms_operator" VALUES('OP-009','Yusuf Permadi','A','2');;
INSERT INTO "ms_operator" VALUES('OP-010','Fitri Nugroho','shift b','5');;
INSERT INTO "ms_operator" VALUES('OP-011','Bambang Wibowo','C','5');;
INSERT INTO "ms_operator" VALUES('OP-012','Wati Anggraini','A',NULL);;
INSERT INTO "ms_operator" VALUES('OP-013','Joko Susanto',' B ','2');;
INSERT INTO "ms_operator" VALUES('OP-014','Lestari Firmansyah','Shift C','5');;
INSERT INTO "ms_operator" VALUES('OP-015','Hadi Rahmawati','Shift A','1');;

-- 1.3 DIMENSION TABLE: ms_material (Material ID, Raw Material Type, Supplier Vendor)
-- Note: same material appears twice with different text casing (data entry inconsistency).
-- 5 rows
INSERT INTO "ms_material" VALUES('MAT-01','Steel Coil','PT Krakatau Steel');;
INSERT INTO "ms_material" VALUES('MAT-02','steel coil','PT Krakatau Steel');;
INSERT INTO "ms_material" VALUES('MAT-03','Aluminum Sheet','PT Inalum Sejahtera');;
INSERT INTO "ms_material" VALUES('MAT-04','ALUMINUM SHEET','PT Inalum Sejahtera');;
INSERT INTO "ms_material" VALUES('MAT-05','Galvanized Steel','PT Gunung Garuda');;

-- 1.4 FACT TABLE: tr_produksi (Date, Time, Machine, Operator, Material, Speed, Temp, Output, Reject)
-- Note: contains missing suhu_mesin/output_qty_ok, mixed date formats, mixed rpm formatting,
-- physically impossible suhu_mesin values (negative / 999 sensor spikes), and a few
-- duplicate rows — all intentional, to be cleaned in the Phase 1 Pandas notebook.
-- 275 rows
INSERT INTO "tr_produksi" VALUES('TRX-00001','01-Jan-26','14:30','MSN-04','OP-006','MAT-01','1200','70.8','1070','46');;
INSERT INTO "tr_produksi" VALUES('TRX-00002','01/01/2026','15:00','MSN-07','OP-005','MAT-05','1500','-15','1033','5');;
INSERT INTO "tr_produksi" VALUES('TRX-00003','2026-01-02','14:30','MSN-06','OP-006','MAT-02','1500','999','1450','46');;
INSERT INTO "tr_produksi" VALUES('TRX-00004','2026-01-02','07:45','MSN-04','OP-014','MAT-01','1350','84.2','867','60');;
INSERT INTO "tr_produksi" VALUES('TRX-00005','03-Jan-26','8:15','MSN-07','OP-011','MAT-04','1350 rpm','67.4','1069','27');;
INSERT INTO "tr_produksi" VALUES('TRX-00006','03-Jan-26','14:30','MSN-03','OP-002','MAT-01','1200 rpm','64.8','1410','24');;
INSERT INTO "tr_produksi" VALUES('TRX-00007','03-Jan-26','14:30','MSN-01','OP-002','MAT-05','1500','70.2','961','46');;
INSERT INTO "tr_produksi" VALUES('TRX-00008','03-Jan-26','8:15','MSN-02','OP-005','MAT-05','1800 rpm','71.2','1343','38');;
INSERT INTO "tr_produksi" VALUES('TRX-00009','04/01/2026','6:00','MSN-05','OP-004','MAT-05','1200 rpm','-15','1345','8');;
INSERT INTO "tr_produksi" VALUES('TRX-00010','04-Jan-26','14:15','MSN-07','OP-015','MAT-05','1350','72.0','1182','33');;
INSERT INTO "tr_produksi" VALUES('TRX-00011','04/01/2026','06:15','msn-06','OP-009','MAT-02','1800 rpm','62.1','1034','2');;
INSERT INTO "tr_produksi" VALUES('TRX-00012','2026-01-05','15:15','MSN-08','OP-003','MAT-05','1800','83.5','994','42');;
INSERT INTO "tr_produksi" VALUES('TRX-00013','05/01/2026','08:45','MSN-01','OP-011','MAT-01','1200','70.2','1054','34');;
INSERT INTO "tr_produksi" VALUES('TRX-00014','05/01/2026','07:45','MSN-08','OP-015','MAT-01','1650','85.7','1467','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00015','2026-01-06','23:15','MSN-08','OP-014','MAT-04','1200 rpm','60.1','1265','44');;
INSERT INTO "tr_produksi" VALUES('TRX-00016','06-Jan-26','23:45','MSN-05','OP-001','MAT-05','1800 rpm','-15','1288','54');;
INSERT INTO "tr_produksi" VALUES('TRX-00017','2026-01-07','6:00','MSN-02','OP-011','MAT-02','1650 rpm','86.7','1408','5');;
INSERT INTO "tr_produksi" VALUES('TRX-00018','07/01/2026','22:30','MSN-04','OP-006','MAT-02','1500','80.2','1123','59');;
INSERT INTO "tr_produksi" VALUES('TRX-00019','2026-01-07','6:45','MSN-02','OP-004','MAT-05','1500 rpm','-15','1050','10');;
INSERT INTO "tr_produksi" VALUES('TRX-00020','07/01/2026','23:30','MSN-01','OP-009','MAT-03','1200','64.0','909','9');;
INSERT INTO "tr_produksi" VALUES('TRX-00021','08/01/2026','15:15','MSN-04','OP-014','MAT-03','1800','87.2','894','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00022','08/01/2026','06:00','MSN-03','OP-005','MAT-02','1650','','877','44');;
INSERT INTO "tr_produksi" VALUES('TRX-00023','2026-01-08','15:00','MSN-03','OP-001','MAT-03','1500','83.9','1166','15');;
INSERT INTO "tr_produksi" VALUES('TRX-00024','2026-01-09','8:45','MSN-03','OP-004','MAT-02','1350','60.7','1140','26');;
INSERT INTO "tr_produksi" VALUES('TRX-00025','09-Jan-26','23:15','MSN-02','OP-001','MAT-04','1350 rpm','87.6','1033','42');;
INSERT INTO "tr_produksi" VALUES('TRX-00026','2026-01-09','14:30','MSN-02','OP-005','MAT-03','1800','89.4','828','16');;
INSERT INTO "tr_produksi" VALUES('TRX-00027','2026-01-09','15:30','MSN-07','OP-013','MAT-03','1650','75.3','1390','2');;
INSERT INTO "tr_produksi" VALUES('TRX-00028','10/01/2026','06:15','MSN-02','OP-015','MAT-03','1800','85.4','1107','42');;
INSERT INTO "tr_produksi" VALUES('TRX-00029','10/01/2026','8:45','MSN-03','OP-011','MAT-04','1350','69.0','800','13');;
INSERT INTO "tr_produksi" VALUES('TRX-00030','10/01/2026','23:30','MSN-08','OP-009','MAT-04','1350','68.5','1434','52');;
INSERT INTO "tr_produksi" VALUES('TRX-00031','2026-01-10','22:30','MSN-04','OP-001','MAT-02','1650','83.1','1444','45');;
INSERT INTO "tr_produksi" VALUES('TRX-00032','11/01/2026','14:45','MSN-01','OP-014','MAT-01','1650 rpm','84.1','1275','15');;
INSERT INTO "tr_produksi" VALUES('TRX-00033','2026-01-11','14:15','MSN-06','OP-015','MAT-04','1800','86.8','1361','10');;
INSERT INTO "tr_produksi" VALUES('TRX-00034','11-Jan-26','23:45','MSN-04','OP-005','MAT-05','1650','999','1092','21');;
INSERT INTO "tr_produksi" VALUES('TRX-00035','11/01/2026','15:00','MSN-04','OP-003','MAT-02','1200','69.9','863','26');;
INSERT INTO "tr_produksi" VALUES('TRX-00036','12-Jan-26','22:00','MSN-07','OP-006','MAT-03','1650','88.6','1359','57');;
INSERT INTO "tr_produksi" VALUES('TRX-00037','2026-01-12','14:15','msn-08','OP-006','MAT-04','1350','87.6','','25');;
INSERT INTO "tr_produksi" VALUES('TRX-00038','12-Jan-26','15:00','MSN-07','OP-008','MAT-02','1200 rpm','69.8','1145','24');;
INSERT INTO "tr_produksi" VALUES('TRX-00039','13/01/2026','08:00','MSN-01','OP-006','MAT-02','1200','79.6','1053','1');;
INSERT INTO "tr_produksi" VALUES('TRX-00040','13-Jan-26','07:15','MSN-02','OP-004','MAT-04','1500','65.0','917','10');;
INSERT INTO "tr_produksi" VALUES('TRX-00041','13/01/2026','6:00','MSN-07','OP-012','MAT-02','1200','84.9','1108','38');;
INSERT INTO "tr_produksi" VALUES('TRX-00042','14-Jan-26','23:00','MSN-07','OP-002','MAT-05','1500 rpm','72.6','1243','40');;
INSERT INTO "tr_produksi" VALUES('TRX-00043','14/01/2026','22:15','MSN-05','OP-015','MAT-05','1650','84.8','1130','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00044','15/01/2026','14:15','MSN-07','OP-008','MAT-03','1350','70.6','1086','44');;
INSERT INTO "tr_produksi" VALUES('TRX-00045','15/01/2026','15:00','MSN-04','OP-012','MAT-04','1650','67.2','1302','1');;
INSERT INTO "tr_produksi" VALUES('TRX-00046','16/01/2026','7:45','MSN-05','OP-006','MAT-04','1800','72.8','1138','29');;
INSERT INTO "tr_produksi" VALUES('TRX-00047','16/01/2026','08:30','MSN-04','OP-012','MAT-05','1350 rpm','82.2','1403','33');;
INSERT INTO "tr_produksi" VALUES('TRX-00048','17/01/2026','06:15','MSN-06','OP-001','MAT-05','1350 rpm','89.2','929','48');;
INSERT INTO "tr_produksi" VALUES('TRX-00049','17/01/2026','6:00','MSN-08','OP-006','MAT-02','1200 rpm','85.9','866','4');;
INSERT INTO "tr_produksi" VALUES('TRX-00050','17-Jan-26','22:00','MSN-05','OP-004','MAT-01','1800','78.2','1031','24');;
INSERT INTO "tr_produksi" VALUES('TRX-00051','17/01/2026','14:30','MSN-07','OP-010','MAT-01','1800','63.0','1440','42');;
INSERT INTO "tr_produksi" VALUES('TRX-00052','2026-01-18','7:15','msn-03','OP-008','MAT-05','1650 rpm','66.9','1264','14');;
INSERT INTO "tr_produksi" VALUES('TRX-00053','18/01/2026','23:15','MSN-04','OP-015','MAT-03','1350 rpm','65.0','1382','28');;
INSERT INTO "tr_produksi" VALUES('TRX-00054','19/01/2026','22:30','MSN-05','OP-008','MAT-04','1200','86.7','1418','5');;
INSERT INTO "tr_produksi" VALUES('TRX-00055','2026-01-19','22:00','MSN-05','OP-013','MAT-02','1650','73.3','1399','52');;
INSERT INTO "tr_produksi" VALUES('TRX-00056','2026-01-20','14:30','MSN-06','OP-014','MAT-02','1500','74.9','1210','35');;
INSERT INTO "tr_produksi" VALUES('TRX-00057','2026-01-20','14:00','MSN-06','OP-013','MAT-04','1800','60.0','1273','12');;
INSERT INTO "tr_produksi" VALUES('TRX-00058','20-Jan-26','8:45','MSN-01','OP-009','MAT-02','1500','80.9','1445','15');;
INSERT INTO "tr_produksi" VALUES('TRX-00059','2026-01-21','8:00','MSN-02','OP-014','MAT-01','1650','79.4','1098','17');;
INSERT INTO "tr_produksi" VALUES('TRX-00060','21/01/2026','23:45','MSN-04','OP-003','MAT-04','1350','75.2','871','50');;
INSERT INTO "tr_produksi" VALUES('TRX-00061','21/01/2026','8:30','MSN-05','OP-014','MAT-05','1800','74.7','1351','21');;
INSERT INTO "tr_produksi" VALUES('TRX-00062','21-Jan-26','23:45','MSN-06','OP-012','MAT-02','1800','85.7','1125','45');;
INSERT INTO "tr_produksi" VALUES('TRX-00063','22/01/2026','22:15','MSN-01','OP-010','MAT-03','1200','73.2','','9');;
INSERT INTO "tr_produksi" VALUES('TRX-00064','22/01/2026','23:15','MSN-05','OP-012','MAT-04','1200','85.6','1189','40');;
INSERT INTO "tr_produksi" VALUES('TRX-00065','22-Jan-26','23:45','MSN-01','OP-004','MAT-03','1350','73.0','1448','6');;
INSERT INTO "tr_produksi" VALUES('TRX-00066','2026-01-23','22:30','MSN-01','OP-001','MAT-03','1500','64.4','1379','11');;
INSERT INTO "tr_produksi" VALUES('TRX-00067','2026-01-23','7:00','MSN-07','OP-004','MAT-04','1800 rpm','73.8','1061','57');;
INSERT INTO "tr_produksi" VALUES('TRX-00068','23/01/2026','08:15','MSN-06','OP-005','MAT-04','1500','69.1','1294','24');;
INSERT INTO "tr_produksi" VALUES('TRX-00069','24/01/2026','15:30','msn-05','OP-014','MAT-04','1500 rpm','86.0','850','47');;
INSERT INTO "tr_produksi" VALUES('TRX-00070','24/01/2026','23:30','MSN-04','OP-006','MAT-02','1350','80.3','1475','8');;
INSERT INTO "tr_produksi" VALUES('TRX-00071','24-Jan-26','06:00','msn-08','OP-006','MAT-02','1200','69.8','1005','34');;
INSERT INTO "tr_produksi" VALUES('TRX-00072','24/01/2026','15:30','MSN-05','OP-008','MAT-03','1500','999','1031','46');;
INSERT INTO "tr_produksi" VALUES('TRX-00073','25/01/2026','23:30','msn-07','OP-009','MAT-01','1650','82.5','1190','60');;
INSERT INTO "tr_produksi" VALUES('TRX-00074','25/01/2026','06:15','MSN-06','OP-004','MAT-01','1650','69.1','943','2');;
INSERT INTO "tr_produksi" VALUES('TRX-00075','25/01/2026','14:00','MSN-03','OP-006','MAT-05','1650','81.8','1470','31');;
INSERT INTO "tr_produksi" VALUES('TRX-00076','25-Jan-26','14:30','MSN-06','OP-008','MAT-02','1500 rpm','80.6','1460','25');;
INSERT INTO "tr_produksi" VALUES('TRX-00077','2026-01-26','06:45','MSN-04','OP-010','MAT-01','1200','67.3','1378','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00078','26-Jan-26','7:15','MSN-04','OP-003','MAT-05','1200 rpm','89.5','1353','11');;
INSERT INTO "tr_produksi" VALUES('TRX-00079','2026-01-26','22:00','MSN-06','OP-004','MAT-05','1500 rpm','68.0','1231','47');;
INSERT INTO "tr_produksi" VALUES('TRX-00080','27/01/2026','14:30','MSN-02','OP-004','MAT-05','1200','87.3','1108','1');;
INSERT INTO "tr_produksi" VALUES('TRX-00081','2026-01-27','14:45','MSN-02','OP-015','MAT-04','1200','69.7','929','40');;
INSERT INTO "tr_produksi" VALUES('TRX-00082','28-Jan-26','22:30','MSN-05','OP-010','MAT-04','1200','63.4','1364','13');;
INSERT INTO "tr_produksi" VALUES('TRX-00083','28/01/2026','14:15','MSN-08','OP-012','MAT-01','1500','80.0','956','30');;
INSERT INTO "tr_produksi" VALUES('TRX-00084','2026-01-28','06:00','MSN-02','OP-006','MAT-02','1800 rpm','88.7','1486','22');;
INSERT INTO "tr_produksi" VALUES('TRX-00085','28-Jan-26','23:45','MSN-01','OP-010','MAT-03','1500 rpm','75.2','1293','6');;
INSERT INTO "tr_produksi" VALUES('TRX-00086','29-Jan-26','8:00','MSN-04','OP-014','MAT-05','1800','','1473','17');;
INSERT INTO "tr_produksi" VALUES('TRX-00087','2026-01-29','7:30','MSN-05','OP-006','MAT-01','1350','77.0','945','1');;
INSERT INTO "tr_produksi" VALUES('TRX-00088','2026-01-29','22:15','MSN-08','OP-006','MAT-03','1500','999','853','48');;
INSERT INTO "tr_produksi" VALUES('TRX-00089','2026-01-30','22:00','MSN-07','OP-008','MAT-04','1500 rpm','75.4','913','43');;
INSERT INTO "tr_produksi" VALUES('TRX-00090','30-Jan-26','14:30','MSN-07','OP-001','MAT-01','1350','66.3','1061','7');;
INSERT INTO "tr_produksi" VALUES('TRX-00091','2026-01-30','14:45','MSN-07','OP-004','MAT-05','1800','999','843','29');;
INSERT INTO "tr_produksi" VALUES('TRX-00092','2026-01-30','23:30','MSN-07','OP-007','MAT-03','1200','89.0','1432','44');;
INSERT INTO "tr_produksi" VALUES('TRX-00093','2026-01-31','14:00','MSN-07','OP-007','MAT-03','1500 rpm','999','1448','32');;
INSERT INTO "tr_produksi" VALUES('TRX-00094','2026-01-31','23:30','MSN-03','OP-003','MAT-03','1350 rpm','64.6','877','49');;
INSERT INTO "tr_produksi" VALUES('TRX-00095','31-Jan-26','14:45','MSN-08','OP-015','MAT-05','1800','89.1','1250','28');;
INSERT INTO "tr_produksi" VALUES('TRX-00096','01/02/2026','23:30','MSN-06','OP-005','MAT-04','1650 rpm','71.1','1460','54');;
INSERT INTO "tr_produksi" VALUES('TRX-00097','2026-02-01','15:45','MSN-01','OP-013','MAT-05','1350','74.3','863','51');;
INSERT INTO "tr_produksi" VALUES('TRX-00098','01/02/2026','22:00','msn-03','OP-012','MAT-04','1650','78.3','1089','49');;
INSERT INTO "tr_produksi" VALUES('TRX-00099','01/02/2026','22:00','MSN-06','OP-002','MAT-05','1650 rpm','81.7','1417','21');;
INSERT INTO "tr_produksi" VALUES('TRX-00100','02-Feb-26','22:15','MSN-05','OP-012','MAT-04','1350','88.1','1185','21');;
INSERT INTO "tr_produksi" VALUES('TRX-00101','2026-02-02','22:00','MSN-07','OP-001','MAT-03','1500 rpm','66.4','1297','8');;
INSERT INTO "tr_produksi" VALUES('TRX-00102','2026-02-03','8:00','MSN-01','OP-015','MAT-05','1350','64.6','1439','10');;
INSERT INTO "tr_produksi" VALUES('TRX-00103','03-Feb-26','14:00','MSN-04','OP-010','MAT-03','1650 rpm','67.2','1280','12');;
INSERT INTO "tr_produksi" VALUES('TRX-00104','04-Feb-26','15:45','MSN-05','OP-009','MAT-05','1650','84.5','941','3');;
INSERT INTO "tr_produksi" VALUES('TRX-00105','04-Feb-26','14:30','MSN-02','OP-009','MAT-01','1500 rpm','64.8','1325','27');;
INSERT INTO "tr_produksi" VALUES('TRX-00106','2026-02-04','7:45','MSN-01','OP-007','MAT-05','1500 rpm','89.8','828','6');;
INSERT INTO "tr_produksi" VALUES('TRX-00107','05-Feb-26','08:15','MSN-05','OP-008','MAT-02','1650','999','1062','9');;
INSERT INTO "tr_produksi" VALUES('TRX-00108','05-Feb-26','22:45','MSN-05','OP-002','MAT-01','1350','83.8','913','31');;
INSERT INTO "tr_produksi" VALUES('TRX-00109','05-Feb-26','15:00','MSN-04','OP-005','MAT-04','1200','67.2','1480','33');;
INSERT INTO "tr_produksi" VALUES('TRX-00110','05/02/2026','06:00','msn-08','OP-007','MAT-03','1500','-15','1046','40');;
INSERT INTO "tr_produksi" VALUES('TRX-00111','06-Feb-26','22:30','MSN-06','OP-014','MAT-02','1650','74.4','938','49');;
INSERT INTO "tr_produksi" VALUES('TRX-00112','06/02/2026','06:30','MSN-04','OP-006','MAT-03','1800','84.5','837','12');;
INSERT INTO "tr_produksi" VALUES('TRX-00113','07/02/2026','23:00','MSN-06','OP-013','MAT-03','1650','82.3','1195','11');;
INSERT INTO "tr_produksi" VALUES('TRX-00114','07/02/2026','22:45','MSN-05','OP-012','MAT-04','1200','89.9','1100','5');;
INSERT INTO "tr_produksi" VALUES('TRX-00115','07/02/2026','22:30','MSN-07','OP-008','MAT-03','1650 rpm','86.1','1245','50');;
INSERT INTO "tr_produksi" VALUES('TRX-00116','2026-02-08','22:45','MSN-03','OP-003','MAT-05','1650 rpm','62.0','1175','60');;
INSERT INTO "tr_produksi" VALUES('TRX-00117','08-Feb-26','6:15','MSN-06','OP-013','MAT-01','1800 rpm','71.0','1085','7');;
INSERT INTO "tr_produksi" VALUES('TRX-00118','09-Feb-26','7:45','MSN-02','OP-005','MAT-04','1350','68.6','1302','8');;
INSERT INTO "tr_produksi" VALUES('TRX-00119','2026-02-09','14:15','MSN-08','OP-013','MAT-03','1500','76.5','1107','45');;
INSERT INTO "tr_produksi" VALUES('TRX-00120','10-Feb-26','22:15','MSN-04','OP-004','MAT-02','1350','60.8','1177','35');;
INSERT INTO "tr_produksi" VALUES('TRX-00121','2026-02-10','15:00','MSN-07','OP-012','MAT-04','1800','72.3','928','41');;
INSERT INTO "tr_produksi" VALUES('TRX-00122','2026-02-10','14:45','MSN-06','OP-014','MAT-05','1800 rpm','89.0','856','33');;
INSERT INTO "tr_produksi" VALUES('TRX-00123','2026-02-10','08:15','MSN-04','OP-009','MAT-03','1200 rpm','79.1','928','39');;
INSERT INTO "tr_produksi" VALUES('TRX-00124','2026-02-11','15:15','MSN-03','OP-010','MAT-05','1500','76.9','829','60');;
INSERT INTO "tr_produksi" VALUES('TRX-00125','11-Feb-26','23:30','MSN-07','OP-001','MAT-04','1800 rpm','88.7','1215','4');;
INSERT INTO "tr_produksi" VALUES('TRX-00126','11-Feb-26','06:15','MSN-08','OP-006','MAT-05','1350','81.6','1153','8');;
INSERT INTO "tr_produksi" VALUES('TRX-00127','11/02/2026','15:00','MSN-08','OP-008','MAT-02','1350 rpm','68.7','1430','55');;
INSERT INTO "tr_produksi" VALUES('TRX-00128','12/02/2026','15:30','MSN-03','OP-009','MAT-04','1650','74.9','1202','15');;
INSERT INTO "tr_produksi" VALUES('TRX-00129','2026-02-12','15:30','MSN-05','OP-015','MAT-04','1500','85.4','1070','48');;
INSERT INTO "tr_produksi" VALUES('TRX-00130','13/02/2026','06:45','MSN-04','OP-005','MAT-01','1650','82.9','1438','7');;
INSERT INTO "tr_produksi" VALUES('TRX-00131','2026-02-13','06:45','MSN-06','OP-006','MAT-02','1350','-15','839','21');;
INSERT INTO "tr_produksi" VALUES('TRX-00132','13/02/2026','15:45','MSN-03','OP-010','MAT-03','1350','78.5','1407','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00133','14-Feb-26','14:30','MSN-01','OP-011','MAT-01','1650','83.9','','30');;
INSERT INTO "tr_produksi" VALUES('TRX-00134','14/02/2026','22:15','MSN-08','OP-011','MAT-05','1650 rpm','','912','28');;
INSERT INTO "tr_produksi" VALUES('TRX-00135','14/02/2026','14:15','MSN-04','OP-013','MAT-05','1650','-15','941','35');;
INSERT INTO "tr_produksi" VALUES('TRX-00136','14/02/2026','22:45','MSN-06','OP-008','MAT-05','1500','80.3','1497','44');;
INSERT INTO "tr_produksi" VALUES('TRX-00137','15-Feb-26','14:15','MSN-05','OP-004','MAT-03','1500','80.7','1291','59');;
INSERT INTO "tr_produksi" VALUES('TRX-00138','15-Feb-26','08:30','MSN-07','OP-007','MAT-03','1350 rpm','68.6','1154','41');;
INSERT INTO "tr_produksi" VALUES('TRX-00139','15/02/2026','22:45','MSN-05','OP-012','MAT-03','1350 rpm','82.2','851','33');;
INSERT INTO "tr_produksi" VALUES('TRX-00140','16-Feb-26','07:00','MSN-06','OP-002','MAT-02','1200','89.3','1468','56');;
INSERT INTO "tr_produksi" VALUES('TRX-00141','16/02/2026','14:15','MSN-05','OP-011','MAT-01','1200','67.0','838','11');;
INSERT INTO "tr_produksi" VALUES('TRX-00142','2026-02-17','6:45','MSN-03','OP-014','MAT-03','1200 rpm','77.0','1143','41');;
INSERT INTO "tr_produksi" VALUES('TRX-00143','17-Feb-26','15:45','MSN-03','OP-008','MAT-03','1350','69.9','1463','11');;
INSERT INTO "tr_produksi" VALUES('TRX-00144','2026-02-17','22:30','MSN-04','OP-014','MAT-04','1650','62.6','989','30');;
INSERT INTO "tr_produksi" VALUES('TRX-00145','2026-02-18','06:30','MSN-08','OP-006','MAT-03','1800','60.3','1041','7');;
INSERT INTO "tr_produksi" VALUES('TRX-00146','18/02/2026','08:15','MSN-05','OP-011','MAT-03','1500','66.6','956','38');;
INSERT INTO "tr_produksi" VALUES('TRX-00147','18/02/2026','14:45','MSN-04','OP-011','MAT-05','1200','75.8','1377','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00148','19-Feb-26','07:15','MSN-08','OP-004','MAT-05','1650 rpm','75.3','1264','26');;
INSERT INTO "tr_produksi" VALUES('TRX-00149','19/02/2026','15:00','MSN-05','OP-007','MAT-03','1200','-15','1152','34');;
INSERT INTO "tr_produksi" VALUES('TRX-00150','2026-02-19','06:45','MSN-07','OP-003','MAT-04','1500','71.5','1186','43');;
INSERT INTO "tr_produksi" VALUES('TRX-00151','19-Feb-26','23:15','MSN-06','OP-009','MAT-04','1800 rpm','89.4','823','29');;
INSERT INTO "tr_produksi" VALUES('TRX-00152','20-Feb-26','15:45','MSN-04','OP-006','MAT-02','1500 rpm','86.3','832','26');;
INSERT INTO "tr_produksi" VALUES('TRX-00153','20-Feb-26','23:00','MSN-02','OP-001','MAT-04','1800','86.2','845','14');;
INSERT INTO "tr_produksi" VALUES('TRX-00154','20-Feb-26','07:00','MSN-05','OP-015','MAT-05','1500','83.2','1042','9');;
INSERT INTO "tr_produksi" VALUES('TRX-00155','20-Feb-26','15:15','MSN-05','OP-010','MAT-02','1650','61.4','1458','50');;
INSERT INTO "tr_produksi" VALUES('TRX-00156','21/02/2026','22:45','MSN-05','OP-013','MAT-05','1650 rpm','66.8','947','58');;
INSERT INTO "tr_produksi" VALUES('TRX-00157','2026-02-21','15:45','MSN-03','OP-005','MAT-02','1500','87.7','894','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00158','2026-02-21','06:30','MSN-01','OP-004','MAT-05','1800 rpm','66.3','1110','0');;
INSERT INTO "tr_produksi" VALUES('TRX-00159','2026-02-21','7:00','MSN-08','OP-012','MAT-05','1350','67.2','1089','34');;
INSERT INTO "tr_produksi" VALUES('TRX-00160','22/02/2026','08:30','MSN-08','OP-013','MAT-04','1500','71.1','1376','47');;
INSERT INTO "tr_produksi" VALUES('TRX-00161','2026-02-22','6:30','MSN-07','OP-004','MAT-03','1350','85.0','1470','21');;
INSERT INTO "tr_produksi" VALUES('TRX-00162','22/02/2026','23:45','MSN-08','OP-012','MAT-03','1350 rpm','76.4','1355','3');;
INSERT INTO "tr_produksi" VALUES('TRX-00163','22-Feb-26','6:00','MSN-01','OP-007','MAT-02','1350 rpm','64.5','1266','39');;
INSERT INTO "tr_produksi" VALUES('TRX-00164','23-Feb-26','15:45','msn-01','OP-009','MAT-04','1200 rpm','81.7','','52');;
INSERT INTO "tr_produksi" VALUES('TRX-00165','23-Feb-26','22:45','MSN-03','OP-002','MAT-05','1350 rpm','78.6','1162','25');;
INSERT INTO "tr_produksi" VALUES('TRX-00166','2026-02-23','08:45','MSN-04','OP-004','MAT-03','1200','85.7','895','24');;
INSERT INTO "tr_produksi" VALUES('TRX-00167','23-Feb-26','14:00','MSN-03','OP-014','MAT-04','1500','85.7','1340','14');;
INSERT INTO "tr_produksi" VALUES('TRX-00168','24-Feb-26','15:45','MSN-02','OP-005','MAT-05','1800','65.4','816','37');;
INSERT INTO "tr_produksi" VALUES('TRX-00169','2026-02-24','23:45','MSN-05','OP-004','MAT-05','1650','76.2','943','44');;
INSERT INTO "tr_produksi" VALUES('TRX-00170','2026-02-25','15:30','MSN-07','OP-002','MAT-03','1800','88.6','','17');;
INSERT INTO "tr_produksi" VALUES('TRX-00171','25/02/2026','14:15','MSN-07','OP-011','MAT-05','1650 rpm','78.6','875','9');;
INSERT INTO "tr_produksi" VALUES('TRX-00172','25/02/2026','22:15','MSN-06','OP-002','MAT-01','1500','82.8','889','28');;
INSERT INTO "tr_produksi" VALUES('TRX-00173','25-Feb-26','15:45','MSN-02','OP-002','MAT-05','1800','','1223','5');;
INSERT INTO "tr_produksi" VALUES('TRX-00174','26-Feb-26','7:15','MSN-03','OP-005','MAT-03','1650 rpm','65.0','1106','4');;
INSERT INTO "tr_produksi" VALUES('TRX-00175','26/02/2026','8:15','MSN-08','OP-004','MAT-04','1200 rpm','60.2','1435','55');;
INSERT INTO "tr_produksi" VALUES('TRX-00176','26/02/2026','14:30','MSN-03','OP-010','MAT-02','1650','88.9','1098','40');;
INSERT INTO "tr_produksi" VALUES('TRX-00177','26/02/2026','15:15','MSN-05','OP-007','MAT-03','1200','66.0','984','35');;
INSERT INTO "tr_produksi" VALUES('TRX-00178','27-Feb-26','14:15','MSN-05','OP-002','MAT-04','1650 rpm','69.1','957','50');;
INSERT INTO "tr_produksi" VALUES('TRX-00179','27/02/2026','6:45','MSN-08','OP-009','MAT-05','1650','83.7','1349','58');;
INSERT INTO "tr_produksi" VALUES('TRX-00180','2026-02-28','23:15','MSN-06','OP-010','MAT-01','1800','80.3','1139','27');;
INSERT INTO "tr_produksi" VALUES('TRX-00181','2026-02-28','06:00','MSN-04','OP-007','MAT-04','1800','64.5','1294','26');;
INSERT INTO "tr_produksi" VALUES('TRX-00182','2026-03-01','23:15','MSN-06','OP-004','MAT-05','1650','62.9','1263','19');;
INSERT INTO "tr_produksi" VALUES('TRX-00183','2026-03-01','23:00','MSN-06','OP-011','MAT-02','1350','76.6','1236','14');;
INSERT INTO "tr_produksi" VALUES('TRX-00184','02-Mar-26','7:15','MSN-07','OP-012','MAT-05','1350','','1019','48');;
INSERT INTO "tr_produksi" VALUES('TRX-00185','02-Mar-26','23:00','MSN-03','OP-004','MAT-04','1200 rpm','85.9','1454','24');;
INSERT INTO "tr_produksi" VALUES('TRX-00186','02-Mar-26','14:00','MSN-08','OP-014','MAT-03','1800','80.2','1044','11');;
INSERT INTO "tr_produksi" VALUES('TRX-00187','03-Mar-26','07:45','MSN-03','OP-007','MAT-02','1650','80.8','977','31');;
INSERT INTO "tr_produksi" VALUES('TRX-00188','03/03/2026','07:15','MSN-08','OP-014','MAT-03','1200','65.9','1375','31');;
INSERT INTO "tr_produksi" VALUES('TRX-00189','03/03/2026','22:45','MSN-08','OP-002','MAT-05','1200','','1030','10');;
INSERT INTO "tr_produksi" VALUES('TRX-00190','04-Mar-26','22:45','MSN-02','OP-005','MAT-05','1500','82.7','1251','27');;
INSERT INTO "tr_produksi" VALUES('TRX-00191','2026-03-04','22:15','MSN-01','OP-006','MAT-01','1650','63.5','1014','37');;
INSERT INTO "tr_produksi" VALUES('TRX-00192','04-Mar-26','08:45','MSN-03','OP-014','MAT-02','1200','76.0','972','45');;
INSERT INTO "tr_produksi" VALUES('TRX-00193','05/03/2026','15:30','MSN-02','OP-013','MAT-04','1200','86.0','935','45');;
INSERT INTO "tr_produksi" VALUES('TRX-00194','05/03/2026','23:15','MSN-07','OP-010','MAT-03','1650','62.3','895','47');;
INSERT INTO "tr_produksi" VALUES('TRX-00195','05/03/2026','22:30','MSN-08','OP-001','MAT-01','1650','80.9','1347','27');;
INSERT INTO "tr_produksi" VALUES('TRX-00196','06/03/2026','8:30','MSN-06','OP-003','MAT-05','1650','86.8','847','50');;
INSERT INTO "tr_produksi" VALUES('TRX-00197','06/03/2026','6:00','MSN-03','OP-001','MAT-04','1350','87.3','1109','59');;
INSERT INTO "tr_produksi" VALUES('TRX-00198','2026-03-07','22:30','MSN-06','OP-011','MAT-02','1200','69.2','1039','5');;
INSERT INTO "tr_produksi" VALUES('TRX-00199','07-Mar-26','06:00','MSN-02','OP-004','MAT-05','1650 rpm','80.9','1232','30');;
INSERT INTO "tr_produksi" VALUES('TRX-00200','2026-03-07','07:45','MSN-02','OP-006','MAT-03','1350','84.4','1456','9');;
INSERT INTO "tr_produksi" VALUES('TRX-00201','08-Mar-26','15:00','MSN-03','OP-012','MAT-02','1350','78.5','1022','6');;
INSERT INTO "tr_produksi" VALUES('TRX-00202','2026-03-08','23:00','MSN-07','OP-007','MAT-03','1350 rpm','79.3','1415','38');;
INSERT INTO "tr_produksi" VALUES('TRX-00203','09-Mar-26','06:30','MSN-04','OP-005','MAT-01','1350','63.4','1408','56');;
INSERT INTO "tr_produksi" VALUES('TRX-00204','2026-03-09','08:30','MSN-07','OP-011','MAT-02','1650','','','13');;
INSERT INTO "tr_produksi" VALUES('TRX-00205','2026-03-09','6:45','MSN-07','OP-007','MAT-01','1800','999','880','13');;
INSERT INTO "tr_produksi" VALUES('TRX-00206','10-Mar-26','8:45','MSN-02','OP-007','MAT-02','1200 rpm','87.7','1426','19');;
INSERT INTO "tr_produksi" VALUES('TRX-00207','10-Mar-26','22:15','MSN-03','OP-003','MAT-04','1500','83.5','970','47');;
INSERT INTO "tr_produksi" VALUES('TRX-00208','11-Mar-26','06:00','MSN-07','OP-002','MAT-03','1800','74.9','856','36');;
INSERT INTO "tr_produksi" VALUES('TRX-00209','2026-03-11','08:15','MSN-02','OP-011','MAT-01','1350','60.1','812','30');;
INSERT INTO "tr_produksi" VALUES('TRX-00210','11/03/2026','14:15','MSN-01','OP-015','MAT-04','1350','72.5','1077','36');;
INSERT INTO "tr_produksi" VALUES('TRX-00211','2026-03-12','15:00','MSN-01','OP-002','MAT-04','1500','999','','12');;
INSERT INTO "tr_produksi" VALUES('TRX-00212','12/03/2026','15:30','MSN-04','OP-010','MAT-04','1350','76.4','','26');;
INSERT INTO "tr_produksi" VALUES('TRX-00213','2026-03-12','7:30','MSN-01','OP-001','MAT-04','1500 rpm','75.9','1303','9');;
INSERT INTO "tr_produksi" VALUES('TRX-00214','13/03/2026','6:00','MSN-07','OP-006','MAT-04','1200','75.2','1203','36');;
INSERT INTO "tr_produksi" VALUES('TRX-00215','2026-03-13','14:15','MSN-05','OP-015','MAT-04','1500','999','1007','49');;
INSERT INTO "tr_produksi" VALUES('TRX-00216','13-Mar-26','06:15','MSN-08','OP-007','MAT-01','1800','83.1','1274','7');;
INSERT INTO "tr_produksi" VALUES('TRX-00217','2026-03-13','7:30','MSN-01','OP-014','MAT-03','1350 rpm','67.4','1325','19');;
INSERT INTO "tr_produksi" VALUES('TRX-00218','2026-03-14','6:45','MSN-04','OP-002','MAT-02','1200 rpm','84.9','933','25');;
INSERT INTO "tr_produksi" VALUES('TRX-00219','14/03/2026','22:00','MSN-05','OP-002','MAT-01','1200 rpm','79.4','894','53');;
INSERT INTO "tr_produksi" VALUES('TRX-00220','14/03/2026','6:00','MSN-01','OP-010','MAT-04','1650','71.5','1162','11');;
INSERT INTO "tr_produksi" VALUES('TRX-00221','15/03/2026','14:15','MSN-04','OP-008','MAT-04','1800','62.6','1229','56');;
INSERT INTO "tr_produksi" VALUES('TRX-00222','15-Mar-26','7:00','MSN-06','OP-013','MAT-04','1500','75.1','','38');;
INSERT INTO "tr_produksi" VALUES('TRX-00223','2026-03-15','06:30','MSN-08','OP-013','MAT-05','1350','63.0','1072','50');;
INSERT INTO "tr_produksi" VALUES('TRX-00224','2026-03-16','23:15','MSN-07','OP-014','MAT-02','1350 rpm','69.5','1167','1');;
INSERT INTO "tr_produksi" VALUES('TRX-00225','16-Mar-26','22:30','MSN-03','OP-004','MAT-04','1800','74.7','1038','1');;
INSERT INTO "tr_produksi" VALUES('TRX-00226','16-Mar-26','14:00','MSN-04','OP-006','MAT-02','1500 rpm','64.4','945','54');;
INSERT INTO "tr_produksi" VALUES('TRX-00227','16-Mar-26','23:30','MSN-06','OP-011','MAT-04','1800 rpm','69.1','961','27');;
INSERT INTO "tr_produksi" VALUES('TRX-00228','17/03/2026','22:30','MSN-06','OP-010','MAT-02','1650','80.7','801','60');;
INSERT INTO "tr_produksi" VALUES('TRX-00229','17-Mar-26','14:00','MSN-06','OP-010','MAT-02','1800 rpm','74.9','879','20');;
INSERT INTO "tr_produksi" VALUES('TRX-00230','2026-03-17','22:00','MSN-06','OP-005','MAT-02','1350','70.5','801','28');;
INSERT INTO "tr_produksi" VALUES('TRX-00231','17-Mar-26','14:15','MSN-08','OP-006','MAT-05','1650 rpm','74.4','1466','14');;
INSERT INTO "tr_produksi" VALUES('TRX-00232','18/03/2026','06:00','MSN-06','OP-002','MAT-01','1500 rpm','71.3','1360','5');;
INSERT INTO "tr_produksi" VALUES('TRX-00233','18/03/2026','15:45','MSN-07','OP-003','MAT-05','1650 rpm','63.0','994','35');;
INSERT INTO "tr_produksi" VALUES('TRX-00234','19-Mar-26','15:30','MSN-05','OP-001','MAT-04','1800','-15','803','18');;
INSERT INTO "tr_produksi" VALUES('TRX-00235','19-Mar-26','22:45','MSN-01','OP-011','MAT-03','1200','63.5','1282','42');;
INSERT INTO "tr_produksi" VALUES('TRX-00236','19/03/2026','06:45','MSN-07','OP-008','MAT-01','1500','67.9','1377','48');;
INSERT INTO "tr_produksi" VALUES('TRX-00237','19-Mar-26','22:00','MSN-06','OP-007','MAT-05','1350','85.2','1228','43');;
INSERT INTO "tr_produksi" VALUES('TRX-00238','20-Mar-26','07:45','MSN-07','OP-012','MAT-01','1800','75.5','1435','60');;
INSERT INTO "tr_produksi" VALUES('TRX-00239','20/03/2026','7:15','MSN-04','OP-007','MAT-01','1650 rpm','84.7','1409','58');;
INSERT INTO "tr_produksi" VALUES('TRX-00240','20-Mar-26','23:00','MSN-07','OP-014','MAT-03','1800','86.2','1438','50');;
INSERT INTO "tr_produksi" VALUES('TRX-00241','2026-03-21','14:15','MSN-02','OP-010','MAT-01','1500','86.4','1070','31');;
INSERT INTO "tr_produksi" VALUES('TRX-00242','21-Mar-26','15:45','MSN-05','OP-010','MAT-05','1650 rpm','86.7','1043','30');;
INSERT INTO "tr_produksi" VALUES('TRX-00243','21/03/2026','08:00','MSN-05','OP-014','MAT-04','1200','66.8','1253','20');;
INSERT INTO "tr_produksi" VALUES('TRX-00244','22-Mar-26','14:00','MSN-04','OP-007','MAT-04','1800','84.6','962','45');;
INSERT INTO "tr_produksi" VALUES('TRX-00245','22-Mar-26','14:15','MSN-01','OP-015','MAT-02','1200 rpm','73.7','1003','52');;
INSERT INTO "tr_produksi" VALUES('TRX-00246','22/03/2026','15:45','MSN-02','OP-004','MAT-03','1650','65.3','1400','22');;
INSERT INTO "tr_produksi" VALUES('TRX-00247','23/03/2026','22:00','msn-07','OP-014','MAT-05','1350','79.4','1075','32');;
INSERT INTO "tr_produksi" VALUES('TRX-00248','2026-03-23','23:00','MSN-03','OP-010','MAT-01','1350 rpm','84.2','1458','57');;
INSERT INTO "tr_produksi" VALUES('TRX-00249','24/03/2026','14:30','MSN-05','OP-014','MAT-05','1650','60.2','1183','38');;
INSERT INTO "tr_produksi" VALUES('TRX-00250','24-Mar-26','8:30','MSN-08','OP-005','MAT-03','1500 rpm','81.3','1105','33');;
INSERT INTO "tr_produksi" VALUES('TRX-00251','2026-03-24','6:45','MSN-03','OP-011','MAT-04','1500 rpm','72.6','836','36');;
INSERT INTO "tr_produksi" VALUES('TRX-00252','25/03/2026','22:15','MSN-08','OP-011','MAT-03','1800','65.1','1371','6');;
INSERT INTO "tr_produksi" VALUES('TRX-00253','25/03/2026','7:30','MSN-03','OP-015','MAT-03','1200 rpm','66.7','1230','21');;
INSERT INTO "tr_produksi" VALUES('TRX-00254','26/03/2026','15:30','MSN-02','OP-014','MAT-05','1800','62.1','1312','43');;
INSERT INTO "tr_produksi" VALUES('TRX-00255','26/03/2026','15:30','MSN-03','OP-004','MAT-03','1650','86.8','946','45');;
INSERT INTO "tr_produksi" VALUES('TRX-00256','2026-03-26','23:00','MSN-03','OP-001','MAT-01','1650 rpm','82.8','962','48');;
INSERT INTO "tr_produksi" VALUES('TRX-00257','2026-03-27','15:45','MSN-07','OP-008','MAT-04','1200 rpm','66.0','814','48');;
INSERT INTO "tr_produksi" VALUES('TRX-00258','27-Mar-26','7:00','MSN-04','OP-015','MAT-03','1500 rpm','71.5','971','2');;
INSERT INTO "tr_produksi" VALUES('TRX-00259','28/03/2026','14:30','MSN-03','OP-015','MAT-04','1500','64.9','','14');;
INSERT INTO "tr_produksi" VALUES('TRX-00260','28-Mar-26','7:15','MSN-03','OP-012','MAT-01','1650','67.7','849','3');;
INSERT INTO "tr_produksi" VALUES('TRX-00261','28-Mar-26','06:00','MSN-02','OP-007','MAT-01','1800 rpm','81.1','','26');;
INSERT INTO "tr_produksi" VALUES('TRX-00262','2026-03-29','22:30','MSN-03','OP-015','MAT-01','1800','63.5','908','38');;
INSERT INTO "tr_produksi" VALUES('TRX-00263','2026-03-29','23:30','MSN-04','OP-007','MAT-03','1350 rpm','74.9','1292','0');;
INSERT INTO "tr_produksi" VALUES('TRX-00264','2026-03-29','22:00','MSN-08','OP-002','MAT-05','1200','63.0','1036','18');;
INSERT INTO "tr_produksi" VALUES('TRX-00265','29/03/2026','14:00','MSN-03','OP-014','MAT-03','1500','69.4','897','56');;
INSERT INTO "tr_produksi" VALUES('TRX-00266','2026-03-30','23:15','MSN-03','OP-015','MAT-04','1800 rpm','82.0','1150','25');;
INSERT INTO "tr_produksi" VALUES('TRX-00267','30/03/2026','14:30','MSN-08','OP-011','MAT-02','1200 rpm','81.8','963','58');;
INSERT INTO "tr_produksi" VALUES('TRX-00268','31/03/2026','23:45','MSN-07','OP-010','MAT-01','1350','74.6','1251','16');;
INSERT INTO "tr_produksi" VALUES('TRX-00269','31-Mar-26','8:00','MSN-04','OP-011','MAT-03','1800','81.0','1477','30');;
INSERT INTO "tr_produksi" VALUES('TRX-00270','31/03/2026','22:45','msn-01','OP-015','MAT-02','1800','85.6','876','20');;
INSERT INTO "tr_produksi" VALUES('TRX-00271','2026-03-31','08:30','MSN-04','OP-007','MAT-04','1350 rpm','73.3','890','28');;
INSERT INTO "tr_produksi" VALUES('TRX-00011','04/01/2026','06:15','msn-06','OP-009','MAT-02','1800 rpm','62.1','1034','2');;
INSERT INTO "tr_produksi" VALUES('TRX-00056','2026-01-20','14:30','MSN-06','OP-014','MAT-02','1500','74.9','1210','35');;
INSERT INTO "tr_produksi" VALUES('TRX-00121','2026-02-10','15:00','MSN-07','OP-012','MAT-04','1800','72.3','928','41');;
INSERT INTO "tr_produksi" VALUES('TRX-00201','08-Mar-26','15:00','MSN-03','OP-012','MAT-02','1350','78.5','1022','6');;

-- 1.5 FACT TABLE: tr_maintenance (Date, Machine, Damage Type, Repair Cost, Downtime Duration)
-- Note: mixed currency formatting in biaya_perbaikan and mixed time units in durasi_downtime.
-- 45 rows
INSERT INTO "tr_maintenance" VALUES('MNT-0001','2026-02-10','MSN-08','Overheat','Rp 500.000','1.5 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0002','2026-03-12','MSN-02','Hydraulic Leak','Rp 3,000,000','45 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0003','28/02/2026','MSN-06','Overheat','Rp 750.000','60 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0004','21-Mar-26','MSN-08','Belt Damage','2500000','30 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0005','2026-01-29','MSN-06','Belt Damage','Rp 1,200,000','120 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0006','2026-01-14','MSN-03','Electrical Fault','Rp 750,000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0007','14/01/2026','MSN-04','SENSOR ERROR','Rp 500.000','45 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0008','25-Jan-26','MSN-06','overheat','2500000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0009','2026-03-17','MSN-08','Electrical Fault','Rp 3,000,000','45 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0010','01-Jan-26','MSN-01','Mold Misalignment','Rp 2,500,000','90 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0011','23-Jan-26','MSN-03','Sensor Error','Rp 500.000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0012','11-Feb-26','MSN-07','belt damage','Rp 3,000,000','4 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0013','20/02/2026','MSN-05','Electrical Fault','750000','90 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0014','07/03/2026','MSN-06','Mold Misalignment','750000','45 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0015','07-Feb-26','MSN-06','Sensor Error','Rp 750,000','120 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0016','11-Feb-26','MSN-02','Belt Damage','Rp 3.000.000','120 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0017','27-Mar-26','MSN-07','Mold Misalignment','Rp 1.200.000','4 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0018','2026-01-14','MSN-07','Sensor Error','Rp 500,000','0.5 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0019','21/01/2026','MSN-05','Sensor Error','Rp 500,000','4 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0020','2026-03-11','MSN-06','Electrical Fault','','240 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0021','2026-03-13','MSN-07','SENSOR ERROR','Rp 3,000,000','60 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0022','07/01/2026','MSN-07','belt damage','Rp 1,200,000','0.5 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0023','2026-02-02','MSN-08','SENSOR ERROR','Rp 1,200,000','120 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0024','26-Jan-26','MSN-04','Hydraulic Leak','2500000','3 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0025','23-Jan-26','MSN-02','belt damage','Rp 500.000','60 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0026','2026-01-17','MSN-05','Overheat','Rp 1.200.000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0027','2026-01-06','MSN-06','Overheat','Rp 3,000,000','60 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0028','15-Mar-26','MSN-06','overheat','Rp 1,200,000','45 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0029','2026-03-08','MSN-03','belt damage','Rp 3,000,000','1.5 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0030','2026-01-29','MSN-06','Belt Damage','Rp 1.200.000','45 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0031','21-Mar-26','MSN-08','Mold Misalignment','500000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0032','31-Jan-26','MSN-04','Overheat','Rp 1.200.000','240 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0033','19/02/2026','MSN-05','Overheat','Rp 3.000.000','120 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0034','27/02/2026','MSN-01','Hydraulic Leak','Rp 750.000','2 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0035','2026-01-13','MSN-01','overheat','Rp 750,000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0036','29/03/2026','MSN-02','SENSOR ERROR','Rp 3,000,000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0037','2026-03-24','MSN-03','Overheat','Rp 2,500,000','1 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0038','2026-01-10','MSN-03','Hydraulic Leak','3000000','120 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0039','03/02/2026','MSN-07','Electrical Fault','Rp 2.500.000','1 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0040','2026-03-28','MSN-01','overheat','3000000','180 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0041','15-Feb-26','MSN-02','Hydraulic Leak','Rp 1,200,000','0.5 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0042','26/02/2026','MSN-07','Overheat','2500000','2 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0043','20-Feb-26','MSN-05','Sensor Error','Rp 1,200,000','240 menit');;
INSERT INTO "tr_maintenance" VALUES('MNT-0044','24/03/2026','MSN-01','Mold Misalignment','3000000','0.5 jam');;
INSERT INTO "tr_maintenance" VALUES('MNT-0045','15-Mar-26','MSN-07','Mold Misalignment','3000000','1 jam');;

COMMIT;

-- ============================================================================
-- SECTION 3: PHASE 1 DATA ACQUISITION — SQL JOIN EXTRACTION
-- Instruction from the brief: "Perform data extraction using the SQL JOIN
-- method on a minimum of 3 tables."
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 3.1 Production extract: tr_produksi JOIN ms_mesin JOIN ms_operator JOIN ms_material
--     (4 tables — exceeds the minimum of 3)
--
--     UPPER() is used on the machine-id join key because the raw id_mesin
--     values are not consistently cased (e.g. 'MSN-04' vs 'msn-04'); a plain
--     case-sensitive join would silently drop those rows from the match.
-- ----------------------------------------------------------------------------
SELECT
    p.id_produksi,
    p.tanggal,
    p.jam,
    p.id_mesin,
    m.nama_mesin,
    m.tipe          AS tipe_mesin,
    m.lokasi,
    p.id_operator,
    o.nama_lengkap   AS nama_operator,
    o.grup_shift,
    o.skill_level,
    p.id_material,
    mt.jenis_bahan_baku,
    mt.vendor_pemasok,
    p.setting_speed_rpm,
    p.suhu_mesin,
    p.output_qty_ok,
    p.reject_qty_ng
FROM tr_produksi p
LEFT JOIN ms_mesin    m  ON UPPER(p.id_mesin)    = UPPER(m.id_mesin)
LEFT JOIN ms_operator o  ON p.id_operator        = o.id_operator
LEFT JOIN ms_material mt ON p.id_material        = mt.id_material;

-- ----------------------------------------------------------------------------
-- 3.2 Maintenance extract: tr_maintenance JOIN ms_mesin (2 tables)
--     Supports the downtime/failure analysis used later in Phase 3.
--     (Requirement of >= 3 tables is already satisfied by query 3.1 above.)
-- ----------------------------------------------------------------------------
SELECT
    mn.id_maintenance,
    mn.tanggal,
    mn.id_mesin,
    m.nama_mesin,
    m.lokasi,
    mn.tipe_kerusakan,
    mn.biaya_perbaikan,
    mn.durasi_downtime
FROM tr_maintenance mn
LEFT JOIN ms_mesin m ON UPPER(mn.id_mesin) = UPPER(m.id_mesin);
