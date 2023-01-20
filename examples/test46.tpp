local := R[50..90]

def circleCenter3Points(x1,y1,z1,x2,y2,z2,x3,y3,z3) : numreg, numreg, numreg 
    a := LR[]
    b := LR[]
    c := LR[]
    d := LR[]
    x := LR[]
    y := LR[]
    z := LR[]
    
    # solving the equation of a circle passing through three points.
    # A * x2 + A * y2 + B * x + C* y + D = 0
    a = x1 * (y2 - y3) - y1 * (x2 - x3) + x2 * y3 - x3 * y2
    b = (Mth::pow(x1, 2) + Mth::pow(y1, 2)) * (y3 - y2)
    c = (Mth::pow(x1, 2) + Mth::pow(y1, 2)) * (x2 - x3)
    d = (Mth::pow(x3, 2) + Mth::pow(y3, 2)) * (x2 * y1 - x1 * y2)
    
    x = -b / (a * 2)    # x component of the center
    y = -c / (a * 2)    # y component of the center
    z = (z1+z2+z3)/3    # averaging the z comp., because all three points will allways lie in same plane which perpendicular to robot flange.

    return(x, y, z)
end

center := R[30..33]

X1 := -0.00000252127529
Y1 := 0.0716490895
Z1 := 0.566001117
X2 := 0.0719940
Y2 := -0.04156384
Z2 := 0.56600052
X3 := -0.06479058
Y3 := -0.03740988
Z3 := 0.56600016

center = circleCenter3Points(X1,Y1,Z1,X2,Y2,Z3,X3,Y3,Z3)