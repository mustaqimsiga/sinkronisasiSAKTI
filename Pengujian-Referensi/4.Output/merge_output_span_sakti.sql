merge INTO ADM_R_OUTPUT arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description,
  nvl2(ffv.flex_value,ffv.attribute4,arb.satuan) attribute4
FROM
  (SELECT DATA_1.flex_value,
  DATA_2.enabled_flag,
  DATA_2.description,
  DATA_2.attribute4
FROM
  (SELECT SUBSTR(CONCATENATED_SEGMENTS_LOW,4,3)
    || '.'
    || SUBSTR(CONCATENATED_SEGMENTS_LOW,7,2)
    || '.'
    || SUBSTR(CONCATENATED_SEGMENTS_LOW,9,3)
    || SUBSTR(CONCATENATED_SEGMENTS_LOW,12,4)
    || '.'
    || SUBSTR(CONCATENATED_SEGMENTS_LOW,16,3) flex_value,
    SUBSTR(CONCATENATED_SEGMENTS_LOW,12,7) OUTPUT
  FROM APPS.FND_FLEX_VALIDATION_RULE_LINES@SPAN_ST
  WHERE FLEX_VALIDATION_RULE_NAME                 ='CVR002'
  AND INCLUDE_EXCLUDE_INDICATOR                   ='I'
  AND ENABLED_FLAG                                = 'Y'
  AND SUBSTR(CONCATENATED_SEGMENTS_LOW,7,2) NOT  IN ('ZZ','00')
  AND SUBSTR(CONCATENATED_SEGMENTS_LOW,9,2) NOT  IN ('ZZ','00')
  AND SUBSTR(CONCATENATED_SEGMENTS_LOW,12,4) NOT IN ('ZZZZ', '0000')
  AND SUBSTR(CONCATENATED_SEGMENTS_LOW,16,3) NOT IN ('ZZZ', '000')
  ) DATA_1
LEFT JOIN
  (SELECT ffv.flex_value,
    CASE
      WHEN ffv.enabled_flag='Y'
      THEN 0
      ELSE 1
    END AS enabled_flag ,
    ffvt.description,
    ffv.attribute4
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_OUTPUT'
  AND ffv.summary_flag          ='N'
  AND ffvt.language             ='IN'
  ) DATA_2 ON DATA_1.OUTPUT     = DATA_2.flex_value
  WHERE DATA_2.enabled_flag IS NOT NULL
  ) ffv
FULL OUTER JOIN ADM_R_OUTPUT arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
WHEN matched THEN
  UPDATE
  SET arb.deskripsi      =src.description,
    arb.deleted          =src.enabled_flag,
    arb.satuan           =src.attribute4,
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
      satuan,
      kode_kegiatan
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
      src.attribute4,
      substr(src.flex_value,1,14)
    ); 