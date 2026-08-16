@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Batch shelf life'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_BATCH_SHELF
  as select from ztbatchshelf
{
      @UI.facet: [
          {
              id: 'General',
              purpose: #STANDARD,
              type: #IDENTIFICATION_REFERENCE,
              label: 'Batch Information',
              position: 10
          }
          ]

      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @EndUserText.label: 'Material'
  key material      as Material,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @EndUserText.label: 'Plant'
  key plant         as Plant,
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @EndUserText.label: 'Batch'
  key batch         as Batch,
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Expiry Date'
      expiry_date   as ExpiryDate,
      @UI.lineItem: [{ position: 50 },
                     { type: #FOR_ACTION,
                      dataAction: 'extendExpiry',
                      label : 'Extend Expiry' },
                      { type: #FOR_ACTION,
                      dataAction: 'extendExpiryExcel',
                      label : 'Extend Expiry Mass' }
                    ]
      @UI.identification: [{ position: 50 }]
      @EndUserText.label: 'Extended Date'
      extended_date as ExtendedDate,
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{ position: 60  }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Status'
      @UI.multiLineText: true
      status        as Status,
      @UI.lineItem: [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      @EndUserText.label: 'Remarks'
      remarks       as Remarks
}
