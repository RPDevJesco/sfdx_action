/**
 * Created by Jesse Glover on 7/25/2023.
 * Utilizes https://reqres.in/ as the api for testing.
 */

@isTest
private class MockHttpCalloutTest {
    @isTest
    static void HttpCalloutTest() {
        // Create an instance of the MockHttpResponse class
        MockHttpCallout mockResponse = new MockHttpCallout();

        // Prepare the mock response data as a JSON object
        Map<String, Object> responseBody = new Map<String, Object>{
                'page' => 2,
                'per_page' => 6,
                'total' => 12,
                'total_pages' => 2,
                'data' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'id' => 7,
                                'email' => 'michael.lawson@reqres.in',
                                'first_name' => 'Michael',
                                'last_name' => 'Lawson',
                                'avatar' => 'https://reqres.in/img/faces/7-image.jpg'
                        },
                        new Map<String, Object>{
                                'id' => 8,
                                'email' => 'lindsay.ferguson@reqres.in',
                                'first_name' => 'Lindsay',
                                'last_name' => 'Ferguson',
                                'avatar' => 'https://reqres.in/img/faces/8-image.jpg'
                        },
                        new Map<String, Object>{
                                'id' => 9,
                                'email' => 'tobias.funke@reqres.in',
                                'first_name' => 'Tobias',
                                'last_name' => 'Funke',
                                'avatar' => 'https://reqres.in/img/faces/9-image.jpg'
                        },
                        new Map<String, Object>{
                                'id' => 10,
                                'email' => 'byron.fields@reqres.in',
                                'first_name' => 'Byron',
                                'last_name' => 'Fields',
                                'avatar' => 'https://reqres.in/img/faces/10-image.jpg'
                        },
                        new Map<String, Object>{
                                'id' => 11,
                                'email' => 'george.edwards@reqres.in',
                                'first_name' => 'George',
                                'last_name' => 'Edwards',
                                'avatar' => 'https://reqres.in/img/faces/11-image.jpg'
                        },
                        new Map<String, Object>{
                                'id' => 12,
                                'email' => 'rachel.howell@reqres.in',
                                'first_name' => 'Rachel',
                                'last_name' => 'Howell',
                                'avatar' => 'https://reqres.in/img/faces/12-image.jpg'
                        }
                },
                'support' => new Map<String, Object>{
                        'url' => 'https://reqres.in/#support-heading',
                        'text' => 'To keep ReqRes free, contributions towards server costs are appreciated!'
                }
        };

        // Convert the JSON object to a JSON string
        String responseBodyString = JSON.serialize(responseBody);

        // Create the mock HTTP response
        HttpResponse sampleResponse = new HttpResponse();
        sampleResponse.setHeader('Content-Type', 'application/json');
        sampleResponse.setBody(responseBodyString);
        sampleResponse.setStatusCode(200);

        // Add the mock response to the MockHttpResponse instance
        mockResponse.addHttpResponse('https://reqres.in/api/users?page=2', sampleResponse);

        // Set the test to use the mock response
        Test.setMock(HttpCalloutMock.class, mockResponse);

        // Now, call the method that makes the HTTP callout in your actual class
        // For example:
         List<User> users = HttpCallout.getUsers(2);

        System.assertEquals(6, users.size());
        System.assertEquals('michael.lawson@reqres.in', users[0].Email);
        System.assertEquals('Michael', users[0].FirstName);
        System.assertEquals('Lawson', users[0].LastName);
    }

    @isTest
    static void HttpCalloutTest_MockResponseNotFound() {
        // Create an instance of the MockHttpCallout class
        MockHttpCallout mockResponse = new MockHttpCallout();

        // Set the test to use the mock response, but without adding any specific mock response
        Test.setMock(HttpCalloutMock.class, mockResponse);

        // Now, call the method that makes the HTTP callout in your actual class
        List<User> users = HttpCallout.getUsers(2);

        // Since there is no specific mock response, the default 404 response should be returned
        System.assertEquals(0, users.size());

        // Get the last response sent by the mocked Http.send() method
        HttpResponse lastResponse = mockResponse.respond(new HttpRequest());

        // Check if the default 404 response message is correct
        System.assertEquals('{"message": "Mock response not found."}', lastResponse.getBody());
        System.assertEquals(404, lastResponse.getStatusCode());
    }
}