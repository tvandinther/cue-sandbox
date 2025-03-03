package sqlite

import (
    "list"
    "tool/exec"
    "tool/file"
    "encoding/csv"
)

tables: {
    "users": users
}

command: sql: {
    mkTemp: file.MkdirTemp

    writeTables: [for name, table in tables {
        file.Create & {
            filename: "\(mkTemp.path)/\(name).csv"
            contents: csv.Encode([
                [for k, _ in table[0] {k}],
                [for item in table for v in item {v}]
            ])
        }
    }]

    execute: exec.Run & {
        $dependsOn: [writeTables]
        mustSucceed: false
        cmd: list.Concat([["sqlite3", ":memory:", "-header", "-table"], list.FlattenN([for name, _ in tables {["-cmd", ".import \(mkTemp.path)/\(name).csv \(name) --csv"]}], 1)])
    }

    clean: file.RemoveAll & {
        $dependsOn: [execute]
        path: mkTemp.path
    }
}
