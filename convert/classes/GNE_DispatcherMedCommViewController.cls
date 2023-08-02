public without sharing class GNE_DispatcherMedCommViewController {
 
    public GNE_DispatcherMedCommViewController(ApexPages.StandardController controller) {
        this.controller = controller;
        
    }
    Medical_Communication_gne__c objReferral = null;
    RecordType referralRecordType = null;
    User currentUser = new User();
    private Boolean isSFA2User;
    public PageReference getRedir() 
    {
        System.debug('Inside getRedir --> ');
        referralRecordType = GNE_Referral_Utils.getReferralRecordType();
        objReferral = [Select Id, Name,OwnerId, RecordTypeId, RecordType.Id, RecordType.Name, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Id,Referral_Assignment_gne__r.OwnerId from Medical_Communication_gne__c where Id = :ApexPages.currentPage().getParameters().get('id')];

		currentUser=GNE_Referral_Utils.getCurrentUser(UserInfo.getUserId());
        isSFA2User = GNE_SFA2_Util.isSFA2User();

        PageReference newPage;
        if(objReferral != null){
            if (objReferral.RecordTypeId != null &&  objReferral.RecordTypeId == referralRecordType.Id) {
                //newPage = Page.Contact_View_1;
                if(objReferral.Referral_Assignment_gne__c != null){
                    
                    System.debug('currentUser: --> ' +  currentUser);
                    if(currentUser !=null && currentUser.Profile_Name_gne__c !=null && currentUser.Profile_Name_gne__c !='')
                    {
                        if((currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MedAffairProfile) || currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.SysAdminProfile)) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.TISLProfile)) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MCLProfile))){
                            System.debug(' MedAffair profile user :');
                            newPage = new PageReference('/'+ objReferral.Referral_Assignment_gne__c);  
                        }else if(objReferral.OwnerId == currentUser.Id){
                            System.debug(' Other profile user and he is owner of MC:');
                            newPage = new PageReference('/'+ objReferral.Referral_Assignment_gne__c);
                            //newPage = Page.GNE_MedCommErrorPage;
                            //newPage.getParameters().put('ErrorType', 'viewError');                            
                        } else if(isSFA2User){
							System.debug(' SFA2 user');
                            newPage = new PageReference('/'+ objReferral.Referral_Assignment_gne__c);
						} else {
                            System.debug(' other profile user :');
                            newPage = Page.GNE_MedCommErrorPage;
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not authorised to view this page. xyzs.'));
                            newPage.getParameters().put('ErrorType', 'viewError');
                            //return newPage.setRedirect(true);
                            
                            //newPage = new PageReference('/' + objReferral.id);
                            //newPage.getParameters().put('nooverride', '1');
                        }
                    } else {
						if(isSFA2User){
							newPage = new PageReference('/apex/GNE_SFA2_Med_Comm_Layout?id=' + objReferral.id);
						}else{
							newPage = new PageReference('/' + objReferral.id);
							newPage.getParameters().put('nooverride', '1');
						}
                    }
                } else {
                   if(isSFA2User){
						newPage = new PageReference('/apex/GNE_SFA2_Med_Comm_Layout?id=' + objReferral.id);
					}else{
						newPage = new PageReference('/' + objReferral.id);
						newPage.getParameters().put('nooverride', '1');
					}
                }               
            } else {
                if(isSFA2User){
					newPage = new PageReference('/apex/GNE_SFA2_Med_Comm_Layout?id=' + objReferral.id);
				}else{
					newPage = new PageReference('/' + objReferral.id);
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