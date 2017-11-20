merge INTO sakti_ut.ADM_R_MATA_UANG arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description
FROM
  (SELECT FC.CURRENCY_CODE flex_value,
    CASE
      WHEN FC.enabled_flag ='Y'
      THEN 0
      ELSE 1
    END AS enabled_flag,
    FCT.DESCRIPTION
  FROM APPS.FND_CURRENCIES@SPAN_ST FC
  LEFT JOIN APPS.FND_CURRENCIES_TL@SPAN_ST FCT
  ON FC.CURRENCY_CODE = FCT.CURRENCY_CODE
  WHERE FCT.LANGUAGE  ='IN'
  ) ffv
FULL OUTER JOIN sakti_ut.ADM_R_MATA_UANG arb
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