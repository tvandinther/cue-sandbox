package sqlite

import (
    "list"
)

#Value: {
    CUEValue: string | bool | float | int | bytes | null
    SQLiteDataType: "TEXT" | "REAL" | "INTEGER" | "BLOB" | "NULL"
    value: _ | *CUEValue

    if (CUEValue & string) != _|_ {
        SQLiteDataType: "TEXT"
    }
    if (CUEValue & bool) != _|_ {
        SQLiteDataType: "INTEGER"
        if CUEValue {
            value: 1
        }
        if !CUEValue {
            value: 0
        }
    }
    if (CUEValue & float) != _|_ {
        SQLiteDataType: "REAL"
    }
    if (CUEValue & int) != _|_ {
        SQLiteDataType: "INTEGER"
    }
    if (CUEValue & bytes) != _|_ {
        SQLiteDataType: "BLOB"
    }
    if (CUEValue & null) != _|_ {
        SQLiteDataType: "NULL"
    }
}

#Table: {
    name: string
    // headers: [...string]
    columns: [...{name: string, valueMetadata: #Value, ...}]
    values: [...[...#Value]]
    rawValues: [for row in values {[for value in row {value.value}]}]
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
                        valueMetadata: #Value & {CUEValue: v.id}
                    },
                    { // else
                        name: k
                        valueMetadata: #Value & {CUEValue: v}
                    }
                ][0]
            }]
            values: [for item in source {
                [for v in item if (v & [..._]) == _|_ {
                    [
                        if (v & {...}) != _|_ { // if is struct
                            #Value & {CUEValue: v.id}
                        },
                        { // else
                            #Value & {CUEValue: v}
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
                valueMetadata: #Value & {CUEValue: source[0].id}
            }, {
                name: key
                valueMetadata: #Value & {CUEValue: value[0]}
            }]
            values: [for row in source for field in row if (field & [..._]) != _|_ for v in field {
                [#Value & {CUEValue: row.id}, #Value & {CUEValue: v}]
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
