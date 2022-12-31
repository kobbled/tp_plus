local := R[50..80]

namespace Calc

  inline def normalize(n1,n2,n3,e1,e2,e3)
    norm := LR[]
    
    norm = Mth::sqrt(n1*n1 + n2*n2 + n3*n3)
    indirect('r', e1) = n1/norm
    indirect('r', e2) = n2/norm
    indirect('r', e3) = n3/norm
  end

  inline def dot(nix,niy,niz,vix,viy,viz) : numreg
      return(nix*vix + niy*viy + niz*viz)
  end

  inline def intersect(x1,y1,z1,x2,y2,z2,nx,ny,nz)
    ux := LR[]
    uy := LR[]
    uz := LR[]
    vx := LR[]
    vy := LR[]
    vz := LR[]
    d  := LR[]

    # vector from two points
    vx=x2-x1
    vy=y2-y1
    vz=z2-z1

    normalize(vx,vy,vz,&ux,&uy,&uz)  # unit vector
    d = dot(nx,ny,nz,ux,uy,uz)  # dot product
  end
end

X1 := -0.30694321232747335
Y1 := 1.6723049456001353
Z1 := 1.432745154010752
X2 := -0.7868785787889008
Y2 := 1.7975569490378929
Z2 := 1.44473503116485
CX := -0.23966969549655914
CY := 1.6529096364974976
CZ := 1.438263177871704

Calc::intersect(X1,Y1,Z1,X2,Y2,Z2,CX,CY,CZ)
