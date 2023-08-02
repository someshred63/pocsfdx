@RestResource(urlMapping='/iPhoneGetProductInfo/*')
global with sharing class iPhone_GetProductInfo {

	@HttpPost
	global static iPhone_Commons_gne.RestResponse processRequest(List<String> productIds) {
		return iPhone_Commons_gne.buildResponse(
					new GetConfigurationResponseBuilder(productIds),  
					null
			   ); 
	}

	//without sharing to be able to return inactive products beloging to deactivated queues
	private without sharing class GetConfigurationResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
		
		private List<String> productIds;

		public GetConfigurationResponseBuilder(List<String> productIds) {
			this.productIds = productIds;
		}

		public iPhone_Commons_gne.RestResponse build(Object arg) {
			List<ProductInfo> products = getInfos(productIds);
			return new ProductInfoResponse(products);
		}

		private List<ProductInfo> getInfos(List<String> productIds) {
			List<ProductInfo> result = new List<ProductInfo>();

			if (productIds != null && !productIds.isEmpty()) {
				for (Product_vod__c product : [SELECT Id, Name, Active__c, Product_Type_vod__c FROM Product_vod__c WHERE Id IN :productIds]) {
					result.add(new ProductInfo(product));
				}
			}

			return result;
		}
	}

	@testVisible
	private class ProductInfoResponse extends iPhone_Commons_gne.RestResponse {
		@testVisible
		private List<ProductInfo> products;
		
		public ProductInfoResponse(List<ProductInfo> products) {
			this.products = products;
		}
	}

	private class ProductInfo extends iPhone_Commons_gne.RestRecord {
		private String id;
		private String name;
		private Boolean isActive;
		private String productType;

		public ProductInfo(Product_vod__c product) {
			this.id = product.Id;
			this.name = product.Name;
			this.isActive = product.Active__c;
			this.productType = product.Product_Type_vod__c;
		}
	}
}