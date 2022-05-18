#  Response validation

Janet automatically takes care of response validation. This does not include `URLError`s, which will be thrown as they occur. If, however, the server responds with a `HTTPURLResponse`, Janet will use a response interceptor to validate the status code. By default, all status codes in the range `200..<300` are accepted - for any other status code, a `NetworkManager.error.errorStatusCode(code: Int, response: HTTPResponse)` will be thrown.

To customise this, either create your own interceptor, or instantiate the `ValidateHTTPStatusResponseInterceptor(allowedStatusCodes: Range<Int>)` with a custom range parameter and plug it into your `NetworkManager`. For details on how to use interceptors, please check [here](Interception.md).
