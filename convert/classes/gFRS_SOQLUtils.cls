public with sharing class gFRS_SOQLUtils {

    private static String SYNTAX_INCLUDES = 'INCLUDES';
    private static String SYNTAX_EXCLUDES = 'EXCLUDES';
    private static String SYNTAX_IN = 'IN';
    private static String SYNTAX_LIKE = 'LIKE';
    private static String SYNTAX_NOT = 'NOT';

    private static Set<String> sLiterals = new Set<String> {
        'YESTERDAY',
        'TODAY',
        'TOMORROW',
        'LAST_WEEK',
        'THIS_WEEK',
        'NEXT_WEEK',
        'LAST_MONTH',
        'THIS_MONTH',
        'NEXT_MONTH',
        'LAST_90_DAYS',
        'NEXT_90_DAYS',
        'LAST_N_DAYS',
        'NEXT_N_DAYS',
        'NEXT_N_WEEKS',
        'LAST_N_WEEKS',
        'NEXT_N_MONTHS',
        'LAST_N_MONTHS',
        'THIS_QUARTER',
        'LAST_QUARTER',
        'NEXT_QUARTER',
        'NEXT_N_QUARTERS',
        'LAST_N_QUARTERS',
        'THIS_YEAR',
        'LAST_YEAR',
        'NEXT_YEAR',
        'NEXT_N_YEARS',
        'LAST_N_YEARS',
        'THIS_FISCAL_QUARTER',
        'LAST_FISCAL_QUARTER',
        'NEXT_FISCAL_QUARTER',
        'NEXT_N_FISCAL_​QUARTERS',
        'LAST_N_FISCAL_​QUARTERS',
        'THIS_FISCAL_YEAR',
        'LAST_FISCAL_YEAR',
        'NEXT_FISCAL_YEAR',
        'NEXT_N_FISCAL_​YEARS',
        'LAST_N_FISCAL_​YEARS'
    };

    public static String StringValueOf(Object o) {
        if (o == null) return '';
        if (o instanceof SObject) 	return enquoteString( String.valueOf( ((sObject) o).get('Id') ));
        if (o instanceof Date )		return String.valueOf( o ).left(10);
        if (o instanceof DateTime) 	return String.valueOf( o ).replace(' ', 'T') + 'Z';
        if (o instanceof String)		return StringValueOf((String) o);
        if (o instanceof Id)			return enquoteString( String.valueOf(o) );
        return String.valueOf(o);
    }

    public static String StringValueOf(String str) {
        String temp = str.substringBeforeLast(':');
        if ( sLiterals.contains(temp)) {
            return str;
        }
        else if( Pattern.matches('[0-9]{4}-[0-9]{2}-[0-3][0-9](T([0-9]{2}:?){2})?', str)){
        	return str;
        }
        else {
            return enquoteString(str);
        }
    }

    public static String StringValueOf(Object[] objs) {
        String[] lValues = new String[] {};
        for (Object o : objs) {
            lValues.add( StringValueOf(o));
        }

        return String.join(lValues, ',');
    }

    public static String whereField(String field, String operator, Object value) {
        String valueArg = StringValueOf(value);
        String [] queryPart = new String[] { field, operator, valueArg };

        return String.join(queryPart, ' ');
    }

    public static String whereField(String field, String operator, Object[] values) {
        String strValues = StringValueOf(values);
        String [] queryPart = new String[] { field, operator,'(', strValues,')' };

        return String.join(queryPart, ' ');
    }

    public static String whereFieldIn(String field, String[] values) {
        return whereField(field, SYNTAX_IN, values);
    }

    public static String whereFieldNotIn(String field, String[] values) {
        return 'NOT ' + whereFieldIn(field, values);
    }

    public static String whereFieldEquals(String field, Object value) {
        return whereField(field, '=', value);
    }

    public static String whereFieldNotEquals(String field, Object value) {
        return 'NOT ' + whereField(field, '!=', value);
    }

    public static String whereFieldLike(String field, String value) {
        return whereField(field, SYNTAX_LIKE, value);
    }

    public static String whereFieldNotLike(String field, String value) {
        return 'NOT ' + whereField(field, SYNTAX_LIKE, value);
    }

    public static String whereFieldIncludes(String field, String value) {
        return whereField(field, SYNTAX_INCLUDES, new String[]{value});
    }

    public static String whereFieldIncludes(String field, String[] values) {
        return whereField(field, SYNTAX_INCLUDES, values);
    }

    public static String whereFieldNotIncludes(String field, String value) {
        return 'NOT ' + whereField(field, SYNTAX_INCLUDES, new String[]{value});
    }

    public static String whereFieldNotIncludes(String field, String[] value) {
        return 'NOT ' + whereField(field, SYNTAX_INCLUDES, value);
    }

    public static String whereFieldExcludes(String field, String value) {
        return whereField(field, SYNTAX_EXCLUDES, new String[]{value});
    }

    public static String whereFieldNotExcludes(String field, String value) {
        return 'NOT ' + whereField(field, SYNTAX_EXCLUDES, new String[]{value});
    }

    public static String whereFieldExcludes(String field, String[] value) {
        return whereField(field, SYNTAX_EXCLUDES, value);
    }

    public static String whereFieldNotExcludes(String field, String[] value) {
        return 'NOT ' + whereField(field, SYNTAX_EXCLUDES, value);
    }

    public static String enquoteString(String value) {
        if (!value.startsWith('\'') && !value.endsWith('\'')) {
            value = value.center(value.length() + 2, '\'');
        }
        return value;
    }

    public static String[] enquoteStrings(String[] values) {
        String[] enquotedStrings = new String[] {};
        for (String str : values) {
            if (!str.startsWith('\'') && !str.endsWith('\'')) {
                str = str.center(str.length() + 2, '\'');
            }
            enquotedStrings.add(str);
        }
        return enquotedStrings;
    }
}