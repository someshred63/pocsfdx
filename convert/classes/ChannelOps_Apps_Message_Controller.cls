/**********************************************************************
Purpose: ChannelOps_Apps_Message_Controller class is bind with 
         ChannelOps_Apps_Message component. It is used fetch the system 
         specific messages to show on Home page and field specific messages 
		 to capture in message field of spoilage request
========================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay      09/05/2019      INITIAL DEVELOPMENT           
***********************************************************************/
Public class ChannelOps_Apps_Message_Controller{
    
    public String applicationName {get;set;}
    public String appModule {get;set;}
    public String messageLocation {get;set;}
    public String msgType {get;set;}   
    public Sobject sObj {get;set;}
    
    //default constructor for component
    public ChannelOps_Apps_Message_Controller(){
        
    }
    
    //parameterized constructor 
    public ChannelOps_Apps_Message_Controller(String applicationName, String appModule, String messageLocation,
                                             String msgType, Sobject sObj){
        this.applicationName = applicationName;
        this.appModule = appModule;
        this.messageLocation =  messageLocation;
        this.msgType = msgType;
        this.sObj = sObj;                                           
    }
    
    /*********************************************************************************************
     Purpose: This method retrieves the channelOps App messages based on application name,
              module, location, type and return the list of channelOps app messages
    **********************************************************************************************/                                
    public List<ChannelOps_Apps_Message__c> getMessageList(){
        List<ChannelOps_Apps_Message__c> appMessageList = new List<ChannelOps_Apps_Message__c>();
        
        String queryStr = 'SELECT Field_API_Name__c, Field_Value__c, Operator__c,Message__c, Message_Type__c,'+
                          'Message_Location__c, Valid_From__c, Valid_To__c FROM  ChannelOps_Apps_Message__c';
        
        String condition = '';
        if(String.isNotBlank(applicationName)){
            condition += 'Application__c = \''+String.escapeSingleQuotes(applicationName)+'\'';
        }
        if(String.isNotBlank(appModule)){
            if(String.isNotBlank(condition)){
                condition += ' AND ';
            }
            condition += '(Application_Module__c = \''+String.escapeSingleQuotes(appModule)+'\' OR Application_Module__c =\''+String.escapeSingleQuotes(ChannelOps_Constants.ALL_MODULES)+'\')';
        }
        if(String.isNotBlank(messageLocation)){
            if(String.isNotBlank(condition)){
                condition += ' AND ';
            }
            condition +='Message_Location__c = \''+String.escapeSingleQuotes(messageLocation)+'\'';
        }
        if(String.isNotBlank(msgType)){
            if(String.isNotBlank(condition)){
                condition += ' AND ';
            }
            condition +='Message_Type__c = \''+String.escapeSingleQuotes(msgType)+'\'';
        }
        
        if(String.isNotBlank(condition)){
            queryStr += ' WHERE ' + condition + ' AND Active__c = true ORDER BY Display_Order__c';
        }else{
            queryStr += ' WHERE Active__c =: true  ORDER BY Display_Order__c';
        }
        if(String.isNotBlank(queryStr)){
            System.debug('queryStr-----'+queryStr);
            appMessageList = (List<ChannelOps_Apps_Message__c>) Database.query(queryStr);
        }
        System.debug('appMessageList-----'+appMessageList);
        
        SObjectType objType = null;
        DescribeSObjectResult describeObjResult = null;
        if(sObj != null){
            objType = sObj.getSObjectType();
            describeObjResult = objType.getDescribe();
        }
        
        List<ChannelOps_Apps_Message__c> channelOpsAppMessageList = new List<ChannelOps_Apps_Message__c>();

        for(ChannelOps_Apps_Message__c channelOpsAppMsg : appMessageList){
            if(isValidDateRange(channelOpsAppMsg.Valid_From__c, channelOpsAppMsg.Valid_To__c)){
                if(describeObjResult != null && channelOpsAppMsg.Message_Type__c == 'Field'){
                    if(String.isNotBlank(channelOpsAppMsg.Field_API_Name__c) && String.isNotBlank(channelOpsAppMsg.operator__c)
                      && describeObjResult != null && describeObjResult.fields.getMap().get(channelOpsAppMsg.Field_API_Name__c) != null){
                    	Schema.Describefieldresult fieldResult =  describeObjResult.fields.getMap().get(channelOpsAppMsg.Field_API_Name__c).getDescribe();
                        if(fieldResult != null && sObj != null && sObj.get(channelOpsAppMsg.Field_API_Name__c) != null){
                            if(isValidMessage(String.valueOf(sObj.get(channelOpsAppMsg.Field_API_Name__c)), channelOpsAppMsg.operator__c,
                            fieldResult.getType().name(),channelOpsAppMsg.Field_Value__c)){
                               channelOpsAppMessageList.add(channelOpsAppMsg);
                            }
                        }
                    }
                }else{
                    channelOpsAppMessageList.add(channelOpsAppMsg);
                }
            }
        }
        return channelOpsAppMessageList;
    }
    
   /*********************************************************************************************
     Purpose: This method accepts the validForm and validTo dates and validate the date against 
              system.today date and returns boolean value(true/false)
    **********************************************************************************************/   
    private Boolean isValidDateRange(Date validFrom, Date validTo){
        Boolean isValid = false;        
        if(validFrom == null && validTo == null){
            isValid = true;
        }else if(validFrom != null && validTo == null && validFrom <= System.today()){
            isValid = true;
        }else if(validFrom == null && validTo != null && validTo >= System.today()){
           isValid = true; 
        }else if(validFrom != null && validTo != null && validFrom <= System.today() && validTo >= system.today()){
            isValid = true;
        }      
        return isValid;
    }
    
    /*********************************************************************************************
     Purpose: This method accepts the record value, operator, data type and message record value
              validate both the values as per perator and return the boolean true/false.
    **********************************************************************************************/
    private Boolean isValidMessage(String spoilageReqFieldValue, String operator, String dataType, String value){
        try{
            if(String.isNotBlank(spoilageReqFieldValue)){      
              if(operator.equals('equals')){
                  if(dataType.equalsIgnoreCase('double')){
                    return (Double.valueOf(spoilageReqFieldValue) == Double.valueOf(value));
                  }else if(dataType.equalsIgnoreCase('date')){
                    return (Date.valueOf(spoilageReqFieldValue) == Date.valueOf(value));
                  }
                  return spoilageReqFieldValue == value;
                }else if(operator.equals('not equal to')){
                  if(dataType.equalsIgnoreCase('double')){
                    return !(Double.valueOf(spoilageReqFieldValue) == Double.valueOf(value));
                  }
                  return !(spoilageReqFieldValue == value);
                }else if(operator.equals('starts with')){
                  return spoilageReqFieldValue.startsWith(value);
                }else if(operator.equals('contains')){
                  return spoilageReqFieldValue.contains(value);
                }else if(operator.equals('does not contain')){
                  return !spoilageReqFieldValue.contains(value);
                }else if(operator.equals('less than')){
                  if(dataType.equalsIgnoreCase('number'))
                    return Integer.valueOf(spoilageReqFieldValue) < Integer.valueOf(value);
                  else if(dataType.equalsIgnoreCase('date')){
                    return Date.valueOf(spoilageReqFieldValue) < Date.valueOf(value);
                  }else if(dataType.equalsIgnoreCase('double')){
                    return Double.valueOf(spoilageReqFieldValue) < Double.valueOf(value);
                  }
                  else{
                    return spoilageReqFieldValue < value;
                  }
                }else if(operator.equals('greater than')){
                  if(dataType.equalsIgnoreCase('number'))
                    return Integer.valueOf(spoilageReqFieldValue) > Integer.valueOf(value);
                  else if(dataType.equalsIgnoreCase('date')){
                    return Date.valueOf(spoilageReqFieldValue) > Date.valueOf(value);
                  }else if(dataType.equalsIgnoreCase('double')|| dataType.equalsIgnoreCase('CURRENCY')){
                    return Double.valueOf(spoilageReqFieldValue) > Double.valueOf(value);
                  }
                  else{
                    return spoilageReqFieldValue > value;
                  }
                }else if(operator.equals('less or equal')){
                  if(dataType.equalsIgnoreCase('number'))
                    return Integer.valueOf(spoilageReqFieldValue) <= Integer.valueOf(value);
                  else if(dataType.equalsIgnoreCase('date')){
                    return Date.valueOf(spoilageReqFieldValue) <= Date.valueOf(value);
                  }else if(dataType.equalsIgnoreCase('double') || dataType.equalsIgnoreCase('CURRENCY')){
                    return Double.valueOf(spoilageReqFieldValue) <= Double.valueOf(value);
                  }
                  else{
                    return spoilageReqFieldValue <= value;
                  }
                }else if(operator.equals('greater or equal')){
                  System.debug('================ value = ' + value + ' && spoilage value = ' + spoilageReqFieldValue);
                  if(dataType.equalsIgnoreCase('number'))
                    return Integer.valueOf(spoilageReqFieldValue) >= Integer.valueOf(value);
                  else if(dataType.equalsIgnoreCase('date')){
                    return Date.valueOf(spoilageReqFieldValue) >= Date.valueOf(value);
                  }else if(dataType.equalsIgnoreCase('double') || dataType.equalsIgnoreCase('CURRENCY')){
                    return Double.valueOf(spoilageReqFieldValue) >= Double.valueOf(value);
                  }
                  else{
                    return spoilageReqFieldValue >= value;
                  }
               }
            }
        }catch(Exception e){
            System.debug(Logginglevel.ERROR, e.getMessage());
        }
        return false;
    }
}