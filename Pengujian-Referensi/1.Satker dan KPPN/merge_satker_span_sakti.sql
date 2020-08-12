merge INTO sakti_app.ADM_R_SATKER arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description,
  nvl2(ffv.flex_value,ffv.kode_unit,arb.kode_unit) kode_unit ,
  nvl2(ffv.flex_value,ffv.kode_kppn,arb.kode_kppn) kode_kppn,
  nvl2(ffv.flex_value,ffv.kode_jenis_satker,arb.kode_jenis_satker) kode_jenis_satker
FROM
  (SELECT ffv.flex_value,
    CASE
      WHEN ffv.enabled_flag='Y'
      THEN 0
      ELSE 1
    END AS enabled_flag ,
    ffvt.description,
    SUBSTR(ffv.attribute2,1,3)
    ||'.'
    ||SUBSTR(ffv.attribute2,4,2) kode_unit,
    ffv.attribute5 kode_kppn,
    attribute18 kode_jenis_satker
  FROM fnd_flex_values@SPAN_ST ffv
  LEFT JOIN fnd_flex_value_sets@SPAN_ST ffvs
  ON ffv.flex_value_set_id = ffvs.flex_value_set_id
  LEFT JOIN fnd_flex_values_tl@SPAN_ST ffvt
  ON ffv.FLEX_VALUE_ID          = ffvt.FLEX_VALUE_ID
  WHERE ffvs.FLEX_VALUE_SET_NAME='SPAN_SATKER'
  AND ffv.summary_flag          ='N'
  AND ffvt.language             ='IN'
  AND REGEXP_LIKE(ffv.FLEX_VALUE , '^[0-9]{6}$')
  AND REGEXP_LIKE(ffv.ATTRIBUTE1 , '^[0-9]{3}$')
  AND REGEXP_LIKE(ffv.ATTRIBUTE2 , '^[0-9]{5}$')
  AND REGEXP_LIKE(ffv.ATTRIBUTE5 , '^[0-9]{3}$')
  ) ffv
FULL OUTER JOIN sakti_app.ADM_R_SATKER arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
--WHEN matched THEN
  --UPDATE
  --SET arb.deskripsi      =src.description,
    --arb.deleted          =src.enabled_flag,
    --arb.kode_unit        =src.kode_unit,
    --arb.kode_kppn        =src.kode_kppn,
    --arb.kode_jenis_satker=src.kode_jenis_satker,
    --arb.modified_date    = sysdate
    WHEN NOT matched THEN
  INSERT
    (
      kode,
      deskripsi,
      deleted,
      kode_unit,
      kode_kppn,
      kode_jenis_satker,
      active_date,
      inactive_date,
      kode_kab_kota,
      kode_kewenangan,
      modified_by,
      modified_date,
      version,
      active,
      aktif_1
    )
    VALUES
    (
      src.flex_value,
      src.description,
      src.enabled_flag,
      src.kode_unit,
      src.kode_kppn,
      src.kode_jenis_satker,
      sysdate,
      sysdate+10000,
      '01.51', -- dummy di adm_r_lokasi
      '2',
      'sync',
      sysdate,
      0,
      1,
      1
    );
