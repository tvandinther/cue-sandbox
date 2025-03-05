package sqlite

import (
    "strconv"
)

#Course: {
    id: int
    name: string
    tags: [...string]
}

#Student: {
    id: int
    familyName: string
    givenName: string
    graduated: bool | *false
}

#Enrolment: {
    course: #Course
    student: #Student
    note: string
}

// _coursesById is not yet closed. Consider changing to definition
_coursesById: [ID= =~ "\\d+"]: #Course & {id: strconv.ParseInt(ID, 10, 32)}
courses: [for course in _coursesById {course}]

// _studentsById is not yet closed. Consider changing to definition
_studentsById: [ID= =~ "\\d+"]: #Student & {id: strconv.ParseInt(ID, 10, 32)}
students: [for student in _studentsById {student}]

_enrolmentsByStudentByCourse: [StudentId=string]: [CourseId=string]: #Enrolment & {
    course: _coursesById[CourseId]
    student: _studentsById[StudentId]
}
enrolments: [for byStudent in _enrolmentsByStudentByCourse for byCourse in byStudent {byCourse}]

_coursesById: {
    "1": {
        name: "CUE 101"
        tags: ["Computer Science", "Logic"]
    }
    "2": {
        name: "SQL 101"
        tags: ["Computer Science", "Databases"]
    }
}

_studentsById: {
    "1": {
        familyName: "Doe"
        givenName: "John"
        graduated: true
    }
    "2": {
        familyName: "Doe"
        givenName: "Jane"
    }
}

_enrolmentsByStudentByCourse: {for enrolment in _enrolmentsByStudentByCourseList {"\(enrolment.student.id)": "\(enrolment.course.id)": {enrolment}}}

_enrolmentsByStudentByCourseList: [...#Enrolment]
_enrolmentsByStudentByCourseList: [
    {
        student: _studentsById["1"]
        course: _coursesById["1"]
        note: "Special admission"
    }
]
