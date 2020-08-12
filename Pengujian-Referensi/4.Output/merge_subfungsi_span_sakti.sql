merge INTO sakti_app.ADM_R_SUB_FUNGSI arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description,
  nvl2(ffv.flex_value,ffv.kode_fungsi,arb.fungsi_kode) kode_fungsi
FROM
  (SELECT substr(ffv.flex_value,1,2)||'.'||substr(ffv.flex_value,3,2) flex_value,
    CASE
      WHEN ffv.enabled_flag='Y'
      THEN 0
      ELSE 1
    END AS enabled_flag ,
    ffvt.description,
    substr(ffv.flex_value,1,2) kode_fungsi
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_DFF_SUBFUNGSI'
  AND ffv.summary_flag          ='N'
  AND ffvt.language             ='IN'
  AND REGEXP_LIKE(FFV.FLEX_VALUE , '^[0-9]{4}$')
  ) ffv
FULL OUTER JOIN sakti_app.ADM_R_SUB_FUNGSI arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
--WHEN matched THEN
--  UPDATE
--  SET arb.deskripsi      =src.description,
--    arb.deleted          =src.enabled_flag,
--    arb.fungsi_kode        =src.kode_fungsi,
--    arb.modified_date    = sysdate
    WHEN NOT matched THEN
  INSERT
    (
      kode,
      deskripsi,
      deleted,
      fungsi_kode,
      active_date,
      inactive_date,
      modified_by,
      modified_date,
      version,
      active
    )
    VALUES
    (
      src.flex_value,
      src.description,
      src.enabled_flag,
      src.kode_fungsi,
      sysdate,
      sysdate+10000,
      'sync',
      sysdate,
      0,
      1
    );
    commit;
    
