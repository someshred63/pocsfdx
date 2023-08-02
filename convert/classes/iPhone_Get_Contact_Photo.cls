@RestResource(urlMapping='/iPhoneGetContactPhoto/*')
global with sharing class iPhone_Get_Contact_Photo {
	public iPhone_Get_Contact_Photo() {
		
	}

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String contactId) {
        return iPhone_Commons_gne.buildResponse(
        	new GetContactPhotoResponseBuilder(),
            new ContactPhotoArgs(contactId)
        );
    }
    
    class GetContactPhotoResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
            ContactPhotoArgs contArgs = (ContactPhotoArgs)args;
            Contact cont = iPhone_DAO.getContactPhotoById(contArgs.contactId);
            if (cont == null) {
                throw new iPhone_Commons_gne.IPhoneException('Contact not found: ' + contArgs.contactId);
            }
            
            return new GetContactPhotoResponse(cont);
        }

    }

    public class GetContactPhotoResponse extends iPhone_Commons_gne.RestResponse {
        public String id; //(sfdcId)
        public String photo; //(Photo_gne__c)

        public GetContactPhotoResponse(Contact cont) {
            this.id = cont.id;
            this.photo = cont.Photo_gne__c;
        }
    }
    
	private class ContactPhotoArgs extends iPhone_Commons_gne.DeltaArgs {
    	public String contactId { get; private set; }
    	    	
    	public ContactPhotoArgs(String contactId) {
    	    super();
    		this.contactId = contactId;
    	}
    }

}