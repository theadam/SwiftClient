# SwiftClient
A Simple HTTP Client written in Swift

## Installation
1. If you are using git then add Dollar as a submodule using `git submodule add https://github.com/theadam/SwiftClient.git` otherwise download the project using `git clone https://github.com/theadam/SwiftClient.git` in your project folder.
2. Open the SwiftClient folder. Drag SwiftClient.xcodeproj into the file navigator of your Xcode project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. In the tab bar at the top of that window, open the "Build Phases" panel.
5. Expand the "Link Binary with Libraries" group, and add SwiftClient.framework.
6. In your project file `import SwiftClient` and you can start using SwiftClient.

## Usage
### Basic Example

	var client = Client()
		.baseUrl("http://myapi.org")
		.onError({e in alertError(e)});
	
	// GET http://myapi.org/get?key=value&key2=value2
	client.get("/get")
		.query("key", "value")
		.query("key2", "value2")
		.set("header", "headerValue")
		.end({(res:Response) -> Void in
			if(res.ok) { // status of 2xx
				handleResponseJson(res.body)
			}
			else {
				handleErrorJson(res.body)
			}
		})

## Client
A Client is like a request factory.  Client objects use functions to create Request Objects.

`client.get(url)`

`client.post(url)`

`client.put(url)`

`client.patch(url)`

`client.delete(url)`

`client.head(url)`

### Middleware
Middleware can be used as plugins that affect every request created by a client.
    
    Client().use({(req:Request) -> Request in 
	    // perform actions on the request.
    })
### Base URL
Sets the base URL for any request which has a URL that starts with a "/"
	
	var client = Client().baseUrl("http://myapi.org");
	client.get("/endpoint").end(...);
### Response Transformer
Adds a function that affects every response retrieved from a clients requests.

	Client().transform({(res:Response) -> Response in 
		// perform actions on the response
	})
	
### Error Handler
Adds a default error handler for any request made with a client

	Client().onError({(err:NSError) -> Void in 
		// handle error
	})
## Request
### Setting headers
Headers can be set on the request by passing in a key and value or a dictionary of string to string.
	
	Client().get(url).set(key, value)

	
	Client().get(url).set([key : value, key2: value2])
	
### Middleware
Middleware can be used as plugins that affect a request.
    
    Client().get(url).use({(req:Request) -> Request in 
	    // perform actions on the request.
    })

### Response Transformer
Adds a function that affects the response retrieved from a request.

	Client().get(url).transform({(res:Response) -> Response in 
		// perform actions on the response
	})
	
### Setting the content type
The content type can be set using a short hand name (json, html, form, urlencoded, form, form-data, xml), or the full type (application/json for example).

	Client().get(url).type("json")
	
### Query Parameters
Query parameters can be added to the URL by passing in a key and value or a dictionary of string to string.

	Client().get(url).query(key, value)
	
	Client().get(url).query([key : value, key2: value2])
	
### Request Body
Data can be sent in the request body.  If the content type is set to "form" or "json", the request attempts to format the data to the appropriate format and send it.  A dictionary passed in defaults the type to JSON.

	Client.post(url).type("json").send([1,2,3,4]);

	Client.post(url).send([key : value, key2 : value2]);
	
	Client.post(url).type("form").send([key : value, key2 : value2]);
	
	Client.post(url).type("html").send("<html>").send("</html>");
	
### Request timeout interval
Sets the request's timeout interval.

	Client().get(url).timeout(timeoutInSeconds);	
### NSURLSessionDelegate
Sets the underlying NSURLSessionDelegate.

	Client().get(url).delegate(delegate);
	
### Handler Request Errors
Adds a error handler for a request.

	Client().get(url).onError({(err:NSError) -> Void in 
		// handle error
	})
	
### Performing the request
The request is performed and handled by passing in a response handler and an optional error handler.

	Client().get(url).end(responseHandler);
	
	Client().get(url).end(responseHandler, onError: errorHandler); // Overrides all other error handlers.

## Response
### Fields
`response.status` - The HTTP response status code.

`response.text` - An optional string containing the text of the body of the response.

`response.data` - An optional NSData object with the raw body data from the respnse.

`response.body` - An optional object with the parsed version of the response body (for JSON and form responses).

`response.headers` - A dictionary of string to string containing the headers of the response.

### status code helpers
Each of these booleans are helpers to determine the status of the Response

`info` -> 1xx

`ok` -> 2xx

`clientError` -> 4xx

`serverError` -> 5xx

`error` -> 4xx/5xx

`accepted` -> 202

`noContent` -> 404

`badRequest` -> 400

`unauthorized` -> 401

`notAcceptable` -> 406

`notFound` -> 404

`forbidden` -> 403
