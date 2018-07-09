-- PURPOSE:
-- CHANGES:
--   20171122 remove database name #1
--            nama field cursor dari SPAN langsung diubah sesuai SAKTI
--            set active #2

MERGE INTO ADM_R_AKUN sakti USING
(SELECT NVL(span.kode, sakti.kode) kode ,
  NVL2(span.kode, span.deleted, 1) deleted ,
  NVL2(span.kode, span.deskripsi, sakti.deskripsi) deskripsi ,
  NVL2(span.kode, span.tipe_akun, sakti.tipe_akun) tipe_akun
FROM
  (SELECT flex_value kode,
    enabled_flag deleted,
    description deskripsi,
    account_type tipe_akun
  FROM(
    (SELECT ffv.flex_value,
      ffv.flex_value_set_id,
      CASE
        WHEN ffv.enabled_flag='Y'
        THEN 0
        ELSE 1
      END AS enabled_flag ,
      ffvt.description,
      SUBSTR( ffv.compiled_value_attributes, 5, 1 ) account_type
    FROM fnd_flex_values@SPAN_ST ffv
    LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
    ON ffv.flex_value_set_id = ffvs.flex_value_set_id
    LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
    ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
    WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_AKUN'
      --AND ffv.summary_flag          ='N'
    AND ffvt.language ='IN'
    AND ffv.flex_value NOT LIKE '%0'
    AND (ffv.flex_value NOT LIKE 'B%'
    AND ffv.flex_value NOT LIKE 'C%'
    AND ffv.flex_value NOT LIKE 'T%' )
    ) ffvx
  LEFT JOIN apps.fnd_flex_value_norm_hierarchy@SPAN_ST h
  ON ffvx.flex_value         = h.parent_flex_value
  AND ffvx.flex_value_set_id = h.flex_value_set_id )
  ) span
FULL OUTER JOIN sakti_app.ADM_R_AKUN sakti
ON sakti.kode        = span.kode
) span ON (span.kode = sakti.kode)
WHEN matched THEN
  UPDATE
  SET sakti.deskripsi   = span.deskripsi,
    sakti.deleted       = span.deleted,
    sakti.active        = 1,
    sakti.tipe_akun     = span.tipe_akun,
    sakti.modified_date = SYSDATE WHEN NOT matched THEN
  INSERT
    (
      kode,
      deskripsi,
      deleted,
      active,
      active_date,
      inactive_date,
      modified_by,
      modified_date,
      version,
      nama_akun,
      kelompok_akun,
      tahun_anggaran_kode,
      tipe_akun
    )
    VALUES
    (
      span.kode,               -- kode
      span.deskripsi,          -- deskripsi
      span.deleted,            -- deleted
      1,                       -- active
      SYSDATE,                 -- active_date
      SYSDATE+10000,           -- inactive_date
      'sync',                  -- modified_by
      SYSDATE,                 -- modified_date
      0,                       -- version
      '-',                     -- nama_akun
      SUBSTR(span.kode,1,5),   -- kelompok_akun
      TO_CHAR(SYSDATE,'YYYY'), -- tahun_anggaran_kode
      span.tipe_akun           -- tipe_akun
    );
--
--COMMIT;
--    
--    select * from sakti_ut.ADM_R_AKUN ;
--    
--    SELECT ffv.flex_value,
--      CASE
--        WHEN ffv.enabled_flag='Y'
--        THEN 0
--        ELSE 1
--      END AS enabled_flag ,
--      ffvt.description,
--      SUBSTR( ffv.compiled_value_attributes, 5, 1 ) account_type
--    FROM fnd_flex_values@SPAN_ST ffv
--    LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
--    ON ffv.flex_value_set_id = ffvs.flex_value_set_id
--    LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
--    ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
--    LEFT JOIN apps.fnd_flex_value_norm_hierarchy@SPAN_ST h
--    ON ffv.flex_value               = h.parent_flex_value
--    AND ffvs.flex_value_set_id      = h.flex_value_set_id
--    WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_AKUN'
--      --AND ffv.summary_flag          ='N'
--    AND ffvt.language ='IN'
--    AND ffv.flex_value NOT LIKE '%0'
--    AND (ffv.flex_value NOT LIKE 'B%'
--    AND ffv.flex_value NOT LIKE 'C%'
--    AND ffv.flex_value NOT LIKE 'T%') and SUBSTR(ffv.flex_value,1,5) not in (
--     select kode from sakti_ut.ADM_R_KELOMPOK_AKUN);
