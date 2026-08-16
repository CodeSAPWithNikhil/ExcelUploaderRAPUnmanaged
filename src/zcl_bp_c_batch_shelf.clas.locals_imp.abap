CLASS lcl_buffer DEFINITION.

  PUBLIC SECTION.

    CLASS-DATA: GT_delete        TYPE TABLE OF zc_batch_shelf,
                gt_extend_expiry TYPE TABLE OF zc_batch_shelf.

ENDCLASS.

CLASS lhc_ZC_BATCH_SHELF DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zc_batch_shelf RESULT result.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zc_batch_shelf.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_batch_shelf RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_batch_shelf.

    METHODS extendExpiry FOR MODIFY
      IMPORTING keys FOR ACTION zc_batch_shelf~extendExpiry. "RESULT result.

    METHODS extendExpiryExcel FOR MODIFY
      IMPORTING keys FOR ACTION zc_batch_shelf~extendExpiryExcel.

ENDCLASS.

CLASS lhc_ZC_BATCH_SHELF IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD delete.
    lcl_buffer=>gt_delete = CORRESPONDING #( keys ).
    LOOP AT keys INTO DATA(ls_key).
      APPEND CORRESPONDING #( ls_key ) TO mapped-zc_batch_shelf ASSIGNING FIELD-SYMBOL(<lfs_mapped>).
      <lfs_mapped>-%cid = ls_key-%cid_ref.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.

    SELECT * FROM zc_batch_shelf AS db INNER JOIN @keys AS ky ON db~Material = ky~Material
    AND db~Batch = ky~Batch
    AND db~Plant = ky~Plant
    INTO CORRESPONDING FIELDS OF TABLE @result.


  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD extendExpiry.
    READ ENTITY IN LOCAL MODE zc_batch_shelf
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT keys INTO DATA(ls_key).
      IF line_exists( lt_result[ %tky = ls_key-%tky ] ).
        APPEND CORRESPONDING #( ls_key ) TO lcl_buffer=>gt_extend_expiry ASSIGNING FIELD-SYMBOL(<lfs_data>).
        <lfs_data>-ExtendedDate = ls_key-%param-extended_date.
        <lfs_data>-Remarks = ls_key-%param-remarks_d.
        APPEND CORRESPONDING #( ls_key ) TO mapped-zc_batch_shelf ASSIGNING FIELD-SYMBOL(<lfs_mapped>).
        <lfs_mapped>-%cid = ls_key-%cid_ref.
*       APPEND CORRESPONDING #( ls_key ) TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
*        <lfs_result>-%cid_ref = ls_key-%cid_ref.
      ELSE.
        APPEND CORRESPONDING #( ls_key ) TO failed-zc_batch_shelf ASSIGNING FIELD-SYMBOL(<lfs_failed>).
        <lfs_failed>-%cid = ls_key-%cid_ref.
        <lfs_failed>-%action = VALUE #( extendExpiry = if_abap_behv=>mk-on ).
        reported-zc_batch_shelf = VALUE #( BASE reported-zc_batch_shelf (  %action = VALUE #( extendExpiry = if_abap_behv=>mk-on  )
                                                                           %cid    = ls_key-%cid_ref
                                                                           %tky    = ls_key-%tky
                                                                           %msg    = new_message_with_text(  severity = if_abap_behv_message=>severity-error
                                                                                                             text     = |Invalid input|   ) )  ).
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD extendExpiryExcel.

    DATA lt_extend_action TYPE TABLE FOR ACTION IMPORT zc_batch_shelf~extendExpiry.

    TYPES: BEGIN OF ty_sheet,
             material TYPE string,
             plant TYPE string,
             batch TYPE string,
             date  TYPE string,
           END OF ty_sheet.

    DATA lt_sheet_data TYPE TABLE OF ty_sheet.

    LOOP AT keys INTO DATA(ls_key).
      IF ls_key-%param-remarks_d IS INITIAL OR ls_key-%param-_streamproperties-excel_attachment IS INITIAL.
        APPEND CORRESPONDING #( ls_key ) TO failed-zc_batch_shelf ASSIGNING FIELD-SYMBOL(<lfs_failed>).
        <lfs_failed>-%cid = ls_key-%cid.
        <lfs_failed>-%action = VALUE #( extendExpiry = if_abap_behv=>mk-on ).
        reported-zc_batch_shelf = VALUE #( BASE reported-zc_batch_shelf (  %action = VALUE #( extendExpiryExcel = if_abap_behv=>mk-on  )
                                                                           %cid    = ls_key-%cid
                                                                           %msg    = new_message_with_text(  severity = if_abap_behv_message=>severity-error
                                                                                                             text     = |Input is Mandatory|   ) )  ).
        CONTINUE.
      ENDIF.

      IF ls_key-%param-_streamproperties-excel_mimetype <> 'application/vnd.ms-excel' AND
      ls_key-%param-_streamproperties-excel_mimetype <> 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
        APPEND CORRESPONDING #( ls_key ) TO failed-zc_batch_shelf ASSIGNING <lfs_failed>.
        <lfs_failed>-%cid = ls_key-%cid.
        <lfs_failed>-%action = VALUE #( extendExpiry = if_abap_behv=>mk-on ).
        reported-zc_batch_shelf = VALUE #( BASE reported-zc_batch_shelf (  %action = VALUE #( extendExpiryExcel = if_abap_behv=>mk-on  )
                                                                           %cid    = ls_key-%cid
                                                                           %msg    = new_message_with_text(  severity = if_abap_behv_message=>severity-error
                                                                                                             text     = |Only excel sheet is allowed|   ) )  ).
        CONTINUE.
      ENDIF.
      lt_sheet_data = VALUE #(  ).
      DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ls_key-%param-_streamproperties-excel_attachment )->read_access( ).

      DATA(lo_worksheet) = lo_document->get_workbook( )->worksheet->at_position( 1 ).

      DATA(o_sel_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )  " Start reading from Column A
        )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'N' )   " End reading at Column N
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )    " *** Start reading from ROW 2 to skip the header ***
        )->get_pattern( ).

      lo_worksheet->select(  o_sel_pattern
                                       )->row_stream(
                                       )->operation->write_to( REF #( lt_sheet_data )
                                       )->set_value_transformation(
                                           xco_cp_xlsx_read_access=>value_transformation->string_value
                                       )->execute( ).
      lt_extend_action = VALUE #(  ).
      LOOP AT lt_sheet_data REFERENCE INTO DATA(ls_sheet).
        DATA(lv_index) = sy-tabix.
        TRY.
            cl_abap_datfm=>conv_date_ext_to_int(
              EXPORTING im_datext    = ls_sheet->date
                        im_datfmdes  = CONV #( 1 )
              IMPORTING ex_datint    = DATA(lv_date) ).

            ls_sheet->date = lv_date.

            APPEND CORRESPONDING #( ls_sheet->* ) TO lt_extend_action ASSIGNING FIELD-SYMBOL(<lf_extent>).
           " <lf_extent>-%cid_ref = lv_index.
            <lf_extent>-%param-extended_date = lv_date.
            <lf_extent>-%param-remarks_d = ls_key-%param-remarks_d.

          CATCH cx_abap_datfm_no_date cx_abap_datfm_invalid_date cx_abap_datfm_format_unknown cx_abap_datfm_ambiguous.
            "handle exception
        ENDTRY.
      ENDLOOP.

      MODIFY ENTITIES OF zc_batch_shelf IN LOCAL MODE
      ENTITY zc_batch_shelf
      EXECUTE extendExpiry
      FROM lt_extend_action
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported)
      MAPPED DATA(ls_mapped).

      IF ls_failed-zc_batch_shelf IS NOT INITIAL.
        APPEND CORRESPONDING #( ls_key ) TO failed-zc_batch_shelf ASSIGNING <lfs_failed>.
        <lfs_failed>-%cid = ls_key-%cid.
        <lfs_failed>-%action = VALUE #( extendExpiryExcel = if_abap_behv=>mk-on ).
        reported-zc_batch_shelf = VALUE #( BASE reported-zc_batch_shelf (  %action = VALUE #( extendExpiryExcel = if_abap_behv=>mk-on  )
                                                                           %cid    = ls_key-%cid
                                                                           %msg    = new_message_with_text(  severity = if_abap_behv_message=>severity-error
                                                                                                             text     = |Batch expiry extension failed|   ) )  ).
      ELSE.
        APPEND CORRESPONDING #( ls_key ) TO mapped-zc_batch_shelf ASSIGNING FIELD-SYMBOL(<lfs_mapped>).
        <lfs_mapped>-%cid = ls_key-%cid.
        reported-zc_batch_shelf = VALUE #( BASE reported-zc_batch_shelf (  %action = VALUE #( extendExpiryExcel = if_abap_behv=>mk-on  )
                                                                           %cid    = ls_key-%cid
                                                                           %msg    = new_message_with_text(  severity = if_abap_behv_message=>severity-success
                                                                                                             text     = |Batch expiry extended successfully|   ) )  ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZC_BATCH_SHELF DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_BATCH_SHELF IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    LOOP AT lcl_buffer=>gt_delete INTO DATA(ls_delete).
      DELETE FROM ztbatchshelf WHERE material = @ls_delete-Material AND batch = @ls_delete-batch AND plant = @ls_delete-plant.
    ENDLOOP.



    LOOP AT lcl_buffer=>gt_extend_expiry INTO DATA(ls_extend).
      UPDATE ztbatchshelf SET extended_date = @ls_extend-ExtendedDate, remarks = @ls_extend-Remarks WHERE material = @ls_extend-Material
      AND batch = @ls_extend-batch AND plant = @ls_extend-plant.
    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup.
    lcl_buffer=>gt_delete = VALUE #(  ).
    lcl_buffer=>gt_extend_expiry = VALUE #(  ).

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
