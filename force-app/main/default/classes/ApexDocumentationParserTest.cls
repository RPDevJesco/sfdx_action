@IsTest
private class ApexDocumentationParserTest {
    static final String classBody = 'global class ApexDocumentationBatchLauncher {\n' +
            '    /**\n' +
            '     * Global function for launching the managed package\'s batch class for generating documentation.\n' +
            '     * @param batchSize size of the batch\n' +
            '     */\n' +
            '    global static void launchApexDocumentationBatch(Integer batchSize) {\n' +
            '        ApexDocumentationBatch batchInstance = new ApexDocumentationBatch();\n' +
            '        Database.executeBatch(batchInstance, batchSize);\n' +
            '    }\n' +
            '}';
    static final String classBodyWithInnerClass = 'global class ApexDocumentationBatchLauncher {\n' +
            '    /**\n' +
            '     * Global function for launching the managed package\'s batch class for generating documentation.\n' +
            '     * @param batchSize size of the batch\n' +
            '     */\n' +
            '    global static void launchApexDocumentationBatch(Integer batchSize) {\n' +
            '        ApexDocumentationBatch batchInstance = new ApexDocumentationBatch();\n' +
            '        Database.executeBatch(batchInstance, batchSize);\n' +
            '    }\n' +
            'public class ApexCode {\n' +
            '@AuraEnabled\n' +
            'public String ClassName;\n' +
            '@AuraEnabled\n' +
            'public String Body;\n' +
            '\t}\n' +
            '}';
    static final String commentBlock = '/**\n' +
            '* JDoc Style comment with param and return statements\n' +
            '* @param parameter for function would be described here\n' +
            '* @return if the function returns anything other than void, this would exist\n' +
            '*/';

    @TestSetup
    static void GenerateDocumentation() {
        ApexCodeDocumentation__c documentation = new ApexCodeDocumentation__c();
        documentation.ParentClass__c = 'ApexDocumentationBatchLauncher';
        documentation.MethodName__c = 'launchApexDocumentationBatch';
        documentation.MethodSignature__c = 'global static void';
        documentation.Parameters__c = 'Integer batchSize';
        documentation.FieldReference__c = 'Database.executeBatch';
        documentation.Description__c = '@param batchSize size of the batch';
        documentation.Return__c = 'not documented';
        insert documentation;
    }

    @IsTest
    static void testExtractDocumentation() {
        Test.startTest();
        List<ApexCodeDocumentation__c> getDocs = ApexDocumentationParser.ExtractDocumentation(classBody);
        Test.stopTest();

        List<ApexCodeDocumentation__c> docs = [SELECT MethodName__c FROM ApexCodeDocumentation__c];

        System.assert(!docs.isEmpty(), 'Docs should not be empty.');
        if (!docs.isEmpty()) {
            System.assertEquals('launchApexDocumentationBatch', docs[0].MethodName__c, 'Method Name should be launchApexDocumentationBatch');
        }
        System.assertEquals(1, docs.size(), 'Should only contain one method documentation');
    }

    @IsTest
    static void testExtractMethodDetails() {
        Test.startTest();
        List<ApexCodeDocumentation__c> getDocs = ApexDocumentationParser.ExtractDocumentation(classBody);
        Test.stopTest();

        List<ApexCodeDocumentation__c> docs = [SELECT MethodName__c FROM ApexCodeDocumentation__c];
        System.assert(!docs.isEmpty(), 'Docs should not be empty.');
        if (!docs.isEmpty()) {
            System.assertEquals('launchApexDocumentationBatch', docs[0].MethodName__c, 'Method Name should be launchApexDocumentationBatch');
        }
        System.assertEquals(1, docs.size(), 'Should only contain one method documentation');
    }

    @IsTest
    static void testExtractClassName() {
        Test.startTest();
        String className = ApexDocumentationParser.extractClassName(classBody);
        Test.stopTest();
        System.debug(className);
        System.assertEquals('ApexDocumentationBatchLauncher', className, 'Class Name should be ApexDocumentationBatchLauncher');
    }

    @IsTest
    static void testExtractInnerClassNames() {
        Test.startTest();
        List<String> innerClassNames = ApexDocumentationParser.extractInnerClassNames(classBodyWithInnerClass);
        Test.stopTest();
        System.debug(innerClassNames.size());
        System.debug(innerClassNames[1]);
        System.assertEquals(2, innerClassNames.size(), 'Should only contain one inner class name and one outter class name');
        System.assertEquals('ApexCode', innerClassNames[1], 'Inner Class Name should be ApexCode');
    }

    @IsTest
    static void testExtractFieldReferences() {
        Test.startTest();
        Set<String> fields = ApexDocumentationParser.extractFieldReferences(classBody);
        List<String> extractedFields = new List<String>(fields);
        Test.stopTest();
        System.debug(extractedFields.size());
        System.debug(extractedFields);
        System.assertEquals(1, fields.size(), 'Should only contain one field reference');
        System.assertEquals('Database.executeBatch', extractedFields[0], 'Field Reference should be Database.executeBatch');
    }

    @IsTest
    static void testExtractParamsComments() {
        Test.startTest();
        String paramsComments = ApexDocumentationParser.extractParamsComments(commentBlock);
        Test.stopTest();

        System.debug('Actual Params Comments: <' + paramsComments + '>, Length: ' + paramsComments.length());

        System.debug('Expected Params Comments: <' + paramsComments + '>, Length: ' + paramsComments.length());

        System.assertEquals('parameter: for function would be described here', paramsComments.trim(), 'Params Comments should match');
    }

    @IsTest
    static void testExtractReturnComment() {
        Test.startTest();
        String returnComment = ApexDocumentationParser.extractReturnComment(commentBlock);
        Test.stopTest();

        System.assertEquals('if the function returns anything other than void, this would exist', returnComment, 'Return Comment should match');
    }
}