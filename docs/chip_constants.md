A list of some basic equations and constants I have found useful in my life as a chip and board designer. 

## Basic Laws

| Rule                               | Value                                 |
|------------------------------------|---------------------------------------|
| Speed of light                     | c = 299,792,458 m/s (~3.00x10^8 m/s)  |
| Vacuum permitivity                 | eps0 = 8.854187817 x 10-12 F/m        | 
| Vacuum permeability                | u0   = 4pi x 10-7 H / m or (V*s/A*m)  |
| Time of Flight (air)               | 3.35 ps/mm                            |
| Time of Flight (FR4-inner layer)   | 7.09 ps/mm                            |
| Capacitance (parallel plate)       | C = k * eps0 * Area / d               |
| Inductance (wire/ground plan)      | L = (u/2pi) * ln ( 4 * h / d)         |
| Capacitor current                  | I = C * dV / dt                       |
| Inductor voltage                   | V = L * dI / dt                       |
| Resistor voltage                   | V = I * R                             |
| Charge on capacitor                | Q = C * V                             |
| Power                              | P = I * V                             |
| Dynaminc power for capacitive load | P = Freq * Cap * VDD^2                |
| Energy                             | E = P * t                             |

## Board Design
| Rule                               | Value                                 |
|------------------------------------|---------------------------------------|
| Lumped system rule of thumb (mm)   | length < 1/6*Rise_time/time_of_flight |

## Chip Design

| Rule                                | Value                                 |
|-------------------------------------|---------------------------------------|
| De Morgan's Law                     | ~(A & B) =~A or ~B, ~(A or B) =~A &~B |
| RC delay                            | (0.35) * res/um * cap/um * L(um)^2    |
| Relative permitivity (SiO2)         | 3.9                                   |
| Relative permitivity (Si)           | 11.68                                 |
| Line capacitance / mm (max density) |           (highly variable!)          |
| Line resistance  / mm (fat layer)   |           (copper, highly variable!)  |



## Interconnects

| Rule                                | Value                                 |
|-------------------------------------|---------------------------------------|
| Chip wire pitch                     | ~0.1um                                |
| 2.5D wire pitch                     | 4um                                   |
| Wirebond pitch                      | 30um                                  |
| 2.5D Bump pitch                     | 45um                                  |
| Flip-chip pitch                     | 170um                                 |
| BGA pitch (advanced)                | 400um                                 |
| BGA pitch (standard)                | 1000um                                |
| Hobby "solderable" connector        | 2540um                                |
| Ethernet connector                  | ~10,000um                             |







