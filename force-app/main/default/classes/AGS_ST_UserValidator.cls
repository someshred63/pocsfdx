public without sharing class AGS_ST_UserValidator 
{
    private AGS_ST_User user;
        
    public AGS_ST_UserValidator(AGS_ST_User user)
    {
        this.user = user;
    }
    
    public String validate()
    {
        String msg;
        msg = validateData();   
        if(msg!=null)
            return msg;                           
        return null;
    }       
    
    private String validateData()
    {
        String errMsg;
            
        errMsg = validateNameNotNull();
        if(errMsg != null)
            return errMsg;          
        errMsg = validateNameFormat();
        if(errMsg != null)
            return errMsg;

        errMsg = validateEmailNotNull();
        if(errMsg != null)
            return errMsg;          
            
        errMsg = validateIdNotNull();
        if(errMsg != null)
            return errMsg;          
        errMsg = validateIdFormat();
        if(errMsg != null)
            return errMsg;          
            
        errMsg = validateStreetNotNull();
        if(errMsg != null)
            return errMsg;          
        errMsg = validateStreetFormat();
        if(errMsg != null)
            return errMsg;  
            
        errMsg = validateCityNotNull();
        if(errMsg != null)
            return errMsg;          
        errMsg = validateCityFormat();
        if(errMsg != null)
            return errMsg;  

        errMsg = validateDobNotNull();
        if(errMsg != null)
            return errMsg;          
        errMsg = validateDobFormat();
        if(errMsg != null)
            return errMsg;                      
        return null;        
    }
        
    private String validateNameNotNull()
    {
        if(!AGS_ST_Utils.hasValue(this.user.firstName) && !AGS_ST_Utils.hasValue(this.user.lastName))
            return '"Your First Name" and "Your Last Name" must be filled!';
            
        if(!AGS_ST_Utils.hasValue(this.user.firstName))
            return '"Your First Name" must be filled!';
                    
        if(!AGS_ST_Utils.hasValue(this.user.lastName))
            return '"Your Last Name" must be filled!';        
        
        return null;
    }
    
    private String validateNameFormat()
    {
        if(AGS_ST_Utils.hasValue(this.user.firstName))                          
            if(!AGS_ST_Utils.isAlpha(this.user.firstName))
                return '"Your First Name" can only contain letters!'; 
                    
        if(AGS_ST_Utils.hasValue(this.user.lastName))                       
            if(!AGS_ST_Utils.isLastName(this.user.lastName))
                return '"Your Last Name" can only contain letters!';  
                
        return null;                        
    }
    
    private String validateEmailNotNull()
    {
        if(!AGS_ST_Utils.hasValue(this.user.email) && !AGS_ST_Utils.hasValue(this.user.email2))
            return '"Your Email Address" and "Re-enter Email Address" must be filled!';
                    
        if(!(AGS_ST_Utils.hasValue(this.user.email)))
            return'"Your Email Address" must be filled!';         
        return null;
    }
    
    private String validateIdNotNull()
    {
        if(!(AGS_ST_Utils.hasValue(this.user.npi) || (AGS_ST_Utils.hasValue(this.user.stateLicence) && AGS_ST_Utils.hasValue(this.user.licenceStateCode)) ))
            return 'Please enter either NPI ID or state LIC and state code!';
    
        return null;
    }
    
    private String validateIdFormat()
    {
        if(AGS_ST_Utils.hasValue(this.user.npi))                        
            if(!AGS_ST_Utils.isNumber(this.user.npi))
                return '"NPI#" can only contain digits!'; 
                
        return null;    
    }
    
    private String validateStreetNotNull()
    {
        if(!AGS_ST_Utils.hasValue(this.user.street) && !AGS_ST_Utils.hasValue(this.user.suite))
            return '"Street address" must be filled!';       
        
        if(!AGS_ST_Utils.hasValue(this.user.street))
            return '"Street address" must be filled!';
            
        return null;             
    }
    
    private String validateStreetFormat()
    {
        return null;
    }
    
    private String validateCityNotNull()
    {
        if(!AGS_ST_Utils.hasValue(this.user.city) && !AGS_ST_Utils.hasValue(this.user.state) && !AGS_ST_Utils.hasValue(this.user.zip))
            return '"City", "State Code" and "Zip" must be filled!'; 
                        
        if(!AGS_ST_Utils.hasValue(this.user.city) && !AGS_ST_Utils.hasValue(this.user.state))
            return '"City" and "State Code" must be filled!';    
                
        if(!AGS_ST_Utils.hasValue(this.user.city) && !AGS_ST_Utils.hasValue(this.user.zip))
            return '"City" and "Zip" must be filled!';   
                
        if(!AGS_ST_Utils.hasValue(this.user.zip) && !AGS_ST_Utils.hasValue(this.user.state))
            return '"Zip" and "State Code" must be filled!';
                            
        
        if(!AGS_ST_Utils.hasValue(this.user.city))
            return '"City" must be filled!';
        
        if(!AGS_ST_Utils.hasValue(this.user.state))
            return '"State Code" must be filled!';
        
        if(!AGS_ST_Utils.hasValue(this.user.zip))
            return '"Zip" must be filled!';       
            
        return null;
    }
    
    private String validateCityFormat()
    {
        if(AGS_ST_Utils.hasValue(this.user.city))                                   
            if(!AGS_ST_Utils.isAlphaWithSpaces(this.user.city))
                return '"City" can only contain letters!';    
                    
        if(AGS_ST_Utils.hasValue(this.user.state))                      
            if(!AGS_ST_Utils.isAlphaWithSpaces(this.user.state))
                return '"State" can only contain letters!';   
                    
        if(AGS_ST_Utils.hasValue(this.user.zip))                            
            if(!AGS_ST_Utils.isNumber(this.user.zip))
                return '"Zip" can only contain digits!';  
                
        return null;        
    }           

    private String validateDobNotNull()
    {
        if(!(AGS_ST_Utils.hasValue(this.user.dob)))
            return 'Fields "Date of Birth" must be filled!';
    
        return null;
    }
    
    private String validateDobFormat()
    {
       // if (AGS_ST_Utils.stringToDate(this.user.dob) != null)
            return null;  
      //  return 'Invalid date or date format. Field "Date of Birth" should be in MM/DD/YYYY format!';    
    }     

}