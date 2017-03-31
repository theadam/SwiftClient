//
//  SwiftClientTests.swift
//  SwiftClientTests
//
//  Created by Adam Nalisnick on 10/25/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import XCTest
@testable import SwiftClient


class SwiftClientTests: XCTestCase {
    private func wait(){
        waitForExpectations(timeout: 5, handler: { error in
            if error != nil {
                print("test timed out with error \(error)");
            }
        });
    }
    
    var globalExpectation:XCTestExpectation!;
    
    var defaultError:((Error) -> Void)!;
    
    var shouldNotSucceed:((Response) -> Void)!;
    
    var request:Client!;

    override func setUp(){
        super.setUp();
        self.globalExpectation = expectation(description: "request");
        
        defaultError = {(err:Error) -> Void in
            XCTFail("Request should succeed.  Failed with error \(err)");
            self.globalExpectation.fulfill();
        }
        
        shouldNotSucceed = {(res:Response) -> Void in
            XCTFail("Request should not succeed");
            self.globalExpectation.fulfill();
        }
        
        request = Client().baseUrl(url: "http://httpbin.org");
    }
    
    func testHeadersFromDictionary(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as? String, "headerValue", "header should have been sent");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/headers")
            .set(headers: ["x-header-key": "headerValue"])
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testHeadersFromKeyValue(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as? String, "headerValue", "header should have been sent");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/headers")
            .set(key: "x-header-key", value: "headerValue")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testHeadersMixture(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as? String, "headerValue", "header should have been sent");
            XCTAssertEqual(json["headers"]["X-Header-Key2"].value as? String, "headerValue2", "header should have been sent");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/headers")
            .set(key: "x-header-key", value: "headerValue")
            .set(headers: ["x-header-key2": "headerValue2"])

            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testRequestMiddleware(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as? String, "headerValue", "header should have been sent");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/headers")
            .use(middleware: {$0.set(key: "x-header-key", value: "headerValue")})
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testResponseMiddleware(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = res.body as! Body;
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as? String, "headerValue", "header should have been sent");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/headers")
            .set(key: "x-header-key", value: "headerValue")
            .transform(transformer: {r in r.body = Body(rawValue: r.body); return r;})
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testType(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = res.body as! Body;
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["Content-Type"].value as? String, "application/json", "header should have been sent");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/headers")
            .type(type: "json")
            .transform(transformer: {r in r.body = Body(rawValue: r.body); return r;})
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testGetHeader(){
        let r = request.get(url: "/headers")
            .type(type: "json");
        
        XCTAssertEqual(r.getHeader(header: "content-TYPE")!, "application/json", "headers should match");
        self.globalExpectation.fulfill();
        wait();
    }
    
    func testQueryAsDictionary(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            XCTAssertEqual(json["args"]["this has some spaces"].value! as? String, "this does too", "query arguments should match");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/get")
            .query(query: ["this has some spaces": "this does too"])
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testQueryAsKeyValue(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            XCTAssertEqual(json["args"]["key"].value! as? String, "value", "query arguments should match");
            XCTAssertEqual(json["args"]["key2"].value! as? String, "value+", "query arguments should match");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/get")
            .query(query: "key=value")
            .query(query: "key2=value+")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testQueryMixture(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            XCTAssertEqual(json["args"]["key"].value! as? String, "value", "query arguments should match");
            XCTAssertEqual(json["args"]["this has some spaces"].value! as? String, "this does too", "query arguments should match");
            XCTAssertEqual(json["args"]["withParam"].value! as? String, "5", "query arguments should match");
            self.globalExpectation.fulfill();
        }
        request.get(url: "/get?withParam=5")
            .query(query: "key=value")
            .query(query: ["this has some spaces": "this does too"])
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testSendDictionary(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            XCTAssertEqual(json["json"]["key"].value! as? String, "value", "json should be equal");
            XCTAssertEqual(json["json"]["key2"].value! as? String, "value2", "json should be equal");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .send(data: ["key": "value"])
            .send(data: ["key2": "value2"])
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testSendString(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let form = Body(rawValue: res.body);
            XCTAssertEqual(form["form"]["key"].value! as? String, "value", "json should be equal");
            XCTAssertEqual(form["form"]["key2"].value! as? String, "value2", "json should be equal");
            XCTAssertEqual(form["form"]["key3"].value! as? String, "+foo+", "json should be equal");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .send(data: "key=value")
            .send(data: "key2=value2")
            .send(data: "key3=+foo+")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testSendStringNoForm(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let content = Body(rawValue: res.body);
            XCTAssertEqual(content["data"].value! as? String, "<html></html>", "html should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .type(type: "html")
            .send(data: "<html>")
            .send(data: "</html>")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testSendOther(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let content = Body(rawValue: res.body);
            XCTAssertEqual(content["json"].value! as! [Int], [1,2,3,4,5,6], "array should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .type(type: "json")
            .send(data: [1,2,3,4,5,6])
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testBaseUrlOverride(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            self.globalExpectation.fulfill();
        }
        request.get(url: "http://httpbin.org/headers")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testErrorHandlerOnClient(){
        let onError1 = { (err: Error) -> Void in
            self.globalExpectation.fulfill();
        }
        request = request.onError(errorHandler: onError1);
        request.get(url: "http://badurl.example.com")
            .end(done: self.shouldNotSucceed);
        wait();
    }
    
    func testErrorHandlerChained(){
        let onError1 = { (err: Error) -> Void in
            XCTFail("first error handler should be overriden")
            self.globalExpectation.fulfill();
        }
        let onError2 = { (err: Error) -> Void in
            self.globalExpectation.fulfill();
        }
        request = request.onError(errorHandler: onError1);
        
        request.get(url: "http://badurl.example.com")
            .onError(errorHandler: onError2)
            .end(done: self.shouldNotSucceed);
        wait();
    }
    
    func testErrorHandlerInEnd(){
        let onError1 = { (err: Error) -> Void in
            XCTFail("first error handler should be overriden")
            self.globalExpectation.fulfill();
        }
        let onError2 = { (err: Error) -> Void in
            XCTFail("second error handler should be overriden")
            self.globalExpectation.fulfill();
        }
        let onError3 = { (err: Error) -> Void in
            self.globalExpectation.fulfill();
        }
        request = request.onError(errorHandler: onError1);
        
        request.get(url: "http://badurl.example.com")
            .onError(errorHandler: onError2)
        .end(done: self.shouldNotSucceed, onError: onError3);
        wait();
    }
    
    func testAuth(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let json = Body(rawValue: res.body);
            XCTAssertTrue(json["authenticated"].value as! Bool, "authenticated should be equal to true")
            XCTAssertEqual(json["user"].value as? String, "username", "user should be equal to username")
            self.globalExpectation.fulfill();
        }
        request.get(url: "/hidden-basic-auth/username/password")
            .auth(username: "username", password: "password")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartFields(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let form = Body(rawValue: res.body)["form"];
            XCTAssertEqual(form["key"].value as? String, "value", "form data should have been sent");
            XCTAssertEqual(form["key2"].value as? String, "value2", "form data should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .field(name: "key", value: "value")
            .field(name: "key2", value: "value2")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartFiles(){
        let htmlString1 = "<html><body>1</body></html>";
        let htmlString2 = "<html><body>2</body></html>";
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let files = Body(rawValue: res.body)["files"];
            XCTAssertEqual(files["file1"].value as? String, htmlString1, "form data should have been sent");
            XCTAssertEqual(files["file2"].value as? String, htmlString2, "form data should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .attach(name: "file1", data: htmlString1.data(using: String.Encoding.utf8, allowLossyConversion: true)!, filename: "file1.html")
            .attach(name: "file2", data: htmlString2.data(using: String.Encoding.utf8, allowLossyConversion: true)!, filename: "file2.html")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartMixed(){
        let htmlString1 = "<html><body>1</body></html>";
        let htmlString2 = "<html><body>2</body></html>";
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let files = Body(rawValue: res.body)["files"];
            XCTAssertEqual(files["file1"].value as? String, htmlString1, "form data should have been sent");
            XCTAssertEqual(files["file2"].value as? String, htmlString2, "form data should have been sent");
            let form = Body(rawValue: res.body)["form"];
            XCTAssertEqual(form["key"].value as? String, "value", "form data should have been sent");
            XCTAssertEqual(form["key2"].value as? String, "value2", "form data should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .attach(name: "file1", data: htmlString1.data(using: String.Encoding.utf8, allowLossyConversion: true)!, filename: "file1.html")
            .attach(name: "file2", data: htmlString2.data(using: String.Encoding.utf8, allowLossyConversion: true)!, filename: "file2.html")
            .field(name: "key", value: "value")
            .field(name: "key2", value: "value2")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartFilesWithMime(){
        let htmlString1 = "<html><body>1</body></html>";
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let files = Body(rawValue: res.body)["files"];
            XCTAssertEqual(files["file1"].value as? String, htmlString1, "form data should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .attach(name: "file1", data: htmlString1.data(using: String.Encoding.utf8, allowLossyConversion: true)!, filename: "file1.html", withMimeType: "text/html")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartPathFilesNoFileName(){
        let filePath:String = Bundle(for: self.classForCoder).path(forResource: "test", ofType: "html")!;
        let fileContents = NSString(data: try! Data(contentsOf: URL(fileURLWithPath: filePath)), encoding: String.Encoding.utf8.rawValue)!;
        
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let files = Body(rawValue: res.body)["files"];
            XCTAssertEqual(files["file1"].value as? NSString, fileContents, "form data should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .attach(name: "file1", path: filePath)
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartPathFilesNoMimeType(){
        let filePath:String = Bundle(for: self.classForCoder).path(forResource: "test", ofType: "html")!;
        let fileContents = NSString(data: try! Data(contentsOf: URL(fileURLWithPath: filePath)), encoding: String.Encoding.utf8.rawValue)!;
        
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let files = Body(rawValue: res.body)["files"];
            XCTAssertEqual(files["file1"].value as? NSString, fileContents, "form data should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .attach(name: "file1", path: filePath, filename: "notTest.html")
            .end(done: done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartPathFilesMimeType(){
        let filePath:String = Bundle(for: self.classForCoder).path(forResource: "test", ofType: "html")!;
        let fileContents = NSString(data: try! Data(contentsOf: URL(fileURLWithPath: filePath)), encoding: String.Encoding.utf8.rawValue)!;
        
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.ok);
            let files = Body(rawValue: res.body)["files"];
            XCTAssertEqual(files["file1"].value as? NSString, fileContents, "form data should have been sent");
            self.globalExpectation.fulfill();
        }
        request.post(url: "/post")
            .attach(name: "file1", path: filePath, filename: "notTest.html", withMimeType: "text/html")
            .end(done: done, onError: self.defaultError);
        wait();
    }

    func testBasicResponseTypeCodes(){
        let basicResponseCodes: [Int : Response.BasicResponseType] = [1: Response.BasicResponseType.info,
            2: Response.BasicResponseType.ok,
            3: Response.BasicResponseType.redirection,
            4: Response.BasicResponseType.clientError,
            5: Response.BasicResponseType.serverError]
        
        for code in basicResponseCodes {
            
            /// The first iteration should fulfill the setUp() expectation.
            let basicResponseCodesKeys = basicResponseCodes.keys

            if (basicResponseCodesKeys.first != code.key) {
                self.globalExpectation = expectation(description: String(format: "BasicResponseType Code: %i", code.0));
            }
//            if (Array(basicResponseCodes.keys)[0] != code.0){
            
                /// Create new expectations for the other ResponseType codes.
//                expectation = self.globalExpectation(withDescription: String(format: "BasicResponseType Code: %i", code.0))
//            }
            
            let done = { (res: Response) -> Void in
                XCTAssertEqual(res.basicStatus, code.1);
                self.globalExpectation.fulfill()
            }
            
            request.get(url: "/basicResponseTypeCodes")
                .transform(transformer: { (response: Response) -> Response in
                    let mockResponse = HTTPURLResponse(url: URL(fileURLWithPath: "foobar"), statusCode: (code.0*100), httpVersion: "foo", headerFields: nil)
                    let mockRequest = Request(method: "foo", url: "bar", errorHandler: {(error: Error) -> Void in})
                    
                    return Response(response: mockResponse!, request: mockRequest, rawData: nil)
                })
                .end(done: done, onError: self.defaultError);
            
            wait();
        }
    }
    
    func testResponseTypeCodes(){
        let responseCodes: [Int : Response.ResponseType] = [200: Response.ResponseType.ok,
            201: Response.ResponseType.created,
            202: Response.ResponseType.accepted,
            203: Response.ResponseType.nonAuthoritativeInfo,
            204: Response.ResponseType.noContent,
            205: Response.ResponseType.resetContent,
            206: Response.ResponseType.partialContent,
            207: Response.ResponseType.multiStatus,
            300: Response.ResponseType.multipleChoices,
            301: Response.ResponseType.movedPermanently,
            302: Response.ResponseType.found,
            303: Response.ResponseType.seeOther,
            304: Response.ResponseType.notModified,
            305: Response.ResponseType.useProxy,
            307: Response.ResponseType.temporaryRedirect,
            400: Response.ResponseType.badRequest,
            401: Response.ResponseType.unauthorized,
            402: Response.ResponseType.paymentRequired,
            403: Response.ResponseType.forbidden,
            404: Response.ResponseType.notFound,
            405: Response.ResponseType.methodNotAllowed,
            406: Response.ResponseType.notAcceptable,
            407: Response.ResponseType.proxyAuthentication,
            408: Response.ResponseType.requestTimeout,
            409: Response.ResponseType.conflict,
            410: Response.ResponseType.gone,
            411: Response.ResponseType.lengthRequired,
            412: Response.ResponseType.preConditionFail,
            413: Response.ResponseType.requestEntityTooLarge,
            414: Response.ResponseType.requestURITooLong,
            415: Response.ResponseType.unsupportedMediaType,
            416: Response.ResponseType.requestedRangeNotSatisfiable,
            417: Response.ResponseType.expectationFailed,
            419: Response.ResponseType.authenticationTimeout,
            429: Response.ResponseType.tooManyRequests,
            500: Response.ResponseType.internalServerError,
            501: Response.ResponseType.notImplemented,
            502: Response.ResponseType.badGateway,
            503: Response.ResponseType.serviceUnavailable,
            504: Response.ResponseType.gatewayTimeout,
            505: Response.ResponseType.httpVersionNotSupported]
        
        for code in responseCodes {
            let responseCodesKeys = responseCodes.keys
            
            if (responseCodesKeys.first != code.key) {
                self.globalExpectation = expectation(description: String(format: "ResponseType Code: %i", code.0));
            }
            
            let done = { (res: Response) -> Void in
                XCTAssertEqual(res.statusCode, code.0)
                XCTAssertEqual(res.status, code.1);
                self.globalExpectation.fulfill()
            }
            
            request.get(url: "/responseTypeCodes")
                .transform(transformer: { (response: Response) -> Response in
                    let mockResponse = HTTPURLResponse(url: URL(fileURLWithPath: "foobar"), statusCode: code.0, httpVersion: "foo", headerFields: nil)
                    let mockRequest = Request(method: "foo", url: "bar", errorHandler: {(error: Error) -> Void in})
                    
                    return Response(response: mockResponse!, request: mockRequest, rawData: nil)
                })
                .end(done: done, onError: self.defaultError);
            
            wait();
        }
    }
    
}
