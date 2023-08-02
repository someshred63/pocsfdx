/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-12-20
*  Description: This is a controller extension for GNE_SFA2_Account_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {   
	
	// Wrapper class for Picture File
    public class AttachmentWrapper {
    	public String Name {get;set;}
    	public String Body {get;set;}
    	public String contentType {get; set;} 
    }
    
    public AttachmentWrapper pictureFile {get;set;}
    
    public GNE_SFA2_Account_Edit_Create_Ext(ApexPages.StandardController controller){
       
        super(controller,'/apex/GNE_SFA2_Account_Layout');
        if(controller.getRecord().Id == null){
            //String recordTypeName = System.currentPageReference().getParameters().get('recordTypeName');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordTypeName');
            if(recordTypeName != null){
                this.recordTypeName = recordTypeName;
                RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName AND SobjectType = 'Account' limit 1][0];
                myObject = new Account(recordTypeId =recordType.Id);
            }
            else{
                myObject = new Account();
            }
        }
        
        //for Canada MSL users 
        if(System.currentPageReference().getParameters().get('sfacanadaparentId')!=null){
            String parentIdC = System.currentPageReference().getParameters().get('sfacanadaparentId');
            myObject.put('parentId',parentIdC);
        }
		
		//Initialize Picture File 
        pictureFile = new AttachmentWrapper();
    }
    
    //Override save action for uploading picture file
    public PageReference saveAccount() {
		if(pictureFile.Name != null && pictureFile.Body != null){
			Attachment pictureFileAttach;
			pictureFileAttach = new Attachment(ParentId = controller.getRecord().Id);
			pictureFileAttach.Name = pictureFile.Name;
			pictureFileAttach.Body = EncodingUtil.Base64Decode(pictureFile.Body);
			pictureFileAttach.contentType = pictureFile.contentType;
			try{
				insert pictureFileAttach;
				if(((Account)myObject).Picture_File_Id_gne__c != null){
					try{
						delete new Attachment(Id=((Account)myObject).Picture_File_Id_gne__c);
					}
					catch(DmlException ex){
						System.debug('Attachment cannot be deleted: '+ex);
					}
				}
				myObject.put('Picture_File_Id_gne__c', pictureFileAttach.Id);
				
			}
			catch(DmlException ex){
				System.debug('Attachment cannot be inserted: '+ex);
			}
		}
		return save();
 	}
 	
 	public PageReference setPictureFile(){
        System.debug('Picture File Name: ' + pictureFile.Name);
        System.debug('Picture File Body: ' + pictureFile.Body);
        //pictureFile.Body = Apexpages.currentPage().getParameters().get('fileBody'); 
        return null;
    }
}