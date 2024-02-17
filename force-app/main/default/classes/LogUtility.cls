public class LogUtility {

    // Method to log DML errors
    public static void logDMLErrors(List<Database.SaveResult> results, SObject so) {
        String governorLimitsReport = GovernorLimitsUtil.getApexResourceUsageReports();
        List<ErrorLog__c> errorLogs = new List<ErrorLog__c>();

        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    ErrorLog__c log = new ErrorLog__c();
                    log.Error_Message__c = err.getMessage();
                    log.SObject_Type__c = String.valueOf(so.getSObjectType());
                    log.Record_Id__c = result.getId() != null ? result.getId() : '';
                    log.StackTrace__c = err.getMessage();
                    log.report__c = governorLimitsReport;
                    errorLogs.add(log);
                }
            }
        }

        if(!errorLogs.isEmpty()) {
            insert errorLogs;
        }
    }

    public static void logException(Exception ex, SObject so) {
        String governorLimitsReport = GovernorLimitsUtil.getApexResourceUsageReports();

        ErrorLog__c log = new ErrorLog__c();
        log.Error_Message__c = ex.getMessage();
        log.SObject_Type__c = String.valueOf(so.getSObjectType());
        if(so.Id != null) log.Record_Id__c = String.valueOf(so.Id);
        log.StackTrace__c = ex.getStackTraceString();
        log.report__c = governorLimitsReport;

        insert log;
    }
}