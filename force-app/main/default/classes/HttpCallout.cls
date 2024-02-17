/**
 * Created by Jesse Glover on 7/25/2023.
 */

public class HttpCallout {
    public static List<User> getUsers(Integer pageNumber) {
        String url = 'https://reqres.in/api/users?page=' + String.valueOf(pageNumber);

        // Make the real HTTP callout to the API and retrieve the response
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = new Http().send(request);

        // Parse the response and extract the data
        List<User> users = new List<User>();
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> userDataList = (List<Object>) responseData.get('data');

            for (Object userDataObj : userDataList) {
                Map<String, Object> userData = (Map<String, Object>) userDataObj;

                User user = new User();
                user.Email = (String) userData.get('email');
                user.FirstName = (String) userData.get('first_name');
                user.LastName = (String) userData.get('last_name');

                users.add(user);
            }
        }

        return users;
    }
}