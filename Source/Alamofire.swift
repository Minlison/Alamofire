//
//  Alamofire.swift
//
//  Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


/**
 *  函数参数说明：
 *  函数第一个参数，默认在调用时不显示参数名
 *  在参数名前加 `_` 目的是在调用时不显示参数名
 */

import Foundation

// MARK: - URLStringConvertible

/**
    Types adopting the `URLStringConvertible` protocol can be used to construct URL strings, which are then used to 
    construct URL requests.

    用来把URL, NSURLComponents, NSURLRequest转换成String类型的协议
*/

public protocol URLStringConvertible {
    /**
        A URL that conforms to RFC 2396.

        Methods accepting a `URLStringConvertible` type parameter parse it according to RFCs 1738 and 1808.

        See https://tools.ietf.org/html/rfc2396
        See https://tools.ietf.org/html/rfc1738
        See https://tools.ietf.org/html/rfc1808
    */
    var URLString: String { get }
}

// MARK: - String的扩展，添加URLString方法
extension String: URLStringConvertible {
    public var URLString: String {
        return self
    }
}

// MARK: - NSURL的扩展，添加URLString方法
extension NSURL: URLStringConvertible {
    public var URLString: String {
        return absoluteString
    }
}

// MARK: - NSURLComponents的扩展，添加URLString方法
extension NSURLComponents: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

// MARK: - NSURLRequest的扩展，添加URLString的方法
extension NSURLRequest: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

// MARK: - URLRequestConvertible

/**
    Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
    把不可变NSURLRequest 转换成可变 NSMutableURLRequest 协议, 协议中有一个只读属性 URLRequest
*/
public protocol URLRequestConvertible {
    /// The URL request.
    var URLRequest: NSMutableURLRequest { get }
}

// MARK: - 给NSURLRequest增加属性
extension NSURLRequest: URLRequestConvertible {
    public var URLRequest: NSMutableURLRequest {
        return self.mutableCopy() as! NSMutableURLRequest
    }
}

// MARK: - Convenience
/**
 快捷生URLRequest的方法

 - parameter method:    HTTP 请求类型
 - parameter URLString: HTTP 请求地址
 - parameter headers:   HTTP 请求的headers

 - returns: 可变的URLRequest
 */
func URLRequest(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil)
    -> NSMutableURLRequest
{
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
    mutableURLRequest.HTTPMethod = method.rawValue

    if let headers = headers {
        for (headerField, headerValue) in headers {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
    }

    return mutableURLRequest
}

// MARK: - Request Methods  创建Request的方法

/**
    Creates a request using the shared manager instance for the specified method, URL string, parameters, and
    parameter encoding.
    根据规定的方法，http请求地址，参数和参数编码格式，使用单例创建Request

    - parameter method:     The HTTP method.  HTTP 请求方法
    - parameter URLString:  The URL string.   HTTP 请求地址
    - parameter parameters: The parameters. `nil` by default.   请求参数
    - parameter encoding:   The parameter encoding. `.URL` by default.  参数的编码格式（URL(URL编码),URLEncodedInURL(URL编码),JSON(JSON字符串),PropertyList(属性列表),Custom(自定义)）
    - parameter headers:    The HTTP headers. `nil` by default. 请求头

    - returns: The created request.
*/
public func request(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil)
    -> Request
{
    /**
     调用单例类，创建请求的request
     */
    return Manager.sharedInstance.request(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers
    )
}

/**
    Creates a request using the shared manager instance for the specified URL request.
    根据规定的NSURLRequest创建 Request

    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    如果 startRequestsImmediately 是true (默认是true) 该请求会被在创建后立即发出
 
    - parameter URLRequest: The URL request
    URL请求

    - returns: The created request.
*/
public func request(URLRequest: URLRequestConvertible) -> Request {
    return Manager.sharedInstance.request(URLRequest.URLRequest)
}

// MARK: - Upload Methods  上传方法

// MARK: File  文件上传

/**
    Creates an upload request using the shared manager instance for the specified method, URL string, and file.
    根据指定的方法类型，url地址和文件地址（本地文件地址）使用单例创建上传的Request

    - parameter method:    The HTTP method.                     http方法
    - parameter URLString: The URL string.                      服务器接收文件的地址
    - parameter headers:   The HTTP headers. `nil` by default.  http请求头 默认为空
    - parameter file:      The file to upload.                  需要上传的文件地址（本地文件地址）

    - returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    file: NSURL)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, file: file)
}

/**
    Creates an upload request using the shared manager instance for the specified URL request and file.
    根据指定的NSURLRequest和文件地址（本地文件地址），使用单例创建上传的Request

    - parameter URLRequest: The URL request.        NSURLRequest
    - parameter file:       The file to upload.     文件地址（本地文件地址）

    - returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, file: NSURL) -> Request {
    return Manager.sharedInstance.upload(URLRequest, file: file)
}

// MARK: Data  二进制上传

/**
    Creates an upload request using the shared manager instance for the specified method, URL string, and data.
    根据指定的方法类型，url地址和二进制数据，使用单例创建上传的Request

    - parameter method:    The HTTP method.                     http方法
    - parameter URLString: The URL string.                      服务器接收文件的地址
    - parameter headers:   The HTTP headers. `nil` by default.  http请求头 默认为空
    - parameter data:      The data to upload.                  需要上传的二进制数据（NSData）

    - returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    data: NSData)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, data: data)
}

/**
    Creates an upload request using the shared manager instance for the specified URL request and data.
    根据指定的NSURLRequest，和需要上传的二进制数据使用单例创建上传Request

    - parameter URLRequest: The URL request.        服务器接收文件的地址
    - parameter data:       The data to upload.     需要上传的二进制数据

    - returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, data: NSData) -> Request {
    return Manager.sharedInstance.upload(URLRequest, data: data)
}

// MARK: Stream  使用文件流上传

/**
    Creates an upload request using the shared manager instance for the specified method, URL string, and stream.
    根据指定的http方法，url地址，和文件输入流使用单例创建Request

    - parameter method:    The HTTP method.                     http方法
    - parameter URLString: The URL string.                      服务器接收文件的地址
    - parameter headers:   The HTTP headers. `nil` by default.  http请求头 默认为空
    - parameter stream:    The stream to upload.                需要上传的文件输入流

    - returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    stream: NSInputStream)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, stream: stream)
}

/**
    Creates an upload request using the shared manager instance for the specified URL request and stream.
    根据指定的NSURLRequest和文件输入流使用单例创建Request

    - parameter URLRequest: The URL request.        NSURLRequest
    - parameter stream:     The stream to upload.   需要上传的文件输入流

    - returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, stream: NSInputStream) -> Request {
    return Manager.sharedInstance.upload(URLRequest, stream: stream)
}

// MARK: MultipartFormData  在http body中指定参数拼接二进制数据上传

/**
    Creates an upload request using the shared manager instance for the specified method and URL string.
    根据指定的http请求方法，url地址，http请求头等创建Request

    - parameter method:                  The HTTP method.                                                       http请求方法
    - parameter URLString:               The URL string.                                                        url地址
    - parameter headers:                 The HTTP headers. `nil` by default.                                    http请求头，默认为空
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.      拼接的数据
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.                                拼接的二进制数据内存占用大小
                                         `MultipartFormDataEncodingMemoryThreshold` by default.                 (默认 10 * 1024 *1024)
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.  完成回调
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        method,
        URLString,
        headers: headers,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

/**
    Creates an upload request using the shared manager instance for the specified method and URL string.
    根据NSURLRequest和拼接的数据，使用单例创建Request

    - parameter URLRequest:              The URL request.                                                       NSURLRequest
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.      拼接的数据
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.                                拼接的二进制数据内存占用大小
                                         `MultipartFormDataEncodingMemoryThreshold` by default.                 (默认 10 * 1024 *1024)
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.  完成回调
*/
public func upload(
    URLRequest: URLRequestConvertible,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        URLRequest,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

// MARK: - Download Methods  下载方法

// MARK: URL Request  NSURLRequest

/**
    Creates a download request using the shared manager instance for the specified method and URL string.
    使用指定的http请求方法和url地址创建Request

    - parameter method:      The HTTP method.                                                           http请求方法
    - parameter URLString:   The URL string.                                                            url地址
    - parameter parameters:  The parameters. `nil` by default.                                          参数
    - parameter encoding:    The parameter encoding. `.URL` by default.                                 参数的编码格式（URL(URL编码),URLEncodedInURL(URL编码),JSON(JSON字符
                                                                                                        串),PropertyList(属性列表),Custom(自定义)）
    - parameter headers:     The HTTP headers. `nil` by default.                                        http请求头，默认为nil
    - parameter destination: The closure used to determine the destination of the downloaded file.      下载文件的存放地址

    - returns: The created download request.
*/
public func download(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil,
    destination: Request.DownloadFileDestination)
    -> Request
{
    return Manager.sharedInstance.download(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers,
        destination: destination
    )
}

/**
    Creates a download request using the shared manager instance for the specified URL request.
    根据NSURLRequest使用单例创建下载的Request

    - parameter URLRequest:  The URL request.                                                       NSURLRequest
    - parameter destination: The closure used to determine the destination of the downloaded file.  下载文件地址

    - returns: The created download request.
*/
public func download(URLRequest: URLRequestConvertible, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(URLRequest, destination: destination)
}

// MARK: Resume Data 断点续传

/**
    Creates a request using the shared manager instance for downloading from the resume data produced from a 
    previous request cancellation.
    根据resumeData和文件存放地址创建Request

    - parameter resumeData:  The resume data. This is an opaque data blob produced by `NSURLSessionDownloadTask`
                             when a task is cancelled. See `NSURLSession -downloadTaskWithResumeData:` for additional 
                             information.
                            resume data 是 NSURLSessionDownloadTask cancel是回传的一个二进制数据，实际是一个plist文件，保存着下载信息
    - parameter destination: The closure used to determine the destination of the downloaded file. 一个闭包，返回下载文件保存地址

    - returns: The created download request.
*/
public func download(resumeData data: NSData, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(data, destination: destination)
}
