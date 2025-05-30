$version: "2.0"

namespace saashup

resource Dump {
    identifiers: {
        dump_id: DumpId
        host_id: HostId
    }
    properties: {
        dump_path: DumpPath
        filesize: Filesize
        created_at: Timestamp
    }
    create: CreateDump
    read: DownloadDump
    delete: DeleteDump
    list: ListDumps
    operations: [
        RestoreDump
    ]
}

@tags(["Dump"])
@http(method: "POST", uri: "/api/hosts/{host_id}/dump", code: 202)
@documentation("Create a new Dump for a Host.")
@examples([
    {
        title: "Create a new Dump"
        input: { host_id: "Nny3tUFGL7" }
        output: { dump_id: "6mUNSKuj5i", created_at: "2025-05-21T14:48:00.000Z" }
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
operation CreateDump {
    input := for Host {
        @required
        @httpLabel
        $host_id
    }

    output := for Dump {
        @required
        $dump_id

        @required
        @timestampFormat("date-time")
        $created_at

        $dump_path

        $filesize
    }

    errors: [
        NoSuchResource
    ]
}

@tags(["Dump"])
@http(method: "GET", uri: "/api/hosts/{host_id}/dumps/{dump_id}", code: 200)
@documentation("Download a Dump.")
@readonly
@examples([
    {
        title: "Download a host dump file"
        input: { host_id: "Nny3tUFGL7", dump_id: "IUxvYDwQV5" }
        output: { content_disposition: "attachment; filename=\"1747731292920_Nny3tUFGL7_postgresql_postgres-14_14.18_mydb.sql.tar.gz\"", content: "..." }
    }
    {
        title: "Dump not found"
        input: { host_id: "IUxvYDwQV5", dump_id: "1Ade87BB98" }
        error: {
            shapeId: NoSuchResource
            content: { code: 404, message: "Host not found" }
        }
    }
])
operation DownloadDump {
    input := for Dump {
        @required
        @httpLabel
        $host_id

        @required
        @httpLabel
        $dump_id
    }

    output := {
        @required
        @httpHeader("Content-Disposition")
        @notProperty
        content_disposition: String

        @required
        @httpPayload
        @notProperty
        content: DownloadData
    }

    errors: [
        NoSuchResource
    ]
}

@tags(["Dump"])
@http(method: "DELETE", uri: "/api/hosts/{host_id}/dumps/{dump_id}", code: 204)
@idempotent
@documentation("Download a Dump.")
@examples([
    {
        title: "Delte a host dump file"
        input: { host_id: "Nny3tUFGL7", dump_id: "IUxvYDwQV5" }
    }
    {
        title: "Dump not found"
        input: { host_id: "IUxvYDwQV5", dump_id: "1Ade87BB98" }
        error: {
            shapeId: NoSuchResource
            content: { code: 404, message: "Host not found" }
        }
    }
])
operation DeleteDump {
    input := for Dump {
        @required
        @httpLabel
        $host_id

        @required
        @httpLabel
        $dump_id
    }

    errors: [
        NoSuchResource
    ]
}

@tags(["Dump"])
@http(method: "GET", uri: "/api/hosts/{host_id}/dumps", code: 200)
@readonly
@documentation("Get dumps for a given host")
@examples([
    {
        title: "Get dumps for a given host"
        input: { host_id: "RsTHAFv375" }
        output: {
            dumps: [
                {
                    host_id: "RsTHAFv375"
                    dump_id: "74mvb32P9e"
                    created_at: "2025-05-20T14:46:17.143Z"
                    dump_path: "/dumps/RsTHAFv375/2025/05/20/1747752377143_RsTHAFv375_postgresql_postgres-14_14.18_mydb.sql.tar.gz"
                    filesize: 453
                }
                {
                    host_id: "RsTHAFv375"
                    dump_id: "yph1Ct7zj2"
                    created_at: "2025-05-20T14:46:20.511Z"
                    dump_path: "/dumps/RsTHAFv375/2025/05/20/1747752380511_RsTHAFv375_postgresql_postgres-14_14.18_mydb.sql.tar.gz"
                    filesize: 452
                }
            ]
        }
    }
])
operation ListDumps {
    input := for Dump {
        @required
        @httpLabel
        $host_id
    }

    output := {
        dumps: DumpList
    }
}

list DumpList {
    member: DumpStructure
}

structure DumpStructure for Dump {
    @required
    $host_id

    @required
    $dump_id

    @required
    @timestampFormat("date-time")
    $created_at

    $dump_path

    $filesize
}

@tags(["Dump"])
@http(method: "POST", uri: "/api/hosts/{host_id}/dumps/{dump_id}/restore", code: 202)
@documentation("Restore a dump")
@examples([
    {
        title: "Restore a dump"
        input: { host_id: "RsTHAFv375", dump_id: "74mvb32P9e" }
        output: {
        }
    }
    {
        title: "Dump not found"
        input: { host_id: "IUxvYDwQV5", dump_id: "1Ade87BB98" }
        error: {
            shapeId: NoSuchResource
            content: { code: 404, message: "Host not found" }
        }
    }
])
operation RestoreDump {
    input := for Dump {
        @required
        @httpLabel
        $host_id

        @required
        @httpLabel
        $dump_id
    }

    output := {}

    errors: [
        NoSuchResource
    ]
}

@documentation("The SUID of the Dump")
@pattern("^[0-9a-zA-Z]{10}$")
string DumpId

@documentation("The path of the dump file")
@pattern("^\/[0-9AZa-z_-]+\/[0-9a-zA-Z]{10}\/\\d{4}\/\\d{2}\/\\d{2}\/\\d+_[0-9a-zA-Z]{10}_(postgresql)_(.*)_(14|15|16|17)\\.\\d{1,2}_(.*)\\.tar\\.gz$")
string DumpPath

@documentation("The size of the dump file in Bytes")
integer Filesize

@mediaType("application/gzip")
blob DownloadData
