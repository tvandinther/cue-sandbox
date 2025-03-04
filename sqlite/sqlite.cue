package sqlite

import (
    "list"
)

#SQLiteValue: string | bool | float | int | bytes | null

#Table: {
    name: string
    headers: [...string]
    values: [...[...#SQLiteValue]]
    ...
}

#SQL: {
    sources: [SourceName=string]: [...{...}] & list.MinItems(1)
    tables: [...#Table]

    tables: list.Concat([_entity, _associative])

    _entity: [for sourceName, source in sources {
        #Table & {
            name: sourceName
            headers: [for k, v in source[0] if (v & [..._]) == _|_ {
                [
                    if (v & {...}) != _|_ { // if is struct
                        "\(k)_id"
                    },
                    { // else
                        k
                    }
                ][0]
            }]
            values: [for item in source {
                [for v in item if (v & [..._]) == _|_ {
                    [
                        if (v & {...}) != _|_ { // if is struct
                            v.id
                        },
                        { // else
                            v
                        }
                    ][0]
                }]
            }]
        }
    }]

    _associative: [for sourceName, source in sources for key, value in source[0] if (value & [..._]) != _|_ {
        #Table & {
            name: "\(sourceName)_\(key)"
            headers: ["\(sourceName)_id", key]
            values: [for row in source for field in row if (field & [..._]) != _|_ for v in field {
                [row.id, v]
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
