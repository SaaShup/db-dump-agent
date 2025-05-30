$version: "2.0"

namespace saashup

@error("client")
@httpError(404)
structure NoSuchResource {
    @required
    code: Integer

    @required
    message: String
}

@error("client")
@httpError(400)
structure BadRequest {
    @required
    code: Integer

    @required
    message: String
}

@error("server")
@httpError(500)
structure ServiceError {
    @required
    code: Integer = 500

    @required
    message: String = "Internal Server Error"
}
