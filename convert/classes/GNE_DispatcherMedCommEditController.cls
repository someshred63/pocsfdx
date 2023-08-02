public without sharing class GNE_DispatcherMedCommEditController {
 
    public GNE_DispatcherMedCommEditController(ApexPages.StandardController controller) {
        this.controller = controller;
        
    }
    Medical_Communication_gne__c objReferral = null;
    RecordType referralRecordType = null;
    User currentUser = new User();
    private Boolean isSFA2User;
    Boolean isClosed = false;
    public PageReference getRedir() 
    {
        System.debug('Inside getRedir --> ');
        referralRecordType = GNE_Referral_Utils.getReferralRecordType();
        objReferral = [Select Id, Name,OwnerId, RecordTypeId, RecordType.Id, RecordType.Name, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Id,Referral_Assignment_gne__r.OwnerId,Referral_Assignment_gne__r.Status_Referral_gne__c from Medical_Communication_gne__c where Id = :ApexPages.currentPage().getParameters().get('id')];
 
 		currentUser=GNE_Referral_Utils.getCurrentUser(UserInfo.getUserId());
 		isSFA2User = GNE_SFA2_Util.isSFA2UserForUI();
 
        PageReference newPage;
        if(objReferral != null){
            if (objReferral.RecordTypeId != null &&  objReferral.RecordTypeId == referralRecordType.Id) {
                //newPage = Page.Contact_View_1;
                System.debug('#### inside objreferral recordtype');
                if(objReferral.Referral_Assignment_gne__c != null){
                    
                    System.debug('currentUser: --> ' +  currentUser);
                    if(currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.SysAdminProfile)){
                        isClosed = false;
                    }
                    else if((String)objReferral.Referral_Assignment_gne__r.Status_Referral_gne__c  
                    !=GNE_Referral_Utils.strAcknowledged && (String)objReferral.Referral_Assignment_gne__r.Status_Referral_gne__c != GNE_Referral_Utils.strAssigned){
                        if((currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MedAffairProfile)) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.TISLProfile)) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MCLProfile))){
                            isClosed = true;
                        }else{
                            isClosed = false;
                        }
                    }
                    else{
                        if(objReferral.Referral_Assignment_gne__r.OwnerId != UserInfo.getUserId())
                            isClosed = true;
                        else
                            isClosed = false;
                    }
                    if(!isClosed)
                    {
                        System.debug(' MedAffair profile user :');
                        if(isSFA2User){
                        	newPage=GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE) ? Page.GNE_SFA2_Referral : Page.GNE_SFA2_EditReferralPage;
                        	newPage.getParameters().put('id',objReferral.Referral_Assignment_gne__c);
                        }else{
                        	newPage=Page.GNE_EditReferralPage;
                        	newPage.getParameters().put('id',objReferral.Referral_Assignment_gne__c);
                        }
                                               
                    }else{
                        if(isSFA2User){
                        	System.debug(' other profile user :');
                        	newPage = Page.GNE_SFA2_MedCommErrorPage;
                        	newPage.getParameters().put('ErrorType', 'editError');
                        }else{
                        	System.debug(' other profile user :');
                        	newPage = Page.GNE_MedCommErrorPage;
                        	newPage.getParameters().put('ErrorType', 'editError');
                        }
                    }
                }           
            } else {
                PageReference pageRef = ApexPages.currentPage();
                System.debug('#### pageRef=>'+pageRef);
                System.debug('#### pageRef id=>'+pageRef.getParameters().get('id'));
                if(isSFA2User){                    
                    newPage = new PageReference('/apex/GNE_SFA2_Med_Comm_Edit_Create_Layout?id=' + objReferral.id);
                }else{
                	newPage = new PageReference('/' + objReferral.id + '/e?retURL=%2F'+pageRef.getParameters().get('retURL'));
	                //newPage = new PageReference('/' + objReferral.id + '/e');
	                //newPage = ApexPages.currentPage();
	                newPage.getParameters().put('nooverride', '1');
                }
                
            }       
        
        }
        //newPage.getParameters().put('id', c.id);
        newPage.setRedirect(true);
        return newPage;
 
    }
    
    private final ApexPages.StandardController controller;
 
}