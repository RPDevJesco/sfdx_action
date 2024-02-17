public class ApexDocumentationParser {
    /**
     * Extracts all documentation related to class names, inner class names and method details
     * @param classBody JSON for the class information pulled from the DB.
     * @return A AgileDocMaster__ApexDocumentation__c object with all the documentation related to the class.
     */
    public static List<ApexCodeDocumentation__c> ExtractDocumentation(String classBody) {
        List<ApexCodeDocumentation__c> docs = new List<ApexCodeDocumentation__c>();
        ApexPatternMatcher.parseClassBody(classBody);
        //List<String> constructors = ApexPatternMatcher.matchConstructor(classBody);
        List<String> variables = ApexPatternMatcher.matchVariable(classBody);
        List<String> methods = ApexPatternMatcher.matchMethod(classBody);
        List<String> singleComments = ApexPatternMatcher.matchSingleComment(classBody);
        List<String> multicomments = ApexPatternMatcher.matchMultiComment(classBody);
        List<String> docComments = ApexPatternMatcher.matchDocComment(classBody);
        List<String> annotations = ApexPatternMatcher.matchAnnotation(classBody);
        return null;
    }

    private static List<ApexCodeDocumentation__c> testParse(String classBody) {
        List<ApexCodeDocumentation__c> docs = new List<ApexCodeDocumentation__c>();
        Pattern bodyPattern = ApexPatternMatcher.classPattern;
        Matcher bodyMatcher = bodyPattern.matcher(classBody);
        while (bodyMatcher.find()) {
            for(Integer i = 1; i <= bodyMatcher.groupCount(); i++) {
                System.debug('Group ' + i + ': ' + bodyMatcher.group(i));
            }
        }
        return docs;
    }


    @TestVisible
    private static List<ApexCodeDocumentation__c> extractPropertiesDetails(String classBody, String className) {
        List<ApexCodeDocumentation__c> docs = new List<ApexCodeDocumentation__c>();

        Pattern propertyPattern = Pattern.compile('(@(AuraEnabled|Deprecated|Future|InvocableMethod|InvocableVariable|IsTest|JsonAccess|NamespaceAccessible|ReadOnly|RemoteAction|SuppressWarnings|TestSetup|RestResource|HttpDelete|HttpGet|HttpPatch|HttpPost|HttpPut)\\s+)*(public|private|protected|global)\\s+\\w+\\s+(\\w+);');
        Matcher propertyMatcher = propertyPattern.matcher(classBody);

        while (propertyMatcher.find()) {
            ApexCodeDocumentation__c doc = new ApexCodeDocumentation__c();

            doc.ParentClass__c = className;
            doc.PropertyName__c = propertyMatcher.group(1) + ' ' +
                    (propertyMatcher.group(3) != null ? propertyMatcher.group(4).trim() : '');
            docs.add(doc);
        }

        return docs;
    }


    /**
     * Extracts all documentation related to method details
     * @param classBody JSON for the class information pulled from the DB.
     * @param className Name of the class
     * @return List<AgileDocMaster__ApexDocumentation__c> which stores all the methods in the class.
     */
    @TestVisible
    private static List<ApexCodeDocumentation__c> extractMethodDetails(String classBody, String className) {
        List<ApexCodeDocumentation__c> docs = new List<ApexCodeDocumentation__c>();

        Pattern methodPattern = Pattern.compile('(/\\*\\*([\\s\\S]*?)\\*/\\s*)?(public|private)(\\s+static)? (\\w+) (\\w+)\\(([^)]*)\\)');
        Matcher methodMatcher = methodPattern.matcher(classBody);
        while (methodMatcher.find()) {
            ApexCodeDocumentation__c doc = new ApexCodeDocumentation__c();

            doc.ParentClass__c = className;
            doc.MethodName__c = methodMatcher.group(6);
            doc.MethodSignature__c = methodMatcher.group(3) + ' ' +
                    (methodMatcher.group(4) != null ? methodMatcher.group(4).trim() : '') +
                    ' ' + methodMatcher.group(5);
            doc.Parameters__c = '(' + methodMatcher.group(7) + ')';

            // Extracting field references within the method context
            Set<String> referencedFields = extractFieldReferences(methodMatcher.group(0)); // Group 0 is the entire matched method block
            doc.FieldReference__c = String.join(new List<String>(referencedFields), '; '); // Storing the referenced fields as a semi-colon delimited string

            if (methodMatcher.group(1) != null) {
                String paramsComments = extractParamsComments(methodMatcher.group(2));
                doc.Description__c = String.isEmpty(paramsComments) ? 'Not documented' : paramsComments;

                String returnComment = extractReturnComment(methodMatcher.group(2));
                doc.Return__c = String.isEmpty(returnComment) ? 'Not documented' : returnComment;
            } else {
                doc.Return__c = 'Not documented';
            }

            docs.add(doc);
        }
        return docs;
    }

    /**
     * Extracts all documentation related to class names
     * @param classBody JSON for the class information pulled from the DB.
     * @return A String which looks for the class name with the access modifier.
     */
    @TestVisible
    private static String extractClassName(String classBody) {
        Pattern classPattern = Pattern.compile('(public|private|global|protected)(\\s+virtual|\\s+abstract)?(\\s+with sharing)?\\s+(class|interface) (\\w+)');
        Matcher classMatcher = classPattern.matcher(classBody);
        if (classMatcher.find()) {
            return classMatcher.group(5);
        }
        return null;
    }

    /**
     * Extracts all documentation related to inner class names
     * @param classBody JSON for the class information pulled from the DB.
     * @return A String which looks for the inner class name with the access modifier.
     */
    @TestVisible
    private static List<String> extractInnerClassNames(String classBody) {
        List<String> innerClassNames = new List<String>();
        Pattern innerClassPattern = Pattern.compile('(public|private|global|protected)(\\s+virtual|\\s+abstract)?(\\s+with sharing)?\\s+class (\\w+)');
        Matcher innerClassMatcher = innerClassPattern.matcher(classBody);
        while (innerClassMatcher.find()) {
            innerClassNames.add(innerClassMatcher.group(4));
        }
        return innerClassNames;
    }

    /**
     * Extracts all documentation related to field references
     * @param classBody JSON for the class information pulled from the DB.
     * @return Set<String> for the field references used int he function.
     */
    @TestVisible
    private static Set<String> extractFieldReferences(String classBody) {
        Pattern fieldPattern = Pattern.compile('\\b([A-Za-z]\\w*)\\.([A-Za-z_]\\w*)\\b');

        Set<String> fields = new Set<String>();

        Matcher fieldMatcher = fieldPattern.matcher(classBody);
        while (fieldMatcher.find()) {
            fields.add(fieldMatcher.group(1) + '.' + fieldMatcher.group(2));
        }

        Set<String> knownNonFields = new Set<String>{'String', 'Integer', 'Boolean', 'Date', 'Datetime', 'System', 'Database'};
        fields.removeAll(knownNonFields);

        return fields;
    }

    /**
     * Extracts all documentation related to @param comments
     * @param commentBlock JSON for the @param comment information pulled from the DB.
     * @return A String from the comments.
     */
    @TestVisible
    private static String extractParamsComments(String commentBlock) {
        Pattern paramPattern = Pattern.compile('@param (\\w+) (.*?)(\\r?\\n|$)');
        Matcher paramMatcher = paramPattern.matcher(commentBlock);
        String paramsComments = '';
        while (paramMatcher.find()) {
            paramsComments += paramMatcher.group(1) + ': ' + paramMatcher.group(2).trim() + '\n';
        }
        return paramsComments;
    }

    /**
     * Extracts all documentation related to @return comments
     * @param commentBlock JSON for the @return information pulled from the DB.
     * @return A String from the return statement.
     */
    @TestVisible
    private static String extractReturnComment(String commentBlock) {
        Pattern returnPattern = Pattern.compile('@return (.*?)(\\r?\\n|$)');
        Matcher returnMatcher = returnPattern.matcher(commentBlock);
        if (returnMatcher.find()) {
            return returnMatcher.group(1).trim();
        }
        return null;
    }
}