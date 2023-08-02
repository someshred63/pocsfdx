public class GNE_SFA2_MCCO_AM_Profile_Utility {
    
    /* For storing the active MCCO user extract    */
    public String generatedCSVFile ='';  
    
    /* For storing Users Name and Alias    */
    public List<String> lContacts = new List<String>();
      
    /* Function to collect all MCCO Users having data discrepancies    */
    public void checkMCCOUserDiscrepancy(){
        List<User> lUsers = [SELECT Id, Name, Alias
                                FROM User
                                WHERE 
                                      Profile.name = :System.Label.GNE_SFA2_MCCO_AM_Profile
                                      AND isActive=true
                                      AND (UserRole.name != :System.Label.GNE_SFA2_MCCO_AM_Role 
                                          OR UserPermissionsSFContentUser != true 
                                          OR UserPreferencesContentNoEmail != false 
                                          OR UserPreferencesContentEmailAsAndWhen != false)];                           
                                
        if(!lUsers.isEmpty()){            
            for(User user : lUsers){                
                lContacts.add(user.name+'('+user.alias+')');//Add name and alias for mailing purpose                
            }            
        }
    }

    
     /* Function to create Excel from MCCO User Data    */
    public void createExcelFromUserData(){
        List<User> lMccoUsers = [   SELECT Id, Name, FirstName, LastName, Alias, UserName,
                                            Email,IsActive, LastLoginDate, Profile.Name, UserRole.Name,
                                            LastModifiedBy.Name ,LastModifiedDate
                                    FROM User 
                                    WHERE Profile.Name = :System.Label.GNE_SFA2_MCCO_AM_Profile
                                        AND UserRole.Name = :System.Label.GNE_SFA2_MCCO_AM_Role
                                        AND IsActive = true];
        
        List<String> lQueryFields = new List<String>{
            'ID','NAME','FIRSTNAME','LASTNAME','ALIAS','USERNAME','EMAIL','ISACTIVE','LASTLOGINDATE',
            'PROFILE NAME','USERROLE NAME','USERPERMISSIONSSFCONTENTUSER','USERPREFERENCESCONTENTNOEMAIL',
            'USERPREFERENCESCONTENTEMAILASANDWHEN','LASTMODIFIEDBYNAME','LASTMODIFIEDDATE'
        };
        String queryFieldsRow = String.join( lQueryFields, ',' );
        List<String> lFileRows = new List<String>{ queryFieldsRow };

        for(User user: lMccoUsers){
            List<String> lUserFields = new List<String>{
                user.Id,    
                user.Name,
                user.FirstName,
                user.LastName,
                user.Alias,
                user.UserName,
                user.Email,
                String.valueOf(user.IsActive),
                String.valueOf(user.LastLoginDate),
                user.Profile.Name,
                user.UserRole.Name,
                System.Label.GNE_SFA2_CheckBox_Selected,
                System.Label.GNE_SFA2_CheckBox_Selected,
                System.Label.GNE_SFA2_CheckBox_Selected,
                user.LastModifiedBy.Name,
                String.valueOf(user.LastModifiedDate)
            };

            lFileRows.add(String.join(lUserFields, ',') );
        }
        this.generatedCSVFile = String.join(lFileRows, '\n');
     }


    /* Function to create attachment from Blob and email to User    */
     public Messaging.SendEmailResult[] emailUserData(){      
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        String tDate = Datetime.now().format('MM_dd_yyyy');
        String csvName = 'Active_MCCO_AM_Users_'+tDate+'.csv';

        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
     
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = System.Label.GNE_SFA2_MCCO_AM_Distribution_List.split(',');
        String subject = '';
        String textBody = '';
         if (lContacts.isEmpty()){
            subject = tDate + System.Label.GNE_SFA2_MCCO_AM_Subject_No_Discrepancy;
            textBody = System.Label.GNE_SFA2_MCCO_AM_textBody_No_Discrepancy;
         }
         else{
            subject = tDate + System.Label.GNE_SFA2_MCCO_AM_Subject_Yes_Discrepancy;
            textBody = System.Label.GNE_SFA2_MCCO_AM_textBody1_Yes_Discrepancy + '\n\n'
                       + String.join(lContacts,'\n') + '\n\n'
                       + System.Label.GNE_SFA2_MCCO_AM_textBody2_Yes_Discrepancy;
         }
        OrgWideEmailAddress owe = [SELECT ID,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :System.Label.GNE_SFA2_SFA_OPS_Team];
        if (null != owe) {     
            email.setOrgWideEmailAddressId(owe.id);
        }
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(textBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});  
        return r;                
     }
   }