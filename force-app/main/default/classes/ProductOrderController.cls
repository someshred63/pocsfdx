public without sharing class ProductOrderController {
    
    /*
    Create a brand new order
    */
    public Product_Order_gne__c createNewOrder(){
        Product_Order_gne__c order = new Product_Order_gne__c();
    
        //Set default value
        order.Tax__c = 0;
        order.Total__c = 0;
        order.discountAmount__c = 0;
        
        return order;
    }
         
    /*
    Initialize new line item
    */
    public Product_Order_Item_gne__c initLineItem(){
        Product_Order_Item_gne__c item = new Product_Order_Item_gne__c();
        
        //get status code
        Product_Order_Code_Lookup_gne__c code = new Product_Order_Code_Lookup_gne__c();
        code = [select Id, Name from Product_Order_Code_Lookup_gne__c where Name = 'PENDING' limit 1];
    
        //Set default value
        item.Quantity__c = null;
        item.Net_Price__c = 0;
        item.Total__c = 0;
        item.Status__c= code.Id;
        
        return item;
    }
    
    /*
    Get order by name
    */
    public Product_Order_gne__c getOrderByOrderNum(String orderNum, boolean cloneForNew){
        Product_Order_gne__c order  = null;
        if(orderNum==null){
            return null;
        }
        
        //Select Order
        List <Product_Order_gne__c> oldOrders = [select Id, Name, CreatedDate,CreatedBy.FirstName, CreatedBy.LastName, Order_Type__c, 
            Ordered_By__c, Ordered_On__c, PO_Num__c, SAP_Order_ID__c, AOC_Status__c, Order_Category__c,
            Customer_Reference__c,   Total__c, Bill_To__c, Bill_To__r.Name, Bill_To__r.Id, Bill_To__r.SAP_ID_gne__c,  
            Order_Contact_Email__c,   Tax__c  from Product_Order_gne__c where name=:orderNum];
        Product_Order_gne__c oldOrder = null;
        if(oldOrders.size()>0){
            oldOrder = oldOrders[0];
        }
        if(oldOrder==null){
            return null; 
        }
    
        //Clone it
        if(cloneForNew){
            order = oldOrder.clone(false);
            return order;   
        } else {
            return oldOrder;    
        }
    }
    
    
    /*
    Get order by order ID
    */
    public Product_Order_gne__c getOrderByOrderId(String orderId, boolean cloneForNew){
        Product_Order_gne__c order  = null;
        if(orderId==null){
            return null;
        }
        
        //Select Order
        List <Product_Order_gne__c> oldOrders = [select Id, Name, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName,  Order_Type__c, 
            Ordered_By__c, Ordered_On__c, AOC_Status__c, Order_Category__c,
            Customer_Reference__c,   Total__c,  Bill_To__c, Bill_To__r.Name, Bill_To__r.Id, Bill_To__r.SAP_ID_gne__c, 
             Order_Contact_Email__c,  Tax__c, PO_Num__c, SAP_Order_ID__c, payment_term_changed__c, payment_term_change_date__c from Product_Order_gne__c where Id =:orderId];
        Product_Order_gne__c oldOrder = null;
        if(oldOrders.size()>0){
            oldOrder = oldOrders[0];
        }         
        if(oldOrder==null){
            return null; 
        }
    
        //Clone it
        if(cloneForNew){
            order = oldOrder.clone(false);
            return order;   
        } else {
            return oldOrder;    
        }
    }
    
    /*
    Get order payments list
    */
    public List<Product_Order_Payment_gne__c> getOrderPayments(String orderId){
        List<Product_Order_Payment_gne__c> payments  = [select Id, Name,Expiration_Date__c, Card_Holder_Name__c, Card_Type__c,  Total__c,  
            Quantity__c from Product_Order_Payment_gne__c where
                Order__c =:orderId];
        return payments;
    }
    
    /*
    Get order items list
    Fwang: 8/19/09  Added retrieving Order__r.Id, Order__r.SAP_Order_ID__c, Order__r.name
    */
    public List<Product_Order_Item_gne__c> getOrderItems(String orderId){
        
        List<Product_Order_Item_gne__c> items  = [select Id, Name, CreatedDate, Expected_Delivery_Date__c, Expected_Ship_Date__c,Expected_Settlement_Date__c,
            Status__c, Status__r.Name, Status__r.Display_Text__c, Quantity__c, Shipping_Method__c, Shipping_Charge__c, Tracking_URL__c,Tracking_Number__c,
            Product__r.Name, Product__r.description_vod__c, Product__r.List_Price_gne__c, Unit_Price__c, Net_Price__c, Total__c, Tax__c,
            SAP_Line_Number_gne__c, Shipped_Quantity__c, 
            Order__r.id, Order__r.SAP_Order_ID__c, Order__r.name, Order__r.AOC_Status__c              
            from Product_Order_Item_gne__c where Order__c =:orderId];
        
        return items;
    }
    
    
    /*
    Get order number by ID
    */
    public String getOrderNumber(String orderId){
        if(orderId==null){
            return null;
        }
        
        //Get order number
        List <Product_Order_gne__c> orders = [select Name,SAP_Order_ID__c  from Product_Order_gne__c where id =:orderId];
        Product_Order_gne__c order = null;
        if(orders.size()>0){
            order = orders[0];
        }
        if(order!=null){
            return order.SAP_Order_ID__c;
        }
        else {
            return '';
        }
     }
          
    /*********************************************************
     *
     *  Sample Order Functions
     *  
    /*********************************************************/
    /*
     * OrderType: 1, get 'In Process' sample order
     * OrderType: 2, get earliest 'Pending Confirmation' order
     * OrderType: 3, get most recent non 'Pending Confirmation/Expired' order         
    */
    public Product_Order_Item_gne__c getSampleOrder(String accountId, Integer orderType){

        System.debug('calling getSampleOrder##################');
        
        String name = 'PENDING';
        
        if( orderType == 2 || orderType == 3)
            name = 'PENDINGCONF';        
                          
        //get status code
        Product_Order_Code_Lookup_gne__c code = new Product_Order_Code_Lookup_gne__c();        
        code = [select Id, Name from Product_Order_Code_Lookup_gne__c where Name = :name limit 1];
        
        List <Product_Order_Item_gne__c> items = null;
        
        if( orderType == 1 || orderType == 2) {
                 
             System.debug('search for In Process or Pending Conf orders....................');       
            // Sample should have only one 'In Process' order
            items = [ Select p.name, p.Order__r.id,  p.Order__r.SAP_Order_ID__c, p.Order__r.name,
                            p.Expected_Ship_Date__c, p.Expected_Delivery_Date__c, p.Status__c,
                            p.Product__c, p.Product__r.Name, Product__r.description_vod__c,p.Product__r.List_Price_gne__c,
                            p.Product__r.NDC_Number_gne__c, p.Quantity__c, p.Order__r.AOC_Status__c, p.Status__r.Display_Text__c                                                    
                            from Product_Order_Item_gne__c p                                           
                            WHERE p.Order__r.Bill_To__c = :accountId        // '001Q0000003J2udIAC'
                            and p.Status__c=  :code.Id                      // 'a1YQ00000008OIkMAM'
                            and p.Expected_Ship_Date__c != null
                            and p.Order__r.Order_Category__c = 'Sample'
                            and p.isDeleted = false  
                            order by p.Order__r.SAP_Order_ID__c asc];
                         //order by p.Order__r.SAP_Order_ID__c desc];
                            
                            
            System.debug('1,2 type, items.size========================'+items.size());                            
        }
        else  {
            
            Product_Order_Code_Lookup_gne__c expiredCode = new Product_Order_Code_Lookup_gne__c();        
            expiredCode = [select Id, Name from Product_Order_Code_Lookup_gne__c where Name = 'EXPIRED' limit 1];
            
            System.debug('search for last order which is not Pending Conf, not expired order....................');
            items = [ Select p.name, p.Order__r.id, p.Order__r.SAP_Order_ID__c, p.Order__r.name,
                            p.Expected_Ship_Date__c, p.Expected_Delivery_Date__c, p.Status__c,
                            p.Product__c, p.Product__r.Name, Product__r.description_vod__c, p.Product__r.List_Price_gne__c, 
                            p.Product__r.NDC_Number_gne__c, p.Quantity__c, p.Order__r.AOC_Status__c, Status__r.Display_Text__c
                            from Product_Order_Item_gne__c p                                           
                            WHERE p.Order__r.Bill_To__c = :accountId        
                            and p.Status__c !=  :code.Id                     
                            and p.Status__c !=  :expiredCode.Id
                            and p.Expected_Ship_Date__c != null
                            and p.Order__r.Order_Category__c = 'Sample'
                            and p.isDeleted = false  
                            order by p.Order__r.SAP_Order_ID__c desc];
                          
               System.debug('items for aoc'+items);
               //System.debug('first item=--->'+ items[0] );             
            System.debug('3 type, items.size========================'+items.size());
            if(items != null && items.size() > 0) {
            	System.debug('first item=--->'+ items[0] );
            }                               
        }
         
        Product_Order_Item_gne__c orderItem = null;
        
        if(items.size()>0)          
            orderItem = items[0];
            
        return orderItem;
    }
 
     public Product_Order_Item_gne__c getSampleOrderByOrderExpireDate(String accountId, Integer orderType, Date orderExpireDate){

        System.debug('calling getSampleOrderByOrderExpireDate##################');
        
        String name = 'PENDING';
        
        if( orderType == 2 || orderType == 3)
            name = 'PENDINGCONF';
        
        System.debug('name========='+name);    
        //get status code
        Product_Order_Code_Lookup_gne__c code = new Product_Order_Code_Lookup_gne__c();        
        code = [select Id, Name from Product_Order_Code_Lookup_gne__c where Name = :name limit 1];
        
        List <Product_Order_Item_gne__c> items = null;
        
        if( orderType == 1 || orderType == 2) {
                        
            // Sample should have only one 'In Process' order
            items = [ Select p.name, p.Order__r.id,  p.Order__r.SAP_Order_ID__c, p.Order__r.name,
                            p.Expected_Ship_Date__c, p.Expected_Delivery_Date__c, p.Status__c,
                            p.Product__c, p.Product__r.Name, Product__r.description_vod__c,p.Product__r.List_Price_gne__c,
                            p.Product__r.NDC_Number_gne__c, p.Quantity__c, p.Order__r.AOC_Status__c, p.Status__r.Display_Text__c                                                    
                            from Product_Order_Item_gne__c p                                           
                            WHERE p.Order__r.Bill_To__c = :accountId        
                            and p.Status__c=  :code.Id                      
                            and p.Expected_Ship_Date__c != null
                            and p.Order__r.Order_Category__c = 'Sample'
                            and p.isDeleted = false
                            and p.Expected_Ship_Date__c <= :orderExpireDate 
                            order by p.Expected_Ship_Date__c asc];
        }
        else {
            
            Product_Order_Code_Lookup_gne__c expiredCode = new Product_Order_Code_Lookup_gne__c();        
            expiredCode = [select Id, Name from Product_Order_Code_Lookup_gne__c where Name = 'EXPIRED' limit 1];
            
            items = [ Select p.name, p.Order__r.id, p.Order__r.SAP_Order_ID__c, p.Order__r.name,
                            p.Expected_Ship_Date__c, p.Expected_Delivery_Date__c, p.Status__c,
                            p.Product__c, p.Product__r.Name, Product__r.description_vod__c, p.Product__r.List_Price_gne__c,
                            p.Product__r.NDC_Number_gne__c, p.Quantity__c, p.Order__r.AOC_Status__c, Status__r.Display_Text__c
                            from Product_Order_Item_gne__c p                                           
                            WHERE p.Order__r.Bill_To__c = :accountId       
                            and p.Status__c !=  :code.Id                     
                            and p.Status__c !=  :expiredCode.Id
                            and p.Expected_Ship_Date__c != null
                            and p.Order__r.Order_Category__c = 'Sample'
                            and p.isDeleted = false
                            and p.Expected_Ship_Date__c <= :orderExpireDate
                            order by p.Expected_Ship_Date__c desc];         
        }
         

        Product_Order_Item_gne__c orderItem = null;

        if(items.size()>0)          
            orderItem = items[0];
            
        return orderItem;
    }                 
}