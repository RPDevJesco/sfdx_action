public class ApexDocumentationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    /**
     * @param bc Database Batchable Context
     * @return Query for Apex Class from tooling API.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Brute force approach to not have Salesforce native code added to the documentation list.
        List<String> systemClasses = new List<String>{'SiteLoginController', 'SiteLoginControllerTest', 'SiteRegisterController', 'SiteRegisterControllerTest', 'ChangePasswordController', 'ChangePasswordControllerTest', 'ForgotPasswordController', 'ForgotPasswordControllerTest', 'MyProfilePageController', 'MyProfilePageControllerTest', 'CommunitiesLoginController', 'CommunitiesLoginControllerTest', 'CommunitiesLandingController', 'CommunitiesLandingControllerTest', 'CommunitiesSelfRegController', 'CommunitiesSelfRegControllerTest', 'CommunitiesSelfRegConfirmController', 'CommunitiesSelfRegConfirmControllerTest', 'MicrobatchSelfRegController', 'MicrobatchSelfRegControllerTest', 'LightningSelfRegisterController', 'LightningForgotPasswordController', 'LightningLoginFormController', 'LightningLoginFormControllerTest', 'LightningForgotPasswordControllerTest', 'LightningSelfRegisterControllerTest'};
        return Database.getQueryLocator('SELECT Name, Body, NamespacePrefix FROM ApexClass');
    }

    /**
     * @param bc Database Batchable Context
     * @param scope List of SObject which will store the results from the tooling API ApexClass query.
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Processing scope of size: ' + scope.size());
        List<ApexCodeDocumentation__c> docsToUpsert = new List<ApexCodeDocumentation__c>();
        Set<String> uniqueIdentifiers = new Set<String>();

        for(SObject sObj : scope) {
            ApexClass aClass = (ApexClass)sObj;
            String apexCode = aClass.Body;

            List<ApexCodeDocumentation__c> docsForThisClass = ApexDocumentationParser.ExtractDocumentation(apexCode);
            for(ApexCodeDocumentation__c doc : docsForThisClass) {
                // Generating the unique identifier using ParentClass, MethodName, and Parameters
                String uniqueId = doc.Name + '_' + doc.MethodName__c + '_' + doc.Parameters__c;

                // Only add the doc to the upsert list if it hasn't been added already
                if(!uniqueIdentifiers.contains(uniqueId)) {
                    uniqueIdentifiers.add(uniqueId);
                    doc.UniqueIdentifier__c = uniqueId;
                    docsToUpsert.add(doc);
                } else {
                    System.debug('Duplicate Unique Identifier Found: ' + uniqueId);
                }
            }
        }

        System.debug('Number of docs to upsert: ' + docsToUpsert.size());
        if(!docsToUpsert.isEmpty()) {
            upsert docsToUpsert UniqueIdentifier__c; // Specify the unique identifier field for the upsert
        }
    }

    /**
     * @param bc Database Batchable Context
     */
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
        FROM AsyncApexJob
        WHERE Id = :bc.getJobId()];

        if(job.NumberOfErrors > 0) {
            System.debug('The batch job failed with ' + job.NumberOfErrors + ' errors.');
        }
    }
}