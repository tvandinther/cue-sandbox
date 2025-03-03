#CelsiusToFahrenheit: {
  in: float

  out: in * (9/5) + 32
}

temperature: (#CelsiusToFahrenheit & {in: 18}).out

#Temperature: {
  kelvin: float & celsius + 273.15
  celsius: float & kelvin - 273.15 & (fahrenheit -32) * (5/9)
  fahrenheit: float & celsius * (9/5) + 32
}

c: #Temperature
c: celsius: 20.0
inFahrenheit: c.fahrenheit

k: #Temperature
k: kelvin: 293.15

f: #Temperature
f: fahrenheit: 68.0
