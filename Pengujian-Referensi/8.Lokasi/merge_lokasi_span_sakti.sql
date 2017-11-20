merge INTO sakti_ut.ADM_R_LOKASI arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description,
  nvl2(ffv.flex_value,ffv.parent_code,arb.parent_kode) parent_code
FROM
  (SELECT substr(ffv.flex_value,1,2)||'.'||substr(ffv.flex_value,3,2) flex_value,
    CASE
      WHEN ffv.enabled_flag='Y'
      THEN 0
      ELSE 1
    END AS enabled_flag ,
    ffvt.description,
    substr(ffv.flex_value,1,2) parent_code
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_LOKASI'
  AND ffv.summary_flag          ='N'
  AND ffvt.language             ='IN' 
  and substr(ffv.flex_value,1,2) <= '39'
  ) ffv
FULL OUTER JOIN sakti_ut.ADM_R_LOKASI arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
WHEN matched THEN
  UPDATE
  SET arb.deskripsi      =src.description,
    arb.deleted          =src.enabled_flag,
    arb.modified_date    = sysdate WHEN NOT matched THEN
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
      active,
      parent_kode,
      level_
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
      1,
      src.parent_code,
      '3'
    ); 
    commit;
    
    select * from sakti_ut.ADM_R_LOKASI where modified_by = 'sync'; 
    
    SELECT substr(ffv.flex_value,1,2),
    --||'.'||substr(ffv.flex_value,3,2) flex_value,
    CASE
      WHEN ffv.enabled_flag='Y'
      THEN 0
      ELSE 1
    END AS enabled_flag ,
    ffvt.description,
    substr(ffv.flex_value,1,2) parent_code
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_LOKASI'
  AND ffv.summary_flag          ='N'
  AND ffvt.language             ='IN'  and substr(ffv.flex_value,1,2) not in (
  select kode from adm_r_lokasi where parent_kode='00');