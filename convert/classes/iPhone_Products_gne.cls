/*
    This is a webservice in SFDC that sends to OTR all product data with relations between products.
    
    Author : Lukasz "in your face, Apex" Indyk
    Created : 8 Aug 2011, 11:02 PM PST
    Project : gMARS Phase 2

    */

global without sharing class iPhone_Products_gne {
    WebService String userId;
    
    global class Product {
        WebService String id;
        WebService String name;
        WebService Boolean mySetup;
        WebService String parent;
        WebService String theraDisease;
        WebService String otrType;
        WebService Boolean isMLB;
        WebService String mlbType;
        WebService Boolean visible;
        WebService boolean noDetails;
        public Boolean active;
    }
    
    global class TdToMolecule {
        WebService String id;
        WebService String molecule;
        WebService String theraDisease;
    }
    
    global enum OtrType {
        Brand,
        AppInd, // approved indication
        Sample,
        Molecule,
        TD, // therapeutic disease
        Other // for example Reimbursement
    }
    
    global class Response {
        Webservice List<Product> products;
        WebService List<TdToMolecule> tdToMoleculeMapping;
    }
    
    public static List<Product_vod__c> allDiscussedProducts() {
        List<Product_vod__c> products = new List<Product_vod__c>();

                products =
                [
                    select id, name, product_type_vod__c, detail_product_subtype_code_gne__c, TheraDisease_Reference_gne__c, Parent_Product_vod__c, no_details_vod__c,active__c
                    from product_vod__c
                    where
                    	product_type_vod__c = 'Detail'     
                    	or detail_product_subtype_code_gne__c = 'Molecule'
                    order by TheraDisease_Reference_gne__c
                ];
         
        return products;
    }
    
    public static List<Product_vod__c> allMySetupProducts(String userId, List<Product> alreadyFetchedProducts) {
        List<Product_vod__c> products = new List<Product_vod__c>();
        Set<String> alreadyFetchedProductIds = mapProductsToIds(alreadyFetchedProducts);

                products =
                [
                    select id, name, product_type_vod__c, detail_product_subtype_code_gne__c, TheraDisease_Reference_gne__c, Parent_Product_vod__c, no_details_vod__c,active__c
                    from product_vod__c
                    where
                        id in (select product_vod__c from my_setup_products_vod__c where ownerid = :userId)
                        and
                        id not in :alreadyFetchedProductIds
                ];
         
        return products;
    }

    public static List<String> allMySetupProductsIds(String userId) {
        List<Product_vod__c> products = new List<Product_vod__c>();

                products =
                [
                    select id,active__c
                    from product_vod__c
                    where
                        id in (select product_vod__c from my_setup_products_vod__c where ownerid = :userId)
                ];
         
        return mapProductsToIds(products);
    }
    
    public static List<String> mapProductsToIds(List<Product_vod__c> products) {
        List<String> productIds = new List<String>();
        for (Product_vod__c product : products) {
            productIds.add(product.id);
        }
        
        return productIds;
    }

    public static Set<String> mapProductsToIds(List<Product> products) {
        Set<String> productIds = new Set<String>();
        for (Product product : products) {
            productIds.add(product.id);
        }
        
        return productIds;
    }

    public static List<Product_vod__c> allChildProducts(List<Product> parentProductList) {
        List<Product_vod__c> products = new List<Product_vod__c>();

        Set<String> parentProductIds = mapProductsToIds(parentProductList);
                products =
                [
                    select id, name, product_type_vod__c, detail_product_subtype_code_gne__c, TheraDisease_Reference_gne__c, Parent_Product_vod__c, no_details_vod__c, active__c
                    from product_vod__c
                    where                    
                        parent_product_vod__c in :parentProductIds                        
                        and
                        (parent_product_vod__r.product_type_vod__c = 'Detail' and product_type_vod__c not in ('Detail','Sample','Market'))
                ];
                         
        return products;
    }
    
    public static void createProduct(List<Product> productList, Product_vod__c dbproduct, Boolean mySetup, Boolean isChild) {
            Product product = new Product();
			
            product.id = dbproduct.id;
            product.name = dbproduct.name;
            product.mySetup = mySetup;
            if (isChild) {
                product.parent = dbproduct.Parent_Product_vod__c;                
            }
            
            product.theraDisease = dbproduct.TheraDisease_Reference_gne__c;
            OtrType otrType = getOtrType(dbproduct);
            product.isMLB = checkIfProductIsMLB(dbproduct, isChild);
            product.otrType = '' + otrType;
            if (product.isMLB) {
                product.mlbType = dbproduct.product_type_vod__c;
            }            
            product.noDetails = dbproduct.No_Details_vod__c;
            product.visible = false;
            product.active = dbproduct.active__c;            
            
            productList.add(product);
    }
    
    public static void createProduct(List<Product> productList, Product_vod__c dbproduct, Boolean mySetup, Boolean isChild, Set<Id> taSubTAList) {
            Product product = new Product();
			
            product.id = dbproduct.id;
            product.name = dbproduct.name;
            product.mySetup = mySetup;
            if (isChild) {
                product.parent = dbproduct.Parent_Product_vod__c;
            }
            product.theraDisease = dbproduct.TheraDisease_Reference_gne__c;
            OtrType otrType;
            if(!taSubTAList.contains(dbproduct.id)) {
            	otrType = getOtrType(dbproduct);
            	product.otrType = '' + otrType;
            	product.isMLB = checkIfProductIsMLB(dbproduct, isChild);
            } else {
            	product.otrType = 'TD';
            	product.isMLB = checkIfProductIsMLB(dbproduct, isChild);
            }
            if (product.isMLB) {
                product.mlbType = dbproduct.product_type_vod__c;
            }
            product.noDetails = dbproduct.No_Details_vod__c;
            product.visible = false;
            product.active = dbproduct.active__c;
            
            productList.add(product);
    }
    
    public static Boolean checkIfProductIsMLB (Product_vod__c dbproduct, Boolean isChild) {
            if(isChild && dbproduct.Product_Type_vod__c != 'Market' && dbproduct.Product_Type_vod__c != 'Sample') {
            	return true;
            } else {
            	return false;
            }
    }
    
    public static OtrType getOtrType(Product_vod__c dbproduct) {
        if (dbproduct.product_type_vod__c == 'Detail'  && dbproduct.detail_product_subtype_code_gne__c == 'Brand') {
            return OtrType.Brand;
        } else if (dbproduct.product_type_vod__c == 'Detail'  && dbproduct.detail_product_subtype_code_gne__c == 'Approved Product Indications') {
            return OtrType.AppInd;
        } else if (dbproduct.product_type_vod__c == 'Sample'  && (dbproduct.detail_product_subtype_code_gne__c == '' || dbproduct.detail_product_subtype_code_gne__c == null)) {
            return OtrType.Sample;
        } else if (dbproduct.detail_product_subtype_code_gne__c == 'Molecule') {
            return OtrType.Molecule;    
        } else {
        	return OtrType.Other;
        }
    }
    
    /**
		Get all available TASubTA. 
	*/
	
	public static Set<Id> getTASubTA() {
		
		List<String> productOwnerQueueNames = new List<String>{'GNE-SFA-CANADA-Queue','GNE-INACTIVE-PROD-QUEUE'};
		List<Id> productOwnerQueueId = new List<Id>();
		productOwnerQueueId = GNE_Referral_Utils.getProductOwnerQueueId(productOwnerQueueNames);
		
		List<String> medAffairsMoleculeNames = new List<String>();
		medAffairsMoleculeNames = GNE_Referral_Utils.getRestrictedProductName();
		
		List<Product_vod__c> tempList = new List<Product_vod__c>();
		Set<Id> tASubTAIdsList = new Set<Id>();
		if(productOwnerQueueId.size() > 0) {
			tempList = getAllProductsForMedAffairsMoleculeNames(productOwnerQueueId, medAffairsMoleculeNames);
		} else {
			tempList = getAllProductsForMedAffairsMoleculeNames(medAffairsMoleculeNames);
		}
		
		if(!tempList.isEmpty()) {
			for(Product_vod__c prod : tempList) {
				tASubTAIdsList.add(prod.Id);
			}
		}
		
		return tASubTAIdsList;
	}
	
	public static List<Product_vod__c> getAllProductsForMedAffairsMoleculeNames(List<Id> productOwnerQueueId, List<String> medAffairsMoleculeNames) {
		return [
			SELECT
				Id,active__c
			FROM 
				Product_vod__c 
			WHERE 
				Name NOT IN : medAffairsMoleculeNames 
				AND OwnerId NOT IN : ProductOwnerQueueId
				AND Product_Type_vod__c = 'Detail'
				AND Detail_Product_Subtype_Code_gne__c = 'TheraDisease'
			ORDER BY Name
		];
	}
	
	public static List<Product_vod__c> getAllProductsForMedAffairsMoleculeNames(List<String> medAffairsMoleculeNames) {
		return [
			SELECT
				Id,active__c
			FROM 
				Product_vod__c 
			WHERE 
				Name NOT IN : medAffairsMoleculeNames
				AND Product_Type_vod__c = 'Detail'
				AND Detail_Product_Subtype_Code_gne__c = 'TheraDisease' 
			ORDER BY Name
		];
	}
    
    global with sharing class AllUserProductsFetcher {
        public List<Product_vod__c> getAllProducts() {
            List<Product_vod__c> products = new List<Product_vod__c>();

            products =
                [
                    select id, name, product_type_vod__c, detail_product_subtype_code_gne__c, TheraDisease_Reference_gne__c, Parent_Product_vod__c, no_details_vod__c, active__c
                    from product_vod__c                    
                ];
         
            return products;
        }
    }
    
    public static Map<String, Product> createIdToProductMap(List<Product> products) {
        Map<String, Product> idToProductMap = new Map<String, Product>();
        for (Product product: products) {
            idToProductMap.put(product.id, product);
        }
        return idToProductMap;
    }
    
    public static void initializeVisibilityAndAddNotMySetupNotVisibleProductsToReturnProducts(Map<String, Product> idToProductMap, List<Product> addNotMySetupNotVisibleProductsHere) {
        
        AllUserProductsFetcher fetcher = new AllUserProductsFetcher();
        List<Product_vod__c> allUserProducts = fetcher.getAllProducts();
        
        for (Product_vod__c dbproduct : allUserProducts) {
            Product product = idToProductMap.get(dbproduct.id);            
            if (product != null) {            	
            	if (String.isNotBlank(product.parent) && product.isMLB){             
                	product.visible = product.active;
            	} else {
            		product.visible = true;
            	}
            } else {
                createProduct(addNotMySetupNotVisibleProductsHere, dbproduct, false, false);
            }
        }       
    }

        
    public static void initializeMySetup(String userId, Map<String, Product> idToProductMap) {
        
        List<String> mySetupIds = allMySetupProductsIds(userId);
        
        for (String mySetupId : mySetupIds) {
            Product product = idToProductMap.get(mySetupId);
            if (product != null) {
                product.mySetup = true;
            }
        }       
    }
    
    
    public static List<TdToMolecule> getTdToMoleculeMappings() {
        List<TASubTA_To_Molecule_gne__c> rows =
            [
                select Id, Product_TA_SubTA_gne__c, Product_Molecule_gne__c from TASubTA_To_Molecule_gne__c
            ];
            
        List<TdToMolecule> mappings = new List<TdToMolecule>();
        
        for (TASubTA_To_Molecule_gne__c row : rows) {
            TdToMolecule mapping = new TdToMolecule();
            mapping.id = row.Id;
            mapping.molecule = row.Product_Molecule_gne__c;
            mapping.theraDisease = row.Product_TA_SubTA_gne__c;
            
            mappings.add(mapping);
        }

        return mappings;
    }
    
    public static void filterOutMedAffairsMoleculesTheraDiseases(List<Product> products) {
        Map<String, Product> nameToProductMap = new Map<String, Product>();
        
        for (Product product : products) {
        	nameToProductMap.put(product.name, product);
        }
            
        List<MedAffairs_Molecules_gne__c> names =
            [
		    	select Molecule_Name_gne__c from MedAffairs_Molecules_gne__c order by Molecule_Name_gne__c
            ];
            
        for (MedAffairs_Molecules_gne__c molecule : names) {
        	Product product = nameToProductMap.get(molecule.Molecule_Name_gne__c);
        	
        	if (product != null) {
        		//System.debug(logginglevel.WARN, 'XXXXXXXXXXXXXXXXXXXXXXX: Molecule Name: ' + molecule.Molecule_Name_gne__c);    
        		product.otrType = '' + OtrType.OTHER;
        	}
        }
            
    }
    
    WebService static Response products(String userId) {
        Response response = new Response(); 
        response.products = new List<Product>();
        
        Set<Id> taSubTAList = getTASubTA();
        
        for (Product_vod__c dbproduct : allDiscussedProducts()) {
            createProduct(response.products, dbproduct, false, false, taSubTAList);
        }
        for (Product_vod__c dbproduct : allMySetupProducts(userId, response.products)) {
            createProduct(response.products, dbproduct, true, false, taSubTAList); 
        }
        
        for (Product_vod__c dbproduct : allChildProducts(response.products)) {
            createProduct(response.products, dbproduct, false, true, taSubTAList);
        }
        
        Map<String, Product> idToProductMap = createIdToProductMap(response.products);
        
        initializeMySetup(userId, idToProductMap);
        initializeVisibilityAndAddNotMySetupNotVisibleProductsToReturnProducts(idToProductMap, response.products);
        filterOutMedAffairsMoleculesTheraDiseases(response.products);
        
        response.tdToMoleculeMapping = getTdToMoleculeMappings();
        return response;
    }
    
    /*public static void printProductIds(String debugMessage, List<Product> products) {
    	System.debug(logginglevel.WARN, 'BEGIN BEGIN BEGIN BEGIN ' + debugMessage);
    	for (Product product : products) {
    		System.debug(logginglevel.WARN, product.id);
    	}
    	System.debug(logginglevel.WARN, 'END END END END END END ' + debugMessage);
    }*/
    
    public static void testMe(String userId) {
        Response resp = products(userId);

        for (Product product : resp.products) {
            System.debug(logginglevel.WARN, 'XXXXXXXXXXXXXXXXXXXXXXX: Product: ' + product.id + ' visible ' + product.visible);    
        }
    }        
    
}