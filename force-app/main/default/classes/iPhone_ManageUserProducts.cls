@RestResource(urlMapping='/iPhoneManageUserProducts/*')
global with sharing class iPhone_ManageUserProducts implements iPhone_Commons_gne.Runnable {

	@HttpPost
	global static iPhone_Commons_gne.RestResponse updateUserProductsAssignments(UserProductsManagementParams params) {
        return iPhone_Commons_gne.executeAlterData(
            new iPhone_ManageUserProducts(),
            params
        );
	}

    public Object run(Object arg) {
        UserProductsManagementParams params = (UserProductsManagementParams)arg;

        try {
            User processedUser = String.isNotBlank(params.unixId) ? iPhone_DAO.getUserByExternalId(params.unixId) : null;

            List<My_Setup_Products_vod__c> mySetupProductsToInsert = new List<My_Setup_Products_vod__c>();
            for (String productIdToAdd : params.productsIdsToAdd) {
                mySetupProductsToInsert.add(new My_Setup_Products_vod__c(Product_vod__c = productIdToAdd, OwnerId = processedUser.Id));
            }
            insert mySetupProductsToInsert;

            if (params.productsIdsToRemove.size() > 0) {
                List<My_Setup_Products_vod__c> productsToDelete = [SELECT product_vod__c, OwnerId FROM My_Setup_Products_vod__c WHERE product_vod__c IN :params.productsIdsToRemove AND OwnerId = :processedUser.Id];
                delete productsToDelete;
            }
            return new iPhone_Commons_gne.AlterDataResponse();
        } catch (Exception ex) {
            return new iPhone_Commons_gne.AlterDataResponse(ex);
        }
    }

    global class UserProductsManagementParams implements iPhone_Commons_gne.BaseArgs {
        public String unixId;
        public List<String> productsIdsToAdd;
        public List<String> productsIdsToRemove;
        public String iPhoneRequestId;

        public String getIPhoneRequestId() {
            return iPhoneRequestId;
        }

    }
}