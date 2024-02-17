public class AzureWorkItem {
    @AuraEnabled
    public Integer Id;
    @AuraEnabled
    public String State;
    @AuraEnabled
    public String AssignedTo;
    @AuraEnabled
    public String Title;
    @AuraEnabled
    public String WorkItemType;
    @AuraEnabled
    public String Tags;
    @AuraEnabled
    public String Description;
    @AuraEnabled
    public List<String> Comments;
}