package sqlite

#Course: {
    id: string
    name: string
    tags: [...string]
}

#Student: {
    id: string
    familyName: string
    givenName: string
}

#Enrolment: {
    course: #Course
    student: #Student
    note: string
}

_coursesById: [ID=string]: #Course & {id: ID}
courses: [for course in _coursesById {course}]

_studentsById: [ID=string]: #Student & {id: ID}
students: [for student in _studentsById {student}]

_enrolmentsByStudentByCourse: [StudentId=#Student.id]: [CourseId=#Course.id]: #Enrolment & {
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

 _enrolmentsByStudentByCourse: (_studentsById["1"].id): (_coursesById["1"].id): note: "Test"
// _enrolmentsByStudentByCourse: {for enrolment in _enrolmentsByStudentByCourseList {(enrolment.student.id): (enrolment.course.id): {enrolment}}}

_enrolmentsByStudentByCourseList: [...#Enrolment]
_enrolmentsByStudentByCourseList: [
    {
        student: _studentsById["1"]
        course: _coursesById["1"]
        note: "test"
    }
]
