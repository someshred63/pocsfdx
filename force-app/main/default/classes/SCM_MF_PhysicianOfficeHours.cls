//created By Shobha Rawat


public class SCM_MF_PhysicianOfficeHours extends SCM_MF_AddressField{
		public SCM_MF_PhysicianOfficeHours(String addressId){
    	super(addressId);
		    	      
	    Key = 'PhysicianOfficeHours';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
	    className='SCM_MF_PhysicianOfficeHours';   
        fieldValue=getFieldValue();
    }
    
    public override String getFieldValue() {
    	string operatingHours = '';
			if(address != Null){
				string startHours=address.Operating_Hours_Start_gne__c;
				string endHours=address.Operating_Hours_End_gne__c;
    			if (startHours != null)
	    			operatingHours = startHours ;
				if ( endHours != null)
	    			operatingHours = operatingHours + ' ' + endHours ;
					
	   		 }
	   		   operatingHours=(operatingHours==null)?'':operatingHours;  
    		   return operatingHours;	
		
    }

}