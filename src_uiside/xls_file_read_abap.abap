    TYPES: BEGIN OF ty_sheet,
             material TYPE string,
             plant    TYPE string,
             batch    TYPE string,
             date     TYPE string,
           END OF ty_sheet.

    DATA lt_sheet_data TYPE TABLE OF ty_sheet.
    LOOP AT keys INTO DATA(ls_key).
      lt_sheet_data = VALUE #(  ).
      DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ls_key-%param-excel_attachment )->read_access( ).

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
    ENDLOOP.
