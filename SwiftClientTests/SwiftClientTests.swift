//
//  SwiftClientTests.swift
//  SwiftClientTests
//
//  Created by Adam Nalisnick on 10/25/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import XCTest
import SwiftClient

class SwiftClientTests: XCTestCase {
    
    private func wait(){
        waitForExpectationsWithTimeout(5, handler: { error in
            if error != nil {
                print("test timed out with error \(error)");
            }
        });
    }
    
    var expectation:XCTestExpectation!;
    
    var defaultError:((NSError) -> Void)!;
    
    var shouldNotSucceed:((Response) -> Void)!;
    
    var request:Client!;

    override func setUp(){
        super.setUp();
        expectation = expectationWithDescription("request");
        
        defaultError = {(err:NSError) -> Void in
            XCTFail("Request should succeed.  Failed with error \(err)");
            self.expectation.fulfill();
        }
        
        shouldNotSucceed = {(res:Response) -> Void in
            XCTFail("Request should not succeed");
            self.expectation.fulfill();
        }
        
        request = Client().baseUrl("http://httpbin.org");
    }
    
    func testHeadersFromDictionary(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as! String, "headerValue", "header should have been sent");
            self.expectation.fulfill();
        }
        request.get("/headers")
            .set(["x-header-key": "headerValue"])
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testHeadersFromKeyValue(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as! String, "headerValue", "header should have been sent");
            self.expectation.fulfill();
        }
        request.get("/headers")
            .set("x-header-key", "headerValue")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testHeadersMixture(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as! String, "headerValue", "header should have been sent");
            XCTAssertEqual(json["headers"]["X-Header-Key2"].value as! String, "headerValue2", "header should have been sent");
            self.expectation.fulfill();
        }
        request.get("/headers")
            .set("x-header-key", "headerValue")
            .set(["x-header-key2": "headerValue2"])

            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testRequestMiddleware(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as! String, "headerValue", "header should have been sent");
            self.expectation.fulfill();
        }
        request.get("/headers")
            .use({$0.set("x-header-key", "headerValue")})
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testResponseMiddleware(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = res.body as! Body;
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["X-Header-Key"].value as! String, "headerValue", "header should have been sent");
            self.expectation.fulfill();
        }
        request.get("/headers")
            .set("x-header-key", "headerValue")
            .transform({r in r.body = Body(r.body); return r;})
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testType(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = res.body as! Body;
            // the service capitalizes the headers ....
            XCTAssertEqual(json["headers"]["Content-Type"].value as! String, "application/json", "header should have been sent");
            self.expectation.fulfill();
        }
        request.get("/headers")
            .type("json")
            .transform({r in r.body = Body(r.body); return r;})
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testGetHeader(){
        var r = request.get("/headers")
            .type("json");
        
        XCTAssertEqual(r.getHeader("content-TYPE")!, "application/json", "headers should match");
        self.expectation.fulfill();
        wait();
    }
    
    func testQueryAsDictionary(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            XCTAssertEqual(json["args"]["this has some spaces"].value! as! String, "this does too", "query arguments should match");
            self.expectation.fulfill();
        }
        request.get("/get")
            .query(["this has some spaces": "this does too"])
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testQueryAsKeyValue(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            XCTAssertEqual(json["args"]["key"].value! as! String, "value", "query arguments should match");
            self.expectation.fulfill();
        }
        request.get("/get")
            .query("key=value")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testQueryMixture(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            XCTAssertEqual(json["args"]["key"].value! as! String, "value", "query arguments should match");
            XCTAssertEqual(json["args"]["this has some spaces"].value! as! String, "this does too", "query arguments should match");
            XCTAssertEqual(json["args"]["withParam"].value! as! String, "5", "query arguments should match");
            self.expectation.fulfill();
        }
        request.get("/get?withParam=5")
            .query("key=value")
            .query(["this has some spaces": "this does too"])
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testSendDictionary(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            XCTAssertEqual(json["json"]["key"].value! as! String, "value", "json should be equal");
            XCTAssertEqual(json["json"]["key2"].value! as! String, "value2", "json should be equal");
            self.expectation.fulfill();
        }
        request.post("/post")
            .send(["key": "value"])
            .send(["key2": "value2"])
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testSendString(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let form = Body(res.body);
            XCTAssertEqual(form["form"]["key"].value! as! String, "value", "json should be equal");
            XCTAssertEqual(form["form"]["key2"].value! as! String, "value2", "json should be equal");
            self.expectation.fulfill();
        }
        request.post("/post")
            .send("key=value")
            .send("key2=value2")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testSendStringNoForm(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let content = Body(res.body);
            XCTAssertEqual(content["data"].value! as! String, "<html></html>", "html should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
            .type("html")
            .send("<html>")
            .send("</html>")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testSendOther(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let content = Body(res.body);
            XCTAssertEqual(content["json"].value! as! [Int], [1,2,3,4,5,6], "array should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
            .type("json")
            .send([1,2,3,4,5,6])
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testBaseUrlOverride(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            self.expectation.fulfill();
        }
        request.get("http://httpbin.org/headers")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testErrorHandlerOnClient(){
        let onError1 = { (err: NSError) -> Void in
            self.expectation.fulfill();
        }
        request = request.onError(onError1);
        request.get("http://badurl.example.com")
            .end(self.shouldNotSucceed);
        wait();
    }
    
    func testErrorHandlerChained(){
        let onError1 = { (err: NSError) -> Void in
            XCTFail("first error handler should be overriden")
            self.expectation.fulfill();
        }
        let onError2 = { (err: NSError) -> Void in
            self.expectation.fulfill();
        }
        request = request.onError(onError1);
        
        request.get("http://badurl.example.com")
            .onError(onError2)
            .end(self.shouldNotSucceed);
        wait();
    }
    
    func testErrorHandlerInEnd(){
        let onError1 = { (err: NSError) -> Void in
            XCTFail("first error handler should be overriden")
            self.expectation.fulfill();
        }
        let onError2 = { (err: NSError) -> Void in
            XCTFail("second error handler should be overriden")
            self.expectation.fulfill();
        }
        let onError3 = { (err: NSError) -> Void in
            self.expectation.fulfill();
        }
        request = request.onError(onError1);
        
        request.get("http://badurl.example.com")
            .onError(onError2)
        .end(self.shouldNotSucceed, onError: onError3);
        wait();
    }
    
    func testAuth(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let json = Body(res.body);
            XCTAssertEqual(json["authenticated"].value as! Int, 1, "authenticated should be equal to 1")
            XCTAssertEqual(json["user"].value as! String, "username", "user should be equal to 1")
            print(json);
            self.expectation.fulfill();
        }
        request.get("/hidden-basic-auth/username/password")
            .auth("username", "password")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartFields(){
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let form = Body(res.body)["form"];
            XCTAssertEqual(form["key"].value as! String, "value", "form data should have been sent");
            XCTAssertEqual(form["key2"].value as! String, "value2", "form data should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
            .field("key", "value")
            .field("key2", "value2")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartFiles(){
        var htmlString1 = "<html><body>1</body></html>";
        var htmlString2 = "<html><body>2</body></html>";
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let files = Body(res.body)["files"];
            XCTAssertEqual(files["file1"].value as! String, htmlString1, "form data should have been sent");
            XCTAssertEqual(files["file2"].value as! String, htmlString2, "form data should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
            .attach("file1", htmlString1.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, "file1.html")
            .attach("file2", htmlString2.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, "file2.html")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartMixed(){
        var htmlString1 = "<html><body>1</body></html>";
        var htmlString2 = "<html><body>2</body></html>";
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let files = Body(res.body)["files"];
            XCTAssertEqual(files["file1"].value as! String, htmlString1, "form data should have been sent");
            XCTAssertEqual(files["file2"].value as! String, htmlString2, "form data should have been sent");
            let form = Body(res.body)["form"];
            XCTAssertEqual(form["key"].value as! String, "value", "form data should have been sent");
            XCTAssertEqual(form["key2"].value as! String, "value2", "form data should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
            .attach("file1", htmlString1.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, "file1.html")
            .attach("file2", htmlString2.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, "file2.html")
            .field("key", "value")
            .field("key2", "value2")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartFilesWithMime(){
        var htmlString1 = "<html><body>1</body></html>";
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let files = Body(res.body)["files"];
            XCTAssertEqual(files["file1"].value as! String, htmlString1, "form data should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
        .attach("file1", htmlString1.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, "file1.html", withMimeType: "text/html")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartPathFilesNoFileName(){
        var filePath:String = NSBundle(forClass: self.classForCoder).pathForResource("test", ofType: "html")!;
        var fileContents = NSString(data: NSData(contentsOfFile: filePath)!, encoding: NSUTF8StringEncoding)!;
        
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let files = Body(res.body)["files"];
            XCTAssertEqual(files["file1"].value as! NSString, fileContents, "form data should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
            .attach("file1", filePath)
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartPathFilesNoMimeType(){
        var filePath:String = NSBundle(forClass: self.classForCoder).pathForResource("test", ofType: "html")!;
        var fileContents = NSString(data: NSData(contentsOfFile: filePath)!, encoding: NSUTF8StringEncoding)!;
        
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let files = Body(res.body)["files"];
            XCTAssertEqual(files["file1"].value as! NSString, fileContents, "form data should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
            .attach("file1", filePath, "notTest.html")
            .end(done, onError: self.defaultError);
        wait();
    }
    
    func testMultipartPathFilesMimeType(){
        var filePath:String = NSBundle(forClass: self.classForCoder).pathForResource("test", ofType: "html")!;
        var fileContents = NSString(data: NSData(contentsOfFile: filePath)!, encoding: NSUTF8StringEncoding)!;
        
        let done = { (res: Response) -> Void in
            XCTAssertEqual(res.status, Response.ResponseType.OK);
            let files = Body(res.body)["files"];
            XCTAssertEqual(files["file1"].value as! NSString, fileContents, "form data should have been sent");
            self.expectation.fulfill();
        }
        request.post("/post")
        .attach("file1", filePath, "notTest.html", withMimeType: "text/html")
            .end(done, onError: self.defaultError);
        wait();
    }
    
}

