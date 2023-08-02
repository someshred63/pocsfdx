/*
* 4/6/11 FL: Moved getSystemMessage() to GNE_LWO_Controller
*/
public without sharing class ProductDataController {
    private String message = null; 
    
    
    private Pattern hasDecimal1 = Pattern.compile('[\\d,]+\\.\\d');
    private Pattern hasDecimal2 = Pattern.compile('[\\d,]+\\.\\d{2}');
    
    public String getMessage(){
        return message;
    }
    
    
    public void testDataConversion(){
        
        Product_Order_gne__c order = new Product_Order_gne__c();
        order.Total__c = Double.valueOf('2.00');
        //order.Ordered_On__c = Date.valueOf('2007-02-15');
        //order.Total__c = new ProductOrderSimulateOrderNew.SimulateOrderResponseItem().tax;
        //order.Ordered_On__c = new ProductOrderSimulateOrderNew.SimulateOrderResponseItem().orderExpectedSettlementDate;
        
    }
    
    /*
    Populate Product order address obj
    */
    public Product_Order_Address_gne__c populateAddress(Map<String,String> address, boolean billing) {
        Product_Order_Address_gne__c addr = new Product_Order_Address_gne__c();
        
        addr.SAP_Address_ID__c = address.get('id');
        addr.Name = address.get('name');
        addr.Address_Line_4__c = address.get('name2');
        addr.Address_Line_2__c = address.get('line2');
        addr.City__c = address.get('city');
        addr.State__c = address.get('state');
        addr.Zip__c = address.get('zip');
        
        //if(address.Zip_4_vod__c!=null){
        //    addr.Zip_4__c = address.Zip_4_vod__c;
        //}
        
        addr.Country__c = address.get('country');
        if (billing) {
            addr.Billing__c = true;
        }
        return addr;
    }


    public Product_Order_Address_gne__c populateDisplayAddress(Map<String,String> address, boolean billing) {
        Product_Order_Address_gne__c addr = new Product_Order_Address_gne__c();
        
        addr.SAP_Address_ID__c = address.get('id');
        addr.Name = address.get('name');
        addr.Address_Line_4__c = address.get('name2');
        
        /*
        addr.Address_Line_2__c = address.get('line2');
        addr.City__c = address.get('city');
        addr.State__c = address.get('state');
        addr.Zip__c = address.get('zip');
        
        //if(address.Zip_4_vod__c!=null){
        //    addr.Zip_4__c = address.Zip_4_vod__c;
        //}
        
        addr.Country__c = address.get('country');
        if (billing) {
            addr.Billing__c = true;
        }
        */
        return addr;
    }
    
    /*
    Construct Address for display; address for new order ; Map 
    */
    public  String constructAddressForDisplayMap(Map<String,String> address){
        
        String value = '';

        value += address.get('name') + '<br/> ';
        if (address.get('line2') != '') {
            value += address.get('line2') + '<br/>  ';
        }
        value +=   address.get('city') + ', ' +
        address.get('state')+' '+
        address.get('zip');
        
        /*
        if (address.get('name2') != '') {
            value += address.get('name2') + '<br/>  ';
        }
                
        value += address.get('name') + '<br/> ';
        if (address.get('line2') != '') {
            value += address.get('line2') + '<br/>  ';
        }
        value +=   address.get('city') + '<br/> ' +
            address.get('state')+', '+
            address.get('zip');
                    
        value += '<br/>' + address.get('country');
        */
        
        
        return value;
    }
    
    /*
    Construct Address for display
    */
    public  String constructAddressForDisplay(SObject obj){
        if(obj==null){
            return '';
        }
        String value = '';
        
        if(obj instanceof Product_Order_Address_gne__c){
            Product_Order_Address_gne__c address = (Product_Order_Address_gne__c) obj;
            
            if (address.Address_Line_4__c != null) {
                value = address.Address_Line_4__c + '<br/> ';
            }
            value += address.Name + '<br/> ';
            if (address.Address_Line_2__c != null) {
                value += address.Address_Line_2__c + '<br/> ';
            }
            value += address.City__c + '<br/> ' +
            address.State__c+', '+
            address.Zip__c;
            if(address.Zip_4__c!=null){
                value += '-'+address.Zip_4__c;
            }
            //value += '<br/>' + address.Country__c;
        }
        return value;
    }
    
    /*
    Constructe address for select
    */
    
    public String constructAddressForSelect(Map<String,String> address){
        
        if(address==null){
            return '';
        }
        
        String value = '';
        value += address.get('name');
        if (address.get('line2') != '') {
            value += ', ' + address.get('line2');
        }
        
        /*
        if (address.get('name2') != '') {
            value += address.get('name2') + ', ';
        }
        value += address.get('name') + ', ';
        if (address.get('line2') != '') {
            value += address.get('line2') + ', ';
        }
        value += address.get('city') +', ' +
        address.get('state') +' '+
        address.get('zip');
        value += ', ' + address.get('country');
        */
        
        
        return value;
    }
    

    /*
    Constructe address for select
    */
    
    public String constructDisplayAddressForSelect(Map<String,String> address){
        if(address==null){
            return '';
        }
        String value;
        if (address.get('name')!=null && address.get('name').trim()!= '') {
            value = address.get('name');
        }else value='';
        if (address.get('city')!=null && address.get('city').trim()!= '') {
            value += ', '+address.get('city') ;
        }
        if (address.get('state')!=null && address.get('state').trim()!= '') {
            value += ', '+address.get('state');
        }
        /*if (address.get('zip')!=null && address.get('zip').trim()!= '') {
            value += ', '+address.get('zip');
        }
        if (address.get('country')!=null && address.get('country').trim()!= '') {
            value += ', '+address.get('country');
        }*/
        
        
        return value;
    }
    
    /*
    Get a list of account IDs that a user can see
    */
    public  Set<ID> getAccountIDs(){
        String userId = GNE_LWO_Controller.userID;
        //String contactId = null; 
        String accountId = null; 
        
        List <Account> accs = null;
        Set<ID> accountIds = new Set<ID>();
        List <Affiliation_vod__c> accList = null;
        
        if (GNE_LWO_Controller.getAdminUser()) {
            //User is sys admin, retreive all accounts available for web ordering
            List <Account> accounts = [select Name, Id from Account where Web_Order_Enabled_gne__c =true and SAP_Id_gne__c <> '' order by Name asc limit 999];
            if (accounts != null && accounts.size() > 0) {
                for (Account account : accounts){
                    accountIds.add(account.Id);
                }
            }
        }   
        else {
            //Regular end user logic            
            //Get person account ID - with IHCP implementation LWO Users always have reference to Person Account (not contact)
            List<User> user = [select id, accountId, contactId from User where id = :userId];
            if(user != null && user.size() > 0 && user[0].accountId != null)
            {               
                accList = [select from_account_vod__c  from Affiliation_vod__c
                            where to_account_vod__c =: user[0].accountId and Web_Order_Enabled_gne__c = true and From_Account_vod__r.Web_Order_Enabled_gne__c=true];
                //Populate a set of account IDs to get rid of potential duplicates
                if (accList != null && accList.size() > 0) {
                    for (Affiliation_vod__c affiliation : accList){
                        accountIds.add(affiliation.from_account_vod__c);
                    }
                }
                message = userId + ',  '+user[0].contactId + ', '+ user[0].accountId;
            }
            /*
                //Get contact ID
                User user = [select id, contactId  from User where id= :userId];
                contactId = user.contactId;
                
                System.debug('contactId ==================='+contactId );
                //Get account id 
                Contact userContact = new Contact();
                System.debug('**problem here**');
                
               userContact = [select id, accountId, IsPersonAccount from contact where id = :contactId order by Id limit 1];
                   System.debug('****testing timeout **');
                  
                 if (userContact != null) {
                    accountId = userContact.accountId;
                }
             
                if(userContact != null && userContact.IsPersonAccount){
                    //User is Person Account
                    accList = [select from_account_vod__c  from Affiliation_vod__c
                    where to_account_vod__c = :accountId and Web_Order_Enabled_gne__c =true and From_Account_vod__r.Web_Order_Enabled_gne__c=true];
                }
                else {
                    //User is not Person Account
                    accList = [select from_account_vod__c from Affiliation_vod__c
                    where to_contact_vod__c = :contactId and Web_Order_Enabled_gne__c =true and From_Account_vod__r.Web_Order_Enabled_gne__c=true];
                }
                
                //Populate a set of account IDs to get rid of potential duplicates
                if (accList != null && accList.size() > 0) {
                    for (Affiliation_vod__c affiliation : accList){
                        accountIds.add(affiliation.from_account_vod__c);
                    }
                }
            */
        }
        return accountIds;
    }  
    
    /*
    Get a list of account IDs that a user can see
    */
    public Set<ID> getAccountIDsByUserId(String userId){
        String contactId = null; 
        String accountId = null; 
        
        List <Account> accs = null;
        Set<ID> accountIds = new Set<ID>();
        List <Affiliation_vod__c> accList = null;
        
        //Regular end user logic
        
        //Get contact ID
        User user = [select id, contactId from User where id= :userId];
        contactId = user.contactId;
        
        System.debug('contactId ==================='+contactId );
        //Get account id 
        Contact userContact = new Contact();
        userContact = [select id, accountId, IsPersonAccount from contact where id = :contactId limit 1];
        if (userContact != null) {
            accountId = userContact.accountId;
        }
        
        if(userContact != null && userContact.IsPersonAccount){
            //User is Person Account
            accList = [select from_account_vod__c  from Affiliation_vod__c
            where to_account_vod__c /*from_account_vod__c*/ = :accountId and Web_Order_Enabled_gne__c =true and From_Account_vod__r.Web_Order_Enabled_gne__c=true];
        }
        else {
            //User is not Person Account
            accList = [select from_account_vod__c from Affiliation_vod__c
            where to_contact_vod__c = :contactId and Web_Order_Enabled_gne__c =true and From_Account_vod__r.Web_Order_Enabled_gne__c=true];
        }
        
        //Populate a set of account IDs to get rid of potential duplicates
        if (accList != null && accList.size() > 0) {
            for (Affiliation_vod__c affiliation : accList){
                accountIds.add(affiliation.from_account_vod__c);
            }
        }
        
        
        
        
        message = userId + ',  '+contactId + ', '+ accountId;
        
        return accountIds;
    }  
    
    
    /*
    * Get a list of accounts which name greater than startAccName
    * returned account list contain no more than 999 accounts
    */ 
    
    public List<Account> getLT999Accounts(String startAccId){
        List<Account> accs=new List<Account>();
        if(startAccId==null || startAccId.trim().length()==0)
        accs = [select Name, Id, SAP_ID_gne__c from Account where Web_Order_Enabled_gne__c =true and SAP_Id_gne__c <> '' order by SAP_ID_gne__c asc limit 999];
        else 
        accs = [select Name, Id, SAP_ID_gne__c from Account where Web_Order_Enabled_gne__c =true and SAP_Id_gne__c <> '' and SAP_ID_gne__c>:startAccId order by SAP_ID_gne__c asc limit 999];
        return accs;
    }
    
     /*
    * Get a list of accounts which name greater than startAccName and startSAPId
    * returned account list contain no more than 999 accounts
    */ 
    
    public List<Account> getLT999Accounts(String startAccName, String startSAPId){
        List<Account> accs=new List<Account>();
        if(startAccName==null || startAccName.trim().length()==0)
        accs = [select Name, Id, SAP_ID_gne__c from Account where Web_Order_Enabled_gne__c =true and SAP_Id_gne__c <> '' order by Name, SAP_ID_gne__c limit 999];
        else 
        accs = [select Name, Id, SAP_ID_gne__c from Account where Web_Order_Enabled_gne__c =true and SAP_Id_gne__c <> '' and Name>=:startAccName and SAP_ID_gne__c>:startSAPId order by Name, SAP_ID_gne__c limit 999];
        return accs;
    }
    
    /*
    * Get a list of accounts Admin can see
    */
    public List<List<Account>> getAccountsForAdmin(){
        List <List<Account>> allAccounts=new List<List<Account>>();
        if(!GNE_LWO_Controller.getAdminUser()) return allAccounts;
        String startAccName='';
        String startSAPId='';
        boolean haveNextList=false;
        do{
            List<Account> temp=this.getLT999Accounts(startSAPId);
            if(temp!= null && temp.size()>0)
            allAccounts.add(temp);
            
            if(temp!=null && temp.size()==999) {
                haveNextList=true;
                Account lastAcnt = temp.get(998);
                //startAccName=lastAcnt.Name;
                startSAPId=lastAcnt.SAP_ID_gne__c;
            }
            else{
                haveNextList=false;
                break;
            }
        }while(haveNextList);
        
        return allAccounts;
    }
    
    /*
    Get a list of accounts that a user can see
    */
    public  List<Account> getAccounts(){
        List <Account> accs = null;
        Set<ID> accountIds = getAccountIDs();
        
        //accs = [select Id, Name, SAP_ID_gne__c  from Account where id in :accountIds];
        if (accountIds != null && accountIds.size() > 0) {
            accs = [select Id, Name, SAP_ID_gne__c  from Account where id in :accountIds order by Name];
        }
        
        if(accs != null) {
            System.debug('account size'+ accs.size()+'***'+accs);
        }
        return accs;
    }
    
    
    /*
    Get a list of accounts that a user can see
    */
    public  List<Account> getAccountsByUserId(String userId){
        List <Account> accs = null;
        Set<ID> accountIds = getAccountIDsByUserId(userId);
        
        //accs = [select Id, Name, SAP_ID_gne__c  from Account where id in :accountIds];
        if (accountIds != null && accountIds.size() > 0) {
            accs = [select Id, Name, SAP_ID_gne__c  from Account where id in :accountIds order by Name];
        }
        
        System.debug('account size'+ accs.size()+'***'+accs);
        return accs;
    }


    // get account by sap Id - December 09 2010
    public  List<Account> getAccountBySAPId(String sapId){
        return  [select Id, Name, SAP_ID_gne__c  from Account where Web_Order_Enabled_gne__c =true and SAP_Id_gne__c = :sapId];            
    }

    
    /*
    Get Account info for a Bill_To
    */
    public Account getAccountInfoForID(String accountId) {
        Account acc = [select Id, Name, SAP_ID_gne__c  from Account where id = :accountId limit 1];
        if (acc == null) {
            acc = new Account();
        }
        return acc;
    }
    
    /*
    Get Item info for a Bill_To
    */
    public Product_Order_Item_gne__c getItemInfoForID(String orderId) {
        Product_Order_Item_gne__c item = [select Id, Name,  Order__r.Name, Order__r.SAP_Order_ID__c, Status__c, Status__r.Display_Text__c  from Product_Order_Item_gne__c where Order__r.Name = :orderId limit 1];
        return item;
    }
    
    /*
    Get list of Order Status
    */
    public  List<Product_Order_Code_Lookup_gne__c> getOrderStatus() {
        List<Product_Order_Code_Lookup_gne__c> statusList = null;
        statusList = [select Id, Name, Display_Text__c from Product_Order_Code_Lookup_gne__c 
        where Code_List__c = 'Order status' order by Display_Text__c];
        return statusList;
    }

    /*
    Get a list of products that can be sold via web ordering
    */
    public List<Product_vod__c> getProducts(){
        List<Product_vod__c> products = new List<Product_vod__c>();
        products = [select Id, Name, NDC_Number_gne__c, Description_vod__c, List_Price_gne__c from Product_vod__c where Web_Order_Enabled_gne__c=true order by Name asc];
        return products;
    }
    
    /*
    Get system message, if any. These messages are display at the bottom of the LWO welcome page.
    */
    /*
    public List<System_Message_gne__c> getSystemMessages() {
        
        List<System_Message_gne__c> message;
        
        Date today = Date.today();
        message = [select Id, System_Downtime_Required_gne__c, Message_gne__c
                    from System_Message_gne__c
                    where Target_Application_gne__c = 'LWO' 
                    and (Valid_From_gne__c <= :today and Valid_To_gne__c >= :today)
                order by Display_Sequence_Number__c];
        
        return message;
    }
    */
    /**********************************************************
    *
    *   Sampel Order functions
    *
    *********************************************************/  

    /*
    Construct Address for display; address for a sample order 
    */
    public  String constructSampleAddressForDisplayMap(Map<String,String> address){
        
        String value = '';
        value += address.get('name') + '<br/> ';
        if (address.get('line2') != '') {
            value += address.get('line2') + '<br/>  ';
        }
        value +=   address.get('city') + ', ' +
        address.get('state')+', '+
        address.get('zip');
        value += ' ' + address.get('country');
        return value;
    }
    
    
    public String convertToCurrency(String amount) {
        
        System.debug('calling convertToCurrenty, amount============'+amount);
        String newAmount;
        
        // matcher 1: e.g. 2355.5 
        // matcher 2: e.g. 2355.55
        Matcher dotMatcher1 = hasDecimal1.matcher(amount);
        Matcher dotMatcher2 = hasDecimal2.matcher(amount);
        dotMatcher1.lookingAt();
        dotMatcher2.lookingAt();
        
        if (dotMatcher1.lookingAt()) {
            Integer decimalPos = amount.indexOf('.'); 
            Integer strLen = amount.length();
            
            if(decimalPos >= 0 && strLen - decimalPos - 1 == 1)                     
            newAmount = amount + '0';
            else
            newAmount = amount;
            
        } else if (dotMatcher2.lookingAt()) {           
            newAmount = amount;
        } else {            
            newAmount = amount + '.00';
        }
        
        //String debugMessage = 'old/new: ' + amount + '/' + newAmount + '<br/>';
        return newAmount;
    }
}