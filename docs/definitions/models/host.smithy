$version: "2.0"

namespace saashup

resource Host {
    identifiers: {
        host_id: HostId
    }
    properties: {
        type: HostType
        host: HostName
        port: TcpPort
        db: Db
        user: User
        password: Password
        version: Version
    }
    create: CreateHost
    read: GetHost
    update: UpdateHost
    delete: DeleteHost
    list: ListHosts
    operations: [
        UploadDump
    ]
    resources: [
        Dump
    ]
}

@tags(["Host"])
@http(method: "POST", uri: "/api/hosts", code: 201)
@documentation("Create a new Host and test the connection in order to get the server version.")
@examples([
    {
        title: "Create a Host"
        input: { type: "postgresql", host: "postgres-15", port: 5432, db: "mydb", user: "me", password: "password" }
        output: { host_id: "Nny3tUFGL7", version: "15.12" }
    }
    {
        title: "Unable to get host version"
        input: { type: "postgresql", host: "postgres-15", port: 5432, db: "mydb", user: "me", password: "password" }
        error: {
            shapeId: ServiceError
            content: { code: 500, message: "Unable to get host version" }
        }
    }
])
operation CreateHost {
    input := for Host {
        @required
        $type

        @required
        $host

        $port = 5432

        @required
        $db

        @required
        $user

        @required
        $password
    }

    output := for Host {
        @required
        $host_id

        @required
        $version
    }
}

@tags(["Host"])
@readonly
@http(method: "GET", uri: "/api/hosts/{host_id}", code: 200)
@documentation("Get a stored Host by its UUID.")
@examples([
    {
        title: "Get a Host"
        input: { host_id: "Nny3tUFGL7" }
        output: { host_id: "Nny3tUFGL7", type: "postgresql", host: "postgres-15", port: 5432, db: "mydb", user: "me", password: "password", version: "15.12" }
    }
    {
        title: "Host not found"
        input: { host_id: "IUxvYDwQV5" }
        error: {
            shapeId: NoSuchResource
            content: { code: 404, message: "Host not found" }
        }
    }
])
operation GetHost {
    input := for Host {
        @required
        @httpLabel
        $host_id
    }

    output := for Host {
        @required
        $host_id

        @required
        $type

        @required
        $host

        @required
        $port = 5432

        @required
        $db

        @required
        $user

        @required
        $password

        @required
        $version
    }

    errors: [
        NoSuchResource
        BadRequest
    ]
}

@tags(["Host"])
@http(method: "POST", uri: "/api/hosts/{host_id}", code: 200)
@documentation("Update a Host, test the connection in order to get the server version. All dump on the local volume will be kept until the retention date.")
@examples([
    {
        title: "Update a Host"
        input: { host_id: "Nny3tUFGL7", type: "postgresql", host: "postgres-16", port: 5432, db: "mydb", user: "me", password: "password" }
        output: { version: "16.0" }
    }
    {
        title: "Host not found"
        input: { host_id: "IUxvYDwQV5", type: "postgresql", host: "postgres-18", port: 5432, db: "mydb", user: "me", password: "password" }
        error: {
            shapeId: NoSuchResource
            content: { code: 404, message: "Host not found" }
        }
    }
])
operation UpdateHost {
    input := for Host {
        @required
        @httpLabel
        $host_id

        $type

        $host

        $port

        $db

        $user

        $password
    }

    output := for Host {
        @required
        $version
    }

    errors: [
        NoSuchResource
    ]
}

@tags(["Host"])
@http(method: "DELETE", uri: "/api/hosts/{host_id}", code: 204)
@documentation("Delete a Host. All dumps on the local volume will also be deleted.")
@idempotent
@examples([
    {
        title: "Delete a Host"
        input: { host_id: "Nny3tUFGL7" }
    }
])
operation DeleteHost {
    input := for Host {
        @required
        @httpLabel
        $host_id
    }
}

@tags(["Host"])
@http(method: "GET", uri: "/api/hosts", code: 200)
@readonly
@documentation("Get all stored Hosts.")
@examples([
    {
        title: "Get all Hosts"
        output: {
            hosts: [
                {
                    host_id: "Nny3tUFGL7"
                    type: "postgresql"
                    host: "postgres-14"
                    port: 5432
                    db: "mydb"
                    user: "me"
                    password: "password"
                    version: "14.0"
                }
                {
                    host_id: "IUxvYDwQV5"
                    type: "postgresql"
                    host: "postgres-15"
                    port: 5432
                    db: "mydb"
                    user: "me"
                    password: "password"
                    version: "15.12"
                }
                {
                    host_id: "CiriMJSube"
                    type: "postgresql"
                    host: "postgres-16"
                    port: 5432
                    db: "mydb"
                    user: "me"
                    password: "password"
                    version: "16.0"
                }
                {
                    host_id: "y1vdUpppoo"
                    type: "postgresql"
                    host: "postgres-17"
                    port: 5432
                    db: "mydb"
                    user: "me"
                    password: "password"
                    version: "17.0"
                }
            ]
        }
    }
])
operation ListHosts {
    output := {
        hosts: HostList
    }
}

list HostList {
    member: HostStructure
}

structure HostStructure for Host {
    @required
    $host_id

    @required
    $type

    @required
    $host

    @required
    $port = 5432

    @required
    $db

    @required
    $user

    @required
    $password

    @required
    $version
}

@tags(["Dump"])
@http(method: "POST", uri: "/api/hosts/{host_id}/upload", code: 200)
@documentation("Upload a dump file for a Host.")
operation UploadDump {
    input := for Host {
        @required
        @httpLabel
        $host_id

        @required
        @httpHeader("Content-Type")
        @notProperty
        contentType: String = "multipart/form-data"

        @httpPayload
        @notProperty
        dump_file: UploadData
    }

    output := for Dump {
        @required
        @notProperty
        $dump_id

        @required
        @timestampFormat("date-time")
        @notProperty
        $created_at

        @required
        @notProperty
        $dump_path

        @required
        @notProperty
        $filesize
    }

    errors: [
        NoSuchResource
        BadRequest
    ]
}

@documentation("The SUID of the Host.")
@pattern("^[0-9a-zA-Z]{10}$")
string HostId

@documentation("The type of the Host. Can be `postgresql`.")
enum HostType {
    POSTGRESQL = "postgresql"
}

@documentation("The host name of the machine on which the server is running.")
string HostName

@documentation("The TCP port on which the server is listening for connections.")
@range(min: 0, max: 65535)
integer TcpPort

@documentation("The name of the database to dump.")
string Db

@documentation("The user name to connect as.")
string User

@documentation("The user password to connect with.")
string Password

@documentation("The version of the server running on the host.")
string Version

@mediaType("application/x-gzip")
blob UploadData
