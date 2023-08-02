/**
* @author GFRS Dev Team
* @date 08/02/2015    
* @description gFRS_ThirdPartyController class - controller for gFRS_ThirdParty page.
*/



public without sharing class gFRS_AddDiseaseStateCopay {

    public GFRS_copay_Funding_Request__c fundingRequest        { get; set; }
    public GFRS_Funding_Request__c fundingRequest1        { get; set; }  
    
    public gFRS_CoPay_Disease_State__c ds{get; set;}
    public List<gFRS_Third_Party__c> requestThirdParties { get; set; }
     public List<gFRS_CoPay_Disease_State__c > lstdiseasestate  { get; set; }
    public String introMessage                           { get; set; }
    public Boolean enabled                               { get; set; }
    public Integer currentActiveThirdParty               { get; set; }

    public Boolean allowDeleteThirdParty{
        get{
            if(enabled && lstdiseasestate.size()>1){
                return true;
            }else{
                return false;
            }
        }   
    }

    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description gFRS_ThirdPartyController class - constructor.
    */
    public gFRS_AddDiseaseStateCopay(ApexPages.StandardController std){
    enabled = false;
    ds = new gFRS_CoPay_Disease_State__c();
    lstdiseasestate = new List<gFRS_CoPay_Disease_State__c >();
        //get current funding request reference
        //std.addFields(new List<String>{'Information_Needed__c','Record_Type_Name__c'});
        fundingRequest =  (GFRS_copay_Funding_Request__c)std.getRecord();
        if(fundingRequest == null){
            fundingRequest = new GFRS_copay_Funding_Request__c();
        }else{
            fundingRequest = [Select Status__c, Information_Needed__c,Record_Type_Name__c, Request_Creation_Progress__c,  id from GFRS_copay_Funding_Request__c where id =: fundingRequest.id limit 1].get(0);
           if(this.fundingRequest.Status__c == null || this.fundingRequest.Status__c == 'Intake' || 
            (!String.isBlank(this.fundingRequest.Information_Needed__c) && gFRS_Util.multiSelectHasItem( this.fundingRequest.Information_Needed__c, 'Disease State'))){
         enabled = true;
         }
        }
        system.debug(fundingRequest);
        refreshThirdParty();
        if(lstdiseasestate.size() == 0){
            //create default third party
            gFRS_CoPay_Disease_State__c thirdPartyItem = new gFRS_CoPay_Disease_State__c(Copay_Funding_Request__c =fundingRequest.id);
          //  insert thirdPartyItem;
            lstdiseasestate.add(thirdPartyItem);
        }
        //system.debug()
        // system.debug(requestThirdParties.size());
        introMessage = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( 'Funding Request', UserInfo.getLanguage() ).get('ThirdParty');  
        //
        //set active index to first element on list
        currentActiveThirdParty=0;
       // this.enabled = gFRS_Util.multiSelectHasItem( fundingRequest.Information_Needed__c, 'Third Party' );
       // if(this.enabled == null){
       //      this.enabled=false;
       // }    
        //enabled=true;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description refreshThirdParty method - retrive third parties for current funding request.
    */
    public void refreshThirdParty(){
        lstdiseasestate = new List<gFRS_CoPay_Disease_State__c >([SELECT Copay_Funding_Request__c, CreatedById, CreatedDate, IsDeleted, Disease_State_Fund_Name__c, IsLocked, LastActivityDate, LastModifiedById, LastModifiedDate, MayEdit, ConnectionReceivedId, Id, Requested_Donation_Amount__c, ConnectionSentId, SystemModstamp, Name FROM gFRS_CoPay_Disease_State__c
        
                                             WHERE Copay_Funding_Request__c =: fundingRequest.id
                                             Order by CreatedDate asc                     
                                     ]);
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description refreshThirdParty method - return third parties
    */
    public List<gFRS_Third_Party__c> getThirdParties(){
    
       
        return requestThirdParties;
    }
    
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description saveThirdParties method - save all third parties
    */
    public PageReference saveThirdParties(){
        
            upsert lstdiseasestate;
        
        if(this.fundingRequest.Request_Creation_Progress__c == 'Organization'){
            this.fundingRequest.Request_Creation_Progress__c = 'Donation';
            gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(this.fundingRequest);
        }
        system.debug('check current index:'+currentActiveThirdParty);
       return( new ApexPages.PageReference('/apex/gFRS_FileAttachmentCopay?id='+this.fundingRequest.id ));
   
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description back method - navigate to previous page - application
    */
    public PageReference back(){
    return new ApexPages.PageReference(gFRS_Utilcopay.initializeLinkcopay('/apex/GFRS_Applicationcopay', fundingRequest, null));
       // return( new ApexPages.PageReference( gFRS_Util.initializeLinkcopay( gFRS_Util.PATH_APPLICATION, this.fundingRequest, '' ) ));
    }

    /**
    * @author GFRS Dev Team
    * @date 04/05/2016    
    * @description next method - navigate to next page in read-only mode
    */
    public PageReference next(){
        
        if(this.fundingRequest.Request_Creation_Progress__c == 'Organization'){
            this.fundingRequest.Request_Creation_Progress__c = 'Donation';
            gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(this.fundingRequest);
        }
    
        return( new ApexPages.PageReference('/apex/gFRS_FileAttachmentCopay?id='+this.fundingRequest.id ));
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description addThirdParty method - add new third party item
    */
    public PageReference addThirdParty(){
        

            upsert lstdiseasestate;

            gFRS_CoPay_Disease_State__c thirdPartyItem = new gFRS_CoPay_Disease_State__c(Copay_Funding_Request__c =fundingRequest.id);

            insert thirdPartyItem;

            refreshThirdParty();
            currentActiveThirdParty=lstdiseasestate.size()-1;
            
            system.debug('check current index:'+currentActiveThirdParty);
        
        return null;
        
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description removeThirdParty method - remove third party item
    */
    public PageReference removeThirdParty(){
        delete lstdiseasestate[currentActiveThirdParty];
        refreshThirdParty();
        if(currentActiveThirdParty != 0){
            currentActiveThirdParty--;    
        }
        system.debug('check current index:'+currentActiveThirdParty);
        return null;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description validateThirdParties method - validate if all data under each third
    * party item is set properly
    */
  /*  public Boolean validateThirdParties(){
        Map<String,Schema.SObjectField> labelMap= Schema.SObjectType.gFRS_Third_Party__c.fields.getMap();
        Integer index=0;
        Boolean isValid=true;
        for(gFRS_Third_Party__c t : requestThirdParties){
            isValid &= addRequiredMessage( t.Company_Name__c == null, getFieldLabel(labelMap, 'company_Name__c') );
            isValid &= addRequiredMessage( t.Third_Party_Contact_First_Name__c == null, getFieldLabel(labelMap, 'third_party_contact_first_name__c') );
            isValid &= addRequiredMessage( t.Third_Party_Contact_Last_Name__c == null, getFieldLabel(labelMap, 'third_party_contact_last_name__c') );
            isValid &= addRequiredMessage( t.Third_Party_Company_Function__c == null, getFieldLabel(labelMap, 'third_party_company_function__c') );
            isValid &= addRequiredMessage( t.Third_Party_Contact_Email__c == null, getFieldLabel(labelMap, 'third_party_contact_email__c') );
            if(t.Third_Party_Contact_Email__c != null && !validateEmailAddress(t.Third_Party_Contact_Email__c)){
                isValid &=false;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, '' + getFieldLabel(labelMap, 'third_party_contact_email__c') +': '+Label.gFRS_ThirdParty_InvailidEmail));
            }
            if(fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                isValid &= addRequiredMessage( t.Is_the_Third_Party_org_accredited__c == null, getFieldLabel(labelMap, 'is_the_third_party_org_accredited__c') );
                isValid &= addRequiredMessage( t.Is_Third_Party_org_owned_by_physicians__c == null, getFieldLabel(labelMap, 'is_third_party_org_owned_by_physicians__c') );
            }
            if(!isValid){
                currentActiveThirdParty = index;
                return false;
            }
            index++;
        }
        return true;
    }  
    
    public static string getFieldLabel(Map<String,Schema.SObjectField> item,string field){
        if(item.containsKey(field)){
            if(field == 'is_the_third_party_org_accredited__c' || field == 'is_third_party_org_owned_by_physicians__c'){
                return item.get(field).getDescribe().getInlineHelpText();
            }else{
                return item.get(field).getDescribe().getLabel();    
            }
            
        }else{
            return '';
        }   
    }  
    
    public static Boolean addRequiredMessage( Boolean shouldAddMessage, String fieldName ){
        if( shouldAddMessage ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, '' + fieldName +' '+ System.Label.gFRS_FIELD_NAME_REQUIRED ));
        return( !shouldAddMessage );
    }  
    
    public Boolean validateEmailAddress(String email){
        
        String emailRegex    = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(email);

        return emailMatcher.matches();
    }  */
    /*
    public void createProgramDesignIfNotExists(){
        try{
            List<gFRS_Program_Design_and_Implementation__c> requestProgramDesigns = 
            new List<gFRS_Program_Design_and_Implementation__c>([SELECT id
                                            FROM  gFRS_Program_Design_and_Implementation__c
                                            WHERE GFRS_copay_Funding_Request__c =: this.fundingRequest.id                     
                                     ]);
            if(requestProgramDesigns.size() == 0){
                gFRS_Program_Design_and_Implementation__c programDesign = new gFRS_Program_Design_and_Implementation__c(GFRS_copay_Funding_Request__c=fundingRequest.id);
                insert programDesign;
            }            
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot create program design record!'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }*/
    
}