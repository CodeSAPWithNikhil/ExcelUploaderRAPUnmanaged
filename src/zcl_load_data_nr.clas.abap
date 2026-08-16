CLASS zcl_load_data_nr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_LOAD_DATA_NR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA lt_batch TYPE STANDARD TABLE OF ztbatchshelf.

    lt_batch = VALUE #(
      FOR i = 1 UNTIL i > 100
      (
        mandt         = sy-mandt
        material      = |MAT{ i WIDTH = 6 PAD = '0' }|
        plant         = |{ ( ( i - 1 ) MOD 5 ) + 1000 }|
        batch         = |BAT{ i WIDTH = 5 PAD = '0' }|
        expiry_date   = sy-datum + i
        extended_date = sy-datum + i + 90
        status        = COND #(
                          WHEN i MOD 3 = 0 THEN 'EXTENDED'
                          WHEN i MOD 2 = 0 THEN 'OPEN'
                          ELSE 'PENDING' )
        remarks       = |Dummy batch shelf-life record { i }.|
        created_by    = sy-uname
        created_on    = sy-datum
        changed_by    = sy-uname
        changed_on    = sy-datum
      )
    ).

    INSERT ztbatchshelf FROM TABLE @lt_batch
           ACCEPTING DUPLICATE KEYS.

    out->write( sy-dbcnt ).

    out->write( lines( lt_batch ) ).

    COMMIT WORK.


  ENDMETHOD.
ENDCLASS.
