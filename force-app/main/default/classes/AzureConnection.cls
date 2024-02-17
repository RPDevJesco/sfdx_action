public class AzureConnection {
    private static String ORGANIZATION;
    private static String PROJECT;
    private static String USERNAME;
    private static String PAT;

    // Initialize HttpRequest
    private static HttpRequest initializeHttpRequest(String endpoint, String method) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        return req;
    }

    // Set Authentication
    private static void setAuthentication(HttpRequest req) {
        // For Basic Authentication
        String credentials = USERNAME + ':' + PAT;
        Blob headerValue = Blob.valueOf(credentials);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
    }

    // Execute Callout
    private static HttpResponse executeCallout(HttpRequest req) {
        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
        } catch (System.CalloutException e) {
            System.debug('Callout error: ' + e);
            throw e;
        }

        return res;
    }

    // Main Function to Coordinate the Callout
    public static HttpResponse makeCallout(String endpoint, String method) {
        HttpRequest req = initializeHttpRequest(endpoint, method);
        setAuthentication(req);
        HttpResponse res = executeCallout(req);
        return res;
    }

    // Validate and Sanitize value for Callout
    public static String sanitizeAssignedToValue(String input) {
        if (input == null) {
            return null;
        }

        // Basic validation: Check for allowed patterns, length, etc.
        // For example: Check if the string is of reasonable length
        if (input.length() > 255) {
            System.debug('AssignedTo value is too long.');
        }

        // Basic validation: Ensure it doesn't contain semicolons, double quotes, etc.
        Pattern disallowedChars = Pattern.compile('[;"]'); // Add other characters as needed
        if (disallowedChars.matcher(input).find()) {
            System.debug('Invalid characters in AssignedTo value.');
        }

        // Escape single quotes
        return String.escapeSingleQuotes(input);
    }

    @AuraEnabled(Cacheable=true)
    public static List<AzureWorkItem> getDetailedWorkItems(String setOrganizationName, String setProjectName, String setUserName, String setPersonalAccessToken) {
        ORGANIZATION = setOrganizationName;
        PROJECT = setProjectName;
        USERNAME = setUserName;
        PAT = setPersonalAccessToken;
        List<AzureWorkItem> workItems = new List<AzureWorkItem>();

        String endpoint = 'https://dev.azure.com/' + ORGANIZATION +'/' + PROJECT + '/_apis/wit/wiql?api-version=6.0';
        HttpRequest req = initializeHttpRequest(endpoint, 'POST');
        setAuthentication(req);

        String wiqlQuery = '{"query": "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.AssignedTo], [System.State], [System.Tags] ' +
                'FROM workitems ' +
                'WHERE [System.TeamProject] = @project ' +
                'AND ([System.AssignedTo] = \'\' OR [System.AssignedTo] = \'' + sanitizeAssignedToValue(USERNAME) + '\') ' +
                'ORDER BY [Microsoft.VSTS.Common.Priority] ASC, [System.CreatedDate] DESC"}';

        req.setBody(wiqlQuery);
        HttpResponse initialResponse = executeCallout(req);

        System.debug(initialResponse);

        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(initialResponse.getBody());
        List<Object> workItemsData = (List<Object>) parsedResponse.get('workItems');

        // Collecting the IDs from the initial response
        List<Integer> ids = new List<Integer>();
        for (Object itemData : workItemsData) {
            Map<String, Object> itemMap = (Map<String, Object>) itemData;
            Integer id = (Integer) itemMap.get('id');
            ids.add(id);
        }

        // Make a batch call with the collected IDs
        String batchEndpoint = 'https://dev.azure.com/' + ORGANIZATION +'/' + PROJECT + '/_apis/wit/workitems?ids=' + String.join(ids, ',') + '&api-version=6.0';
        HttpResponse batchResponse = makeCallout(batchEndpoint, 'GET');

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(batchResponse.getBody());
        List<Object> workItemsList = (List<Object>) responseMap.get('value');

        for (Object obj : workItemsList) {
            Map<String, Object> workItemDetails = (Map<String, Object>) obj;
            Map<String, Object> fields = (Map<String, Object>) workItemDetails.get('fields');

            AzureWorkItem workItem = new AzureWorkItem();
            workItem.Id = (Integer) workItemDetails.get('id');
            workItem.Title = (String) fields.get('System.Title');
            Object rawAssignedValue = fields.get('System.AssignedTo');

            if (rawAssignedValue != null) {
                Map<String, Object> assignedValueMap = (Map<String, Object>) rawAssignedValue;
                if (assignedValueMap != null && assignedValueMap.containsKey('uniqueName')) {
                    workItem.AssignedTo = (String) assignedValueMap.get('uniqueName');
                }
            } else {
                System.debug('AssignedTo is null or not present.');
            }

            // Fetch the Description and remove html tags
            String description = (String) fields.get('System.Description');
            if(description != null) {
                description = description.replace('<div>', '').replace('</div>', '').replace('<br>', '').replace('</u>', ' ').replace('<u>', ' ').replace('</b>', '').replace('<b>', '');
                workItem.Description = description.trim();  // Trim to remove any leading or trailing spaces
            }
            workItem.State = (String) fields.get('System.State');
            workItem.WorkItemType = (String) fields.get('System.WorkItemType');

            if(fields.containsKey('System.Tags')) {
                workItem.Tags = (String) fields.get('System.Tags');
            } else {
                workItem.Tags = null;
            }

            workItems.add(workItem);
        }

        return workItems;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getWorkItemComments(String setOrganizationName, String setProjectName, String setUserName, String setPersonalAccessToken, Integer workItemId) {
        ORGANIZATION = setOrganizationName;
        PROJECT = setProjectName;
        USERNAME = setUserName;
        PAT = setPersonalAccessToken;
        List<String> comments = new List<String>();
        String endpoint = 'https://dev.azure.com/' + ORGANIZATION + '/' + PROJECT + '/_apis/wit/workitems/' + workItemId + '/comments?api-version=6.0-preview';
        HttpRequest req = initializeHttpRequest(endpoint, 'GET');
        setAuthentication(req);
        HttpResponse res = executeCallout(req);
        if (res.getStatusCode() != 200) {
            // You can log the error or throw an exception with the response body to get more details about the failure
            System.debug('Callout failed with status: ' + res.getStatusCode() + '. Response: ' + res.getBody());
            System.debug('Failed to fetch comments for work item: ' + workItemId);
        }

        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> commentsData = (List<Object>) parsedResponse.get('comments');
        for (Object commentData : commentsData) {
            Map<String, Object> commentMap = (Map<String, Object>) commentData;
            comments.add((String) commentMap.get('text'));
        }
        return comments;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getTeamNames(String setOrganizationName, String setProjectName, String setUserName, String setPersonalAccessToken) {
        String ORGANIZATION = setOrganizationName;
        String PROJECT = setProjectName;
        String USERNAME = setUserName;
        String PAT = setPersonalAccessToken;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        List<String> teamNames = new List<String>();

        String endpointTeams = 'https://dev.azure.com/' + ORGANIZATION + '/' + PROJECT + '_apis/work/teamsettings/teamfieldvalues?api-version=7.2-preview.1';

        req.setEndpoint(endpointTeams);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(USERNAME + ':' + PAT));
        req.setHeader('Authorization', authorizationHeader);

        HttpResponse response = http.send(req);
        System.debug(response);
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (results.containsKey('value') && results.get('value') instanceof List<Object>) {
                List<Object> teams = (List<Object>) results.get('value');
                for (Object teamObj : teams) {
                    Map<String, Object> teamMap = (Map<String, Object>) teamObj;
                    if (teamMap.containsKey('name')) {
                        teamNames.add((String) teamMap.get('name'));
                    }
                }
            }
        } else {
            System.debug('Error fetching team names: ' + response.getStatus());
        }
        return teamNames;
    }

    @AuraEnabled(Cacheable=true)
    public static String getBoardColumns(String setOrganizationName, String setProjectName, String setUserName, String setPersonalAccessToken) {
        ORGANIZATION = setOrganizationName;
        PROJECT = setProjectName;
        USERNAME = setUserName;
        PAT = setPersonalAccessToken;
        // https://dev.azure.com/{organization}/{project}/_apis/work/boardcolumns?api-version=6.0
        String endpoint = 'https://dev.azure.com/' + ORGANIZATION + '/' + PROJECT + '/_apis/work/boardcolumns?api-version=6.0';
        HttpRequest req = initializeHttpRequest(endpoint, 'GET');
        setAuthentication(req);
        HttpResponse res = executeCallout(req);
        if (res.getStatusCode() != 200) {
            // Handle error
            System.debug('Callout failed with status: ' + res.getStatusCode() + '. Response: ' + res.getBody());
            return null;
        }

        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> columns = (List<Object>) results.get('value');

        List<BoardColumn> transformedColumns = new List<BoardColumn>();
        Integer loc = 0;
        for (Object col : columns) {
            Map<String, Object> column = (Map<String, Object>) col;
            transformedColumns.add(new BoardColumn((String) column.get('name'), String.valueOf(loc) + ' 43.52284749830794'));
            loc += 109; // Adjust as needed
        }

        return JSON.serialize(transformedColumns);
    }

    @AuraEnabled(Cacheable=true)
    public static void updateWorkItemState(String setOrganizationName, String setProjectName, String setUserName, String setPersonalAccessToken, Integer workItemId, String newState) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        ORGANIZATION = setOrganizationName;
        PROJECT = setProjectName;
        USERNAME = setUserName;
        PAT = setPersonalAccessToken;

        req.setEndpoint('https://dev.azure.com/' + ORGANIZATION + '/' + PROJECT + '/_apis/wit/workitems/' + workItemId + '?api-version=6.0');
        req.setMethod('PATCH');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(':' + PAT)));
        req.setHeader('Content-Type', 'application/json-patch+json');

        // Construct the JSON body for the update
        String body = '[{"op": "add", "path": "/fields/System.State", "value": "' + newState + '"}]';
        req.setBody(body);

        res = http.send(req);
        // Handle the response as required
    }

    @AuraEnabled(Cacheable=true)
    public static void addWorkItemComment(String setOrganizationName, String setProjectName, String setUserName, String setPersonalAccessToken,Integer workItemId, String commentText) {
        ORGANIZATION = setOrganizationName;
        PROJECT = setProjectName;
        USERNAME = setUserName;
        PAT = setPersonalAccessToken;
        String endpoint = 'https://dev.azure.com/' + ORGANIZATION + '/' + PROJECT + '/_apis/wit/workitems/' + workItemId + '/comments?api-version=6.0-preview';
        HttpRequest req = initializeHttpRequest(endpoint, 'POST');
        setAuthentication(req);

        Map<String, String> requestBody = new Map<String, String>{
                'text' => commentText
        };
        req.setBody(JSON.serialize(requestBody));

        HttpResponse res = executeCallout(req);
        // Handle the response if necessary
    }

    // Navigate to Wiki Page
    @AuraEnabled(Cacheable=true)
    public static String getWikiPageURL(String wikiName) {
        // Constructing URL based on Azure DevOps documentation and your organization and project details
        String wikiURL = 'https://dev.azure.com/' + ORGANIZATION + '/' + PROJECT + '/_wiki/wikis/' + wikiName + '.wiki';
        return wikiURL;
    }

    // Create a Wiki Page
    @AuraEnabled(Cacheable=true)
    public static void createWikiPage(String setOrganizationName, String setProjectName, String setUserName, String setPersonalAccessToken, String wikiName, String pagePath, String pageContent) {
        ORGANIZATION = setOrganizationName;
        PROJECT = setProjectName;
        USERNAME = setUserName;
        PAT = setPersonalAccessToken;

        String endpoint = 'https://dev.azure.com/' + ORGANIZATION + '/' + PROJECT + '/_apis/wiki/wikis/' + wikiName + '/pages?path=' + EncodingUtil.urlEncode(pagePath, 'UTF-8') + '&api-version=6.0';
        HttpRequest req = initializeHttpRequest(endpoint, 'PUT'); // Assuming PUT as per Azure DevOps API to create or update a page
        setAuthentication(req);

        Map<String, Object> requestBody = new Map<String, Object>{
                'content' => pageContent
        };
        req.setBody(JSON.serialize(requestBody));

        HttpResponse res = executeCallout(req);
        // Handle the response if necessary, for example, check for success or failure
    }
}