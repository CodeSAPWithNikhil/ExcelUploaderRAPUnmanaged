sap.ui.define([
    "sap/m/MessageToast",
    "sap/m/TextArea",
    "sap/ui/core/Fragment",
    "sap/m/MessageBox"
], function (MessageToast, TextArea, Fragment, MessageBox) {
    'use strict';
    function _readFileAsBase64(oFile) {
        return new Promise((resolve, reject) => {
            const oReader = new FileReader();
            oReader.onload = () => {
                const sResult = oReader.result; // "data:<mime>;base64,AAAA..."
                const sBase64 = sResult.split(",")[1];
                resolve(sBase64);
            };
            oReader.onerror = (e) => reject(e);
            oReader.readAsDataURL(oFile);
        });
    }
    return {
        /**
         * Generated event handler.
         *
         * @param oContext the context of the page on which the event was fired. `undefined` for list report page.
         * @param aSelectedContexts the selected contexts of the table rows.
         */
        UploadExcel2: async function (oContext, aSelectedContexts) {
            MessageToast.show("Custom handler invoked.");
            if (!this._oPopup) {

                this._oPopup = await Fragment.load({
                    name: "batchshelf.ext.controller.view1Frag",
                    controller: this
                });
                this._view.addDependent(this._oPopup);
            }
            this._oPopup.open();
        },

        onCloseExtendExpiryDialog: function (oEvent) {
            debugger;
            if (this._oPopup) {

                this._oPopup.close();

                this._oPopup.destroy();
                this._oPopup = null;
            }

        },
        onRemarksChange: function (oEvent) {
            this._sRemarks = oEvent.getParameter("value");
        },
        UploadComplete: () => {

        },
        onExtendExpiryMass: async function (oEvent) {
            debugger;
            const oSelectedFile = this._oSelectedFile;
            const sRemarks = this._sRemarks;

            if (!oSelectedFile) {
                MessageBox.error("Please select an Excel file before submitting.");
                return;
            }
            if (!sRemarks) {
                MessageBox.error("Remarks is mandatory.");
                return;
            }
            try {
                const sBase64 = await _readFileAsBase64(oSelectedFile);
                const oModel = oEvent.getSource().getModel();

                // action is unbound -> bind directly off the model root

                // 2. Prepare the payload (data object matching your backend Entity properties)
                var oPayload = {
                    "excel_attachment": sBase64,
                    "excel_mimetype": oSelectedFile.type || "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "excel_filename": oSelectedFile.name,
                    "remarks": sRemarks
                }
                var oListBinding = oModel.bindList("/ZC_BATCH_SHELF/SAP__self.excelUploadUi");
                var oContext = oListBinding.create(oPayload);

                // 3. Trigger the POST call
                oContext.created().then(
                    function () {
                        // Success callback
                        sap.m.MessageToast.show("V4 Entry created successfully!");
                    },
                    function (oError) {
                        // Error callback
                        sap.m.MessageBox.error("V4 Creation failed: " + oError.message);
                    }
                );

            } catch (oError) {
                MessageBox.error("Upload failed: " + (oError.message || oError));
            }

        },
        onFileChange: function (oEvent) {
            const oFile = oEvent.getParameter("files") && oEvent.getParameter("files")[0];
            // stash it for use later, e.g. on a local model or controller property
            this._oSelectedFile = oFile || null;
        }
    };
});
