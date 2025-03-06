package sqlite

import (
    "strconv"
)

sqlModel: #SQL & {
    sources: {
        "students": students
        "faculties": faculties
        "courses": courses
        "enrolments": enrolments
    }
}

#Faculty: {
    id: int
    name: string
}

#Course: {
    id: int & >0
    name: string
    faculty: #Faculty
    tags: [...string]
}

#Student: {
    id: int & >0
    familyName: string
    givenName: string
    graduated: bool | *false
}

#Enrolment: {
    course: #Course
    student: #Student
    note: string | *""
}

#FacultyIndex: [ID= =~ "^\\d+$"]: #Faculty & {id: strconv.ParseInt(ID, 10, 32)}
_facultiesById: #FacultyIndex
faculties: [for faculty in _facultiesById {faculty}]

#CoursesIndex: [ID= =~ "^\\d+$"]: #Course & {id: strconv.ParseInt(ID, 10, 32)}
_coursesById: #CoursesIndex
courses: [for course in _coursesById {course}]

#StudentsIndex: [ID= =~ "^\\d+$"]: #Student & {id: strconv.ParseInt(ID, 10, 32)}
_studentsById: #StudentsIndex
students: [for student in _studentsById {student}]

_enrolmentsByStudentIdByCourseId: [StudentId= =~ "^\\d+$"]: [CourseId= =~ "^\\d+$"]: #Enrolment & {
    course: _coursesById[CourseId]
    student: _studentsById[StudentId]
}
enrolments: [for byStudent in _enrolmentsByStudentIdByCourseId for byCourse in byStudent {byCourse}]

_facultiesById: {
    "1": {name: "Science"}
}

_coursesById: {
    "1": {
        name: "CUE 101"
        faculty: _facultiesById["1"]
        tags: ["Computer Science", "Logic"]
    }
    "2": {
        name: "SQL 101"
        faculty: _facultiesById["1"]
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

_enrolmentsByStudentIdByCourseId: "1": "1": note: "Special admission"
