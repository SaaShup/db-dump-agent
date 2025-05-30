$version: "2.0"

namespace saashup

use aws.protocols#restJson1

@restJson1
@title("DB Dump Agent")
service DbDumpAgent {
    version: "1.0.0"
    resources: [
        Host
    ]
    errors: [
        ServiceError
    ]
}
