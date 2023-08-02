public without sharing class GNE_SFA2_Address_Util {
    public static Boolean isAddressTheSame(Address_vod__c firstAddress, Address_vod__c secondAddress) {
        //prepare address
        if(firstAddress == null || secondAddress == null) {
            return false;
        }
        String firstAddressName = normalizeString(firstAddress.Name.toLowerCase());
        String secondAddressName = normalizeString(secondAddress.Name.toLowerCase());

        //prepare city
        String firstCity, secondCity;
        if(firstAddress.City_vod__c != null) {
            firstCity = normalizeString(firstAddress.City_vod__c.toLowerCase());
            firstCity = removeCityFromCityName(firstCity);
        }

        if(secondAddress.City_vod__c != null) {
            secondCity = normalizeString(secondAddress.City_vod__c.toLowerCase());
            secondCity = removeCityFromCityName(secondCity);
        }

        //check if equals
        return  firstAddressName == secondAddressName &&
                firstAddress.Inactive_vod__c == false &&
                secondAddress.Inactive_vod__c == false &&
                firstCity == secondCity &&
                firstAddress.Province_can_gne__c == secondAddress.Province_can_gne__c &&
                firstAddress.Postal_Code_can_gne__c == secondAddress.Postal_Code_can_gne__c;
    }

    private static String normalizeString(String value) {
        Map<String, String> correspondingCharacters = new Map<String, String> {
                'ô' => 'o',
                'é' => 'e'
        };
        Integer[] chars = value.getChars();

        for(Integer i : chars) {
            if(i > 122) {
                String charac = String.fromCharArray(new Integer[] { i });
                if(correspondingCharacters.containsKey(charac)) {
                    String correspondingChar = correspondingCharacters.get(charac);
                    value = value.replace(charac, correspondingChar);
                }
            }
        }
        value = removeDotsAndCommas(value);
        value = removeAddressShortcuts(value);
        return value;
    }

    private static String removeDotsAndCommas(String address) {
        if(address.contains('.')) {
            address = address.remove('.');
        }
        if(address.contains(',')) {
            address = address.remove(',');
        }
        return address;
    }

    private static String removeAddressShortcuts(String address) {
        Set<String> shortcuts = new Set<String> {
            'ave',
            'avenue',
            'street',
            'st',
            'rd',
            'road'
        };
        for(String shortcut : shortcuts) {
            if(address.contains(shortcut)) {
                address = address.remove(' '+shortcut);
            }
        }
        return address;
    }

    private static String removeCityFromCityName(String cityName) {
        cityName = cityName.toLowerCase();
        if(cityName.contains(' city')) {
            cityName = cityName.remove(' city');
        }
        return cityName;
    }
}