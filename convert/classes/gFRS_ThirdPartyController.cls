/**
* @author GFRS Dev Team
* @date 08/02/2015    
* @description gFRS_ThirdPartyController class - controller for gFRS_ThirdParty page.
*/



public without sharing class gFRS_ThirdPartyController {

    public GFRS_Funding_Request__c fundingRequest        { get; set; }
    public List<gFRS_Third_Party__c> requestThirdParties { get; set; }
    public String introMessage                           { get; set; }
    public Boolean enabled                               { get; set; }
    public Integer currentActiveThirdParty               { get; set; }

    public Boolean allowDeleteThirdParty{
        get{
            if(enabled && requestThirdParties.size()>1){
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
    public gFRS_ThirdPartyController(ApexPages.StandardController std){
        //get current funding request reference
        //std.addFields(new List<String>{'Information_Needed__c','Record_Type_Name__c'});
        fundingRequest =  (GFRS_Funding_Request__c)std.getRecord();
        if(fundingRequest == null){
            fundingRequest = new GFRS_Funding_Request__c();
        }else{
            fundingRequest = [Select Information_Needed__c,Record_Type_Name__c, Foundation_Classified__c, id from GFRS_Funding_Request__c where id =: fundingRequest.id limit 1].get(0);
        }
        system.debug(fundingRequest);
        refreshThirdParty();
        if(requestThirdParties.size() == 0){
            //create default third party
            gFRS_Third_Party__c thirdPartyItem = new gFRS_Third_Party__c(Funding_Request__c=fundingRequest.id);
            insert thirdPartyItem;
            requestThirdParties.add(thirdPartyItem);
        }
        //system.debug()
         system.debug(requestThirdParties.size());
        introMessage = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( 'Funding Request', UserInfo.getLanguage() ).get('ThirdParty');  
        //
        //set active index to first element on list
        currentActiveThirdParty=0;
        this.enabled = gFRS_Util.multiSelectHasItem( fundingRequest.Information_Needed__c, 'Third Party' );
        if(this.enabled == null){
        	 this.enabled=false;
        }	 
        //enabled=true;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description refreshThirdParty method - retrive third parties for current funding request.
    */
    public void refreshThirdParty(){
        requestThirdParties = new List<gFRS_Third_Party__c>([SELECT id,name,Third_Party_Company_Function__c,Third_Party_Contact_Email__c,
                                             Third_Party_Contact_First_Name__c,Third_Party_Contact_Last_Name__c,
                                             Company_Name__c,Funding_Request__c,Is_the_Third_Party_org_accredited__c,
                                             Is_Third_Party_org_owned_by_physicians__c,Funding_Request__r.Record_Type_Name__c
                                             FROM  gFRS_Third_Party__c
                                             WHERE Funding_Request__c =: fundingRequest.id
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
        if(validateThirdParties()){
            update requestThirdParties;

            if(fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                createProgramDesignIfNotExists();
                return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAMDESIGN, this.fundingRequest, '' ) ));
            } else {
                if (this.fundingRequest.foundation_classified__c == 'FALSE' && gFRS_Util.isExternalRequest(this.fundingRequest.Record_Type_Name__c)){
                    PageReference demographicPage = new PageReference(gFRS_Util.PATH_DEMOGRAPHIC);
                    demographicPage.getParameters().put('request_id', this.fundingRequest.id);
                    return demographicPage;
                } else {
                    return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAM, this.fundingRequest, '' ) ));
                }
            }
        }        
        system.debug('check current index:'+currentActiveThirdParty);
        return null;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description back method - navigate to previous page - application
    */
    public PageReference back(){
        return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_APPLICATION, this.fundingRequest, '' ) ));
    }

    /**
    * @author GFRS Dev Team
    * @date 04/05/2016    
    * @description next method - navigate to next page in read-only mode
    */
    public PageReference next(){
        if(fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAMDESIGN, this.fundingRequest, '' ) ));
        } else {
            // if (this.fundingRequest.foundation_classified__c == 'FALSE' && gFRS_Util.isExternalRequest(this.fundingRequest.Record_Type_Name__c)){
            if (gFRS_Util.isExternalRequest(this.fundingRequest.Record_Type_Name__c)){
                PageReference demographicPage = new PageReference(gFRS_Util.PATH_DEMOGRAPHIC);
                demographicPage.getParameters().put('request_id', this.fundingRequest.id);
                return demographicPage;
            } else {
                return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAM, this.fundingRequest, '' ) ));
            }
        }
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description addThirdParty method - add new third party item
    */
    public PageReference addThirdParty(){
        if(validateThirdParties()){

            update requestThirdParties;

            gFRS_Third_Party__c thirdPartyItem = new gFRS_Third_Party__c(Funding_Request__c=fundingRequest.id);

            insert thirdPartyItem;

            refreshThirdParty();
            currentActiveThirdParty=requestThirdParties.size()-1;
            
            system.debug('check current index:'+currentActiveThirdParty);
        }
        return null;
        
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description removeThirdParty method - remove third party item
    */
    public PageReference removeThirdParty(){
        delete requestThirdParties[currentActiveThirdParty];
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
    public Boolean validateThirdParties(){
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
    }

    public void createProgramDesignIfNotExists(){
        try{
            List<gFRS_Program_Design_and_Implementation__c> requestProgramDesigns = 
            new List<gFRS_Program_Design_and_Implementation__c>([SELECT id
                                            FROM  gFRS_Program_Design_and_Implementation__c
                                            WHERE gFRS_Funding_Request__c =: this.fundingRequest.id                     
                                     ]);
            if(requestProgramDesigns.size() == 0){
                gFRS_Program_Design_and_Implementation__c programDesign = new gFRS_Program_Design_and_Implementation__c(gFRS_Funding_Request__c=fundingRequest.id);
                insert programDesign;
            }            
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot create program design record!'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
}