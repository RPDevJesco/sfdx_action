public with sharing class ApexDocumentationController {
    /**
     * @return returns the ApexDocumentation__c fields to be used in the apexCodeDocumentation LWC Component.
     */
    @AuraEnabled(cacheable=true)
    public static List<ApexCodeDocumentation__c> getDocumentation() {
        //return null;
        return [SELECT ParentClass__c, MethodName__c, PropertyName__c, Parameters__c, MethodSignature__c, Description__c, FieldReference__c, Return__c FROM ApexCodeDocumentation__c];
    }
}