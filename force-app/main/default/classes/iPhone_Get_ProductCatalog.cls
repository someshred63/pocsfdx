@RestResource(urlMapping='/iPhoneGetProductCatalog/*')
global with sharing class iPhone_Get_ProductCatalog  implements iPhone_Commons_gne.ResponseBuilder {
    private enum ProductFlag {ms, mc, rr, ta, ml, aa, sl}
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, Boolean enhDelta, String otrVersion) {
        return iPhone_Commons_gne.buildResponse(
                new iPhone_Get_ProductCatalog(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, null, enhDelta, otrVersion)
        );                              
    }
    
    public iPhone_Commons_gne.RestResponse build(Object args){
        String unixId = ((iPhone_Commons_gne.DefaultDeltaArgs)args).unixId;
        User user = iPhone_DAO.getUserByExternalId(unixId);
        Boolean isCanada = GNE_SFA2_Util.isCanadaUser(user.Profile_Name_gne__c);
        List<ProductWrapper> products = new List<ProductWrapper>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> mySetupProdIds = new Set<Id>();
        Set<String> visitedSamples = new Set<String>();
        Map<String,GNE_SFA2_ReferralUtil.ReferralProduct> referralProductsMap = new Map<String,GNE_SFA2_ReferralUtil.ReferralProduct>();
        List<GNE_SFA2_ReferralUtil.ReferralProduct> referralProducts = GNE_SFA2_ReferralUtil.getProducts();
        
        for(GNE_SFA2_ReferralUtil.ReferralProduct rProd : referralProducts) {
            referralProductsMap.put(rProd.getId(), rProd);
        }
        
        Map<String,ProductWrapper> productsByNameMap = new Map<String,ProductWrapper>();
        
        for(Product_vod__c prod: getDetailProducts(user.Id)) {
            productIds.add(prod.Id);
            ProductWrapper product = getProductWrapper(prod, !prod.My_Setup_Products_vod__r.isEmpty(), false, true, referralProductsMap.get(prod.Id), referralProductsMap);
            String prodName = String.isNotBlank(product.pn) ? product.pn.toUpperCase() : null;
            
            if(productsByNameMap.containsKey(prodName)) {
                productsByNameMap.put(prodName, productsByNameMap.get(prodName).mergeProduct(product));
            } else {
                productsByNameMap.put(prodName, product);
            }
            
            if(product.getFlags().contains(ProductFlag.ms.name())) {
                mySetupProdIds.add(prod.Id);
            }
        }
        
        List<String> prodNames = new List<String>(productsByNameMap.keySet());
        prodNames.sort();
        
        for(String prodName : prodNames) {
            products.add(productsByNameMap.get(prodName));
        }
        
        productsByNameMap = null;
        
        for(Product_vod__c prod: getProductSamples(mySetupProdIds)) {
            String sampleKey = ((isCanada && String.isNotBlank(prod.Parent_Product_vod__c) ? String.valueOf(prod.Parent_Product_vod__c) : '') + prod.Product_Type_vod__c + '_' + prod.Name).toUpperCase();
            
            if(!visitedSamples.contains(sampleKey)) { 
	            ProductWrapper product = getProductWrapper(prod, false, true, true, referralProductsMap.get(prod.Id), referralProductsMap);
	            products.add(product);
	            productIds.add(prod.Id);
	            visitedSamples.add(sampleKey);
            }
        }

        for(GNE_SFA2_ReferralUtil.ReferralProduct rProd : referralProducts) {
            if(!(rProd.getId() instanceof Id) || !productIds.contains((Id)rProd.getId())) {
                ProductWrapper product = getProductWrapper(null, false, false, false, rProd, referralProductsMap);
                
                if(!product.getFlags().isEmpty()) {
                    products.add(product);
                }
            }
        }
        
        return new DeltaRecordsResponse(products);
    }
    
    private ProductWrapper getProductWrapper(Product_vod__c prod, Boolean isMySetup, Boolean isSample, Boolean isVisible, GNE_SFA2_ReferralUtil.ReferralProduct rProd, Map<String,GNE_SFA2_ReferralUtil.ReferralProduct> referralProductsMap) {
        rProd = rProd!=null ? rProd : referralProductsMap.get(prod.Id);
        return rProd!=null ? 
                (rProd.isBrand() && referralProductsMap.containsKey(rProd.getTA()) && referralProductsMap.get(rProd.getTA()).isTA()
                    ? (ProductWrapper)new ReferralBrandProductWrapper(prod, rProd, isMySetup, isVisible)
                    : (ProductWrapper)new ReferralProductWrapper(prod, rProd, isMySetup, isVisible))
            : isSample
                ? (ProductWrapper)new SampleWrapper(prod)
                : new ProductWrapper(prod, isMySetup, isVisible);
    }
    
    private List<Product_vod__c> getDetailProducts(Id userId) {
        return [
            SELECT Id, Name, Active__c, Parent_Product_vod__c, Product_Type_vod__c, Detail_Product_Subtype_Code_gne__c, TheraDisease_Reference_gne__c,
                (SELECT Id FROM My_Setup_Products_vod__r WHERE OwnerId =:userId LIMIT 1)
            FROM Product_vod__c
            WHERE Product_Type_vod__c = :GNE_SFA2_ReferralUtil.PRODUCT_DETAIL_TYPE
            ORDER BY Name
        ];
    }
    
    private List<Product_vod__c> getProductSamples(Set<Id> mySetupProductIds){
        Set<String> invalidProductTypes = new Set<String>{'Detail', 'Market', 'Sample', 'PFG'};
        return [
            SELECT Id, Name, Active__c, Parent_Product_vod__c, Product_Type_vod__c, Detail_Product_Subtype_Code_gne__c, TheraDisease_Reference_gne__c
            FROM Product_vod__c
            WHERE Active__c = true
                AND Parent_Product_vod__c IN :mySetupProductIds
                AND Product_Type_vod__c NOT IN :invalidProductTypes
            ORDER BY Product_Type_vod__c, Name
        ];
    }
    
    private virtual class ProductWrapper extends iPhone_Commons_gne.RestRecord {
        public String pn; //product name
        public Set<String> flags;
        
        private ProductWrapper(Product_vod__c prod, Boolean isMySetup, Boolean isVisible) {
            this(prod.Id, prod.Name, prod.Product_Type_vod__c, isMySetup, isVisible);
            
            
        }
        
        private ProductWrapper(String id, String name, String pType, Boolean isMySetup, Boolean isVisible) {
            this.id = id;
            this.pn = name;
            
            if(isMySetup) {
                addFlag(ProductFlag.ms);
            }
            
            if(isVisible && pType==GNE_SFA2_ReferralUtil.PRODUCT_DETAIL_TYPE) {
                addFlag(ProductFlag.mc);
            }
        }
        
        private void addFlag(ProductFlag flag) {
            addFlag(flag.name());
        }
        
        private void addFlag(String flag) {
            if(this.flags==null) {
                this.flags = new Set<String>();
            }
            
            this.flags.add(flag);
        }
        
        private Set<String> getFlags() {
            return this.flags!=null ? this.flags : new Set<String>();
        }
        
        private ProductWrapper mergeProduct(ProductWrapper other) {
            ProductWrapper baseProduct = this;
            ProductWrapper otherProduct = other;
            
            if(!(this instanceof ReferralProductWrapper) && other instanceof ReferralProductWrapper) {
                baseProduct = other;
                otherProduct = this;
            }
            
            for(String flag : otherProduct.getFlags()) {
                baseProduct.addFlag(flag);
            }
            
            return baseProduct;
        }
    }
    
    private virtual class SampleWrapper extends ProductWrapper {
        private String pt;
        private String pp; 

        private SampleWrapper(Product_vod__c prod) {
            super(prod, false, true);
            this.pt = prod.Product_Type_vod__c;
            this.pp = prod.Parent_Product_vod__c;
            addFlag(ProductFlag.sl);
        } 
    }
    
    private virtual class ReferralProductWrapper extends ProductWrapper {
        
        private ReferralProductWrapper(Product_vod__c prod, GNE_SFA2_ReferralUtil.ReferralProduct rProd, Boolean isMySetup, Boolean isVisible) {
            super(rProd.getId(), rProd.getName(), prod!=null ? prod.Product_Type_vod__c : null, isMySetup, isVisible);
            
            if(rProd.isBrand()) {
                addFlag(ProductFlag.rr);
            } else if(rProd.isTA()) {
                addFlag(ProductFlag.ta);
                
                if(rProd.isAutoMode()) {
                    addFlag(ProductFlag.aa);
                }
            } else if(rProd.isMolecule()) {
                addFlag(ProductFlag.ml);
            }
        } 
    }
    
    private virtual class ReferralBrandProductWrapper extends ReferralProductWrapper {
        private String ta;

        private ReferralBrandProductWrapper(Product_vod__c prod, GNE_SFA2_ReferralUtil.ReferralProduct rProd, Boolean isMySetup, Boolean isVisible) {
            super(prod, rProd, isMySetup, isVisible);
            this.ta = rProd.getTA();
        } 
    }
    
    private class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        private List<ProductWrapper> products;
        
        private DeltaRecordsResponse(List<ProductWrapper> products) {
            this.products = products;
        }
    }
}