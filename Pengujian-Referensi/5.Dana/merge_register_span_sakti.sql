merge INTO sakti_ut.ADM_R_REGISTER arb USING
(SELECT NVL(ffv.flex_value,arb.KODE)flex_value ,
  nvl2(ffv.flex_value,ffv.enabled_flag,1) enabled_flag ,
  nvl2(ffv.flex_value,ffv.description,arb.deskripsi) description,
  nvl2(ffv.flex_value,ffv.lender_name,arb.nama_donor) lender_name,
  nvl2(ffv.flex_value,ffv.no_nphln,arb.no_pln) no_nphln,
  nvl2(ffv.flex_value,ffv.nilai_phln,arb.pagu) nilai_phln,
  nvl2(ffv.flex_value,ffv.tgl_nphln,arb.tgl_pln) tgl_npln,
  nvl2(ffv.flex_value,ffv.nod_currency,arb.kode_mata_uang) nod_currency,
  nvl2(ffv.flex_value,ffv.no_reksus,arb.no_reksus) no_reksus
FROM
  (SELECT register_no flex_value,
    CASE
      WHEN CLOSING_DATE >= SYSDATE
      THEN 0
      WHEN CLOSING_DATE IS NULL
      THEN 0
      ELSE 1
    END AS enabled_flag,
    nama_loan_grant description,
    lender_name,
    no_nphln,
    nilai_phln,
    tgl_nphln,
    nod_currency,
    (SELECT bank_account_num
    FROM
      (SELECT u.bank_account_num,
        u.attribute,
        u.register
      FROM ce_bank_accounts@SPAN_ST s unpivot ( register FOR attribute IN (attribute10, attribute11, attribute12, attribute13, attribute14, attribute15) ) u
      WHERE u.register                                                 IN
        (SELECT register
        FROM
          (SELECT register,
            COUNT(*) jml
          FROM
            (SELECT u.bank_account_num,
              u.attribute,
              u.register
            FROM ce_bank_accounts@SPAN_ST s unpivot ( register FOR attribute IN (attribute10, attribute11, attribute12, attribute13, attribute14, attribute15) ) u
            WHERE u.end_date                                                 IS NULL
            )
          GROUP BY register
          HAVING COUNT(*) = 1
          )
        )
      AND u.end_date IS NULL
      )
    WHERE register=srl.register_no
    ) no_reksus
  FROM apps.sppm_register_lender@SPAN_ST srl
  ) ffv
FULL OUTER JOIN sakti_ut.ADM_R_REGISTER arb
ON arb.kode              =ffv.flex_value
) src ON (src.flex_value = arb.kode)
WHEN matched THEN
  UPDATE
  SET arb.deskripsi    =src.description,
    arb.deleted        =src.enabled_flag,
    arb.nama_donor     =src.lender_name,
    arb.no_pln         = NVL(src.no_nphln,arb.no_pln),
    arb.pagu           =src.nilai_phln,
    arb.tgl_pln        =src.tgl_npln,
    arb.kode_mata_uang =src.nod_currency,
    arb.no_reksus      =src.no_reksus,
    arb.modified_date  = sysdate WHEN NOT matched THEN
  INSERT
    (
      kode,
      deskripsi,
      deleted,
      modified_by,
      modified_date,
      version,
      nama_donor,
      no_pln,
      pagu,
      tgl_pln,
      kode_mata_uang,
      no_reksus
    )
    VALUES
    (
      src.flex_value,
      src.description,
      src.enabled_flag,
      'sync',
      sysdate,
      0,
      src.lender_name,
      NVL(src.no_nphln,'ZZZ'),
      src.nilai_phln,
      src.tgl_npln,
      src.nod_currency,
      src.no_reksus
    );
  COMMIT;