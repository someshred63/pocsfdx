public class RosterAPIQueueable implements Queueable, Database.AllowsCallouts
{
    private String nextPagePath;
    
    public  RosterAPIQueueable(String nextPagePath)
    {
        this.nextPagePath = nextPagePath;
    }
    
    public void execute(QueueableContext context) 
    {
        Roster_Setting__mdt rstrMdt = [select MasterLabel,Client_Id__c,Client_Secret__c,Endpoint_Url__c from Roster_Setting__mdt where MasterLabel = 'RosterInfo'];
        string clientId = rstrMdt.Client_Id__c ; 
        string clientSecret =rstrMdt.Client_Secret__c;
        string endptURL =rstrMdt.Endpoint_Url__c;
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        request.setEndPoint(endptURL+this.nextPagePath);
        
        System.debug('endptURL+this.nextPagePath :::::' + endptURL+this.nextPagePath);
        
        request.setMethod('GET');
        Blob headerValue = Blob.valueOf(clientId + ':' + clientSecret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        request.setHeader('Authorization', authorizationHeader);
        
        List<Roster_Data__c> sObjList = new List<Roster_Data__c>();
        
        HttpResponse response = h.send(request);                
        if(response.getstatusCode() == 200 && response.getbody() != null){
            //System.debug('rosterData :::::' + response.getBody());
            Roster_JSON rosterData = Roster_JSON.parse(response.getBody());
            
           
            
            if(rosterData != null && rosterData.data != null && rosterData.data.size() > 0)
            {
                system.debug('All Veeva data ' + rosterData.data.size());
                for(Roster_JSON.Data d : rosterData.data)
                {
                    if(d.Employee_Assignment!=null && d.Employee_Assignment.size() >0 ){
                        for(Roster_JSON.Employee_Assignment assign:d.Employee_Assignment){
                            
                                
                            
                            Roster_Data__c rec = new Roster_Data__c();
                             if(string.isNotBlank(assign.Assignment_end_date)){
                                date dat= date.valueOf(assign.Assignment_end_date);
                                date stadat= date.valueOf(assign.Assignment_start_date);                                
                                 if(dat >= date.today() && stadat<= date.today()){
                                     
                                 }else{
                                      continue;
                                 }
                                   
                            }
                            if(d.LOGIN_ID!=null){
                                rec.put('Employee_Identifier__c', d.EMPLOYEE_IDENTIFIER);
                                rec.put('Login_Id__c', d.LOGIN_ID);
                                rec.put('First_Name__c', d.FIRST_NAME);
                                rec.put('Last_Name__c', d.LAST_NAME);
                                rec.put('Email__c', d.EMAIL_ADDRESS);
                                rec.put('Field_Ecosystem_Name__c', (d.FIELD_ECOSYSTEM_NAME != null ? String.join(d.FIELD_ECOSYSTEM_NAME, ';') : null));
                                rec.put('Field_Ecosystem_Id__c', (d.FIELD_ECOSYSTEM_ID != null ? String.join(d.FIELD_ECOSYSTEM_ID, ';') : null));
                                rec.put('Field_Team__c', (d.FIELD_TEAM != null ? String.join(d.FIELD_TEAM, ';') : null));
                                rec.put('Field_Therepautic_Area__c', (d.FIELD_THEREPAUTIC_AREA != null ? String.join(d.FIELD_THEREPAUTIC_AREA, ';') : null));
                                rec.put('State__c', d.STATE);
                                rec.put('Employee_Status_Code__c', (d.EMPLOYEE_STATUS_CODE != null ? String.join(d.EMPLOYEE_STATUS_CODE, ';') : null));
                                
                                rec.put('Employee_Last_Update_Date__c', d.EMPLOYEE_LAST_UPDATE_DATE);                               
                                
                                rec.put('Field_Title_Code__c',assign.Field_Title_Code);
                                rec.put('Field_Title_Description__c',assign.Field_Title_Description);  
                                rec.put('Field_Area_Code__c',assign.Field_Area_Code);
                                rec.put('Field_Area_Name__c',assign.Field_Area_Name) ;   
                                rec.put('Field_Force__c', assign.Field_Force);    
                                rec.put('Assignment_Type__c', assign.Assignment_Type);
                                rec.put('Assignment_Start_Date__c',assign.Assignment_start_date);
                                rec.put('Assignment_End_Date__c', assign.Assignment_end_date);
                                rec.put('Status__c', assign.Status);
                                rec.put('Assignment_Modified_Date__c', assign.Assignment_Modifiled_date);  
                                rec.put('Region__c', assign.Region);
                                sObjList.add(rec);
                            }
                        }
                    }
                }
                system.debug('Veeva data with assignment' + sObjList.size());
                
                if(sObjList.size() > 0)
                    Database.SaveResult[] rsts=Database.insert( sObjList, false) ;
                    
                
                if(rosterData.ResponseDetails != null && rosterData.ResponseDetails.nextPage)
                {
                    String nextPagePath = '&nextPage=true&path='+rosterData.ResponseDetails.nextPagePath;
                    
                    RosterAPIQueueable apc = new RosterAPIQueueable(nextPagePath);
                    
                    System.enqueueJob(apc);
                }
            }
        }
    }
    
}