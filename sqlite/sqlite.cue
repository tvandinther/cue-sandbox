package sqlite

import (
    "list"
    "strings"
)

#Value: {
    cue: string | bool | float | int | bytes | null
    sqliteType: "TEXT" | "REAL" | "INTEGER" | "BLOB" | "NULL"
    sqlite: string | float | int | null// | *cue

    if (cue & string) != _|_ {
        sqliteType: "TEXT"
        sqlite: cue
    }
    if (cue & int) != _|_ {
        sqliteType: "INTEGER"
        sqlite: cue
    }
    if (cue & bool) != _|_ {
        sqliteType: "INTEGER"
        if cue {
            sqlite: 1
        }
        if !cue {
            sqlite: 0
        }
    }
    if (cue & float) != _|_ {
        sqliteType: "REAL"
        sqlite: cue
    }
    if (cue & bytes) != _|_ {
        sqliteType: "BLOB"
        sqlite: cue
    }
    if (cue & null) != _|_ {
        sqliteType: "NULL"
        sqlite: cue
    }
}

#Table: {
    name: string
    columns: [...{name: string, valueMetadata: #Value}]
    values: [...[...#Value]]
    sqliteValues: [for row in values {[for value in row {value.sqlite}]}]
}

#SQL: {
    sources: [SourceName=string]: [...{...}] & list.MinItems(1) // must have at least one record/row for inference
    tables: [...#Table]
    tableDDL: [...string]

    tables: list.Concat([_entity, _associative])

    _entity: [for sourceName, source in sources {
        let keys = [for k, _ in source[0] {k}]
        #Table & {
            name: sourceName
            columns: [for k, v in source[0] if (v & [..._]) == _|_ {
                [
                    if (v & {...}) != _|_ { // if is struct
                        name: "\(k)_id"
                        valueMetadata: #Value & {cue: v.id}
                    },
                    { // else
                        name: k
                        valueMetadata: #Value & {cue: v}
                    }
                ][0]
            }]
            values: [for row in source {
                [for k in keys if (row[k] & [..._]) == _|_ {
                    let v = row[k]
                    [
                        if (v & {...}) != _|_ { // if is struct
                            #Value & {cue: v.id}
                        },
                        { // else
                            #Value & {cue: v}
                        }
                    ][0]
                }]
            }]
        }
    }]

    _associative: [for sourceName, source in sources for key, value in source[0] if (value & [..._]) != _|_ {
        let keys = [for k, _ in source[0] {k}]
        #Table & {
            name: "\(sourceName)_\(key)"
            columns: [{
                name: "\(sourceName)_id"
                valueMetadata: #Value & {cue: source[0].id}
            }, {
                name: key
                valueMetadata: #Value & {cue: value[0]}
            }]
            values: [for row in source for k in keys if (row[k] & [..._]) != _|_ for v in row[k] {
                [#Value & {cue: row.id}, #Value & {cue: v}]
            }]
        }
    }]

    tableDDL: [for table in tables {
        let columns = strings.Join([for column in table.columns {"\(column.name) \(column.valueMetadata.sqliteType)"}], ", ")
        
        """
        CREATE TABLE \(table.name) (\(columns));
        """
    }]

    // inserts: [for table in tables {
    //     let columnSeperator = ",\n"
    //     let valueSeperator = ", "

    //     let columns = strings.Join([for column in table.columns {column.name}], columnSeperator)
    //     let values = strings.Join([for row in table.values {"(\(strings.Join([for value in row {"\(value.sqlite)"}], valueSeperator)))"}], columnSeperator)

    //     """
    //     INSERT INTO \(table.name) (
    //         \(columns)
    //     )
    //     VALUES
    //         \(values);
    //     """
    // }]
}

sqlModel: #SQL & {
    sources: {
        "students": students
        "courses": courses
        "enrolments": enrolments
    }
}
