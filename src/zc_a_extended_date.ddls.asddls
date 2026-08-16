@EndUserText.label: 'abstract entity'
define abstract entity zc_a_extended_date
{

  @EndUserText.label: 'New Expiry'
  extended_date : dats;
  @EndUserText.label: 'Remarks'
  @UI.multiLineText: true
  remarks_d    : abap.string(6002);

}
