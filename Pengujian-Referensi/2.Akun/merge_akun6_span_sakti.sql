merge INTO sakti_ut.ADM_R_AKUN arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description,
  nvl2(ffv.flex_value,ffv.account_type,arb.tipe_akun) account_type
FROM
  (SELECT ffv.flex_value,
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
    LEFT JOIN apps.fnd_flex_value_norm_hierarchy@SPAN_ST h
    ON ffv.flex_value               = h.parent_flex_value
    AND ffvs.flex_value_set_id      = h.flex_value_set_id
    WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_AKUN'
      --AND ffv.summary_flag          ='N'
    AND ffvt.language ='IN'
    AND ffv.flex_value NOT LIKE '%0'
    AND (ffv.flex_value NOT LIKE 'B%'
    AND ffv.flex_value NOT LIKE 'C%'
    AND ffv.flex_value NOT LIKE 'T%')) ffv
FULL OUTER JOIN sakti_ut.ADM_R_AKUN arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
WHEN matched THEN
  UPDATE
  SET arb.deskripsi   =src.description,
    arb.deleted       =src.enabled_flag,
    arb.tipe_akun     =src.account_type,
    arb.modified_date = sysdate WHEN NOT matched THEN
  INSERT
    (
      kode,
      deskripsi,
      deleted,
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
      src.flex_value,
      src.description,
      src.enabled_flag,
      sysdate,
      sysdate+10000,
      'sync',
      sysdate,
      0,
      '-', -- not found
      SUBSTR(src.flex_value,1,5),
      YEAR(sysdate),
      src.account_type
    ); 
    commit;
    
    select * from sakti_ut.ADM_R_AKUN ;
    
    SELECT ffv.flex_value,
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
    LEFT JOIN apps.fnd_flex_value_norm_hierarchy@SPAN_ST h
    ON ffv.flex_value               = h.parent_flex_value
    AND ffvs.flex_value_set_id      = h.flex_value_set_id
    WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_AKUN'
      --AND ffv.summary_flag          ='N'
    AND ffvt.language ='IN'
    AND ffv.flex_value NOT LIKE '%0'
    AND (ffv.flex_value NOT LIKE 'B%'
    AND ffv.flex_value NOT LIKE 'C%'
    AND ffv.flex_value NOT LIKE 'T%') and SUBSTR(ffv.flex_value,1,5) not in (
     select kode from sakti_ut.ADM_R_KELOMPOK_AKUN);