@isTest
public class GNE_SFA2_EventCurclmBureau_EdCreEx_Test {

	@TestSetup
	public static void setupData() {
		setupMappingCS();
	}

	private static void setupMappingCS() {
		Map<String, String> brandToIndications = new Map<String, String> {
			'Actemra' => 'Rheumatoid Arthritis;SC;SJIA;PJIA',
			'Avastin' => 'Cervical Cancer;GBM;mCRC;NSCLC;Ovarian;RCC',
			'Erivedge' => 'Basal Cell',
			'Esbriet' => 'IPF',
			'GAZYVA' => 'CLL',
			'Herceptin' => 'eBC;mBC',
			'Kadcyla' => 'mBC',
			'Lucentis' => 'AMD;DME;DR w/DME;RVO',
			'Nutropin' => 'CRF;GH;ISS;TS',
			'PERJETA' => 'eBC;mBC',
			'Rituxan' => 'Non-Hodgkins Lymphoma;RA;WG/MPA;RA;Chronic Lymphocytic Leukemia',
			'Tarceva' => 'Lung;Pancreatic',
			'TECENTRIQ' => 'mUC',
			'Xeloda' => 'aCC;mBC;mCRC',
			'Xolair' => 'Allergic Asthma;CIU',
			'Zelboraf' => 'Metastatic Melanoma'
		};

		List<EDM_SBM_Brand_To_Indications_gne__c> brands = new List<EDM_SBM_Brand_To_Indications_gne__c>();

		for (String brandName : brandToIndications.keyset()) {
			brands.add(new EDM_SBM_Brand_To_Indications_gne__c(Name = brandName, Indications__c = brandToIndications.get(brandName)));
		}

		brands.add(new EDM_SBM_Brand_To_Indications_gne__c(Name = 'NoIndications'));

		insert brands;
		
	}

	@isTest
	public static void shouldPopulateBrandToIndicationMap() {
		//given
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Event_Curriculum_gne__c());

		//when
		GNE_SFA2_EventCurclmBureau_EditCreateEx extension = new GNE_SFA2_EventCurclmBureau_EditCreateEx(stdCtrl);

		//then
		System.assertEquals(new List<String> {'eBC','mBC'}, extension.loadBrandsToIndicationsMap().get('Herceptin'));
		System.assertEquals(null, extension.loadBrandsToIndicationsMap().get('NoIndications'));
		List<String> sortedIndications = extension.loadBrandsToIndicationsMap().get('No Product Discussed');
		System.assertEquals('None', sortedIndications[0]);
		System.assertEquals('WG/MPA', sortedIndications[sortedIndications.size() - 1]);
	}
}