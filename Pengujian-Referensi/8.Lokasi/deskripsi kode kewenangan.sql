select * from SAKTI_UT.ADM_R_UAPPBW where lower(deskripsi) like '%pajak%';
select * from SAKTI_UT.ADM_R_UAPPBW where lower(deskripsi) like '%pusat%';

select * from SAKTI_UT.ADM_R_UAKPB where lower(deskripsi) like '%pajak%';
select * from SAKTI_UT.ADM_R_UAKPB where lower(deskripsi) like '%pusat%';

select * from SAKTI_UT.ADM_R_UAKPB where lower(kode) like '%024%';


select * from SAKTI_UT.ADM_R_KEMENTERIAN;

select * from SAKTI_UT.ADM_R_KANWIL;

select * from SAKTI_UT.ADM_R_KPPN;

select * from SAKTI_UT.ADM_R_JENIS_SATKER;

select kode,deskripsi, kode_kewenangan  from SAKTI_UT.ADM_R_SATKER where kode in ( 
'119091',
'672863',
'689952',
'690311',
'100041')   ;

select * from SAKTI_UT.ADM_R_TIPE_AKUN;

select * from SAKTI_UT.ADM_R_JENBEL;

select * from SAKTI_UT.ADM_R_GBKPK;

select * from SAKTI_UT.ADM_R_KBKPK;

select * from SAKTI_UT.ADM_R_BKPK;

select * from SAKTI_UT.ADM_R_KELOMPOK_AKUN;

select * from SAKTI_UT.ADM_R_AKUN;

select * from SAKTI_UT.ADM_R_PROGRAM;

select * from SAKTI_UT.ADM_R_FUNGSI;

select * from SAKTI_UT.ADM_R_SUB_FUNGSI;

select * from SAKTI_UT.ADM_R_KEGIATAN;

select * from SAKTI_UT.ADM_R_OUTPUT;

select * from SAKTI_UT.ADM_R_MATA_UANG;

select * from SAKTI_UT.ADM_R_REGISTER;

select * from SAKTI_UT.ADM_R_REKENING_BANK;

select * from SAKTI_UT.ADM_R_KEWENANGAN;

select * from SAKTI_UT.ADM_R_LOKASI;