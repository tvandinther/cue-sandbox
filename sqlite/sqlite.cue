package sqlite

import (
    "list"
)

#Value: {
    cue: string | bool | float | int | bytes | null
    sqliteType: "TEXT" | "REAL" | "INTEGER" | "BLOB" | "NULL"
    sqlite: _ | *cue

    if (cue & string) != _|_ {
        sqliteType: "TEXT"
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
    }
    if (cue & int) != _|_ {
        sqliteType: "INTEGER"
    }
    if (cue & bytes) != _|_ {
        sqliteType: "BLOB"
    }
    if (cue & null) != _|_ {
        sqliteType: "NULL"
    }
}

#Table: {
    name: string
    columns: [...{name: string, valueMetadata: #Value}]
    values: [...[...#Value]]
    sqliteValues: [for row in values {[for value in row {value.sqlite}]}]
}

#SQL: {
    sources: [SourceName=string]: [...{...}] & list.MinItems(1)
    tables: [...#Table]

    tables: list.Concat([_entity, _associative])

    _entity: [for sourceName, source in sources {
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
            values: [for item in source {
                [for v in item if (v & [..._]) == _|_ {
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
        #Table & {
            name: "\(sourceName)_\(key)"
            columns: [{
                name: "\(sourceName)_id"
                valueMetadata: #Value & {cue: source[0].id}
            }, {
                name: key
                valueMetadata: #Value & {cue: value[0]}
            }]
            values: [for row in source for field in row if (field & [..._]) != _|_ for v in field {
                [#Value & {cue: row.id}, #Value & {cue: v}]
            }]
        }
    }]
}

sqlModel: #SQL & {
    sources: {
        "students": students
        "courses": courses
        "enrolments": enrolments
    }
}
