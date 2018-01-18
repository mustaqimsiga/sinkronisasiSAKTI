merge INTO ADM_R_KEGIATAN arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description,
  nvl2(ffv.flex_value,ffv.attribute3,arb.SUB_FUNGSI_KODE) attribute3
FROM
  (SELECT DATA_12.flex_value,
    DATA_3.enabled_flag,
    DATA_3.description,
    DATA_12.attribute3
  FROM
    (SELECT DISTINCT DATA_1.flex_value,
      DATA_1.KEGIATAN,
      SUBSTR(DATA_2.attribute3,1,2)
      || '.'
      || SUBSTR(DATA_2.attribute3,3,2) attribute3
    FROM
      (SELECT DISTINCT SUBSTR(CONCATENATED_SEGMENTS_LOW,4,3)
        || '.'
        || SUBSTR(CONCATENATED_SEGMENTS_LOW,7,2)
        || '.'
        || SUBSTR(CONCATENATED_SEGMENTS_LOW,9,3)
        || SUBSTR(CONCATENATED_SEGMENTS_LOW,12,4) flex_value,
        SUBSTR(CONCATENATED_SEGMENTS_LOW,12,4) KEGIATAN,
        SUBSTR(CONCATENATED_SEGMENTS_LOW,12,7) OUTPUT
      FROM apps.FND_FLEX_VALIDATION_RULE_LINES@SPAN_ST
      WHERE FLEX_VALIDATION_RULE_NAME                 ='CVR002'
      AND INCLUDE_EXCLUDE_INDICATOR                   ='I'
      AND ENABLED_FLAG                                = 'Y'
      AND SUBSTR(CONCATENATED_SEGMENTS_LOW,7,2) NOT  IN ('ZZ','00')
      AND SUBSTR(CONCATENATED_SEGMENTS_LOW,9,2) NOT  IN ('ZZ','00')
      AND SUBSTR(CONCATENATED_SEGMENTS_LOW,12,4) NOT IN ('ZZZZ', '0000')
      AND SUBSTR(CONCATENATED_SEGMENTS_LOW,16,3) NOT IN ('ZZZ', '000')
      ) DATA_1
    LEFT JOIN
      (SELECT data_1.flex_value,
  data_2.attribute3
FROM (
  (SELECT ffv.flex_value,
    attribute1
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID            = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME  ='SPAN_OUTPUT'
  AND SUBSTR(ffv.flex_value,5,3) != 'ZZZ'
  AND ffv.summary_flag ='N'
  AND ffvt.language    ='IN'
  ) data_1
LEFT JOIN
  (SELECT ffv.attribute1,
    REGEXP_SUBSTR(listagg(ffv.attribute3,',') within GROUP (
  ORDER BY ffv.last_update_date DESC), '([0-9]+)', 1) attribute3
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID            = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME  ='SPAN_OUTPUT'
  AND ffv.summary_flag            ='N'
  AND ffvt.language               ='IN'
  AND SUBSTR(ffv.flex_value,5,3) != 'ZZZ'
  GROUP BY ffv.attribute1
  ) data_2 ON data_1.attribute1= data_2.attribute1 )
      ) DATA_2 ON DATA_1.OUTPUT     = DATA_2.flex_value
    WHERE DATA_2.flex_value        IS NOT NULL
    ) data_12
  LEFT JOIN
    (SELECT ffv.flex_value,
      CASE
        WHEN ffv.enabled_flag='Y'
        THEN 0
        ELSE 1
      END AS enabled_flag ,
      ffvt.description
    FROM fnd_flex_values@SPAN_ST ffv
    LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
    ON ffv.flex_value_set_id = ffvs.flex_value_set_id
    LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
    ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
    WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_DFF_KEGIATAN'
    AND ffv.summary_flag          ='N'
    AND ffvt.language             ='IN'
    ) DATA_3 ON DATA_12.KEGIATAN  = DATA_3.flex_value
    WHERE DATA_3.enabled_flag = '0'
  ) ffv
FULL OUTER JOIN ADM_R_KEGIATAN arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
WHEN matched THEN
  UPDATE
  SET arb.deskripsi     =src.description,
    arb.deleted         =src.enabled_flag,
    arb.SUB_FUNGSI_KODE =src.attribute3,
    arb.modified_date   = sysdate WHEN NOT matched THEN
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
      SUB_FUNGSI_KODE,
      program_kode
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
      src.attribute3,
      SUBSTR(src.flex_value,1,9)
    ); 