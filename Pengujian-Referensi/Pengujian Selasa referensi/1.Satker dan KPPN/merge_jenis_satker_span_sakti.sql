merge INTO sakti_ut.ADM_R_JENIS_SATKER arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description
FROM
  (SELECT ffv.flex_value,
    ffvt.description,
    CASE
      WHEN ffv.enabled_flag='Y'
      THEN 0
      ELSE 1
    END AS enabled_flag
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_DFF_SATKER_TYPE'
  AND ffv.summary_flag          ='N'
  AND ffvt.language             ='IN'
  ) ffv
FULL OUTER JOIN sakti_ut.ADM_R_JENIS_SATKER arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
WHEN matched THEN
  UPDATE
  SET arb.deskripsi   =src.description,
    arb.deleted       =src.enabled_flag,
    arb.modified_date = sysdate WHEN NOT matched THEN
  INSERT
    (
      kode,
      deskripsi,
      deleted,
      modified_by,
      modified_date,
      version
    )
    VALUES
    (
      src.flex_value,
      src.description,
      src.enabled_flag,
      'sync',
      sysdate,
      0
    ); 
    commit;