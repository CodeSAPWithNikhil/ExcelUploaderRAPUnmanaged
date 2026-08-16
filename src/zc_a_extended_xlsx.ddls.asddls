@EndUserText.label: 'abstract excel'
define root abstract entity ZC_a_extended_xlsx
{
//  @UI.facet        : [{
//    id             : 'idFiles',
//    label          : 'Files',
//    position       : 30,
//    type           : #IDENTIFICATION_REFERENCE,
//    targetQualifier: 'FILE'
//  }]
  @Semantics.largeObject: {
    mimeType       : 'excel_mimetype',
    fileName       : 'excel_filename',
    acceptableMimeTypes: [ 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'  ],
    contentDispositionPreference: #INLINE
  }

  @EndUserText.label:'Excel'
  excel_attachment : abap.rawstring(0);
  @Semantics.mimeType: true
  @UI.hidden       : true
  excel_mimetype   : abap.char(128);

  @UI.hidden       : true
  excel_filename   : abap.char(128);
}
