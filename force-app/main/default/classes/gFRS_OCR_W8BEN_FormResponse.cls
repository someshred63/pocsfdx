@RestResource(urlMapping='/GFRS_OCR_JSON_FormResonse/*')
global class gFRS_OCR_W8BEN_FormResponse {
    @HttpPost
    global static void get_W8BEN_FormResponse(){
        String strBatchID = null;
        gFRS_OCR_Forms__c rcd = null;
        try
        {
            String jsonString = RestContext.request.requestBody.toString();  
            System.debug('@@@ Veera'+jsonString);
            RestContext.response.addHeader('Content-Type', 'application/json');
            
            JSONParser parser = JSON.createParser(jsonString);            
            gFRS_OCR_Generic_Resp_Parser parsedResponse = gFRS_OCR_Generic_Resp_Parser.parse(jsonString);
            strBatchID = String.valueOf(parsedResponse.batch_id);
            
            if(strBatchID != null && strBatchID != '')
            {
                //system.debug('@@@:::value of batch_id:::check::'+strBatchID); 
                rcd = [Select id,gFRS_Batch_ID__c,gFRS_Type_of_Form__c,gFRS_Form_Organization__c 
                       from gFRS_OCR_Forms__c where gFRS_Batch_ID__c =:strBatchID];
                if(rcd != null)
                {
                    
                    if(rcd.gFRS_Type_of_Form__c != null && rcd.gFRS_Type_of_Form__c == 'W9 Form')
                    {
                        
                        gFRS_OCR_Form_Response__c frObj = new gFRS_OCR_Form_Response__c();
                        gFRS_Ltng_W9_Parser videdoResponse = (gFRS_Ltng_W9_Parser) JSON.deserialize(jsonString, gFRS_Ltng_W9_Parser.class);
                        List<gFRS_OCR_Form_Response__c> lstFR=new list<gFRS_OCR_Form_Response__c>();
                        
                        frObj.gFRS_OCR_FR_Organization__c = rcd.gFRS_Form_Organization__c;
                        Id objectRecordTypeId = Schema.SObjectType.gFRS_OCR_Form_Response__c.getRecordTypeInfosByName().get('gFRS_W9_Form_RcdType').getRecordTypeId();
                        frObj.RecordTypeId = objectRecordTypeId;
                        //System.debug('@@@ Veera'+videdoResponse.forms[0].data[0]);
                        frObj.gFRS_FormsID__c = rcd.id;
                        
                        //System.debug('@@@ Rejected Case'+videdoResponse.forms[0].name);
                        
                        if(videdoResponse.forms[0].name=='Rejected'){
                            
                            frObj.gFRS_Page_Status__c='Rejected'; 
                            frObj.gFRS_PageID__c=String.valueOf(videdoResponse.forms[0].pages[0].page_id);
                            
                        }
                        else
                        {
                            frObj.gFRS_PageID__c=String.valueOf(videdoResponse.forms[0].data[0].page_id);
                            frObj.gFRS_Page_Status__c='Success'; 
                            //System.debug('@@@ Rejected Case'+videdoResponse.forms[0].name);
                            
                            for(gFRS_Ltng_W9_Parser.Forms fr: videdoResponse.forms)
                            {
                                for(gFRS_Ltng_W9_Parser.Data da : fr.data)
                                {
                                    if(da.field_name=='tp_full_name'){
                                        
                                        frObj.gFRS_tp_full_name__c=da.value;
                                    }
                                    if(da.field_name=='page_id'){
                                        
                                        frObj.gFRS_PageID__c=da.value;
                                    }
                                    if(da.field_name=='tp_entity_name'){
                                        
                                        frObj.gFRS_tp_entity_name__c=da.value;
                                    }
                                    if(da.field_name=='tp_ein'){
                                        
                                        System.debug('@@@'+da.value);
                                        String taxId=da.value;
                                        if(taxId.contains('-')){
                                            frObj.gFRS_tp_ein__c=da.value;
                                        }
                                        else{
                                           taxId=taxId.right(9);
                                           frObj.gFRS_tp_ein__c=taxId.left(2)+'-'+taxId.substring(2,9);
                                        }
                                        
                                    }
                                    
                                    if(da.field_name=='tp_street_address'){
                                        
                                        frObj.gFRS_tp_street_address__c=da.value;
                                    }
                                    
                                    if(da.field_name=='tp_city_state_zip'){
                                        
                                        frObj.gFRS_tp_city_state_zip__c=da.value;
                                    }
                                    
                                    if(da.field_name=='tp_other_account_nos'){
                                        
                                        frObj.gFRS_tp_other_account_nos__c=da.value;
                                    }
                                    
                                    if(da.field_name=='tp_signature'){
                                        
                                        frObj.gFRS_tp_signature__c=da.value;
                                    }
                                     if(da.field_name=='signed_date'){
                                        
                                        frObj.gFRS_signed_date__c=da.value;
                                    }
                                     if(da.field_name=='revision_info'){
                                        
                                        frObj.gFRS_revision_info__c=da.value;
                                    }
                                }
                            }
                        }
                        
                        lstFR.add(frObj);
                        
                        insert lstFR;
                        
                    } 
                    else if(rcd.gFRS_Type_of_Form__c != null && rcd.gFRS_Type_of_Form__c == 'W8 Form')
                    {
                        
                        
                        List<String> checkedlst=new List<String>{'corporation_check','disregarded_entity_check',
                            'partnership_check','simple_trust_check','grantor_trust_check',
                            'complex_trust_check','estate_check','government_check',
                            'central_bank_of_issue_check','tax_exempt_organization_check','private_foundation_check','international_organization_check','non_participating_ffi_check','participating_ffi_check',
                            'reporting_model_1_ffi_check','reporting_model_2_ffi_check','reg_deemed_complaint_ffi_check','part_iv_check','part_v_check',
                            'part_vi_check','part_vii_check','part_viii_check','part_ix_check',
                            'part_x_check','part_xi_check','part_xii_check','part_xiii_check','part_xiv_check',
                            'part_xv_check','part_xvi_check','part_xvii_check',
                            'part_xviii_check','part_xix_check','part_xx_check','part_xxi_check','part_xxii_check',
                            'part_xxiii_check','part_xxiv_check','part_xxv_check','part_xxvi_check','part_xxvii_check','direct_reporting_nffe_check','part_xxviii_check',
                            'not_financial_account_check'};
                                
                                
                                
                                //System.debug('@@@ Veera W8 Response'+jsonString);
                                String ChekedValue;
                        gFRS_OCR_Form_Response__c frObj = new gFRS_OCR_Form_Response__c();
                        gFRS_Ltng_W8_Parser videdoResponse = (gFRS_Ltng_W8_Parser) JSON.deserialize(jsonString, gFRS_Ltng_W8_Parser.class);
                        List<gFRS_OCR_Form_Response__c> lstFR=new list<gFRS_OCR_Form_Response__c>();
                        
                        frObj.gFRS_OCR_FR_Organization__c = rcd.gFRS_Form_Organization__c;
                        Id objectRecordTypeId = Schema.SObjectType.gFRS_OCR_Form_Response__c.getRecordTypeInfosByName().get('gFRS_W8BN_Form_RcdType').getRecordTypeId();
                        frObj.RecordTypeId = objectRecordTypeId;
                        
                        frObj.gFRS_FormsID__c = rcd.id;
                        
                        if(videdoResponse.forms[0].name=='Rejected'){
                            
                            frObj.gFRS_Page_Status__c='Rejected'; 
                            frObj.gFRS_PageID__c=String.valueOf(videdoResponse.forms[0].pages[0].page_id);
                            
                        }
                        else
                        {
                            //frObj.gFRS_PageID__c=String.valueOf(videdoResponse.forms[0].data[0].page_id);
                            frObj.gFRS_Page_Status__c='Success'; 
                            //System.debug('@@@ Rejected Case'+videdoResponse.forms[0].name);
                            
                            for(gFRS_Ltng_W8_Parser.Forms fr: videdoResponse.forms)
                            {
                                for(gFRS_Ltng_W8_Parser.Data da : fr.data)
                                {
                                    
                                    frObj.gFRS_PageID__c=String.valueOf(da.page_id);
                                    if(da.field_name=='bene_org_name'){
                                        
                                        frObj.gFRS_bene_org_name__c=da.value;
                                    }
                                    if(da.field_name=='bene_org_country'){
                                        
                                        frObj.gFRS_bene_org_country__c=da.value;
                                    }
                                    if(da.field_name=='bene_disregarded_entity_name'){
                                        
                                        frObj.gFRS_bene_disregarded_entity_name__c=da.value;
                                    }
                                    if(da.field_name=='bene_perm_residence_street_address'){
                                        
                                        frObj.gFRS_bene_perm_residence_street_address__c=da.value;
                                    }
                                    if(da.field_name=='bene_mailing_street_address'){
                                        
                                        frObj.gFRS_bene_mailing_street_address__c=da.value;
                                    }
                                    
                                   /* if(da.field_name=='bene_tin'){
                                        
                                        frObj.gFRS_bene_tin__c=da.value;
                                    } */
                                    
                                    if(da.field_name=='bene_tin'){
                                        
                                        System.debug('@@@'+da.value);
                                        String taxId=da.value;
                                        if(taxId.contains('-')){
                                            frObj.gFRS_bene_tin__c=da.value;
                                        }
                                        else{
                                           taxId=taxId.right(9);
                                           frObj.gFRS_bene_tin__c=taxId.left(2)+'-'+taxId.substring(2,9);
                                        }
                                        
                                    }
                                                                        
                                    if(da.field_name=='bene_foreign_tin'){
                                        
                                        frObj.gFRS_bene_foreign_tin__c=da.value;
                                    }
                                    if(da.field_name=='bene_giin'){
                                        
                                        frObj.gFRS_bene_giin__c=da.value;
                                    }
                                    if(da.field_name=='bene_ref_no'){
                                        
                                        frObj.gFRS_bene_ref_no__c=da.value;
                                    }
                                    if(da.field_name=='bene_signature'){
                                        
                                        frObj.gFRS_bene_signature__c=da.value;
                                    }
                                    if(da.field_name=='bene_signed_name'){
                                        
                                        frObj.gFRS_bene_signed_name__c=da.value;
                                    }
                                    if(da.field_name=='signed_date'){
                                        
                                        frObj.gFRS_signed_date__c=da.value;
                                    }
                                    if(da.field_name=='bene_perm_residence_city_state_zip'){
                                        
                                        frObj.Bene_perm_residence_city_state_zip__c=da.value;
                                    }
                                    if(da.field_name=='bene_mailing_city_state_zip'){
                                        
                                        frObj.gFRS_bene_mailing_city_state_zip__c=da.value;
                                    }
                                    if(da.field_name=='bene_perm_residence_country'){
                                        
                                        frObj.gFRS_bene_perm_residence_country__c=da.value;
                                    }
                                    if(da.field_name=='bene_mailing_country'){
                                        
                                        frObj.gFRS_bene_mailing_country__c=da.value;
                                    }
                                    if(da.field_name=='revision_info'){
                                        
                                        frObj.gFRS_revision_info__c=da.value;
                                    }
                                    
                                    if(checkedlst.contains(da.field_name)){
                                        
                                        if(da.value!='--blank--'){
                                            if(ChekedValue!=null){
                                                ChekedValue=ChekedValue+';'+da.field_name;
                                            }
                                            else{
                                                ChekedValue=da.field_name+';';
                                            }
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                            frObj.W8_Checked_Values__c=ChekedValue;
                            
                            lstFR.add(frObj);
                            
                            insert lstFR;
                        } 
                    }
                    else if(rcd.gFRS_Type_of_Form__c != null && rcd.gFRS_Type_of_Form__c == 'Electronic Payment Form')
                    {
                        System.debug('@@@ Veera ELE Response'+jsonString);
                        gFRS_OCR_Form_Response__c frObj = new gFRS_OCR_Form_Response__c();
                        gFRS_Ltng_ElePay_Parser videdoResponse = (gFRS_Ltng_ElePay_Parser) JSON.deserialize(jsonString, gFRS_Ltng_ElePay_Parser.class);
                        List<gFRS_OCR_Form_Response__c> lstFR=new list<gFRS_OCR_Form_Response__c>();
                        
                        frObj.gFRS_OCR_FR_Organization__c = rcd.gFRS_Form_Organization__c;
                        Id objectRecordTypeId = Schema.SObjectType.gFRS_OCR_Form_Response__c.getRecordTypeInfosByName().get('gFRS_Elec_Payment_Form_RcdType').getRecordTypeId();
                        frObj.RecordTypeId = objectRecordTypeId;
                        
                        frObj.gFRS_FormsID__c = rcd.id;
                        
                        if(videdoResponse.forms[0].name=='Rejected'){
                            
                            frObj.gFRS_Page_Status__c='Rejected'; 
                            frObj.gFRS_PageID__c=String.valueOf(videdoResponse.forms[0].pages[0].page_id);
                            
                        }
                        else
                        {
                            
                            frObj.gFRS_Page_Status__c='Success'; 
                            //System.debug('@@@ Rejected Case'+videdoResponse.forms[0].name);
                            
                            for(gFRS_Ltng_ElePay_Parser.Forms fr: videdoResponse.forms)
                            {
                                for(gFRS_Ltng_ElePay_Parser.Data da : fr.data)
                                {
                                     frObj.gFRS_PageID__c=String.valueOf(da.page_id);
                                    if(da.field_name=='payee_name'){
                                        
                                        frObj.gFRS_payee_name__c=da.value;
                                    }
                                    
                                    if(da.field_name=='payee_ein_ssn'){
                                        
                                        frObj.gFRS_payee_ein_ssn__c=da.value;
                                    }
                                    
                                    if(da.field_name=='payee_phone'){
                                        
                                        frObj.gFRS_payee_phone__c=da.value;
                                    }
                                    
                                    if(da.field_name=='payee_email'){
                                        
                                        frObj.gFRS_payee_email__c=da.value;
                                    }
                                    
                                    if(da.field_name=='bank_rounting_sort_code'){
                                        
                                        frObj.gFRS_bank_rounting_sort_code__c=da.value;
                                    }
                                    
                                    
                                    if(da.field_name=='bank_account_no'){
                                        
                                        frObj.gFRS_bank_account_no__c=da.value;
                                    }
                                    
                                    
                                    if(da.field_name=='bank_swift_code'){
                                        
                                        frObj.gFRS_bank_swift_code__c=da.value;
                                    }
                                    
                                    
                                    
                                    if(da.field_name=='bank_iban'){
                                        
                                        frObj.gFRS_bank_iban__c=da.value;
                                    }
                                    if(da.field_name=='bank_canada_branch_id'){
                                        
                                        frObj.gFRS_bank_canada_branch_id__c=da.value;
                                    }
                                    if(da.field_name=='bank_name'){
                                        
                                        frObj.gFRS_bank_name__c=da.value;
                                    }
                                    if(da.field_name=='bank_branch_name'){
                                        
                                        frObj.gFRS_bank_branch_name__c=da.value;
                                    }
                                    if(da.field_name=='bank_city'){
                                        
                                        frObj.gFRS_bank_city__c=da.value;
                                    }
                                    if(da.field_name=='bank_account_holder_name'){
                                        
                                        frObj.gFRS_bank_account_holder_name__c=da.value;
                                    }
                                    if(da.field_name=='bank_country'){
                                        
                                        frObj.gFRS_bank_country__c=da.value;
                                    }
                                    if(da.field_name=='intermediary_bank_check'){
                                        
                                        frObj.gFRS_intermediary_bank_check__c=da.value;
                                    }
                                    if(da.field_name=='intermediary_bank_name'){
                                        
                                        frObj.gFRS_intermediary_bank_name__c=da.value;
                                    }
                                    if(da.field_name=='intermediary_bank_country'){
                                        
                                        frObj.gFRS_intermediary_bank_country__c=da.value;
                                    }
                                    if(da.field_name=='intermediary_bank_account_no'){
                                        
                                        frObj.gFRS_intermediary_bank_account_no__c=da.value;
                                    }
                                    if(da.field_name=='intermediary_bank_swift_code'){
                                        
                                        frObj.gFRS_intermediary_bank_swift_code__c=da.value;
                                    }
                                    if(da.field_name=='intermediary_bank_routing_id'){
                                        
                                        frObj.gFRS_intermediary_bank_routing_id__c=da.value;
                                    }
                                    if(da.field_name=='approver_name_title'){
                                        
                                        frObj.gFRS_approver_name_title__c=da.value;
                                    }
                                    if(da.field_name=='approver_signature'){
                                        
                                        frObj.gFRS_approver_signature__c=da.value;
                                    }
                                    if(da.field_name=='signed_date'){
                                        
                                        frObj.gFRS_signed_date__c=da.value;
                                    }
                                    if(da.field_name=='account_type_check'){
                                        
                                        frObj.gFRS_account_type_check__c=da.value;
                                    }
                                    if(da.field_name=='payment_type_check'){
                                        
                                        frObj.gFRS_payment_type_check__c=da.value;
                                    }
                                    if(da.field_name=='payement_currency'){
                                        
                                        frObj.gFRS_payement_currency__c=da.value;
                                    }
                                    
                                }
                            }
                            
                            lstFR.add(frObj);
                            
                            insert lstFR;
                        }
                    }
                } 
            }
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('Status','Success');
            gen.writeStringField('StatusCode','200');
            gen.writeEndObject();
            gen.writeEndArray();
            RestContext.response.responseBody = Blob.valueOf(gen.getAsString());
        }
        catch (Exception ex) 
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('Status','Failed');
            gen.writeStringField('StatusCode','400');
            gen.writeStringField('Message',ex.getMessage());
            gen.writeEndObject();
            gen.writeEndArray();
            RestContext.response.responseBody = Blob.valueOf(gen.getAsString());
            system.debug('@@:::Exception::LineNumber::::'+ex.getLineNumber());
            system.debug('@@:::Exception::Msg::'+ex.getMessage());
        }    
    }
}