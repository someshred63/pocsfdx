public class GNE_CM_DispatcherInfusionEditController {
 
    public GNE_CM_DispatcherInfusionEditController(ApexPages.StandardController controller) 
    {
        this.controller = controller;
        
    }
    Case objCase = null;
    Infusion_gne__c objInfusion = null;
    public PageReference getRedir() 
    {
        System.debug('Inside getRedir --> '+ApexPages.currentPage().getParameters());
        PageReference newPage = ApexPages.currentPage();
        
        System.debug('#### newPage retURL=>'+newPage.getParameters().get('retURL'));
        String returnURL = newPage.getParameters().get('retURL');
        System.debug('#### newPage=>'+newPage);
        System.debug('#### returnURL=>'+returnURL);
        
        List<Case> lstCases = new List<Case> ();
        List<Infusion_gne__c> lstInfusion = new List<Infusion_gne__c> ();
        Id Infu_id = ApexPages.currentPage().getParameters().get('id');
        Id case_id = null;
        String case_number = ''; 
        String case_recordtype='';
        String case_product='';
        Id shipment_id = null;
        String shipment_number = '';
        
        String Infusion_Type = '';
        String Infusion_Injection_Status = '';
        Date Receipt_Date = Date.today();
        String strReceiptDate = System.today().format();
        Boolean isReceiptDateGiven = false;
        
        Id AccountId = null;
        String Account_Name = '';
        String shipmentId = '';
        String actionType = ApexPages.currentPage().getParameters().get('actionType');
        
        System.debug('#### Infu_id=>'+Infu_id);
        System.debug('#### actionType=>'+actionType);
        String[] lstRetUrls = new List<String> ();
        String strPertuzumabProduct = System.Label.GNE_CM_Pertuzumab_Product_Name;
        String strReturnId = '';
        
        if(actionType == null || actionType == 'SaveAndNew')
        {
            System.debug('#### actionType=>'+actionType);
            if(actionType == null || actionType == 'SaveAndNew')
                
                system.debug('-----------------------------------ApexPages------------'+ApexPages.currentPage().getParameters().get('id'));
                lstInfusion = [Select Account_gne__c,Account_gne__r.Name,Case_gne__c, Case_gne__r.CaseNumber, Case_gne__r.Id, Case_gne__r.Product_gne__c,Case_gne__r.RecordType.Name, Case_gne__r.RecordTypeId, Id,Infusion_Type_gne__c,Infusion_Injection_Status_gne__c,Receipt_Date_gne__c, Shipment_gne__c, Shipment_gne__r.Id, Shipment_gne__r.Name from Infusion_gne__c where Id= :ApexPages.currentPage().getParameters().get('id')];
         
            if(lstInfusion != null && lstInfusion.size()>0)
            {
                objInfusion = lstInfusion[0];
                Infu_id = objInfusion.Id;
                if(returnURL != null && returnURL !='')
                {
                    newPage = new PageReference('/a2P/e?retURL='+EncodingUtil.urlEncode(returnURL, 'UTF-8'));
                }else if(objInfusion.Case_gne__c != null)
                {              
                    newPage = new PageReference('/a2P/e?retURL=%2F'+objInfusion.Case_gne__c);
                }
                else if(objInfusion.Shipment_gne__c != null)
                {
                    newPage = new PageReference('/a2P/e?retURL=%2F'+objInfusion.Shipment_gne__c);
                }
                else
                {
                    newPage = new PageReference('/a2P/e?retURL=%2F'+newPage.getParameters().get('retURL'));
                }
                if(objInfusion.Case_gne__c != null)
                {
                    case_id = objInfusion.Case_gne__c;
                    case_number = objInfusion.Case_gne__r.CaseNumber;
                    case_recordtype = objInfusion.Case_gne__r.RecordType.Name;
                    if(objInfusion.Case_gne__r.Product_gne__c != null)
                        case_product = objInfusion.Case_gne__r.Product_gne__c;
                    
                }
                if(String.valueOf(objInfusion.Receipt_Date_gne__c) != null)
                {
                    Receipt_Date = objInfusion.Receipt_Date_gne__c;
                    strReceiptDate = Receipt_Date.format();
                    isReceiptDateGiven = true;
                }else
                {
                    isReceiptDateGiven = false;
                }
                if(objInfusion.Infusion_Type_gne__c != null & objInfusion.Infusion_Type_gne__c!='')
                {
                    Infusion_Type = objInfusion.Infusion_Type_gne__c;
                }
                if(objInfusion.Infusion_Injection_Status_gne__c != null & objInfusion.Infusion_Injection_Status_gne__c !='')
                {
                    Infusion_Injection_Status = objInfusion.Infusion_Injection_Status_gne__c;
                }
                
                if(objInfusion.Shipment_gne__c != null)
                {
                    shipment_id = objInfusion.Shipment_gne__c;
                    shipment_number = objInfusion.Shipment_gne__r.Name;                
                }
                if(objInfusion.Account_gne__c != null)
                {
                    AccountId = objInfusion.Account_gne__c;
                    Account_Name = objInfusion.Account_gne__r.Name;                
                }
                System.debug('Infu_id : ' + Infu_id);
                if(Infu_id != null)
                {
                    if(actionType == null)
                    {
                        newPage.getParameters().put('id', Infu_id);
                        //newPage.getParameters().put('actionType', 'Edit');
                        newPage.getParameters().put('actionType', 'SaveAndNew');
                    }else
                    {
                        newPage.getParameters().put('actionType', 'SaveAndNew');
                    }
                    newPage.getParameters().put('CF00N70000002Lo56', case_number);
                    newPage.getParameters().put('CF00N70000002Lo56_lkid', case_id);
                    newPage.getParameters().put('CF00N70000002Lo5H', shipment_number);
                    newPage.getParameters().put('CF00N70000002Lo5H_lkid', shipment_id);
                    newPage.getParameters().put('case_product', case_product);
                    if (case_product == 'Herceptin') 
                    {
                    //if(case_product!='Avastin' && case_product!='Lucentis' && case_product!='Rituxan' && case_product!='Rituxan RA' && case_product!=strPertuzumabProduct){
                        newPage.getParameters().put('CF00N70000002Lo55', Account_Name);
                        newPage.getParameters().put('CF00N70000002Lo55_lkid', AccountId);
                    }
                    if(isReceiptDateGiven)
                        newPage.getParameters().put('00N70000002Lo5F', strReceiptDate);
                    
                    newPage.getParameters().put('00N70000002Lo5B', Infusion_Type);
                    newPage.getParameters().put('00N70000002Lo5A', Infusion_Injection_Status);
                    
                    newPage.getParameters().put('nooverride', '1');                 
                }else{  
                                      
                }//end if-else on infu_id
            }//end check on lstInfusion
        }//end if on actionType
        else
        {
            System.debug('#### actionType=>'+actionType);
            if(ApexPages.currentPage().getParameters().get('CF00N70000002Lo56') != null && ApexPages.currentPage().getParameters().get('CF00N70000002Lo56') !='')
                case_number = ApexPages.currentPage().getParameters().get('CF00N70000002Lo56');
            if(ApexPages.currentPage().getParameters().get('CF00N70000002Lo56_lkid') != null && ApexPages.currentPage().getParameters().get('CF00N70000002Lo56_lkid') != '')
                case_id = ApexPages.currentPage().getParameters().get('CF00N70000002Lo56_lkid');
            if(ApexPages.currentPage().getParameters().get('CF00N70000002Lo5H_lkid') != null && ApexPages.currentPage().getParameters().get('CF00N70000002Lo5H_lkid') != '')
                shipment_id = ApexPages.currentPage().getParameters().get('CF00N70000002Lo5H_lkid');            
            if(ApexPages.currentPage().getParameters().get('CF00N70000002Lo5H') != null && ApexPages.currentPage().getParameters().get('CF00N70000002Lo5H') !='')
                shipment_number = ApexPages.currentPage().getParameters().get('CF00N70000002Lo5H');         
            if(ApexPages.currentPage().getParameters().get('CF00N70000002Lo55_lkid') != null && ApexPages.currentPage().getParameters().get('CF00N70000002Lo55_lkid') != '')
                AccountId = ApexPages.currentPage().getParameters().get('CF00N70000002Lo55_lkid');
            if(ApexPages.currentPage().getParameters().get('CF00N70000002Lo55') != null && ApexPages.currentPage().getParameters().get('CF00N70000002Lo55') != '')
                Account_Name = ApexPages.currentPage().getParameters().get('CF00N70000002Lo55');
            if(ApexPages.currentPage().getParameters().get('case_product') != null && ApexPages.currentPage().getParameters().get('case_product') !='')
                case_product = ApexPages.currentPage().getParameters().get('case_product');
                //PK-PFS-966 for Xolair CIU. Updated to ensure hitting 'Cancel' button redirects the user to the correct page.
            if(returnURL != null && returnURL !=''){
                newPage = new PageReference('/a2P/e?retURL='+EncodingUtil.urlEncode(returnURL, 'UTF-8'));
            }else if(case_id != null){
                newPage = new PageReference('/a2P/e?retURL=%2F'+case_id);               
            }
            else if(shipment_id != null){
                newPage = new PageReference('/a2P/e?retURL=%2F'+shipment_id);               
            }
            else{
                newPage = new PageReference('/a2P/e?retURL=%2F'+newPage.getParameters().get('retURL'));
            }
            newPage.getParameters().put('case_product', case_product);
            newPage.getParameters().put('CF00N70000002Lo56', case_number);
            newPage.getParameters().put('CF00N70000002Lo56_lkid', case_id);
            newPage.getParameters().put('CF00N70000002Lo5H', shipment_number);
            newPage.getParameters().put('CF00N70000002Lo5H_lkid', shipment_id);
           
            if(case_product=='Herceptin'){
            //if(case_product!='Avastin' && case_product!='Lucentis' && case_product!='Rituxan' && case_product!='Rituxan RA' && case_product!=strPertuzumabProduct){
                newPage.getParameters().put('CF00N70000002Lo55', Account_Name);
                newPage.getParameters().put('CF00N70000002Lo55_lkid', AccountId);
            }
            //PK-PFS-966 for Xolair CIU. To ensure 'Save and New' button redirects the user to the new page after Saving.
            newPage.getParameters().put('actionType', 'Save');
            
            newPage.getParameters().put('nooverride', '1');
            
        }
        newPage.setRedirect(true);
        return newPage;
 
    }
 
    private final ApexPages.StandardController controller;
 
}