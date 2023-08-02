global with sharing class iPhone_Key_Messages_Webservice_gne {
    
    global class KeyMessage {
        WebService String Id;
        WebService String OwnerId;
        WebService String Name;
        WebService String Description;
        WebService Boolean isActive;
        WebService String ProductName;
        WebService String Product;
    }
    
    global class ResponseItem {
        WebService String productId;
        WebService List<KeyMessage> keyMessages;
    }
    
    global class FullResponse {
        WebService List<ResponseItem> response;
    }
    
    static List<Key_Message_vod__c> keyMessages(String userId) {        
        return [
            Select
            	Id,
            	OwnerId,
            	Name,
            	Description_vod__c,
            	Active_vod__c,
            	Product_vod__c,
            	Product_vod__r.Name
            From
            	Key_Message_vod__c
            Where
            	Product_vod__c IN (Select Product_vod__c from My_Setup_Products_vod__c Where OwnerId =: userId)
            // AND
            // Active_vod__c = true
        ];
    }
    
    WebService static FullResponse returnKeyMessages(String userId) {
        FullResponse fullResp = new FullResponse(); 
        fullResp.response = new List<ResponseItem>();
        Map<Id, List<Key_Message_vod__c>> productMessagesMap = new Map<Id, List<Key_Message_vod__c>>();
        
        for(Key_Message_vod__c keyMessage : keyMessages(userId)) {
        	if(!productMessagesMap.containsKey(keyMessage.Product_vod__c)) {
        		productMessagesMap.put(keyMessage.Product_vod__c, new List<Key_Message_vod__c>());
            }
            productMessagesMap.get(keyMessage.Product_vod__c).add(keyMessage);
        }
        
        for(Id key : productMessagesMap.keySet()) {
            ResponseItem respItem = new ResponseItem();
            respItem.keyMessages = new List<KeyMessage>();
            respItem.productId = key;
            for(Key_Message_vod__c msg : productMessagesMap.get(key)) {
                KeyMessage keyMsg = new KeyMessage();
                keyMsg.Id = msg.Id;
                keyMsg.OwnerId = msg.OwnerId;
               	keyMsg.Name = msg.Name;
                keyMsg.Description = msg.Description_vod__c;
                keyMsg.isActive = msg.Active_vod__c;
                keyMsg.ProductName = msg.Product_vod__r.Name;
                keyMsg.Product = msg.Product_vod__c;
                respItem.keyMessages.add(keyMsg);
            }
            fullResp.response.add(respItem);    
        }
        return fullResp;
    }
}