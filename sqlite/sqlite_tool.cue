package sqlite

import (
    "list"
    "tool/exec"
    "tool/file"
    "encoding/csv"
)

command: sql: {
    mkTemp: file.MkdirTemp

    writeTables: [for table in sqlModel.tables {
        file.Create & {
            filename: "\(mkTemp.path)/\(table.name).csv"
            contents: csv.Encode(list.Concat([[table.headers], table.values]))
        }
    }]

    execute: exec.Run & {
        $dependsOn: [writeTables]
        mustSucceed: false
        cmd: list.Concat([["sqlite3", ":memory:", "-header", "-table"], list.FlattenN([for table in sqlModel.tables {["-cmd", ".import \(mkTemp.path)/\(table.name).csv \(table.name) --csv"]}], 1)])
    }

    clean: file.RemoveAll & {
        $dependsOn: [execute]
        path: mkTemp.path
    }
}
