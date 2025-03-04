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
}

#Enrolment: {
    course: #Course
    student: #Student
    note: string
}

_coursesById: [ID=string]: #Course & {id: strconv.ParseInt(ID, 10, 32)}
courses: [for course in _coursesById {course}]

_studentsById: [ID=string]: #Student & {id: strconv.ParseInt(ID, 10, 32)}
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
