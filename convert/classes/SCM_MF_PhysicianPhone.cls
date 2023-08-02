//Created by : Paras Sharma

public class SCM_MF_PhysicianPhone extends SCM_MF_PhysicianCollection{

	public SCM_MF_PhysicianPhone(String accountId) {
		super(accountId);
		
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        key = 'Physician Phone';
	}
	
	public override String getFieldValue() {				
		if(physicianManager !=null && physicianManager.Phone != null ){
			return ProcessPhoneNumber(physicianManager.Phone);		
		}
		else {
			return '' ;
		}
  	}
  	
  	private String ProcessPhoneNumber(string phoneNumber) 
  		{
  			phoneNumber = phoneNumber.ReplaceAll('\\Dx', '');
  			if (phoneNumber.contains('x'))
  			{
  				return phoneNumber;
  			}
  			else
  			{
  				// Not sure what assigning character > 10 means.
  				phoneNumber = (phoneNumber.length() > 10 )? phoneNumber.Trim():phoneNumber;
  				if (phoneNumber.length() == 7)
  				{
  					phoneNumber = phoneNumber.substring(0,2) + '-' + phoneNumber.substring(3,6);  					
  				}
  				else if (phoneNumber.length() > 7)
  				{
  					Integer startIndex = 0;
  					String phoneNumberLocal;
  					String PhoneNumberCode;
  					
  					startIndex = phoneNumber.length() - 7; 
  					phoneNumberLocal = phoneNumber.substring(startIndex , (startIndex + 2) ) 
  								  + '-' + phoneNumber
  								  .substring(( startIndex + 3),( startIndex + 6 ) );
  					
  					phoneNumberCode = '(' + phoneNumber.substring(0, startIndex) + ')';
  					phoneNumber = phoneNumberCode + phoneNumberLocal;  								    					
  				}
  				else if ((phoneNumber.length() < 7))
  				{
  					Integer EndIndex = 0;
  					
  					EndIndex = phoneNumber.length() - 4 ;
  					if (EndIndex <= 0)
  					{
  						phoneNumber = '(999)999-9999';
  					}
  					else
  					{ 
	  					phoneNumber = phoneNumber.substring(0,EndIndex) + '-' 
	  									+ phoneNumber.substring(EndIndex + 1);	  						  					
  					}
  				}  				
  				return phoneNumber;  				
  			}  			
  		}
	
}