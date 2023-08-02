/**
 * Created by pigulaks on 2019-05-22.
 */
global class EDM_Unknown_Brand_Email_Comp_Ctrl{

    public String unfilteredBrands {get;set;}

    public String getFilteredBrands() {
        String filteredBrands = '';
        Set<String> existingBrandsNames;
        List<String> incomingBrands = new List<String>();
        if(unfilteredBrands.contains(';')) {
            incomingBrands = unfilteredBrands.split(';');
        }
        else if(unfilteredBrands.contains(',')) {
            incomingBrands = unfilteredBrands.split(',');
        }
        else {
            incomingBrands = new List<String>{unfilteredBrands};
        }
        List<EDM_SBM_Brand_To_Indications_gne__c> curriculumBrands =  [SELECT Name FROM EDM_SBM_Brand_To_Indications_gne__c];
        existingBrandsNames = getExistingBrandsSet(curriculumBrands);

        for(String brandName : incomingBrands) {
            if(!existingBrandsNames.contains(brandName) ) {
                filteredBrands += brandName + ', ';
            }
        }

        return filteredBrands.removeEnd(', ');
    }

    private static Set<String> getExistingBrandsSet(List<EDM_SBM_Brand_To_Indications_gne__c> brands) {
        Set<String> result = new Set<String>();
        for (EDM_SBM_Brand_To_Indications_gne__c brand : brands) {
            result.add(brand.Name);
        }
        return result;
    }
}