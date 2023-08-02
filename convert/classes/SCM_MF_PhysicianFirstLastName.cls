// Added By: Shobha Rawat
// Merge field for Physician  First and Last name

public class SCM_MF_PhysicianFirstLastName extends SCM_MF_PhysicianCollection 
{
		string phyName='';
	 public SCM_MF_PhysicianFirstLastName(String accountId) 
		{
		super(accountId);
		
		key = 'Physician First Last Name';
		checked = false;
	    displayCheck = false;
       	displayTextBox = false;
        displayLabel = false;
        className='SCM_MF_PhysicianFirstLastName';
     
		}
	 
	public override String getFieldValue() 
	{				
		if(physicianManager !=null )
		{	
			 
			  if(physicianManager.LastName != null)
			{
				phyName= physicianManager.LastName ;				
			}
			if(physicianManager.FirstName != null )
			{
				phyName=physicianManager.FirstName+' '+phyName	 ;		
			}
		    
		return phyName;	
		}
		else  
		{
			return '' ;
		}
  	}
	
}