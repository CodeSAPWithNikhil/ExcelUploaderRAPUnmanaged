@EndUserText.label: 'Action Param for Uploading Excel'
define root abstract entity ZC_A_XLSX_FILE
{
  @EndUserText.label:'Remarks'
  @UI.multiLineText: true
  remarks_d        : abap.string(6001);
     _StreamProperties : association [1] to ZC_a_extended_xlsx on 1 = 1;
    
}
